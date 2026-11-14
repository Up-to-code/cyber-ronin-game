# Menu campaign map and buttons

Scope corrected after user clarification: redesign the campaign map in the main menu and menu buttons. Gameplay level geometry, platforms, actors, VFX and scenery retain their previous art. The 102 textures temporarily processed during the mistaken pass were restored byte-for-byte from a local backup.

The campaign atlas uses one generated pixel-art world with ten regions. WORLD shows an overview; each region opens its level route. All 100 level nodes preserve progression locks, 44-unit targets, keyboard focus and explicit ENTER action. Generated pixel button faces and panels are shared across title, pause, settings, story and defeat flows. The title uses pixel-font lettering; main-menu screens have a plain navy backdrop.

Assets generated with the built-in image-generation tool. Originals and source backup: assets/archive/pixel-redesign. Runtime files: game/art/pixel-redesign. Prompts: assets/archive/pixel-redesign/prompts.json. Deterministic cleanup uses palette reduction and nearest-neighbor sizing, with no drawn replacement artwork.

Trailer: actual Godot scenes and audio, directed by scripted input through the real player physics and combat controller. Four maps: Monastery Approach, Bamboo Ramparts, Sunken Cistern, Oni Throne. Opponents are staged for filming; this is not footage of a human playtest. Capture is repeatable with game/tests/record_trailer.gd and Godot --write-movie at 60fps. Native music and sound effects are recorded together.

Rams quick_review was requested via rules but could not run because review credits are exhausted. Campaign navigation and responsive menu layout tests passed; native menu renders were inspected. Physical mobile verification is pending.
