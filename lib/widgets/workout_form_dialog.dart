import 'package:flutter/material.dart';
import 'package:lab_02/domain/models/workout.dart';

class WorkoutInput {
  const WorkoutInput({required this.title, required this.reason});

  final String title;
  final String reason;
}

class WorkoutFormDialog extends StatefulWidget {
  const WorkoutFormDialog({this.workout, super.key});

  final Workout? workout;

  @override
  State<WorkoutFormDialog> createState() => _WorkoutFormDialogState();
}

class _WorkoutFormDialogState extends State<WorkoutFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.workout?.title ?? '');

    _reasonController = TextEditingController(
      text: widget.workout?.reason ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(context).pop(
      WorkoutInput(
        title: _titleController.text.trim(),
        reason: _reasonController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workout != null;
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing
                            ? Icons.edit_note_rounded
                            : Icons.add_circle_outline,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Редагувати тренування' : 'Нове тренування',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  isEditing
                      ? 'Зміни інформацію про своє тренування.'
                      : 'Додай тренування до свого списку.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Назва тренування',
                    hintText: 'Наприклад: Morning Run',
                    prefixIcon: const Icon(Icons.fitness_center_outlined),
                    counterText: '',
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введіть назву тренування';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _reasonController,
                  maxLength: 240,
                  minLines: 2,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Опис тренування',
                    hintText: 'Наприклад: Running for 30 minutes',
                    alignLabelWithHint: true,
                    counterText: '',
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введіть опис тренування';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Скасувати'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: Icon(
                          isEditing ? Icons.check : Icons.add,
                          size: 18,
                        ),
                        label: Text(isEditing ? 'Зберегти' : 'Додати'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
