import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/state/medflow_state.dart';
import 'features/navigation/medflow_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MedFlowApp());
}

class MedFlowApp extends StatefulWidget {
  const MedFlowApp({super.key});

  @override
  State<MedFlowApp> createState() => _MedFlowAppState();
}

class _MedFlowAppState extends State<MedFlowApp> {
  late final MedFlowState _state;

  @override
  void initState() {
    super.initState();
    _state = MedFlowState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MedFlowScope(
      notifier: _state,
      child: MaterialApp(
        title: 'MedFlow - Hospital Management App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MedFlowNavigationShell(),
      ),
    );
  }
}
