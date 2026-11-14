# World migration review

## Implemented scope

The campaign now uses100 distinct route geometries across10 directional traversal structures and four world materials: surface marsh, underground crystal cistern, cloud realm, and historical citadel. Each tenth route has a finale boss. Required interaction devices include a renewable one-charge sun relic and physical beam seal, a cloud seed and grown bridge, portal visits to an underground pocket, and timed fire vents. Existing level11 sentinel sequence remains.

The three new640x360 world backgrounds and three realm terrain strips are original generated raster art, retained with source images and prompts in `assets/environments/world-migration`. Walkable artwork is aligned to collision tops. Vertical shelves no longer create invisible full-height foundation walls. Citadel decks have suspension details. Realm particles differ in color; backgrounds are subdued for character readability.

## Evidence and limits

- Continuous route test:100 routes,820 sequential landing transitions with no between-jump teleport; enemies removed to isolate geometry.
- Realm integration test: portal roundtrip preserves health, switches background, required device keeps exit locked, retry restores seal.
- Background coverage: four biome modes across12 viewport/camera combinations.
- Player regressions: moving/reversing sword chains, effect budget, feedback separation, earned beam/bridge use and reset state.
- Native screenshots: `docs/qa/world-migration-{1,2,3,4,5,10}.png`.

This is a local playtest migration, not a claim of100 human-completed and balanced levels. Shared traversal structures and combat primitives remain; generated creature body artwork is distinct but is not100 separately hand-drawn animation sets. The playable campaign is finite rather than an unrestricted open world.

Rams quick_review was attempted for world-device labels using rules in the context. Its exposed schema has no `via` field and it returned `ran:false` because the workspace's15 review credits were exhausted. No Rams findings were available to fix.

## Final integration checks

- All100 runtime levels load with their introduced monster body/profile and contract;10 boss assignments validated.
- Broodmother test: death creates exactly6 children at22health, marks them as required before mother's defeat, locks gate until all6die, no recursive spawn.
- Required cloud puzzle: all10 loom levels now place the vow on the outer grown cloud. Activation alone does not complete the objective; the physical crossing/retrieval test passes.
- All30 device sections tested:10 pickup-to-seal shots,10 cloud activations/20cloud jumps/vow retrievals,10 portal entry and physical return traversals.
- Native stress sample on AppleM4/OpenGL, VSyncdisabled and simulated60Hz,240renderframes each on levels2/3/10/50/100 with forced monster casts and blood bursts: median1.82–3.45ms,95thpercentile4.56–7.96ms, maximum sampled100drawcalls. These are local uncapped render timings, not a guarantee across devices or a full gameplay benchmark.
- Fixed: old projectile lifetime across retry, relic beam invalidation on portal/retry, stuck plunge/drop-through state on portal, overly bright background competing with character, cloud jumps intercepted by normal upper decks.
