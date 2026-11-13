# Campaign route redesign

The runtime now consumes 100 individually sequenced route scores from `scripts/redesign_campaign.py`. These replace chapter-scaled copies of ten templates. Rebuild with `python3 scripts/redesign_campaign.py`; the earlier `build_campaign.py` and `author_vertical_routes.py` scripts describe the superseded template pipeline.

Each score orders safe arrivals, recovery landings, duel decks, mixed arenas, bridges, ranged terraces, chokes and exit sanctuaries. Chapter contours, gap patterns and branch modes vary independently. There are 176 optional landings, 30 optional one-way shuttles, and 432 encounter actors. Every roster ID 1–100 appears. Bosses remain on levels 10/20/.../100; level 11 retains its sentinel cockpit and its first two familiar landings.

Validation: `campaign_data.gd` checks supports/bounds/route connectivity; `redesigned_campaign.gd` rejects duplicate translated route signatures, verifies roster coverage and branch/lift declarations; `authored_routes.gd` passed 738 real physics jump/landing transitions over all 100 routes using injected starts. The traversal harness holds movement until the landing, and drops through optional overhead branches when testing the lower route. This is traversal validation, not a complete combat playthrough or proof of finished balancing.

The existing environment art is reused. This change supplies new route layouts and encounters, not 100 newly painted backgrounds.

