import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'screens/theme_provider.dart';
import 'screens/app_colors.dart';


void main() {

  runApp(

    ChangeNotifierProvider(

      create: (_) => ThemeProvider(),

      child: const CampusZApp(),

    ),

  );

}



class CampusZApp extends StatelessWidget {

  const CampusZApp({super.key});


  @override
  Widget build(BuildContext context) {


    final themeProvider =
    context.watch<ThemeProvider>();


    return MaterialApp(

      title: 'CampusZ Teacher App',

      debugShowCheckedModeBanner: false,


      themeMode:
      themeProvider.themeMode,



      theme: ThemeData(

        brightness: Brightness.light,

        scaffoldBackgroundColor:
        const Color(0xffF7F8FC),


        colorScheme:
        ColorScheme.fromSeed(

          seedColor:
          AppColors.primaryIndigo,

          brightness:
          Brightness.light,

        ),


        textTheme:
        const TextTheme(

          titleLarge: TextStyle(

            color:
            Color(0xff1E1B3A),

            fontWeight:
            FontWeight.bold,

          ),


          bodyMedium: TextStyle(

            color:
            Color(0xff666666),

          ),

        ),


        useMaterial3:
        true,

      ),




      darkTheme: ThemeData(

        brightness:
        Brightness.dark,


        scaffoldBackgroundColor:
        const Color(0xff121212),


        colorScheme:
        ColorScheme.fromSeed(

          seedColor:
          AppColors.primaryIndigo,

          brightness:
          Brightness.dark,

        ),



        textTheme:
        const TextTheme(


          titleLarge:
          TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.bold,

          ),



          bodyMedium:
          TextStyle(

            color:
            Color(0xffBDBDBD),

          ),


        ),


        useMaterial3:
        true,

      ),



      home:
      const SplashScreen(),

    );

  }
}