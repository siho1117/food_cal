// lib/utils/emoji_filters.dart
import 'package:animated_emoji/animated_emoji.dart';

/// Utility class for filtering animated emojis by category
class EmojiFilters {
  EmojiFilters._(); // Private constructor to prevent instantiation

  /// Emojis to exclude from the "Animals and nature" category
  /// These are nature elements, weather, plants, symbols, and unwanted animals
  static const Set<String> excludedFromAnimals = {
    // Plants & Flowers
    'bouquet',
    'rose',
    'wiltedFlower',
    'plant',
    'leaves',
    'luck', // four-leaf clover
    'fallenLeaf',
    'leaflessTree',

    // Weather & Sky
    'snowflake',
    'rainCloud',
    'rainbow',
    'tornado',
    'cloudWithLightning',
    'sunrise',
    'sunriseOverMountains',
    'comet',
    'windFace',

    // Earth & Elements
    'volcano',
    'ocean',
    'bubbles',
    'droplet',
    'globeShowingAmericas',
    'globeShowingAsiaAustralia',
    'globeShowingEuropeAfrica',

    // Symbols (not actual animals)
    'pawPrints',
    'peace',

    // User-requested exclusions (service/working dogs, pests, and specific animals)
    'guideDog',      // Guide dog
    'serviceDog',    // Service dog
    'ant',           // Ant
    'mosquito',      // Mosquito
    'cockroach',     // Cockroach
    'fly',           // Fly
    'worm',          // Worm
    'bat',           // Bat
    'blackBird',     // Black bird
  };

  /// Get all animal emojis from the "Animals and nature" category
  /// Excludes plants, weather, earth elements, and symbols
  ///
  /// Returns approximately 57 actual animal emojis including:
  /// - Mammals (dog, cat, rabbit, etc.)
  /// - Birds (eagle, owl, peacock, etc.)
  /// - Reptiles & Amphibians (snake, turtle, frog, etc.)
  /// - Fish & Sea Creatures (dolphin, whale, shark, etc.)
  /// - Insects (bee, butterfly, ladybug, etc.)
  /// - Fantasy Animals (dragon, unicorn)
  static List<AnimatedEmojiData> getAnimalEmojis() {
    return AnimatedEmojis.values
        .where((emoji) =>
            emoji.categories.contains('Animals and nature') &&
            !excludedFromAnimals.contains(emoji.name))
        .toList();
  }

  /// Get a curated list of popular animal emojis
  /// This is a subset of the most recognizable and commonly used animals
  ///
  /// TODO: Implement this in Phase 2 after user feedback
  static List<AnimatedEmojiData> getPopularAnimalEmojis() {
    // For now, return all animals. Later, we can curate a smaller list.
    return getAnimalEmojis();
  }

  /// Check if an emoji is in the animals category (after filtering)
  static bool isAnimalEmoji(String emojiId) {
    return getAnimalEmojis().any((emoji) => emoji.id == emojiId);
  }
}
