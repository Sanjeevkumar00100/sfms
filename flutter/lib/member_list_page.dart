import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _allMembers = [];

  void _filterMembers() {
    final search = _searchController.text.trim().toLowerCase();

    setState(() {
      if (search.isEmpty) {
        _members = List.from(_allMembers);
      } else {
        _members = _allMembers.where((member) {
          final memberNumber =
              (member['member_number'] ?? '').toString().toLowerCase();
          final name =
              (member['full_name'] ?? '').toString().toLowerCase();
          final mobile =
              (member['mobile'] ?? '').toString().toLowerCase();

          return memberNumber.contains(search) ||
              name.contains(search) ||
              mobile.contains(search);
        }).toList();
      }
    });
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _supabase
          .from('members')
          .select()
          .order('created_at', ascending: false);

      _allMembers = List<Map<String, dynamic>>.from(response);
      _members = List.from(_allMembers);
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'BLOCKED':
      case 'FROZEN':
        return Colors.red;
      case 'KYC_PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(member['full_name'] ?? 'Member Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow(
                  'Member Number',
                  member['member_number'],
                ),
                _detailRow(
                  'Mobile',
                  member['mobile'],
                ),
                _detailRow(
                  'Alternate Mobile',
                  member['alternate_mobile'],
                ),
                _detailRow(
                  'Email',
                  member['email'],
                ),
                _detailRow(
                  'Gender',
                  member['gender'],
                ),
                _detailRow(
                  'Occupation',
                  member['occupation'],
                ),
                _detailRow(
                  'Village',
                  member['village'],
                ),
                _detailRow(
                  'Taluk',
                  member['taluk'],
                ),
                _detailRow(
                  'District',
                  member['district'],
                ),
                _detailRow(
                  'State',
                  member['state'],
                ),
                _detailRow(
                  'PIN Code',
                  member['pincode'],
                ),
                _detailRow(
                  'Address',
                  member['address'],
                ),
                _detailRow(
                  'Member Status',
                  member['member_status'],
                ),
                _detailRow(
                  'KYC Status',
                  member['kyc_status'],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty || text == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadMembers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by member number, name or mobile',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Members: ${_members.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildMemberContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load members',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadMembers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_members.isEmpty) {
      return const Center(
        child: Text(
          'No members found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];

        final name = member['full_name'] ?? 'Unknown';
        final memberNumber = member['member_number'] ?? '';
        final mobile = member['mobile'] ?? '';
        final status = member['member_status'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                name.toString().isNotEmpty
                    ? name.toString()[0].toUpperCase()
                    : '?',
              ),
            ),
            title: Text(
              name.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '$memberNumber  •  $mobile',
              ),
            ),
            trailing: Chip(
              label: Text(
                status.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              backgroundColor: _statusColor(status.toString()),
            ),
            onTap: () => _showMemberDetails(member),
          ),
        );
      },
    );
  }
}