| Level | Name | Route score | Primary / optional landings | Shuttles | Encounter actors |
|---|---|---|---|---|---|
| 1 | Monastery Approach | `srdratre` | 8 / 2 | 0 | 4 |
| 2 | Broken Bell Steps | `sdrbtdre` | 8 / 2 | 0 | 3 |
| 3 | Three-Seal Crossing | `sbrdarce` | 8 / 2 | 0 | 4 |
| 4 | Ember Switchback | `strdbrte` | 8 / 1 | 1 | 3 |
| 5 | The Empty Watch | `sdrtarde` | 8 / 2 | 0 | 5 |
| 6 | Split Patrol | `sbdrcatre` | 9 / 2 | 0 | 5 |
| 7 | Roof of Ash | `strbdare` | 8 / 2 | 1 | 4 |
| 8 | Silent Causeway | `sdrcrbte` | 8 / 1 | 0 | 3 |
| 9 | Marked at Dusk | `sbrtdacre` | 9 / 2 | 1 | 5 |
| 10 | Oni Throne | `srdbrtae` | 8 / 2 | 0 | 5 |
| 11 | Lantern Marsh — First Watch | `srdtbrade` | 9 / 2 | 0 | 5 |
| 12 | Lantern Marsh — Reed Crossing | `sbrtrdce` | 8 / 2 | 0 | 3 |
| 13 | Lantern Marsh — Three Reliquaries | `sdrbarte` | 8 / 1 | 0 | 4 |
| 14 | Lantern Marsh — The Switchback | `strdcbre` | 8 / 2 | 1 | 3 |
| 15 | Lantern Marsh — Fallen Guardhouse | `sbdtrare` | 8 / 2 | 0 | 4 |
| 16 | Lantern Marsh — Split Watch | `srtbdrce` | 8 / 2 | 0 | 3 |
| 17 | Lantern Marsh — High Sanctuary | `sdbrtace` | 8 / 1 | 1 | 5 |
| 18 | Lantern Marsh — Broken Causeway | `stardbre` | 8 / 2 | 0 | 4 |
| 19 | Lantern Marsh — The Pursuit | `sbrdctare` | 9 / 2 | 1 | 5 |
| 20 | Lantern Marsh — Throne Approach | `sbtrdrae` | 8 / 2 | 0 | 5 |
| 21 | Iron Ramparts — First Watch | `sctrdare` | 8 / 2 | 0 | 5 |
| 22 | Iron Ramparts — Reed Crossing | `sdcrbte` | 7 / 1 | 0 | 3 |
| 23 | Iron Ramparts — Three Reliquaries | `sbrctadre` | 9 / 2 | 0 | 5 |
| 24 | Iron Ramparts — The Switchback | `stcdrbre` | 8 / 2 | 1 | 3 |
| 25 | Iron Ramparts — Fallen Guardhouse | `scrdatre` | 8 / 2 | 0 | 5 |
| 26 | Iron Ramparts — Split Watch | `sdtcrabe` | 8 / 1 | 0 | 5 |
| 27 | Iron Ramparts — High Sanctuary | `scbrdtare` | 9 / 2 | 1 | 5 |
| 28 | Iron Ramparts — Broken Causeway | `strcadre` | 8 / 2 | 0 | 5 |
| 29 | Iron Ramparts — The Pursuit | `sdctbrare` | 9 / 2 | 1 | 5 |
| 30 | Iron Ramparts — Throne Approach | `sctbrdae` | 8 / 1 | 0 | 6 |
| 31 | Cinder Aqueduct — First Watch | `sbrbrdte` | 8 / 1 | 0 | 2 |
| 32 | Cinder Aqueduct — Reed Crossing | `strbdrbe` | 8 / 2 | 0 | 2 |
| 33 | Cinder Aqueduct — Three Reliquaries | `sbdrbtare` | 9 / 2 | 0 | 4 |
| 34 | Cinder Aqueduct — The Switchback | `srbtdbre` | 8 / 2 | 1 | 2 |
| 35 | Cinder Aqueduct — Fallen Guardhouse | `sbtbrdce` | 8 / 1 | 0 | 3 |
| 36 | Cinder Aqueduct — Split Watch | `sdrbtbre` | 8 / 2 | 0 | 2 |
| 37 | Cinder Aqueduct — High Sanctuary | `sbtrbdare` | 9 / 2 | 1 | 4 |
| 38 | Cinder Aqueduct — Broken Causeway | `strbcrde` | 8 / 2 | 0 | 3 |
| 39 | Cinder Aqueduct — The Pursuit | `sbrtdbrce` | 9 / 1 | 1 | 3 |
| 40 | Cinder Aqueduct — Throne Approach | `sbtrbdae` | 8 / 2 | 0 | 5 |
| 41 | Hollow Cistern — First Watch | `stdcrbre` | 8 / 2 | 0 | 3 |
| 42 | Hollow Cistern — Reed Crossing | `srctbdare` | 9 / 2 | 0 | 5 |
| 43 | Hollow Cistern — Three Reliquaries | `sdtrcbre` | 8 / 2 | 0 | 3 |
| 44 | Hollow Cistern — The Switchback | `sbrcdrte` | 8 / 1 | 1 | 3 |
| 45 | Hollow Cistern — Fallen Guardhouse | `strdcare` | 8 / 2 | 0 | 5 |
| 46 | Hollow Cistern — Split Watch | `sctrbdre` | 8 / 2 | 0 | 3 |
| 47 | Hollow Cistern — High Sanctuary | `srdctabre` | 9 / 2 | 1 | 5 |
| 48 | Hollow Cistern — Broken Causeway | `stcbrdare` | 9 / 1 | 0 | 5 |
| 49 | Hollow Cistern — The Pursuit | `sdrctbre` | 8 / 2 | 1 | 3 |
| 50 | Hollow Cistern — Throne Approach | `stcrbdae` | 8 / 2 | 0 | 6 |
| 51 | Storm Monastery — First Watch | `srbtcdre` | 8 / 2 | 0 | 3 |
| 52 | Storm Monastery — Reed Crossing | `sctbrdare` | 9 / 2 | 0 | 5 |
| 53 | Storm Monastery — Three Reliquaries | `sbdrctre` | 8 / 1 | 0 | 3 |
| 54 | Storm Monastery — The Switchback | `strbcadre` | 9 / 2 | 1 | 5 |
| 55 | Storm Monastery — Fallen Guardhouse | `sbdctrbe` | 8 / 2 | 0 | 3 |
| 56 | Storm Monastery — Split Watch | `scrtbdae` | 8 / 2 | 0 | 5 |
| 57 | Storm Monastery — High Sanctuary | `stbrdcre` | 8 / 1 | 1 | 3 |
| 58 | Storm Monastery — Broken Causeway | `sdrbctare` | 9 / 2 | 0 | 5 |
| 59 | Storm Monastery — The Pursuit | `sctrbdare` | 9 / 2 | 1 | 5 |
| 60 | Storm Monastery — Throne Approach | `srctbdae` | 8 / 2 | 0 | 6 |
| 61 | Crimson Gardens — First Watch | `strarbre` | 8 / 2 | 0 | 3 |
| 62 | Crimson Gardens — Reed Crossing | `sbdartre` | 8 / 1 | 0 | 4 |
| 63 | Crimson Gardens — Three Reliquaries | `srtdabre` | 8 / 2 | 0 | 4 |
| 64 | Crimson Gardens — The Switchback | `stdarcre` | 8 / 2 | 1 | 5 |
| 65 | Crimson Gardens — Fallen Guardhouse | `srbadtre` | 8 / 2 | 0 | 4 |
| 66 | Crimson Gardens — Split Watch | `sdtarbre` | 8 / 1 | 0 | 4 |
| 67 | Crimson Gardens — High Sanctuary | `sartbdre` | 8 / 2 | 1 | 4 |
| 68 | Crimson Gardens — Broken Causeway | `strbdacre` | 9 / 2 | 0 | 5 |
| 69 | Crimson Gardens — The Pursuit | `sbratdcre` | 9 / 2 | 1 | 5 |
| 70 | Crimson Gardens — Throne Approach | `strabdae` | 8 / 1 | 0 | 7 |
| 71 | Obsidian Keep — First Watch | `sdcartre` | 8 / 1 | 0 | 5 |
| 72 | Obsidian Keep — Reed Crossing | `scrdtabe` | 8 / 2 | 0 | 5 |
| 73 | Obsidian Keep — Three Reliquaries | `sdtcarbe` | 8 / 2 | 0 | 5 |
| 74 | Obsidian Keep — The Switchback | `sctardre` | 8 / 2 | 1 | 5 |
| 75 | Obsidian Keep — Fallen Guardhouse | `sdcratre` | 8 / 1 | 0 | 5 |
| 76 | Obsidian Keep — Split Watch | `srdactbe` | 8 / 2 | 0 | 5 |
| 77 | Obsidian Keep — High Sanctuary | `scdbrtare` | 9 / 2 | 1 | 5 |
| 78 | Obsidian Keep — Broken Causeway | `sdtarcbre` | 9 / 2 | 0 | 5 |
| 79 | Obsidian Keep — The Pursuit | `scratdbe` | 8 / 1 | 1 | 5 |
| 80 | Obsidian Keep — Throne Approach | `sdcatbrae` | 9 / 2 | 0 | 8 |
| 81 | Eclipse Ascent — First Watch | `stbrtcre` | 8 / 2 | 0 | 3 |
| 82 | Eclipse Ascent — Reed Crossing | `scrtbdrte` | 9 / 2 | 0 | 4 |
| 83 | Eclipse Ascent — Three Reliquaries | `sbtcrtre` | 8 / 2 | 0 | 3 |
| 84 | Eclipse Ascent — The Switchback | `strcbdrte` | 9 / 1 | 1 | 4 |
| 85 | Eclipse Ascent — Fallen Guardhouse | `sctbrtre` | 8 / 2 | 0 | 3 |
| 86 | Eclipse Ascent — Split Watch | `srtcbdrte` | 9 / 2 | 0 | 4 |
| 87 | Eclipse Ascent — High Sanctuary | `sbrtctrde` | 9 / 2 | 1 | 4 |
| 88 | Eclipse Ascent — Broken Causeway | `stcrbtre` | 8 / 1 | 0 | 3 |
| 89 | Eclipse Ascent — The Pursuit | `scrtbdtre` | 9 / 2 | 1 | 4 |
| 90 | Eclipse Ascent — Throne Approach | `stcrbtrae` | 9 / 2 | 0 | 6 |
| 91 | The Last Bell — First Watch | `sdractbre` | 9 / 2 | 0 | 5 |
| 92 | The Last Bell — Reed Crossing | `scbrtadre` | 9 / 2 | 0 | 5 |
| 93 | The Last Bell — Three Reliquaries | `stracbdre` | 9 / 1 | 0 | 5 |
| 94 | The Last Bell — The Switchback | `sbdcratre` | 9 / 2 | 1 | 5 |
| 95 | The Last Bell — Fallen Guardhouse | `srtacbdre` | 9 / 2 | 0 | 5 |
| 96 | The Last Bell — Split Watch | `scdrbatre` | 9 / 2 | 0 | 5 |
| 97 | The Last Bell — High Sanctuary | `sbractdre` | 9 / 1 | 1 | 5 |
| 98 | The Last Bell — Broken Causeway | `stdcbarre` | 9 / 2 | 0 | 5 |
| 99 | The Last Bell — The Pursuit | `scbradtare` | 10 / 2 | 1 | 7 |
| 100 | The Last Bell — Throne Approach | `srdctbrae` | 9 / 2 | 0 | 6 |
