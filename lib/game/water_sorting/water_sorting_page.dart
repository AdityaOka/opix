import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opix/game/water_sorting/controller/level_generator_controller.dart';
import 'package:opix/game/water_sorting/controller/pour_controller.dart';
import 'package:opix/game/water_sorting/widget/tube_widget.dart';

class _LevelParams {
  const _LevelParams({
    required this.numColors,
    required this.capacity,
    required this.numEmptyTubes,
  });

  final int numColors;
  final int capacity;
  final int numEmptyTubes;
}

/// Runs [generateLevel] on a background isolate via [compute].
List<List<int>> _generateLevelInBackground(_LevelParams params) {
  return generateLevel(
    numColors: params.numColors,
    capacity: params.capacity,
    numEmptyTubes: params.numEmptyTubes,
  );
}

class WaterSortingPage extends StatefulWidget {
  const WaterSortingPage({super.key});

  @override
  State<WaterSortingPage> createState() => _WaterSortingPageState();
}

class _WaterSortingPageState extends State<WaterSortingPage>
    with SingleTickerProviderStateMixin {
  static const int numColors = 8;
  static const int capacity = 6;
  static const int numEmptyTubes = 1;

  // Null while the level is still being generated.
  List<List<int>>? tubes;

  int? selected;

  late final AnimationController _pourController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  int? _pourFrom;
  int? _pourTo;
  int _pourCount = 0;
  int _pourColorId = 0;

  @override
  void initState() {
    super.initState();
    // Wait for the first frame (the loading spinner) to actually be
    // painted before starting the heavy generation work, so the page
    // transition isn't blocked by it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLevel());
  }

  Future<void> _loadLevel() async {
    // On web, `compute()` only yields a microtask (`await null`) before
    // running synchronously on the main thread — that's not enough for
    // the browser to actually paint the spinner frame first. A real
    // macrotask yield here gives it that chance. (No-op cost on
    // non-web, where `compute()` already runs on a true isolate.)
    // await Future.delayed(Duration.zero);

    // final generated = await compute(
    //   _generateLevelInBackground,
    //   const _LevelParams(
    //     numColors: numColors,
    //     capacity: capacity,
    //     numEmptyTubes: numEmptyTubes,
    //   ),
    // );
    final generated = generateLevel(
      numColors: numColors,
      capacity: capacity,
      numEmptyTubes: 2,
    );
    if (!mounted) return;
    setState(() => tubes = generated);
  }

  @override
  void dispose() {
    _pourController.dispose();
    super.dispose();
  }

  void _onTapTube(int i) {
    final tubes = this.tubes!;
    if (_pourController.isAnimating) return;

    setState(() {
      if (selected == null) {
        selected = i;
      } else if (selected == i) {
        selected = null;
      } else {
        final from = selected!;
        final moved = pourAmount(tubes[from], tubes[i], capacity);
        selected = null;
        if (moved > 0) {
          _pourFrom = from;
          _pourTo = i;
          _pourCount = moved;
          _pourColorId = tubes[from].last;
        }
      }
    });

    if (_pourFrom == null) return;

    final from = _pourFrom!;
    final to = _pourTo!;

    _pourController.forward(from: 0).then((_) {
      setState(() {
        pour(tubes[from], tubes[to], capacity);
        _pourFrom = null;
        _pourTo = null;
        _pourCount = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tubes = this.tubes;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Water Sorting',
          style: GoogleFonts.vt323(fontSize: 16, color: Colors.white),
        ),
      ),
      body: Center(
        child: tubes == null
            ? const CircularProgressIndicator()
            : AnimatedBuilder(
                animation: _pourController,
                builder: (context, _) {
                  final double t = _pourController.value;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      for (int i = 0; i < tubes.length; i++)
                        GestureDetector(
                          onTap: () => _onTapTube(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            // Lift the selected tube up so you can see
                            // it's picked.
                            transform: Matrix4.translationValues(
                              0,
                              selected == i ? -20 : 0,
                              0,
                            ),
                            child: TubeWidget(
                              capacity: capacity,
                              // Pass a COPY so the painter sees a changed
                              // list and repaints (pour mutates the
                              // original list in place).
                              colors: [...tubes[i]],
                              // While this tube is the pour's source, hold
                              // back the segments in transit so they draw
                              // as the shrinking band below instead of the
                              // static stack.
                              staticCount: i == _pourFrom
                                  ? tubes[i].length - _pourCount
                                  : null,
                              bandHeight: i == _pourFrom
                                  ? _pourCount * (1 - t)
                                  : i == _pourTo
                                  ? _pourCount * t
                                  : 0,
                              bandColorId: (i == _pourFrom || i == _pourTo)
                                  ? _pourColorId
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
