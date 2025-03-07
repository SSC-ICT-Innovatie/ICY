import 'dart:io';

import 'package:border_progress_indicator/border_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/utils/constants.dart';
import 'package:icy/features/home/pages/survey.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/home/bloc/home_bloc.dart';

class OngoingSurvey extends StatelessWidget {
  const OngoingSurvey({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      return const Center(child: Text('Please log in to view ongoing surveys'));
    }

    // We'll get ongoing surveys from user profile once implemented
    // For now, show placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.pending_actions, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No ongoing surveys",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            "Start a survey to see it here",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
