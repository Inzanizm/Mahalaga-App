import 'package:flutter/material.dart';

class AdoptionFormDialog extends StatefulWidget {
  final String petName;

  // Constructor for AdoptionFormDialog, requires the pet name as a parameter.
  const AdoptionFormDialog({super.key, required this.petName});

  @override
  State<AdoptionFormDialog> createState() => _AdoptionFormDialogState();
}

class _AdoptionFormDialogState extends State<AdoptionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields in the form.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Rounded corners for the dialog.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      // Centered title with the pet name.
      title: Center(
        child: Text(
          'Adopt ${widget.petName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Form(
            key: _formKey, // Assigning the form key.
            child: Column(
              children: [
                // Build the text fields for each required field.
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _addressController,
                  label: 'Home Address',
                  icon: Icons.home,
                ),
                const SizedBox(height: 20),
                // Section for the "Why do you want to adopt?" question.
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Why do you want to adopt?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _messageController,
                  label: 'Optional',
                  icon: Icons.edit_note,
                  maxLines: 4,
                  required: false,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Action buttons for cancelling or submitting the form.
        OverflowBar(
          alignment: MainAxisAlignment.end,
          children: [
            // Cancel button closes the dialog without submission.
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Submit button validates the form, sends the adoption request, and displays a confirmation snackbar.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Close the dialog if the form is valid.
                  Navigator.pop(context);

                  // Show a confirmation snackbar.
                  final snackBar = SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.teal,
                    content: Text(
                      'Your request to adopt ${widget.petName} has been sent!',
                      style: const TextStyle(color: Colors.white),
                    ),
                    duration: const Duration(seconds: 3),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  // Additional backend API call or submission logic can be added here.
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      validator:
          required
              ? (value) => value!.trim().isEmpty ? 'Please enter $label' : null
              : null,
    );
  }
}
