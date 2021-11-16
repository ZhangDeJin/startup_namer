///本示例创建了一个具有Material Design风格的应用，Material是一种移动端和网页端通用的视觉设计语言，Flutter
///提供了丰富的Material风格的widgets。在pubspec.yaml文件的flutter部分选择加入users-material-design: true
///会是一个明智之举，通过这个可以让我们使用更多Material的特性，比如其预定义好的图标集。

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

//主函数（main）使用了（=>）符号，这是Dart中单行函数或方法的简写
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  //每次MaterialApp需要渲染时或者在Flutter Inspector中切换平台时build都会运行。
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Startup Name Generator',
      //使用Themes修改UI不生效，不知道是为什么
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];

  ///添加一个_saved Set（集合）到RandomWordsState，这个集合存储用户喜欢（收藏）到单词对。
  ///在这里，Set比List更合适，因为Set中不允许重复的值。
  final Set<WordPair> _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    ///在_buildRow方法中添加alreadySaved来检查确保单词对还没有添加到收藏夹中。
    ///同时在_buildRow()中，添加一个心形图标到ListTiles以启用收藏功能。
    ///接下来，我们就可以给心形图标添加交互能力了。
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      ///添加交互：我们为心形图标增加交互，当用户点击列表中的条目，切换其"收藏"状态，并将该词对添加到
      ///或移除出"收藏夹"。
      ///为了做到这个，我们在_buildRow中让心形图标变得可以点击。如果单词条目已经添加到收藏夹中，
      ///再次点击它将其从收藏夹删除。当心形图标被点击时，函数调用setState()通知框架状态已经改变。
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
      ///在Flutter的响应式风格的框架中，调用setState()会为State对象触发build()方法，从而
      ///导致对UI的更新
    );
  }

  void _pushSaved() {
    //添加Navigator.push调用，这会使路由入栈（导航管理器的栈）
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
