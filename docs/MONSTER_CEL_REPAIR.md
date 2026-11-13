# Monster motion repair — 13 November 2026

All 100 roster identities now use model-generated whole-character pose sheets through the live enemy state controller. Each sheet contains 12 distinct poses: four locomotion, four attack, two hurt and two death poses (1,200 total). This is a four-pose movement cycle, not a fully inbetweened animation set. Individual clip mappings accommodate unusual anatomies and attacks.

The renderer follows actual windup, contact, recovery, hurt and death timing, mirrors around registered origins, and uses one consistent scale per creature. Grounded walking advances with distance; flying and swimming have separate cadence. Death origins align visible bodies with the support surface. Current-pose snapshots replace standing-image afterimages, and legacy body shards no longer cover the new deaths.

Foot-contact dust, wing streaks, swimming bubbles and impact particles supplement the existing individual attack motifs. Particle counts and offscreen activity are bounded. Hovering monsters are kept inside the upper world boundary. Underground/citadel foundations use tiled masonry; compact objective guidance reveals more of the play area.

## Validation

- All 20 suites in `qa/cel-final/test-results.json` passed: 100 pose profiles, animation states, death grounding, attack timing, AI timing, individual contracts, platforming, aquatic behavior, moving sword facing, underwater integration, directed traversal, route devices, runtime migration, gate lifecycle, HUD/foundations, campaign navigation, inventory, sequence machine, background coverage and exit clearance.
- Directed traversal checks inject cleared required barriers; gate lifecycle tests inject objective completion. These are not 100 complete human combat playthroughs.
- Native 12-state staged captures exist for every identity as `qa/drawn-monster-NNN.jpg`. Generation agents reviewed their assigned sheets; final representative runtime inspections include the crane (005), wide centipede (024), sword rack (073), and crab boss (080). These captures verify visible states, not every transition at normal speed.
- Five native stress samples (levels 2, 3, 10, 50, 100): median frame time 7.25–9.91 ms, p95 11.27–12.02 ms on this Apple M4. Short local samples are not a guarantee for every encounter or machine.
- Three isolated headless suites retain ObjectDB exit warnings (2–13 instances); no failing assertions or script errors were reported. This remains a cleanup issue.
- Rams quick_review was attempted after UI changes with rules requested, but returned `ran:false` because review credits were exhausted. No Rams approval is claimed; local layout tests passed.

## Build and storage

The self-contained `dist/AshenVeil-Playtest.app` was rebuilt with the new assets. Its nested Godot bundle and enclosing app passed deep/strict signature verification; a packaged native level-2 startup smoke test exited successfully without script errors. This is an ad-hoc local playtest, not a notarized release.

The three explicitly approved old ZIPs and older `dist/Ashen Veil.app` were removed. The older app's game-data package is preserved as `dist/AshenVeil-legacy-preserved.pck`; its SHA-256 was rechecked successfully against `dist/AshenVeil-legacy-preserved.sha256`. All source art and project files remain. Identical PNG copies share APFS blocks without changing file contents. About 244 MiB remained after the build, so storage is still tight.
