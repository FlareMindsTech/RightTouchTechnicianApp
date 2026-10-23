import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/screens/kyc/widgets/kyc_document_card.dart';
import 'package:right_touch/utils/validators.dart';

class KycDocumentFields extends StatelessWidget {
  final TextEditingController aadharController;
  final TextEditingController panController;
  final TextEditingController dlController;
  final String? aadharPath;
  final String? aadharBackPath;
  final String? panPath;
  final String? dlPath;
  final VoidCallback onPickAadhar;
  final VoidCallback onPickAadharBack;
  final VoidCallback onPickPan;
  final VoidCallback onPickDl;

  const KycDocumentFields({
    super.key,
    required this.aadharController,
    required this.panController,
    required this.dlController,
    required this.aadharPath,
    required this.aadharBackPath,
    required this.panPath,
    required this.dlPath,
    required this.onPickAadhar,
    required this.onPickAadharBack,
    required this.onPickPan,
    required this.onPickDl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KycDocumentCard(
          title: "Aadhar Card",
          subtitle: "Format: 1234 1234 1234",
          controller: aadharController,
          hint: "1234 5678 9012",
          localImagePath: aadharPath,
          onUpload: onPickAadhar,
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 14,
          inputFormatters: [
            Validators.digitsOnlyFormatter,
            AadharInputFormatter(),
          ],
          validator: Validators.validateAadhaar,
          localImageBackPath: aadharBackPath,
          onUploadBack: onPickAadharBack,
        ),
        const SizedBox(height: 20),
        KycDocumentCard(
          title: "PAN Card",
          subtitle: "Format: ABCDE1234F",
          controller: panController,
          hint: "ABCDE1234F",
          localImagePath: panPath,
          onUpload: onPickPan,
          icon: Icons.credit_card_outlined,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          inputFormatters: [
            Validators.panInputFormatter,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: Validators.validatePan,
        ),
        const SizedBox(height: 20),
        KycDocumentCard(
          title: "Driving License",
          subtitle: "Format: TN20245678901",
          controller: dlController,
          hint: "TN20245678901",
          localImagePath: dlPath,
          onUpload: onPickDl,
          icon: Icons.drive_eta_outlined,
          textCapitalization: TextCapitalization.characters,
          maxLength: 16,
          inputFormatters: [
            Validators.dlInputFormatter,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: Validators.validateDrivingLicense,
        ),
      ],
    );
  }
}
