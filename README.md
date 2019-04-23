# Flutter 开发初探

Flutter 是谷歌推出的新一代跨平台开发框架，一经推出就凭借媲美原生的性能、广泛的第三方库的支持、良好的跨平台能力等特性，受到了众多开发者的关注，其火热程度甚至超过了之前由 Facebook 推出的 React Native。在过去的两周内，我对 Flutter 进行了学习，了解了一些基础知识，并将我之前做的一个简单的 [App](https://github.com/tamarous/asciiwwdc-flutter) 用 Flutter 进行了重写。下面就谈谈我在重写这个简单 App 时的过程及感受。

## App 简介

这个 App 的名字是 ASCIIWWDC-flutter，是给[`ASCIIWWDC`](www.asciiwwdc.com)做的一个简单的客户端。该网站上收录了从2010到2018年的历次 WWDC 上所有 Session 演讲视频的英文字幕。对于平时工作繁忙的开发者来说，阅读英文文本比起看视频显然是一种更高效的学习方式。 本 App 让用户可以更方便地阅读该网站上的内容，对于喜欢的内容还可以进行标记以便再次阅读。本 App 的界面如下图所示。

![Demo](https://github.com/tamarous/asciiwwdc-flutter/blob/master/demo.gif)

打开 App，第一页是一列卡片，每张卡片对应不同年份的 WWDC，标明了每次 WWDC 的年份、主题及召开时间。在该页的右上角有两个按钮，依次是搜索与收藏列表。点击搜索按钮，则进入搜索界面，用户可以按照关键字来对 Session 进行搜索；点击收藏列表按钮会进入收藏界面，在这里用户可以看到所有已经收藏的 Session 的列表。点击各张卡片，则进入会议详情界面，该界面中包含一个可伸缩列表，列表的每一项是一个主题，如 WWDC 2018 共有 Featured、Development Tools、Frameworks、App Store and Distributions、Media、Design 等六个主题。点击每一个项，则会展开二级列表，每一行是该主题下的具体的 Session 的名称与一个快速收藏按钮。点击每一个 Session 的标题，则会进入一个WebView 界面，该 WebView 里就是每个 Session 具体的英文字幕。在该界面的右上角，有两个按钮，依次是收藏与分享，点击收藏按钮，则该 Session 会被标记为喜欢，之后在收藏列表页就可以重新阅读该 Session 的内容；点击分享按钮，则会依据系统平台来自动调用 Android 或 iOS 的分享页面。

该 App 中使用的第三方库如下：

1. 数据存储，[sqflite](https://pub.dartlang.org/packages/sqflite)
2. 网络请求，[Dio](https://pub.dartlang.org/packages/dio)
3. HTML 解析，[html](https://pub.dartlang.org/packages/html)
4. 搜索，[material_search](https://pub.dartlang.org/packages/material_search)
5. 网络状态监测，[connectivity](https://pub.dartlang.org/packages/connectivity)
6. WebView，[flutter_webview_plugin](https://pub.dartlang.org/packages/flutter_webview_plugin)
7. 分享，[share](https://pub.dartlang.org/packages/share)

## UI 搭建
在 Flutter 中，任何 UI 相关的组件都是 Widget。Flutter 中按照有无状态可以分为两类 Widget，分别是 StatelessWidget 及 StatefulWidget。StatelessWidget 顾名思义即无状态组件，用来表示一些在确定后就不变的内容，如 Image、Text 等，而 StatefulWidget 则是有状态组件，该 Widget 所表示的内容会随着 State 的变化而改变。在使用 StatefulWidget 时，需要创建与 StatefulWidget 相关的 State 对象，在该 State 对象中存储一些状态变量，然后在这些状态变量发生变化时通过调用`setState()`函数来控制 StatefulWidget 的重新绘制。

以主页面为例，AllConferencesPage 继承自 StatefulWidget，在这个类的定义中，重载 createState() 方法并返回一个 AllConferencesState 对象，从而让 AllConferencesState 来控制 AllConferencesPage 的显示内容，而AllConferencesState 则需要继承自泛型参数为 AllConferencesPage 的 State，并且重写  build(BuildContext context) 方法，build 方法的作用是根据AllConferencesState 中的某些状态变量来绘制出 Widget 的内容。

```
class AllConferencesPage extends StatefulWidget {
  @override
  AllConferencesState createState() => new AllConferencesState();
}

class AllConferenceState extends State<AllConferencesPage> {
    List<Conference> _conferences;
  
    void fetchList(List<Conference> fetchedList) {
        setState(() {
            _conferences = fetchedList;
        });
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold();
    }
}
```
在 AllConferencesState 中，声明了一个 List 类型的私有成员变量 _conferences，这个私有成员变量的作用是存储历次 WWDC 下各个主题及 Session 的内容。当从网络或者数据库中解析出数据并赋值给该变量后，通过调用 setState() 方法来触发 AllConferencesPage 的重新渲染。

在布局上，Flutter 将 padding、margin、align 等常见的布局关系也抽象为 Widget，通过将内容 Widget 设置为布局 Widget 的子 Widget，来实现对内容 Widget 的布局。例如要让一个 Text 文本与它的父 Widget 之间存在一定内边距，那么只需要让该 Text 文本作为 Padding 的child，如下代码所示：

```
Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(
        'Hello World',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
        ),
    ),
),
```

更为具体的说，Flutter 将布局 Widget 分为三类，分别是只有一个子元素的布局 Widget、有多个子元素的布局 Widget 以及 Layout Helper。只有一个子元素的布局 Widget 常用来对某个 Widget 与其父 Widget 之间的相对位置及大小关系进行调整，常见的有`Container`、`Padding`、`Center`、`Align`等；多个子元素的布局 Widget 常用来对多个 Widget 之间的相对位置关系进行设置，如用来将多个 Widget 排列在一行上的`Row`，用来将多个 Widget 排列在一列上的`Column`，用来将多个 Widget 按照先后顺序排列的`Stack`及`IndexedStack`，用来按照列表形式排布多个 Widget 的`ListView`及 `ListBody`等。

当用户单击卡片时，需要响应单击事件然后进入主题列表页。Flutter 将用户手势响应能力抽象为一个名为`GestureDetector` 的 Widget，如果需要给某个 Widget 添加响应手势操作的能力，那么只需要让这个 Widget 成为 `GestureDetector` 的子元素。`GestureDetector`的构造函数如下所示：

```
GestureDetector({
    Key key,
    this.child,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onLongPressUp,
    this.onLongPressDragStart,
    this.onLongPressDragUpdate,
    this.onLongPressDragUp,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.down,
  })
```
从该构造函数可见`GestureDetector`能够处理非常多不同类型的用户手势事件，比如用于处理单击事件的`onTap`、用于处理双击事件的`onDoubleTap`、用于处理长按事件的`onLongPress`，可见 Flutter 框架在设计时就已经考虑的非常周到了。

## 数据处理

### 异步加载
在用户使用该 App 时，该 App 首先会尝试能否从本地数据库中取得所需的各种数据，如果获取不到，则会访问[`ASCIIWWDC`](https://www.asciiwwdc.com/ )然后从 HTML 响应中解析出各种数据，并存储在 App 目录下的 SQLite3 数据库中。无论是解析网络请求还是从读取数据库，获取数据的过程相对来说都是比较漫长的，因此为了不造成 UI 的卡顿，获取数据操作应该异步地执行。Flutter 中提供了`async`和`await`这两个关键字来进行异步操作，并且这两个关键字总是应该搭配着进行使用。`async`用来修饰一个函数，表示该函数是异步执行的，可以认为该函数被扔到其他线程进行处理了，程序会在当前线程继续向下执行；而`await`则用来修饰`async`函数的返回值，表示当前线程也会暂停，直到`async`函数执行完毕，再回到当前线程继续往下执行。

```
void loadConferences() async {
    List<Conference> conferences;
    conferences = await loadConferencesFromDatabase();
    if (conferences == null || conferences.isEmpty) {
      try {
        Response response = await Dio().get(URL_PREFIX);
        conferences = await loadConferencesFromNetworkResponse(response);
        setState(() {
          _conferences = conferences;
          _hasLoadedData = true;
        });
        saveAllConferencesToDatabase();
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        _conferences = conferences;
        _hasLoadedData = true;
      });
    }
  }
```
上面这段代码中，首先尝试从数据库中加载数据，加载失败后再发起网络请求并对网络响应进行解析，最后将数据存在数据库中。loadConferencesFromDatabase 函数尝试从数据库中加载数据，其实现如下：

```
Future<List<Conference>> loadConferencesFromDatabase() async {
    List<Conference> conferences;

    conferences = await ConferenceProvider.instance.getConferences('1 = 1');

    await ConferenceProvider.instance.close();

    return conferences;
  }
```

  该函数是用`async`修饰的，返回类型为 Future<T>，表示一个未完成的动作，所以在上一步中为了得到数据库加载的结果，必须用`await`来修饰：
  
```
  conferences = await loadConferencesFromDatabase();
```
### 页面之间的跳转与数据传递
在开发中，经常需要在两个或多个页面之间进行跳转，并进行数据的相互传递。例如在本 App 中，点击收藏列表页(FavoriteSessionsPage)中的各个 Session 的标题文本，会进入详情页(SessionDetailPage)来展示该 Session 的详细内容。点击详情页右上角的收藏/取消收藏按钮，可以切换该 Session 的收藏状态，当取消收藏后，返回收藏列表页，原Session 对应的那一行文本应该消失。在上述过程中，涉及到了两个方向上的数据传递：

1. 当点击标题文本时，FavoriteSessionsPage 需要将标题文本对应的 Session 实例传递给 SessionDetailPage，SessionDetailPage 进而访问该 Session 对应的 URL 地址并将网页内容显示出来。
2. 当点击收藏按钮并返回后，SessionDetailPage 需要将该 Session 实例返回给 FavoriteSessionsPage，FavoriteSessionsPage 通过判断该 Session 实例的收藏状态来决定是否需要更新显示。

`Navigator` 是 Flutter 中用来管理页面之间跳转的类，只要调用该方法，并返回新页面的一个实例就可以跳转到新的页面上，因此在第1点中，为了跳转到 SessionDetailPage 并传递 Session 给它，可以让它的构造函数以 Session 为参数：

```
class SessionDetailPage extends StatefulWidget {
  final Session session;

  SessionDetailPage({Key key, @required this.session}) : super(key: key);

  @override
  _SessionDetailState createState() => new _SessionDetailState();
}
```
在 FavoriteSessionsPage 中点击标题文本进行跳转的方法如下：
```
Navigator.of(context).push(MaterialPageRoute(
        builder: (context)=> SessionDetailPage(session: session)
    )
);
```
在点击收藏按钮并返回时，SessionDetailPage 需要将该 Session 实例返回给 FavoriteSessionsPage，`Navigator`的 pop 方法接受零或一个参数，当有一个参数时，该参数会被传递给上一页面，因此为了完成第2点，可以在页面返回时将 session 实例传入pop 方法中：

```
Navigator.of(context).pop(session);
```
而在 FavoriteSessionsPage 中也需要对代码进行相应的修改：

```
bool oldFavorite = session.isFavorite;

Session updatedSession = await Navigator.of(context).push(MaterialPageRoute(builder: (context)=> SessionDetailPage(session: session)));

if (updatedSession.isFavorite != oldFavorite) {
  _fetchFavoriteSessionsList();
}
```
`await`关键字表明程序会等待`await`后面的函数返回一个值后再往下执行，因此在 SessionDetailPage 中的 pop 方法返回后，这里能够取到 pop 中携带的 session，然后通过比较点击时的 session 实例与返回的 session 实例的收藏状态来决定是否需要更新收藏列表。

## 优点与不足

在使用 Flutter 开发 App 的过程中，让我感觉最爽的就是它良好的跨平台性。Flutter 提供了 Android Studio 及 Visual Studio Code 的插件，让使用这两个软件来开发 Flutter App 变得非常愉悦，其中 Android Studio 插件功能最全最方便，可以方便地查看 Flutter App 的 UI 层次、分析运行时的性能及资源消耗情况。白天我可以在 Windows 上用 Android Studio 及一台 Android 手机调试运行代码，晚上回宿舍了则可以在 Mac 上用 Visual Studio Code 及 iPhone 6 继续开发，这无疑是一个非常过瘾的体验。写一份代码就可以发布在两个平台上，并且还有着不输原生的性能表现，这样的 Flutter 谁不爱呢？

当然 Flutter 也有不足，从语言层面上来说，Flutter 项目中的代码存在着多层括号嵌套的问题，比如下面这段代码：

```
  Widget _buildSession(Session session) {
    return GestureDetector(
      onTap: () {
        _showSessionDetail(session);
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.0,horizontal: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
                child: Text(
                  session.sessionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Text(
                  session.sessionConferenceName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
```
好在 Flutter 的插件做的不错，在每个右括号的后方都会标注对应的左括号所属的层次，但是当脱离插件时，这种代码不管是在阅读还是在编写上都可能会产生一定的问题。此外由于 Flutter还不够成熟，因此目前第三方库的数量、功能都还比不过原生及 React Native。不过，随着Flutter 的不断发展，相信这些问题在未来都会得到解决。