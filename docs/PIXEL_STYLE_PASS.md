# Red-and-ivory pixel-art pass

New image-generated assets:

- A coordinated red/ivory menu kit: primary/secondary buttons, panel, toggles, navigation icons and meter artwork. Functional components own values, focus and navigation; baked meter fill is not used as a false volume reading.
- Matching directional and combat button atlas replacing the brass/turquoise style.
- Twenty-four enemy drawings: guard, fire keeper and floating oni mask, eight key poses each. They now all render through whole-character cel profiles, replacing the fire/wraith rigid cutout puppets. Gait/hover and action states own separate drawings. This is a sparse authored pose set, not a complete smooth high-frame animation.
- Dark-stone platform surface with crimson moss and ivory snow flecks, registered to the unchanged walkable collision top.

The UI font remains Pixelify Sans with antialiasing disabled and nearest-neighbor textures. Start and pause screens retain separate context; settings have top icons and nested breadcrumbs. Generated toggle artwork reflects saved state; the volume slider controls and persists actual Master volume.

The camera zoom changes from0.5 to0.625 (25percent closer). Horizontal bounds use the actual zoom-adjusted half-view. Vertical tracking remembers the landing surface and follows only beyond a64-world-pixel rise window, with eased return on landing. Camera offsets never alter physics.

Damage effects and hurt flashes are crimson. Enemy footsteps have their own quiet cue and EnemyCombat bus. Ranged, energy and power releases are distinct. Projectiles no longer duplicate actor contact VFX; their environmental impact remains.

Validation includes camera_closeup, all-six-map campaign_runtime, enemy_pixel_visuals, body_physics, kick_states, recovery_flow, effects, jungle_terrain, mobile_ui, defeat_ui, pixel_menu_components, red_feedback_audio and projectile_feedback. The native capture uses staged enemy placements to show all three enemy types and menu states in one shot; it is not a human full-level playthrough.

Remaining: the hero's idle/first sword/kick are the new redraw while several locomotion/other actions still use normalized source sprites. Those need an authored redraw pass for fully consistent character artwork. More enemy breakdown frames and human motion/audio approval remain. Pixel art assets do not by themselves establish game feel. Rams rules checks were requested but blocked by exhausted workspace credits. Physical-phone comfort/performance remains unverified.
