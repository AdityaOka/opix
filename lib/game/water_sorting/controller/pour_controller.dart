/// A tube is a list of color ids, ordered bottom to top.
/// So `tube.last` is the top of the tube — the only liquid you can pour out.

/// Checks if you're allowed to pour [from] into [to].
/// True only if [from] has liquid, [to] has room, and [to] is empty
/// or its top color matches [from]'s top color.
bool canPour(List<int> from, List<int> to, int capacity) {
  if (from.isEmpty) return false;
  if (to.length >= capacity) return false;
  if (to.isEmpty) return true;
  return from.last == to.last;
}

/// Pours the top color from [from] into [to], moving as much as fits.
/// Changes both lists directly and returns how many segments moved.
int pour(List<int> from, List<int> to, int capacity) {
  if (!canPour(from, to, capacity)) return 0;

  final int color = from.last; // the color we're moving
  int moved = 0;

  // Keep moving while the source's top is still that same color and the
  // target still has room.
  while (from.isNotEmpty && from.last == color && to.length < capacity) {
    to.add(from.removeLast());
    moved++;
  }

  return moved;
}

/// Works out how many segments a [pour] call would move, without
/// changing anything. Handy for animating a pour before it happens.
int pourAmount(List<int> from, List<int> to, int capacity) {
  if (!canPour(from, to, capacity)) return 0;

  final int color = from.last;
  final int room = capacity - to.length;
  int moved = 0;
  while (moved < from.length &&
      from[from.length - 1 - moved] == color &&
      moved < room) {
    moved++;
  }
  return moved;
}
