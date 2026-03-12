import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reference colors
const _blue600 = Color(0xFF2563EB);
const _blue500 = Color(0xFF3B82F6);
const _slate50 = Color(0xFFF8FAFC);
const _slate100 = Color(0xFFF1F5F9);
const _slate200 = Color(0xFFE2E8F0);
const _slate400 = Color(0xFF94A3B8);
const _slate500 = Color(0xFF64748B);
const _slate600 = Color(0xFF475569);
const _slate700 = Color(0xFF334155);
const _slate900 = Color(0xFF0F172A);
const _orange50 = Color(0xFFFFF7ED);
const _orange200 = Color(0xFFFED7AA);
const _orange600 = Color(0xFFEA580C);
const _orange700 = Color(0xFFC2410C);
const _orange900 = Color(0xFF7C2D12);

class _InventoryItem {
  const _InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minStock,
    required this.price,
    this.expiryDate,
  });
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final int minStock;
  final double price;
  final String? expiryDate;
}

/// Inventory screen - exact replica of PatientTrackingVersion4 inventory.tsx
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showAddModal = false;

  static const _mockInventory = [
    _InventoryItem(
      id: '1',
      name: 'Anesthetic (Lidocaine 2%)',
      category: 'anesthetics',
      quantity: 25,
      unit: 'vials',
      minStock: 10,
      price: 15,
    ),
    _InventoryItem(
      id: '2',
      name: 'Dental Gloves (Medium)',
      category: 'ppe',
      quantity: 150,
      unit: 'pairs',
      minStock: 50,
      price: 0.5,
    ),
    _InventoryItem(
      id: '3',
      name: 'Amalgam Filling Material',
      category: 'filling_materials',
      quantity: 8,
      unit: 'packs',
      minStock: 5,
      price: 45,
    ),
    _InventoryItem(
      id: '4',
      name: 'Composite Resin',
      category: 'filling_materials',
      quantity: 3,
      unit: 'syringes',
      minStock: 5,
      price: 85,
      expiryDate: '2027-12-31',
    ),
    _InventoryItem(
      id: '5',
      name: 'Amoxicillin 500mg',
      category: 'antibiotics',
      quantity: 120,
      unit: 'tablets',
      minStock: 50,
      price: 0.75,
      expiryDate: '2026-12-31',
    ),
    _InventoryItem(
      id: '6',
      name: 'Ibuprofen 400mg',
      category: 'pain_relief',
      quantity: 200,
      unit: 'tablets',
      minStock: 100,
      price: 0.25,
      expiryDate: '2027-06-30',
    ),
    _InventoryItem(
      id: '7',
      name: 'Face Masks',
      category: 'ppe',
      quantity: 80,
      unit: 'pieces',
      minStock: 100,
      price: 0.3,
    ),
    _InventoryItem(
      id: '8',
      name: 'Dental Burs (Assorted)',
      category: 'instruments',
      quantity: 45,
      unit: 'pieces',
      minStock: 20,
      price: 12,
    ),
  ];

  List<_InventoryItem> get _filteredInventory {
    return _mockInventory.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<_InventoryItem> get _lowStockItems =>
      _mockInventory.where((i) => i.quantity <= i.minStock).toList();

  List<String> get _categories => [
    'All',
    ..._mockInventory.map((i) => i.category).toSet(),
  ];

  String _formatCategory(String cat) {
    return cat
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: _blue600,
                expandedHeight: 180,
                toolbarHeight: 56,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: _blue600,
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Inventory',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: _blue500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search items...',
                              hintStyle: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: _slate400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Category Filter
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = _categories[i];
                              final isSelected = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : _blue500,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _formatCategory(cat),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? _blue600
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_lowStockItems.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _orange50,
                            border: Border.all(color: _orange200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: _orange600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Low Stock Alert',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _orange900,
                                      ),
                                    ),
                                    Text(
                                      '${_lowStockItems.length} item(s) running low on stock',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: _orange700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ..._filteredInventory.map((item) {
                        final isLowStock = item.quantity <= item.minStock;
                        return _InventoryCard(
                          item: item,
                          isLowStock: isLowStock,
                          onQuantityChanged: () => setState(() {}),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showAddModal)
            _AddItemModal(onClose: () => setState(() => _showAddModal = false)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => setState(() => _showAddModal = true),
          backgroundColor: _blue600,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _InventoryCard extends StatefulWidget {
  const _InventoryCard({
    required this.item,
    required this.isLowStock,
    required this.onQuantityChanged,
  });

  final _InventoryItem item;
  final bool isLowStock;
  final VoidCallback onQuantityChanged;

  @override
  State<_InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<_InventoryCard> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
  }

  String _formatCategory(String cat) {
    return cat
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        final d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return '${d.month}/${d.day}/${d.year}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isLowStock = widget.isLowStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: isLowStock ? _orange200 : _slate200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _slate900,
                          ),
                        ),
                        if (isLowStock) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.trending_down,
                            size: 16,
                            color: _orange600,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatCategory(item.category),
                      style: GoogleFonts.inter(fontSize: 14, color: _slate600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.inventory_2, color: _blue600, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoBlock(
                label: 'Current Stock',
                value: '$_quantity ${item.unit}',
                valueColor: isLowStock ? _orange600 : _slate900,
              ),
              _InfoBlock(
                label: 'Min. Stock',
                value: '${item.minStock} ${item.unit}',
              ),
              _InfoBlock(label: 'Price per unit', value: '₹${item.price}'),
              if (item.expiryDate != null)
                _InfoBlock(
                  label: 'Expiry Date',
                  value: _formatDate(item.expiryDate),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adjust Quantity',
                style: GoogleFonts.inter(fontSize: 14, color: _slate600),
              ),
              Row(
                children: [
                  Material(
                    color: _slate100,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        if (_quantity > 0) {
                          setState(() {
                            _quantity--;
                            widget.onQuantityChanged();
                          });
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.remove, size: 16, color: _slate600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantity',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _slate900,
                      ),
                    ),
                  ),
                  Material(
                    color: _blue600,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _quantity++;
                          widget.onQuantityChanged();
                        });
                      },
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: _slate500)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _slate900,
          ),
        ),
      ],
    );
  }
}

