import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
// ─── Provider ───────────────────────────────────────────────────────────────

final notificationsProvider =
    StateNotifierProvider<
      NotificationsNotifier,
      AsyncValue<List<Map<String, dynamic>>>
    >((ref) => NotificationsNotifier());

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NotificationsNotifier() : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final _api = ApiService();

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      String companyId = '';
      final token = prefs.getString('token') ?? prefs.getString('jwt_token');
      if (token != null && token.isNotEmpty) {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          companyId = payload['companyId']?.toString() ?? '';
        }
      }
      if (companyId.isEmpty) {
        final userStr =
            prefs.getString('user') ?? prefs.getString('user_profile');
        if (userStr != null) {
          final user = jsonDecode(userStr);
          companyId =
              user['companyId']?.toString() ??
              user['company']?['id']?.toString() ??
              user['company']?['_id']?.toString() ??
              '';
        }
      }

      final raw = await _api.getNotifications(companyId: companyId);
      final list = <Map<String, dynamic>>[];
      for (var item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          // The API returns 'type' as 'both' or 'push', but the real type is in 'metadata'
          if (map['metadata'] is Map) {
            final metadata = map['metadata'] as Map;
            if (metadata['type'] != null) {
              map['actualType'] = metadata['type'].toString().toLowerCase();
            }
          }
          list.add(map);
        }
      }

      String _getDateStr(Map<String, dynamic> n) {
        return n['createdAt']?.toString() ??
            n['created_at']?.toString() ??
            n['timestamp']?.toString() ??
            n['date']?.toString() ??
            '';
      }

      // Sort newest first
      list.sort((a, b) {
        final aTime = DateTime.tryParse(_getDateStr(a)) ?? DateTime(2000);
        final bTime = DateTime.tryParse(_getDateStr(b)) ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      state = AsyncValue.data(list);
    } catch (e, st) {
      print('Error loading notifications: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    final previousState = state;
    state.whenData((list) {
      final updated = list.map((n) {
        final nId = n['id']?.toString() ?? n['_id']?.toString();
        if (nId == id) {
          return <String, dynamic>{...n, 'isRead': true, 'read': true};
        }
        return n;
      }).toList();
      state = AsyncValue.data(updated);
    });
    try {
      await _api.markNotificationAsRead(id);
      print('Successfully marked notification as read: $id');
    } catch (e) {
      print('Failed to mark notification as read ($id): $e');
      // Silently ignore API failures so the UI doesn't revert
    }
  }

  Future<void> markAllRead() async {
    final previousState = state;
    state.whenData((list) {
      final updated = list
          .map((n) => <String, dynamic>{...n, 'isRead': true, 'read': true})
          .toList();
      state = AsyncValue.data(updated);
    });
    try {
      await _api.markAllNotificationsRead();
      print('Successfully marked all notifications as read');
    } catch (e) {
      print('Failed to mark all notifications as read: $e');
      // Silently ignore API failures so the UI doesn't revert
    }
  }

  Future<void> deleteNotification(String id) async {
    final previousState = state;
    state.whenData((list) {
      state = AsyncValue.data(
        list.where((n) {
          final nId = n['id']?.toString() ?? n['_id']?.toString();
          return nId != id;
        }).toList(),
      );
    });
    try {
      await _api.deleteNotification(id);
      print('Successfully deleted notification: $id');
    } catch (e) {
      print('Failed to delete notification ($id): $e');
      // Silently ignore API failures so the UI doesn't revert
    }
  }
}

// ─── Unread count provider ────────────────────────────────────────────────────

final unreadCountProvider = Provider<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .whenOrNull(
            data: (list) => list
                .where((n) => n['isRead'] != true && n['read'] != true)
                .length,
          ) ??
      0;
});

