# Armory, monster scale and gate review

Open B or click ARMORY. The ronin preview appears on the left and purchases on the right. Blade Discipline adds15% sword damage per rank (five ranks); Iron Heart adds20 maximum health (three ranks). Tidal Nova and Crimson Elixir packs each contain three uses, activated with Q/H or the new gameplay buttons. Remaining charges must be used before repurchasing a pack. Elixir does not spend a charge at full health.

Coins, upgrades and charges share the existing settings save. Purchases save wallet and inventory together via a temporary file rename. Retries apply purchased maximum health and damage but do not replenish charges or refund coins. The armory pauses gameplay and releases held movement controls. Inventory tests use separate settings files, not the player's real wallet.

A shared objective model now drives both gate completion and the persistent guide. The guide names the next requirement and gives direction, target and distance. It distinguishes guards, bosses, Sun Core/prism, cloud seed/loom/vow, hidden realm gateway, pearls, cockpit and exit. Using a locked gate shows its outstanding requirement. Level4's reported locked exit was the unfinished prism objective, not an instruction to remove the puzzle.

The native gate audit loads all100 routes, completes actual enemy/brood and pickup callbacks plus device activation, then checks each gate animation reaches open. The cockpit state is simulated in this broad audit; its dedicated sequence test covers inputs separately. This is an automated objective lifecycle audit, not100 manually completed combat runs.

Monster visual sizing now uses measured alpha bounds and full transform scale, including boss parent scaling. Normal bodies target120 world pixels high and bosses210, with width limits. Colliders, health bars and aquatic bounds use that size. Aquatic roots no longer allow whole sprites to project onto the pier.

The artist pass adds20 attack-specific warning glyphs, an original generated15-frame impact atlas across five elements, boss phase announcements, and12 original synthesized cast/contact sounds. Sounds respect mute and EnemyCombat volume, distance and eight-voice limits. These cover100 combined contracts with shared elemental art/sound families; they are not100 bespoke animation and audio sets.

World presentation: panoramic backgrounds use one unmirrored image with bounded parallax, removing center seams and duplicated castles/trees. Generated citadel balconies now use short attached corbels rather than suspension ropes ending in empty space. Source art and prompt are in assets/archive/armory-review.

Validated: armory purchase/save/consumption/retry, real level4 puzzle-to-open-gate,100 native gate lifecycles,100 monster size/audio cases,100 attack contacts, aquatic tests, background coverage, and native screenshots. The UI guide was reduced after visual inspection to avoid covering combat. Full campaign difficulty and handcrafted animation refinement remain playtest/production work.

Rams quick_review was attempted for inventory and objective UI with rules in context (the exposed tool has no via field). It returned ran:false because workspace credits are exhausted; no findings were available. Native UI review was completed.

Final build: self-contained local macOS app rebuilt and ad-hoc signature verified. Packaged level2 screenshot smoke test clean. Native stress sample on AppleM4/OpenGL with VSync disabled and fixed60Hz simulation: five representative levels with forced monster casts, median2.00–4.21ms and p95≤7.91ms. This is a local sample, not a guarantee on all hardware.
