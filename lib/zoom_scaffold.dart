import 'package:aclean/Page/home.dart';
import 'package:flutter/material.dart';

//主类
class ZoomScaffold extends StatefulWidget {
//menuScreen 是下面需要显示的页面
//contentScreen 是上面的页面中，BODY部分。
  final Widget menuScreen;
  final Layout contentScreen;

  ZoomScaffold({
    this.menuScreen,
    this.contentScreen,
  });

  @override
  _ZoomScaffoldState createState() => new _ZoomScaffoldState();
}

//scofld级别的设置。
class _ZoomScaffoldState extends State<ZoomScaffold>
    with TickerProviderStateMixin {
//New一个动画控制器
//这个控制器 
  MenuController menuController;
  //插值器 实现了以下接口 Cubic ElasticInCurve ElasticInOutCurve ElasticOutCurve FlippedCurve Interval SawTooth Threshold
  //所以 Interval 可以换成以上任何动画实现方式。
  //Interval 前两个参数 分别 是开始和结束点，后面的Curves.xxx 是动画实现方式。
  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();

    menuController = new MenuController(
      vsync: this,
    )
      //这里的addListener与MenuController构造函数后面的：初始化参数无关。
      //在这里添加一个监听方法，是为了在这个Widget中 储存动画状态。
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    //注销动画
    menuController.dispose();
    super.dispose();
  }

//创建显示内容
  createContentDisplay() {
    //zoomAndSlideContent需要传入一个Widget做为Stack最上层的显示内容 ，这里是制作了 一个Ccontainer 里面包含Scaffold
    return zoomAndSlideContent(new Container(
      child: new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0.0,
          leading: new IconButton(
              icon: new Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                menuController.toggle();
              }),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.access_time,
                color: Colors.grey,
              ),
            )
          ],
        ),
        //contentScreen 就是Layout的引用 ，contentBuilder是Layout构造函数中的一员。
        body: widget.contentScreen.contentBuilder(null),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
                title: Text(''),
                icon: Icon(
                  Icons.home,
                  color: Colors.grey,
                )),
            BottomNavigationBarItem(
                title: Text(''),
                icon: Icon(Icons.shopping_basket, color: Colors.grey)),
            BottomNavigationBarItem(
                title: Text(''),
                icon: Icon(Icons.shopping_cart, color: Colors.grey)),
            BottomNavigationBarItem(
                title: Text(''), icon: Icon(Icons.person, color: Colors.grey)),
          ],
        ),
      ),
    ));
  }

//针对传入的Widget 设置变形动画
//这里的构建的Widget就是Stack中最上面的那一层
  zoomAndSlideContent(Widget content) {
    // 设置
    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(menuController.percentOpen);
        scalePercent = scaleDownCurve.transform(menuController.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(menuController.percentOpen);
        scalePercent = scaleUpCurve.transform(menuController.percentOpen);
        break;
    }

    final slideAmount = 280.0 * slidePercent;
    final contentScale = 1.0 - (0.2 * scalePercent);
    final cornerRadius = 16.0 * menuController.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0.0, 0.0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              offset: const Offset(0.0, 5.0),
              blurRadius: 15.0,
              spreadRadius: 10.0,
            ),
          ],
        ),
        child: new ClipRRect(
            borderRadius: new BorderRadius.circular(cornerRadius),
            child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Scaffold(
            body: widget.menuScreen,
          ),
        ),
        createContentDisplay()
      ],
    );
  }
}
//控制器
class ZoomScaffoldMenuController extends StatefulWidget {
  final ZoomScaffoldBuilder builder;

  ZoomScaffoldMenuController({
    this.builder,
  });

  @override
  ZoomScaffoldMenuControllerState createState() {
    return new ZoomScaffoldMenuControllerState();
  }
}

class ZoomScaffoldMenuControllerState
    extends State<ZoomScaffoldMenuController> {
  MenuController menuController;


  @override
  void initState() {
    super.initState();

    menuController = getMenuController(context);
    menuController.addListener(_onMenuControllerChange);
  }

  @override
  void dispose() {
    menuController.removeListener(_onMenuControllerChange);
    super.dispose();
  }

  getMenuController(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<_ZoomScaffoldState>())
            as _ZoomScaffoldState;
    return scaffoldState.menuController;
  }

  _onMenuControllerChange() {
    setState(() {});
  }
//builder 就是引用了ZoomScaffoldBuilder 的构造方法体，传入了一个MenuController
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, getMenuController(context));
  }
}
//定义ZoomScaffold 的 Builder 方法结构 。
typedef Widget ZoomScaffoldBuilder(
    BuildContext context, MenuController menuController);

//中间Body的构建器，没有完成。
class Layout {
  final WidgetBuilder contentBuilder;

  Layout({
    this.contentBuilder,
  });
}

//构造动画的要素，AnimationController&&TickerProvider，其中TickerProvider被加入构造方法内。谁引入TickerProvider，就作用于谁。
class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;
//添加构造器的初始化列表，将TickerProvider传入AnimationController 并为AnimationController设置动画时间参数，
//设置addListener(notifyListeners)监听
//notifyListeners的作用是每次帧有所变动就有一个通知做为回调返回。
//继续设置addStatusListener状态监听，传入一个AnimationStatus 是为了确认动画的执行阶段。

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 250)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        //根据动画的执行阶段改变MenuState状态，其实需要反过来理解：根据MenuState状态执行动画的某个阶段。
        //status动画  state枚举类型
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

//返回动画
  get percentOpen {
    return _animationController.value;
  }

//正向执行动画
  open() {
    _animationController.forward();
  }

//反向回滚动画
  close() {
    _animationController.reverse();
  }

//根据 MenuState 状态，实现动画转换开关。
  toggle() {
    if (state == MenuState.open) {
      close();
    } else if (state == MenuState.closed) {
      open();
    }
  }
}

enum MenuState {
  closed,
  opening,
  open,
  closing,
}
