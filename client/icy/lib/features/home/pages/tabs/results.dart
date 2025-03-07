import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/features/home/pages/survey.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';

class SurveyResults extends StatelessWidget {
  const SurveyResults({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      return const Center(child: Text('Please log in to view survey results'));
    }

    // We'll get completed surveys from user profile once implemented
    // For now, show placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.analytics, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No survey results yet",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            "Complete surveys to see results here",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
