# Earned relics and realm devices

Sun pedestals give one colossal beam charge. X/G spends it, independently of power, after a 0.22-second aim telegraph. The beam pierces enemies and sun seals, stops at ordinary terrain, and owns its damage contact (no duplicate normal projectile). A spent charge can be recovered from the pedestal after three seconds. Death/retry resets charges through the existing motion reset.

Cloud seeds are spent with E at a cloud anchor. Each anchor grows its authored landing list into permanent one-way cloud decks for this level. The collision surface matches the visible flat cloud top. Empty anchors reject activation without consuming the seed; completed anchors cannot accumulate duplicate bodies. Permanent bridges avoid expiry softlocks.

Portals emit destination tokens to the world assembly. The parent teleports into an authored region and chooses its biome; the device throttles activation and E must be pressed again. Fire vents have a 0.7-second gold warning followed by a one-second flame window, per-device phase, and bounded damage cadence.

Runtime contract: `realm_device.setup(player, record)` before `add_child`; signals `completed(id)`, `realm_requested(destination)`, `relic_granted(kind)`. Record types: relic_laser, laser_seal, relic_cloud, cloud_anchor, portal, fire_vent. Position accepts Vector2 or [x,y]. Cloud landings are [x,y,width]. Parent owns required device IDs and level cleanup; devices and their bridges must live below that cleanup root. Portal transitions should preserve player relic charges.

The player receives short pixel strokes at takeoff, a broken ascending helix on the second jump, and gravel fans on landing. Authored character body cels and existing moving/reversing J combo timing remain intact. Sword miss and actual blood contact remain separate. Existing 64-node effect cap is preserved; this is a resource bound, not an FPS measurement.

Generated art prompt/source: assets/realm-relics/source/. Four transparent crops imported at nearest filtering in game/art/realm-relics/. Native screenshot: docs/qa/relic-devices-native.png. The screenshot is a device staging capture, not evidence of an entire level playthrough.

Validation: earned_relics, moving_sword_facing, effect_budget, feedback_separation, directional_fx pass under Godot 4.7.2. Native OpenGL device rendering captured and inspected. Parent still needs integrated route traversal/portal playtests.
