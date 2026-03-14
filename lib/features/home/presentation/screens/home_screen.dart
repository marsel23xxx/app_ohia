import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum Mobilitas { bergerak, diam, deliveri, semua }

enum TipePencarian { publik, pribadi }

enum MenuKategori {
  pedagangKeliling,
  pedagangTetap,
  cariLokasi,
  antarJemput,
  jasaPanggilan
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'John';
  String _saldo = 'Rp 150.000';
  String _activeRole = 'pencari';

  double _jarak = 1.5;
  Mobilitas _mobilitas = Mobilitas.semua;
  TipePencarian _tipe = TipePencarian.publik;

  MenuKategori? _selectedMenu;
  final _searchController = TextEditingController();
  String? _selectedKategori;
  String? _selectedSubKategori;

  // Search results
  List<Map<String, dynamic>> _searchResults = [];
  bool _hasSearched = false;

  // Dummy data pedagang (nanti ganti dengan API call)
  final List<Map<String, dynamic>> _dummyPembagis = [
    {
      'id': 1,
      'branding_name': 'Baso Pak Warso',
      'produk': 'Mie Ayam, Baso, Kwetiauw',
      'detail': 'Mie Ayam, Baso, Kwetiauw',
      'status_dagangan': 'ada',
      'jarak_km': 0.3,
      'lokasi': {'latitude': -6.6010, 'longitude': 106.8020},
      'mobilitas': 'mobile',
      'allow_chat': true,
      'allow_call': true,
      'no_hp': '081234567001',
      'katalog_harga': [
        {'nama': 'Mie Ayam', 'harga': '15000'},
        {'nama': 'Baso Urat', 'harga': '18000'},
        {'nama': 'Kwetiauw', 'harga': '17000'},
      ],
      'availability': {
        'hari_dari': 'Senin',
        'hari_sampai': 'Sabtu',
        'jam_dari': '08:00',
        'jam_sampai': '17:00',
      },
    },
    {
      'id': 2,
      'branding_name': 'Es Doger Bu Siti',
      'produk': 'Es Doger, Es Duren, Es Campur',
      'detail': 'Es Doger, Es Duren, Es Campur',
      'status_dagangan': 'ada',
      'jarak_km': 2.1,
      'lokasi': {'latitude': -6.5930, 'longitude': 106.8100},
      'mobilitas': 'mobile',
      'allow_chat': true,
      'allow_call': false,
      'no_hp': '081234567002',
      'katalog_harga': [
        {'nama': 'Es Doger', 'harga': '8000'},
        {'nama': 'Es Duren', 'harga': '15000'},
      ],
    },
    {
      'id': 3,
      'branding_name': 'Nasi Goreng Bang Ahmad',
      'produk': 'Nasi Goreng, Mie Goreng',
      'detail': 'Nasi Goreng Spesial, Mie Goreng, Kwetiauw Goreng',
      'status_dagangan': 'ada',
      'jarak_km': 2.3,
      'lokasi': {'latitude': -6.5850, 'longitude': 106.7980},
      'mobilitas': 'mobile',
      'allow_chat': true,
      'allow_call': true,
      'no_hp': '081234567003',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _switchRole() {
    setState(() {
      _activeRole = _activeRole == 'pencari' ? 'pembagi' : 'pencari';
    });
  }

  void _doSearch() {
    // TODO: Ganti dengan API call ke POST /api/search
    setState(() {
      _hasSearched = true;
      _searchResults = List.from(_dummyPembagis);
    });
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
              _buildTopBar(),
              _buildParameterPencarian(),
              _buildSearchBar(),
              const SizedBox(height: AppSpacing.sm),
              _buildMenuGrid(),
              if (_selectedMenu != null) _buildKategoriPanel(),
              _buildResultsArea(),
              const SizedBox(height: AppSpacing.xl),
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
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.accent,
              child: Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi $_userName',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error, fontWeight: FontWeight.w700)),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: (_activeRole == 'pencari'
                            ? AppColors.info
                            : AppColors.success)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _activeRole == 'pencari' ? '🔍 Pencari' : '📍 Pembagi',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _activeRole == 'pencari'
                            ? AppColors.info
                            : AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Saldo:',
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
              Text(_saldo,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.lightbulb, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 2. PARAMETER PENCARIAN (compact)
  // ═══════════════════════════════════════════════
  Widget _buildParameterPencarian() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Text('Parameter pencarian',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 13))),
          const SizedBox(height: 10),

          // ── Jarak ──
          Row(
            children: [
              const Text('Jarak',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.info,
                    inactiveTrackColor: AppColors.info.withOpacity(0.2),
                    thumbColor: AppColors.info,
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text('${_jarak.toStringAsFixed(1)} KM',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Mobilitas ──
          const Text('Mobilitas',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              _filterChip('Bergerak', Mobilitas.bergerak),
              _filterChip('Diam', Mobilitas.diam),
              _filterChip('Deliveri', Mobilitas.deliveri),
              _filterChip('Semua', Mobilitas.semua),
            ],
          ),
          const SizedBox(height: 8),

          // ── Tipe ──
          const Text('Tipe',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              _filterChip('Publik', TipePencarian.publik),
              _filterChip('Pribadi', TipePencarian.pribadi),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip<T>(String label, T value) {
    final bool selected;
    final VoidCallback onTap;

    if (value is Mobilitas) {
      selected = _mobilitas == value;
      onTap = () => setState(() => _mobilitas = value);
    } else if (value is TipePencarian) {
      selected = _tipe == value;
      onTap = () => setState(() => _tipe = value);
    } else {
      selected = false;
      onTap = () {};
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.info : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AppColors.info : AppColors.divider),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 3. SEARCH BAR
  // ═══════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
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
                horizontal: AppSpacing.md, vertical: 12),
            suffixIcon: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.search, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 4. MENU GRID (horizontal scroll, no overflow)
  // ═══════════════════════════════════════════════
  Widget _buildMenuGrid() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
        children: MenuKategori.values.map((menu) {
          final isSelected = _selectedMenu == menu;
          final menuData = _getMenuData(menu);
          return GestureDetector(
            onTap: () => setState(() {
              _selectedMenu = _selectedMenu == menu ? null : menu;
              _selectedKategori = null;
              _selectedSubKategori = null;
            }),
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? (menuData['color'] as Color).withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: menuData['color'] as Color, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: menuData['color'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(menuData['icon'] as IconData,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      (menuData['label'] as String).replaceAll('\n', ' '),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? menuData['color'] as Color
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, dynamic> _getMenuData(MenuKategori menu) {
    switch (menu) {
      case MenuKategori.pedagangKeliling:
        return {
          'icon': Icons.local_shipping_outlined,
          'label': 'Pedagang\nKeliling',
          'color': const Color(0xFFE5A100)
        };
      case MenuKategori.pedagangTetap:
        return {
          'icon': Icons.store_outlined,
          'label': 'Pedagang\nTetap',
          'color': const Color(0xFF4CAF50)
        };
      case MenuKategori.cariLokasi:
        return {
          'icon': Icons.location_on_outlined,
          'label': 'Cari\nLokasi',
          'color': const Color(0xFFF44336)
        };
      case MenuKategori.antarJemput:
        return {
          'icon': Icons.people_outline,
          'label': 'Antar\nJemput',
          'color': const Color(0xFF607D8B)
        };
      case MenuKategori.jasaPanggilan:
        return {
          'icon': Icons.chat_bubble_outline,
          'label': 'Jasa\nPanggilan',
          'color': const Color(0xFF2196F3)
        };
    }
  }

  // ═══════════════════════════════════════════════
  // 5. KATEGORI PANEL
  // ═══════════════════════════════════════════════
  Widget _buildKategoriPanel() {
    final menuData = _getMenuData(_selectedMenu!);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: menuData['color'] as Color,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11), topRight: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(menuData['icon'] as IconData,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text((menuData['label'] as String).replaceAll('\n', ' '),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _dropdownRow(
                'Kategori',
                _selectedKategori,
                [
                  'Makanan & Minuman',
                  'Sayuran & Buah',
                  'Peralatan Rumah',
                  'Jasa',
                  'Lainnya',
                ],
                (v) => setState(() {
                      _selectedKategori = v;
                      _selectedSubKategori = null;
                    })),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: _dropdownRow(
                'Sub Kategori',
                _selectedSubKategori,
                _getSubKategori(),
                (v) => setState(() => _selectedSubKategori = v)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _doSearch,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 20)),
                child: const Text('Cari', style: TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownRow(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 85,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                hint: Text('Pilih $label',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
                items: items
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
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
          'Gorengan'
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

  // ═══════════════════════════════════════════════
  // 6. RESULTS AREA
  // ═══════════════════════════════════════════════
  Widget _buildResultsArea() {
    // Kalau sudah search dan ada hasil
    if (_hasSearched && _searchResults.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasil Pencarian (${_searchResults.length})',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            ..._searchResults.map((item) => _buildResultCard(item)),
          ],
        ),
      );
    }

    // Empty state
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedMenu != null ? Icons.search_off : Icons.explore_outlined,
              size: 44,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _selectedMenu != null
                  ? 'Pilih kategori lalu tekan Cari\nuntuk melihat hasil'
                  : 'Favourit di Areamu..\nPilih menu di atas untuk mulai mencari',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    final isAda = (item['status_dagangan'] ?? 'ada') == 'ada';
    return GestureDetector(
      onTap: () {
        // Navigate ke detail → di sini map akan muncul!
        Navigator.pushNamed(context, '/pembagi/detail', arguments: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8)),
              child:
                  const Icon(Icons.store, color: AppColors.textHint, size: 22),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['branding_name'] ?? '-',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(item['produk'] ?? '-',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(isAda ? 'Ada' : 'Habis',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAda ? AppColors.success : AppColors.error)),
                ],
              ),
            ),
            // Jarak badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10)),
              child: Text('${item['jarak_km']} KM',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DRAWER
  // ═══════════════════════════════════════════════
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // ── Header (fixed) ──
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 32, color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.md),
                  Text(_userName,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                        _activeRole == 'pencari'
                            ? '🔍 Mode Pencari'
                            : '📍 Mode Pembagi',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),

          // ── Menu items (scrollable) ──
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(
                      'Switch ke ${_activeRole == 'pencari' ? 'Pembagi' : 'Pencari'}'),
                  onTap: () {
                    _switchRole();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Saldo & Top Up'),
                  subtitle: Text(_saldo),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Profil Saya'),
                    onTap: () => Navigator.pop(context)),
                ListTile(
                    leading: const Icon(Icons.chat_outlined),
                    title: const Text('Chat'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/chat');
                    }),
                ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text('Setup Profil Pembagi'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/pembagi/setup');
                    }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.warning_amber_outlined,
                      color: AppColors.error),
                  title: const Text('Tombol Darurat'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/emergency');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone_android_outlined),
                  title: const Text('Lacak HP'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/find-device');
                  },
                ),
              ],
            ),
          ),

          // ── Logout (fixed di bawah) ──
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Keluar',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
