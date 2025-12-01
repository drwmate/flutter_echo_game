import 'package:flutter/material.dart';

void main() {
  runApp(const EchoGameApp());
}

class EchoGameApp extends StatelessWidget {
  const EchoGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Эхо на перешейке',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueGrey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
      // В будущем здесь можно добавить маршруты (routes) для Меню
      home: const GameScreen(),
    );
  }
}

// Класс для хранения данных одной сцены
class StoryNode {
  final String text;
  final List<Choice> choices;

  StoryNode({required this.text, required this.choices});
}

// Класс для варианта ответа
class Choice {
  final String text;
  final String nextNodeId;

  Choice(this.text, this.nextNodeId);
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Текущий ID сцены. Начинаем со старта.
  String currentNodeId = 'start';

  // --- БАЗА ДАННЫХ СЮЖЕТА ---
  // В будущем вынесем это в отдельный файл
  final Map<String, StoryNode> storyData = {
    'start': StoryNode(
      text: 'Сцена 1: Тишина перед бурей\n\n'
          'Вы на смотровой вышке. Рассвет. В утренней дымке вы замечаете странные блики на горизонте. '
          'Это десантные корабли противника. Их много, и они идут прямо к старому пляжу.',
      choices: [
        Choice('Бежать к командиру с докладом', 'commander_briefing'),
      ],
    ),
    'commander_briefing': StoryNode(
      text: 'Сцена 2: Штаб\n\n'
          'Командир хмурится. Приходит шифровка из Центра: "Срочное отступление. Силы неравны".\n'
          'Однако командир знает, что землетрясение создало новые удобные высоты для обороны, которых нет на картах врага.',
      choices: [
        Choice('Подчиниться приказу и отступать сразу (Безопасно)', 'retreat_early'),
        Choice('Предложить встретить врага огнем с высот (Риск)', 'high_ground_battle'),
      ],
    ),
    'retreat_early': StoryNode(
      text: 'Вы решили не рисковать. Отряд спешно покинул позиции. \n\n'
          'Враг беспрепятственно высадился и занял плацдарм. Территория потеряна без боя.\n\n'
          'КОНЕЦ ИГРЫ (Плохая концовка)',
      choices: [
        Choice('Начать заново', 'start'),
      ],
    ),
    'high_ground_battle': StoryNode(
      text: 'Сцена 3: Огонь с высоты\n\n'
          'Ваши КВ-1 открыли огонь с новых скал. Враг несет потери, но их слишком много. '
          'Корабельная артиллерия начинает бить по вам. \n'
          'Барометр показывает резкое падение давления — надвигается снежная буря.',
      choices: [
        Choice('Стоять насмерть до последнего снаряда', 'heroic_death'),
        Choice('Отступить под прикрытием начинающейся метели', 'retreat_path'),
      ],
    ),
    'heroic_death': StoryNode(
      text: 'Вы решили стоять до конца. Артиллерия врага накрыла высоту. \n\n'
          'Ваш подвиг будет забыт, так как некому о нем доложить.\n\n'
          'КОНЕЦ ИГРЫ',
      choices: [
        Choice('Попробовать другую тактику', 'start'),
      ],
    ),
    'retreat_path': StoryNode(
      text: 'Сцена 4: Ловушка на тропе\n\n'
          'Вы отступаете к резервной точке связи. Разведка докладывает: с юга движется колонна легких танков врага, чтобы перерезать путь. '
          'Они идут по узкой тропе под нестабильной скалой.',
      choices: [
        Choice('Принять бой лоб в лоб', 'head_on_clash'),
        Choice('Подорвать скалу и устроить завал', 'swamp_tactic_setup'),
      ],
    ),
    'head_on_clash': StoryNode(
      text: 'Врагов было слишком много. В узком ущелье ваши танки не смогли маневрировать.\n\n'
          'КОНЕЦ ИГРЫ',
      choices: [
        Choice('Вернуться назад', 'retreat_path'),
      ],
    ),
    'swamp_tactic_setup': StoryNode(
      text: 'Сцена 5: Дорога через болота\n\n'
          'Завал сработал! Враг уничтожен камнепадом. Вы добрались до связи и получили добро на засаду.\n'
          'Теперь главные силы врага (15 тяжелых танков) идут по единственной дороге через болота. Ваши КВ-1 в засаде.',
      choices: [
        Choice('Атаковать середину колонны (Паника)', 'failed_ambush'),
        Choice('Тактика "Пробка": подбить первый и последний танк', 'victory'),
      ],
    ),
    'failed_ambush': StoryNode(
      text: 'Вы ударили по центру. Головные танки успели развернуться и открыть огонь. Засада раскрыта.\n\n'
          'ПОРАЖЕНИЕ',
      choices: [
        Choice('Попробовать снова', 'swamp_tactic_setup'),
      ],
    ),
    'victory': StoryNode(
      text: 'ФИНАЛ: Болото и Сталь\n\n'
          'Головной и замыкающий танки горят. Колонна заперта. Слева и справа топь.\n'
          'Вы методично расстреливаете врага. Это полная победа!\n'
          'Вы выиграли время для подхода основных сил.',
      choices: [
        Choice('Начать историю заново', 'start'),
      ],
    ),
  };

  void _makeChoice(String nextId) {
    setState(() {
      // Здесь мы обновляем состояние, меняя ID текущей сцены
      currentNodeId = nextId;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Получаем данные текущей сцены
    final node = storyData[currentNodeId];

    // Если вдруг ID неправильный (ошибка в коде), показываем заглушку
    if (node == null) {
      return const Scaffold(body: Center(child: Text("Ошибка сюжета")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Эхо на перешейке"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ТЕКСТ ИСТОРИИ
            Expanded(
              flex: 2, // Текст занимает больше места
              child: SingleChildScrollView(
                child: Text(
                  node.text,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),
            // КНОПКИ ВЫБОРА
            // Мы генерируем список кнопок динамически на основе choices
            ...node.choices.map((choice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton(
                  onPressed: () => _makeChoice(choice.nextNodeId),
                  child: Text(
                    choice.text,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}