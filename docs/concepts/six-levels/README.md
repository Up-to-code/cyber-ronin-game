# Six level concepts

Generated with built-in imagegen. These are visual targets, not screenshots or imported playable levels.

Shared prompt direction: wide16:9 pixel-art side-scrolling ASHEN VEIL, charcoal stone platforms, scarlet layered sky, straw-hat crimson-scarf ronin, supported geometry, warm landing edges, no HUD/text.

1. Arrival: open causeway, five broad steps, gate and distant guard.
2. Stair garden: five steps, safe terrace, upper bridge and lower alternate route.
3. Opening gate: split red doors within stone wall, broken seal fragments, dust/leaves, spacious courtyard beyond.
4. Guarded wall: spear guard and fire monk, supported balcony and door beyond encounter.
5. Monster courtyard: floating masked wraith, heavy oni and shadow beast, separated combat lanes.
6. Bell keeper: huge armored oni with chained bell, flat spacious boss arena and sealed exit.

Implementation notes: five stair risers require step-up controller handling or a matching smooth collision slope; decorative stairs alone are insufficient. Gate must gate collision until opening finishes, emit VFX once, and reveal traversable space. Preserve readable landings and telegraphs. Monster designs require separate sprites/animations and AI before use. Source illustrations contain perspective and fine detail; convert into consistent side-on tiles and separate parallax layers before runtime integration. No gameplay was changed or play-tested during this concept-art phase.
