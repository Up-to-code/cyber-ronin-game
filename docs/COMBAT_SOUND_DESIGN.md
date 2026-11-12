# Combat sound revision

Original samples generated with `tools/audio_combat_layers.py`; no downloaded library sounds or composer stems were modified. Added files total roughly 230 KB of 44.1 kHz mono PCM16. This is authored synthesis, not a recording of a real sword or a claim that the player has approved the sound.

Design references:

- [Tsugi: Medieval Weapons Sound Design 1](https://tsugi-studio.com/blog/2022/01/27/medieval-weapons-in-gamesynth-part-1/) separates low-weight/air layers for swings and damped modal resonances for contact. Here, short twice-filtered air/cloth envelopes are separated from low-mid contact and damped inharmonic steel.
- [CRI Middleware: Elemental Weapons](https://blog.criware.com/index.php/2023/12/09/elemental-weapons/) describes separate weapon/element layers with variation. Here, ordinary swings and contact cycle three samples; the supernatural power release has a short harmonic halo while normal misses remain fabric/air only. Sample libraries and middleware projects were not downloaded.

Event mapping:

| Cue | Meaning | Duration | Runtime level |
| --- | --- | --- | --- |
| swing | Ordinary blade motion; three variants | 0.115–0.127 s | -15 dB |
| impact | Confirmed sword contact; three variants | 0.19 s | -6 dB |
| kick | Fabric/leg motion, including a miss | 0.13 s | -15 dB |
| kick_hit | Confirmed kick contact; body instead of steel | 0.16 s | -8 dB |
| charge | Quiet rising anticipation | 0.52 s max | -22 dB |
| charged_swing | Heavy blade air/cloth release | 0.24 s | -12 dB |
| power | Supernatural release, not a false target hit | 0.34 s | -12 dB |
| aerial_land | Landing stone/sole/debris | 0.26 s | -12 dB |
| power_empty | Quiet dry unavailable tick | 0.052 s | -24 dB |

All sounds have attack/tail fades and DC removal. The heavier actions have longer low-mid envelopes rather than a louder sustained hiss. Charge is a one-shot; `Audio.stop_cue("charge")` must be called on release/cancel. Audio voices record cue metadata so cancelling charge does not cut other actions. Existing master limiter and composer music crossfade remain intact.

Validation: script regeneration succeeded; Godot import completed (new preloads require first import before a clean second parse). Native isolated audio probe produced all new cues, verified charge cancellation and alternating swing samples. Per-cue output ranged from about -34.3 dB for the dry unavailable tick to -9.94 dB for contact; this isolated check stopped music and is not a full battle-mix loudness assessment. Source peaks are at most -3.74 dBFS before runtime gain. Physical phone speaker/headphone preference remains untested.
