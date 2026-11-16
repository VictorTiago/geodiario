// Import usado nos materiais da disciplina; compatível com versões anteriores
// do Flutter (a partir do 3.47 o Material também existe no pacote material_ui).
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/registro_card.dart';
import '../providers/registros_provider.dart';
import 'detalhe_screen.dart';
import 'novo_registro_screen.dart';

/// Tela inicial: galeria com todos os registros salvos (RF04).
class GaleriaScreen extends StatelessWidget {
  const GaleriaScreen({super.key});

  Future<void> _novoRegistro(BuildContext context) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NovoRegistroScreen()),
    );
    if (salvou == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegistrosProvider>();
    final registros = provider.todos;

    Widget corpo;
    if (provider.carregando && registros.isEmpty) {
      corpo = const Center(child: CircularProgressIndicator());
    } else if (registros.isEmpty) {
      corpo = const _GaleriaVazia();
    } else {
      corpo = RefreshIndicator(
        onRefresh: provider.carregar,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: registros.length,
          itemBuilder: (context, index) {
            final registro = registros[index];
            return RegistroCard(
              registro: registro,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetalheScreen(registro: registro),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoDiário'),
        centerTitle: true,
        actions: [
          if (registros.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${registros.length} '
                  '${registros.length == 1 ? 'registro' : 'registros'}',
                ),
              ),
            ),
        ],
      ),
      body: corpo,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _novoRegistro(context),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nova foto'),
      ),
    );
  }
}

class _GaleriaVazia extends StatelessWidget {
  const _GaleriaVazia();

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, size: 80, color: cor),
            const SizedBox(height: 16),
            Text(
              'Nenhum registro ainda',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Toque em "Nova foto" para fotografar um lugar ou momento. '
              'A data, a hora e a localização serão registradas automaticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cor),
            ),
          ],
        ),
      ),
    );
  }
}
