import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:bloodinsight/core/styles/style.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodmarker_definitions.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodmarker_model.dart';
import 'package:bloodinsight/features/bloodwork/data/bloodwork_model.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MarkerEntry {
  MarkerEntry({
    this.markerDefinition,
    required this.valueController,
  });

  MarkerDefinition? markerDefinition;
  final TextEditingController valueController;
}

class AddBloodworkPage extends StatefulWidget {
  const AddBloodworkPage({super.key, this.bloodworkId});
  final String? bloodworkId;

  @override
  State<AddBloodworkPage> createState() => _AddBloodworkPageState();
}

class _AddBloodworkPageState extends State<AddBloodworkPage> {
  final _formKey = GlobalKey<FormState>();
  final _labNameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<MarkerEntry> _markers = [];
  bool _isLoading = false;
  bool get _isEditMode => widget.bloodworkId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadExistingBloodwork();
    } else {
      _initializeMarkers();
    }
  }

  Future<void> _loadExistingBloodwork() async {
    setState(() => _isLoading = true);
    try {
      final bloodwork = await context
          .read<BloodworkService>()
          .getBloodwork(widget.bloodworkId!);

      _labNameController.text = bloodwork.labName;
      _selectedDate = bloodwork.dateCollected;

      setState(() {
        _markers
          ..clear()
          ..addAll(
            bloodwork.markers.map(
              (m) => MarkerEntry(
                markerDefinition:
                    markerDefinitions.firstWhere((def) => def.name == m.name),
                valueController:
                    TextEditingController(text: m.value.toString()),
              ),
            ),
          );
      });
    } catch (err) {
      if (mounted) {
        context.showSnackBar('Error loading bloodwork: $err', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeMarkers() {
    _markers.add(
      MarkerEntry(
        valueController: TextEditingController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Bloodwork' : 'Add New Bloodwork',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _saveBloodwork,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Sizes.kPadd16,
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildInfoCard(),
                    Sizes.kGap20,
                    Text(
                      'Blood Markers',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Sizes.kGap20,
                    ..._markers.map(_buildMarkerCard),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: _addMarker,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Marker'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    Sizes.kGap20,
                  ],
                ),
              ),
            ),
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
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bloodwork Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labNameController,
              onTapOutside: (event) =>
                  FocusScope.of(context).requestFocus(FocusNode()),
              decoration: InputDecoration(
                labelText: 'Laboratory Name',
                hintText: 'Enter laboratory name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.local_hospital_outlined),
              ),
              validator: (value) => value?.isEmpty ?? true
                  ? 'Please enter laboratory name'
                  : null,
            ),
            const Divider(height: 24),
            Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              borderRadius: Sizes.kRadius12,
              child: InkWell(
                onTap: () => _selectDate(context),
                highlightColor:
                    Theme.of(context).colorScheme.tertiary.withAlpha(25),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                            const Text('Date Collected'),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, y')
                                  .format(_selectedDate),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerCard(MarkerEntry marker) {
    final definition = marker.markerDefinition;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: Sizes.kPadd20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Sizes.kRadius16,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<MarkerDefinition>(
                  value: marker.markerDefinition,
                  decoration: const InputDecoration(
                    labelText: 'Marker Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down_rounded),
                  dropdownColor: Colors.white,
                  menuMaxHeight: 300,
                  style: Theme.of(context).textTheme.bodyLarge,
                  selectedItemBuilder: (context) {
                    return markerDefinitions.map((def) {
                      return Text(
                        def.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }).toList();
                  },
                  items: markerDefinitions.map((def) {
                    return DropdownMenuItem(
                      value: def,
                      child: Text(
                        def.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      marker.markerDefinition = value;
                      marker.valueController.clear();
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                ),
              ),
              Sizes.kGap15,
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _removeMarker(marker),
              ),
            ],
          ),
          Sizes.kGap15,
          TextFormField(
            controller: marker.valueController,
            decoration: InputDecoration(
              labelText: 'Value',
              suffixText: definition?.unit.toString(),
              helperText: definition != null
                  ? 'Normal range: ${definition.minRange} - ${definition.maxRange} ${definition.unit}'
                  : null,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Required';
              }
              final number = double.tryParse(value!);
              if (number == null) {
                return 'Invalid number';
              }
              return null;
            },
            onTapOutside: (event) =>
                FocusScope.of(context).requestFocus(FocusNode()),
          ),
        ],
      ),
    );
  }

  void _addMarker() {
    setState(() {
      _markers.add(
        MarkerEntry(
          valueController: TextEditingController(),
        ),
      );
    });
  }

  void _removeMarker(MarkerEntry marker) {
    if (_markers.length > 1) {
      setState(() {
        _markers.remove(marker);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveBloodwork() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final markers = _markers
            .map(
              (entry) => BloodMarker(
                name: entry.markerDefinition!.name,
                value: double.parse(entry.valueController.text),
                unit: entry.markerDefinition!.unit.toString(),
                minRange: entry.markerDefinition!.minRange,
                maxRange: entry.markerDefinition!.maxRange,
                category: entry.markerDefinition!.category,
              ),
            )
            .toList();

        final bloodwork = Bloodwork(
          id: widget.bloodworkId ?? '',
          labName: _labNameController.text,
          dateCollected: _selectedDate,
          markers: markers,
        );

        final bloodworkService = context.read<BloodworkService>();
        if (_isEditMode) {
          await bloodworkService.updateBloodwork(
            widget.bloodworkId!,
            bloodwork,
          );
        } else {
          await bloodworkService.addBloodwork(bloodwork);
        }

        if (mounted) {
          context
            ..showSnackBar(
              _isEditMode
                  ? 'Bloodwork updated successfully'
                  : 'Bloodwork added successfully',
            )
            ..pop();
        }
      } catch (err) {
        if (mounted) {
          context.showSnackBar('Error saving bloodwork: $err', isError: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _labNameController.dispose();
    for (final marker in _markers) {
      marker.valueController.dispose();
    }
    super.dispose();
  }
}
