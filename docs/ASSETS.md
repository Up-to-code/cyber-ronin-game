# Asset inventory

Current revision: the rejected sword pack and old drone are replaced. See `AUDIO_REVISION.md`, `LOCOMOTION.md` and `CASTLE_MAPS.md` for the six-map castle campaign and current audio. Earlier source listings below are historical.

Researched 2026-11-11. Web-page terms are intake evidence; preserve and read the actual included license before release. Download state is recorded separately in `asset-intake.json`. Public source links are not permission to republish asset archives.

| Role | Source and decision | Availability / terms observed |
|---|---|---|
| Player, enemies, bosses | [Cyber Ronin — PavelEKh](https://pavelekh.itch.io/cyber-ronin-sprite-pack). Primary character pack. Godot SpriteFrames resources supplied; smooth sprites, use bilinear filtering. | Name your price; commercial use and modification allowed; no standalone source redistribution; optional credit. AI-assisted artwork disclosed. |
| Equipment/reward icons | [20 sets spearman — Cyber Sausage](https://cyber-sausage.itch.io/20-sets-spearmet). Menu icons, not animated combatants or a GUI kit. | Name your price; 64×64 cells; commercial modification allowed; no standalone source redistribution or AI-system use. Optional credit. Do not send these images to image-generation tools. |
| Primary terrain | Custom near-black stone, wood and rooftop modules; small lighter collision-edge accents. | Planned original assets; not yet authored. Separate collision from decoration. |
| Backgrounds | Original generated crimson monastery concept, then separately authored parallax layers for all six locations. | Concept generation in this workspace; flattened concept is not production-ready scrolling art. |
| Optional temple scenery | [Feudal Japan Temple — Pozac](https://pozac.itch.io/feudal-japan-temple-2d-pixel-art-platformer-asset-pack). Side-view modular alternative. | Paid, not purchased. Commercial modification permitted; no source redistribution. Pixel style differs from primary characters. |
| Optional bamboo scenery | [Feudal Japan Bamboo — Pozac](https://pozac.itch.io/feudal-japan-bamboo-village). Alternate bamboo/bridge setting. | Paid, not purchased. Commercial modification permitted; no source redistribution. Pixel style differs. |
| Optional platform demo | [Japanese Sakura side-scroller — SakPix](https://sakpix.itch.io/japanese-sakura-side-scroller-tileset). Trial for traversal geometry. | Free demo/paid full pack; commercial use advertised. Pixel style; license file must be checked before integration. |
| HUD/menu components | [UI Pack — Kenney](https://kenney.nl/assets/ui-pack). Primary neutral panels/buttons, recolor charcoal/red/ivory. | Free CC0. Candidate, not yet integrated. |
| Optional pixel menu | [UI Pack Pixel Adventure — Kenney](https://kenney.nl/assets/ui-pack-pixel-adventure). Alternative if matching equipment slots. | Free CC0. Candidate, not yet integrated. |
| Sword attacks/parries | [20 Sword Sound Effects — StarNinjas](https://opengameart.org/comment/92361). Ten attacks and ten clashes. | CC0 stated on source listing. Candidate; audition before integration. |
| UI audio | [Interface Sounds — Kenney](https://kenney.nl/assets/interface-sounds). Menu selection/confirmation candidates. | Candidate; retain included license at download and verify clip selection. |
| Exploration/combat music | [Free Japanese Fantasy Music Pack — Momiziba](https://momiziba.itch.io/free-japanese-music-pack). Audition Mountain God's Shrine for monastery, Shamisen Samurai Rock for fights. | Free, commercial use allowed; credit required unless using the stated donation alternative. Candidate, not auditioned. |
| Boss music | [Ketchaku — Haru Studios](https://haru-studios.itch.io/ketchaku). Japanese/orchestral battle candidate. | Name your price; commercial use allowed, credit optional. Short track; do not assume seamless looping. |
| Optional music set | [BGM Collection VOL.1 Japanese Style — oten10](https://oten10.itch.io/bgm-collection-vol1-japanese-style). Exploration and battle cues, OGG/MP3. | Paid, not purchased; commercial use, editing/looping permitted; no standalone redistribution. |

Keep a consistent perceived character size; inspect feet/pivots rather than scaling all textures to the same rectangle. Trim atlas memory only after animation alignment is verified. For mobile, ship selected animations and compressed music instead of importing every unused source file into the export.

Missing before production: footsteps by surface, landing, hurt/death, dodge, checkpoint/exit, ambience, finished GUI theme, six layered backgrounds, modular terrain and collision shapes. The selected pack may cover some character cues but its name alone does not establish that.

Suggested credits: “Sprites: Cyber Ronin Sprite Pack by PavelEKh”; “Assets by CyberSausage”; “Free Music : MOMIZizm MUSiC — https://music.storyinvention.com/en/”; “Sword sounds: StarNinjas”. Keep license files with the private project and credits with the exported game.
