# Crimson spirit projectile

Implemented generated nine-frame flight animation for the existing energy attack (X/G). Built-in imagegen produced the raw 3×3 sheet; deterministic Pillow processing removed magenta, split shared cells, nearest-resized to 96×64, and packed the engine strip. No creative shapes were drawn in processing.

- Runtime: `game/systems/combat_projectile.gd`, `game/art/crimson-magic/spirit-flight.png`
- Raw/prompt: `assets/vfx/crimson-magic/spirit-flight-source.png`, `spirit-flight.prompt.txt`
- Preview: `game/art/crimson-magic/spirit-flight.webp`
- Rebuild: `.pixel-tools/bin/python tools/build_crimson_magic.py`
- Frame metadata: `game/art/crimson-magic/manifest.json`

The procedural purple/teal tail is removed. Generated crimson flame ribbons and ivory spear tip animate at 16 FPS with nearest texture sampling. The tip is positioned at the swept collision point, trailing smoke behind it. Damage 65, speed 1100, life 0.8 seconds and fire interception are unchanged. Enemy fire and basic blade projectiles are unchanged.

Validation: Godot import succeeds; `fire_interception.gd` passes; native `crimson_magic_preview.gd` checks nine advancing cels and unchanged combat values and captures `docs/qa/crimson-magic.png`. Screenshot visually inspected. Capture stages a stationary projectile to inspect art; it is not a full playthrough or an impact audio evaluation.