// ─── Page ────────────────────────────────────────────────────────────────────

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _filter = ['ALL', 'UNREAD', 'READ'][_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterList(List<Map<String, dynamic>> all) {
    switch (_filter) {
      case 'UNREAD':
        return all
            .where((n) => n['isRead'] != true && n['read'] != true)
            .toList();
      case 'READ':
        return all
            .where((n) => n['isRead'] == true || n['read'] == true)
            .toList();
      default:
        return all;
    }
  }

  String _timeAgo(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  IconData _typeIcon(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('leave')) return Icons.time_to_leave_rounded;
    if (t.contains('attendance')) return Icons.how_to_reg_rounded;
    if (t.contains('payroll') || t.contains('salary'))
      return Icons.payments_rounded;
    if (t.contains('task')) return Icons.task_alt_rounded;
    if (t.contains('project')) return Icons.folder_special_rounded;
    if (t.contains('finance') || t.contains('expense') || t.contains('income'))
      return Icons.account_balance_wallet_rounded;
    if (t.contains('employee')) return Icons.person_add_rounded;
    if (t.contains('wfh')) return Icons.home_work_rounded;
    return Icons.notifications_rounded;
  }

  Color _typeColor(String? type) {
    final t = type?.toLowerCase() ?? '';
    if (t.contains('leave')) return const Color(0xFF2563EB);
    if (t.contains('attendance')) return const Color(0xFF7C3AED);
    if (t.contains('payroll') || t.contains('salary'))
      return const Color(0xFF059669);
    if (t.contains('task')) return const Color(0xFFD97706);
    if (t.contains('project')) return const Color(0xFF0891B2);
    if (t.contains('finance') || t.contains('expense') || t.contains('income'))
      return const Color(0xFF16A34A);
    if (t.contains('employee')) return const Color(0xFFE11D48);
    if (t.contains('wfh')) return const Color(0xFF7C3AED);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(activeRoute: 'Notifications'),
      appBar: _buildAppBar(unreadCount),
      body: notifAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
        error: (err, _) => _buildError(err.toString()),
        data: (allNotifications) {
          final filtered = _filterList(allNotifications);
          return Column(
            children: [
              _buildTabBar(allNotifications, unreadCount),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: const Color(0xFF2563EB),
                        onRefresh: () => ref
                            .read(notificationsProvider.notifier)
                            .loadNotifications(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) =>
                              _buildNotificationCard(filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int unreadCount) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0F172A), size: 24),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 0.2,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Read all', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
          onPressed: () =>
              ref.read(notificationsProvider.notifier).loadNotifications(),
        ),
      ],
    );
  }

  Widget _buildTabBar(List<Map<String, dynamic>> all, int unread) {
    final readCount = all
        .where((n) => n['isRead'] == true || n['read'] == true)
        .length;
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 2.5,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF94A3B8),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: [
          Tab(text: 'All (${all.length})'),
          Tab(text: 'Unread ($unread)'),
          Tab(text: 'Read ($readCount)'),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    final isRead = n['isRead'] == true || n['read'] == true;
    final type = n['actualType']?.toString() ?? n['type']?.toString();
    final id = n['id']?.toString() ?? n['_id']?.toString() ?? '';
    final title = n['title']?.toString() ?? 'Notification';
    final message = n['message']?.toString() ?? n['body']?.toString() ?? '';
    final createdAt =
        n['createdAt']?.toString() ??
        n['created_at']?.toString() ??
        n['timestamp']?.toString() ??
        n['date']?.toString();
    final color = _typeColor(type);

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFDC2626),
        ),
      ),
      onDismissed: (_) =>
          ref.read(notificationsProvider.notifier).deleteNotification(id),
      child: GestureDetector(
        onTap: () {
          if (!isRead && id.isNotEmpty) {
            ref.read(notificationsProvider.notifier).markAsRead(id);
          }
          _showNotificationDetails(context, n);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? const Color(0xFFE2E8F0)
                  : color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isRead ? 0.02 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_typeIcon(type), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (type != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _timeAgo(createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),
                        if (!isRead)
                          GestureDetector(
                            onTap: () => ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(id),
                            child: Text(
                              'Mark read',
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
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
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: Color(0xFF93C5FD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _filter == 'UNREAD'
                ? 'All caught up! No unread notifications.'
                : 'Nothing here yet.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> n) {
    final title = n['title']?.toString() ?? 'Notification';
    final message = n['message']?.toString() ?? n['body']?.toString() ?? '';
    final type = n['type']?.toString();
    final createdAt =
        n['createdAt']?.toString() ??
        n['created_at']?.toString() ??
        n['timestamp']?.toString() ??
        n['date']?.toString();
    final color = _typeColor(type);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_typeIcon(type), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (type != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Message
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Time
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _timeAgo(createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).loadNotifications(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
