# Approved-reference menu reconstruction

This replaces the independently invented citadel menu art direction. `reference.png` is the user-approved composition. New layers were produced with the built-in image generation editor using that exact image as the reference. This is a close reconstruction, not a claim of identical pixels: generated cutout edges, title ornament and plaque detail vary slightly.

## Assets and final prompt specifications

- `world.png`: Edit approved artwork into the background world layer, preserve exact citadel, moon, portal, bridges and waterfall composition; remove all interface, outer border, foreground samurai, roof, branch and bell; reconstruct obscured distant scenery. Keep original rendering and colors.
- `foreground.png`: Extract only original samurai/cape, bottom-left roof, upper-left maple branches and hanging bell; preserve source placement, scale, identity, colors and details on a transparent full-size canvas. Remove world and interface.
- `frame.png`: Extract only original thin stone/gold outer border, corner reliefs and moss in source registration. Everything inside transparent, no redesigned border.
- `controls.png`: Extract only the three right plaques and bottom-right gear at original positions. Keep crimson lacquer, gold edging, left icons and dividers. Remove the words for live labels. Everything else transparent.
- `logo.png`: Extract only ASHEN VEIL title, red brushstroke circle and gold flourish in full-canvas source registration. Everything else transparent.

All five prompts used `reference.png` as the editing source. Original outputs remain in the image generator directory; these project copies are runtime assets. Text on primary actions is live, with serif SystemFont fallback (Baskerville, Times New Roman, serif); the decorative title is its own transparent image.

## Runtime

`ui/citadel_backdrop.gd` stacks world, foreground, live particles/edge laser channels, and the screen border. `ui/approved_title.gd` separately positions logo and four independent focusable buttons using the original 1672 × 941 design coordinates and uniform scale. Tall screens use a centered vertical stack; landscape screens retain the reference arrangement. Safe-area margins keep the gear and plaques within the screen. Placards use runtime AtlasTexture regions; they are never stretched into thin strips. Motion is deliberately subtle to preserve the reference composition.

START enters gameplay at the current unlocked route, or the first route for a new save. Inventory shows consumable packs; Skills shows permanent training. Settings retains the campaign map, new adventure, help and credits. The in-game armory retains the full offer list. Existing prices, rank limits and saved progression are unchanged.

## Checks

`Godot --path game --script res://tests/citadel_menu.gd` checks layer motion, title/gameplay transitions, settings/back, offer filtering, and opening/closing both inventory and skills from the actual paused title scene. The graphical test produces temporary screenshots for visual comparison. A headless startup also passes. Rams quick_review with via=rules was attempted; the workspace's exhausted review credits prevented the review from running.
