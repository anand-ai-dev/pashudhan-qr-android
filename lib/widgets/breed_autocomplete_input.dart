import 'package:flutter/material.dart';

class BreedAutocompleteInput extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? animalCategory; // 'COW', 'BUFFALO', 'DOG', 'CAT'
  final Color darkBrown;
  final Color backgroundColor;
  final double fontSize;

  static const List<String> cowBreeds = [
    'AMRITMAHAL', 'BACHAUR', 'BADRI', 'BARGUR', 'BELAHI', 'BINJHARPURI', 'DAGRI', 'DANGI', 'DEONI',
    'GANGATIRI', 'GAOLAO', 'GHUMUSARI', 'GIR', 'HALLIKAR', 'HARIANA', 'HIMACHALI PAHARI', 'JERSY',
    'KANGAYAM', 'KANKREJ', 'KENKATHA', 'KHARIAR', 'KHERIGARH', 'KHILLAR', 'KONKAN KAPILA', 'KOSALI',
    'KRISHNA VALLEY', 'LADAKHI', 'LAKHIMI', 'MALNAD GIDDA', 'MALVI', 'MEWATI', 'MOTU', 'NAGORI',
    'NARI', 'NIMARI', 'ONGOLE', 'PODA THURPU', 'PONWAR', 'PULIKULAM', 'PUNGANUR', 'PURNEA', 'RATHI',
    'RED KANDHARI', 'RED SINDHI', 'SAHIWAL', 'SHWETA KAPILA', 'SIRI', 'THARPARKAR', 'THUTHO',
    'UMBLACHERY', 'VECHUR'
  ];

  static const List<String> buffaloBreeds = [
    'BANNI', 'BARGUR', 'BHADAWARI', 'CHHATTISGARHI', 'CHILIKA', 'DHARWADI', 'GOJRI', 'JAFFARABADI',
    'KALAHANDI', 'LUIT', 'MANDA', 'MARATHWADI', 'MEHSANA', 'MURRAH', 'NAGPURI', 'NILI', 'PANDHARPURI',
    'PURNATHADI', 'SURTI', 'TODA'
  ];

  static const List<String> dogBreeds = [
    'BEAGLE', 'BULLDOG', 'DALMATIAN', 'DOBERMAN', 'GERMAN_SHEPHERD', 'GOLDEN_RETRIEVER',
    'INDIAN_PARIAH', 'LABRADOR', 'PUG', 'ROTTWEILER'
  ];

  static const List<String> catBreeds = [
    'BENGAL', 'BRITISH_SHORTHAIR', 'INDIAN_BILLI', 'MAINE_COON', 'PERSIAN', 'RAGDOLL',
    'SCOTTISH_FOLD', 'SIAMESE', 'SPHYNX'
  ];

  const BreedAutocompleteInput({
    super.key,
    required this.hint,
    required this.controller,
    this.animalCategory,
    this.darkBrown = const Color(0xFF452B14),
    this.backgroundColor = const Color(0xFFEDEDED),
    this.fontSize = 18,
  });

  List<String> get _breedList {
    final cat = (animalCategory ?? '').toUpperCase();
    if (cat == 'COW') return cowBreeds;
    if (cat == 'BUFFALO') return buffaloBreeds;
    if (cat == 'DOG') return dogBreeds;
    if (cat == 'CAT') return catBreeds;
    return [...cowBreeds, ...buffaloBreeds, ...dogBreeds, ...catBreeds];
  }

  @override
  Widget build(BuildContext context) {
    final options = _breedList;

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return options;
        }
        final query = textEditingValue.text.toUpperCase();
        return options.where((String option) {
          return option.toUpperCase().contains(query);
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: darkBrown, width: 4),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkBrown,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: darkBrown,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 250,
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: darkBrown, width: 3),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black26),
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: darkBrown,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
