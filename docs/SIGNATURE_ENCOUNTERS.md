# Singular encounters

This pass replaces four repeated patrol maps with bespoke encounters. Each signature is placed once, and replaces the monster's generic ranged power/doctrine. Other campaign enemies still share base combat roles and existing artwork.

| Level | Encounter | Rule | Counter | Arena purpose |
| --- | --- | --- | --- | --- |
| 12 | Mirror Scriptorium | Attacking leaves a delayed strike at your old position | Move after swinging | Long escape runway with upper relief ledges |
| 24 | The Severed Thread | A knot pulls you back when you stray too far | Cut near the knot with J or dash free | Broad tether arena and split elevation approaches |
| 37 | Glass Vow Duel | Guard rejects attacks outside recovery | Bait a committed strike or kick to open the guard | Isolated duel plinth and retreat crossing |
| 58 | Garden of Sleeping Embers | Footsteps arm planted ground hazards | Jump the delayed bloom or use upper trellises | Split ground sections and overhead bypass |

Implementation uses existing pixel art and distinct telegraph behavior, not four new body animations. The generated campaign script applies these explicit layouts after constructing the other routes, so regeneration preserves them.

Validation: signature_encounters.gd tests unique placement and the four counters; campaign_data and redesigned_campaign pass; authored_routes verifies 724 actual jump/landing transitions across100 routes from injected starts. Native rendered captures are docs/qa/signature-12.png, signature-24.png, signature-37.png and signature-58.png. This is not a full combat playthrough of all100 levels. Rams was attempted for world-space hints but review credits were exhausted.
