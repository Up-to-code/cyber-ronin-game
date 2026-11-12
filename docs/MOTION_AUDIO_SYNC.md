# Motion and sound synchronization

This pass changes timing and the envelopes of existing recorded Foley. It does not replace the entire sound library or music. No new third-party assets were shipped.

## Findings and repairs

The player and enemies started their motion sound at the damage/contact frame. A 5 ms RMS-window measurement found the main energy of the existing sword take at 95 ms, alternate at 70 ms, kick takes at 50/70 ms, reverse cut at 70 ms and finisher at 50 ms after playback started. These are recording-envelope measurements, not audio-device latency measurements.

Melee now starts once per action at `contact_seconds − measured_peak_seconds`. Timing uses the authored animation duration/contact point, the next variant and the fixed enemy pitch. Actual damage, collision and contact VFX stay at the authored contact. A cancelled attack has no queued timer to fire later. Projectile release cues remain on launch. At 60 Hz the emission is quantized to one simulation tick; the sword's ±4% pitch variation introduces a few extra milliseconds. Short clips clamp the start to zero.

Light landing's energy peak was 85 ms late, air jump 95 ms, kick contact 20–35 ms, sword impact 20 ms, and enemy cast 155 ms. The finalizer removes the pre-transient portion, retaining a 2 ms fade and a measured peak around 5 ms. Heavy landing already peaked near 5 ms and was retained. These are approximate transient alignments rather than claims about perceived quality.

Sentinel's missed swing previously played the body-hit recording. It now uses a lower-pitched movement recording; actual damage owns the body response.

## Evidence

- `game/tests/motion_audio_sync.gd`: actual player sword/kick/launch clocks, once-only cues, damage contact retained, interruption before sound, actual guard/lancer/sentinel/fire clocks and heavy miss role.
- Native `audio_combat` output check passed for all nine cues, charge cancellation and alternating swing takes; measured overall peak −10.54 dB.
- Six existing suites passed: audio_event_states, audio_palette, audio_roles, authored_contact, air_slash_energy, feedback_separation.
- `docs/qa/motion-audio-sync.mp4`: native engine recording at 60 FPS, with actual audio. Jump/air cut, missed kick, sword contact, kick contact, enemy swing/hurt contact and energy release. The sample uses staged enemy placement and extra health, not a full campaign playthrough.
- `docs/qa/motion-audio/contact-before-after.wav`: eight 1-second slots: landing before/after, air jump before/after, kick hit before/after, sword impact before/after; game cue gains applied.
- Captured event trace: `docs/qa/motion-audio/events.json`. Cue requests are logged before voice cooldown/pool acceptance; this trace is not proof that every request was audible.

The sample was checked for recorded audio, video frames and event order. No subjective listening judgment is claimed. Device speaker/headphone listening and the palette's artistic quality remain to be judged.

## Research applied

1. [CRYENGINE: Audio for animations](https://www.cryengine.com/tutorials/view/audio-and-music/audio-using-fmod-studio/article/audio-for-animations-fmod-studio-workflow-part-2), especially 7:20–11:41: animation events trigger Foley at authored points. Applied here as action-clock events rather than delayed callbacks.
2. [Jakob Schmid: INSIDE, Sonic College 2018](https://schmid.dk/talks/2018-03-05-sonic/schmid-Sonic_College_2018-INSIDE.pdf), slides 24–36 and 38–42: frame-specific events, context-dependent footsteps, geometry/speed-driven cloth. Applied: distinguish motion from contact/release; don't let a miss imply a collision. Geometry-driven continuous cloth is a future option, not implemented in this pass.
3. [FMOD: Working with instruments](https://www.fmod.com/docs/2.03/studio/working-with-instruments.html), multi-instruments and synchronization: variation reduces repetition, while playback timing and lifecycle need explicit control. Existing alternation is retained and its next take is used for timing. No FMOD dependency was added.

The peak-compensation strategy is our implementation inference from the animation-event principle, not a numerical prescription in those sources.

## Rebuild

Run existing `tools/build_audio_audition.py` and `tools/build_event_audio.py` first if rebuilding the source edits. Then run `.pixel-tools/bin/python tools/build_motion_audio.py`, followed by Godot's asset import. The finalizer archives its original inputs under `docs/qa/motion-audio/*-before.wav` and rebuilds from them deterministically. Delete/update those archived inputs deliberately when changing source recordings. `game/data/audio_timing.json` is generated from the final WAVs.
