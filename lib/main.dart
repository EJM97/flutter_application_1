import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(200, 200, 0, 180)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void removeItem() {
    notifyListeners();
  }

  var liked = <WordPair>{};
  void toggleLikes() {
    if (liked.contains(current)) {
      liked.remove(current);
    } else {
      liked.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = LikedPage();
        break;
      default:
        throw UnimplementedError("No page for index $selectedIndex");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Namer App'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              // backgroundColor: Theme.of(context).colorScheme.primary,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_filled),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text("Liked"),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class LikedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    if (appState.liked.isEmpty) {
      return Center(
        child: Text("Like words to list them here"),
      );
    } else {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
                "You have ${appState.liked.length}, liked word${(appState.liked.length > 1) ? "s" : ""}."),
          ),
          for (var i in appState.liked)
            Dismissible(
              key: Key(i.asLowerCase),
              onDismissed: (direction) {
                appState.liked.remove(i);
                appState.removeItem();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Removed ${i.asLowerCase}"),
                  ),
                );
              },
              background: Container(
                color: Color(0XFFDC3545),
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Icon(
                    Icons.delete,
                    color: (Color.fromARGB(100, 255, 255, 255)),
                  ),
                ),
              ),
              direction: DismissDirection.startToEnd,
              child: ListTile(
                leading: Icon(Icons.format_list_bulleted),
                title: Text(i.asLowerCase),
              ),
            ),
        ],
      );
    }
  }
}

// class that generates the word pair and displays it on the screen
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var wPair = appState.current;
    var likeDislikeIcon =
        appState.liked.contains(wPair) ? Icons.favorite : Icons.favorite_border;
    var likeDislikeText = appState.liked.contains(wPair) ? "Dislike" : "Like";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BigCard(wPair: wPair),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: Icon(likeDislikeIcon),
                label: Text(likeDislikeText),
                onPressed: () {
                  print("pressed button-> Like");
                  appState.toggleLikes();
                  print(appState.liked);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  print("pressed button-> New Word");
                  appState.getNext();
                },
                child: Text("New Word"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wPair,
  });

  final WordPair wPair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Text(
          wPair.asLowerCase,
          style: style,
          semanticsLabel: wPair.asPascalCase,
        ),
      ),
    );
  }
}
