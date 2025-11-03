import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:news_ai_app/providers/news_provider.dart';
import 'package:news_ai_app/widgets/article_page.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // This is the correct place to trigger an initial data load.
    // We use addPostFrameCallback to ensure the widget is fully built
    // before we try to access its Provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We set listen: false because we are in initState. We don't
      // want to listen for changes here, we just want to call a method.
      Provider.of<NewsProvider>(context, listen: false).fetchFeed();
    });
  }

// In lib/screens/feed_screen.dart

// In lib/screens/feed_screen.dart

@override
Widget build(BuildContext context) {
  // We go back to the simple Consumer + Scaffold
  return Consumer<NewsProvider>(
    builder: (context, provider, child) {
      
      return CupertinoPageScaffold(
        // This is the simple, centered nav bar
        navigationBar: const CupertinoNavigationBar(
          middle: Text('NewsAI'),
        ),
        child: Center(
          child: _buildBody(provider),
        ),
      );
    },
  );
}

 // In lib/screens/feed_screen.dart

Widget _buildBody(NewsProvider provider) {
  if (provider.isLoading && provider.articles.isEmpty) {
    // 1. Show a loading spinner if we're loading for the first time
    return const CupertinoActivityIndicator(radius: 20.0);
  }

  if (provider.errorMessage != null) {
    // 2. Show an error message if something went wrong
    return Text(
      'Error: ${provider.errorMessage}',
      style: const TextStyle(color: CupertinoColors.systemRed),
    );
  }

  if (provider.articles.isEmpty) {
    // 3. Show a message if the feed is empty
    return const Text('No articles found.');
  }

  // 4. Success! This is the new part.
  // We return a PageView.builder to create the swipeable feed.
  return PageView.builder(
    scrollDirection: Axis.vertical, // This makes it swipe up/down
    itemCount: provider.articles.length,
    itemBuilder: (context, index) {
      // For each item, we get the article...
      final article = provider.articles[index];
      // ...and we return our new ArticlePage widget.
      return ArticlePage(article: article);
    },
  );
}
}