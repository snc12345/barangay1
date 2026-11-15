import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfficialFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const OfficialFormPage({super.key, this.documentId, this.initialData});

  @override
  State<OfficialFormPage> createState() => _OfficialFormPageState();
}

class _OfficialFormPageState extends State<OfficialFormPage> {
  final _key = GlobalKey<FormState>();

  static const Color primaryBlue = Color(0xFF123B6D);
  static const Color accentBlue = Color(0xFF2878C8);
  static const Color backgroundColor = Color(0xFFF3F6FB);

  late final TextEditingController _id;
  late final TextEditingController _name;
  late final TextEditingController _position;
  late final TextEditingController _termStart;
  late final TextEditingController _termEnd;
  late final TextEditingController _contact;
  late final TextEditingController _email;

  String? _status;
  bool _saving = false;

  bool get _isEditing => widget.documentId != null;

  @override
  void initState() {
    super.initState();

    final d = widget.initialData ?? {};

    _id = TextEditingController(text: d['officialId']?.toString() ?? '');
    _name = TextEditingController(text: d['fullName']?.toString() ?? '');
    _position = TextEditingController(text: d['position']?.toString() ?? '');
    _termStart = TextEditingController(text: d['termStart']?.toString() ?? '');
    _termEnd = TextEditingController(text: d['termEnd']?.toString() ?? '');
    _contact = TextEditingController(
      text: d['contactNumber']?.toString() ?? '',
    );
    _email = TextEditingController(text: d['officeEmail']?.toString() ?? '');

    const statuses = ['Active', 'Inactive'];
    final savedStatus = d['status']?.toString();
    _status = statuses.contains(savedStatus) ? savedStatus : 'Active';
  }

  @override
  void dispose() {
    _id.dispose();
    _name.dispose();
    _position.dispose();
    _termStart.dispose();
    _termEnd.dispose();
    _contact.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initialDate = now;

    if (controller.text.isNotEmpty) {
      final parsed = DateTime.tryParse(controller.text);
      if (parsed != null) initialDate = parsed;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;

    setState(() => _saving = true);

    final collection = FirebaseFirestore.instance.collection('officials');

    final data = <String, dynamic>{
      'officialId': _id.text.trim(),
      'fullName': _name.text.trim(),
      'position': _position.text.trim(),
      'termStart': _termStart.text.trim(),
      'termEnd': _termEnd.text.trim(),
      'contactNumber': _contact.text.trim(),
      'officeEmail': _email.text.trim(),
      'status': _status ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (_isEditing) {
        await collection.doc(widget.documentId).update(data);
      } else {
        await collection.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Official updated successfully!'
                : 'Official added successfully!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // FORM FIELD — styled to match the Resident Form UI.
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryBlue),
          suffixIcon: readOnly
              ? const Icon(Icons.calendar_month_rounded, color: primaryBlue)
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E7F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryBlue, width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26364A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: _status,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Official Status',
          prefixIcon: const Icon(
            Icons.verified_user_outlined,
            color: primaryBlue,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E7F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryBlue, width: 1.8),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Active', child: Text('Active')),
          DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
        ],
        onChanged: _saving ? null : (value) => setState(() => _status = value),
        validator: (value) =>
            value == null ? 'Official Status is required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: primaryBlue,
        title: Text(
          _isEditing ? 'Edit Official' : 'Add Official',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _key,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // HEADER CARD — matching Resident Form.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryBlue, accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.groups_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isEditing
                                ? 'Update Official Information'
                                : 'Barangay Official Registration',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Please complete all required information',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // WHITE FORM CARD.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            'Personal Information',
                            Icons.person_outline,
                          ),
                          _field(_id, 'Official ID', Icons.badge_outlined),
                          _field(_name, 'Full Name', Icons.person_outline),
                          _field(
                            _position,
                            'Position / Designation',
                            Icons.work_outline_rounded,
                          ),

                          const SizedBox(height: 8),

                          _sectionTitle(
                            'Term Information',
                            Icons.calendar_month_outlined,
                          ),
                          _field(
                            _termStart,
                            'Term Start Date',
                            Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () => _selectDate(_termStart),
                          ),
                          _field(
                            _termEnd,
                            'Term End Date',
                            Icons.event_outlined,
                            readOnly: true,
                            onTap: () => _selectDate(_termEnd),
                          ),
                          _statusDropdown(),

                          const SizedBox(height: 8),

                          _sectionTitle(
                            'Contact Information',
                            Icons.contact_phone_outlined,
                          ),
                          _field(
                            _contact,
                            'Contact Number',
                            Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          _field(
                            _email,
                            'Office Email',
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Office Email is required';
                              }
                              if (!value.trim().contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),
                    const Text(
                      'Barangay Resident Management System',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            // FIXED BOTTOM SAVE BUTTON — matching Resident Form.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(_isEditing ? Icons.update : Icons.save),
                  label: Text(
                    _saving
                        ? 'PLEASE WAIT...'
                        : _isEditing
                        ? 'UPDATE OFFICIAL'
                        : 'SAVE OFFICIAL',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
