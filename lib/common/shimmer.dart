import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget friendLocationShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
    child: Shimmer(
      gradient: LinearGradient(
        colors: [
          Color(0xFFEBEBF4),
          Color(0xFFF4F4F4),
          Color(0xFFEBEBF4),
        ],
        stops: [
          0.1,
          0.3,
          0.4,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      ),
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemBuilder: (_, __) => Container(
            padding:
                const EdgeInsets.only(bottom: 8.0, left: 8, right: 8, top: 8),
            margin:
                const EdgeInsets.only(top: 8, bottom: 10, left: 8, right: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              Padding(padding: const EdgeInsets.all(8)),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 8,
                      color: Colors.white,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 210,
                      height: 18,
                      color: Colors.white,
                    ),
                  ])
            ])),
        itemCount: 6,
      ),
    ),
  );
}

Widget ChangeIdentityShimmer() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Shimmer(
      gradient: LinearGradient(
        colors: [
          Color(0xFFEBEBF4),
          Color(0xFFF4F4F4),
          Color(0xFFEBEBF4),
        ],
        stops: [
          0.1,
          0.3,
          0.4,
        ],
        begin: Alignment(-1.0, -0.3),
        end: Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      ),
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15),
        itemBuilder: (_, __) => Container(
            padding:
                const EdgeInsets.only(bottom: 8.0, left: 8, right: 8, top: 8),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 10,
              ),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
              Padding(padding: const EdgeInsets.all(8)),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 8,
                      color: Colors.white,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 210,
                      height: 18,
                      color: Colors.white,
                    ),
                  ])
            ])),
        itemCount: 6,
      ),
    ),
  );
}

Widget chatTabShimmer() {
  return Shimmer(
    gradient: LinearGradient(
      colors: [
        Color(0xFFEBEBF4),
        Color(0xFFF4F4F4),
        Color(0xFFEBEBF4),
      ],
      stops: [
        0.1,
        0.3,
        0.4,
      ],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
      tileMode: TileMode.clamp,
    ),
    enabled: true,
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15),
      itemBuilder: (_, __) => Container(
          padding:
              const EdgeInsets.only(bottom: 8.0, left: 8, right: 8, top: 8),
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(14)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                ),
                Padding(padding: const EdgeInsets.all(8)),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 8,
                        color: Colors.white,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 210,
                        height: 18,
                        color: Colors.white,
                      ),
                    ])
              ])),
      itemCount: 5,
    ),
  );
}
