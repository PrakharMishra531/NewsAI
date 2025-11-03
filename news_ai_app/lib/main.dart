// lib/main.dart
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure this is imported
import 'package:provider/provider.dart';
import 'package:news_ai_app/providers/news_provider.dart';
import 'package:news_ai_app/screens/feed_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NewsAiApp());
}

class NewsAiApp extends StatelessWidget {
  
  const NewsAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      
      create: (context) => NewsProvider(),
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'NewsAI',
        
        // --- THIS IS THE FULL, CORRECT THEME ---
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          textTheme: CupertinoTextThemeData(
            // This is the base style
            textStyle: GoogleFonts.inter().copyWith(
              inherit: true,
              color: CupertinoColors.black,
            ),
            // This is for nav bar titles
            navTitleTextStyle: GoogleFonts.inter().copyWith(
              inherit: true,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
            // This is for buttons
            actionTextStyle: GoogleFonts.inter().copyWith(
              inherit: true,
              color: CupertinoColors.activeBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // --- END OF THEME ---
        
        home: const FeedScreen(),
      ),
    );
  }
}