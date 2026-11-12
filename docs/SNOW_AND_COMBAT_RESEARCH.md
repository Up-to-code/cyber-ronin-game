# Snow, depth and combat mechanisms

Research: [Godot parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html) describes independent camera-relative layer speeds and the need to cover the viewport throughout scrolling. [Godot physics](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) distinguishes static architecture, controlled character bodies and impulse-driven rigid bodies. [Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) supplies licensed impact material; existing local licensed sources are reused for differentiated cues.

The game already integrates downward gravity in its fixed physics step. Animation poses, visual feedback and simulation are separate responsibilities. Static castle walls should remain structurally fixed; contact response belongs to struck actors, movable props, debris and short visual feedback. This pass does not claim that castle walls are rigid-body destructible objects.

Weather uses 100 deterministic flakes with independent depth, wind drift and camera-relative movement, bounded without accumulating nodes. Snow bursts accompany steps, takeoff and landing. Pausing freezes snowfall. Existing sky and architectural layers remain independently camera-relative, with stronger slow sky movement and extra coverage to avoid revealing an edge. Artwork is reused from existing project assets; no new environment illustration is claimed.

Controls now have centered icons only, animated press/release presentation, and stable touch hit regions. Charge and insufficient-energy states use visual feedback. Physical-device accessibility and subjective sound review remain pending.

Kick repair: one input can buffer through recovery; crouch clearance stays active for low kicks. Foot-to-torso contact uses the displayed attack frame. Airborne kicks preserve gravity and land normally. Stone contact blocks damage through walls and produces brief backward recoil with impact feedback. Enemy attack and cast cues are distinct from player attack sounds. See the kick-state tests and `AUDIO_EVENT_ROLES.md` for validation.

Native recording: `qa/snow-combat.mp4`. Inspected rendered frames show snowfall, icon-only controls and kick contact. Continuous subjective motion/audio approval and physical-phone play remain pending; this does not supply new intermediate character drawings. Rams UI review was attempted and blocked by exhausted credits.
