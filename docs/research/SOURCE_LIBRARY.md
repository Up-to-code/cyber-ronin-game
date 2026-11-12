# Source library for Crimson Monastery

**181 unique sources returned HTTP 200 on 11 November 2026.** This is a research library, not a claim that every source was deeply read or every video watched. Individual evidence labels say exactly what was done. HTTP availability does not certify content accuracy, licensing, complete playable video access, or quality. No paid course, game, video subscription or asset was purchased. The library is weighted toward primary engine documentation, artist-authored visual lessons and accessibility guidance, with developer games, talks and slides for comparison.

## Start here: connect research to the actual faults

1. **Airborne J unexpectedly dives:** the controller explicitly entered plunge on ordinary airborne attack. This is a state/intent bug, not missing gravity. Ordinary aerial slash must preserve vertical velocity; plunge requires an explicit separate intent. Test rising, apex, falling, held movement and attack interruption.
2. **Kick looks stiff:** six pose records and adjusted timing cannot create missing hip/shoulder/support-leg transitions. Draw anticipation, chamber, extension, recoil and recovery with consistent silhouette and feet registration. Use [body mechanics breakdown](https://www.animationmentor.com/blog/animation-tips-tricks-what-makes-or-breaks-a-good-body-mechanics-shot/) (read through web search; direct HTTP validation failed, so excluded from the verified count) and Saint11's Attack Sheet, Jump, Walk and Subpixel lessons as the next review set.
3. **60 FPS request:** 60 rendered frames per second, 60 physics updates and 60 unique drawings per second are different. Measure frame pacing on a phone; use authored drawing durations for action emphasis. Interpolation can smooth transforms, but cannot invent a missing pose or make a wrong hit frame correct.
4. **Mobile arrangement:** let players choose comfortable control size/layout, preserve safe areas and stable hit targets, and provide visible press state. Evaluate simultaneous move+jump+attack. Desktop screenshots alone do not establish thumb comfort.
5. **VFX and sound:** separate anticipation/swing, confirmed contact, recoil and recovery. A miss should not sound like a body hit. A powerful X beam needs a clear origin, collision query, bounded lifetime, energy rule and bright focal path; adding random particles is not a mechanism.
6. **Sky appears fixed:** each depth layer needs both camera response and, where appropriate, its own wind/autoscroll. Clouds should move independently from the architecture. Verify coverage at both ends of every map.
7. **Levels feel unfair:** compare gap width and height with the actual jump envelope and landing clearance, then play the route. Celeste's forgiveness article is a design reference, not permission to copy constants blindly.
8. **Privacy/settings:** expose configurable privacy/help links only when real URLs exist. Describe actual local storage and external-link behavior; do not invent legal assurances.

## First 15 sources: an ordered study path

1. [Celeste & Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/) — Movement forgiveness: compare coyote/buffer windows with current controller.
2. [Using CharacterBody2D/3D](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html) — Controller semantics: distinguish input intent from physics integration.
3. [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) — Understand why static walls do not move and characters need coded response.
4. [Using physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html) — Smooth transform presentation without inventing missing drawings.
5. [Fixing jitter, stutter and input lag](https://docs.godotengine.org/en/stable/tutorials/rendering/jitter_stutter.html) — Measure frame pacing and distinguish jitter from animation pose gaps.
6. [Saint11: Attack Sheet](https://saint11.art/img/pixel-tutorials/AttackSheet.gif) — Plan anticipation/contact/recoil silhouettes before generating more frames.
7. [Saint11: Jump](https://saint11.art/img/pixel-tutorials/Jump.gif) — Draw readable takeoff, rising, apex, falling and landing phases.
8. [Saint11: Run Cycle Simple](https://saint11.art/img/pixel-tutorials/RunCycleSimple.gif) — Compare locomotion support and travel with the current run cycle.
9. [Saint11: Subpixel](https://saint11.art/img/pixel-tutorials/Subpixel.gif) — Study small pixel changes without destabilizing the character silhouette.
10. [2D Parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html) — Give sky/cloud/architecture independent camera response and coverage.
11. [Saint11: CLouds](https://saint11.art/img/pixel-tutorials/CLouds.gif) — Art reference for cloud clusters and shape readability.
12. [The Art of Screenshake — Jan Willem Nijman](https://www.youtube.com/watch?v=AJdEqssNZ-U) — Watch how brief feedback layers change impact, then tune conservatively.
13. [The Audio of Killer Instinct — Justin Bell](https://media.gdcvault.com/GDC2014/Presentations/Bell_Justin_The_Audio_Of.pdf) — Study combat-audio roles and dynamic mix from developer slides.
14. [Ensure interactive elements / virtual controls are large and well spaced, particularly on small or touch screens](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/) — Evaluate target separation and thumb accuracy on an actual phone.
15. [Allow controls to be remapped / reconfigured](https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/) — Let controls adapt to the player rather than declaring one universal layout.

## Suggested comparison sessions

- **Katana ZERO:** sword silhouette, brief anticipation, attack direction and color hierarchy. Watch the official mobile trailer, then inspect actual play; do not infer all controls from a trailer.
- **The Messenger:** aerial mobility, jump-to-attack continuity and clear ninja poses.
- **Dead Cells:** differentiated attack arcs and coherent character production pipeline. Its developer's 3D-to-2D process is an option, not a shortcut that automatically makes this project's art good.
- **Celeste:** forgiving movement and level progression; it is not a sword-combat reference.
- **Hollow Knight:** aerial directional attacks and legible enemy anticipation; its art style differs.
- **Huntdown:** foreground/midground separation, readable projectiles and environmental detail.
- **Blasphemous:** deliberate recovery and weight; avoid importing its pacing indiscriminately into a faster mobile game.

## How to use the library

Choose one defect and a small source set. Record a reference action's anticipation/contact/recovery, write the desired input behavior, implement, then compare native-scale footage with effects off and on. Treat the remaining indexed sources as a reading queue. Source count is not a quality score.

The JSON companion contains verification status and resolved URLs. Failed/unverified candidates are listed separately and are not included in the count. Illustrated GIFs are individual authored lessons, not 61 separate authors; documentation pages likewise are distinct topics from the same publisher.


## Animation (6)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S001 | [Introduction to the animation features](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |
| S002 | [Animation Track types](https://docs.godotengine.org/en/stable/tutorials/animation/animation_track_types.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |
| S003 | [Cutout animation](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |
| S004 | [2D skeletons](https://docs.godotengine.org/en/stable/tutorials/animation/2d_skeletons.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |
| S005 | [Using AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |
| S006 | [Creating movies](https://docs.godotengine.org/en/stable/tutorials/animation/creating_movies.html) | document | Drive poses, transitions and authored action events. | indexed; HTTP checked, not deeply read |

## Physics (16)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S007 | [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | text read; actionable principles summarized |
| S008 | [Using RigidBody](https://docs.godotengine.org/en/stable/tutorials/physics/rigid_body.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S009 | [Using Area2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S010 | [Using CharacterBody2D/3D](https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S011 | [Ray-casting](https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S012 | [Kinematic character (2D)](https://docs.godotengine.org/en/stable/tutorials/physics/kinematic_character_2d.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S013 | [Collision shapes (2D)](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S014 | [Quick start guide](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_quick_start_guide.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S015 | [Introduction](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_introduction.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S016 | [Using physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S017 | [Advanced physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/advanced_physics_interpolation.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S018 | [2D and 3D physics interpolation](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/2d_and_3d_physics_interpolation.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S019 | [Troubleshooting physics issues](https://docs.godotengine.org/en/stable/tutorials/physics/troubleshooting_physics_issues.html) | document | Keep gravity, collision, impulses and gameplay state consistent. | indexed; HTTP checked, not deeply read |
| S084 | [Fix Your Timestep](https://gafferongames.com/post/fix_your_timestep/) | document | Separate frame rate from physics integration. | indexed; HTTP checked, not deeply read |
| S085 | [Integration Basics](https://gafferongames.com/post/integration_basics/) | document | Integrate velocity and force consistently. | indexed; HTTP checked, not deeply read |
| S086 | [Physics in 3D](https://gafferongames.com/post/physics_in_3d/) | document | Mass, momentum and impulses; adapt dimensional reasoning carefully. | indexed; HTTP checked, not deeply read |

## World and VFX (14)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S020 | [Introduction to 2D](https://docs.godotengine.org/en/stable/tutorials/2d/introduction_to_2d.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S021 | [Canvas layers](https://docs.godotengine.org/en/stable/tutorials/2d/canvas_layers.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S022 | [Viewport and canvas transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S023 | [2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S024 | [2D meshes](https://docs.godotengine.org/en/stable/tutorials/2d/2d_meshes.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S025 | [2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S026 | [2D particle systems](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S027 | [ParticleProcessMaterial 2D Usage](https://docs.godotengine.org/en/stable/tutorials/2d/particle_process_material_2d.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S028 | [2D antialiasing](https://docs.godotengine.org/en/stable/tutorials/2d/2d_antialiasing.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S029 | [Custom drawing in 2D](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S030 | [2D Parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html) | document | Build layered worlds, particles and readable effects. | text read; actionable principles summarized |
| S031 | [2D movement overview](https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S032 | [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |
| S033 | [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) | document | Build layered worlds, particles and readable effects. | indexed; HTTP checked, not deeply read |

## Sound (9)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S034 | [Audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S035 | [Audio effects](https://docs.godotengine.org/en/stable/tutorials/audio/audio_effects.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S036 | [Audio streams](https://docs.godotengine.org/en/stable/tutorials/audio/audio_streams.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S037 | [Sync the gameplay with audio and music](https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S038 | [Recording with microphone](https://docs.godotengine.org/en/stable/tutorials/audio/recording_with_microphone.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S039 | [Text to speech](https://docs.godotengine.org/en/stable/tutorials/audio/text_to_speech.html) | document | Mix action, impact, ambience and music with distinct roles. | indexed; HTTP checked, not deeply read |
| S078 | [Impact Sounds](https://www.kenney.nl/assets/impact-sounds) | document | Licensed impact material for body and environment contact. | indexed; HTTP checked, not deeply read |
| S079 | [RPG Audio](https://www.kenney.nl/assets/rpg-audio) | document | Licensed weapon and foley source recordings. | indexed; HTTP checked, not deeply read |
| S080 | [Interface Sounds](https://www.kenney.nl/assets/interface-sounds) | document | Separate UI click feedback from combat cues. | indexed; HTTP checked, not deeply read |

## Controls (7)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S040 | [Using InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S041 | [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S042 | [Mouse and input coordinates](https://docs.godotengine.org/en/stable/tutorials/inputs/mouse_and_input_coordinates.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S043 | [Customizing the mouse cursor](https://docs.godotengine.org/en/stable/tutorials/inputs/custom_mouse_cursor.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S044 | [Controllers, gamepads, and joysticks](https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S045 | [Controller features](https://docs.godotengine.org/en/stable/tutorials/inputs/controller_features.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |
| S046 | [Handling quit requests](https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html) | document | Handle independent touches, action mapping and input transitions. | indexed; HTTP checked, not deeply read |

## Mobile UI (12)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S047 | [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S048 | [Using Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S049 | [Custom GUI controls](https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S050 | [Keyboard/Controller Navigation and Focus](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S051 | [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S052 | [Introduction to GUI skinning](https://docs.godotengine.org/en/stable/tutorials/ui/gui_skinning.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S053 | [Using the theme editor](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S054 | [Theme type variations](https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S055 | [Using Fonts](https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S056 | [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S057 | [Creating applications](https://docs.godotengine.org/en/stable/tutorials/ui/creating_applications.html) | document | Arrange scalable controls and menus without overlap. | indexed; HTTP checked, not deeply read |
| S081 | [Apple game controls](https://developer.apple.com/design/human-interface-guidelines/game-controls) | document | Thumb reach, touch-specific layouts and controller support. | indexed; HTTP checked, not deeply read |

## Performance (7)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S058 | [General optimization tips](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html) | document | Measure rendering and simulation rather than claiming 60 FPS from settings. | indexed; HTTP checked, not deeply read |
| S059 | [Optimization using Servers](https://docs.godotengine.org/en/stable/tutorials/performance/using_servers.html) | document | Measure rendering and simulation rather than claiming 60 FPS from settings. | indexed; HTTP checked, not deeply read |
| S060 | [CPU optimization](https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html) | document | Measure rendering and simulation rather than claiming 60 FPS from settings. | indexed; HTTP checked, not deeply read |
| S061 | [GPU optimization](https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html) | document | Measure rendering and simulation rather than claiming 60 FPS from settings. | indexed; HTTP checked, not deeply read |
| S062 | [Reducing stutter from shader (pipeline) compilations](https://docs.godotengine.org/en/stable/tutorials/performance/pipeline_compilations.html) | document | Measure rendering and simulation rather than claiming 60 FPS from settings. | indexed; HTTP checked, not deeply read |
| S082 | [Android game loops](https://developer.android.com/games/develop/gameloops) | document | Frame pacing and simulation scheduling on mobile. | indexed; HTTP checked, not deeply read |
| S083 | [Android frame pacing](https://developer.android.com/games/sdk/frame-pacing) | document | Consistent presentation timing instead of FPS-only claims. | indexed; HTTP checked, not deeply read |

## Rendering (5)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S063 | [Overview of renderers](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html) | document | Understand frame pacing, interpolation and mobile rendering constraints. | indexed; HTTP checked, not deeply read |
| S064 | [Using Viewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html) | document | Understand frame pacing, interpolation and mobile rendering constraints. | indexed; HTTP checked, not deeply read |
| S065 | [Multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html) | document | Understand frame pacing, interpolation and mobile rendering constraints. | indexed; HTTP checked, not deeply read |
| S066 | [Fixing jitter, stutter and input lag](https://docs.godotengine.org/en/stable/tutorials/rendering/jitter_stutter.html) | document | Understand frame pacing, interpolation and mobile rendering constraints. | indexed; HTTP checked, not deeply read |
| S067 | [Using DrawableTextures](https://docs.godotengine.org/en/stable/tutorials/rendering/drawable_textures.html) | document | Understand frame pacing, interpolation and mobile rendering constraints. | indexed; HTTP checked, not deeply read |

## Game feel (1)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S068 | [Celeste & Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/) | document | Coyote time, jump buffering and forgiving landing adjustments. | text read; actionable principles summarized |

## Pixel art (2)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S069 | [Style consistency](https://saint11.art/blog/consistency/) | document | Keep grid scale, rotation and drawing styles coherent. | indexed; HTTP checked, not deeply read |
| S071 | [Pixel art tutorials](https://saint11.art/blog/pixel-art-tutorials/) | document | Artist-authored tutorial collection. | indexed; HTTP checked, not deeply read |

## Art production (2)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S070 | [Using 3D reference](https://saint11.art/blog/3d-ref/) | document | Use 3D as pose reference while preserving drawn pixel identity. | indexed; HTTP checked, not deeply read |
| S072 | [Dead Cells 3D-to-2D pipeline](https://www.gamedeveloper.com/production/art-design-deep-dive-using-a-3d-pipeline-for-2d-animation-in-i-dead-cells-i-) | document | Developer pipeline for many coherent character frames. | indexed; HTTP checked, not deeply read |

## Talks and videos (6)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S073 | [Designing Celeste — Maddy Thorson, GDC](https://www.youtube.com/watch?v=4RlpMhBKNr0) | video/talk | Platform spacing, progression and designer iteration. | landing page/PDF HTTP checked; talk not watched |
| S074 | [The Art of Screenshake — Jan Willem Nijman](https://www.youtube.com/watch?v=AJdEqssNZ-U) | video/talk | Layer feedback proportionally; preserve readable actions. | landing page/PDF HTTP checked; talk not watched |
| S075 | [Juicing Your Cameras — Squirrel Eiserloh](https://media.gdcvault.com/gdc2016/Presentations/Eiserloh_Squirrel_JuicingYourCameras.pdf) | video/talk | Transient camera feedback and trauma-based shake. | landing page/PDF HTTP checked; talk not watched |
| S076 | [The Audio of Killer Instinct — Justin Bell](https://media.gdcvault.com/GDC2014/Presentations/Bell_Justin_The_Audio_Of.pdf) | video/talk | Combat sound roles, impact and dynamic mix. | landing page/PDF HTTP checked; talk not watched |
| S077 | [Rules of the Game — Richard Rouse](https://media.gdcvault.com/gdc2016/Presentations/Rouse_Richard_RulesOfTheGame.pdf) | video/talk | Player feedback and game-design references. | landing page/PDF HTTP checked; talk not watched |
| S181 | [Katana ZERO mobile official trailer — Netflix Games](https://www.youtube.com/watch?v=9TpUyq8Ms1I) | video | Watch mobile presentation of side-view sword combat; trailer is not a control usability test. | landing page/PDF HTTP checked; talk not watched |

## Geometry (1)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S087 | [Line drawing on a grid](https://www.redblobgames.com/grids/line-drawing/) | document | Pixel-aligned line and beam visual reasoning. | indexed; HTTP checked, not deeply read |

## Game references (9)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S088 | [Celeste](https://www.celestegame.com/) | game/developer site | Study forgiving platform controls and animation readability. | indexed; HTTP checked, not deeply read |
| S089 | [Dead Cells](https://dead-cells.com/) | game/developer site | Study readable anticipation, attack variants and impact staging. | indexed; HTTP checked, not deeply read |
| S090 | [Shovel Knight](https://www.shovelknight.com/) | game/developer site | Study short-range attacks, aerial control and enemy telegraphs. | indexed; HTTP checked, not deeply read |
| S091 | [Hollow Knight](https://www.hollowknight.com/) | game/developer site | Study aerial slashes and readable encounter silhouettes. | indexed; HTTP checked, not deeply read |
| S176 | [Askiisoft — Katana ZERO](https://askiisoft.com/) | developer/publisher document | Study the developer’s official sword-action media. | indexed; HTTP checked, not deeply read |
| S177 | [The Messenger press kit](https://sabotagestudio.com/presskits/the-messenger/) | developer/publisher document | Study airborne attacks and ninja silhouettes. | indexed; HTTP checked, not deeply read |
| S178 | [Blasphemous publisher page](https://www.team17.com/games/blasphemous) | developer/publisher document | Study deliberate weight, anticipation and recovery. | indexed; HTTP checked, not deeply read |
| S179 | [Huntdown official publisher page](https://coffeestain.com/game/huntdown/) | developer/publisher document | Study layered pixel environments and combat legibility. | indexed; HTTP checked, not deeply read |
| S180 | [Huntdown instruction manual](https://huntdown.com/manual/Manual-Huntdown.pdf) | developer/publisher document | Compare clear input vocabulary and movement/weapon explanations. | indexed; HTTP checked, not deeply read |

## Accessibility (23)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S092 | [Include an option to adjust the game speed](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-game-speed/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S093 | [Include toggle/slider for any haptics](https://gameaccessibilityguidelines.com/include-toggle-slider-for-any-haptics/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S094 | [Ensure interactive elements / virtual controls are large and well spaced, particularly on small or touch screens](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S095 | [Include an option to adjust the sensitivity of controls](https://gameaccessibilityguidelines.com/include-an-option-to-adjust-the-sensitivity-of-controls/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S096 | [Ensure that all areas of the user interface can be accessed using the same input method as the gameplay](https://gameaccessibilityguidelines.com/ensure-that-all-areas-of-the-user-interface-can-be-accessed-using-the-same-input-method-as-the-gameplay/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S097 | [Ensure controls are as simple as possible, or provide a simpler alternative](https://gameaccessibilityguidelines.com/ensure-controls-are-as-simple-as-possible-or-provide-a-simpler-alternative/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S098 | [Allow controls to be remapped / reconfigured](https://gameaccessibilityguidelines.com/allow-controls-to-be-remapped-reconfigured/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S099 | [Avoid flickering images and repetitive patterns](https://gameaccessibilityguidelines.com/avoid-flickering-images-and-repetitive-patterns/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S100 | [Allow players to progress through text prompts at their own pace](https://gameaccessibilityguidelines.com/allow-players-to-progress-through-text-prompts-at-their-own-pace/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S101 | [Include interactive tutorials](https://gameaccessibilityguidelines.com/include-interactive-tutorials/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S102 | [Use simple clear language](https://gameaccessibilityguidelines.com/use-simple-clear-language/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S103 | [Allow the game to be started without the need to navigate through multiple levels of menus](https://gameaccessibilityguidelines.com/allow-the-game-to-be-started-without-the-need-to-navigate-through-multiple-levels-of-menus/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S104 | [Use simple clear text formatting](https://gameaccessibilityguidelines.com/use-simple-clear-text-formatting/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S105 | [Use an easily readable default font size](https://gameaccessibilityguidelines.com/use-an-easily-readable-default-font-size/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S106 | [Provide high contrast between text/UI and background](https://gameaccessibilityguidelines.com/provide-high-contrast-between-text-ui-and-background/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S107 | [Ensure no essential information is conveyed by a fixed colour alone](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S108 | [If any subtitles / captions are used, present them in a clear, easy to read way](https://gameaccessibilityguidelines.com/if-any-subtitles-captions-are-used-present-them-in-a-clear-easy-to-read-way/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S109 | [Ensure no essential information is conveyed by sounds alone](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-sounds-alone/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S110 | [Provide separate volume controls or mutes for effects, speech and background / music](https://gameaccessibilityguidelines.com/provide-separate-volume-controls-or-mutes-for-effects-speech-and-background-music/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S111 | [Solicit accessibility feedback](https://gameaccessibilityguidelines.com/solicit-accessibility-feedback/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S112 | [Ensure that all settings are saved/remembered](https://gameaccessibilityguidelines.com/ensure-that-all-settings-are-saved-remembered/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S113 | [Provide details of accessibility features in-game](https://gameaccessibilityguidelines.com/provide-details-of-accessibility-features-in-game/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |
| S114 | [Offer a wide choice of difficulty levels](https://gameaccessibilityguidelines.com/offer-a-wide-choice-of-difficulty-levels/) | document | Apply the named guideline to touch, readability, feedback or settings. | indexed; HTTP checked, not deeply read |

## Pixel art illustrated lessons (61)

| ID | Source | Type | Why it matters | Evidence |
|---|---|---|---|---|
| S115 | [Saint11: 4Legs Walk](https://saint11.art/img/pixel-tutorials/4LegsWalk.gif) | illustrated tutorial | Study 4legs walk for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S116 | [Saint11: Attack Sheet](https://saint11.art/img/pixel-tutorials/AttackSheet.gif) | illustrated tutorial | Study attack sheet for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S117 | [Saint11: Breaking](https://saint11.art/img/pixel-tutorials/Breaking.gif) | illustrated tutorial | Study breaking for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S118 | [Saint11: Bullets](https://saint11.art/img/pixel-tutorials/Bullets.gif) | illustrated tutorial | Study bullets for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S119 | [Saint11: character Idle](https://saint11.art/img/pixel-tutorials/characterIdle.gif) | illustrated tutorial | Study character idle for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S120 | [Saint11: CLouds](https://saint11.art/img/pixel-tutorials/CLouds.gif) | illustrated tutorial | Study clouds for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S121 | [Saint11: Dark Magic](https://saint11.art/img/pixel-tutorials/DarkMagic.gif) | illustrated tutorial | Study dark magic for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S122 | [Saint11: Darkness](https://saint11.art/img/pixel-tutorials/Darkness.gif) | illustrated tutorial | Study darkness for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S123 | [Saint11: Defend](https://saint11.art/img/pixel-tutorials/Defend.gif) | illustrated tutorial | Study defend for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S124 | [Saint11: Easings](https://saint11.art/img/pixel-tutorials/Easings.gif) | illustrated tutorial | Study easings for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S125 | [Saint11: Electric](https://saint11.art/img/pixel-tutorials/Electric.gif) | illustrated tutorial | Study electric for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S126 | [Saint11: Explosion](https://saint11.art/img/pixel-tutorials/Explosion.gif) | illustrated tutorial | Study explosion for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S127 | [Saint11: Fabric](https://saint11.art/img/pixel-tutorials/Fabric.gif) | illustrated tutorial | Study fabric for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S128 | [Saint11: Fire](https://saint11.art/img/pixel-tutorials/Fire.gif) | illustrated tutorial | Study fire for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S129 | [Saint11: Fundamentals](https://saint11.art/img/pixel-tutorials/Fundamentals.gif) | illustrated tutorial | Study fundamentals for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S130 | [Saint11: Fundamentals2](https://saint11.art/img/pixel-tutorials/Fundamentals2.gif) | illustrated tutorial | Study fundamentals2 for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S131 | [Saint11: GD Level Progression](https://saint11.art/img/pixel-tutorials/GD_LevelProgression.gif) | illustrated tutorial | Study gd level progression for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S132 | [Saint11: Glitch](https://saint11.art/img/pixel-tutorials/Glitch.gif) | illustrated tutorial | Study glitch for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S133 | [Saint11: Hazards](https://saint11.art/img/pixel-tutorials/Hazards.gif) | illustrated tutorial | Study hazards for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S134 | [Saint11: Holograms Ghosts](https://saint11.art/img/pixel-tutorials/Holograms-Ghosts.gif) | illustrated tutorial | Study holograms ghosts for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S135 | [Saint11: Ice](https://saint11.art/img/pixel-tutorials/Ice.gif) | illustrated tutorial | Study ice for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S136 | [Saint11: Illumination Techniques](https://saint11.art/img/pixel-tutorials/IlluminationTechniques.gif) | illustrated tutorial | Study illumination techniques for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S137 | [Saint11: Impact export](https://saint11.art/img/pixel-tutorials/Impact-export.gif) | illustrated tutorial | Study impact export for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S138 | [Saint11: Jump](https://saint11.art/img/pixel-tutorials/Jump.gif) | illustrated tutorial | Study jump for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S139 | [Saint11: Light Magic](https://saint11.art/img/pixel-tutorials/LightMagic.gif) | illustrated tutorial | Study light magic for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S140 | [Saint11: loop](https://saint11.art/img/pixel-tutorials/loop.gif) | illustrated tutorial | Study loop for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S141 | [Saint11: Metal](https://saint11.art/img/pixel-tutorials/Metal.gif) | illustrated tutorial | Study metal for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S142 | [Saint11: Modular](https://saint11.art/img/pixel-tutorials/Modular.gif) | illustrated tutorial | Study modular for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S143 | [Saint11: Motion Blur](https://saint11.art/img/pixel-tutorials/MotionBlur.gif) | illustrated tutorial | Study motion blur for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S144 | [Saint11: Outlines](https://saint11.art/img/pixel-tutorials/Outlines.gif) | illustrated tutorial | Study outlines for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S145 | [Saint11: Parallax](https://saint11.art/img/pixel-tutorials/Parallax.gif) | illustrated tutorial | Study parallax for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S146 | [Saint11: Pipeline](https://saint11.art/img/pixel-tutorials/Pipeline.gif) | illustrated tutorial | Study pipeline for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S147 | [Saint11: Planning](https://saint11.art/img/pixel-tutorials/Planning.gif) | illustrated tutorial | Study planning for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S148 | [Saint11: Resizing](https://saint11.art/img/pixel-tutorials/Resizing.gif) | illustrated tutorial | Study resizing for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S149 | [Saint11: Rock](https://saint11.art/img/pixel-tutorials/Rock.gif) | illustrated tutorial | Study rock for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S150 | [Saint11: Rocket Trail](https://saint11.art/img/pixel-tutorials/RocketTrail.gif) | illustrated tutorial | Study rocket trail for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S151 | [Saint11: Ruins](https://saint11.art/img/pixel-tutorials/Ruins.gif) | illustrated tutorial | Study ruins for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S152 | [Saint11: Run Cycle Simple](https://saint11.art/img/pixel-tutorials/RunCycleSimple.gif) | illustrated tutorial | Study run cycle simple for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S153 | [Saint11: Sand](https://saint11.art/img/pixel-tutorials/Sand.gif) | illustrated tutorial | Study sand for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S154 | [Saint11: Shading](https://saint11.art/img/pixel-tutorials/Shading.gif) | illustrated tutorial | Study shading for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S155 | [Saint11: Shine](https://saint11.art/img/pixel-tutorials/Shine.gif) | illustrated tutorial | Study shine for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S156 | [Saint11: Silhouette](https://saint11.art/img/pixel-tutorials/Silhouette.gif) | illustrated tutorial | Study silhouette for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S157 | [Saint11: Slide Roll](https://saint11.art/img/pixel-tutorials/Slide-Roll.gif) | illustrated tutorial | Study slide roll for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S158 | [Saint11: Smoke Sheet](https://saint11.art/img/pixel-tutorials/SmokeSheet.gif) | illustrated tutorial | Study smoke sheet for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S159 | [Saint11: Squash](https://saint11.art/img/pixel-tutorials/Squash.gif) | illustrated tutorial | Study squash for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S160 | [Saint11: Stars](https://saint11.art/img/pixel-tutorials/Stars.gif) | illustrated tutorial | Study stars for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S161 | [Saint11: Subpixel](https://saint11.art/img/pixel-tutorials/Subpixel.gif) | illustrated tutorial | Study subpixel for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S162 | [Saint11: Swords](https://saint11.art/img/pixel-tutorials/Swords.gif) | illustrated tutorial | Study swords for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S163 | [Saint11: Tech](https://saint11.art/img/pixel-tutorials/Tech.gif) | illustrated tutorial | Study tech for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S164 | [Saint11: Tiles](https://saint11.art/img/pixel-tutorials/Tiles.gif) | illustrated tutorial | Study tiles for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S165 | [Saint11: UI 9 Slice](https://saint11.art/img/pixel-tutorials/UI-9-Slice.gif) | illustrated tutorial | Study ui 9 slice for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S166 | [Saint11: Vegetation](https://saint11.art/img/pixel-tutorials/Vegetation.gif) | illustrated tutorial | Study vegetation for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S167 | [Saint11: Vegetation2](https://saint11.art/img/pixel-tutorials/Vegetation2.gif) | illustrated tutorial | Study vegetation2 for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S168 | [Saint11: Vegetation3](https://saint11.art/img/pixel-tutorials/Vegetation3.gif) | illustrated tutorial | Study vegetation3 for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S169 | [Saint11: Walk](https://saint11.art/img/pixel-tutorials/Walk.gif) | illustrated tutorial | Study walk for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S170 | [Saint11: Wall Slide](https://saint11.art/img/pixel-tutorials/WallSlide.gif) | illustrated tutorial | Study wall slide for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S171 | [Saint11: Water](https://saint11.art/img/pixel-tutorials/Water.gif) | illustrated tutorial | Study water for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S172 | [Saint11: Wind](https://saint11.art/img/pixel-tutorials/Wind.gif) | illustrated tutorial | Study wind for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S173 | [Saint11: Wings](https://saint11.art/img/pixel-tutorials/Wings.gif) | illustrated tutorial | Study wings for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S174 | [Saint11: Wood](https://saint11.art/img/pixel-tutorials/Wood.gif) | illustrated tutorial | Study wood for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |
| S175 | [Saint11: Alignment](https://saint11.art/img/pixel-tutorials/Alignment.png) | illustrated tutorial | Study alignment for readable pixel animation, effects and environment construction. | artist index discovered; image HTTP checked; sequence not visually reviewed |

## Unverified candidates — excluded from count

- [Celeste & TowerFall Physics](https://www.maddymakesgames.com/articles/collision/): direct HTTP check failed; not counted. Use the creator/publisher alternatives above where available.
- [Body mechanics breakdown](https://www.animationmentor.com/blog/animation-tips-tricks-what-makes-or-breaks-a-good-body-mechanics-shot/): direct HTTP check failed; not counted. Use the creator/publisher alternatives above where available.
- [Vector math](https://www.redblobgames.com/articles/vector-math/): direct HTTP check failed; not counted. Use the creator/publisher alternatives above where available.
- [Katana ZERO](https://www.katanazero.com/): direct HTTP check failed; not counted. Use the creator/publisher alternatives above where available.
- [Blasphemous (candidate)](https://www.blashphemous.com/): direct HTTP check failed; not counted. Use the creator/publisher alternatives above where available.