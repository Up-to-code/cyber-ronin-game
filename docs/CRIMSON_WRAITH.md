# Crimson wraith hover pass

Built-in image generation produced nine sequential hover drawings: ivory horned mask, crimson cloth, burgundy shadow. Source and exact prompt are in `assets/crimson-wraith/`; engine exports and animated WebP are in `game/art/crimson-wraith/`.

`tools/build_crimson_wraith.py` removes the magenta extraction background, applies one shared scale, and registers each ivory mask to (64,68) in a 128-square cell. This prevents cloth length changes from moving the head. All nine frames are distinct, alpha bounds stay inside each cell, and the loop runs at 90ms per cel (810ms total). Simulation remains independent of art cadence.

Integrated into `wraith_pixel.json` idle, float and movement clips. Attack, windup, hurt, death and damage definitions remain byte-equivalent JSON values to the archived prior profile. The new mask/cloth art is similar to the previous horned-mask design but combat cels still use the older drawings; a complete authored combat pass remains a visual gap.

Validation: Godot import succeeded; native `tests/crimson_wraith.gd` passed, confirming all nine hover frames advance, combat states override hover, and existing reaction clips are preserved. Rendered output inspected at `docs/qa/crimson-wraith.png`. This was a scripted visual check, not full-level playtesting.

## Matching casting follow-up

A second six-cel sheet now supplies the same crimson mask/cloth design for windup and attack. Two windup cels cycle over 320ms; five attack presentation beats use 100/50/45/45/80ms. The contact remains 100ms, active end 150ms, total attack 320ms, and attack definitions remain unchanged. Wider 192x128 casting canvases preserve trailing cloth without shrinking the mask; their origin and sockets shift together by 32px to retain world positions. The new source, prompt and `attack.webp` are saved alongside hover assets.

Native `tests/crimson_wraith.gd` passed with explicit contact/active-end/duration assertions and five attack frames. `docs/qa/crimson-wraith-cast.png` was inspected. **Remaining old artwork is hurt/death and the air fallback only**, not the normal hover-to-cast transition. Earlier paragraph describing preserved attack/windup artwork is superseded by this follow-up.
