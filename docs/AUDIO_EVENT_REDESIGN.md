# Landing, attack and defeat event redesign

The prior pass changed timbre but still used one landing cue at every fall speed and one motion sound for all three sword attacks. This pass makes event roles explicit.

- Landing below550px/s uses a light boot-settle recording; faster landing uses a longer, lower body/ground thud. Plunge retains its dedicated impact. A stale `attack_kind=plunge` no longer suppresses ordinary landing sounds after an earlier plunge.
- Sword contact phases select light sweep, reverse sweep and finisher sweep cues. These are separate edited cloth recordings with distinct duration/filtering, not a random raw recording substituted for the same action.
- Enemy blade and fire releases use separate edited recordings rather than sharing player power release.
- Lethal damage triggers a single short low defeat cue, stops active combat voices, suppresses later battle sounds and fades music down. Retry/title restore the music state with fade-in. HUD delay does not delay the death sound.

Sources remain the installed CC0 Kenney RPG Audio and Impact Sounds recordings; original license files stay in `game/licenses`. `tools/build_event_audio.py` reproduces the edits. Defeat is a pitched/echoed recorded soft impact, not a generated melody or unlicensed music.

Research: [Audiokinetic Dynamic Mixing](https://media.gowwise.com/EducatorPortal/2024-10-01_Workshop_DynamicMixing.pdf) describes parameter-driven intensity and priority mixing. [Wwise Project Adventure](https://www.audiokinetic.com/download/documents/WwiseProjectAdventure_en.pdf) discusses grouping weapon/material/event sounds. These justify event separation and speed-dependent landing, not a claim of subjective audio quality.

`audio_event_states` verifies actual combo event progression, landing-tier selection, distinct enemy streams, once-only defeat, music attenuation and audio restoration. Native `audio_combat` verifies playback/mixing. Hearing suitability on speakers and user preference remain unverified.
