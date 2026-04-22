import 'package:flutter/material.dart';

class MasterItem {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  final Color color;
  final String description;

  const MasterItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
    this.description = '',
  });

  String get spritePath => 'assets/items/$id.png';
}

const List<MasterItem> pokemonItemRegistry = [
  // Medicine
  MasterItem(id: 'potion', name: 'Potion', category: 'Medicine', icon: Icons.healing, color: Colors.green, description: 'Restores 20 HP.'),
  MasterItem(id: 'super-potion', name: 'Super Potion', category: 'Medicine', icon: Icons.healing, color: Colors.greenAccent, description: 'Restores 60 HP.'),
  MasterItem(id: 'hyper-potion', name: 'Hyper Potion', category: 'Medicine', icon: Icons.healing, color: Colors.teal, description: 'Restores 120 HP.'),
  MasterItem(id: 'max-potion', name: 'Max Potion', category: 'Medicine', icon: Icons.healing, color: Colors.tealAccent, description: 'Fully restores HP.'),
  MasterItem(id: 'full-restore', name: 'Full Restore', category: 'Medicine', icon: Icons.local_hospital, color: Colors.blue, description: 'Fully restores HP and all status conditions.'),
  MasterItem(id: 'revive', name: 'Revive', category: 'Medicine', icon: Icons.favorite, color: Colors.purple, description: 'Revives a fainted Pokémon with half HP.'),
  MasterItem(id: 'max-revive', name: 'Max Revive', category: 'Medicine', icon: Icons.favorite, color: Colors.deepPurple, description: 'Revives a fainted Pokémon with full HP.'),
  MasterItem(id: 'full-heal', name: 'Full Heal', category: 'Medicine', icon: Icons.clean_hands, color: Colors.orange, description: 'Heals all status conditions.'),
  MasterItem(id: 'antidote', name: 'Antidote', category: 'Medicine', icon: Icons.medical_services, color: Colors.greenAccent, description: 'Heals poisoning.'),
  MasterItem(id: 'parlyz-heal', name: 'Parlyz Heal', category: 'Medicine', icon: Icons.electrical_services, color: Colors.yellowAccent, description: 'Heals paralysis.'),
  MasterItem(id: 'awakening', name: 'Awakening', category: 'Medicine', icon: Icons.alarm_on, color: Colors.blueGrey, description: 'Wakes up sleeping Pokémon.'),
  MasterItem(id: 'burn-heal', name: 'Burn Heal', category: 'Medicine', icon: Icons.water_drop, color: Colors.redAccent, description: 'Heals burns.'),
  MasterItem(id: 'ice-heal', name: 'Ice Heal', category: 'Medicine', icon: Icons.ac_unit, color: Colors.cyanAccent, description: 'Heals freezing.'),
  MasterItem(id: 'rare-candy', name: 'Rare Candy', category: 'Medicine', icon: Icons.star, color: Colors.blueAccent, description: 'Raises a Pokémon’s level by one.'),
  MasterItem(id: 'ability-capsule', name: 'Ability Capsule', category: 'Medicine', icon: Icons.swap_horiz, color: Colors.pinkAccent, description: 'Switches a Pokémon between its standard abilities.'),
  MasterItem(id: 'ability-patch', name: 'Ability Patch', category: 'Medicine', icon: Icons.auto_awesome, color: Colors.deepPurpleAccent, description: 'Switches a Pokémon to its Hidden Ability.'),
  MasterItem(id: 'pp-up', name: 'PP Up', category: 'Medicine', icon: Icons.bolt, color: Colors.yellow, description: 'Slightly raises a move’s Max PP.'),
  MasterItem(id: 'pp-max', name: 'PP Max', category: 'Medicine', icon: Icons.bolt, color: Colors.amber, description: 'Fully raises a move’s Max PP.'),

  // Berries
  MasterItem(id: 'cheri-berry', name: 'Cheri Berry', category: 'Berries', icon: Icons.settings_input_composite, color: Colors.red, description: 'Heals paralysis.'),
  MasterItem(id: 'chesto-berry', name: 'Chesto Berry', category: 'Berries', icon: Icons.night_shelter, color: Colors.blue, description: 'Wakes up sleeping Pokémon.'),
  MasterItem(id: 'pecha-berry', name: 'Pecha Berry', category: 'Berries', icon: Icons.face_retouching_natural, color: Colors.pink, description: 'Heals poisoning.'),
  MasterItem(id: 'rawst-berry', name: 'Rawst Berry', category: 'Berries', icon: Icons.local_fire_department, color: Colors.cyan, description: 'Heals burns.'),
  MasterItem(id: 'aspear-berry', name: 'Aspear Berry', category: 'Berries', icon: Icons.ac_unit, color: Colors.indigo, description: 'Heals freezing.'),
  MasterItem(id: 'leppa-berry', name: 'Leppa Berry', category: 'Berries', icon: Icons.bolt, color: Colors.redAccent, description: 'Restores 10 PP to a move.'),
  MasterItem(id: 'oran-berry', name: 'Oran Berry', category: 'Berries', icon: Icons.healing, color: Colors.blueAccent, description: 'Restores 10 HP.'),
  MasterItem(id: 'persim-berry', name: 'Persim Berry', category: 'Berries', icon: Icons.psychology, color: Colors.orange, description: 'Heals confusion.'),
  MasterItem(id: 'lum-berry', name: 'Lum Berry', category: 'Berries', icon: Icons.brightness_high, color: Colors.greenAccent, description: 'Heals all status conditions.'),
  MasterItem(id: 'sitrus-berry', name: 'Sitrus Berry', category: 'Berries', icon: Icons.health_and_safety, color: Colors.amber, description: 'Restores 25% of Max HP.'),

  // Poké Balls
  MasterItem(id: 'poke-ball', name: 'Poké Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.red, description: 'Standard ball for catching Pokémon.'),
  MasterItem(id: 'great-ball', name: 'Great Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.blue, description: 'A high-performance ball with a better catch rate.'),
  MasterItem(id: 'ultra-ball', name: 'Ultra Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.yellow, description: 'An ultra-performance ball with an excellent catch rate.'),
  MasterItem(id: 'master-ball', name: 'Master Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.purple, description: 'The ultimate ball that catches any Pokémon without fail.'),
  MasterItem(id: 'dark-ball', name: 'Dark Ball', category: 'Balls', icon: Icons.brightness_3, color: Colors.black, description: 'Administrative Capture Tool. Instantly captures other players’ Pokémon and terminates the encounter with a victory.'),
  MasterItem(id: 'premier-ball', name: 'Premier Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.white, description: 'A rare commemorative ball.'),
  MasterItem(id: 'luxury-ball', name: 'Luxury Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.black, description: 'Makes a caught Pokémon more friendly.'),
  MasterItem(id: 'beast-ball', name: 'Beast Ball', category: 'Balls', icon: Icons.catching_pokemon, color: Colors.cyan, description: 'Specially designed for Ultra Beasts.'),

  // Held Items
  MasterItem(id: 'focus-sash', name: 'Focus Sash', category: 'Held Items', icon: Icons.shield, color: Colors.redAccent, description: 'Prevents fainting from full HP once.'),
  MasterItem(id: 'life-orb', name: 'Life Orb', category: 'Held Items', icon: Icons.blur_on, color: Colors.pink, description: 'Boosts attack power at the cost of some HP.'),
  MasterItem(id: 'choice-band', name: 'Choice Band', category: 'Held Items', icon: Icons.fitness_center, color: Colors.orangeAccent, description: 'Boosts Attack but locks the user into one move.'),
  MasterItem(id: 'choice-specs', name: 'Choice Specs', category: 'Held Items', icon: Icons.auto_stories, color: Colors.lightBlueAccent, description: 'Boosts Sp. Atk but locks the user into one move.'),
  MasterItem(id: 'choice-scarf', name: 'Choice Scarf', category: 'Held Items', icon: Icons.speed, color: Colors.indigoAccent, description: 'Boosts Speed but locks the user into one move.'),
  MasterItem(id: 'leftovers', name: 'Leftovers', category: 'Held Items', icon: Icons.restaurant, color: Colors.lightGreen, description: 'Restores a small amount of HP each turn.'),
  MasterItem(id: 'rocky-helmet', name: 'Rocky Helmet', category: 'Held Items', icon: Icons.hardware, color: Colors.brown, description: 'Damages attackers who make physical contact.'),
  MasterItem(id: 'assault-vest', name: 'Assault Vest', category: 'Held Items', icon: Icons.security, color: Colors.blueGrey, description: 'Boosts Sp. Def but prevents use of status moves.'),
  MasterItem(id: 'eviolite', name: 'Eviolite', category: 'Held Items', icon: Icons.diamond, color: Colors.cyanAccent, description: 'Boosts defenses of Pokémon that can still evolve.'),

  // Evolution
  MasterItem(id: 'fire-stone', name: 'Fire Stone', category: 'Evolution', icon: Icons.local_fire_department, color: Colors.red, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'water-stone', name: 'Water Stone', category: 'Evolution', icon: Icons.water_drop, color: Colors.blue, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'thunder-stone', name: 'Thunder Stone', category: 'Evolution', icon: Icons.flash_on, color: Colors.yellow, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'leaf-stone', name: 'Leaf Stone', category: 'Evolution', icon: Icons.eco, color: Colors.green, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'moon-stone', name: 'Moon Stone', category: 'Evolution', icon: Icons.brightness_3, color: Colors.indigo, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'sun-stone', name: 'Sun Stone', category: 'Evolution', icon: Icons.wb_sunny, color: Colors.orange, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'shiny-stone', name: 'Shiny Stone', category: 'Evolution', icon: Icons.wb_iridescent, color: Colors.white, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'dusk-stone', name: 'Dusk Stone', category: 'Evolution', icon: Icons.nightlight_round, color: Colors.deepPurple, description: 'Evolves certain species of Pokémon.'),
  MasterItem(id: 'dawn-stone', name: 'Dawn Stone', category: 'Evolution', icon: Icons.wb_twilight, color: Colors.lightBlue, description: 'Evolves certain species of Pokémon.'),
];
