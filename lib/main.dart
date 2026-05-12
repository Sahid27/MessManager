import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'app/router.dart';

import 'features/auth/data/repos/auth_repo_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

import 'features/costs/presentation/bloc/cost_bloc.dart';
import 'features/meals/presentation/bloc/meal_bloc.dart';
import 'features/mess/presentation/bloc/mess_bloc.dart';
import 'features/summary/presentation/bloc/summary_bloc.dart';

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
        BlocProvider(
          create: (_) => AuthBloc(AuthRepoImpl())
            ..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => MessBloc()),
        BlocProvider(create: (_) => MealBloc()),
        BlocProvider(create: (_) => CostBloc()),
        BlocProvider(create: (_) => SummaryBloc()),
      ],
      child: Builder(
        builder: (ctx) {
          final router = createRouter(ctx);

          return MaterialApp.router(
            title: 'MessManager',
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              colorSchemeSeed: const Color(0xFF7C3AED),
              useMaterial3: true,

              // ✨ NEW FONT SYSTEM
              textTheme: GoogleFonts.plusJakartaSansTextTheme(
                ThemeData().textTheme,
              ),
            ),

            routerConfig: router,
          );
        },
      ),
    );
  }
}