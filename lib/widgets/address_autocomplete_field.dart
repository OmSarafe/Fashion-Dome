import 'package:flutter/material.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';

class AddressAutocompleteSelection {
  const AddressAutocompleteSelection({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class AddressAutocompleteField extends StatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.controller,
    required this.onSelection,
    this.onManualChanged,
    this.enabled = true,
    this.validator,
    this.helperText,
  });

  final TextEditingController controller;
  final ValueChanged<AddressAutocompleteSelection> onSelection;
  final VoidCallback? onManualChanged;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final String? helperText;

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late final GooglePlacesAutocomplete _places;
  List<Prediction> _predictions = const [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  String? _pendingQuery;

  @override
  void initState() {
    super.initState();
    _places = GooglePlacesAutocomplete(
      predictionsListener: _handlePredictions,
      loadingListener: _handleLoading,
      onError: _handleError,
      debounceTime: 450,
      countries: const ['gb'],
    );
    _initializePlaces();
  }

  Future<void> _initializePlaces() async {
    try {
      await _places.initialize();
      if (!mounted) return;
      _isInitialized = true;
      final pendingQuery = _pendingQuery;
      if (pendingQuery != null && pendingQuery.length >= 3) {
        _places.getPredictions(pendingQuery);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Suggestions unavailable: $error';
      });
    }
  }

  void _handlePredictions(List<Prediction> predictions) {
    if (!mounted) return;
    setState(() {
      _predictions = predictions.take(5).toList(growable: false);
      _isLoading = false;
      _error = null;
    });
  }

  void _handleLoading(bool isLoading) {
    if (!mounted) return;
    setState(() => _isLoading = isLoading);
  }

  void _handleError(PlacesException error) {
    if (!mounted) return;
    setState(() {
      _predictions = const [];
      _isLoading = false;
      _error = 'Suggestions unavailable: $error';
    });
  }

  void _onChanged(String value) {
    widget.onManualChanged?.call();
    final query = value.trim();
    _pendingQuery = query;
    if (query.length < 3) {
      setState(() {
        _predictions = const [];
        _isLoading = false;
        _error = null;
      });
      return;
    }
    if (_isInitialized) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      _places.getPredictions(query);
    }
  }

  Future<void> _select(Prediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _predictions = const [];
      _error = null;
    });
    try {
      final placeId = prediction.placeId;
      if (placeId == null || placeId.isEmpty) {
        throw StateError('No place ID was returned for this address.');
      }
      final details = await _places.getPlaceDetails(placeId);
      final location = details?.location;
      if (details == null || location == null) {
        throw StateError('No coordinates were returned for this address.');
      }
      final fallback = [prediction.title, prediction.description]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(', ');
      final address = details.formattedAddress?.trim();
      final selectedAddress = address == null || address.isEmpty
          ? fallback
          : fallback.length > address.length
              ? fallback
              : address;
      widget.controller.text = selectedAddress;
      widget.controller.selection = TextSelection.collapsed(
        offset: selectedAddress.length,
      );
      widget.onSelection(
        AddressAutocompleteSelection(
          address: selectedAddress,
          latitude: location.lat,
          longitude: location.lng,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to select that address. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          minLines: 2,
          maxLines: 3,
          keyboardType: TextInputType.streetAddress,
          textCapitalization: TextCapitalization.words,
          onChanged: _onChanged,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: 'Full delivery address',
            hintText: 'Start typing your address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: const OutlineInputBorder(),
            helperText: widget.helperText,
          ),
        ),
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < _predictions.length; index++) ...[
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(
                      [
                        _predictions[index].title,
                        _predictions[index].description,
                      ]
                          .whereType<String>()
                          .where((part) => part.trim().isNotEmpty)
                          .join(', '),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _select(_predictions[index]),
                  ),
                  if (index != _predictions.length - 1)
                    const Divider(height: 1),
                ],
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Powered by Google',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _places.dispose();
    super.dispose();
  }
}
