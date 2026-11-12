# Mobile control repair

Apple's [game controls HIG](https://developer.apple.com/design/human-interface-guidelines/game-controls.md) recommends frequent actions near the thumbs, safe-area placement, visible press feedback, and reducing control overlap with gameplay. Its minimum sizes are in platform points, not Godot logical pixels; a device measurement is still necessary. [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/) likewise recommends large separated hit areas and warns that reduced accuracy can require larger controls.

The previous right cluster occupied a 196×184 logical region, stretching upward into combat. It now occupies 156×112: Kick and the wider Sword are on the lower row, Ranged and Power above. The 48×48 direction and 52×52 skill targets remain, with an 84×52 sword. All remain anchored inside the safe area. The requested up-to-jump directional cross is retained rather than replacing it with a thumbstick. This is a task-specific layout choice, not a claim of one universal recommended game layout.

Presses show a perimeter highlight, visible around the fingertip, plus a 12ms mobile vibration where supported. Multi-touch and pause-release ownership are unchanged.

Godot headless mobile_ui checks pass across three dimensions, with complete target containment, no overlap, independent touches, power state and pause/settings input handoff. Native screenshot at /tmp/mobile-layout-repair.png confirms the compact cluster and readable labels. A real phone comfort/physical-size/haptic check is pending. Rams quick_review with via=rules could not run because the workspace has exhausted its 15 credits.

## Icon-only controls and motion

Removed all visible action titles and dynamic READY/NEED/HOLD text. Each icon is centered and enlarged to 38 logical pixels. Pressing gives an 8% artwork compression, a one-pixel depression and an outline that decays after release; touch shapes never move. Charge remains a bar, and unaffordable skills dim. Action descriptions remain in slot tooltip/metadata for tooling; this is not a claim of full screen-reader support. Physical phone use still needs validation.

This follows Apple's specific recommendations to use action-representative symbols and visible/tactile press states: https://developer.apple.com/design/human-interface-guidelines/game-controls.md . Target spacing is retained per https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/ .

Headless mobile_ui passes icon-only checks, simultaneous touches, safe areas and target overlap checks at three window dimensions. Rams quick_review requested with via=rules returned ran:false because review credits are exhausted.
