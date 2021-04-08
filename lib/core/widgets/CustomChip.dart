import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomChip extends StatefulWidget {
  final VoidCallback onSelect;
  final String label;
  final String icon;
  final bool selected;
  CustomChip({this.icon, this.label, this.onSelect, this.selected});
  @override
  _CustomChipState createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {

  bool selected;
  @override
  Widget build(BuildContext context) {
    selected = widget.selected;
    return GestureDetector(
      onTap: (){
        print('onSelected');
        widget.onSelect();
        setState(() {
          selected = !selected;
        });
      },
      child: Card(
        color: selected? Colors.blueGrey[800] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50))
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              selected ?
                Icon(FontAwesomeIcons.check, color: Colors.white,):
                SvgPicture.network(
                    widget.icon,
                    width: 20,
                    height: 20,
                ),

              VerticalDivider(),
              AutoSizeText(
                widget.label,
                maxLines: 1,
                style: TextStyle(color: selected ? Colors.white: Colors.black),
              )
            ],
          ),
        ) ,
      ),
    );
  }
}
