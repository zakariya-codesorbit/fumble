/// Temporary Fumble Playground adventure until CMS / FalAI content is wired.
class PlaygroundAdventure {
  const PlaygroundAdventure({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
}

abstract final class PlaygroundAdventures {
  PlaygroundAdventures._();

  static const List<PlaygroundAdventure> all = [
    PlaygroundAdventure(
      id: 'moon_landing',
      title: 'MOON LANDING',
      description: 'One giant leap for the two of you.',
      imageUrl:
          'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'rollercoaster',
      title: 'ROLLERCOASTER',
      description: 'Hold on tight. This one\'s a scream.',
      imageUrl:
          'https://images.unsplash.com/photo-1563990308267-1c6e4b099487?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'bank_robbery',
      title: 'BANK ROBBERY',
      description: 'Grab the bags. Don\'t look back.',
      imageUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'skydiving',
      title: 'SKYDIVING',
      description: 'Jump together. Land later.',
      imageUrl:
          'https://images.unsplash.com/photo-1521673461164-de300ebcfb17?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'dinosaur_attack',
      title: 'DINOSAUR ATTACK',
      description: 'Run. Don\'t feed the T-Rex.',
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'street_race',
      title: 'STREET RACE',
      description: 'Neon lights. No speed limits.',
      imageUrl:
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'desert_chase',
      title: 'DESERT CHASE',
      description: 'Hot pursuit across the dunes.',
      imageUrl:
          'https://images.unsplash.com/photo-1509316785289-025f5b846b35?auto=format&fit=crop&w=800&q=80',
    ),
    PlaygroundAdventure(
      id: 'big_wave',
      title: 'BIG WAVE',
      description: 'Catch it or wipe out together.',
      imageUrl:
          'https://images.unsplash.com/photo-1502680390469-be75caf25bf9?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  static PlaygroundAdventure? byId(String id) {
    for (final adventure in all) {
      if (adventure.id == id) return adventure;
    }
    return null;
  }
}
