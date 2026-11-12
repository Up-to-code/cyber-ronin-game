# Combat feedback research and repair

## Evidence before editing

The kick event selected the impact sprite family even when the kick missed. This visually reported contact with empty air. Confirmed enemy hits already emitted their own event, so the appropriate repair was to distinguish motion arcs from contact bursts. All twelve SFX voices shared Master with music; when full, the allocator could replace an important hit with a lower-priority cue. The mix had no transient space for contact sound.

## Primary references and design decisions

- [Godot audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) describes independent routing, effect chains and avoiding digital clipping. Added separate Combat and Music buses while retaining the master ceiling. Hit cues momentarily lower music by 3.5 dB and recover over approximately 0.3 seconds. These values are project tuning, not universal recommendations.
- [Audiokinetic Project Adventure](https://www.audiokinetic.com/download/documents/WwiseProjectAdventure_en.pdf) separates swings/impacts and discusses combat variation. Existing three-sample swing/contact pools remain, with limited pitch variation. A quiet material transient accompanies confirmed sword contact and a body layer accompanies confirmed kick contact. Misses never play these contact layers.
- [Sound on Sound: Sound Design for Visual Media](https://www.soundonsound.com/techniques/sound-design-visual-media-radio) discusses constructing combat impact layers. Its search excerpt was available; direct retrieval returned 403. Used as corroborating background, not as a detailed implementation specification.

## Implemented behavior

Kick now draws a short slash-family motion arc; confirmed impact adds a brief expanding pixel contour and the existing sparks. Heavy contacts have a wider contour. Double-jump and plunge contours are flattened at the event position, separate from the character. All contours expire after 220 ms. No persistent full-screen flashes or extra camera shake were added. The existing 64-node effect budget remains; contact audio is protected from voice stealing by low-priority cues. Music remains the licensed composer loops; this is a mix/event repair, not a new composition or replacement of all samples.

## Validation and limits

Headless `audio_combat.gd`, `effects.gd` and `feedback_separation.gd` pass: assets decode, cue variations exist, attacks emit effects, misses differ from contacts, effect nodes expire, and buses route independently. Native `audio_combat.gd` verifies output and cancellation; measured per-cue output ranged from approximately -38.5 to -9.9 dB, with the loudest tested cue below clipping. This is an output test, not a perceived-loudness or aesthetic listening verdict. Continuous gameplay sound and phone-speaker balance still need human audition; no claim that sound preference is solved.
