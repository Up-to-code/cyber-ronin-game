# 100 enemy roster entries

The roster is 100 named combat variants across eight existing animated art families. It is not 100 separately drawn body sprites. Two subfamilies reuse guard/fire bodies with different proportions and palettes. All entries have stable IDs, runtime profiles, and generated role insignia that appear alongside the health bar only during telegraphs or close combat.

Ten behavior doctrines combine with the families:
- Pursuer: sustained chase pressure.
- Duelist: short recovery and retreat after striking.
- Bulwark: frontal light-attack armor; kick, power, charge and plunge bypass it.
- Bombardier: five-shot fan and retreat spacing.
- Deadeye: telegraphed laser with long recovery.
- Earthbreaker: paired ground projectiles and heavy windup.
- Berserker: once-only half-health speed, damage and windup change.
- Ambusher: telegraphed short dash with a cooldown and ledge check.
- Bloodmender: limited periodic healing, interrupted while hurt, capped at one-third maximum health per life.
- Warcaller: alternating laser/ground-attack cadence with ranged spacing.

Runtime hook: call apply_monster_profile(monster_id) after adding an enemy and applying campaign/boss stats. Boss health is not scaled by roster health multipliers. Route kind must match the roster kind so the base controller and visual profile agree.

Generated art: assets/monster-roster/roles-source.png, prompt in roles.prompt.txt, exported game/art/monster-roster/role0.png through role9.png. Built-in image_gen generated the atlas; deterministic processing only cropped/resized the individual icons and preserved alpha.

Validation: tests/monster_roster.gd loads all 100 profiles, checks 100 distinct identities, 10 behaviors, valid animation resources, armor bypass, one-shot enrage, healing and unchanged boss health. tests/capture_monster_roster.gd renders ten representatives in docs/qa/monster-roster-gallery.png.
