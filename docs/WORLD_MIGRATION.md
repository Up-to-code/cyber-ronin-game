# Directed campaign migration

The campaign now uses 100 distinct directed itineraries rather than resized horizontal routes. The first three teach surface crossings, underground descent and sky ascent. Eleven traversal families cover crossings, rootwell descents, cloud stairs, switchbacks, return loops, gorges, towers, deep drops, vow pilgrimages, finale arenas and free swimming. Geometry, widths, elevation rhythm and enemy placement vary within each family; these are deliberately shared traversal vocabulary, not 100 wholly unrelated mechanics.

The data audit records 438 rises, 298 drops and 125 changes of horizontal direction. Platforms carry explicit purposes. Vertical routes use jump-through decks, avoiding filled columns or solid overhead decks that block the next jump. The loader retains authored geometry without resizing or random filler balconies.

Every numbered level features its corresponding monster roster ID. The underwater stage previews existing aquatic identities from later stages. Every tenth stage ends at a wide boss arena, beginning with the broodmother at level 10. Actor mechanics and artwork are implemented separately from route generation. Level 11 retains its sequence-machine-compatible exit and fixed first training jump.

Ten laser-seal routes award a rechargeable Sun Core before the seal. Ten cloud-loom routes award a seed and create two ascending cloud decks with E. A required vow above the outer cloud must be retrieved before the exit unlocks; merely activating the loom does not complete the objective. Ten return-loop stages include an enterable pocket realm, a resident enemy and a reachable return engine. Fire vents occupy broad combat landings on twenty stages. The pocket changes biome through region metadata; it does not replace the entire campaign map.

## Verification

`redesigned_campaign.gd` checks 100 distinct directed geometry signatures, four world biomes, purposeful surfaces, monster identity/kind consistency, first introductions, final boss placement, and portal region records.

Before the flooded-palace replacement, `directed_traversal.gd` traversed all 820 consecutive primary-route transitions across all 100 levels using real movement, jump and down inputs. The player is spawned only once per level; there are no between-jump teleports. Enemies are removed and invulnerability enabled to isolate navigation from combat. This establishes geometry reachability, not balanced combat difficulty or a human playthrough. The current jump suite excludes level 8 because it now uses free swimming.

`route_devices.gd` separately exercises earned laser input, walking to a loom and activating E, physical cloud jumps with required outer-vow retrieval (activation alone leaves the vow outstanding), and physical pocket return-platform traversal. Tests set the initial position at a device section to isolate those mechanics. `realm_integration.gd` checks realm preservation, objective locks and retry reset.

Level 8 is now the Drowned Palace: a dry arrival, three pearls in distinct flooded chambers, three rotating currents, masonry partitions with broad passageways, and a dry eastern exit. `underwater_data.gd` verifies metadata and sweeps a 44×84 body along the authored swim itinerary to ensure clearance; native swimming is covered by the separate runtime integration.

The previous four signature-route overrides are superseded by this campaign. `signature_routes.py` remains historical authoring code and is not imported by the generator.

## Gate guidance audit

`systems/objective_tracker.gd` is a pure model for completion, an actionable explanation and target selection. It distinguishes guards, bosses, required devices, vows/pearls, the level-11 cockpit, and the dry underwater exit. Live actor/pickup snapshots prevent stale markers. Cross-realm targets direct the player to the appropriate portal instead of pointing through inaccessible space.

`tests/objective_tracker.gd` simulates objective completion across all 100 maps, checks that killing all actors cannot bypass required puzzles, verifies every required land actor stands on an authored platform, and checks the level-4 Sun Core/prism guidance and hidden-realm guard routing. These are model and placement checks, not 100 human combat playthroughs. Level 8 deliberately allows aquatic enemies to be avoided; three pearls and reaching dry ground are its objective.

## Exit frame clearance

Exit metadata specifies scale `(0.65, 1.0)` and sprite offset `(0, -88)` for the 256×176 atlas frames. The resulting 166.4×176 visual rectangle rests exactly on the exit floor. `exit_clearance.gd` checks all 100 frames against every authored solid/deck rectangle, full-width floor support and world bounds. Five descending stages (12, 28, 52, 78 and 88) receive a wider outer exit apron; its incoming edge stays fixed while the doorway moves out from below the overhead platform. Water and cockpit exits retain their positions.
