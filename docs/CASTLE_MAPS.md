# Castle campaign geometry

`game/data/campaign.gd` defines six independent maps. `Campaign.levels()` returns an `Array[Dictionary]`; `Campaign.get_level(index)` uses one-based indices and returns a deep copy. The first map retains the tested moving-platform route from the previous prototype.

| Map | Theme | Width | Primary shape | Guards |
|---|---|---:|---|---:|
| Monastery Approach | approach | 2520 | Two long causeways and a drifting bridge | 2 |
| Ember Courtyard | courtyard | 2800 | Four alternating-height terraces | 3 |
| Bamboo Ramparts | bamboo | 3000 | Five wall sections with two upper detours | 4 |
| Castle Rooftops | rooftops | 3300 | A stepped climb to y420 followed by a descent | 4 |
| Broken Sanctuary | sanctuary | 3500 | Long inner-shrine route with an elite late guard | 5 |
| Crimson Castle Keep | summit | 2800 | Three ascending approaches and a wide captain arena | 4 |

The first five maps are marked `normal`; the last is `hard` and ends with an elite captain placement. These are tuning labels rather than claims about player-perceived difficulty.

Coordinates use existing world units. Every platform's `center.y` is the walkable **top**, with collision extending downward. `spawn`, `exit`, and every guard position are foot-origin points on stable static ground. A platform entry contains `center`, `width`, `optional`, and `one_way`. Optional overhead ledges **must** use one-way collision; otherwise the character's head will collide while walking under them. The primary route does not depend on those ledges.

Lift entries use `center`, `width`, `travel`, `duration`; center is the starting walkable top, and travel is the endpoint displacement. The parent's existing sine-based moving-platform implementation can consume them directly. Static platforms and lifts should be children of a per-level terrain root so changing maps clears the old collision shapes as well as the art. Actor X bounds and camera maximum must use each map's `width`; retaining the old 2496/2520 hard limit prevents later levels being completed.

Enemy entries use `position` and `elite`. An elite flag requests the parent's stronger existing guard implementation; it does not supply a new boss behavior. The keep's final static arena spans x1900–2800 at y510, leaving enough room for a readable duel.

Validation run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path game --script res://tests/campaign_data.gd
```

Passed: six distinct names and terrain signatures, map/platform bounds, supported spawns/exits/guards, one-way upper ledges, and a conservative graph route with jump edges and sampled lift positions joined by riding. The graph limits ascents to 90px and horizontal gaps to 145–195px depending on rise. It verifies geometric possibility, not jump timing, an input sequence, combat pacing, or fun; later map routes still need runtime traversal after parent integration. The previously implemented first-level two-jump route already has an actual physics integration test.
