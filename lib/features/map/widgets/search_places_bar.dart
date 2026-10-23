import 'dart:async';
import 'package:flutter/material.dart';
import 'package:right_touch/features/map/services/geocoding_service.dart';
import 'package:right_touch/utils/app_theme.dart';

class SearchPlacesBar extends StatefulWidget {
  final ValueChanged<PlaceSearchResult> onPlaceSelected;
  final VoidCallback? onBack;
  final String hintText;

  const SearchPlacesBar({
    super.key,
    required this.onPlaceSelected,
    this.onBack,
    this.hintText = "Search address or coordinates...",
  });

  @override
  State<SearchPlacesBar> createState() => _SearchPlacesBarState();
}

class _SearchPlacesBarState extends State<SearchPlacesBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GeocodingService _geocodingService = GeocodingService();

  Timer? _debounceTimer;
  bool _isLoading = false;
  List<PlaceSearchResult> _results = [];
  List<PlaceSearchResult> _recentSearches = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _focusNode.addListener(() {
      setState(() {
        _showDropdown = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final recents = await _geocodingService.getRecentSearches();
    if (mounted) {
      setState(() => _recentSearches = recents);
    }
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final results = await _geocodingService.searchPlaces(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    });
  }

  void _selectPlace(PlaceSearchResult place) {
    _controller.text = place.title;
    _focusNode.unfocus();
    setState(() => _showDropdown = false);
    _geocodingService.saveRecentSearch(place);
    widget.onPlaceSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _controller.text.trim().isEmpty ? _recentSearches : _results;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.black87),
                  onPressed: widget.onBack,
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.search, color: AppTheme.grey),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppTheme.grey,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20, color: AppTheme.grey),
                  onPressed: () {
                    _controller.clear();
                    _onQueryChanged('');
                  },
                ),
            ],
          ),
        ),

        // Dropdown Search / Recents Card
        if (_showDropdown && displayList.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 50),
              itemBuilder: (context, index) {
                final place = displayList[index];
                final isRecent = _controller.text.trim().isEmpty;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    isRecent ? Icons.history : Icons.location_on_outlined,
                    color: isRecent ? AppTheme.grey : AppTheme.primaryColor,
                    size: 22,
                  ),
                  title: Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    place.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grey,
                    ),
                  ),
                  onTap: () => _selectPlace(place),
                );
              },
            ),
          ),
      ],
    );
  }
}
