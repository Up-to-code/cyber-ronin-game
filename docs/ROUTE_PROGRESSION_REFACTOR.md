# Route progression refactor

Route progression now owns route requirements, gate opening state, attempt generation, and passage eligibility/charge. The scene delivers enemy/brood, pickup and mechanism events, observes the live cockpit/water state, and renders gate/HUD feedback. ObjectiveTracker remains the rule/text implementation used internally; guide targeting remains separate.

Reset initializes requirements from the authored route and invalidates pending completion callbacks. Gate animation completion must carry the current generation and is accepted only once. Returning to the menu invalidates the attempt. Brood children register before the mother defeat is handled. Swimming gates remain visibly open after diving again, while passage becomes ineligible until dry.

Preserved timing and geometry: 0.8-second opening animation, 0.45-second passage charge, 120-pixel interaction radius, 34-by-24-pixel aperture half-extents. Gate rendering, reward placement, wallet persistence, monster combat and authored mission requirements remain outside this refactor.

The existing scene counter properties remain compatibility accessors for older test fixtures. Runtime changes use progression events; gate status and attempt generation are read-only through the scene. No new abstract adapter framework was introduced.

Validation: 11 relevant suites passed (logs/results in qa/progression-refactor), including all 100 native gate lifecycles, 100 event-driven progression lifecycles, stale/duplicate callbacks, retry, menu cancellation, brood, hunt, cockpit, device, underwater and physical passage checks. The reward test now chooses an authored dry seal route and uses an explicit hunt fixture; its previous level-3/level-9 assumptions no longer matched the campaign. Player invulnerability isolates pickup checks from unrelated combat, and health assertions respect earned maximum health.

The local macOS app was rebuilt and passed deep/strict signature verification. Existing portal-passage test teardown still reports five ObjectDB instances at exit. This change does not claim a full human playthrough of all routes.

CONTEXT.md records the route, marked enemy, gate opening and gate passage vocabulary. Current title/armory changes were retained and are not part of the progression design.

Packaged native level-11 startup/capture passed without reported script errors; the frame was inspected.
