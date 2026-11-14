# Authored monster body-state ownership

MonsterContract now interprets windup, strike and recovery from its authored clock. Enemy movement and both drawn-cel and legacy motion presentation consume that body state. The enemy still mirrors remaining durations for existing native AI checks and compatibility fixtures; it no longer calculates authored phase durations itself. The contract phase used by existing observers is derived from the same interpretation.

Native/signature attacks retain their timer implementation behind the actor's action-body seam. Hurt/death still override attack presentation. An authored action ending no longer exposes a stale recovery snapshot through that seam.

Travelling-effect contact remains on the existing event timeline. All ten boss identities can contact after body commit ends; these contacts were preserved rather than forced into the strike window. Event scheduling, paths, damage and locked aim were not changed. Physics update order remains the existing order.

Nine suites passed: authored_body_state, monster_attack_clock, monster_ai_timing, monster_cel_animation, monster_death_support, individual_contracts, aquatic_enemies, signature_encounters and underwater_integration. The new test advances actual action/actor methods for all 100 identities and checks the renderer against the authoritative snapshot without manufacturing actor attack timers. It covers all ten delayed boss contacts, interruption and end cleanup. It is a stepped integration test, not 100 human combat playthroughs. Existing natural-AI initiation and full contact tests also passed.

The older signature test assumed exactly four unique placements in authored routes. It now validates any authored signature names and separately exercises all four supported rule fixtures; it does not assert the current campaign contains those placements.

Native staged boss-10 tell/commit/recovery captures were produced; commit was visually inspected. Five short Apple M4 stress samples: medians 6.06–10.18 ms, p95 11.03–12.79 ms. These samples do not guarantee every encounter or machine. AI/individual-contract suite teardown still reports 12–16 ObjectDB instances; no script errors or failing assertions remain in the final run.

The local macOS playtest is rebuilt with deep/strict signature verification. CONTEXT.md records Authored action and Body phase. No UI files were edited in this refactor. Existing route, armory and menu work was retained.

Packaged native level-10 startup smoke passed without reported script errors.
