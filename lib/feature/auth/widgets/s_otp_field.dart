import 'package:flutter/material.dart';

import '../../../core/theme/SColor.dart';

            class SOTPField extends StatefulWidget {
              final int length;
              final TextEditingController controller;

              SOTPField({
                Key? key,
                required this.length,
                required this.controller,
              }) : super(key: key);

              @override
              State<SOTPField> createState() => _SOTPFieldState();
            }

            class _SOTPFieldState extends State<SOTPField> {
              late List<FocusNode> _focusNodes;
              late List<TextEditingController> _textControllers;

              @override
              void initState() {
                super.initState();
                _focusNodes = List.generate(widget.length, (_) => FocusNode());
                _textControllers = List.generate(widget.length, (_) => TextEditingController());
              }

              @override
              void dispose() {
                for (var node in _focusNodes) {
                  node.dispose();
                }
                for (var ctrl in _textControllers) {
                  ctrl.dispose();
                }
                super.dispose();
              }

              void _onChanged(int index, String value) {
                if (value.length > 1) {
                  _textControllers[index].text = value[value.length - 1];
                }
                if (value.isNotEmpty && index < widget.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                }
                if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                widget.controller.text = _textControllers.map((c) => c.text).join();
              }

              @override
              Widget build(BuildContext context) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    return Container(
                      width: 55,
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        controller: _textControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,

                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                          ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: SColor.borderColor),
                            )
                        ),
                        onChanged: (value) => _onChanged(index, value),
                      ),
                    );
                  }),
                );
              }
            }