class _AddItemModal extends StatelessWidget {
  const _AddItemModal({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Inventory Item',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _slate900,
                            ),
                          ),
                          IconButton(
                            onPressed: onClose,
                            icon: Icon(Icons.close, color: _slate400),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FormField(
                            label: 'Item Name *',
                            hint: 'Enter item name',
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Category *',
                            hint: 'Select category',
                            isDropdown: true,
                            dropdownOptions: const [
                              'Anesthetics',
                              'PPE',
                              'Filling Materials',
                              'Antibiotics',
                              'Pain Relief',
                              'Instruments',
                            ],
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'Quantity *',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormField(
                                  label: 'Unit *',
                                  hint: 'pieces',
                                  isDropdown: true,
                                  dropdownOptions: const [
                                    'pieces',
                                    'vials',
                                    'pairs',
                                    'packs',
                                    'syringes',
                                    'tablets',
                                  ],
                                  onChanged: (_) {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Minimum Stock Level *',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Price per Unit *',
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            label: 'Expiry Date (Optional)',
                            hint: '',
                            onChanged: (_) {},
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item added successfully!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                onClose();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _blue600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Add Item'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.hint,
    this.onChanged,
    this.keyboardType,
    this.isDropdown = false,
    this.dropdownOptions = const [],
  });

  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool isDropdown;
  final List<String> dropdownOptions;

  @override
  Widget build(BuildContext context) {
    if (isDropdown) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _slate700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: _slate200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dropdownOptions.isNotEmpty
                    ? dropdownOptions.first
                    : null,
                isExpanded: true,
                items: dropdownOptions
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _slate700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
