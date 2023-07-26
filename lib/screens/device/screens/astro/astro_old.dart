import 'package:flutter/material.dart';

class AstroScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AstroScreenState();
}

class _AstroScreenState extends State<AstroScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double iconImgSize = size.width / 4;
    final double iconImgTopMargin = 20;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(iconImgSize / 2),
            ),
            color: Colors.blue.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                offset: Offset(1, 1),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Theme.of(context).scaffoldBackgroundColor,
                offset: Offset(-4, -4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: iconImgTopMargin + iconImgSize,
                margin: EdgeInsets.only(
                  left: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.4),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(iconImgSize / 2),
                    bottomRight: Radius.circular(iconImgSize / 2),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: iconImgTopMargin),
                    Image(
                      image: AssetImage("assets/images/astroclock.png"),
                      width: iconImgSize,
                      height: iconImgSize,
                    ),
                  ],
                ),
              ),
              //const SizedBox(width: 5),
              Expanded(
                child: Column(
                  children: [
                    //const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.4),
                        border: Border(
                          left: BorderSide(
                            width: 1,
                            color: Colors.blue,
                          ),
                          bottom: BorderSide(
                            width: 2,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      child: Text(
                        "Astronimical Clock",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          //fontFamily: 'Nunito',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          ItemBlock(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    "Current State",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          ItemBlock(
                            stringHeight: 10,
                            bgColor: Colors.blue.withOpacity(0.8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    "Sunrise",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                    "6:00 AM",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ItemBlock(
                            stringHeight: 5,
                            bgColor: Colors.blue.withOpacity(0.8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    "Sunset",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                    "6:30 PM",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ItemBlock(
                            stringHeight: 5,
                            bgColor: Colors.blue.withOpacity(0.8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    "Offset Sunrise",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                    "6:00 AM",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ItemBlock(
                            stringHeight: 5,
                            bgColor: Colors.blue.withOpacity(0.8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  child: Text(
                                    "Offset Sunset",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: Text(
                                    "6:30 PM",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        /*Expanded(
          child: Text("test"),
        ),*/
      ],
    );
  }
}

class ItemBlock extends StatelessWidget {
  const ItemBlock({
    super.key,
    this.stringHeight = 15,
    this.bgColor = Colors.blue,
    required this.child,
  });

  final double stringHeight;
  final Color bgColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double stringMargin = 20;
    final double stringWidth = 10;

    return Container(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: stringMargin),
              Container(
                height: stringHeight,
                width: stringWidth,
                decoration: BoxDecoration(
                  color: bgColor,
                ),
              ),
              Spacer(),
              Container(
                height: stringHeight,
                width: stringWidth,
                decoration: BoxDecoration(
                  color: bgColor,
                ),
              ),
              SizedBox(width: stringMargin),
            ],
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
