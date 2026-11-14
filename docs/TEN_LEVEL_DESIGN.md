> Route geometry below describes the earlier expansion. The current authored layouts and validation are in [LEVEL_REDESIGN.md](research/LEVEL_REDESIGN.md).

# Ten-level campaign

## Routes and encounter rhythm

1. Monastery Approach: broad causeway, moving bridge, three guards; learn movement and combos.
2. Ember Courtyard: raised terraces, fire keeper, flanking lancer and floating threat.
3. Bamboo Ramparts: alternating elevations, sentinel on a broad landing, spirits near later platforms.
4. Castle Rooftops: ascending roof route, optional stair ledges and a moving lift.
5. Broken Sanctuary: side stairs and mixed defenders; False Keeper boss, 320 HP and five-shot fire spread.
6. Crimson Castle Keep: shorter upper route with mixed ranged/melee pressure and elite keeper.
7. Sunken Cistern: deep alternating shelf descent, 1900-pixel world depth and camera tracking.
8. Bell Shaft: descent into a basin followed by a 70-pixel-step ascent.
9. Storm Aqueduct: broken piers; climb from y550 to390, descend to550, then climb to420. Lancer, wraith, sentinel and impostor occupy separate landings.
10. Oni Throne: four climbing terraces lead to broad arena floors and optional high ledges. Bell Tyrant boss has 520 HP, 30 melee damage, 20 projectile damage and two-direction ground fire on impact.

Boss placement follows the fifth-level rule in campaign data. Standard authored enemies gain six HP per preceding level. Boss health overrides that scaling. Early added guards preserve room around the player spawn.

## Feedback

Confirmed player hits add 0.28 camera trauma, capped at0.55; existing decay returns it to rest. Immunity prevents repeat damage feedback. Enemy-hit feedback remains separate. Attack and movement collision rules are unchanged by this camera effect.

## Next improvement steps

1. Complete real enclosing shaft-wall artwork and tune shelf spacing through a full descending playthrough.
2. Author distinct boss silhouettes plus matching idle, attack, hurt and death animations; current bosses reuse fire/sentinel art with tint.
3. Add a clearly telegraphed boss phase change, dedicated boss health display and encounter introduction.
4. Make moving sword attacks visibly use stepping footwork rather than only moving the body with an attack cel.
5. Finish coin persistence, pickup feedback and a small upgrade choice after boss levels.
6. Play all ten routes on a phone, measuring missed touches, camera occlusion and combat pacing; tune health/counts from that evidence.
7. Listen to each attack/contact sound against the animation and remove redundant layers.

These are implemented route layouts using existing terrain assets, not ten newly illustrated environment sets. Headless checks establish map validity and mechanics, not final difficulty or enjoyment. No complete human playthrough is claimed.
