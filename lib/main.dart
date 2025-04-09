import 'package:flutter/material.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/database/app_database.dart';
import 'data/database/supabase_config.dart';
import 'presentation/factories/provider_factory.dart';
import 'domain/factories/service_factory.dart';
import 'utils/connectivity_helper.dart';
import 'utils/app_theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'presentation/views/screens/splash_screen.dart';
import 'presentation/views/screens/login_screen.dart';
import 'presentation/views/screens/main_screen.dart';
import 'presentation/views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar a localização para português (Brasil)
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // Carregar variáveis de ambiente
  //  await dotenv.load(fileName: ".env");

  // Inicializar o sqflite para Windows
  databaseFactory = databaseFactoryFfi;

  // Inicializar o banco de dados
  final appDatabase = AppDatabase();
  await appDatabase.database;

  // Inicializar o Supabase
  await SupabaseConfig.initialize();

  // Inicializar verificação de conectividade
  final connectivityHelper = ConnectivityHelper();
  await connectivityHelper.initialize();

  // Inicializar o gerenciador de sincronização
  final syncManager = ServiceFactory.createSyncManager();

  // Configurar sincronização automática
  syncManager.setupConnectivitySync();

  // Obter intervalo de sincronização das variáveis de ambiente ou usar padrão
  final syncIntervalMinutes = 15;
  syncManager.startPeriodicSync(period: Duration(minutes: syncIntervalMinutes));

  // Executar primeira sincronização se estiver online
  if (connectivityHelper.isConnected) {
    await syncManager.syncAll();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProviderFactory.createProviders(),
      child: MaterialApp(
        title: 'Flora App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
