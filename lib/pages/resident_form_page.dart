import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResidentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;

  const ResidentFormPage({super.key, this.documentId, this.initialData});

  @override
  State<ResidentFormPage> createState() => _ResidentFormPageState();
}

class _ResidentFormPageState extends State<ResidentFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _residentIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _purokController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();

  final residents = FirebaseFirestore.instance.collection("residents");

  String gender = "Male";
  bool loading = false;

  static const Color primary = Color(0xFF1565C0);
  static const Color background = Color(0xFFF4F7FC);

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      final data = widget.initialData!;

      _residentIdController.text = data["residentId"] ?? "";
      _fullNameController.text = data["fullName"] ?? "";
      _addressController.text = data["address"] ?? "";
      _purokController.text = data["purok"] ?? "";
      _ageController.text = (data["age"] ?? "").toString();
      _contactController.text = data["contact"] ?? "";
      gender = data["gender"] ?? "Male";
    }
  }

  @override
  void dispose() {
    _residentIdController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _purokController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> saveResident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final residentData = <String, dynamic>{
      "residentId": _residentIdController.text.trim(),
      "fullName": _fullNameController.text.trim(),
      "address": _addressController.text.trim(),
      "purok": _purokController.text.trim(),
      "age": int.parse(_ageController.text.trim()),
      "gender": gender,
      "contact": _contactController.text.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    try {
      if (widget.documentId == null) {
        residentData["createdAt"] = FieldValue.serverTimestamp();
        await residents.add(residentData);
      } else {
        await residents.doc(widget.documentId).update(residentData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.documentId == null
                ? "Resident added successfully!"
                : "Resident updated successfully!",
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator:
            validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return "This field is required";
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primary),
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
            borderSide: const BorderSide(color: primary, width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18, top: 8),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 22),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.documentId != null;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: primary,
        title: Text(
          isEditing ? "Edit Resident" : "Add Resident",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEditing
                        ? "Update Resident Information"
                        : "Resident Registration",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Please complete all required information",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Personal Information", Icons.person_outline),

                    buildField(
                      controller: _residentIdController,
                      label: "Resident ID",
                      icon: Icons.badge_outlined,
                    ),

                    buildField(
                      controller: _fullNameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                    ),

                    buildField(
                      controller: _ageController,
                      label: "Age",
                      icon: Icons.cake_outlined,
                      keyboard: TextInputType.number,
                      validator: (value) {
                        final age = int.tryParse(value ?? "");
                        if (age == null || age < 1 || age > 120) {
                          return "Enter a valid age (1-120)";
                        }
                        return null;
                      },
                    ),

                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: InputDecoration(
                        labelText: "Gender",
                        prefixIcon: const Icon(Icons.wc, color: primary),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFD),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E7F0),
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(
                          value: "Female",
                          child: Text("Female"),
                        ),
                      ],
                      onChanged: loading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => gender = value);
                              }
                            },
                    ),

                    const SizedBox(height: 25),

                    sectionTitle(
                      "Address Information",
                      Icons.location_on_outlined,
                    ),

                    buildField(
                      controller: _addressController,
                      label: "Complete Address",
                      icon: Icons.home_outlined,
                    ),

                    buildField(
                      controller: _purokController,
                      label: "Purok",
                      icon: Icons.location_city_outlined,
                    ),

                    const SizedBox(height: 8),

                    sectionTitle(
                      "Contact Information",
                      Icons.contact_phone_outlined,
                    ),

                    buildField(
                      controller: _contactController,
                      label: "Contact Number",
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : saveResident,
                        icon: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(isEditing ? Icons.update : Icons.save),
                        label: Text(
                          loading
                              ? "PLEASE WAIT..."
                              : isEditing
                              ? "UPDATE RESIDENT"
                              : "SAVE RESIDENT",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Barangay Resident Management System",
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
