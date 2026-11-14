# Ashen Veil: navigation, touch and combat pass

The new game name is Ashen Veil. The app icon carries the name, while a separate640×360 pixel welcome illustration replaces the squareicon on the title screen. A presentation-only overscanned pan gives the welcome art subtle motion without moving UI hit targets. Main menu actions remain on the side.

Automatic route chapter dialogs are removed. Entering a route shows its objective and leaves gameplay running; story remains available on demand. Completion remains a distinct end-of-campaign state. Menus retain native controls/focus for input while removing unsolicited mouse tooltips and decorative hover outlines. Settings have explicit return navigation and opacity guidance.

The revised touch cluster follows the supplied diagram: primary sword is a larger square; kick and powers use stepped pixel circles around/above it; directional movement remains on the left, with handedness customization. Touch bounds are fixed and larger than artwork. Safe-area/ratio and simultaneous-touch tests must not be described as native iOS testing.

Camera follows jump displacement immediately with a faster eased vertical response and short landing settling shake. Physics/collision do not move with the shake. The25percent closer zoom is retained.

Two additional enemies have authored pixel-art key poses: lancer (155worldpixel reach,18damage,85health) and hammer sentinel (115kg,25damage,130health, slower approach and longer telegraph). Their later-level encounters replace selected guards so progression adds attack roles without simply increasing crowd size. New enemy art is a sparse8pose set, not a polished high-frame-count animation.

## iOS evidence boundary

Device inventory found an iOS27.1 simulator on this Mac; Android SDK is unavailable. This workspace has no iOS exportpreset or matching installed exporttemplates. Thus no native iOS app was built/launched/tested. [Godot iOS exporting documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html) describes required macOS/Xcode/template setup; [the engine simulator-slice issue](https://github.com/godotengine/godot/issues/118161) is an additional build consideration. Input/layout validation at iPhone/iPad aspect ratios is preparatory evidence, not a claim of compatibility with every mobile version.

Image-generated raw files and nearest-neighbor derivatives are retained in assets/art/pixel/ashen-veil and assets/art/pixel/ashen-enemies. The icon PNG is exported at1024/256/64; only256is assigned to the Godot project. No mobile-store upload/signing is implied. Physical-device frame pacing, haptics, phone audio and subjective play feel remain unverified.

## Applied interaction and feedback details

The title no longer embeds the appicon. Hover styles use the normal artwork; START focus changes brightness without an outline. Mouse tooltips are replaced by nonvisual action metadata, and gameplay hides the desktop pointer while menus restore it. Opacity includes visible guidance that faded controls keep their touch regions. Chapter text is reachable from the pause menu and uses the shared red/ivory panel/button kit.

Kick motion is a short foot-socket sweep with stepped points, distinct from confirmed red contact. Energy projectiles use three tapered snapped-pixel bands and a bright core instead of a stretched animatedslash overlay. The single sweptcollision damage path and actor-owned impact remain unchanged. Enemy thrust and heavy strike have separate cue roles.

Checks passed: mobile_ui across seven viewport sizes including iPhone/iPad ratios, menu_clean_layout, pixel_menu_components, camera_closeup, ashen_enemy_types, air_slash_energy, feedback_separation, projectile_feedback, authored_contact, death_presentation, audio_roles and effects. Native Mac capture uses staged enemy placement to demonstrate the lancer/sentinel and menus, not a human full-level session. Subjective audio and motion quality remain unverified.
