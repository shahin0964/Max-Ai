import 'package:flutter/material.dart';
import '../../services/skill_registry_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_panel.dart';

class SkillsStoreScreen extends StatefulWidget {
  const SkillsStoreScreen({super.key});

  @override
  State<SkillsStoreScreen> createState() => _SkillsStoreScreenState();
}

class _SkillsStoreScreenState extends State<SkillsStoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Finance',
    'Marketing',
    'Documents',
    'Coding',
    'System',
    'Research',
    'IoT',
    'Communication',
    'Productivity',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomSkillDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final repoCtrl = TextEditingController();
    String category = 'Coding';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.cyan, width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_moderator, color: AppTheme.cyan, size: 22),
              SizedBox(width: 8),
              Text('Import GitHub Skill', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skill Name', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Crypto Arbitrage Bot',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Description', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Brief capability summary',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('GitHub Repo URL / OpenJarvis Playbook', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                TextField(
                  controller: repoCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    hintText: 'https://github.com/user/skill-repo',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: category,
                  dropdownColor: AppTheme.surfaceElevated,
                  isExpanded: true,
                  items: _categories.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final desc = descCtrl.text.trim();
                final repo = repoCtrl.text.trim();
                if (name.isNotEmpty && desc.isNotEmpty) {
                  await SkillRegistryService.instance.addCustomSkill(
                    name: name,
                    desc: desc,
                    category: category,
                    repoUrl: repo.isNotEmpty ? repo : 'https://github.com/community/custom-skill',
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Custom skill "$name" imported successfully!'), backgroundColor: AppTheme.emerald),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cyan, foregroundColor: Colors.black),
              child: const Text('Install', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKILL STORE & PLAYBOOKS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppTheme.cyan),
            tooltip: 'Import Custom Skill from GitHub',
            onPressed: _showAddCustomSkillDialog,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SkillRegistryService.instance,
          builder: (context, _) {
            final service = SkillRegistryService.instance;
            final searchQ = _searchController.text.trim().toLowerCase();

            final filteredSkills = service.allSkills.where((s) {
              final matchesCat = _selectedCategory == 'All' || s.category.toLowerCase() == _selectedCategory.toLowerCase();
              final matchesSearch = searchQ.isEmpty ||
                  s.name.toLowerCase().contains(searchQ) ||
                  s.desc.toLowerCase().contains(searchQ) ||
                  s.category.toLowerCase().contains(searchQ);
              return matchesCat && matchesSearch;
            }).toList();

            return Column(
              children: [
                // Header Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.amber.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt, color: AppTheme.amber, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('OpenJarvis Skill Marketplace', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 13.5)),
                              const SizedBox(height: 2),
                              Text('${service.installedSkills.length} of ${service.allSkills.length} skills active • Powers autonomous ReAct agent loop', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceGlassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.cyan, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12.5),
                            decoration: const InputDecoration(
                              hintText: 'Search community skills & playbooks...',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.textMuted, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      final isSel = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat, style: TextStyle(fontSize: 10.5, color: isSel ? Colors.black : AppTheme.textPrimary, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                        selected: isSel,
                        selectedColor: AppTheme.cyan,
                        backgroundColor: AppTheme.surfaceElevated,
                        side: BorderSide(color: isSel ? AppTheme.cyan : AppTheme.surfaceGlassBorder),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // Skills List
                Expanded(
                  child: filteredSkills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, size: 36, color: AppTheme.textMuted),
                              const SizedBox(height: 8),
                              Text('No skills found for "$_selectedCategory"', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredSkills.length,
                          itemBuilder: (ctx, i) {
                            final skill = filteredSkills[i];
                            final isInst = skill.installed;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isInst ? AppTheme.cyan.withValues(alpha: 0.3) : AppTheme.surfaceGlassBorder,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (isInst ? AppTheme.cyan : AppTheme.textMuted).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(skill.icon, color: isInst ? AppTheme.cyan : AppTheme.textMuted, size: 20),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        skill.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppTheme.surfaceGlassBorder, width: 0.6),
                                      ),
                                      child: Text(skill.version, style: const TextStyle(fontSize: 8.5, fontFamily: 'monospace', color: AppTheme.textMuted)),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(skill.desc, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('${skill.author} • ${skill.category}', style: const TextStyle(fontSize: 9, color: AppTheme.cyan, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () async {
                                    await service.toggleSkill(skill.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${skill.name} ${!isInst ? "installed" : "uninstalled"} successfully!'),
                                          backgroundColor: !isInst ? AppTheme.emerald : AppTheme.surfaceElevated,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isInst ? AppTheme.surface : AppTheme.cyan,
                                    foregroundColor: isInst ? AppTheme.textMuted : Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    minimumSize: const Size(60, 32),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    isInst ? 'INSTALLED' : 'GET',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
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
