import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/core/constants/pokemon_constants.dart';
import 'package:pokedex/core/utils/pokemon_validation_utils.dart';
import 'package:pokedex/core/exceptions/invalid_pokemon_id_exception.dart';

void main() {
  group('Pokemon Default Validation Tests', () {
    test('should validate IDs within range (1-1025)', () {
      // IDs válidos
      expect(() => PokemonValidationUtils.validateDefaultPokemon(1), returnsNormally);
      expect(() => PokemonValidationUtils.validateDefaultPokemon(150), returnsNormally);
      expect(() => PokemonValidationUtils.validateDefaultPokemon(1025), returnsNormally);

      // Verificar helper methods
      expect(PokemonConstants.isDefaultPokemon(1), isTrue);
      expect(PokemonConstants.isDefaultPokemon(150), isTrue);
      expect(PokemonConstants.isDefaultPokemon(1025), isTrue);
      expect(PokemonValidationUtils.isValidDefaultPokemon(1), isTrue);
      expect(PokemonValidationUtils.isValidDefaultPokemon(150), isTrue);
      expect(PokemonValidationUtils.isValidDefaultPokemon(1025), isTrue);
    });

    test('should reject IDs outside range', () {
      // ID demasiado alto pero no forma regional
      expect(
        () => PokemonValidationUtils.validateDefaultPokemon(1026),
        throwsA(isA<InvalidPokemonIdException>()),
      );

      expect(PokemonConstants.isDefaultPokemon(1026), isFalse);
      expect(PokemonValidationUtils.isValidDefaultPokemon(1026), isFalse);
    });

    test('should reject regional form IDs', () {
      // IDs de formas regionales
      expect(
        () => PokemonValidationUtils.validateDefaultPokemon(10001),
        throwsA(isA<InvalidPokemonIdException>()),
      );

      expect(
        () => PokemonValidationUtils.validateDefaultPokemon(10150),
        throwsA(isA<InvalidPokemonIdException>()),
      );

      expect(PokemonConstants.isDefaultPokemon(10001), isFalse);
      expect(PokemonValidationUtils.isValidDefaultPokemon(10001), isFalse);
    });

    test('should reject zero and negative IDs', () {
      expect(
        () => PokemonValidationUtils.validateDefaultPokemon(0),
        throwsA(isA<InvalidPokemonIdException>()),
      );

      expect(
        () => PokemonValidationUtils.validateDefaultPokemon(-1),
        throwsA(isA<InvalidPokemonIdException>()),
      );

      expect(PokemonConstants.isDefaultPokemon(0), isFalse);
      expect(PokemonConstants.isDefaultPokemon(-1), isFalse);
    });

    test('should provide correct validation messages', () {
      expect(PokemonValidationUtils.getValidationMessage(1), isNull);
      expect(PokemonValidationUtils.getValidationMessage(1025), isNull);

      expect(PokemonValidationUtils.getValidationMessage(0), isNotNull);
      expect(PokemonValidationUtils.getValidationMessage(1026), isNotNull);
      expect(PokemonValidationUtils.getValidationMessage(10001), isNotNull);

      // Verificar mensaje específico para forma regional
      final regionalMessage = PokemonValidationUtils.getValidationMessage(10001);
      expect(regionalMessage, contains('forma regional'));
    });

    test('should identify exception types correctly', () {
      try {
        PokemonValidationUtils.validateDefaultPokemon(10001);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<InvalidPokemonIdException>());
        final exception = e as InvalidPokemonIdException;
        expect(exception.isRegionalForm, isTrue);
        expect(exception.isTooHigh, isTrue); // 10001 > 1025
      }

      try {
        PokemonValidationUtils.validateDefaultPokemon(1026);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<InvalidPokemonIdException>());
        final exception = e as InvalidPokemonIdException;
        expect(exception.isRegionalForm, isFalse); // 1026 < 10000
        expect(exception.isTooHigh, isTrue); // 1026 > 1025
      }

      try {
        PokemonValidationUtils.validateDefaultPokemon(0);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<InvalidPokemonIdException>());
        final exception = e as InvalidPokemonIdException;
        expect(exception.isRegionalForm, isFalse);
        expect(exception.isTooHigh, isFalse); // 0 < 1025
      }
    });
  });
}
