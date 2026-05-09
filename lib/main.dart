import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'features/auth/data/repos/auth_repo_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/mess/presentation/bloc/mess_bloc.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MessManagerApp());
}

class MessManagerApp extends StatelessWidget {
  const MessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // AuthBloc — সবার আগে
        BlocProvider(
          create: (_) => AuthBloc(AuthRepoImpl())
            ..add(AuthCheckRequested()),
        ),
        // MessBloc — Dashboard ও Setup এর জন্য
        BlocProvider(
          create: (_) => MessBloc(),
        ),
      ],
      child: Builder(builder: (ctx) {
        final router = createRouter(ctx);
        return MaterialApp.router(
          title: 'MessManager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF534AB7),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      }),
    );
  }
}