import 'package:flutter/material.dart';
import 'package:animaltracker/app/data/models/weight_measurement.dart';
import 'package:animaltracker/app/data/models/birth_weight_measurement.dart';
import 'package:animaltracker/app/data/models/weaning_weight_measurement.dart';
import 'package:animaltracker/app/data/models/olcum_tipi.dart';
import 'package:intl/intl.dart';

class AddWeightDialog extends StatefulWidget {
  final OlcumTipi initialOlcumTipi;
  final Object? initialData;
  final Function(Object, OlcumTipi) onSave;

  const AddWeightDialog({
    Key? key,
    this.initialOlcumTipi = OlcumTipi.normal,
    this.initialData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _animalIdController = TextEditingController();
  final TextEditingController _rfidController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Weaning specific fields
  final TextEditingController _weaningAgeController = TextEditingController();
  final TextEditingController _motherRfidController = TextEditingController();
  DateTime? _weaningDate;

  // Birth specific fields
  final TextEditingController _birthPlaceController = TextEditingController();
  DateTime? _birthDate;

  DateTime _measurementDate = DateTime.now();

  // Seçilen ölçüm tipi
  late OlcumTipi _selectedOlcumTipi;

  // Form step için
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _selectedOlcumTipi = widget.initialOlcumTipi;

    // Populate fields if editing
    if (widget.initialData != null) {
      if (_selectedOlcumTipi == OlcumTipi.normal) {
        final data = widget.initialData as WeightMeasurement;
        _weightController.text = data.weight.toString();
        _animalIdController.text = data.animalId?.toString() ?? '';
        _rfidController.text = data.rfid ?? '';
        _notesController.text = data.notes ?? '';
        _measurementDate = data.measurementDate;
      } else if (_selectedOlcumTipi == OlcumTipi.suttenKesim) {
        final data = widget.initialData as WeaningWeightMeasurement;
        _weightController.text = data.weight.toString();
        _animalIdController.text = data.animalId?.toString() ?? '';
        _rfidController.text = data.rfid ?? '';
        _notesController.text = data.notes ?? '';
        _measurementDate = data.measurementDate;
        _weaningDate = data.weaningDate;
        _weaningAgeController.text = data.weaningAge?.toString() ?? '';
        _motherRfidController.text = data.motherRfid ?? '';
      } else if (_selectedOlcumTipi == OlcumTipi.yeniDogmus) {
        final data = widget.initialData as BirthWeightMeasurement;
        _weightController.text = data.weight.toString();
        _animalIdController.text = data.animalId?.toString() ?? '';
        _rfidController.text = data.rfid ?? '';
        _notesController.text = data.notes ?? '';
        _measurementDate = data.measurementDate;
        _birthDate = data.birthDate;
        _birthPlaceController.text = data.birthPlace ?? '';
        _motherRfidController.text = data.motherRfid ?? '';
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _animalIdController.dispose();
    _rfidController.dispose();
    _notesController.dispose();
    _weaningAgeController.dispose();
    _motherRfidController.dispose();
    _birthPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title;

    switch (_selectedOlcumTipi) {
      case OlcumTipi.normal:
        title = widget.initialData == null
            ? 'Yeni Ağırlık Ölçümü'
            : 'Ağırlık Ölçümünü Düzenle';
        break;
      case OlcumTipi.suttenKesim:
        title = widget.initialData == null
            ? 'Yeni Sütten Kesim Ölçümü'
            : 'Sütten Kesim Ölçümünü Düzenle';
        break;
      case OlcumTipi.yeniDogmus:
        title = widget.initialData == null
            ? 'Yeni Doğum Ölçümü'
            : 'Doğum Ölçümünü Düzenle';
        break;
    }

    return AlertDialog(
      title: Column(
        children: [
          Text(title),
          const SizedBox(height: 16),
          _buildStepIndicator(),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: _buildCurrentStepContent(),
        ),
      ),
      actions: _buildDialogActions(),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_totalSteps, (index) {
        bool isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStepTitle(index),
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Temel Bilgiler';
      case 1:
        return _selectedOlcumTipi == OlcumTipi.normal
            ? 'Notlar'
            : 'Özel Bilgiler';
      case 2:
        return 'Onay';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _selectedOlcumTipi == OlcumTipi.normal
            ? _buildNotesStep()
            : _buildTypeSpecificStep();
      case 2:
        return _buildSummaryStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ölçüm tipi seçimi
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ölçüm Tipi',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary)),
              const SizedBox(height: 8),
              RadioListTile<OlcumTipi>(
                title: const Text('Normal Ağırlık'),
                value: OlcumTipi.normal,
                groupValue: _selectedOlcumTipi,
                onChanged: (OlcumTipi? value) {
                  if (value != null) {
                    setState(() {
                      _selectedOlcumTipi = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              RadioListTile<OlcumTipi>(
                title: const Text('Sütten Kesim Ağırlığı'),
                value: OlcumTipi.suttenKesim,
                groupValue: _selectedOlcumTipi,
                onChanged: (OlcumTipi? value) {
                  if (value != null) {
                    setState(() {
                      _selectedOlcumTipi = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              RadioListTile<OlcumTipi>(
                title: const Text('Yeni Doğmuş Ağırlık'),
                value: OlcumTipi.yeniDogmus,
                groupValue: _selectedOlcumTipi,
                onChanged: (OlcumTipi? value) {
                  if (value != null) {
                    setState(() {
                      _selectedOlcumTipi = value;
                    });
                  }
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Ağırlık (kg)',
            prefixIcon: Icon(Icons.monitor_weight),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen ağırlık girin';
            }
            if (double.tryParse(value) == null) {
              return 'Geçerli bir ağırlık giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _rfidController,
          decoration: const InputDecoration(
            labelText: 'RFID',
            prefixIcon: Icon(Icons.nfc),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen RFID girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _animalIdController,
          decoration: const InputDecoration(
            labelText: 'Hayvan ID (İsteğe Bağlı)',
            prefixIcon: Icon(Icons.pets),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _measurementDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _measurementDate = pickedDate;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Ölçüm Tarihi',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              DateFormat('dd/MM/yyyy').format(_measurementDate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificStep() {
    if (_selectedOlcumTipi == OlcumTipi.suttenKesim) {
      return _buildWeaningSpecificStep();
    } else if (_selectedOlcumTipi == OlcumTipi.yeniDogmus) {
      return _buildBirthSpecificStep();
    } else {
      return _buildNotesStep();
    }
  }

  Widget _buildWeaningSpecificStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _motherRfidController,
          decoration: const InputDecoration(
            labelText: 'Anne RFID',
            prefixIcon: Icon(Icons.female),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _weaningAgeController,
          decoration: const InputDecoration(
            labelText: 'Sütten Kesim Yaşı (Gün)',
            prefixIcon: Icon(Icons.timelapse),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _weaningDate ?? _measurementDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _weaningDate = pickedDate;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Sütten Kesim Tarihi',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _weaningDate != null
                  ? DateFormat('dd/MM/yyyy').format(_weaningDate!)
                  : 'Tarih Seçin',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notlar',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildBirthSpecificStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _motherRfidController,
          decoration: const InputDecoration(
            labelText: 'Anne RFID',
            prefixIcon: Icon(Icons.female),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _birthPlaceController,
          decoration: const InputDecoration(
            labelText: 'Doğum Yeri',
            prefixIcon: Icon(Icons.place),
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? _measurementDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _birthDate = pickedDate;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Doğum Tarihi',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              _birthDate != null
                  ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                  : 'Tarih Seçin',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notlar',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildNotesStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notlar',
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSummaryStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Ölçüm Tipi'),
          subtitle: Text(_selectedOlcumTipi.displayName),
          leading: const Icon(Icons.category),
        ),
        ListTile(
          title: const Text('Ağırlık'),
          subtitle: Text('${_weightController.text} kg'),
          leading: const Icon(Icons.monitor_weight),
        ),
        ListTile(
          title: const Text('RFID'),
          subtitle: Text(_rfidController.text),
          leading: const Icon(Icons.nfc),
        ),
        if (_animalIdController.text.isNotEmpty)
          ListTile(
            title: const Text('Hayvan ID'),
            subtitle: Text(_animalIdController.text),
            leading: const Icon(Icons.pets),
          ),
        ListTile(
          title: const Text('Ölçüm Tarihi'),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(_measurementDate)),
          leading: const Icon(Icons.calendar_today),
        ),
        if (_selectedOlcumTipi == OlcumTipi.suttenKesim ||
            _selectedOlcumTipi == OlcumTipi.yeniDogmus)
          if (_motherRfidController.text.isNotEmpty)
            ListTile(
              title: const Text('Anne RFID'),
              subtitle: Text(_motherRfidController.text),
              leading: const Icon(Icons.female),
            ),
        if (_selectedOlcumTipi == OlcumTipi.suttenKesim) ...[
          if (_weaningDate != null)
            ListTile(
              title: const Text('Sütten Kesim Tarihi'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_weaningDate!)),
              leading: const Icon(Icons.calendar_today),
            ),
          if (_weaningAgeController.text.isNotEmpty)
            ListTile(
              title: const Text('Sütten Kesim Yaşı'),
              subtitle: Text('${_weaningAgeController.text} gün'),
              leading: const Icon(Icons.timelapse),
            ),
        ],
        if (_selectedOlcumTipi == OlcumTipi.yeniDogmus) ...[
          if (_birthDate != null)
            ListTile(
              title: const Text('Doğum Tarihi'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_birthDate!)),
              leading: const Icon(Icons.calendar_today),
            ),
          if (_birthPlaceController.text.isNotEmpty)
            ListTile(
              title: const Text('Doğum Yeri'),
              subtitle: Text(_birthPlaceController.text),
              leading: const Icon(Icons.place),
            ),
        ],
        if (_notesController.text.isNotEmpty)
          ListTile(
            title: const Text('Notlar'),
            subtitle: Text(_notesController.text),
            leading: const Icon(Icons.note),
            isThreeLine: true,
          ),
      ],
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      if (_currentStep > 0)
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep--;
            });
          },
          child: const Text('Geri'),
        ),
      if (_currentStep < _totalSteps - 1)
        ElevatedButton(
          onPressed: () {
            if (_currentStep == 0 && !_formKey.currentState!.validate()) {
              return;
            }
            setState(() {
              _currentStep++;
            });
          },
          child: const Text('İleri'),
        )
      else
        ElevatedButton(
          onPressed: _saveForm,
          child: Text(widget.initialData == null ? 'Ekle' : 'Güncelle'),
        ),
    ];
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double weight = double.tryParse(_weightController.text) ?? 0.0;
    final int? animalId = _animalIdController.text.isNotEmpty
        ? int.parse(_animalIdController.text)
        : null;
    final String rfid = _rfidController.text;
    final String notes = _notesController.text;

    Object result;

    switch (_selectedOlcumTipi) {
      case OlcumTipi.normal:
        result = WeightMeasurement(
          id: (widget.initialData as WeightMeasurement?)?.id,
          weight: weight,
          animalId: animalId,
          rfid: rfid,
          notes: notes,
          measurementDate: _measurementDate,
        );
        break;
      case OlcumTipi.suttenKesim:
        int? weaningAge;
        if (_weaningAgeController.text.isNotEmpty) {
          weaningAge = int.tryParse(_weaningAgeController.text);
        }
        result = WeaningWeightMeasurement(
          id: (widget.initialData as WeaningWeightMeasurement?)?.id,
          weight: weight,
          animalId: animalId,
          rfid: rfid,
          notes: notes,
          measurementDate: _measurementDate,
          weaningDate: _weaningDate ?? _measurementDate,
          weaningAge: weaningAge,
          motherRfid: _motherRfidController.text.isNotEmpty
              ? _motherRfidController.text
              : null,
        );
        break;
      case OlcumTipi.yeniDogmus:
        result = BirthWeightMeasurement(
          id: (widget.initialData as BirthWeightMeasurement?)?.id,
          weight: weight,
          animalId: animalId,
          rfid: rfid,
          notes: notes,
          measurementDate: _measurementDate,
          birthDate: _birthDate ?? _measurementDate,
          birthPlace: _birthPlaceController.text.isNotEmpty
              ? _birthPlaceController.text
              : null,
          motherRfid: _motherRfidController.text.isNotEmpty
              ? _motherRfidController.text
              : null,
        );
        break;
    }

    widget.onSave(result, _selectedOlcumTipi);
    Navigator.of(context).pop();
  }
}
