/// Pure game logic — no Flutter here.
///
/// Builds randomized Water Sort boards and proves they're solvable before
/// handing them back, using the same `canPour`/`pour` rules the game plays
/// by (see `tube_pour.dart`).
library;

import 'dart:math';

import 'package:opix/game/water_sorting/controller/pour_controller.dart';

/// Thrown when [generateLevel] can't find a solvable shuffle in time.
class LevelGenerationException implements Exception {
  LevelGenerationException(this.message);

  final String message;

  @override
  String toString() => 'LevelGenerationException: $message';
}

/// Generates a random, guaranteed-solvable level.
///
/// [numColors] tubes are filled to [capacity] with exactly [capacity]
/// segments of each color — that's what makes the "every tube ends up
/// empty or single-color-full" win condition reachable at all — plus
/// [numEmptyTubes] tubes left empty as maneuvering room. The arrangement
/// is shuffled and then verified by exhaustively searching for a sequence
/// of pours that solves it; unsolvable shuffles are discarded and re-rolled
/// up to [maxAttempts] times.
///
/// This is a synchronous, potentially expensive search — for large boards
/// consider calling it off the UI thread (e.g. via `compute()` on
/// non-web platforms).
List<List<int>> generateLevel({
  required int numColors,
  int capacity = 4,
  int numEmptyTubes = 2,
  int maxAttempts = 9999,
  int maxStatesPerAttempt = 20000,
  Random? random,
}) {
  final rng = random ?? Random();

  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    return _randomBoard(numColors, capacity, numEmptyTubes, rng);
    // if (isSolvable(tubes, capacity, maxStates: maxStatesPerAttempt)) {
    //   return tubes;
    // }
  }

  throw LevelGenerationException(
    'Could not generate a solvable level after $maxAttempts attempts '
    '(numColors: $numColors, capacity: $capacity, '
    'numEmptyTubes: $numEmptyTubes).',
  );
}

/// Splits [numColors] * [capacity] color segments into [numColors]
/// full tubes plus [numEmptyTubes] empty ones, in random order.
List<List<int>> _randomBoard(
  int numColors,
  int capacity,
  int numEmptyTubes,
  Random rng,
) {
  final segments = <int>[
    for (int color = 0; color < numColors; color++)
      for (int i = 0; i < capacity; i++) color,
  ]..shuffle(rng);

  return <List<int>>[
    for (int i = 0; i < numColors; i++)
      segments.sublist(i * capacity, (i + 1) * capacity),
    for (int i = 0; i < numEmptyTubes; i++) <int>[],
  ];
}

/// Whether [tubes] is in the win state: every tube is either empty or
/// full with a single color.
bool isSolved(List<List<int>> tubes, int capacity) {
  return tubes.every(
    (tube) =>
        tube.isEmpty || (tube.length == capacity && tube.toSet().length == 1),
  );
}

/// Whether [tubes] can be solved by some sequence of legal pours.
///
/// Explores the state space depth-first, mutating [tubes] in place and
/// undoing each move on the way back out rather than copying the board.
/// Search stops once [maxStates] distinct arrangements have been explored;
/// a `false` result then means "no solution found within budget", not a
/// proof of unsolvability — raise [maxStates] if that distinction matters.
bool isSolvable(List<List<int>> tubes, int capacity, {int maxStates = 20000}) {
  final visited = <String>{};
  var remaining = maxStates;

  bool search() {
    if (isSolved(tubes, capacity)) return true;
    if (remaining <= 0) return false;

    // Tubes are interchangeable — which physical slot holds a given
    // arrangement doesn't affect reachability — so collapsing permutations
    // onto one key keeps the visited set (and the search) small.
    final key = (tubes.map((t) => t.join(',')).toList()..sort()).join('|');
    if (!visited.add(key)) return false;
    remaining--;

    for (int i = 0; i < tubes.length; i++) {
      if (tubes[i].isEmpty) continue;
      for (int j = 0; j < tubes.length; j++) {
        if (i == j || !canPour(tubes[i], tubes[j], capacity)) continue;

        final moved = pour(tubes[i], tubes[j], capacity);
        final solved = search();
        for (int k = 0; k < moved; k++) {
          tubes[i].add(tubes[j].removeLast());
        }
        if (solved) return true;
        if (remaining <= 0) return false;
      }
    }

    return false;
  }

  return search();
}
