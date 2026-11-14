# Concept-to-game iteration 1

Target: approved opening courtyard and gate concepts in docs/concepts/six-levels. Built-in imagegen created five asset sheets/panoramas. Full-resolution sources retained in assets/concept-art/concept-pass; engine exports in game/art/concept-pass. Scripts only crop, remove background, align, resize nearest-neighbor and pack.

## Generation prompts
- Terrain: 2×2 transparent side-view pieces: flat charcoal masonry with amber walkable edge, alternate cracked rock, five shallow stairs, supported bridge arch; no characters/sky.
- Skyline: wide muted oxblood/charcoal Japanese monastery cliffs, distant pagodas and waterfalls; transparent sky, no foreground/characters.
- Gate: 2×2 same wall-framed red timber gate progressing closed/quarter/three-quarter/fully open; consistent wall, lanterns and baseline, transparent opening.
- Wraith: 3×2 six-frame masked spectral hover loop; ivory mask, tattered charcoal robe, crimson cord, same proportions, transparent.
- Hero: reference-matched 4×2 eight-frame upright walk cycle, alternating contact/passing poses, same katana hand and scarf; transparent.

## Integrated
- Separate distant skyline in existing parallax system; sky/cloud movement retained.
- New generated stone surface/masonry at existing physics tops.
- Dedicated hero walking drawings, separate from run.
- Gate's four frames play over0.8s on encounter clear; exit interaction waits for completion; one small opening particle burst.

## Comparison and correction
First native render: full platform cutouts tiled into repeating hanging islands. Corrected solid-floor export to a continuous masonry crop, keeping full piece for ledges. Near buildings competed with the new skyline; lowered their tint. Tests confirm gate waits for opening and attack/jump behavior remains intact.

## Prepared, not integrated
Stairs and bridge art need collision and traversal authoring; they are not yet playable stairs. Wraith hover sheet is ready as a candidate, but attack/hurt/death poses are not complete, so active enemies retain their coherent existing set. Boss and shadow beast from concept5/6 still require body animation sheets and AI. Existing hero attack/jump/idle artwork remains; the new walk asset is integrated.

## Gaps and next iterations
1. Flatten concept perspective into collision-aligned stair runs, add tested step-up or matching slope.
2. Generate wraith attack/hurt/death to match hover, then swap full profile together.
3. Generate oni/boss and beast by action family, test silhouettes at actual viewport size.
4. Generate closer wall/parallax layer to replace the older near pagodas.
5. Inspect gate in context for alpha fringe and visual frame drift; generated frames are not guaranteed identical architecture.

Validation: campaign_data, authored_contact, aerial_motion and gate_art pass. Native game rendered for comparison; this is scripted capture, not a full interactive playthrough. All game art is not yet replaced.
