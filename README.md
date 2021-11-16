应用功能描述：
为一个创业公司生成建议的公司名称。用户可以选择和取消选择的名称、保存喜欢的名称。该
代码一次生成十个名称，当用户滚动时，会生成新一批名称。

我们这个应用分成两个部分：
第一部分和第二部分。

第一部分，我们将构建：
·Flutter如何在Android、iOS和Web里自动适应不同的UI体系
·Flutter工程/项目的基本结构
·查找和使用packages来扩展功能
·使用热重载（hot reload）加快开发周期
·如何实现有状态的widget
·如何创建一个无限的、延迟加载的列表

第二部分，我们将构建：
·在stateful widget上添加交互
·导航到第二个页面
·修改应用到主题


具体实现：
第一步：创建初始化工程。
创建一个简单的、基于模版的Flutter工程，然后将项目命名为startup_namer。
下面我们将按照我们的需求编辑Dart代码所在的lib/main.dart文件。

一：我们是创建一个具有Material Design风格的应用，Meterial是一种移动端和网页端通用的
视觉设计语言，Flutter提供了丰富的Material风格的widgets。
在pubspec.yaml文件的flutter部分选择加入uses-material-design:true，通过这个我们
可以使用更多Material的特性。

二、主函数（main）使用了（=>）符号，这是Dart中单行函数或方法的简写。

三、该应用程序继承了StatelessWidget，这将会使应用本身也成为一个widget。在Flutter中，几乎所有都是widget，包括对齐（alignment）、填充（padding）和布局（layout）。

四、Scaffold是Material库中提供的一个widget，它提供了默认的导航栏、标题和包含主屏幕widget树的body属性。widget树可以很复杂。

五、一个widget的主要工作是提供一个build()方法来描述如何根据其他较低级别的widgets来显示自己。

第二步：使用外部package。
我们使用一个名为english_words的开源软件包，其中包含数千个最常用的英文单词以及一些实用功能。
pubspec.yaml文件管理Flutter应用程序的assets(资源，如图片、package等)。在pubspec.yaml中，将english_words（3.1.5或更高版本）添加到依赖项列表。如下：
dependencies:
    flutter:
        sdk: flutter
    cupertino_icons: ^1.0.2
    english_words: ^4.0.0

执行pub get命令。（执行pub get会将依赖包安装到项目。在执行pub get命令时会自动生成
一个名为pubspec.lock文件，这里包含了依赖packages的名称和版本）
在lib/main.dart中引入，如下：
import 'package:english_words/english_words.dart'
import 'package:flutter/material.dart'


