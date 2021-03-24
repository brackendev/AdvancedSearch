library auto_search;

import 'package:flutter/material.dart';

typedef OnTap = void Function(int index);

///Class for adding AutoSearchInput to your project
class AdvancedAutoSearch extends StatefulWidget {
  ///List of data that can be searched through for the results
  final List<String> data;

  ///The max number of elements to be displayed when the TextField is clicked
  final int maxElementsToDisplay;

  ///The color of text which actually appears in the results for which the text
  ///is typed
  final Color selectedTextColor;

  ///The color of text which actually appears in the results for the
  ///remaining text
  final Color unSelectedTextColor;

  ///Color of the border when the TextField is enabled
  final Color enabledBorderColor;

  ///Color of the border when the TextField is disabled
  final Color disabledBorderColor;

  ///Color of the border when the TextField is being interated with
  final Color focusedBorderColor;

  ///Color of the cursor
  final Color cursorColor;

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

  ///Boolean to set whether the TextField is enabled
  final bool enabled;

  ///onSubmitted function
  final Function onSubmitted;

  ///Function to call when a certain item is clicked
  /// Takes in a parameter of the item which was clicked
  final OnTap onItemTap;

  final Function onSearchClear;

  ///onEditingComplete function
  final Function onEditingComplete;

  ///List Background Color
  final Color bgColor;

  final SearchMode searchMode;

  final bool caseSensitive;

  final int minLettersForSearch;

  final Color borderColor;

  final bool clearSearchEnabled;

  final bool showListOfResults;

  const AdvancedAutoSearch({
    @required this.data,
    @required this.maxElementsToDisplay,
    @required this.onItemTap,
    @required this.onSearchClear,
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
    this.enabled = true,
    this.onSubmitted,
    this.onEditingComplete,
    this.bgColor = Colors.white,
    this.searchMode = SearchMode.CONTAINS,
    this.caseSensitive = false,
    this.minLettersForSearch = 0,
    this.borderColor = const Color(0xFFFAFAFA),
    this.clearSearchEnabled = true,
    this.showListOfResults = true,
  }) : assert(data != null, maxElementsToDisplay != null);

  @override
  _AdvancedAutoSearchState createState() => _AdvancedAutoSearchState();
}

class _AdvancedAutoSearchState extends State<AdvancedAutoSearch> {
  List<String> results = [];
  bool isItemClicked = false;
  String lastSubmittedText = "";
  String _previouslyResultedText = "";

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController..addListener(onSearchTextChanges);
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
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              TextField(
                autocorrect: widget.autoCorrect,
                enabled: widget.enabled,
                onEditingComplete: () {
                  if (widget.onEditingComplete != null &&
                      (_textEditingController.text != "" ||
                          _previouslyResultedText != "") &&
                      _textEditingController.text != _previouslyResultedText) {
                    widget.onEditingComplete(
                        _textEditingController.text, results);
                    _previouslyResultedText = _textEditingController.text;
                  }
                },
                onSubmitted: (value) {
                  if (lastSubmittedText == value) {
                    return; // Nothing new to Submit
                  }
                  lastSubmittedText = value;
                  setState(() {
                    isItemClicked = true;
                  });
                  if (lastSubmittedText == "")
                    widget.onSearchClear();
                  else
                    widget.onSubmitted(lastSubmittedText, results);
                },
                onTap: () {
                  setState(() {
                    isItemClicked = false;
                  });
                },
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  contentPadding: const EdgeInsets.all(10.0),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.disabledBorderColor != null
                            ? widget.borderRadius
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.enabledBorderColor != null
                          ? widget.borderRadius
                          : Colors.grey[200],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.borderRadius),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: widget.focusedBorderColor != null
                            ? widget.borderRadius
                            : Colors.grey[200]),
                    borderRadius: BorderRadius.only(
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
              widget.clearSearchEnabled
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          if (_textEditingController.text.length == 0) return;
                          setState(() {
                            _textEditingController.clear();
                            widget.onSearchClear();
                            isItemClicked = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.highlight_remove,
                            size: 27,
                            color: _textEditingController.text.length == 0
                                ? Colors.grey[300]
                                : Colors.grey,
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
            height: widget.itemsShownAtStart * widget.singleItemHeight,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Container(
                  height: widget.singleItemHeight,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: widget.bgColor,
                    border: Border.all(color: widget.borderColor),
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
                  ),
                  child: GestureDetector(
                    onTap: () {
                      String value = results[index];
                      widget.onItemTap(widget.data.indexOf(value));
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
                    child: _getRichText(results[index]),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void onSearchTextChanges() {
    if (_textEditingController.text.length < widget.minLettersForSearch) {
      setState(() {
        results = [];
      });
      return;
    }
    String searchText = widget.caseSensitive
        ? _textEditingController.text
        : _textEditingController.text.toLowerCase();
    switch (widget.searchMode) {
      case SearchMode.STARTING_WITH:
        setState(() {
          results = widget.data
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
          results = widget.data
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
          results = widget.data
              .where(
                (element) =>
                    (widget.caseSensitive ? element : element.toLowerCase()) ==
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
}

enum SearchMode {
  STARTING_WITH,
  CONTAINS,
  EXACT_MATCH,
}
