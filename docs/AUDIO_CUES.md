# Combat audio plan

Current revision: the rejected sword pack and old drone are replaced. See `AUDIO_REVISION.md`, `LOCOMOTION.md` and `CASTLE_MAPS.md` for the six-map castle campaign and current audio. Earlier source listings below are historical.

Candidates have not yet been auditioned against the imported animations. These cue names are planned events, not claims about filenames in a pack.

| Event | Sound selection | Playback trigger |
|---|---|---|
| Light attack | Short dry sword whoosh, alternate 2–3 takes | Blade begins its active motion |
| Heavy attack | Weightier longer whoosh | Heavy blade release, after wind-up |
| Confirmed damage | Short impact/body layer | Successful damage event only |
| Block | Muted metal clash | Block resolves |
| Perfect parry | Bright metal clash plus brief accent | Parry resolves inside timing window |
| Miss | Whoosh only | No hit confirmation |
| Dodge | Quiet cloth/air candidate | Dodge starts |
| Footstep/landing | Stone or wood variations | Foot contact/landing event |
| Exit unlock | Low bell/chime | Encounter clear, once |
| UI select/confirm | Restrained click/chime | UI interaction |

At attack animation events, schedule the swing cue; play impacts from damage resolution. A nominal 17 FPS attack has frames approximately 59 ms apart, but use the actual resource durations and identify the blade-contact frame visually. Never invent a shared contact frame for all animations. Avoid restarting sounds every physics tick. Limit simultaneous voices and add small random variation after audition.

Audio buses: Master, Music, SFX, UI, Ambience. Use WAV for short responsive effects and OGG for streamed music. Set loop boundaries by listening; loop tags from other engines may need explicit Godot import settings. Combat may crossfade between calm and battle tracks, but the game should not require beat-synchronized attacks. Music should leave room for attack telegraphs and parries.
