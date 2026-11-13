# Crimson and gold game art

Generated with the built-in image_gen tool, November 13, 2026. Original RGBA sheets are preserved in source; engine exports are in ../../game/art/crimson-gold. Processing uses nearest-neighbor resizing, alpha-preserving crops, and sheet extraction only. Rebuild with python3 tools/prepare_crimson_gold.py.

Prompts: [menus](source/ui.prompt.txt), [machine](source/machine.prompt.txt), [impact animation](source/fx.prompt.txt), [terrain](source/terrain.prompt.txt).

Integrated assets: normal/selected/pressed buttons, panel, cockpit, sentinel, piston, glass, four impact frames, ground cap/fill and timber support. The retaining-wall end export is available for future terrain variants.

Lowest solid platforms now extend their matching collision and textured foundation down to the level boundary. Platforms with overlapping routes below retain their original depth. Balcony posts are background supports, not collision barriers. Walkable deck coordinates remain unchanged.

Checked: rendered title, pause, cockpit, beam impact and balcony landing; machine state tests; player landing and moving/aerial attack tests; responsive mobile UI checks. Rams was attempted but review credits are exhausted; its exposed schema has no via field.
