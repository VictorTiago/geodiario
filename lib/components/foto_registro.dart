import 'dart:io';

// Import usado nos materiais da disciplina; compatível com versões anteriores
// do Flutter (a partir do 3.47 o Material também existe no pacote material_ui).
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

/// Exibe a foto a partir do caminho local, com um aviso caso o arquivo
/// não exista mais (por exemplo, se tiver sido apagado fora do app).
class FotoRegistro extends StatelessWidget {
  final String caminho;
  final BoxFit fit;

  const FotoRegistro({super.key, required this.caminho, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(caminho),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, size: 40),
            SizedBox(height: 4),
            Text('Imagem indisponível'),
          ],
        ),
      ),
    );
  }
}
