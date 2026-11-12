# Ready stance and contact particles

Existing cel artwork now breathes on a 2.4-second cycle with a slower 4.8-second weight rhythm. Scaling remains anchored at the feet. Five low-opacity pixel ash motes loop while idle without allocating effect nodes. This is procedural presentation on existing cels, not newly drawn animation frames.

Contact bursts increased from 7/12 to 16/26 particles for ordinary/finisher hits, with directional spray, short dark-red trails and downward acceleration. Bursts expire after 0.48 seconds and retain the shared effect-node budget. Misses do not emit these contact bursts. No collision or damage changes.

Validation: combat_rules_combo passes, including idle foot anchoring, recoil/mass, buffered double attack and ground clearance. Native staged combat recording produced for visual review.
