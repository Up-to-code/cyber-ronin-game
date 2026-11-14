# Black jungle terrain

`game/systems/terrain_visual.gd` is presentation only. `TerrainVisual.decorate(body, width, one_way=false)` adds a `JungleGround` child; the body and collision remain owned by the level. Its cap begins exactly at body-local y=0, with visible width equal to the owner's width. This matches the existing platform contract where the body's position is its walkable top.

The earlier vertically repeating brick panels are replaced by a generated shallow earth/moss/black shale cap, a single nearly black foundation polygon, and sparse generated root/rock details. The cap tiles horizontally only. The foundation is not a texture and cannot repeat vertically. The visual depths match existing collider depths: 144 world units for static terrain, 56 for moving platforms, 24 for optional one-way ledges. Root detail placement and variant depend deterministically on body position and width, rather than frame randomness.

The visual's jagged underside does not alter collision; the top stays flat. Large static spans remain one dark connected mass, and optional ledges stay thin. Existing red sky/castle cloud parallax remains separate and unchanged. No decorative foliage is baked into collision or above the walking line.

Raw generated images and hand-written prompts are in `assets/art/pixel/jungle/`. `tools/process_jungle_assets.py` only cleans alpha, quantizes, crops, resizes and assembles atlas exports. Output: `game/art/pixel/jungle_surface.png` (256×12), `jungle_roots.png` (128×128, four 64×64 cells).

Validation: `game/tests/jungle_terrain.gd` exercises 256/600-width static terrain, a moving platform and a one-way ledge; checks cap/top alignment, exact width and 144/56/24 depth. Native screenshot `/tmp/jungle-terrain-qa.png` was inspected at 1280×720: ground cap is distinct from the near-black subsurface and no tall repeated masonry remains. This verifies the isolated terrain component, not an integrated full level or physical phone.
