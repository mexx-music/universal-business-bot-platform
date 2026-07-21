import 'package:flutter_test/flutter_test.dart';
import 'package:universalbusiness/data/app_state.dart';
import 'package:universalbusiness/models/intake_mapping_preview.dart';
import 'package:universalbusiness/models/intake_session.dart';

void main() {
  test('mapping import works only on the selected workspace', () {
    final state = AppState();
    final otherBefore = state.companies
        .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
        .company
        .name;

    state.updateIntakeProducts(
      const IntakeProducts(
        importantProducts: 'Unique Intake Product',
        mainProduct: 'Unique Intake Product',
      ),
    );

    final preview = state.generateIntakeMappingPreview();
    state.importSelectedIntakeMapping(preview);

    expect(
      state.products.any((product) => product.name == 'Unique Intake Product'),
      isTrue,
    );
    expect(
      state.companies
          .firstWhere((workspace) => workspace.company.id == 'schnurr-purr')
          .company
          .name,
      otherBefore,
    );
  });

  test('conflicting company fields are not selected by default', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(companyName: 'Changed Company Name'),
    );

    final preview = state.generateIntakeMappingPreview();
    final nameSuggestion = preview.suggestions.firstWhere(
      (suggestion) =>
          suggestion.action == IntakeMappingAction.updateCompanyField &&
          suggestion.fieldKey == 'name',
    );

    expect(nameSuggestion.conflict, isTrue);
    expect(nameSuggestion.selected, isFalse);

    state.importSelectedIntakeMapping(preview);
    expect(state.company.name, 'Healing und Balance GmbH');
  });

  test('selected conflicts overwrite explicitly', () {
    final state = AppState();
    state.updateIntakeBasics(
      const IntakeBasics(companyName: 'Changed Company Name'),
    );

    var preview = state.generateIntakeMappingPreview();
    final nameSuggestion = preview.suggestions.firstWhere(
      (suggestion) =>
          suggestion.action == IntakeMappingAction.updateCompanyField &&
          suggestion.fieldKey == 'name',
    );
    preview = preview.copyWithSuggestionSelected(nameSuggestion.id, true);

    state.importSelectedIntakeMapping(preview);
    expect(state.company.name, 'Changed Company Name');
  });

  test('list imports do not create duplicates', () {
    final state = AppState();
    state.updateIntakeProducts(
      const IntakeProducts(
        importantProducts:
            'Frequency technology with app support\nUnique Intake Product',
        mainProduct: 'Unique Intake Product',
      ),
    );

    final preview = state.generateIntakeMappingPreview();
    state.importSelectedIntakeMapping(preview);
    state.importSelectedIntakeMapping(preview);

    final matches = state.products
        .where((product) => product.name == 'Unique Intake Product')
        .length;
    expect(matches, 1);
    expect(
      state.products.where((product) => product.name == 'HB Cure App').length,
      0,
    );
    expect(
      state.products
          .where(
            (product) =>
                product.name == 'Frequency technology with app support',
          )
          .length,
      1,
    );
  });

  test('unselected suggestions remain unchanged', () {
    final state = AppState();
    state.updateIntakeProducts(
      const IntakeProducts(importantProducts: 'Unselected Product'),
    );

    var preview = state.generateIntakeMappingPreview();
    final productSuggestion = preview.suggestions.firstWhere(
      (suggestion) =>
          suggestion.action == IntakeMappingAction.addProduct &&
          suggestion.label == 'Unselected Product',
    );
    preview = preview.copyWithSuggestionSelected(productSuggestion.id, false);

    state.importSelectedIntakeMapping(preview);
    expect(
      state.products.any((product) => product.name == 'Unselected Product'),
      isFalse,
    );
  });
}
