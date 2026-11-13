# Movement combat and campaign playtest

J attacks now follow A/D facing during windup, contact and recovery. The attack drive follows current input rather than pushing in the old facing direction. Each moving/aerial combo has four distinct authored clips. Holding a horizontal direction for at least 0.28 seconds selects the committed drive combo. Releasing movement and allowing the combo to expire restores the standing first strike. Hit queries use the facing displayed at contact.

Two subagents supplied the 100-entry monster roster and redesigned 100-route campaign. The roster combines eight existing animated body families with ten combat doctrines and generated role insignia. It is not 100 independently drawn animated bodies. Routes have distinct geometry and encounter rhythms; existing environmental artwork is reused.

Native footage: [moving J attacks](qa/moving-sword.mp4). Screenshots include route-redesign-1/17/42/88.png, monster-roster-gallery.png and packaged-playtest.png.

Validation: moving_sword_facing, moving_combat, combat_expansion, player_polish, sequence_machine, monster_roster, monster_projectile_roles, campaign_data, redesigned_campaign and hundred_level_campaign. The route agent also passed 738 physics jump/landing transitions over all100 levels; these use injected starts and do not constitute full combat playthroughs.

Build with `python3 scripts/build_local_macos.py`. Output: `dist/AshenVeil-Playtest.app`. The self-contained local development app bundles the installed Godot4.7.2 runtime plus an exported PCK because release export templates are unavailable. It is locally ad-hoc signed, not notarized for public distribution. The packaged app passed a headless level11 smoke run and a native rendered launch.
