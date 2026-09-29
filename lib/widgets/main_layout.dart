import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../router.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// One destination in the shell navigation.
class NavTab {
  const NavTab(this.path, this.label, this.icon, {String? sidebarLabel})
    : sidebarLabel = sidebarLabel ?? label;

  final String path;

  /// Short label for the bottom bar, which has little room per tab.
  final String label;
  final String sidebarLabel;
  final IconData icon;
}

List<NavTab> _tabsFor(AppLocalizations l10n, {required bool teacher}) => [
  NavTab(AppRoutes.home, l10n.navHome, LucideIcons.home),
  NavTab(AppRoutes.topics, l10n.navTopics, LucideIcons.bookOpen),
  NavTab(AppRoutes.aiLab, l10n.navAiLab, LucideIcons.bot),
  NavTab(AppRoutes.levelCheck, l10n.navCheckup, LucideIcons.barChart3),
  NavTab(AppRoutes.profile, l10n.navProfile, LucideIcons.userCircle),
  if (teacher)
    NavTab(
      AppRoutes.teacherPanel,
      l10n.navTeacherPanel,
      LucideIcons.layoutDashboard,
      sidebarLabel: l10n.navTeacherPanelFull,
    ),
];

/// Widths from this up get the sidebar instead of the bottom bar.
const _sidebarBreakpoint = 900.0;

/// Persistent shell for the main tabs; [child] is the active tab's screen.
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(supabaseServiceProvider);
    final l10n = context.l10n;
    final tabs = _tabsFor(l10n, teacher: auth.isTeacher);

    final location = GoRouterState.of(context).uri.path;
    final foundIndex = tabs.indexWhere((tab) => location.startsWith(tab.path));
    final currentIndex = foundIndex < 0 ? 0 : foundIndex;

    void onSelected(int index) {
      // Bottom sheets opened from a tab sit on the tab navigator, below
      // the bar, so they would otherwise float over the next tab. Only
      // pageless routes (sheets, dialogs) are popped, never go_router pages.
      shellNavigatorKey.currentState?.popUntil(
        (route) => route.settings is Page,
      );
      if (index != currentIndex) context.go(tabs[index].path);
    }

    if (MediaQuery.sizeOf(context).width >= _sidebarBreakpoint) {
      return Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LearnistSidebar(
              tabs: tabs,
              selectedIndex: currentIndex,
              onDestinationSelected: onSelected,
              userName: auth.currentUserFullName ?? l10n.sidebarDefaultUser,
              roleLabel: auth.isTeacher ? l10n.roleTeacher : l10n.roleStudent,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: LearnistNavBar(
        tabs: tabs,
        selectedIndex: currentIndex,
        onDestinationSelected: onSelected,
      ),
    );
  }
}

/// Dark navy side navigation for tablet and desktop widths.
class LearnistSidebar extends StatelessWidget {
  const LearnistSidebar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.userName,
    required this.roleLabel,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final String userName;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.sidebar,
      child: SafeArea(
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SidebarBrand(),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder:
                      (context, i) => _SidebarItem(
                        tab: tabs[i],
                        selected: i == selectedIndex,
                        onTap: () => onDestinationSelected(i),
                      ),
                ),
              ),
              const Divider(color: Color(0x1FFFFFFF), height: 24),
              _SidebarUser(name: userName, roleLabel: roleLabel),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.sparkles,
            size: 20,
            color: AppColors.teacherAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learnist',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                context.l10n.sidebarTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.sidebarText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(12));
    final color = selected ? Colors.white : AppColors.sidebarText;

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppColors.sidebarItemActive : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color:
                selected
                    ? AppColors.teacherAccent.withValues(alpha: 0.6)
                    : Colors.transparent,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(tab.icon, size: 18, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tab.sidebarLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarUser extends StatelessWidget {
  const _SidebarUser({required this.name, required this.roleLabel});

  final String name;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.teacherAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            initial,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                roleLabel,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.sidebarText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Flat white bar with a hairline top border and a soft indigo pill
/// wrapping the selected tab's icon and label.
class LearnistNavBar extends StatelessWidget {
  const LearnistNavBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: tabs[i],
                    selected: i == selectedIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    const radius = BorderRadius.all(Radius.circular(18));

    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 60,
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : Colors.transparent,
                borderRadius: radius,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tab.icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  // Shrink long labels on narrow phones
                  // instead of truncating them.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tab.label,
                      maxLines: 1,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
