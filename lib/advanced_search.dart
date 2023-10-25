library advanced_search;

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'CustomRoundedRectangleBorder';

typedef OnTap = void Function(int index, String value);
typedef SubmitResults = void Function(
    String searchText, List<String> searchResults);
typedef SearchClear = void Function();
typedef WidgetItems = Widget Function(String);

///Class for adding AutoSearchInput to your project
class AdvancedSearch extends StatefulWidget {
  ///List of data that can be searched through for the results
  final List<String> searchItems;

  ///The max number of elements to be displayed when the TextField is clicked
  final int maxElementsToDisplay;

  ///The color of text which actually appears in the results for which the text
  ///is typed
  final Color? selectedTextColor;

  ///The color of text which actually appears in the results for the
  ///remaining text
  final Color? unSelectedTextColor;

  ///Color of the border when the TextField is enabled
  final Color? enabledBorderColor;

  ///Color of the border when the TextField is disabled
  final Color? disabledBorderColor;

  ///Color of the border when the TextField is being integrated with
  final Color? focusedBorderColor;

  ///Color of the cursor
  final Color? cursorColor;

  ///Border Radius of the TextField and the resultant elements
  final double borderRadius;

  ///Font Size for both the text in the TextField and the results
  final double fontSize;

  ///Height of a single item in the resultant list
  final double singleItemHeight;

  ///Number of items to be shown when the TextField is tapped
  final int itemsShownAtStart;

  ///Hint text to show inside the TextField
  final String hintText;

  ///Boolean to set autoCorrect
  final bool autoCorrect;

  ///Boolean to set autoFocus
  final bool autoFocus;

  ///Boolean to set whether the TextField is enabled
  final bool enabled;

  ///onSubmitted function
  final SubmitResults? onSubmitted;

  ///Function to call when a certain item is clicked
  /// Takes in a parameter of the item which was clicked
  final OnTap onItemTap;

  /// Callback to be called when the user clears his search
  final SearchClear onSearchClear;

  /// Function to be called on editing the text field
  final SubmitResults? onEditingProgress;

  /// Text Inout Background Color
  final Color? inputTextFieldBgColor;

  ///List Background Color
  final Color searchResultsBgColor;

  final SearchMode searchMode;

  final bool caseSensitive;

  final int minLettersForSearch;

  final Color borderColor;

  final Color hintTextColor;

  final bool clearSearchEnabled;

  final bool showListOfResults;

  final bool hideHintOnTextInputFocus;

  final double verticalPadding;

  final double horizontalPadding;

  final WidgetItems? searchItemsWidget;

  final bool autoListing;

  const AdvancedSearch({
    required this.searchItems,
    required this.onItemTap,
    this.maxElementsToDisplay = 7,
    this.onSearchClear = _searchClearDefaultFunction,
    this.selectedTextColor,
    this.unSelectedTextColor,
    this.enabledBorderColor,
    this.disabledBorderColor,
    this.focusedBorderColor,
    this.cursorColor,
    this.borderRadius = 10.0,
    this.fontSize = 14.0,
    this.singleItemHeight = 45.0,
    this.itemsShownAtStart = 10,
    this.hintText = 'Enter a name',
    this.autoCorrect = false,
    this.autoFocus = false,
    this.enabled = true,
    this.onSubmitted,
    this.onEditingProgress,
    this.inputTextFieldBgColor,
    this.searchResultsBgColor = Colors.white,
    this.searchMode = SearchMode.CONTAINS,
    this.caseSensitive = false,
    this.minLettersForSearch = 0,
    this.borderColor = const Color(0xFFFAFAFA),
    this.hintTextColor = Colors.grey,
    this.clearSearchEnabled = true,
    this.showListOfResults = true,
    this.hideHintOnTextInputFocus = false,
    this.verticalPadding = 10,
    this.horizontalPadding = 10,
    this.searchItemsWidget,
    this.autoListing = false,
  });

  @override
  _AdvancedSearchState createState() => _AdvancedSearchState();

  static _searchClearDefaultFunction() {
    // Nothing to do here,
    // if the user don't want to do anything special in clearing so that's it
  }
}

class _AdvancedSearchState extends State<AdvancedSearch> {
  List<String> results = [];
  bool isItemClicked = false;
  String lastSubmittedText = "";
  String? hintText;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController..addListener(onSearchTextChanges);

