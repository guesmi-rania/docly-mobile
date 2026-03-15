import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState
    extends State<SymptomCheckerScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _typing = false;
  int _step = 0;

  // Arbre de décision simplifié
  final Map<String, dynamic> _symptomTree = {
    'keywords': {
      'cœur|cardiaque|poitrine|palpitation|essoufflement':
          'Cardiologue',
      'peau|acné|éruption|démangeaison|eczéma|psoriasis':
          'Dermatologue',
      'œil|vision|vue|lunettes|yeux': 'Ophtalmologue',
      'dent|gencive|bouche|mâchoire': 'Dentiste',
      'dos|colonne|vertèbre|lombaire|cervical':
          'Rhumatologue',
      'enfant|bébé|pédiatrique|nourrisson': 'Pédiatre',
      'femme|gynéco|règle|grossesse|utérus':
          'Gynécologue',
      'nez|gorge|oreille|ORL|sinusite|angine': 'ORL',
      'mental|anxiété|dépression|stress|sommeil':
          'Psychiatre',
      'os|fracture|articulation|genou|hanche':
          'Orthopédiste',
      'tête|migraine|mémoire|neurologique|épilepsie':
          'Neurologue',
      'estomac|ventre|digestion|intestin|foie':
          'Gastro-entérologue',
      'diabète|thyroïde|hormones|poids': 'Endocrinologue',
      'urine|rein|vessie|prostate': 'Urologue',
    },
  };

  final List<String> _questions = [
    'Bonjour ! 👋 Je suis votre assistant santé Docly.\n\nDescrivez-moi vos symptômes principaux. Par exemple : "j\'ai mal à la tête", "problème de peau", "douleur au dos"...',
    'Depuis combien de temps avez-vous ces symptômes ?',
    'Sur une échelle de 1 à 10, quelle est l\'intensité de la douleur ou gêne ?',
  ];

final List<String> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage(_questions[0]);
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _detectSpecialty(String symptoms) {
    final lower = symptoms.toLowerCase();
    for (final entry
        in (_symptomTree['keywords'] as Map<String, String>).entries) {
      final keywords = entry.key.split('|');
      for (final kw in keywords) {
        if (lower.contains(kw)) return entry.value;
      }
    }
    return 'Médecin généraliste';
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _addUserMessage(text);
    _userAnswers.add(text);

    setState(() => _typing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _typing = false);

    if (_step == 0) {
      // Analyser les symptômes
      final specialty = _detectSpecialty(text);
      _step = 1;
      _addBotMessage(_questions[1]);
      // Stocker la spécialité détectée
      _userAnswers.insert(0, specialty);
    } else if (_step == 1) {
      _step = 2;
      _addBotMessage(_questions[2]);
    } else if (_step == 2) {
      // Résultat final
      final specialty = _userAnswers[0];
      _showResult(specialty);
    }
  }

  void _showResult(String specialty) {
    final symptoms = _userAnswers[1];
    final duration = _userAnswers[2];

    _addBotMessage(
      '✅ Analyse terminée !\n\n'
      'Sur la base de vos symptômes :\n'
      '• "$symptoms"\n'
      '• Durée : $duration\n\n'
      '💡 Je vous recommande de consulter un(e) :\n\n'
      '🏥 **$specialty**\n\n'
      'Voulez-vous rechercher un(e) $specialty disponible près de chez vous ?',
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(ChatMessage(
          text: '',
          isUser: false,
          isAction: true,
          specialty: specialty,
        ));
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Assistant Symptômes',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (_typing && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[i]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context)
                          .extension<AppColors>()
                          ?.border ??
                      Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Décrivez vos symptômes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                              .extension<AppColors>()
                              ?.background ??
                          Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isAction) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, msg.specialty);
                },
                icon: const Icon(Icons.search),
                label: Text('Chercher un ${msg.specialty}'),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.gradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🤖',
                      style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppTheme.primary
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                  bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : null,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.gradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: List.generate(
                3,
                (i) => _TypingDot(delay: i * 200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        transform:
            Matrix4.translationValues(0, _animation.value, 0),
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isAction;
  final String? specialty;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isAction = false,
    this.specialty,
  });
}