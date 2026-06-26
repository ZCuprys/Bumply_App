import 'package:flutter/material.dart';

import 'package:bumply_app/database/local_database.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() {
    return _ArticlesScreenState();
  }
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late Future<List<Map<String, dynamic>>> articlesFuture;

  static const Color textColor = Color.fromRGBO(96, 111, 160, 1);

  @override
  void initState() {
    super.initState();

    articlesFuture = LocalDatabase.instance.getArticles();
  }

  void showArticleDialog({
    required String title,
    required String content,
    required String category,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            const Text(
              'Articles',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Educational pregnancy content',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: articlesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      'No articles available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(96, 111, 160, 0.75),
                      ),
                    );
                  }

                  final articles = snapshot.data!;

                  return ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      final title = article['title'] as String;
                      final content = article['content'] as String;
                      final category = article['category'] as String;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: () {
                            showArticleDialog(
                              title: title,
                              content: content,
                              category: category,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(158, 178, 255, 0.35),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.menu_book_outlined,
                                  color: textColor,
                                  size: 28,
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color:
                                              Color.fromRGBO(96, 111, 160, 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color.fromRGBO(96, 111, 160, 0.65),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}