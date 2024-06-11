import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomDropdownInDrawer(),
    );
  }
}

class CustomDropdownInDrawer extends StatefulWidget {
  const CustomDropdownInDrawer({super.key});

  @override
  _CustomDropdownInDrawerState createState() => _CustomDropdownInDrawerState();
}

class _CustomDropdownInDrawerState extends State<CustomDropdownInDrawer>
    with SingleTickerProviderStateMixin {
  final List<String> _dropdownItems = ['One', 'Two', 'Three', 'Four', 'Five'];
  String? _selectedItem;
  bool _isDropdownOpened = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  GlobalKey globalKey = GlobalKey();
  late AnimationController animationController;
  late Animation<double> animation;

  late OverlayState _overlayState;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animation =
        CurveTween(curve: Curves.fastOutSlowIn).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Dropdown in Drawer'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight),
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                key: globalKey,
                onTap: () {
                  if (_isDropdownOpened) {
                    _closeDropdown();
                  } else {
                    _openDropdown();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 15.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          if (_selectedItem != null)
                            const Icon(Icons.circle),
                          if (_selectedItem != null)
                            const SizedBox(width: 10),
                          Text(_selectedItem ?? 'Select Item'),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
            // Add other drawer items here
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Content goes here'),
      ),
    );
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    _overlayState = Overlay.of(context);
    _overlayState.insert(_overlayEntry!);
    animationController.forward();
    setState(() {
      _isDropdownOpened = true;
    });
  }

  void _closeDropdown() {
    animationController.reverse().then((value) {
      _overlayEntry?.remove();
      setState(() {
        _isDropdownOpened = false;
      });
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox =
    globalKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    List<String> filteredItems = _dropdownItems.where((item) => item != _selectedItem).toList();

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: Material(
          elevation: 2.0,
          child: FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: filteredItems.length + 1, // +1 for the special item
                  itemBuilder: (context, index) {
                    if (index == filteredItems.length - 1) {
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.circle),
                            title: Text(filteredItems[index]),
                            onTap: () {
                              setState(() {
                                _selectedItem = filteredItems[index];
                              });
                              _closeDropdown();
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    } else if (index == filteredItems.length) {
                      return ListTile(
                        leading: const Icon(Icons.circle),
                        title: const Text("Special item"),
                        onTap: () {
                          _closeDropdown();
                          print("doing special action");
                        },
                      );
                    } else {
                      return ListTile(
                        leading: const Icon(Icons.circle),
                        title: Text(filteredItems[index]),
                        onTap: () {
                          setState(() {
                            _selectedItem = filteredItems[index];
                          });
                          _closeDropdown();
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

