import 'package:flutter/material.dart';
import '../../../core/theme/SColor.dart';

                          class SOTPField extends StatefulWidget {
                            final int length;
                            final TextEditingController controller;

                            SOTPField({
                              Key? key,
                              required this.length,
                              required this.controller,
                            })  : assert(length > 0),
                                  super(key: key);

                            @override
                            State<SOTPField> createState() => _SOTPFieldState();
                          }

                          class _SOTPFieldState extends State<SOTPField> {
                            late List<FocusNode> _focusNodes;
                            late List<TextEditingController> _textControllers;

                            @override
                            void initState() {
                              super.initState();
                              _createFields(widget.length);
                              // Ensure combined controller is in sync
                              widget.controller.text = _textControllers.map((c) => c.text).join();
                              // Optionally request focus on first field
                              if (_focusNodes.isNotEmpty) {
                                _focusNodes.first.requestFocus();
                              }
                            }

                            @override
                            void didUpdateWidget(covariant SOTPField oldWidget) {
                              super.didUpdateWidget(oldWidget);
                              if (oldWidget.length != widget.length) {
                                // Preserve existing values up to the new length
                                final oldText = _textControllers.map((c) => c.text).toList();

                                // Dispose old nodes/controllers
                                for (var node in _focusNodes) {
                                  node.dispose();
                                }
                                for (var ctrl in _textControllers) {
                                  ctrl.dispose();
                                }

                                // Recreate with new length and restore texts where possible
                                _createFields(widget.length);
                                for (var i = 0; i < oldText.length && i < _textControllers.length; i++) {
                                  _textControllers[i].text = oldText[i];
                                }

                                // Update combined controller
                                widget.controller.text = _textControllers.map((c) => c.text).join();

                                // Ensure focus remains on a valid field
                                if (_focusNodes.isNotEmpty) {
                                  final firstEmptyIndex =
                                      _textControllers.indexWhere((c) => c.text.isEmpty);
                                  _focusNodes[(firstEmptyIndex == -1) ? (_focusNodes.length - 1) : firstEmptyIndex]
                                      .requestFocus();
                                }
                                setState(() {});
                              }
                            }

                            void _createFields(int length) {
                              _focusNodes = List.generate(length, (_) => FocusNode());
                              _textControllers = List.generate(length, (_) => TextEditingController());
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
                              if (index < 0 || index >= _textControllers.length) return;

                              // If pasted or multiple characters entered, keep the last char
                              if (value.length > 1) {
                                final char = value[value.length - 1];
                                _textControllers[index].text = char;
                              }

                              // Move focus forward when a value is entered
                              if (value.isNotEmpty && index + 1 < _focusNodes.length) {
                                _focusNodes[index + 1].requestFocus();
                              }

                              // Move focus back on delete
                              if (value.isEmpty && index - 1 >= 0) {
                                _focusNodes[index - 1].requestFocus();
                              }

                              // Update combined controller
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
                                        ),
                                      ),
                                      onChanged: (value) => _onChanged(index, value),
                                      autofocus: index == 0,
                                    ),
                                  );
                                }),
                              );
                            }
                          }