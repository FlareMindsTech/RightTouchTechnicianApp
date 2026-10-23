import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class BankNameDropdown extends StatelessWidget {
  final TextEditingController controller;

  const BankNameDropdown({
    super.key,
    required this.controller,
  });

  static const List<String> bankNames = [
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

  @override
  Widget build(BuildContext context) {
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
          initialValue: controller.value,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return bankNames;
            }
            final query = textEditingValue.text.toLowerCase();
            return bankNames.where(
              (bank) => bank.toLowerCase().contains(query),
            );
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder: (ctx, fieldController, focusNode, onFieldSubmitted) {
            if (fieldController.text.isEmpty && controller.text.isNotEmpty) {
              fieldController.text = controller.text;
            }
            fieldController.addListener(() {
              if (controller.text != fieldController.text) {
                controller.text = fieldController.text;
              }
            });
            return TextFormField(
              controller: fieldController,
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
}
