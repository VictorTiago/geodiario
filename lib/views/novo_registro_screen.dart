import 'dart:io';

// Import usado nos materiais da disciplina; compatível com versões anteriores
// do Flutter (a partir do 3.47 o Material também existe no pacote material_ui).
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/registro.dart';
import '../providers/registros_provider.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../utils/formatadores.dart';

/// Tela de criação de um registro (RF01, RF02 e RF03).
///
/// Fluxo: tirar a foto → o app registra a data/hora e busca o GPS
/// automaticamente → o usuário informa título/descrição → salvar.
class NovoRegistroScreen extends StatefulWidget {
  const NovoRegistroScreen({super.key});

  @override
  State<NovoRegistroScreen> createState() => _NovoRegistroScreenState();
}

class _NovoRegistroScreenState extends State<NovoRegistroScreen> {
  final _cameraService = CameraService();
  final _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  File? _foto;
  DateTime? _dataHora;
  Position? _posicao;
  bool _buscandoLocalizacao = false;
  LocalizacaoException? _erroLocalizacao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Abre a câmera assim que a tela é exibida, agilizando o registro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tirarFoto());
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  /// RF01 – captura a foto e dispara a obtenção da data/hora e do GPS (RF02).
  Future<void> _tirarFoto() async {
    try {
      final foto = await _cameraService.tirarFoto();
      if (foto == null) return; // Usuário cancelou a câmera.
      setState(() {
        _foto = foto;
        _dataHora = DateTime.now();
      });
      await _buscarLocalizacao();
    } catch (e) {
      _mostrarMensagem('Não foi possível acessar a câmera: $e');
    }
  }

  /// RF02 – obtém latitude e longitude pelo GPS.
  Future<void> _buscarLocalizacao() async {
    setState(() {
      _buscandoLocalizacao = true;
      _erroLocalizacao = null;
    });
    try {
      final posicao = await _locationService.obterPosicaoAtual();
      if (!mounted) return;
      setState(() => _posicao = posicao);
    } on LocalizacaoException catch (e) {
      if (!mounted) return;
      setState(() => _erroLocalizacao = e);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _erroLocalizacao =
            LocalizacaoException('Erro ao obter localização: $e'),
      );
    } finally {
      if (mounted) setState(() => _buscandoLocalizacao = false);
    }
  }

  /// RF03 – copia a foto para o armazenamento do app e grava o registro no SQLite.
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_foto == null || _posicao == null || _dataHora == null) return;

    // Obtém o provider antes dos `await` para não usar o context depois deles.
    final provider = context.read<RegistrosProvider>();
    setState(() => _salvando = true);
    try {
      final caminho = await _cameraService.salvarFotoPermanente(_foto!);
      final registro = Registro(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        caminhoFoto: caminho,
        dataHora: _dataHora!,
        latitude: _posicao!.latitude,
        longitude: _posicao!.longitude,
      );
      await provider.adicionar(registro);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _mostrarMensagem('Erro ao salvar o registro: $e');
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  bool get _podeSalvar =>
      _foto != null && _posicao != null && !_salvando && !_buscandoLocalizacao;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Revalida enquanto o usuário digita, removendo o aviso de erro
          // assim que o título é preenchido.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _AreaFoto(foto: _foto, onTirarFoto: _salvando ? null : _tirarFoto),
              const SizedBox(height: 16),
              if (_foto != null) ...[
                _InfoAutomatica(
                  dataHora: _dataHora,
                  posicao: _posicao,
                  buscando: _buscandoLocalizacao,
                  erro: _erroLocalizacao,
                  onTentarNovamente: _buscarLocalizacao,
                  onAbrirConfiguracoes: _locationService.abrirConfiguracoesDoApp,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tituloController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe um título para o registro.'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descricaoController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (opcional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _podeSalvar ? _salvar : null,
                  icon: _salvando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar registro'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pré-visualização da foto ou botão para abrir a câmera.
class _AreaFoto extends StatelessWidget {
  final File? foto;
  final VoidCallback? onTirarFoto;

  const _AreaFoto({required this.foto, required this.onTirarFoto});

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    if (foto == null) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Material(
          color: esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTirarFoto,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, size: 56, color: esquema.primary),
                const SizedBox(height: 8),
                const Text('Toque para tirar uma foto'),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.file(foto!, fit: BoxFit.cover),
          ),
        ),
        TextButton.icon(
          onPressed: onTirarFoto,
          icon: const Icon(Icons.refresh),
          label: const Text('Tirar outra foto'),
        ),
      ],
    );
  }
}

/// Exibe as informações obtidas automaticamente: data/hora e coordenadas.
class _InfoAutomatica extends StatelessWidget {
  final DateTime? dataHora;
  final Position? posicao;
  final bool buscando;
  final LocalizacaoException? erro;
  final VoidCallback onTentarNovamente;
  final VoidCallback onAbrirConfiguracoes;

  const _InfoAutomatica({
    required this.dataHora,
    required this.posicao,
    required this.buscando,
    required this.erro,
    required this.onTentarNovamente,
    required this.onAbrirConfiguracoes,
  });

  @override
  Widget build(BuildContext context) {
    Widget localizacao;
    if (buscando) {
      localizacao = const ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        title: Text('Obtendo localização...'),
        subtitle: Text('Aguarde o sinal do GPS'),
      );
    } else if (erro != null) {
      localizacao = ListTile(
        leading: const Icon(Icons.location_off, color: Colors.red),
        title: const Text('Localização não obtida'),
        subtitle: Text(erro!.mensagem),
        trailing: erro!.abrirConfiguracoes
            ? IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Abrir configurações',
                onPressed: onAbrirConfiguracoes,
              )
            : IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Tentar novamente',
                onPressed: onTentarNovamente,
              ),
      );
    } else if (posicao != null) {
      localizacao = ListTile(
        leading: const Icon(Icons.location_on, color: Colors.redAccent),
        title: const Text('Localização'),
        subtitle: Text(
          'Latitude: ${Formatadores.coordenada(posicao!.latitude)}\n'
          'Longitude: ${Formatadores.coordenada(posicao!.longitude)}',
        ),
      );
    } else {
      localizacao = const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Data e hora'),
            subtitle: Text(
              dataHora == null ? '-' : Formatadores.dataHora(dataHora!),
            ),
          ),
          const Divider(height: 1),
          localizacao,
        ],
      ),
    );
  }
}
