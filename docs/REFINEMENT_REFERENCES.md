# Reference-led refinement

Reviewed the user's HUD crop, current runtime, and publisher screenshots from Katana ZERO, Dead Cells and Celeste. Reference images are local research material, not runtime art.

- Katana ZERO publisher reference: https://store.steampowered.com/app/460950/Katana_ZERO/ — directional attack trails and strong readable actor silhouette.
- Dead Cells publisher reference: https://store.steampowered.com/app/588650/Dead_Cells/ — continuous masonry and clear walking edges. New generated terrain uses straight ends and tiled foundation instead of repeated rock islands.
- Celeste publisher reference: https://store.steampowered.com/app/504230/Celeste/ — short pose echoes that make dash direction visible. This game's horizontal samurai dash remains its own mechanic.
- Maddy's first-person physics article: https://www.maddymakesgames.com/articles/celeste_and_towerfall_physics/index.html — actors should not overlap solids and moving platforms must carry/push predictably. This project retains Godot CharacterBody2D/AnimatableBody2D, not the article's custom engine.
- Godot movement reference: https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html — move_and_slide handles wall/floor collisions.
- Godot tiled panels: https://docs.godotengine.org/en/stable/classes/class_ninepatchrect.html — used to tile generated masonry at native texture scale.
- Foley category reference: https://www.asoundeffect.com/sound-library/epic-swish-whoosh/ — distinguishes natural weapon/cloth whooshes from designed/flame/large whooshes. No library sounds were bought, downloaded or used. The new original dash/swing sounds use short, low-passed cloth transients, not sustained hiss.

HUD findings derive from the user's crop: four centered lines plus a large ornamental meter crowd the upper combat view. Repair: left-aligned compact HP with a narrow generated-art meter; center stage on one line; no duplicate current/max row; gate status only a brief toast and nearby interaction button. Publisher screenshots selected here do not establish a matching HUD layout; this is an authored adaptation to the user's feedback.

Generated raw art and prompts: assets/art/pixel/refinement. Processor: tools/process_refined_art.py. Audio source: tools/audio_dash_revision.py. Existing music and license credits remain intact. The new raw graphics were generated with the built-in image tool; scripts only split, crop, resize and quantize.

Dash contract: 0.16s locked horizontal burst, pose held during the burst, short fading character snapshots, wall stop, short invulnerability, buffered input, gravity resumes afterward. It cancels an active attack. Dash may cross a short gap; it is not restricted to the ground. Confirmed hits receive a small spark; misses receive blade air and a slash only. New VFX are smaller and shorter, with no flame-like hit cloud.

Tests: dash direction/held pose, cooldown, trail bound, invulnerability, wall collision and air recovery; campaign route loading and representative jumps; locomotion, simultaneous touch, native contact/VFX/audio and rendered layout checks. These establish behavior and non-silent output, not human preference or physical-phone feel.

Final native effects check passed with attack output peak -9.92 dB; simultaneous-touch/pause/settings/mute checks passed. Godot imports and every script check passed. The shared skill's structural scanner falsely truncates `.gdshader` to `.gd`; a separate exact full-path resource check passed, including the shader. No missing resource was concealed with a dummy file. Rams quick_review was requested with via=rules for both edited UI files but did not run because the workspace has exhausted its review credits.

`docs/qa/refined-dash.mp4` is a scripted native recording of ground/air dashes, running, jumping and attack presentation, with guards frozen to isolate the effects; it is not a complete campaign playthrough. The generated mobile icon uses chevrons rather than the previous play triangle. Raw source and prompt are saved beside the terrain/VFX sources.
