import 'package:flutter/material.dart';
import 'package:to_do/core/utils/utils.dart';
import 'package:to_do/features/task/data/models/task_model.dart';
import 'package:to_do/features/task/domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child:
        
      Container(
        decoration: BoxDecoration(
             shape: BoxShape.rectangle,
           border: Border.all(width: 1), 
           borderRadius: BorderRadius.circular(10)
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(task.description),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    backgroundColor:
                        Utils.mappingColors[task.priority] ?? Colors.white,
                    label: Text('Priority: ${task.priority}'),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                      label: Text(
                          'Due: ${task.dueDate?.toString().split(' ')[0] ?? 'N/A'}')),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}
