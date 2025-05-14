import 'package:flutter/material.dart';

import '../public.dart';

class TileCard extends StatelessWidget {
  final String img;
  final String content;
  final String avatar;
  final String name;
  final String likes;
  final bool isVip;
  TileCard(
      {required this.img, required this.content, required this.avatar, required this.name, required this.likes, required this.isVip});

  @override
  Widget build(BuildContext context) {
    
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new ClipRRect(
            child: CachedNetworkImage(
              imageUrl: '$img',
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: xmDp(10).toDouble()),
            margin: EdgeInsets.symmetric(vertical: xmDp(5).toDouble()),
            child: Text(
              '$content',
              style: TextStyle(
                  color: Color(0xff343434),
                  fontSize: ScreenUtil().setSp(24),
                  fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: xmDp(10).toDouble(), bottom: xmDp(10).toDouble()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      width: xmDp(28).toDouble(),
                      height: xmDp(28).toDouble(),
                      // color: Colors.red,
                    ),
                    Positioned(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage('$avatar'),
                        radius: xmDp(30).toDouble(),
                      ),
                    ),
                    isVip
                        ? Positioned(
                            width: xmDp(30).toDouble(),
                            height: xmDp(30).toDouble(),
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                            ),
                          )
                        : Text(''),
                    isVip
                        ? Positioned(
                            width: xmDp(28).toDouble(),
                            height: xmDp(28).toDouble(),
                            bottom: xmDp(1).toDouble(),
                            right: xmDp(1).toDouble(),
                            child: CircleAvatar(
                              backgroundImage: AssetImage('res/imgs/vip.png'),
                              // radius: xmDp(28),
                            ),
                          )
                        : Text(''),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: xmDp(10).toDouble()),
                  width: xmDp(220).toDouble(),
                  child: Text(
                    '$name',
                    style: TextStyle(
                      color: Color(0xff343434),
                      fontSize: ScreenUtil().setSp(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: xmDp(10).toDouble()),
                        width: xmDp(40).toDouble(),
                        height: xmDp(40).toDouble(),
                        child: Image.asset('res/imgs/like.png'),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: xmDp(10).toDouble()),
                        child: Text(
                          '$likes',
                          style: TextStyle(
                            color: XMColor.kgray,
                            fontSize: ScreenUtil().setSp(20),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