第三步：添加一个Stateful widget。
Stateless widgets是不可变的，这意味着它们的属性不能改变--所有的值都是final。
Stateful widgets持有的状态可能在widget生命周期中发生变化，实现一个stateful widget至少需要两个类：
（1）一个StatefulWidget类；
（2）一个State类，StatefulWidget类本身是不变的，但是State类在widget生命周期
中始终存在。
因此，我们添加一个stateful widget -- RandomWords，它会创建自己的状态类 -- _RandomWordsState，然后我们需要将RandomWords内嵌到已有的无状态的 MyApp widget。
1、小技能：创建有状态widget的样板代码。
在lib/main.dart中，将光标置于所有代码之后，输入回车几次另起新行。在IDE中，输入stful，编辑器就会提示您是否要创建一个Stateful widget。按回车键表示接受建议，随后就会出现两个类的样板代码，光标也会被定位在输入有状态widget的名称处。
class  extends StatefulWidget {
  const ({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

2、输入RandomWords作为有状态widget的名称。
RandomWords Widget的主要作用就是创建其对应的State类。
输入RandomWords作为有状态widget的名称后，IDE会自动更新其对应的State类，
并将其命名为_RandomWordsState。默认情况下，State类的名称带有下划线前缀。
Dart语言中，给标识符加上下划线前缀可以增强隐私性，这也是针对State对象推荐的最佳实践写法。
IDE也会自动将状态类继承自State<RandomWords>，这表示专门用于RandomWords的通用State类。这个类维护RandomWords widget的状态。
3、更新_RandomWordsState中的build()方法：
class _RandomWordsState extends State<> {
  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    return Text(wordPair.asPascalCase);
  }
}


第四步：创建一个无限滚动的ListView。
扩展_RandomWordsState以生成并显示单词对列表。随着用户滚动，列表（显示在ListView widget中）将无限增长。ListView的builder工厂构造函数使我们可以按需延迟构建列表视图。
1、向_RandomWordsState类中添加一个_suggestions列表以保存建议的单词对，同时，添加一个_biggerFont变量来增大字体大小。
class _RandomWordsState extends State<RandomWords> {
    final _suggestions = <WordPair>[];
    final _biggerFont = const TextStyle(fontSize: 18.0);
}

接下来，我们将向_RandomWordsState类添加一个_buildSuggestions()，此方法构建显示建议单词对的ListView。
ListView类提供了一个名为itemBuilder的builder属性，这是一个工厂匿名回调函数，接受两个参数BuildContext和行迭代器i。迭代器从0开始，每调用一次该函数i就会自增，每次建议的单词对都会让其递增两次，一次是ListTile，另一次是Divider。它用于创建一个在用户滚动时候无限增长的列表。
2、向_RandomWordsState类添加_buildSuggestions()方法，内容如下：
Widget _buildSuggestions() {
  return ListView.builder(
    padding: const EdgeInsets.all(16.0),
    itemBuilder: (context, i) {
      if (i.isOdd) return const Divider();
      final index = i ~/ 2;
      if(index >= _suggestions.length) {
        _suggestions.addAll(generateWordPairs().take(10));
      }
      return _buildRow(_suggestions[index]);
    }
  );
}

(1)对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中。在偶数行，该函数会为单词对添加一个ListTile row，在奇数行，该函数会添加一个分隔线的widget，来分隔相邻的词对。
(2)在ListView里的每一行之前，添加一个1像素高的分隔线widget。
(3)语法i ~/ 2表示i除以2，但返回值是整型（向下取整），比如i为：1,2,3,4,5时，结果为0,1,1,2,2，这个可以计算出ListView中减去分隔线后的实际单词对数量。
(4)如果是建议列表中最后一个单词对，接着再生成10个单词对，然后添加到建议列表。
对于每一个单词对，_buildSuggestions()都会调用一次_buildRow()。
3、在_RandomWordsState中添加_buildRow()函数:
Widget _buildRow(WordPair pair) {
  return ListTile(
    title: Text(
      pair.asPascalCase,
      style: _biggerFont,
    ),
  );
}

4、更新_RandomWordsState的build()方法以使用_buildSuggestions()，而不是直接调用单词生成库，代码更改后如下：（使用Scaffold类实现基础的Material Design布局）
@override
Widget build(BuildContext context) {
  /*final wordPair = WordPair.random();
  return Text(wordPair.asPascalCase);*/
  return Scaffold(
    appBar: AppBar(title: const Text('Startup Name Generator')
    ),
    body: _buildSuggestions(),
  );
}

5、更新MyApp的build()方法，修改title的值来改变标题，修改home的值为RandomWords widget。
class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Startup Name Generator',
            home: RandomWords(),
        )
    }
}


第五步：向列表里添加图标。
我们为每一行添加一个心形的（收藏）图标，下一步我们再为这个图标加入点击收藏的功能。
1、添加一个_saved Set（集合）到RandomWordsState，这个集合存储用户喜欢（收藏）到单词对。在这里，Set比List合适，因为Set中不允许重复的值。
class RandomWordsState extends State<RandomWords> {
    final _suggestions = <WordPair>[];
    final Set<WordPair> _saved = <WordPair>{};
    final _biggerFont = const TextStyle(fontSize: 18.0);
}

2、在_buildRow方法中添加alreadySaved来检查确保单词对还没有添加到收藏夹中。
Widget _buildRow(WordPair pair) {
  final bool alreadySaved = _saved.contains(pair);    
}

3、在_buildRow()中，添加一个心形图标到ListTiles以启用收藏功能。
Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return new ListTile(
        title: new Text(
            pair.asPascalCase,
            style: _biggerFont,
        ),
        trailing: new Icon(
            alreadySaved ? Icons.favorite :Icons.favorite_border,
           color: alreadySaved ? Color.red : null, 
        )
    )
}


第六步：添加交互。
我们将为心形图标增加交互，当用户点击列表中的条目，切换其“收藏”状态，并将该词对添加到或移除出“收藏夹”。
我们在_buildRow中让心形图标变得可以点击。如果单词条目已经添加到收藏夹中，再次点击它将其从收藏夹中删除。当心形图标被点击时，函数调用setState()通知框架状态已经改变。
1、增加onTap方法，如下：
Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return new ListTile(
        title: new Text(
            pair.asPascalCase,
            style: biggerFont,
        ),
        trailing: new Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
           color: alreadySaved ? Colors.red : null, 
        ),
        onTap: () {
            setState(() {
              if(alreadySaved) {
                  saved.remove(pair);
              } else {
                  saved.add(pair);
              }
            });
        },
    )
}

