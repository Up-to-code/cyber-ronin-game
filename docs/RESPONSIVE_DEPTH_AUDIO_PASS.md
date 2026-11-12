# Responsive controls, depth and sound comparison

The repeated feedback exposed two different validation gaps: controls were checked for overlap but not excessive screen coverage; audio was checked for playback/clipping but not the perceived suitability of each cue. Neither kind of test certifies taste or enjoyment.

[Apple's game guidance](https://developer.apple.com/design/human-interface-guidelines/designing-for-games/) recommends platform-appropriate input and customization. Its44pt iOS minimum describes touch targets in platform points, not a72-unit Godot square multiplied by viewport stretch. [WWDC24 game-control guidance](https://developer.apple.com/videos/play/wwdc2024/10085/) discusses thumb placement, feedback and reducing unnecessary controls. The responsive repair treats visible face and interactive region separately, retains safe-area bounds, and adds smaller preferences rather than forcing enlargement only.

Architecture is now displayed at82% of its previous height and lower contrast, with the distant mountains moving more slowly. Ground has a shallow irregular cut face under its walkable cap and a darker deep foundation. Sky drift is reduced from4.5 to0.8 logicalpixels/second; camera-relative response remains. The entire sky image contains the moon, so this is still a limited baked sky rather than separately animated moon/cloud artwork.

Audio comparisons should be heard in context and on phone speakers before calling them approved. The audition artifact explicitly preserves old/proposed examples; waveform and clipping checks are technical evidence only.
