# Audio comparison, not a claim of preference

The previous iteration changed cue mappings but still layered the original synthesized `katana_contact.wav` under recorded hits. That contradicts the intended recorded-material palette. This pass removes the hidden layer and prepares short edited recordings with a defined role.

## Listen to the A/B reel

[24-second comparison](qa/audio-audition/comparison.wav). Each effect has 1.2 seconds for A (previous) followed by 1.2 seconds for B (current candidate). Silence after a short sound is intentional. These are cue-level excerpts at the configured gain, not a full gameplay mix. No narration masks the sounds.

| Time | Event | A/B |
|---|---|---|
| 0–1.2 / 1.2–2.4 | Jump | Previous cloth / short ground push-off |
| 2.4–3.6 / 3.6–4.8 | Kick motion | Previous raw cloth / trimmed, filtered cloth |
| 4.8–6 / 6–7.2 | Sword motion | Previous raw cloth / short high-frequency cloth sweep |
| 7.2–8.4 / 8.4–9.6 | Kick contact | Previous raw body hit / short low-mid body thud |
| 9.6–10.8 / 10.8–12 | Sword contact | Previous raw hit / short midrange impact |
| 12–18 | Earlier music | Previous exploration track excerpt |
| 18–24 | Current music | Moonlight Japanese Harp excerpt |

Music is retained from the last pass rather than blindly replaced again. Samples are private project review excerpts under the existing composer license; do not redistribute them as standalone stock music. Full terms and attribution remain in `game/audio/MUSIC_CREDITS.txt`.

## Candidate rationale and limits

- Jump initiation should communicate the boot leaving the surface, not a large wind rush. The new 110ms cue uses the existing CC0 footstep recording.
- Air jump remains a short cloth movement, distinct from landing.
- Kick motion is separate from its confirmed-hit thud. Two edited variations remain available.
- Sword motion emphasizes higher frequencies than kick contact, with bounded duration.
- Confirmed hits now use one designed cue, removing the old synthesized secondary layer. This avoids contradictory timbre and unplanned peak buildup.

`tools/build_audio_audition.py` deterministically creates these filtered/cropped recordings and the comparison. Sources are existing Kenney RPG Audio and Impact Sounds; CC0 license files remain under `game/licenses`. No synthesized noise or new unlicensed recordings are introduced.

## Research

[Kenney Impact Sounds](https://kenney.nl/assets/impact-sounds) and [RPG Audio](https://kenney.nl/assets/rpg-audio) provide the licensed material already installed. [Audiokinetic's Adventure sound-design guide](https://www.audiokinetic.com/download/documents/WwiseProjectAdventure_en.pdf) distinguishes sound sets by weapon/event roles. [Sonniss GDC bundles](https://gdc.sonniss.com/gdc-game-audio-bundle/) are an alternative professional source researched, not downloaded: the large bundles are unsuitable for the remaining local disk space and individual usable candidates have not been auditioned.

The changes are defensible by event role and measurable duration, not proven to sound better. Subjective listening, synchronization in normal play, phone speaker response and user preference remain unverified. The A/B reel makes that judgment concrete instead of hiding it behind passing code checks.
