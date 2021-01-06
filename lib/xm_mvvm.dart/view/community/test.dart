import 'package:flutter/material.dart';
import 'package:framework/xm_mvvm.dart/model/author.dart';
import 'package:framework/xm_mvvm.dart/model/entry.dart';
import 'package:framework/xm_mvvm.dart/model/entrys.dart';
import 'package:framework/xm_mvvm.dart/model/hot.dart';
import 'package:framework/xm_widgets/tile_card.dart';
import '../../../public.dart';
import 'community_list_view.dart';

class CommPage extends StatefulWidget {
  CommPage({Key key}) : super(key: key);

  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  static double _screenHeight = ScreenUtil().setHeight(ScreenUtil.screenHeight);
  static double _statusBarHeight = ScreenUtil.statusBarHeight;
  static double _tabBarTop = _statusBarHeight + kToolbarHeight;
  static double _tabBarHeight = 50;
  static double _bodyTop;
  static double _bodyHeight;

  ScrollController _scrollController = new ScrollController();
  // int _beLoad = 0; // 0表示不显示, 1表示正在请求, 2表示没有更多数据
  int _position = 0; //表示从第几条开始取

  List<Entrys> posts = [];

  // AnimationController controller;
  // Animation<double> animation;

  @override
  void dispose() {
    // 资源释放
    // controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 4,
    );

    _setBodyFrame();

    // 首次拉取数据
    _fetchData();
    _scrollController.addListener(() {
      //滚动视图滚动位置
      double _scviewPosition = _scrollController.position.pixels;
      double _scviewMinPosition = _scrollController.position.minScrollExtent;
      double _scviewMaxPosition = _scrollController.position.maxScrollExtent;
      print(_scviewPosition);
      print(_tabBarTop);
      print(_statusBarHeight);
      if (_scviewPosition > _scviewMinPosition &&
          _scviewPosition < _scviewMaxPosition &&
          _tabBarTop > _statusBarHeight) {
        setState(() {
          //往上覆盖
          print('缩小-----');
          _scviewPosition = _scviewPosition > kToolbarHeight
              ? kToolbarHeight
              : _scviewPosition; //防止一次性拉动距离过大
          _tabBarTop = kToolbarHeight - _scviewPosition + _statusBarHeight;
          _setBodyFrame();
        });
        // } else if (_tabBarTop < (_statusBarHeight + kToolbarHeight) &&
        //     _tabBarTop >= _statusBarHeight) {
        //   print('还原-----');
        //   _scviewPosition = _scviewPosition.abs();
        //   //防止一次性拉动距离过大
        //   _scviewPosition = _scviewPosition > kToolbarHeight
        //       ? _statusBarHeight + _scviewPosition
        //       : _scviewPosition + kToolbarHeight;
        //   setState(() {
        //     // 执行动画
        //     // controller.forward();
        //     _tabBarTop = _scviewPosition;
        //     _setBodyFrame();
        //   });
      } else if (_scviewPosition == _scviewMaxPosition) {
        //从多少条数据后面开始取数据
        _position = posts.length;
        _fetchData();
        print('我监听到底部了!');
      } else if (_scviewPosition == _scviewMinPosition) {
        print('下拉下拉下拉下拉下拉下拉下拉下拉下拉下拉!');
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _refresh() async {
    _position = 0;
    _fetchData();
  }

  //配置bodyFrame
  _setBodyFrame() {
    _bodyTop = _tabBarTop + _tabBarHeight;
    _bodyHeight = _screenHeight - _bodyTop - _tabBarHeight;
  }

  Future<void> _fetchData() async {
    Hot hot = await Z6Srv.queryHot(_position.toString(), '');
    setState(() {
      if (_position == 0) {
        posts.clear();
      }
      posts.addAll(hot.data.items);
    });
  }

  Widget _tabBar() {
    return Container(
      color: Colors.red,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TabBar(
        controller: this._tabController,
        labelColor: XMColor.darkGray,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelColor: XMColor.kgray,
        indicatorColor: XMColor.deep_kgray,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        indicatorPadding: EdgeInsets.fromLTRB(8, 0, 8, 5),
        tabs: [
          Tab(text: '热门'),
          Tab(text: '关注'),
          Tab(text: '话题'),
          Tab(text: '同城'),
        ],
      ),
    );
  }

  Widget _hotList() {
    return Container(
      color: Colors.orange,
      padding: EdgeInsets.fromLTRB(margin8, margin8, margin8, 0),
      child: StaggeredGridView.countBuilder(
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          primary: false,
          crossAxisCount: 4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          itemBuilder: (context, idx) {
            String img;
            String content;
            String avatar;
            String name;
            String likes;
            try {
              Entry entry = posts[idx].entry ?? Entry();
              List imgs = entry.images ?? [];
              Author author = entry.author ?? Author();

              img = imgs.length >= 1 ? imgs[0] : Api.hot_img;
              content = entry.content ?? '默认测试内容';
              avatar = author.avatar ?? Api.avatar;
              name = author.username ?? '无名';
              likes = (entry.likes ?? 0).toString();
            } catch (e) {
              print('-----ItemError-$idx:$e');
              return Container();
            } finally {
              //     print('''\n      img:$img
              // content:$content
              // avatar:$avatar
              // name:$name
              // likes:$likes''');
              //     print('------' + (idx % 3).toString());
            }

            return TileCard(
              img: img,
              content: content,
              avatar: avatar,
              name: name,
              likes: likes,
              isVip: idx % 3 == 0 ? true : false,
            );
          },
          staggeredTileBuilder: (index) => StaggeredTile.fit(2)),
    );
  }

  _showRefresh() {
    return _bodyTop >= Screen.navigationBarHeight + _tabBarHeight
        ? true
        : false;
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: this._tabController,
      children: [
        // Text('data'), Text('data'), Text('data'), Text('data'),
        Container(
            child: _showRefresh() == true
                ? RefreshIndicator(onRefresh: _refresh, child: _hotList())
                : _hotList()),
        CommunityListView(HomeListType.foucs),
        CommunityListView(HomeListType.topic),
        CommunityListView(HomeListType.local),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: <Widget>[
            AppBar(
              // backgroundColor: Colors.white,
              title: Text('keep'),
              actions: <Widget>[
                new IconButton(
                  // action button
                  icon: new Icon(Icons.people),
                  onPressed: () {
                    print('object');
                  },
                ),
              ],
            ),
            Positioned(
              //TabBar
              top: _tabBarTop,
              width: Screen.width,
              height: _tabBarHeight,

              child: _tabBar(),
            ),
            Positioned(
              //Body
              top: _bodyTop,
              width: Screen.width,
              height: _bodyHeight,
              child: _tabBarView(),
            )
          ],
        ),
      ),
    );
  }
}
