import 'package:flutter/material.dart';
import 'package:diagora/providers/theme_provider.dart';

class ThemeView extends StatefulWidget {
  const ThemeView({
    Key? key,
  }) : super(key: key);

  @override
  ThemeViewState createState() => ThemeViewState();
}

class ThemeViewState extends State<ThemeView> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final _themeModeController =
      TextEditingController(); // Select field ["system", "light", "dark"]
  ThemeMode originalThemeMode = ThemeMode.system;

  ThemeProvider? themeProvider;

  @override
  void initState() {
    super.initState();
    _themeModeController.text = ThemeMode.system.toString();
    _initProviders();
  }

  @override
  void dispose() {
    _themeModeController.dispose();
    super.dispose();
  }

  void _initProviders() async {
    themeProvider = ThemeProvider.of(context);
    await themeProvider?.initialize();
    setState(() {
      _themeModeController.text = themeProvider!.themeMode.toString();
      originalThemeMode = themeProvider!.themeMode;
    });
  }

  void _submitForm(context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      ThemeModeOption themeModeOption = ThemeModeOption.system;
      switch (_themeModeController.text) {
        case "ThemeMode.light":
          themeModeOption = ThemeModeOption.light;
          break;
        case "ThemeMode.dark":
          themeModeOption = ThemeModeOption.dark;
          break;
        default:
          themeModeOption = ThemeModeOption.system;
          break;
      }
      await themeProvider?.setThemeMode(themeModeOption);
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (originalThemeMode == themeProvider!.themeMode) {
              Navigator.of(context).pop(true);
              return;
            }
            ThemeModeOption themeModeOption = ThemeModeOption.system;
            switch (originalThemeMode) {
              case ThemeMode.light:
                themeModeOption = ThemeModeOption.light;
                break;
              case ThemeMode.dark:
                themeModeOption = ThemeModeOption.dark;
                break;
              default:
                themeModeOption = ThemeModeOption.system;
                break;
            }
            themeProvider?.setThemeMode(themeModeOption);
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          loading == true
              ? const IconButton(
                  icon: Icon(Icons.check),
                  onPressed: null,
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    _submitForm(context);
                  },
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Dark mode'),
                  enabled: loading == false,
                  trailing: DropdownButton(
                    value: _themeModeController.text,
                    onChanged: (String? newValue) {
                      setState(() {
                        _themeModeController.text = newValue!;
                        ThemeModeOption themeModeOption;
                        switch (newValue) {
                          case "ThemeMode.light":
                            themeModeOption = ThemeModeOption.light;
                            break;
                          case "ThemeMode.dark":
                            themeModeOption = ThemeModeOption.dark;
                            break;
                          default:
                            themeModeOption = ThemeModeOption.system;
                            break;
                        }
                        themeProvider?.setThemeMode(themeModeOption);
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: "ThemeMode.system",
                        child: Text("System"),
                      ),
                      DropdownMenuItem(
                        value: "ThemeMode.light",
                        child: Text("Light"),
                      ),
                      DropdownMenuItem(
                        value: "ThemeMode.dark",
                        child: Text("Dark"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
