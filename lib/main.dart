import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'models/erp_models.dart';
import 'theme/app_theme.dart';
import 'widgets/revenue_chart.dart';

void main() => runApp(const NexoraApp());

class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NEXORA ERP',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const DashboardShell(),
      );
}

const List<String> pageNames = <String>[
  'Overview',
  'Sales',
  'Purchases',
  'Inventory',
  'Customers',
  'Reports',
  'Settings',
];

const List<IconData> pageIcons = <IconData>[
  Icons.grid_view_rounded,
  Icons.receipt_long_rounded,
  Icons.shopping_bag_outlined,
  Icons.inventory_2_outlined,
  Icons.people_alt_outlined,
  Icons.bar_chart_rounded,
  Icons.settings_outlined,
];

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int selectedIndex = 0;
  String searchQuery = '';
  late final List<TransactionRecord> transactions =
      List<TransactionRecord>.of(sampleTransactions);

  void selectPage(int index) => setState(() => selectedIndex = index);

  Future<void> createInvoice() async {
    final TransactionRecord? record = await showDialog<TransactionRecord>(
      context: context,
      builder: (_) => const CreateInvoiceDialog(),
    );
    if (!mounted || record == null) return;
    setState(() => transactions.insert(0, record));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice added to this demo session.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(pageNames.length, (index) {
            return ListTile(
              leading: Icon(pageIcons[index]),
              title: Text(pageNames[index]),
              selected: selectedIndex == index,
              onTap: () {
                Navigator.pop(sheetContext);
                selectPage(index);
              },
            );
          }),
        ),
      ),
    );
  }

  Future<void> showSearch() async {
    final controller = TextEditingController(text: searchQuery);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search workspace'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search transactions or customers',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onSubmitted: (value) {
            setState(() => searchQuery = value);
            Navigator.pop(dialogContext);
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => searchQuery = controller.text);
              Navigator.pop(dialogContext);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Widget selectedPage() {
    switch (selectedIndex) {
      case 1:
        return TransactionModulePage(
          title: 'Sales management',
          subtitle: 'Create invoices and track customer payments.',
          records: transactions.where((item) => item.isIncome).toList(),
          searchQuery: searchQuery,
          actionLabel: 'Create invoice',
          onAction: createInvoice,
          metrics: const <MetricData>[
            MetricData('Sales this month', '₹4,82,650', '+10.4%'),
            MetricData('Invoices', '186', '+6.8%'),
            MetricData('Outstanding', '₹38,400', '12 invoices'),
          ],
        );
      case 2:
        return TransactionModulePage(
          title: 'Purchase management',
          subtitle: 'Monitor supplier orders and business expenses.',
          records: transactions.where((item) => !item.isIncome).toList(),
          searchQuery: searchQuery,
          metrics: const <MetricData>[
            MetricData('Purchases this month', '₹2,14,300', '+4.2%'),
            MetricData('Purchase orders', '64', '+3.1%'),
            MetricData('Pending bills', '₹28,600', '5 bills'),
          ],
        );
      case 3:
        return const InventoryPage();
      case 4:
        return const CustomersPage();
      case 5:
        return const ReportsPage();
      case 6:
        return const SettingsPage();
      default:
        return DashboardPage(
          transactions: transactions,
          searchQuery: searchQuery,
          onCreate: createInvoice,
          onOpenInventory: () => selectPage(3),
        );
    }
  }

  int get mobileIndex {
    if (selectedIndex == 0) return 0;
    if (selectedIndex == 1) return 1;
    if (selectedIndex == 3) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1050;
        return Scaffold(
          backgroundColor: AppTheme.canvas,
          body: SafeArea(
            child: Row(
              children: <Widget>[
                if (desktop)
                  Sidebar(
                    selectedIndex: selectedIndex,
                    onSelect: selectPage,
                  ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      TopBar(
                        title: pageNames[selectedIndex],
                        compact: !desktop,
                        onMenu: showMoreMenu,
                        onSearch: showSearch,
                        onSearchChanged: (value) =>
                            setState(() => searchQuery = value),
                      ),
                      Expanded(child: selectedPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  height: 68,
                  selectedIndex: mobileIndex,
                  onDestinationSelected: (index) {
                    if (index == 0) {
                      selectPage(0);
                    } else if (index == 1) {
                      selectPage(1);
                    } else if (index == 2) {
                      selectPage(3);
                    } else {
                      showMoreMenu();
                    }
                  },
                  destinations: const <NavigationDestination>[
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.receipt_long_rounded),
                      label: 'Sales',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.inventory_2_rounded),
                      label: 'Stock',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.more_horiz_rounded),
                      label: 'More',
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 246,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 18, 30),
            child: Row(
              children: <Widget>[
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'NEXORA',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'BUSINESS SUITE',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 8,
                        letterSpacing: 1.7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 16, 12),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...List<Widget>.generate(pageNames.length, (index) {
            final selected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => onSelect(index),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEEF1FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        pageIcons[index],
                        size: 19,
                        color: selected ? AppTheme.primary : AppTheme.muted,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          pageNames[index],
                          style: TextStyle(
                            color: selected ? AppTheme.primary : AppTheme.ink,
                            fontSize: 13,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (index == 3)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Color(0xFFD85B55),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8ECFF)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.primary,
                  size: 21,
                ),
                SizedBox(height: 10),
                Text(
                  'Keep your business in sync',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Your workspace overview is ready whenever you are.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: Text(
              'NEXORA ERP  •  DEMO',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    required this.compact,
    required this.onMenu,
    required this.onSearch,
    required this.onSearchChanged,
  });

  final String title;
  final bool compact;
  final VoidCallback onMenu;
  final VoidCallback onSearch;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 520;
        return Container(
          height: 82,
          padding: EdgeInsets.symmetric(horizontal: narrow ? 14 : 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Row(
            children: <Widget>[
              if (compact)
                IconButton(
                  onPressed: onMenu,
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Open navigation',
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!narrow)
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                          'Workspace  /  Manage your business',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!narrow)
                SizedBox(
                  width: compact ? 150 : 245,
                  height: 40,
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Search anything...',
                      prefixIcon: Icon(Icons.search_rounded, size: 18),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Search',
                ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are all caught up.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const SizedBox(width: 7),
              const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFFE8EDFF),
                child: Text(
                  'AA',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.transactions,
    required this.searchQuery,
    required this.onCreate,
    required this.onOpenInventory,
  });

  final List<TransactionRecord> transactions;
  final String searchQuery;
  final VoidCallback onCreate;
  final VoidCallback onOpenInventory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1150 ? 4 : width >= 650 ? 2 : 1;
        return SingleChildScrollView(
          padding: EdgeInsets.all(width < 600 ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Good morning, Ahmad 👋',
                          style: TextStyle(
                            color: AppTheme.ink,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Here is what is happening with your business today.',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (width >= 540)
                    FilledButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create invoice'),
                    ),
                ],
              ),
              if (width < 540) ...<Widget>[
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create invoice'),
                  ),
                ),
              ],
              const SizedBox(height: 23),
              GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 3.4 : 1.85,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  StatCard(
                    title: 'Total revenue',
                    value: '₹8,42,500',
                    change: '+12.8%',
                    caption: 'vs. last month',
                    icon: Icons.account_balance_wallet_outlined,
                    tint: Color(0xFFE9EDFF),
                    iconColor: AppTheme.primary,
                  ),
                  StatCard(
                    title: 'Total orders',
                    value: '1,248',
                    change: '+8.2%',
                    caption: 'vs. last month',
                    icon: Icons.shopping_bag_outlined,
                    tint: Color(0xFFE4F5F0),
                    iconColor: Color(0xFF159B75),
                  ),
                  StatCard(
                    title: 'Total expenses',
                    value: '₹2,14,300',
                    change: '-3.1%',
                    caption: 'vs. last month',
                    icon: Icons.receipt_long_outlined,
                    tint: Color(0xFFFFF2DF),
                    iconColor: Color(0xFFD58A24),
                    positive: false,
                  ),
                  StatCard(
                    title: 'Net profit',
                    value: '₹6,28,200',
                    change: '+14.6%',
                    caption: 'vs. last month',
                    icon: Icons.trending_up_rounded,
                    tint: Color(0xFFF2EAFE),
                    iconColor: Color(0xFF8C63C7),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              if (width >= 950)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: RevenueChart()),
                    SizedBox(width: 16),
                    Expanded(flex: 2, child: QuickActionsPanel()),
                  ],
                )
              else ...<Widget>[
                const RevenueChart(),
                const SizedBox(height: 16),
                QuickActionsPanel(onCreate: onCreate),
              ],
              const SizedBox(height: 19),
              if (width >= 950)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TransactionsPanel(
                        transactions: transactions,
                        searchQuery: searchQuery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: InventoryPanel(onOpenInventory: onOpenInventory),
                    ),
                  ],
                )
              else ...<Widget>[
                TransactionsPanel(
                  transactions: transactions,
                  searchQuery: searchQuery,
                ),
                const SizedBox(height: 16),
                InventoryPanel(onOpenInventory: onOpenInventory),
              ],
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'NEXORA ERP  •  Demo workspace with sample data',
                  style: TextStyle(color: AppTheme.muted, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.caption,
    required this.icon,
    required this.tint,
    required this.iconColor,
    this.positive = true,
  });

  final String title;
  final String value;
  final String change;
  final String caption;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              const Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.muted,
                size: 19,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(color: AppTheme.muted, fontSize: 11),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: <Widget>[
                  Icon(
                    positive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: positive
                        ? const Color(0xFF159B75)
                        : const Color(0xFFD85B55),
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    change,
                    style: TextStyle(
                      color: positive
                          ? const Color(0xFF159B75)
                          : const Color(0xFFD85B55),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      caption,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 10,
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

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction('New invoice', Icons.description_outlined,
          const Color(0xFFE9EDFF), AppTheme.primary, onCreate),
      _QuickAction('Add customer', Icons.person_add_alt_1_rounded,
          const Color(0xFFE4F5F0), const Color(0xFF159B75)),
      _QuickAction('Add product', Icons.add_box_outlined,
          const Color(0xFFFFF2DF), const Color(0xFFD58A24)),
      _QuickAction('Record expense', Icons.payments_outlined,
          const Color(0xFFF2EAFE), const Color(0xFF8C63C7)),
    ];

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PanelTitle(
            title: 'Quick actions',
            subtitle: 'Shortcuts to everyday tasks',
          ),
          const SizedBox(height: 17),
          GridView.builder(
            itemCount: actions.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: action.onTap ??
                    () => showDemoMessage(context, action.label),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBFD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Icon(action.icon, color: action.color, size: 21),
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction(
    this.label,
    this.icon,
    this.tint,
    this.color, [
    this.onTap,
  ]);

  final String label;
  final IconData icon;
  final Color tint;
  final Color color;
  final VoidCallback? onTap;
}

class TransactionsPanel extends StatelessWidget {
  const TransactionsPanel({
    super.key,
    required this.transactions,
    required this.searchQuery,
  });

  final List<TransactionRecord> transactions;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = transactions.where((record) {
      return record.party.toLowerCase().contains(query) ||
          record.id.toLowerCase().contains(query) ||
          record.type.toLowerCase().contains(query);
    }).take(5).toList();

    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PanelTitle(
            title: 'Recent transactions',
            subtitle: 'Your latest business activity',
            trailing: TextButton(
              onPressed: () => showDemoMessage(context, 'All transactions'),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: Text(
                  'No matching transactions found.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ),
            )
          else
            ...filtered.map((record) => TransactionTile(record: record)),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.record});

  final TransactionRecord record;

  @override
  Widget build(BuildContext context) {
    final accent = record.isIncome
        ? const Color(0xFF159B75)
        : const Color(0xFFD58A24);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: record.isIncome
                  ? const Color(0xFFE4F5F0)
                  : const Color(0xFFFFF2DF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              record.isIncome
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  record.party,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.id + '  •  ' + record.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                (record.isIncome ? '+' : '-') + formatCurrency(record.amount),
                style: TextStyle(
                  color: record.isIncome ? accent : AppTheme.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              StatusBadge(status: record.status),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryPanel extends StatelessWidget {
  const InventoryPanel({super.key, required this.onOpenInventory});

  final VoidCallback onOpenInventory;

  @override
  Widget build(BuildContext context) {
    final lowStock =
        sampleProducts.where((product) => product.stock < 10).toList();
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PanelTitle(
            title: 'Inventory alerts',
            subtitle: 'Products that need attention',
            trailing: TextButton(
              onPressed: onOpenInventory,
              child: const Text('Manage'),
            ),
          ),
          const SizedBox(height: 10),
          ...lowStock.map((product) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: product.tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(product.icon, color: AppTheme.ink, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.sku,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE9E8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      product.stock.toString() + ' left',
                      style: const TextStyle(
                        color: Color(0xFFD85B55),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      );
}

class PanelTitle extends StatelessWidget {
  const PanelTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'Paid';
    final isPending = status == 'Pending';
    final color = isPaid
        ? const Color(0xFF159B75)
        : isPending
            ? const Color(0xFFD58A24)
            : const Color(0xFFD85B55);
    final background = isPaid
        ? const Color(0xFFE4F5F0)
        : isPending
            ? const Color(0xFFFFF2DF)
            : const Color(0xFFFFE9E8);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class TransactionModulePage extends StatelessWidget {
  const TransactionModulePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.records,
    required this.searchQuery,
    required this.metrics,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final List<TransactionRecord> records;
  final String searchQuery;
  final List<MetricData> metrics;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.trim().toLowerCase();
    final filtered = records.where((item) {
      return item.party.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);
    }).toList();

    return ModuleScaffold(
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      child: Column(
        children: <Widget>[
          MetricRow(items: metrics),
          const SizedBox(height: 18),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PanelTitle(
                  title: title.contains('Sales') ? 'Sales invoices' : 'Recent purchases',
                  subtitle: 'Recent records and payment status',
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const Text(
                    'No records match your search.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  )
                else
                  ...filtered.map((item) => TransactionTile(record: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) => ModuleScaffold(
        title: 'Inventory',
        subtitle: 'Track stock levels, product value and availability.',
        actionLabel: 'Add product',
        onAction: () => showDemoMessage(context, 'Add product'),
        child: Column(
          children: <Widget>[
            const MetricRow(
              items: <MetricData>[
                MetricData('Total products', '248', '+12 this month'),
                MetricData('Low stock items', '3', 'Needs attention'),
                MetricData('Stock value', '₹12,48,600', 'At cost price'),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 850
                    ? 3
                    : constraints.maxWidth > 540
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sampleProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 3.1 : 1.75,
                  ),
                  itemBuilder: (context, index) =>
                      ProductCard(product: sampleProducts[index]),
                );
              },
            ),
          ],
        ),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductRecord product;

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stock < 10;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: product.tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(product.icon, color: AppTheme.ink, size: 20),
              ),
              const Spacer(),
              if (lowStock)
                const StatusBadge(status: 'Low stock')
              else
                const Icon(Icons.more_horiz_rounded, color: AppTheme.muted),
            ],
          ),
          const Spacer(),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.sku,
            style: const TextStyle(color: AppTheme.muted, fontSize: 9),
          ),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Text(
                formatCurrency(product.price),
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                product.stock.toString() + ' in stock',
                style: TextStyle(
                  color: lowStock ? const Color(0xFFD85B55) : AppTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) => ModuleScaffold(
        title: 'Customers',
        subtitle: 'Build relationships and understand customer activity.',
        actionLabel: 'Add customer',
        onAction: () => showDemoMessage(context, 'Add customer'),
        child: Column(
          children: <Widget>[
            const MetricRow(
              items: <MetricData>[
                MetricData('Total customers', '1,284', '+8.6%'),
                MetricData('New this month', '86', '+12.1%'),
                MetricData('Repeat customers', '72%', 'Healthy'),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 850
                    ? 3
                    : constraints.maxWidth > 540
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sampleCustomers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 3.2 : 1.9,
                  ),
                  itemBuilder: (context, index) =>
                      CustomerCard(customer: sampleCustomers[index]),
                );
              },
            ),
          ],
        ),
      );
}

class CustomerCard extends StatelessWidget {
  const CustomerCard({super.key, required this.customer});

  final CustomerRecord customer;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 21,
                  backgroundColor: customer.tint,
                  child: Text(
                    customer.initials,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        customer.company,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz_rounded, color: AppTheme.muted),
              ],
            ),
            const Spacer(),
            Text(
              customer.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.muted, fontSize: 10),
            ),
            const SizedBox(height: 9),
            Row(
              children: <Widget>[
                Text(
                  customer.orders.toString() + ' orders',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10),
                ),
                const Spacer(),
                Text(
                  formatCurrency(customer.spent),
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) => ModuleScaffold(
        title: 'Reports & analytics',
        subtitle: 'A clear view of revenue, expenses and business performance.',
        child: const Column(
          children: <Widget>[
            MetricRow(
              items: <MetricData>[
                MetricData('Gross revenue', '₹8,42,500', 'This year'),
                MetricData('Total expenses', '₹2,14,300', 'This year'),
                MetricData('Net profit', '₹6,28,200', 'This year'),
              ],
            ),
            SizedBox(height: 18),
            RevenueChart(),
          ],
        ),
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ModuleScaffold(
        title: 'Settings',
        subtitle: 'Manage your workspace preferences.',
        child: Panel(
          child: Column(
            children: <Widget>[
              SettingsTile(
                icon: Icons.business_outlined,
                title: 'Business profile',
                subtitle: 'Business name, address and contact details',
              ),
              const Divider(height: 25),
              SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal preferences',
                subtitle: 'Your profile and display preferences',
              ),
              const Divider(height: 25),
              SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Choose which updates you want to see',
              ),
              const Divider(height: 25),
              SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Theme and interface preferences',
              ),
              const Divider(height: 25),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                subtitle: 'Guides and product support',
              ),
            ],
          ),
        ),
      );
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3FA),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppTheme.ink, size: 19),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            subtitle,
            style: const TextStyle(color: AppTheme.muted, fontSize: 10),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.muted,
        ),
        onTap: () => showDemoMessage(context, title),
      );
}

class ModuleScaffold extends StatelessWidget {
  const ModuleScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return SingleChildScrollView(
            padding: EdgeInsets.all(width < 600 ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (actionLabel != null && width > 480)
                      FilledButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.add_rounded, size: 17),
                        label: Text(actionLabel!),
                      ),
                  ],
                ),
                if (actionLabel != null && width <= 480) ...<Widget>[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: Text(actionLabel!),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                child,
                const SizedBox(height: 22),
                const Center(
                  child: Text(
                    'Demo interface • Data is stored in memory only',
                    style: TextStyle(color: AppTheme.muted, fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        },
      );
}

class MetricData {
  const MetricData(this.label, this.value, this.note);

  final String label;
  final String value;
  final String note;
}

class MetricRow extends StatelessWidget {
  const MetricRow({super.key, required this.items});

  final List<MetricData> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 580 ? 1 : items.length;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 4.2 : 2.25,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.value,
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.note,
                      style: const TextStyle(
                        color: Color(0xFF159B75),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
}

class CreateInvoiceDialog extends StatefulWidget {
  const CreateInvoiceDialog({super.key});

  @override
  State<CreateInvoiceDialog> createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  final formKey = GlobalKey<FormState>();
  final customerController = TextEditingController();
  final amountController = TextEditingController();
  bool paid = true;

  @override
  void dispose() {
    customerController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final record = TransactionRecord(
      id: 'INV-' + DateTime.now().millisecondsSinceEpoch.toString(),
      party: customerController.text.trim(),
      type: 'Sales invoice',
      date: 'Just now',
      status: paid ? 'Paid' : 'Pending',
      amount: double.parse(amountController.text.trim()),
      isIncome: true,
    );
    Navigator.pop(context, record);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text(
          'Create sales invoice',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 390,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: customerController,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Enter a customer name'
                          : null,
                ),
                const SizedBox(height: 13),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Invoice amount',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value ?? '');
                    return amount == null || amount <= 0
                        ? 'Enter a valid amount'
                        : null;
                  },
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Payment received',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: paid,
                  onChanged: (value) => setState(() => paid = value),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Demo only: this invoice is added to the current session.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: save, child: const Text('Save invoice')),
        ],
      );

}

void showDemoMessage(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(feature + ' is available as a frontend demo action.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

String formatCurrency(double value) {
  final raw = value.toStringAsFixed(0);
  final result = StringBuffer('₹');
  for (int index = 0; index < raw.length; index++) {
    result.write(raw[index]);
    final remaining = raw.length - index - 1;
    if (remaining > 0 && remaining % 3 == 0) result.write(',');
  }
  return result.toString();
}
