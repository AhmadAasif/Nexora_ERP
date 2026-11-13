import 'package:flutter/material.dart';

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.party,
    required this.type,
    required this.date,
    required this.status,
    required this.amount,
    required this.isIncome,
  });

  final String id;
  final String party;
  final String type;
  final String date;
  final String status;
  final double amount;
  final bool isIncome;
}

class ProductRecord {
  const ProductRecord({
    required this.name,
    required this.sku,
    required this.category,
    required this.stock,
    required this.price,
    required this.sold,
    required this.icon,
    required this.tint,
  });

  final String name;
  final String sku;
  final String category;
  final int stock;
  final double price;
  final int sold;
  final IconData icon;
  final Color tint;
}

class CustomerRecord {
  const CustomerRecord({
    required this.name,
    required this.email,
    required this.company,
    required this.orders,
    required this.spent,
    required this.initials,
    required this.tint,
  });

  final String name;
  final String email;
  final String company;
  final int orders;
  final double spent;
  final String initials;
  final Color tint;
}
