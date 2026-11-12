# Double jump and combo feedback

Jump permits one additional airborne press, with a 90% height impulse; holding Jump does not repeat. Landing restores the air jump. Coyote time, jump buffering, variable release height, wall-aware dash and moving-platform carry remain in place. Walking off a ledge also leaves the single air jump available.

Attack taps chain `attack`, `attack2`, `attack3` from the existing character kit. Durations are 0.30/0.28/0.36 seconds, with contact after 0.09 seconds; animation playback is fitted to each duration. Damage is 35/35/45 and applies once per enemy per swing. One follow-up can be buffered; holding Attack never auto-fires. Combo expires 0.40 seconds after recovery. Hurt or dash interrupts it. Double-tapping left/right within 0.23 seconds requests the existing cooldown-limited dash toward that direction. All of these action inputs work through keyboard and touch buttons.

New effects reuse the generated slash/dust/impact sheets with authored timing and tint, plus small deterministic pixel-snapped motes: teal air-jump burst, alternating blade arc, larger finisher arc, hit sparks, landing chips, dash-start sparks and enemy defeat embers. No fullscreen flash or additional camera shake. Effects expire in 0.14–0.40 seconds with a 64-child limit. Double jump reuses the cloth takeoff cue at a higher pitch and quieter volume; no sustained new whoosh.

Validation: `tests/combo_air_jump.gd` covers the air-jump limit/recharge, buffered three-clip combo, exact once-per-strike damage, held-input behavior, directional double-tap attack cancellation and transient FX cleanup. Existing dash, locomotion, platforming, touch UI and native audio/contact tests pass. Native attack output measured -8.15 dB peak. The recording uses scripted input and stationary guards to show the new actions, not a full campaign playthrough. Physical phone feel remains untested.

The help UI was updated. Rams quick_review with `via=rules` was requested but returned `ran:false` because the workspace's review credits are exhausted.
