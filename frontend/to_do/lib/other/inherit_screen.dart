import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  final bool isDarkTheme; 
  final void Function() toggeTheme; 

  const ThemeProvider({required this.isDarkTheme, required this.toggeTheme, required super.child }); 

  static ThemeProvider? maybeOf (BuildContext context) => context.dependOnInheritedWidgetOfExactType<ThemeProvider>(); 

  static ThemeProvider of(BuildContext context) {
    final ThemeProvider? result = ThemeProvider.maybeOf(context); 
    assert(result !=null, 'No ThemeProvider found in widget tree'); 
    return result!; 
  }
  @override   
  bool updateShouldNotify(ThemeProvider oldWidget) => isDarkTheme != oldWidget.isDarkTheme; 


}

class ParentWidget extends StatefulWidget {
  const ParentWidget({super.key}); 

  @override
  State<ParentWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {

  bool isDarkTheme = false; 
  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme; 
    });
  }
  @override
  Widget build(BuildContext context) {
    return ThemeProvider(isDarkTheme: isDarkTheme, toggeTheme: toggleTheme, child: Testhehe()); 
  }
}

class Testhehe extends StatefulWidget {
  const Testhehe({super.key}); 

  @override
  State<Testhehe> createState() => _TestheheState();
}

class _TestheheState extends State<Testhehe> {

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies(); 
    bool isDark = ThemeProvider.of(context).isDarkTheme; 
    print('Theme Vừa thay đ                                                                                                                         ổi á bà ơi: Tối hả:  ${isDark}'); 
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 100,), 
          Container(
            height: 200,
            width: 200,
            color: ThemeProvider.of(context).isDarkTheme ? Colors.black : Colors.white12,
          ), 
          const SizedBox(height: 10,), 
          ElevatedButton(onPressed: ThemeProvider.of(context).toggeTheme , child: Text('Change Theme'))
        ],
      ),
    ); 
  }
}