    hintText = widget.hintText;

    var keyboardVisibilityController = KeyboardVisibilityController();

    // Subscribe
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          if (!visible) {
            if (_textEditingController.text != null) {
              sendSubmitResults(_textEditingController.text);
            }
            removeTextFieldFocus();
            if (widget.hideHintOnTextInputFocus) {
              setState(() {
                hintText = widget.hintText;
              });
            }
          } else {
            if (widget.hideHintOnTextInputFocus) {
              setState(() {
                hintText = "";
              });
            }
          }
        });
      }
    });
    if (widget.autoListing) {
      try {
        onSearchTextChanges();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Widget _getRichText(String result) {
    String textSelected = "";
    String textBefore = "";
    String textAfter = "";
    try {
      String lowerCaseResult =
          widget.caseSensitive ? result : result.toLowerCase();
      String lowerCaseSearchText = widget.caseSensitive
          ? _textEditingController.text
          : _textEditingController.text.toLowerCase();
      textSelected = result.substring(
          lowerCaseResult.indexOf(lowerCaseSearchText),
          lowerCaseResult.indexOf(lowerCaseSearchText) +
              lowerCaseSearchText.length);
      String loserCaseTextSelected =
          widget.caseSensitive ? textSelected : textSelected.toLowerCase();
      textBefore =
          result.substring(0, lowerCaseResult.indexOf(loserCaseTextSelected));
      if (lowerCaseResult.indexOf(loserCaseTextSelected) + textSelected.length <
          result.length) {
        textAfter = result.substring(
            lowerCaseResult.indexOf(loserCaseTextSelected) +
                textSelected.length,
            result.length);
      }
    } catch (e) {
      print(e.toString());
    }
    return Container(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: _textEditingController.text.length > 0
            ? TextSpan(
                children: [
                  if (_textEditingController.text.length > 0)
                    TextSpan(
                      text: textBefore,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        color: widget.unSelectedTextColor != null
                            ? widget.unSelectedTextColor
                            : Colors.grey[400],
                      ),
                    ),
                  TextSpan(
                    text: textSelected,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.selectedTextColor != null
                          ? widget.selectedTextColor
                          : Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: textAfter,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: widget.unSelectedTextColor != null
                          ? widget.unSelectedTextColor
                          : Colors.grey[400],
                    ),
                  )
                ],
              )
            : TextSpan(
                text: result,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: widget.unSelectedTextColor != null
                      ? widget.unSelectedTextColor
                      : Colors.grey[400],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLtr = Directionality.of(context) == TextDirection.ltr;
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: widget.inputTextFieldBgColor,
              borderRadius: results.length == 0 || isItemClicked
                  ? BorderRadius.all(
                      Radius.circular(widget.borderRadius),
                    )
                  : BorderRadius.only(
                      topLeft: Radius.circular(widget.borderRadius),
                      topRight: Radius.circular(widget.borderRadius),
                    ),
            ),
            child: Stack(
              children: [
                TextField(
                  autocorrect: widget.autoCorrect,
                  autofocus: widget.autoFocus,
                  enabled: widget.enabled,
                  onEditingComplete: () {
                    sendSubmitResults(_textEditingController.text);
                    removeTextFieldFocus();
                  },
                  onSubmitted: (value) {
                    removeTextFieldFocus();
                  },
                  onTap: () {
                    setState(() {
                      isItemClicked = false;
                    });
                  },
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: widget.hintTextColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: widget.verticalPadding,
                        horizontal: widget.horizontalPadding),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: widget.disabledBorderColor != null
                              ? widget.disabledBorderColor!
                              : Colors.grey[300]!),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.enabledBorderColor != null
                            ? widget.enabledBorderColor!
                            : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: widget.focusedBorderColor != null
                              ? widget.focusedBorderColor!
                              : Colors.grey[300]!),
                      borderRadius: results.length == 0 || isItemClicked
                          ? BorderRadius.all(
                              Radius.circular(widget.borderRadius),
                            )
                          : BorderRadius.only(
                              topLeft: Radius.circular(widget.borderRadius),
                              topRight: Radius.circular(widget.borderRadius),
                            ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: widget.fontSize,
                  ),
                  cursorColor: widget.cursorColor != null
                      ? widget.cursorColor
                      : Colors.grey[600],
                ),
                widget.clearSearchEnabled &&
                        _textEditingController.text.length > 0
                    ? Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        left: 0,
                        child: Align(
                          alignment: isLtr
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (_textEditingController.text.length == 0)
                                return;
                              setState(() {
                                _textEditingController.clear();
                                widget.onSearchClear();
                                isItemClicked = true;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: _textEditingController.text.length == 0
                                    ? Colors.grey[300]
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
          if (!isItemClicked && widget.showListOfResults)
            Container(
              height: results.length * widget.singleItemHeight,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      String value = results[index];
                      widget.onItemTap(
                          widget.searchItems.indexOf(value), value);
                      _textEditingController.text = value;
                      _textEditingController.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                          offset: value.length,
                        ),
                      );
                      setState(() {
                        isItemClicked = true;
                      });
                    },
                    child: widget.searchItemsWidget != null
                        ? widget.searchItemsWidget!(results[index])
                        : Container(
                            height: widget.singleItemHeight,
                            padding: const EdgeInsets.all(8.0),
                            child: _getRichText(results[index]),
                            decoration: ShapeDecoration(
                              color: widget.searchResultsBgColor,
                              shape: CustomRoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    index == (results.length - 1)
                                        ? widget.borderRadius
                                        : 0.0,
                                  ),
                                  bottomRight: Radius.circular(
                                    index == (results.length - 1)
                                        ? widget.borderRadius
                                        : 0.0,
                                  ),
                                ),
                                leftSide: BorderSide(color: widget.borderColor),
                                bottomLeftCornerSide:
                                    BorderSide(color: widget.borderColor),
                                rightSide:
                                    BorderSide(color: widget.borderColor),
                                bottomRightCornerSide:
                                    BorderSide(color: widget.borderColor),
                                bottomSide:
                                    BorderSide(color: widget.borderColor),
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void onSearchTextChanges() {
    if (lastSubmittedText == _textEditingController.text &&
        isItemClicked == true) {
      setState(() {
        isItemClicked = false;
      });
      return;
    }
    setState(() {
      isItemClicked = false;
    });
    if (_textEditingController.text.length < widget.minLettersForSearch) {
      setState(() {
        results = [];
      });
    } else {
      String searchText = widget.caseSensitive
          ? _textEditingController.text
          : _textEditingController.text.toLowerCase();
      switch (widget.searchMode) {
        case SearchMode.STARTING_WITH:
          setState(() {
            results = widget.searchItems
                .where(
                  (element) =>
                      (widget.caseSensitive ? element : element.toLowerCase())
                          .startsWith(searchText),
                )
                .toList();
          });
          break;
        case SearchMode.CONTAINS:
          setState(() {
            results = widget.searchItems
                .where(
                  (element) =>
                      (widget.caseSensitive ? element : element.toLowerCase())
                          .contains(searchText),
                )
                .toList();
          });
          break;
        case SearchMode.EXACT_MATCH:
          setState(() {
            results = widget.searchItems
                .where(
                  (element) =>
                      (widget.caseSensitive
                          ? element
                          : element.toLowerCase()) ==
                      searchText,
                )
                .toList();
          });
          break;
      }
      setState(() {
        if (results.length > widget.maxElementsToDisplay) {
          results = results.sublist(0, widget.maxElementsToDisplay);
        }
      });
    }
    // now send the latest updates
    if (widget.onEditingProgress != null) {
      widget.onEditingProgress!(_textEditingController.text, results);
    }
  }

  void sendSubmitResults(value) {
    try {
      if (lastSubmittedText == value) {
        setState(() {
          results = [];
        });
        return; // Nothing new to Submit
      }
      lastSubmittedText = value;
      setState(() {
        isItemClicked = true;
      });
      if (lastSubmittedText == "")
        widget.onSearchClear();
      else
        widget.onSubmitted!(lastSubmittedText, results);
      setState(() {
        results = [];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void removeTextFieldFocus() {
    try {
      FocusScope.of(context).unfocus();
    } catch (e) {
      print(e.toString());
    }
  }
}

enum SearchMode {
  STARTING_WITH,
  CONTAINS,
  EXACT_MATCH,
}
