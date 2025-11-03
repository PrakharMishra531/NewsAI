import 'package:flutter/cupertino.dart';
import 'package:news_ai_app/models/article.dart';
import 'package:news_ai_app/screens/webview_screen.dart'; 
import 'package:news_ai_app/widgets/chat_modal.dart';
import 'package:news_ai_app/widgets/animated_gradient_border.dart';


class ArticlePage extends StatelessWidget {
  final Article article;

  const ArticlePage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // We get our "hacky" title and summary
    final (title, summary) = _splitTitleAndSummary(article.summaryText);

    return Stack(
      children: [
        // --- Layer 1: Main Content ---
        Column(
          children: [
            _buildImage(),
            _buildContent(context, title, summary), // Pass title/summary
          ],
        ),
        
        // --- Layer 2: "Ask AI" Button (Floating) ---
        _buildAskAiButton(context),
        
        // --- Layer 3: "Tap to know more" Footer ---
        _buildFooter(context),
      ],
    );
  }

  // --- Image (No Change) ---
  Widget _buildImage() {
    return Expanded(
      flex: 2, // You can play with this ratio, e.g., 3
      child: Container(
        width: double.infinity,
        color: CupertinoColors.lightBackgroundGray,
        child: article.imageUrl != null
            ? Image.network(
                article.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CupertinoActivityIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(CupertinoIcons.exclamationmark_circle,
                          color: CupertinoColors.systemRed));
                },
              )
            : const Center(
                child: Icon(CupertinoIcons.photo,
                    color: CupertinoColors.systemGrey, size: 50),
              ),
      ),
    );
  }

// In lib/widgets/article_page.dart

// In lib/widgets/article_page.dart

// In lib/widgets/article_page.dart

// In lib/widgets/article_page.dart

Widget _buildContent(BuildContext context, String title, String summary) {
  final textTheme = CupertinoTheme.of(context).textTheme;

  return Expanded(
    flex: 3,
    child: Container(
      width: double.infinity,
      
      // --- ADDING THE CURVES BACK ---
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      
      // --- ADDING THE "FLOAT" EFFECT BACK ---
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.navTitleTextStyle.copyWith(
                  fontSize: 24,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                summary,
                style: textTheme.textStyle.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.5,
                ),
              ),
              // This padding ensures content doesn't go under your buttons
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    ),
  );
}

// In lib/widgets/article_page.dart

// In lib/widgets/article_page.dart

Widget _buildAskAiButton(BuildContext context) {
  // Define your gradient colors here for easy adjustment
  const List<Color> gradientColors = [
    CupertinoColors.activeBlue,
    CupertinoColors.systemIndigo,
    CupertinoColors.systemPurple,
    CupertinoColors.systemPink,
  ];

  return Positioned(
    bottom: 80,
    left: 20,
    right: 20,
    child: AnimatedGradientBorder( // <-- Wrap with our new widget
      borderRadius: 30.0, // Match button's border radius
      borderWidth: 3.0,
      gradientColors: gradientColors,
      animationDuration: const Duration(seconds: 4), // Adjust speed here
      child: Container( // This container is now the WHITE FILL
        decoration: BoxDecoration(
          color: CupertinoColors.white, // The inner white fill
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              // Give the shadow the same color as the gradient for a glow effect
              color: gradientColors[0].withOpacity(0.4), 
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CupertinoButton(
          // Ensure button is transparent to show the white fill
          color: CupertinoColors.transparent, 
          borderRadius: BorderRadius.circular(30.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Adjust padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ask AI about This',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.black, // Text is now black on white
                      fontWeight: FontWeight.w600,
                      fontSize: 17, // Slightly larger font
                    ),
              ),
              const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.black), // Icon also black
            ],
          ),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (modalContext) {
                return ChatModal(articleId: article.id);
              },
            );
          },
        ),
      ),
    ),
  );
}

Widget _buildFooter(BuildContext context) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding:
          const EdgeInsets.only(left: 24.0, right: 24.0, top: 10.0, bottom: 20.0),
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
  Navigator.of(context).push(
    CupertinoPageRoute(
      
      // --- THIS IS THE CRASH-PREVENTION LINE ---
      // It forces the WebView to open in a new, safe
      // render context (as a modal).
      fullscreenDialog: true, 
      
      builder: (context) => WebViewScreen(url: article.sourceUrl),
    ),
  );
},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tap to know more',
              // USE THEME:
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.link,
              color: CupertinoColors.secondaryLabel,
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}
} 

(String, String) _splitTitleAndSummary(String fullText) {
  final sentences = fullText.split('. ');
  if (sentences.length > 1) {
    final title = sentences.first;
    final summary = sentences.sublist(1).join('. ');
    return (title, summary);
  }
  return (fullText, ''); // Fallback if there's no period
}