import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/reminders/data/remainder_model.dart';
import 'package:bloodinsight/shared/services/reminder_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RescheduleReminderPage extends StatefulWidget {
  const RescheduleReminderPage({
    super.key,
    required this.reminderId,
  });

  final String reminderId;

  @override
  State<RescheduleReminderPage> createState() => _RescheduleReminderPageState();
}

class _RescheduleReminderPageState extends State<RescheduleReminderPage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isFasting;
  late BloodworkReminder _reminder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    try {
      final reminder =
          await context.read<ReminderService>().getReminder(widget.reminderId);
      if (reminder == null) {
        throw StateError('Reminder not found');
      }

      setState(() {
        _reminder = reminder;
        _selectedDate = reminder.scheduledDate;
        _selectedTime = TimeOfDay.fromDateTime(reminder.scheduledDate);
        _isFasting = reminder.isFasting;
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _error = err.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
          ..showSnackBar(_error!, isError: true)
          ..pop();
      });
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reschedule Bloodwork',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: Sizes.kPadd16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            Sizes.kGap20,
            _buildDateTimeSection(),
            Sizes.kGap20,
            if (_reminder.notes != null) _buildNotesSection(),
            Sizes.kGap20,
            _buildSubmitButton(),
            Sizes.kGap20,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Laboratory Name',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              _reminder.labName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: InkWell(
              onTap: _selectDate,
              highlightColor:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date'),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Material(
            color: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: InkWell(
              onTap: _selectTime,
              highlightColor:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time'),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime.format(context),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Material(
            color: Colors.transparent,
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: InkWell(
              onTap: () => setState(() {
                _isFasting = !_isFasting;
              }),
              highlightColor:
                  Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              child: IgnorePointer(
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.no_food_outlined,
                    color: _isFasting
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: const Text('Fasting Required'),
                  subtitle: const Text('Fasting is needed before the test'),
                  value: _isFasting,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    if (_reminder.notes == null) {
      return Sizes.kEmptyWidget;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(_reminder.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final newDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final hasChanges = newDateTime != _reminder.scheduledDate ||
        _isFasting != _reminder.isFasting;

    return Padding(
      padding: Sizes.kPaddH20,
      child: FilledButton(
        onPressed: hasChanges ? _updateReminder : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: Sizes.kRadius16,
          ),
        ),
        child: const Text(
          'Update Schedule',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _updateReminder() async {
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedReminder = _reminder.copyWith(
      scheduledDate: scheduledDateTime,
      isFasting: _isFasting,
    );

    try {
      await context.read<ReminderService>().updateReminder(updatedReminder);
      if (mounted) {
        context
          ..showSnackBar('Reminder updated successfully')
          ..pop();
      }
    } catch (err) {
      if (mounted) {
        context.showSnackBar('Error: $err', isError: true);
      }
    }
  }
}
