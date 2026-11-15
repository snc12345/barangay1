import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'resident_form_page.dart';

class ResidentsPage extends StatelessWidget {
  const ResidentsPage({super.key});

  static const Color primaryBlue = Color(0xFF123B6D);
  static const Color accentBlue = Color(0xFF2878C8);
  static const Color backgroundColor = Color(0xFFF3F6FB);

  Future<void> _deleteResident(
    BuildContext context,
    CollectionReference<Map<String, dynamic>> collection,
    String documentId,
    String fullName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Resident?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete $fullName? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await collection.doc(documentId).delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resident deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FA),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 55,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Residents Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first registered barangay resident.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accentBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${value.isEmpty ? 'Not specified' : value}',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collection = FirebaseFirestore.instance.collection('residents');

    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barangay Residents',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage registered barangay residents',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),

      // BODY
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: collection.orderBy('fullName').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('RESIDENTS FIRESTORE ERROR: ${snapshot.error}');

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 45,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load resident records.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            final docs = snapshot.data!.docs;

            return Column(
              children: [
                // PAGE HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Residents Management',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'View and manage registered barangay residents.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blueGrey.shade500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // RESIDENT COUNT CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F0FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                color: primaryBlue,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${docs.length}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                                Text(
                                  'Total Barangay Residents',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // RESIDENT LIST
                Expanded(
                  child: docs.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 5, 18, 20),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data();

                            final fullName = '${data['fullName'] ?? ''}';
                            final residentId = '${data['residentId'] ?? ''}';
                            final address = '${data['address'] ?? ''}';
                            final purok = '${data['purok'] ?? ''}';
                            final age = '${data['age'] ?? ''}';
                            final gender = '${data['gender'] ?? ''}';
                            final contact = '${data['contact'] ?? ''}';

                            final initial = fullName.trim().isNotEmpty
                                ? fullName.trim()[0].toUpperCase()
                                : '?';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(17),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // PROFILE AVATAR
                                        Container(
                                          height: 55,
                                          width: 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F0FA),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              initial,
                                              style: const TextStyle(
                                                color: primaryBlue,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // RESIDENT NAME
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName.isEmpty
                                                    ? 'Unnamed Resident'
                                                    : fullName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryBlue,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'Purok: ${purok.isEmpty ? 'Not specified' : purok}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Colors.blueGrey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ACTION MENU
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            color: Colors.blueGrey,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          onSelected: (action) async {
                                            if (action == 'edit') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ResidentFormPage(
                                                        documentId: doc.id,
                                                        initialData: data,
                                                      ),
                                                ),
                                              );
                                            } else if (action == 'delete') {
                                              await _deleteResident(
                                                context,
                                                collection,
                                                doc.id,
                                                fullName,
                                              );
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.edit_outlined,
                                                    size: 19,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    size: 19,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFEDF0F5),
                                    ),
                                    const SizedBox(height: 14),

                                    // RESIDENT DETAILS
                                    _detailRow(
                                      Icons.badge_outlined,
                                      'Resident ID',
                                      residentId,
                                    ),
                                    _detailRow(
                                      Icons.location_on_outlined,
                                      'Purok',
                                      purok,
                                    ),
                                    _detailRow(Icons.cake_outlined, 'Age', age),
                                    _detailRow(
                                      Icons.person_outline,
                                      'Gender',
                                      gender,
                                    ),
                                    _detailRow(
                                      Icons.phone_outlined,
                                      'Contact',
                                      contact,
                                    ),
                                    if (address.isNotEmpty)
                                      _detailRow(
                                        Icons.home_outlined,
                                        'Address',
                                        address,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // FIXED BOTTOM ADD BUTTON
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
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResidentFormPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text(
                        'Add Resident',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
