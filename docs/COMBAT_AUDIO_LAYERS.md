# Combat layers

Hove Audio's free pack has two standalone whooshes, not forty different empty swings. Keep movement cues timed independently from contacts. Second cut and kick add alternating effort; finisher/charged/heavy enemy swings use a separately indexed effort pool. Physical contact adds one of three gore takes, while hits of at least 45 damage add one of three ringing blade-contact takes. Armor retains its two metal variants. Spirit impacts retain magical rings. Five action voices and four damage voices rotate independently. Layers use the existing 12-voice budget and quieter gains. Combined whoosh/contact recordings remain imported but unused to avoid playing contact on a miss. No positional panning added in this pass.

Blood bursts now contain 24 ordinary or 38 heavy particles, including larger droplets and short streaks. Player damage emits the same directional contact presentation. Effects expire after 0.55 seconds. No damage or physics changes.

Research: Godot 2D particle documentation https://docs.godotengine.org/en/latest/tutorials/2d/particle_systems_2d.html and Kenney particle art https://kenney.nl/assets/particle-pack . These informed emitter/texture options; this pass retains the existing procedural pixel geometry, with no external art imported.

Validation: motion_audio_sync passed (contact timing, interruption, once-only motion cues). Subjective audio and visual feel still need play review.
