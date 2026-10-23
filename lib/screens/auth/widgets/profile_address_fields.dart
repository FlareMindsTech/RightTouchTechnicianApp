import 'package:flutter/material.dart';
import 'package:right_touch/screens/auth/widgets/profile_setup_text_field.dart';
import 'package:right_touch/utils/validators.dart';

class ProfileAddressFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController localityController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController pincodeController;

  const ProfileAddressFields({
    super.key,
    required this.addressController,
    required this.localityController,
    required this.cityController,
    required this.stateController,
    required this.pincodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileSetupTextField(
          controller: addressController,
          label: "Address",
          hint: "Flat / Street / Area",
          autofillHints: const [AutofillHints.streetAddressLine1],
          validator: (v) =>
              Validators.validateRequired(v, 'Address', minLength: 3),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileSetupTextField(
                controller: localityController,
                label: "Locality",
                hint: "e.g. T Nagar",
                autofillHints: const [AutofillHints.sublocality],
                inputFormatters: [Validators.nameInputFormatter],
                validator: (v) => Validators.validateRequired(v, 'Locality'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileSetupTextField(
                controller: cityController,
                label: "City",
                hint: "e.g. Chennai",
                autofillHints: const [AutofillHints.addressCity],
                inputFormatters: [Validators.nameInputFormatter],
                validator: (v) => Validators.validateName(v, fieldName: 'City'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ProfileSetupTextField(
                controller: stateController,
                label: "State",
                hint: "e.g. TN",
                autofillHints: const [AutofillHints.addressState],
                inputFormatters: [Validators.nameInputFormatter],
                validator: (v) =>
                    Validators.validateName(v, fieldName: 'State'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileSetupTextField(
                controller: pincodeController,
                label: "Pincode",
                hint: "6 digits",
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.postalCode],
                maxLength: 6,
                inputFormatters: [Validators.digitsOnlyFormatter],
                validator: Validators.validatePincode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
