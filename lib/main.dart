// Import usado nos materiais da disciplina; compatível com versões anteriores
// do Flutter (a partir do 3.47 o Material também existe no pacote material_ui).
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/registros_provider.dart';
import 'views/galeria_screen.dart';

void main() {
  runApp(const GeoDiarioApp());
}

class GeoDiarioApp extends StatelessWidget {
  const GeoDiarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Cria o provider e já carrega os registros salvos no SQLite.
        ChangeNotifierProvider<RegistrosProvider>(
          create: (_) => RegistrosProvider()..carregar(),
        ),
      ],
      child: MaterialApp(
        title: 'GeoDiário',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const GaleriaScreen(),
      ),
    );
  }
}
