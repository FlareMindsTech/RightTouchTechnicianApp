import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/widgets/success_overlay.dart';

class BankDetailsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onComplete;
  const BankDetailsScreen({super.key, this.onBack, this.onComplete});

  @override
  ConsumerState<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends ConsumerState<BankDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderState();
      _prefillFields();

      for (final c in [
        _accountHolderController,
        _bankNameController,
        _accountNumberController,
        _ifscController,
        _branchController,
        _upiController,
      ]) {
        c.addListener(_autoSave);
      }
    });
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _loadProviderState() {
    final state = ref.read(registrationFormProvider);
    setState(() {
      if (state.accountHolder.isNotEmpty) {
        _accountHolderController.text = state.accountHolder;
      }
      if (state.bankName.isNotEmpty) _bankNameController.text = state.bankName;
      if (state.accountNumber.isNotEmpty) {
        _accountNumberController.text = state.accountNumber;
      }
      if (state.ifsc.isNotEmpty) _ifscController.text = state.ifsc;
      if (state.branch.isNotEmpty) _branchController.text = state.branch;
      if (state.upi.isNotEmpty) _upiController.text = state.upi;
    });
  }

  void _autoSave() {
    ref.read(registrationFormProvider.notifier).updateBank(
          accountHolder: _accountHolderController.text,
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          ifsc: _ifscController.text,
          branch: _branchController.text,
          upi: _upiController.text,
        );
  }

  void _prefillFields() {
    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (user) {
        // Source 1: Parsed bankDetails map from model
        // Source 2: rawData['bankDetails']
        // Source 3: rawData['technician']['bankDetails']
        final bank = user.bankDetails ??
            user.rawData?['bankDetails'] ??
            user.rawData?['technician']?['bankDetails'];

        if (bank is Map) {
          if (_accountHolderController.text.isEmpty) {
            _accountHolderController.text =
                bank['accountHolderName']?.toString() ??
                    bank['accountHolder']?.toString() ??
                    '';
          }
          if (_bankNameController.text.isEmpty) {
            _bankNameController.text = bank['bankName']?.toString() ?? '';
          }
          if (_accountNumberController.text.isEmpty) {
            _accountNumberController.text = bank['accountNumber']?.toString() ??
                bank['bankAccountNumber']?.toString() ??
                bank['accountNo']?.toString() ??
                '';
          }
          if (_ifscController.text.isEmpty) {
            _ifscController.text = bank['ifscCode']?.toString() ?? '';
          }
          if (_branchController.text.isEmpty) {
            _branchController.text = bank['branchName']?.toString() ?? '';
          }
          if (_upiController.text.isEmpty) {
            _upiController.text = bank['upiId']?.toString() ?? '';
          }
        }

        // Fallback: If bank is null or holder name is empty, use user name
        if (_accountHolderController.text.isEmpty) {
          final fname = user.firstName ?? user.rawData?['fname'] ?? '';
          final lname = user.lastName ?? user.rawData?['lname'] ?? '';
          if (fname.isNotEmpty || lname.isNotEmpty) {
            _accountHolderController.text = "$fname $lname".trim();
          }
        }
      },
      orElse: () {},
    );
  }

  void _listenToAuthState(WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      final wasLoading =
          previous?.maybeWhen(loading: () => true, orElse: () => false) ??
              false;

      next.maybeWhen(
        authenticated: (user) {
          if (wasLoading && user.bankDetails != null) {
            HapticFeedback.heavyImpact();
            // 4️⃣ PROVIDER LIFECYCLE SAFETY: Clear the form state after success!
            ref.read(registrationFormProvider.notifier).clearCache();

            SuccessOverlay.show(
              context,
              message: 'Bank Details Saved!',
              subtitle: 'Taking you to your dashboard...',
              duration: const Duration(milliseconds: 1600),
              onDone: () {
                if (mounted) {
                  if (widget.onComplete != null) {
                    widget.onComplete!();
                  } else {
                    context.pop();
                  }
                }
              },
            );
          }
        },
        error: (message) {
          if (wasLoading) {
            ErrorHandler.showError(
              context,
              message.isNotEmpty
                  ? message
                  : 'Bank details submission failed. Please try again.',
            );
          }
        },
        orElse: () {},
      );
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final bankDetails = {
      "accountHolderName": _accountHolderController.text.trim(),
      "bankName": _bankNameController.text.trim(),
      "accountNumber": _accountNumberController.text.trim(),
      "ifscCode": _ifscController.text.trim().toUpperCase(),
      "branchName": _branchController.text.trim(),
      "upiId": _upiController.text.trim().isEmpty
          ? null
          : _upiController.text.trim(),
    };

    await ref
        .read(authProvider.notifier)
        .submitBankDetails(bankDetails: bankDetails);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _listenToAuthState(ref);
    final authState = ref.watch(authProvider);

    // Guard: Enforce serial requirements (Must have Profile & KYC)
    // 2️⃣ REMOVED ROUTING CONFLICT: No more context.go() guards here
    // Navigation is controlled by RegistrationFlowScreen

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification"),
        leading: IconButton(
          onPressed: () {
            ref.read(authProvider.notifier).refreshKYC();
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bank Account",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please provide your bank details for secure and timely payments.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              _buildInputField(
                                "Account Holder Name",
                                _accountHolderController,
                                Icons.person_outline,
                                "Enter full name",
                              ),
                              const SizedBox(height: 20),
                              _buildBankNameDropdown(),
                              const SizedBox(height: 20),
                              _buildInputField(
                                "Account Number",
                                _accountNumberController,
                                Icons.numbers_outlined,
                                "Enter account number",
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                maxLength: 18,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (v.length < 9 || v.length > 18) {
                                    return 'Account number must be 9-18 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                "IFSC Code",
                                _ifscController,
                                Icons.code_outlined,
                                "e.g. SBIN0001234",
                                textCapitalization:
                                    TextCapitalization.characters,
                                maxLength: 11,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final up = v.toUpperCase();
                                  if (!RegExp(
                                    r'^[A-Z]{4}0[A-Z0-9]{6}$',
                                  ).hasMatch(up)) {
                                    return 'Invalid IFSC (e.g. SBIN0001234)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                "Branch Name",
                                _branchController,
                                Icons.location_on_outlined,
                                "e.g. Chennai Main",
                              ),
                              const SizedBox(height: 20),
                              _buildInputField(
                                "UPI ID (Optional)",
                                _upiController,
                                Icons.payment_outlined,
                                "e.g. name@upi",
                                required: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubmit(),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Complete Registration"),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textTertiary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          _stepItem("Profile", true, true),
          _stepDivider(true),
          _stepItem("KYC", true, true),
          _stepDivider(true),
          _stepItem("Bank", true, false),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.primaryColor
                : isActive
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
            border: Border.all(
              color: isCompleted || isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isActive ? AppTheme.primaryColor : Colors.transparent,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isActive || isCompleted
                ? AppTheme.primaryColor
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider(bool isCompleted) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Divider(
          color: isCompleted
              ? AppTheme.primaryColor
              : AppTheme.textTertiary.withValues(alpha: 0.3),
          thickness: 2,
        ),
      ),
    );
  }

  static const List<String> _bankNames = [
    'Andhra Pradesh Grameena Bank',
    'Axis Bank',
    'Bandhan Bank',
    'Bank of America',
    'Bank of Baroda',
    'Bank of India',
    'Bank of Maharashtra',
    'Barclays Bank',
    'Bihar Gramin Bank',
    'Canara Bank',
    'CSB Bank',
    'Central Bank of India',
    'Citibank',
    'City Union Bank',
    'DBS Bank India',
    'DCB Bank',
    'Deutsche Bank',
    'Dhanlaxmi Bank',
    'Federal Bank',
    'Gujarat Gramin Bank',
    'HDFC Bank',
    'HSBC',
    'ICICI Bank',
    'IDBI Bank',
    'IDFC FIRST Bank',
    'Indian Bank',
    'Indian Overseas Bank',
    'IndusInd Bank',
    'Jammu & Kashmir Bank',
    'Jammu and Kashmir Grameen Bank',
    'JP Morgan Chase',
    'Karnataka Bank',
    'Karnataka Grameena Bank',
    'Karur Vysya Bank',
    'Kerala Grameena Bank',
    'Kotak Mahindra Bank',
    'Maharashtra Gramin Bank',
    'Nainital Bank',
    'Punjab and Sind Bank',
    'Punjab National Bank',
    'Rajasthan Gramin Bank',
    'RBL Bank',
    'SBI',
    'South Indian Bank',
    'Standard Chartered Bank',
    'State Bank of India',
    'Tamilnad Mercantile Bank',
    'UCO Bank',
    'Union Bank of India',
    'Uttar Pradesh Gramin Bank',
    'West Bengal Gramin Bank',
    'YES Bank',
  ];

  Widget _buildBankNameDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bank Name",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          initialValue: _bankNameController.value,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _bankNames;
            }
            final query = textEditingValue.text.toLowerCase();
            return _bankNames.where(
              (bank) => bank.toLowerCase().contains(query),
            );
          },
          onSelected: (String selection) {
            _bankNameController.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            // Sync initial value from _bankNameController
            if (controller.text.isEmpty &&
                _bankNameController.text.isNotEmpty) {
              controller.text = _bankNameController.text;
            }
            // Keep controllers in sync
            controller.addListener(() {
              if (_bankNameController.text != controller.text) {
                _bankNameController.text = controller.text;
              }
            });
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "Search or select bank",
                prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                suffixIcon: Icon(Icons.arrow_drop_down, size: 24),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool required = true,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.words,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            counterText: "",
            prefixIcon: Icon(icon, size: 20),
          ),
          onChanged: (val) {
            if (textCapitalization == TextCapitalization.characters) {
              final upper = val.toUpperCase();
              if (val != upper) {
                controller.value = controller.value.copyWith(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
            }
          },
          validator: validator ??
              (required
                  ? (v) => v == null || v.isEmpty ? 'Required' : null
                  : null),
        ),
      ],
    );
  }
}
