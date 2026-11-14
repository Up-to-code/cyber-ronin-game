# Four-button combat and power

The current mobile layout has two direction buttons on the left and four 52-unit square action targets in an anchored 2×2 group on the right: Jump / Kick above Sword / Power. Labels supplement the generated pixel icons. RUN is removed; direction input moves at the previous 300-unit run speed. Pause stays in the top-right safe area, aligned with the stage header. Red HEALTH and teal POWER meters are independently labelled at top left. Logical game units are not a measurement of physical-device points; actual thumb comfort still needs device testing.

Combat choices:

- Kick (L): close-range 20 damage, strong push, no power cost; new four-pose kick sprite animation. Cloth motion and body contact sounds are separate.
- Sword (J): tap for a three-hit chain, 35/35/45 damage. The second slash is 1.875× its earlier size, with a second reverse arc. Finisher is larger again. Hold after the first strike until READY, then release a charged 60-damage slash for 30 power.
- Power (U): immediate 90-damage forward burst for 50 power, with the largest paired slash effect. The button shows NEED 50 when unaffordable; a quiet rejection cue accompanies a rejected request. This also provides a single-tap special attack for players who prefer not to hold Sword.
- Jump (Space): one extra airborne jump. Airborne Sword starts a descending strike; floor contact creates a wide burst and applies 55 damage once nearby. Double jump or dash can interrupt the descent.

Power regenerates 12/second after a one-second spending delay, pauses while charging, and resets at each shrine transition with health. Power attacks never spend health. Damage, dash, pause and returning to menu cancel charge; no delayed release is stored across a pause. Normal sword/kick remain usable at zero power.

Research and application:

- [Apple game controls](https://developer.apple.com/design/human-interface-guidelines/game-controls): clear virtual controls and visible pressed feedback. The action squares have a pressed tint, descriptive labels and charge state.
- [Apple designing for games](https://developer.apple.com/design/human-interface-guidelines/designing-for-games): platform input conventions and safe areas. Controls are anchored within the existing safe-area container.
- [Game Accessibility Guidelines: control size and spacing](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/): large, separated targets. Movement and actions occupy separate lower corners with gaps between squares.
- [Xbox input accessibility](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/107): alternatives to repeated or held input. Power has a dedicated single-tap action in addition to the optional charged Sword interaction; this is a partial application, not full accessibility certification.
- [Combat sound design](COMBAT_SOUND_DESIGN.md): primary synthesis/layering references, cue assignments, gain and duration.

Validation: power_actions, combo_air_jump, mobile_ui, locomotion, platforming, campaign_runtime and native audio_combat checks. Separate meters, affordability/charge states, 2×2 alignment, independent fingers, pause cancellation, once-per-strike damage, charge interruption, floor impact and transient cleanup are tested. Native output peaks near -9.92dB in the isolated sound test. Scripted native recording uses stationary high-health guards to demonstrate each attack; it is not a campaign playthrough or human preference test. Rams via=rules was requested for UI changes; exhausted workspace credits prevented the review.

New generated raw art/prompts: assets/art/pixel/refinement/combat-buttons.* and kick-motion.*. Exported icons and kick frames use nearest-neighbor scaling, palette reduction, alpha cleanup and foot registration. No purchased sound library was added.
