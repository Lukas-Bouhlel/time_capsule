import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/capsule_model.dart';
import '../models/comment_model.dart';
import '../providers/comment_provider.dart';
import '../providers/user_provider.dart';

class CapsuleImmersiveView extends StatefulWidget {
  final Capsule capsule;

  const CapsuleImmersiveView({super.key, required this.capsule});

  @override
  State<CapsuleImmersiveView> createState() => _CapsuleImmersiveViewState();
}

class _CapsuleImmersiveViewState extends State<CapsuleImmersiveView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentProvider>(context, listen: false)
          .loadComments(widget.capsule.id);
    });
  }

  void _submitComment() async {
    if (_controller.text.trim().isEmpty) return;
    final content = _controller.text;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    _controller.clear();
    FocusScope.of(context).unfocus();

    await commentProvider.addComment(
      widget.capsule.id,
      content,
      userProvider.username ?? 'Moi',
      userProvider.id ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: 60,
            bottom: 80,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.capsule.imageUrl != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.capsule.imageUrl!,
                          width: double.infinity,
                          height: 230,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: cs.primaryContainer,
                        child: Icon(Icons.person, color: cs.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Capsule temporelle de",
                            style: tt.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          Text(
                            widget.capsule.author,
                            style: tt.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.capsule.title,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.capsule.description,
                    style: tt.bodyLarge?.copyWith(
                      height: 1,
                      color: cs.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 360), 
                ],
              ),
            ),
          ),
          Positioned.fill(
            bottom: 90,
            top: 100,
            child: Consumer<CommentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const SizedBox();
                return FloatingCommentsOverlay(comments: provider.comments);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.95),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Laisser une trace...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      onPressed: _submitComment,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingCommentsOverlay extends StatefulWidget {
  final List<Comment> comments;

  const FloatingCommentsOverlay({super.key, required this.comments});

  @override
  State<FloatingCommentsOverlay> createState() => _FloatingCommentsOverlayState();
}

class _FloatingCommentsOverlayState extends State<FloatingCommentsOverlay> {
  final List<Widget> _activeBubbles = [];
  Timer? _spawnerTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  @override
  void didUpdateWidget(covariant FloatingCommentsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _spawnerTimer?.cancel();
    super.dispose();
  }

  void _startLoop() {
    _spawnerTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted) return;
      if (widget.comments.isEmpty) return;

      if (_currentIndex >= widget.comments.length) {
        _currentIndex = 0;
      }
      
      final comment = widget.comments[_currentIndex];
      _addBubble(comment);

      _currentIndex++;
    });
  }

  void _addBubble(Comment comment) {
    final Key key = UniqueKey();

    setState(() {
      _activeBubbles.add(
        FloatingBubble(
          key: key,
          comment: comment,
          onAnimationComplete: () {
            if (mounted) {
              setState(() {
                _activeBubbles.removeWhere((element) => element.key == key);
              });
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _activeBubbles,
    );
  }
}

class FloatingBubble extends StatefulWidget {
  final Comment comment;
  final VoidCallback onAnimationComplete;

  const FloatingBubble({
    super.key,
    required this.comment,
    required this.onAnimationComplete,
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;
  
  final double _randomLeft = Random().nextDouble() * 0.2; 

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.0), 
      end: const Offset(0, -1.2),  
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 10 + (MediaQuery.of(context).size.width * 0.15 * _randomLeft), 
      bottom: 100, 
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _opacityAnim,
          child: _buildBubbleDesign(context),
        ),
      ),
    );
  }

  Widget _buildBubbleDesign(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = widget.comment.username == Provider.of<UserProvider>(context, listen: false).username;

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? cs.primary.withOpacity(0.9) : cs.surfaceContainerHighest.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.comment.username,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white70 : cs.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.comment.content,
            style: TextStyle(
              color: isMe ? Colors.white : cs.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}