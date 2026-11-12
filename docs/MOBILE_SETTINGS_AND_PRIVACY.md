# Mobile controls, settings, and privacy

The right thumb rests on the large central sword button. Kick sits to its left, ranged blade upper-left, power above, and the new energy slash on the outer edge. The left thumb retains the directional cross: up jumps/double-jumps, down crouches, and double-tapping a direction dashes. All combat controls remain icon-only with action descriptions and independent multitouch targets. The energy slash uses 35 power.

Settings > Customize touch layout saves standard/large targets, the sword side (mirrors the combat layout and swaps pads), opacity (100/80/60%), and vibration. Reset restores the touch defaults. Settings > Audio saves sound enabled and master volume (25/50/75/100%). Each setting applies immediately and persists in the existing `user://settings.cfg` beside campaign progress. Failed saves are reported in the menu. Focus stays on the changed setting.

Settings > Privacy describes local preferences/progress storage and supports publisher-approved HTTPS links. Configure `game/config/privacy.cfg` with actual `privacy_policy_url` and optional `terms_url` before distribution. Empty values deliberately show an unavailable notice; this implementation does not invent legal terms, a policy URL, or a privacy assurance. External links open the system browser and report launch failure.

Verification: Godot 4.7.2 headless `tests/mobile_ui.gd` passes independent fingers, release on pause, meter/charge state, safe bounds and nonoverlap at 1280×720, 1600×720 and 960×540, large and mirrored layouts, menu back navigation, rejected non-HTTPS policy links, actual HUD save/reload through an isolated settings file, and mute. Native 1152×648 renders were inspected and saved in `docs/qa/mobile-{central-sword,settings,customization,privacy}.png`. A physical phone and its vibration motor were not exercised.

Rams `quick_review` was requested with `via: rules` for the edited UI files. It returned `ran: false`: all 15 lifetime review credits were exhausted. No findings were returned. Native layout inspection and the automated geometry/input checks above completed.

Primary implementation references:
- [Godot TouchScreenButton](https://docs.godotengine.org/en/stable/classes/class_touchscreenbutton.html): gameplay multitouch uses independent TouchScreenButton nodes hosted in anchored Controls.
- [Godot ConfigFile](https://docs.godotengine.org/en/stable/classes/class_configfile.html): explicit disk save/load for named preferences.
- [Godot AudioServer](https://docs.godotengine.org/en/4.6/classes/class_audioserver.html): master-bus volume is independent of per-cue balancing and music ducking.
- [Godot DisplayServer](https://docs.godotengine.org/en/4.6/classes/class_displayserver.html): existing OS safe-area insets remain applied to the control parent.
