import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget drawerWidget(BuildContext ctx) {
  Widget buildList( IconData icon, String title, Function changeState) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        child: Row(
          children: [
            Icon(icon,size: 20,color: Colors.black,),
            SizedBox(width: 15,),
             Text(
              title,
              style: TextStyle(fontSize: 14,fontFamily: 'Oxygen'),
            ),
           
          ]),
          onTap: changeState
      ),
    );
      
       
        
  }

  return Drawer(
    child: Column(
      children: [
        Container(
          height: MediaQuery.of(ctx).size.height * .3,
          child: Stack(
            alignment: Alignment.center,
            children: [Image.asset('assets/rs-logo.png')],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              buildList(Icons.person_add_alt,'Add friend', () {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(ctx, '/add_friend');
                });
              }),
              buildList(Icons.add, 'Create new identity', () {
                Navigator.pushNamed(
                                      ctx, '/create_identity');}),
              buildList(Icons.visibility, 'Change identity', () {
                Navigator.pushNamed(ctx, '/change_identity');
              }),
              buildList(Icons.devices,'Friends location', () {
                Navigator.pushNamed(ctx, '/friends_locations');
              }),
              buildList(Icons.info_rounded, 'Forum', () {
                 Navigator.pushNamed(ctx, '/forum');
              })
              
            

            ],
          ),
        ),
        Spacer(),
        Text(
          "V 1.0.1",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent),
        ),
        SizedBox(height: 30,)
      ],
    ),
  );
}
