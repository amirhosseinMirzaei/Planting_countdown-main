import 'package:flutter/material.dart';

class RoundedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  RoundedSwitch({required this.value, required this.onChanged});

  @override
  _RoundedSwitchState createState() => _RoundedSwitchState();
}

class _RoundedSwitchState extends State<RoundedSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _value ? Colors.green : Colors.grey,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(!_value)...[
          InkWell(
            onTap: () {
              setState(() {
                _value = false;
                widget.onChanged(false);
              });
            },
            child: Text(
              'خاموش',
              style: TextStyle(
                color: _value ? Colors.white : Colors.black,
              ),
            ),
          )],
          GestureDetector(
            onTap: () {
              setState(() {
                _value = !_value;
                widget.onChanged(_value);
              });
            },
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: AnimatedAlign(
                duration: Duration(milliseconds: 200),
                alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _value ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          if(_value)...[
          InkWell(
            onTap: () {
              setState(() {
                _value = true;
                widget.onChanged(true);
              });
            },
            child: Text(
              'روشن',
              style: TextStyle(
                color: _value ? Colors.black : Colors.white,
              ),
            ),
          )],
        ],
      ),
    );
  }
}
