# Citadel menu layers

Generated with the built-in image generation tool, then integrated as separate Godot assets. No interface copy is baked into these images.

Runtime order in `ui/citadel_backdrop.gd`:

1. `sky.png`: moon, sky, clouds and very distant mountain silhouettes.
2. `architecture.png`: transparent monastery, bridges, waterfalls and valley scenery.
3. `foreground.png`: transparent ronin, roof, bell and maple branches.
4. `ui/citadel_effects.gd`: live drifting embers and traveling crimson perimeter beams.
5. `frame.png`: transparent carved screen border.
6. Live Controls above the artwork: labels, focusable buttons, skill purchases, scroll containers.

`button.png` is a separate transparent ornament without text. `backdrop.png` is the initial combined scenery study, retained for art reference and not used at runtime.

Sky, architecture and foreground have different gentle movement rates. Motion pauses while the artwork is invisible. Set `motion_enabled` on the backdrop to disable motion. The frame and button hit targets remain stationary. Character cloak and individual waterfalls are painted art; they do not have independent deformation animations.

Prompt set (production specifications):

- Sky: wide 16:9, fine crisp pixel art indigo night, ivory moon upper middle left, layered blue clouds, faint mountain silhouettes and mist. Right third quiet. No buildings, character, foreground, text, interface or border.
- Architecture: transparent 16:9 midground Japanese monastery citadel on rocky mountains, bridges, waterfalls, red portal and warm lanterns; structures left and center; top quarter and right third empty. Blue moonlight, crimson and antique gold. No sky, moon, character, foreground roof, interface or border.
- Foreground: transparent 16:9 roof at bottom left, crimson-cloaked samurai at left quarter, maple branches upper left and bronze bell. Moss, dragon endcaps, blue moonlight and gold rim lighting. Center/right transparent. No scenery, text, buttons or frame.
- Frame: transparent 16:9 thin aged gold and carved stone border, four dragon relief corners, moss and maple accents, delicate crimson channels; empty transparent center, no scenery or text.
- Button: one isolated wide horizontal black lacquer/crimson silk button, antique gold carved bevelled border, cloud relief corners, fine pixel art, transparent surround and empty text area.
- Initial backdrop study: 16:9 moonlit Japanese mountain citadel, layered towers, bridges and waterfalls, crimson portal, quiet dark right third; no interface, character or frame.

Validation: `Godot --path game --script res://tests/citadel_menu.gd` checks motion, title/gameplay visibility, title actions and existing skill offers. A graphical run also captures the title and armory to `/tmp/citadel-isolated.png` and `/tmp/citadel-armory.png`. Rams rules quick review was attempted but could not run because the workspace's review credits were exhausted.
