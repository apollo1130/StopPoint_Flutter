import 'package:flutter/material.dart';
class CustomDrop extends StatefulWidget {

  final options;
  final defaultIndex;
  final SelectCallback onSelect;
  final ToggleCallback onOpen;
  final child;
  CustomDrop({Key key, this.options, this.defaultIndex = 0, this.onSelect, this.child, this.onOpen } ): super(key: key);
  @override
  CustomDropState createState() => CustomDropState();
}

class CustomDropState extends State<CustomDrop>  with SingleTickerProviderStateMixin{

  OverlayEntry _overlayEntry ;
  bool _show = false;
  String _selectedOption;
  List<DropdownMenuItem> options;
  BuildContext _mainContext;
  @override
  void initState() {
    super.initState();
    options =  widget.options;
    Text text = options[widget.defaultIndex].child;
    _selectedOption =   text.data;


  }


  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Stack(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  toggleDropDown();
                },
                child: Container(
                    color: Colors.transparent
                ),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 5.0,
              width: 200,
              child:  Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: this.options.map((x) {
                    return ListTile(title: x.child , onTap: () {_selectOption(x); });
                  }).toList(),
                ),
              ),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    _mainContext =  context;
    return GestureDetector (
      child: Container(

        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: widget.child,
      ),
      onTap: () {
        toggleDropDown();
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _selectOption (DropdownMenuItem itemSelected) {
    setState(() {
      _selectedOption = (itemSelected.child as Text).data;
    });
    widget.onSelect(itemSelected);
    toggleDropDown();
  }

  void toggleDropDown () {

    if (!_show) {
      this._overlayEntry = this._createOverlayEntry();
      Overlay.of(context).insert(this._overlayEntry);
      _show = true;
    } else {
      this._overlayEntry.remove();
      _show = false;
    }
    widget.onOpen(_show);
  }


}
typedef SelectCallback = void Function(DropdownMenuItem x);
typedef ToggleCallback = void Function(bool x);
