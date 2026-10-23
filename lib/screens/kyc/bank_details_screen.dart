import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:right_touch/providers/auth_provider.dart';
import 'package:right_touch/providers/registration_form_provider.dart';
import 'package:right_touch/screens/kyc/widgets/bank_input_field.dart';
import 'package:right_touch/screens/kyc/widgets/bank_name_dropdown.dart';
import 'package:right_touch/screens/kyc/widgets/kyc_step_indicator.dart';
import 'package:right_touch/services/security_service.dart';
import 'package:right_touch/utils/error_handler.dart';
import 'package:right_touch/utils/validators.dart';
import 'package:right_touch/widgets/rt_loader.dart';
import 'package:right_touch/widgets/success_overlay.dart';
import 'package:right_touch/utils/app_theme.dart';

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
    final securityError = await SecurityService.checkSensitiveActionSecurity();
    if (securityError != null) {
      if (mounted) {
        ErrorHandler.showError(context, securityError);
      }
      return;
    }

    if (!mounted) return;

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
            const KycStepIndicator(activeStep: 2),
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
                              BankInputField(
                                label: "Account Holder Name",
                                controller: _accountHolderController,
                                icon: Icons.person_outline,
                                hint: "Enter full name",
                                inputFormatters: [Validators.nameInputFormatter],
                                validator: (v) => Validators.validateName(
                                  v,
                                  fieldName: 'Account Holder Name',
                                ),
                              ),
                              const SizedBox(height: 20),
                              BankNameDropdown(
                                controller: _bankNameController,
                              ),
                              const SizedBox(height: 20),
                              BankInputField(
                                label: "Account Number",
                                controller: _accountNumberController,
                                icon: Icons.numbers_outlined,
                                hint: "Enter account number",
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  Validators.digitsOnlyFormatter,
                                ],
                                maxLength: 18,
                                validator: Validators.validateBankAccount,
                              ),
                              const SizedBox(height: 20),
                              BankInputField(
                                label: "IFSC Code",
                                controller: _ifscController,
                                icon: Icons.code_outlined,
                                hint: "e.g. SBIN0001234",
                                textCapitalization:
                                    TextCapitalization.characters,
                                maxLength: 11,
                                inputFormatters: [
                                  Validators.ifscInputFormatter,
                                ],
                                validator: Validators.validateIfsc,
                              ),
                              const SizedBox(height: 20),
                              BankInputField(
                                label: "Branch Name",
                                controller: _branchController,
                                icon: Icons.location_on_outlined,
                                hint: "e.g. Chennai Main",
                                validator: (v) =>
                                    Validators.validateRequired(v, 'Branch Name'),
                              ),
                              const SizedBox(height: 20),
                              BankInputField(
                                label: "UPI ID (Optional)",
                                controller: _upiController,
                                icon: Icons.payment_outlined,
                                hint: "e.g. name@upi",
                                required: false,
                                validator: (v) =>
                                    Validators.validateUpiId(v, required: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => _handleSubmit(),
                        child: isLoading
                            ? const RtLoader.button(color: AppTheme.white)
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
}