在Flutter的响应式风格的框架中，调用setState()会为State对象触发build()方法，从而导致对UI的更新。

第七步：导航到新页面。
我们添加一个显示收藏夹内容的新页面（在Flutter中称为路由[route]）。
在Flutter中，导航器管理应用程序的路由栈。将路由推入(push)到导航器的栈中，
将会显示更新为该路由页面。从导航器的栈中弹出（pop）路由，将显示返回到前一个路由。
接下来，我们在RandomWordsState的build方法中为AppBar添加一个列表图标。当用户点击
列表图标时，包含收藏夹的新路由页面入栈显示。
1、将该图标及其相应的操作添加到build方法中：
class _RandomWordsState extends State<RandomWords> {
    Widget build(BuildContext context) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('Startup Name Generator'),
            actions: <Widget>[
                new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
            ],
          ),
         body: _buildSuggestions(),
        );
    }
}

提示：某些widget属性需要单个widget (child)，而其他一些属性，如action，需要一组widgets(children)，
用方括号[]表示。
2、在RandomWordsState这个类里添加_pushSaved()方法：
class _RandomWordsState extends State<RandomWords> {
    void _pushSaved() {
        
    }
}

此时，热重载应用，我们会发现列表图标出现在导航栏中了。不过现在点击它不会有任何反应，因为
_pushSaved函数还是空的。
接下来，（当用户点击导航栏中的列表图标时）我们会建立一个路由并将其推入到导航管理器栈中。
此操作会切换页面以显示新路由，新页面的内容会在MaterialPageRoute的builder属性中构建，builder
是一个匿名函数。
3、添加Navigator.push调用，这会使路由入栈。
void _pushSaved() {
    Navigator.of(context).push(
        
    );
}

接下来，添加MaterialPageRoute及其builder。现在，添加生成ListTile行的代码，ListTile的divideTiles()
方法在每个ListTile之间添加1像素的分割线。该divided变量持有最终的列表项，并通过toList()方法
非常方便的转换成列表显示。
void _pushSaved() {
    Navigator.of(context).push(
        new MaterialPageRoute<void>(
            builder: (BuildContext context) {
                final Iterable<ListTile> tiles = _saved.map(
                    (WordPair pair) {
                        return new ListTile(
                            title: new Text(
                                pair.asPascalCase,
                               style: biggerFont,
                            ),
                        );
                    },
                );
                
                final List<Widget> divided = ListTile.divideTiles(
                    context: context,
                    tiles: tiles,
                ).toList();
            },
        ),
    );
}

4、添加水平分隔符。
void _pushSaved() {
    Navigator.of(context).push(
        new MaterialPageRoute<void>(
            builder: (BuildContext context) {
                final Iterable<ListTile> tiles = _saved.map(
                    (WordPair pair) {
                        return new ListTile(
                            title: new Text(
                                pair.asPascalCase,
                               style: biggerFont,
                            ),
                        );
                    },
                );
                
                final List<Widget> divided = ListTile.divideTiles(
                    context: context,
                    tiles: tiles,
                ).toList();
                
                return new Scaffold(
                    appBar: new AppBar(
                        title: const Text('Saved Suggestions'),
                    ),
                    body: new ListView(children: divided),
                );
            },
        ),
    );
}

builder返回一个Scaffold，其中包含名为“Saved Suggestions”的新路由的应用栏。新路由的body由包含ListTiles
行的ListView组成；每行之间通过一个分割线分隔。
热重载应用程序，点击列表项收藏一些项，点击列表图标，在新的route（路由）页面中显示收藏的内容。
Navigator（导航器）会在应用栏中自动添加一个“返回”按钮，无需调用Navigator.pop，点击后退按钮就
会返回到主页路由。

第八步：使用Themes修改UI
我们修改应用到主题。Flutter里我们使用theme来控制应用到外观和风格，我们可以使用默认主题，
该主题取决于物理设备或模拟器，也可以自定义主题以适应我们的品牌。
我们可以通过配置ThemeData类轻松更改应用程序的主题，目前我们的应用程序使用默认主题，下面
将更改primaryColor颜色为白色。
1、在MyApp这个类里修改颜色：
class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Startup Name Generator',
            theme: new ThemeData(
                primaryColor: Colors.white,
            ),
            home: new RandomWords(),
        );
    }
}


