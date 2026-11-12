# Current audio revision

The rejected OpenGameArt/StarNinjas sword samples are no longer referenced or used. Current SFX are original synthesis from `tools/audio_samurai_effects.py`: short blade air, weighty contact, cloth takeoff/dash, stone landing/steps, body hurt, shrine bell and wood UI cue. No sampled sounds from that source remain in the runtime set.

Music is the composer's supplied loop exports from Momiziba's Free Japanese Fantasy Music Pack: Mountain God's Shrine for exploration and Shamisen Samurai Rock for combat. Commercial use is permitted with the credit in MUSIC_CREDITS.txt. Include that credit in the game's Credits menu and distributions. Original downloads/terms are private in music_source/ and excluded from Godot import with .gdignore.

systems/audio.gd provides play(cue), set_enabled(bool), set_combat(bool), and shutdown(). `music` remains the exploration AudioStreamPlayer for compatibility; `battle_music` is the combat player. A 1.2-second equal-amplitude crossfade keeps the exploration track running while the battle layer enters. On exit, battle fades out and stops. Muting pauses both music players and clears SFX.

Runtime effect cue names: swing, impact, jump, land, step, dodge, hurt, bell, ui. Use step only at a grounded movement cadence; it is rate-limited and deliberately quiet. Audio is not played through the headless dummy driver. Master hard limiter remains at -1dB.
