# Pixel-art rebuild — 2026-11-11

Current revision: the rejected sword pack and old drone are replaced. See `AUDIO_REVISION.md`, `LOCOMOTION.md` and `CASTLE_MAPS.md` for the six-map castle campaign and current audio. Earlier source listings below are historical.

The user's request supersedes the original painted/smooth direction. The running game now uses pixel textures throughout its environment, characters, platforms, GUI and effects. Two encounters remain; this is not the completed six-level campaign.

## Installed and applied skills

- [kill-game-slop](https://github.com/Ddrubok/kill-game-slop/tree/main/skills/kill-game-slop): installed under `/Users/ahmedmansour/.codex/skills/kill-game-slop`. Applied its gameplay/art coherence checks to contact, timing, state transitions, UI and assets.
- [generating-dot-assets](https://github.com/abagames/agentic-gamedev-skills/tree/main/.agents/skills/generating-dot-assets): installed under `/Users/ahmedmansour/.codex/skills/generating-dot-assets`. Applied its generated-object, sizing, alpha and validation contract. ImageMagick installed for the supplied validation tools.
- Existing `generate2d-assets-clean-align`, `imagegen`, `game-ui-ux`, and Godot skills supplied layered scenery, FX sheets, registration and engine integration guidance.

New skills are available for automatic selection on the next turn; their installed instructions were read and applied explicitly during this turn.

## Repairs and evidence

| Finding | Evidence | Applied repair | Verification |
|---|---|---|---|
| Featureless black floor | Supplied screenshot and old source | Generated capped stone/root ledges with surface-aligned collision | Rendered frame; player/enemy floor-contact assertions |
| Inconsistent smooth/pixel art | Old resources and running scene | Nearest-rendered generated pixel scenery/GUI; registered pixel exports of Ronin animation frames | Runtime captures and asset dimensions/alpha checks |
| Jump pose and physics disconnected | Controller played jump clip while airborne | Distinct rising/apex/fall poses, variable height, coyote and buffered jumps | Movement tests; scripted rendered jump sequence |
| Background was a single shifting image | Old main scene code | Separate opaque sky/mountains and transparent monastery layers with different camera ratios and continuous scrolling | Recorded movement sequence |
| Platform did not move | Old single StaticBody2D floor | Textured AnimatableBody2D lift across actual gap | Standing-rider carry and two-jump route tests |
| No VFX | Old scene lacked FX nodes | Generated animated slash, impact and dust sheets; callbacks from actual gameplay events | Native effect test; recorded contact and jump frames |
| Reported absent sound | Saved `audio.enabled=false` reproduced silence | Enabled saved sound setting, added recorded CC0 sword samples, textured jump/landing sounds, stronger effect mix and limiter | Native audio bus test; recorded movie has non-silent audio, maximum approximately -1.2 dB |
| Death motion froze at first frame | Closer agent source/runtime review | Let death animation finish before pausing on result menu; invalidate stale callback on retry | Death/retry tests |

The platforming agent implemented the controller, enemy ledge safety and moving-body behavior, then acted as closer on the integrated scene. Its traversal and hit-timing tests passed. Human preference/fun and physical phone behavior are not inferred from these tests.

## Asset production

Built-in image generation created six raw assets: sky, transparent monastery, platform, UI atlas, FX sheet and shrine. Each prompt is beside its `.raw.png` in `assets/art/pixel/source`. `tools/process_pixel_assets.py` handles resizing, chroma removal, palette reduction, cell splitting and character registration; it does not draw the raw assets. The shrine is separately trimmed, reduced to 24 colors, fitted and padded to 128×144. Runtime art is under `game/art/pixel`.

Character art derives from the licensed Cyber Ronin kit; original files remain unchanged under `assets/characters`. Processed character atlases stay excluded from Git. Pixelify Sans is bundled with its OFL license. Recorded sword source and CC0 notice: [StarNinjas](https://opengameart.org/comment/92361).

## Technical references checked

- [Godot CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): floor following, moving-platform layers and leaving-platform velocity.
- [Godot AnimatableBody2D](https://docs.godotengine.org/en/stable/classes/class_animatablebody2d.html): moving collision surfaces and physics synchronization.
- [Godot parallax concepts](https://docs.godotengine.org/en/stable/classes/class_parallax2d.html): independent camera-relative scroll rates and repeat coverage. This prototype implements those layers explicitly in its background canvas.
- [Godot hard limiter](https://docs.godotengine.org/en/stable/classes/class_audioeffecthardlimiter.html): master-bus ceiling prevents overlapping voices clipping.

## Checks and limits

Godot import, per-script parsing and smoke checks; controller and actual-level platforming tests; synthetic multi-touch, pause release, menu navigation and responsive layout checks; native slash/impact/dust and audio-output test; platform/shrine transparent-corner validation; native rendered desktop/mobile-width captures. The MP4 uses scripted input with guard AI frozen for isolated contact, not a full playthrough.

Rams quick_review was invoked with `via=rules` as requested. It could not run because the workspace has exhausted its review credits. Manual visual checks were performed instead. Physical-phone installation, signing/export presets, final music composition and the remaining four campaign locations are pending.
