import 'package:flutter/material.dart';

import '../models/erp_models.dart';

const List<double> monthlyRevenue = <double>[
  28, 36, 31, 48, 43, 56, 49, 68, 60, 77, 70, 92,
];

const List<String> monthLabels = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<TransactionRecord> sampleTransactions = <TransactionRecord>[
  TransactionRecord(
    id: 'INV-2026-1048',
    party: 'Aarav Traders',
    type: 'Sales invoice',
    date: 'Today, 10:42 AM',
    status: 'Paid',
    amount: 24500,
    isIncome: true,
  ),
  TransactionRecord(
    id: 'PUR-2026-0832',
    party: 'Metro Supplies',
    type: 'Purchase order',
    date: 'Today, 09:18 AM',
    status: 'Pending',
    amount: 12800,
    isIncome: false,
  ),
  TransactionRecord(
    id: 'INV-2026-1047',
    party: 'Kavya Enterprises',
    type: 'Sales invoice',
    date: 'Yesterday, 04:36 PM',
    status: 'Paid',
    amount: 38750,
    isIncome: true,
  ),
  TransactionRecord(
    id: 'INV-2026-1046',
    party: 'Bright Solutions',
    type: 'Sales invoice',
    date: 'Yesterday, 01:12 PM',
    status: 'Overdue',
    amount: 9600,
    isIncome: true,
  ),
  TransactionRecord(
    id: 'PUR-2026-0831',
    party: 'Apex Wholesale',
    type: 'Purchase order',
    date: '12 Nov 2026, 11:20 AM',
    status: 'Paid',
    amount: 18400,
    isIncome: false,
  ),
];

const List<ProductRecord> sampleProducts = <ProductRecord>[
  ProductRecord(
    name: 'Wireless Headphones',
    sku: 'NXR-AUD-001',
    category: 'Electronics',
    stock: 8,
    price: 2499,
    sold: 184,
    icon: Icons.headphones_rounded,
    tint: Color(0xFFE9EDFF),
  ),
  ProductRecord(
    name: 'Smart Watch Pro',
    sku: 'NXR-WAT-014',
    category: 'Wearables',
    stock: 42,
    price: 5499,
    sold: 156,
    icon: Icons.watch_rounded,
    tint: Color(0xFFE4F5F0),
  ),
  ProductRecord(
    name: 'Desk Lamp',
    sku: 'NXR-HOM-027',
    category: 'Home',
    stock: 5,
    price: 1299,
    sold: 121,
    icon: Icons.lightbulb_outline_rounded,
    tint: Color(0xFFFFF2DF),
  ),
  ProductRecord(
    name: 'Bluetooth Speaker',
    sku: 'NXR-AUD-009',
    category: 'Electronics',
    stock: 67,
    price: 1899,
    sold: 98,
    icon: Icons.speaker_rounded,
    tint: Color(0xFFF2EAFE),
  ),
  ProductRecord(
    name: 'Travel Backpack',
    sku: 'NXR-BAG-006',
    category: 'Accessories',
    stock: 3,
    price: 2199,
    sold: 87,
    icon: Icons.backpack_rounded,
    tint: Color(0xFFFFE9E8),
  ),
];

const List<CustomerRecord> sampleCustomers = <CustomerRecord>[
  CustomerRecord(
    name: 'Aarav Mehta',
    email: 'aarav@example.com',
    company: 'Aarav Traders',
    orders: 24,
    spent: 184500,
    initials: 'AM',
    tint: Color(0xFFE9EDFF),
  ),
  CustomerRecord(
    name: 'Kavya Iyer',
    email: 'kavya@example.com',
    company: 'Kavya Enterprises',
    orders: 18,
    spent: 142800,
    initials: 'KI',
    tint: Color(0xFFE4F5F0),
  ),
  CustomerRecord(
    name: 'Rohan Shah',
    email: 'rohan@example.com',
    company: 'Bright Solutions',
    orders: 15,
    spent: 98600,
    initials: 'RS',
    tint: Color(0xFFFFF2DF),
  ),
  CustomerRecord(
    name: 'Diya Nair',
    email: 'diya@example.com',
    company: 'Nair & Co.',
    orders: 12,
    spent: 76400,
    initials: 'DN',
    tint: Color(0xFFF2EAFE),
  ),
  CustomerRecord(
    name: 'Ishaan Kapoor',
    email: 'ishaan@example.com',
    company: 'IK Retail',
    orders: 9,
    spent: 58200,
    initials: 'IK',
    tint: Color(0xFFFFE9E8),
  ),
];
