import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Serviço de captura de fotografias e gerenciamento dos arquivos de imagem.
class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Abre a câmera do dispositivo e retorna o arquivo temporário da foto,
  /// ou `null` se o usuário cancelar.
  Future<File?> tirarFoto() async {
    final XFile? foto = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920, // Reduz o tamanho do arquivo sem perder qualidade visível.
      imageQuality: 85,
    );
    return foto == null ? null : File(foto.path);
  }

  /// Copia a foto (que o image_picker deixa em uma pasta temporária/cache)
  /// para a pasta de documentos do aplicativo, onde ela fica guardada de forma
  /// permanente. Retorna o caminho definitivo, que será salvo no SQLite.
  Future<String> salvarFotoPermanente(File fotoTemporaria) async {
    final pastaDocumentos = await getApplicationDocumentsDirectory();
    final pastaFotos = Directory(p.join(pastaDocumentos.path, 'fotos'));
    if (!await pastaFotos.exists()) {
      await pastaFotos.create(recursive: true);
    }

    final extensao = p.extension(fotoTemporaria.path).isEmpty
        ? '.jpg'
        : p.extension(fotoTemporaria.path);
    final nomeArquivo =
        'geo_${DateTime.now().millisecondsSinceEpoch}$extensao';
    final destino = p.join(pastaFotos.path, nomeArquivo);

    final copia = await fotoTemporaria.copy(destino);
    return copia.path;
  }

  /// Exclui o arquivo de imagem do armazenamento local, se ele existir.
  Future<void> excluirFoto(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) {
      await arquivo.delete();
    }
  }
}
