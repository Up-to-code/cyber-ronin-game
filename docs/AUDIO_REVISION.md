# Audio revision — 2026-11-11

The user rejected the previous sword sounds and the OpenGameArt/StarNinjas source. Those files and the old drone music are removed from the runtime audio directory and service references. This revision uses original short effects and actual Japanese-instrument music from a different creator.

## Music source and required credit

[Free Japanese Fantasy Music Pack by Momiziba](https://momiziba.itch.io/free-japanese-music-pack) explicitly permits commercial use with attribution. Downloaded through the creator's itch.io download on 2026-11-11; public source terms are saved under `game/audio/music_source/SOURCE_TERMS.html`. The full source ZIP and original files stay private and are excluded from Godot import with `.gdignore`.

Required credit, including link when possible:

> Free Music : MOMIZizm MUSiC
> https://music.storyinvention.com/en/

Selected the composer's supplied loop exports without rearrangement, pitch changes, or arbitrary cuts:

| Game state | Composer track | Runtime file | Supplied loop length |
|---|---|---|---|
| Exploration, menus and cleared rooms | Mountain God's Shrine | `game/audio/exploration_music.ogg` | 148.4385 s |
| Nearby active enemies | Shamisen Samurai Rock | `game/audio/battle_music.ogg` | 111.5 s |

These are authored `*_Loop.ogg` versions rather than fading full-track versions. Godot enables full-file looping. `Audio.set_combat(bool)` crossfades the two players over 1.2 seconds. The parent game owns threat detection and its hysteresis; audio does not decide combat state.

## Current effects

`tools/audio_samurai_effects.py` deterministically generates nine original WAV files without any third-party samples. Effects use short filtered air/cloth, low contact energy and brief inharmonic steel overtones. A miss receives only blade air; confirmed damage receives the heavier contact. Jump no longer produces a rising tonal beep. Steps are quiet, rate-limited stone contact; land is heavier. Source effects peak at about -2.6dBFS before runtime attenuation.

| Cue | Runtime source | Level before master limiter |
|---|---|---|
| swing | katana_air.wav | -9 dB |
| impact | katana_contact.wav | -6 dB |
| jump | takeoff_cloth.wav | -15 dB |
| land | landing_stone.wav | -10 dB |
| step | step_stone.wav | -23 dB |
| dodge | dash_cloth.wav | -15 dB |
| hurt | body_hurt.wav | -10 dB |
| bell | shrine_bell.wav | -15 dB |
| ui | menu_wood.wav | -18 dB |

Exploration music target is -18dB; battle music target is -17dB. Contact/step pitch varies only ±4%. The master hard limiter retains its -1dB ceiling. A 12-voice pool favors meaningful effects over quiet footsteps when saturated.

## API compatibility

Preserved `Audio.play(cue)`, `set_enabled(bool)`, `enabled`, `music`, `streams`, `voices`, and `shutdown()`. `music` is the exploration player; `battle_music` is the second player. Added `set_combat(bool)`, `combat_active`, and `battle_mix`. `step` is the new actor cue. Muting pauses both music players and stops SFX; unmuting resumes the current mix. Headless tests load resources but skip dummy-driver playback.

## Verification

Godot editor import completed cleanly after all audio resources were written. A native CoreAudio test loaded all nine cues, triggered each effect, verified exploration-to-battle and back crossfades, verified muting both players, and measured a master output peak of approximately -6.05dB. No clipping was observed by that meter. This establishes playable non-silent output and state behavior; it is not a human preference or on-phone listening test.

No UI files were edited by the audio task. The parent game must include `MUSIC_CREDITS.txt` text in its Credits screen and call `set_combat(false)` during menus/loading, with threat-driven `set_combat(true)` during combat.
