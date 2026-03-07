import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// ── Enum untuk Mobilitas ──
enum Mobilitas { bergerak, diam, deliveri, semua }

/// ── Enum untuk Tipe ──
enum TipePencarian { publik, pribadi }

/// ── Enum untuk menu kategori ──
enum MenuKategori {
  pedagangKeliling,
  pedagangTetap,
  cariLokasi,
  antarJemput,
  jasaPanggilan,
}

/// ── Home Screen ──
/// Sesuai slide 8-9 PPT: Greeting + Saldo, Parameter Pencarian,
/// Search bar, Side menu kategori, Favourit di Areamu / Hasil Pencarian
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── User Data (nanti dari API) ──
  String _userName = 'John';
  String _saldo = 'Rp 150.000';
  String _activeRole = 'pencari'; // pencari / pembagi

  // ── Parameter Pencarian ──
  double _jarak = 1.5; // dalam KM
  Mobilitas _mobilitas = Mobilitas.semua;
  TipePencarian _tipe = TipePencarian.publik;

  // ── Menu ──
  MenuKategori? _selectedMenu;
  final _searchController = TextEditingController();

  // ── Kategori/Sub (untuk expanded panel) ──
  String? _selectedKategori;
  String? _selectedSubKategori;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _switchRole() {
    setState(() {
      _activeRole = _activeRole == 'pencari' ? 'pembagi' : 'pencari';
    });
    // TODO: Call API switchRole
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Bar: Avatar + Greeting + Saldo ──
              _buildTopBar(),

              // ── 2. Parameter Pencarian ──
              _buildParameterPencarian(),

              // ── 3. Search Bar ──
              _buildSearchBar(),

              const SizedBox(height: AppSpacing.md),

              // ── 4. Main Content: Side Menu + Content Area ──
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 1. TOP BAR
  // ═══════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Greeting + Role badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $_userName',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.error,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _activeRole == 'pencari'
                        ? AppColors.info.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _activeRole == 'pencari' ? '🔍 Pencari' : '📍 Pembagi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _activeRole == 'pencari'
                          ? AppColors.info
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Saldo
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Saldo:', style: AppTextStyles.caption),
              Text(
                _saldo,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // Notification / Saldo icon
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 2. PARAMETER PENCARIAN
  // ═══════════════════════════════════════════════
  Widget _buildParameterPencarian() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Parameter pencarian',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Jarak slider
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('Jarak', style: AppTextStyles.body),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.info,
                    inactiveTrackColor: AppColors.info.withOpacity(0.2),
                    thumbColor: AppColors.info,
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    value: _jarak,
                    min: 0.5,
                    max: 50,
                    divisions: 99,
                    onChanged: (v) => setState(() => _jarak = v),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  '${_jarak.toStringAsFixed(1)} KM',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Mobilitas radio
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('Mobilitas', style: AppTextStyles.body),
              ),
              ...[
                ('Bergerak', Mobilitas.bergerak),
                ('Diam', Mobilitas.diam),
                ('Deliveri', Mobilitas.deliveri),
                ('Semua', Mobilitas.semua),
              ].map((item) => Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Radio<Mobilitas>(
                            value: item.$2,
                            groupValue: _mobilitas,
                            onChanged: (v) =>
                                setState(() => _mobilitas = v!),
                            activeColor: AppColors.info,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            item.$1,
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Tipe radio
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('Tipe', style: AppTextStyles.body),
              ),
              ...[
                ('Publik', TipePencarian.publik),
                ('Pribadi', TipePencarian.pribadi),
              ].map((item) => Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Radio<TipePencarian>(
                            value: item.$2,
                            groupValue: _tipe,
                            onChanged: (v) => setState(() => _tipe = v!),
                            activeColor: AppColors.info,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(item.$1, style: AppTextStyles.caption),
                      ],
                    ),
                  )),
              const Spacer(),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 3. SEARCH BAR
  // ═══════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari brand, produk, lokasi...',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search, color: AppColors.primary),
            ),
          ),
          onSubmitted: (query) {
            // TODO: Trigger search
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 4. MAIN CONTENT: Side Menu + Content
  // ═══════════════════════════════════════════════
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          if (_selectedMenu == null)
            Center(
              child: Text(
                'Favourit di Areamu..',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Side menu + content area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Side Menu Icons ──
              Column(
                children: MenuKategori.values.map((menu) {
                  final isSelected = _selectedMenu == menu;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMenu =
                              _selectedMenu == menu ? null : menu;
                          _selectedKategori = null;
                          _selectedSubKategori = null;
                        });
                      },
                      child: _buildMenuIcon(menu, isSelected),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(width: AppSpacing.sm),

              // ── Content Area ──
              Expanded(
                child: Column(
                  children: [
                    // Expanded panel (kategori selector)
                    if (_selectedMenu != null) _buildKategoriPanel(),

                    // Results area
                    _buildResultsArea(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ── Menu Icon Widget ──
  Widget _buildMenuIcon(MenuKategori menu, bool isSelected) {
    final menuData = _getMenuData(menu);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? menuData['color'].withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: menuData['color'], width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: menuData['color'],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: menuData['color'].withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(menuData['icon'], color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            menuData['label'],
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? menuData['color'] : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMenuData(MenuKategori menu) {
    switch (menu) {
      case MenuKategori.pedagangKeliling:
        return {
          'icon': Icons.local_shipping_outlined,
          'label': 'Pedagang\nKeliling',
          'color': const Color(0xFFE5A100), // kuning
        };
      case MenuKategori.pedagangTetap:
        return {
          'icon': Icons.store_outlined,
          'label': 'Pedagang\nTetap',
          'color': const Color(0xFF4CAF50), // hijau
        };
      case MenuKategori.cariLokasi:
        return {
          'icon': Icons.location_on_outlined,
          'label': 'Cari\nLokasi',
          'color': const Color(0xFFF44336), // merah
        };
      case MenuKategori.antarJemput:
        return {
          'icon': Icons.people_outline,
          'label': 'Antar -\nJemput',
          'color': const Color(0xFF607D8B), // abu
        };
      case MenuKategori.jasaPanggilan:
        return {
          'icon': Icons.chat_bubble_outline,
          'label': 'Jasa\nPanggilan',
          'color': const Color(0xFF2196F3), // biru
        };
    }
  }

  // ── Kategori Panel (slide 9-11) ──
  Widget _buildKategoriPanel() {
    final menuData = _getMenuData(_selectedMenu!);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: menuData['color'],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(menuData['icon'], color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  (menuData['label'] as String).replaceAll('\n', ' '),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Kategori dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
            ),
            child: Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right,
                    size: 16, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('Kategori', style: AppTextStyles.bodyMedium),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKategori,
                        isExpanded: true,
                        isDense: true,
                        hint: Text('Pilih Kategori',
                            style: AppTextStyles.caption),
                        items: [
                          'Makanan & Minuman',
                          'Sayuran & Buah',
                          'Peralatan Rumah',
                          'Jasa',
                          'Lainnya',
                        ]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: AppTextStyles.caption),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedKategori = v;
                          _selectedSubKategori = null;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub Kategori dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
            ),
            child: Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right,
                    size: 16, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text('Sub Kategori', style: AppTextStyles.bodyMedium),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubKategori,
                        isExpanded: true,
                        isDense: true,
                        hint: Text('Pilih Sub Kategori',
                            style: AppTextStyles.caption),
                        items: _getSubKategori()
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style: AppTextStyles.caption),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedSubKategori = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cari button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Trigger search with params
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: const Text('Cari'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getSubKategori() {
    if (_selectedKategori == null) return [];
    switch (_selectedKategori) {
      case 'Makanan & Minuman':
        return [
          'Mie Ayam Baso',
          'Es Doger',
          'Es Duren',
          'Nasi Goreng',
          'Kacang Rebus',
          'Gorengan',
        ];
      case 'Sayuran & Buah':
        return ['Sayur Segar', 'Buah Segar', 'Tahu Tempe'];
      case 'Peralatan Rumah':
        return ['Perabot', 'Elektronik', 'Peralatan Dapur'];
      case 'Jasa':
        return ['Service AC', 'Tukang', 'Laundry'];
      default:
        return ['Lainnya'];
    }
  }

  // ── Results Area ──
  Widget _buildResultsArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: _selectedMenu != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil Pencarian',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Placeholder — nanti diisi hasil dari API (Fase 4)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: AppColors.textHint),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Pilih kategori lalu tekan Cari\nuntuk melihat hasil',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Icon(Icons.explore_outlined,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pilih menu di samping untuk\nmulai mencari',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════
  // DRAWER (Profile + Switch Role + Settings)
  // ═══════════════════════════════════════════════
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _activeRole == 'pencari'
                          ? '🔍 Mode Pencari'
                          : '📍 Mode Pembagi',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(
                'Switch ke ${_activeRole == 'pencari' ? 'Pembagi' : 'Pencari'}',
              ),
              onTap: () {
                _switchRole();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Saldo & Top Up'),
              subtitle: Text(_saldo),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to wallet
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil Saya'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Status Verifikasi'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to verification status
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Laporan Penyalahgunaan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to report
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_outlined, color: AppColors.error),
              title: const Text('Tombol Darurat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Emergency feature
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Keluar',
                  style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                // TODO: Call AuthRepository.logout()
                // await ApiClient.clearToken();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
