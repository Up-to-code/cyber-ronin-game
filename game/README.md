# Crimson Monastery prototype

Open project.godot in Godot 4.7 and press F6/F5, or launch Godot with --path game from the workspace root.

A/D move, Space jump, J attack, K dodge, E use the exit, R retry. Clear two guards and walk to the right-hand shrine to enter encounter two. Three guards guard the second exit. Start journey opens gameplay. Esc or the top-right pause button opens Resume, Settings, Restart level and Main menu. Touch controls appear on mobile or can be enabled in Settings; each action uses its own TouchScreenButton. The HUD adapts to landscape aspect ratios and mobile safe areas. Physical-device testing, signing and export presets remain pending.

The arena uses the generated monastery concept and licensed Cyber Ronin character sprites. Original synthesized sound effects and a quiet atmospheric loop are integrated; toggle audio in Settings. The full six-location campaign remains planned. Copied character sheets retain the source license from ../assets/characters/cyber_ronin/CyberRonin_SpritePack/LICENSE.txt.

Validation: Godot import, script parsing, runtime smoke check, rendered frame inspection, and tests/smoke.gd passed. Run integration checks with Godot --headless --path game --script res://tests/smoke.gd and res://tests/mobile_ui.gd. Synthetic multi-touch and layouts at 1280×720, 1600×720 and 960×540 were checked; the phone layout was rendered at 1200×540 on desktop.

Rams quick_review was attempted with via=rules, but could not run because the workspace review credits were exhausted. HUD was manually checked.

## Pixel rebuild

640×360 reference canvas, nearest-neighbor pixel textures and pixel font. Character frames retain the kit's animation data but are exported onto registered 96×96 cells. Generated pixel-art skies, transparent temple layer, stone ledges, torii exit, menu textures, health, pause/touch icons and VFX are in art/pixel. Raw generated art and prompts remain in ../assets/pixel/source.

The moving platform bridges the gap between x920 and x1200. It carries a standing player; jump buffering, coyote time, variable jump release and accelerated movement are implemented. The integration test traverses both gap jumps and verifies enemies remain grounded. Death animation now completes before the retry menu.

The current revision replaces the rejected sound pack with original cloth, stone and katana effects plus exploration/battle music by MOMIZizm MUSiC. See audio/MUSIC_CREDITS.txt and ../docs/AUDIO_REVISION.md. Sound is enabled for the current run; Settings persists changes. Native output metering and the recorded MP4 verify non-silent audio; the movie peaks below 0dB.

Additional checks: tests/platforming.gd, tests/effects.gd (native with -- --qa-gameplay), tests/mobile_ui.gd. Recording: ../docs/qa/pixel-playthrough.mp4. The capture uses scripted inputs and freezes guard AI to isolate attack contact; it is not a complete playthrough or physical-device test.

Current campaign: six distinct maps in data/campaign.gd with real resource-loading progress, unlockable map selection, moving lifts, animated torches and a final elite captain. Shift runs, A/D walks; mobile RUN toggles sprint with any touch finger. See ../docs/CASTLE_MAPS.md and ../docs/LOCOMOTION.md.
