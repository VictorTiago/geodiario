// Import usado nos materiais da disciplina; compatível com versões anteriores
// do Flutter (a partir do 3.47 o Material também existe no pacote material_ui).
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/foto_registro.dart';
import '../models/registro.dart';
import '../providers/registros_provider.dart';
import '../utils/formatadores.dart';

/// Tela de visualização de um registro, com opção de exclusão (RF05).
class DetalheScreen extends StatelessWidget {
  final Registro registro;

  const DetalheScreen({super.key, required this.registro});

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever),
        title: const Text('Excluir registro'),
        content: Text(
          'Deseja excluir "${registro.titulo}"?\n\n'
          'A foto também será apagada do dispositivo. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<RegistrosProvider>().excluir(registro);
      if (context.mounted) Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Registro excluído com sucesso!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao excluir o registro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: () => _confirmarExclusao(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          Hero(
            tag: 'foto_${registro.id}',
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: Colors.black,
                child: FotoRegistro(
                  caminho: registro.caminhoFoto,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              registro.titulo,
              style: tema.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (registro.descricao.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(registro.descricao, style: tema.textTheme.bodyLarge),
            ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Data e hora'),
            subtitle: Text(Formatadores.dataHora(registro.dataHora)),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.redAccent),
            title: const Text('Coordenadas'),
            subtitle: Text(
              'Latitude: ${Formatadores.coordenada(registro.latitude)}\n'
              'Longitude: ${Formatadores.coordenada(registro.longitude)}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Arquivo'),
            subtitle: Text(
              registro.caminhoFoto,
              style: tema.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
