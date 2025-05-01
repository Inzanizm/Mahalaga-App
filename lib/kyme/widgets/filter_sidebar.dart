import 'package:flutter/material.dart';

class FilterSidebar extends StatelessWidget {
  final bool isOpenNow;
  final ValueChanged<bool?>? onOpenNowChanged;
  final ValueChanged<String?>? onDistanceChanged;
  final ValueChanged<String?>? onRatingChanged;
  final ValueChanged<List<String>> onCategoryChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;
  final List<String> selectedCategories;
  final VoidCallback onClose;

  const FilterSidebar({
    super.key,
    required this.isOpenNow,
    required this.onOpenNowChanged,
    required this.onDistanceChanged,
    required this.onRatingChanged,
    required this.onCategoryChanged,
    required this.onClear,
    required this.onApply,
    required this.selectedCategories,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Vet Clinics',
      'Adoption Shelters',
      'Pet Supplies',
      'Pet Grooming',
      'Pet Training',
      'Hospital'
    ];

    return Container(
      width: 260,
      color: const Color(0xFFD6D6C2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          const Center(
            child: Text(
              'Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

          // Category Switches
          ...categories.map((category) {
            return SwitchListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(category),
              value: selectedCategories.contains(category),
              onChanged: (value) {
                final updated = List<String>.from(selectedCategories);
                value ? updated.add(category) : updated.remove(category);
                onCategoryChanged(updated);
              },
            );
          }),

          // Open Now Switch
          SwitchListTile(
            title: const Text("Open Now"),
            value: isOpenNow,
            onChanged: onOpenNowChanged,
          ),

          const SizedBox(height: 10),

          // Dropdowns
          _buildDropdown("Distance", [
            "None",
            "Within 1 km",
            "Within 3 km",
            "Within 5 km",
            "Within 10 km",
            "Within 20 km",
          ], onDistanceChanged),
          const SizedBox(height: 10),
          _buildDropdown("Ratings", [
            "All",
            "1",
            "2",
            "3",
            "4",
            "5",
          ], onRatingChanged),

          const Spacer(),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: onClear, child: const Text("Clear")),
              ElevatedButton(onPressed: onApply, child: const Text("Apply")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    ValueChanged<String?>? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            border: OutlineInputBorder(),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}