# Crimson Monastery pixel art rebuild

User direction: all art pixel based, red moving background, dark textured walkable platforms, grounded enemies, purposeful responsive controls and matching VFX/audio.

Render contract: 640×360 raster world enlarged nearest-neighbor. World physics remains in the existing 1280×720 coordinates through a half-size game canvas/camera zoom. Generated backgrounds export to 640×360, platforms to 256×64, characters to 96×96 atlas cells with fixed feet registration, UI icons to 32–64 pixel sprites. Keep hard edges and restricted palettes. UI text uses a licensed pixel font without filtering.

Confirmed source defects: uniform black slab has no depth or surface identity; platform collision top isn't visually articulated. Full jump animation plays in air independently of physical ascent/descent. Previous art mixes painted sprites/background with standard GUI controls. Background only shifts as one texture. No visual effects signal takeoff/impact. Reported sound absence requires playback/event checks; files alone do not prove audible feedback.

Repair contract: textured capped ledges with top surfaces matched to collision; one actual AnimatableBody2D carries the player; independently scrolling far sky and transparent monastery midground; short attack arcs and takeoff/landing dust at feet; a generated pixel menu button, health frame, pause/resume icon and touch icons. Preserve two encounters and shrine-based progression. Menus show Start/Continue/Settings/Back with keyboard focus and no promotional subtitle. Health is understandable as hearts and current/max.

Player feedback: ivory/copper hero edge, orange danger telegraph, ivory slash, red damage, warm stone dust. Keep the playable foreground higher-contrast than distant red layers. Frame transient effects so enemies remain visible. Motion acceptance includes jump buffer, coyote time, variable jump release, grounded feet and moving-platform carry.

Source-art provenance and generated prompts live under assets/pixel/source; processed runtime sprites under game/art/pixel. Original smooth sources remain private and unchanged. Skill installation sources recorded in docs/PIXEL_REBUILD.md.

Castle expansion: three additional generated parallax layers (castle, rooftops, bamboo), a castle rampart ledge, and an eight-frame torch loop. Maps use distinct terrain layouts and palettes; progress/loader/menu retain the existing generated pixel frames. Runtime loading reports actual resource/route build stages. Walk/run use separate gait cycles with animation-linked grounded steps. Exploration and combat use separate licensed musical loops with threat-driven 1.2-second crossfade. Rejected audio source is removed from runtime.
