# Menu layout, title artwork and enemy movement cleanup

The menu issue was container overflow: several settings rows plus heading exceeded the safe viewport height. Preserving row heights and scrolling long content is preferable to compressing rows or letting them overlap. Setting switch rows use a quiet flat treatment rather than the ornamental action-button border. Actual toggles, slider values, focus and saved preferences remain interactive.

The title screen separates left-side title artwork from right-side actions in landscape and stacks for narrow windows. A generated pixel START word remains backed by a real keyboard/controller-accessible action. Continue must retain its own label/behavior when saved progression exists.

The generated app icon is assigned as the Godot project icon. Exports are PNG1024/256/64 under game/art/pixel/game-icon-*.png. No mobile-store packaging or submission is implied.

Enemy movement needed timing and registration fixes, not just a higher render framerate. At84worldpixels/sec and stride180, the previous four-record gait showed fewer than two drawings per second. A shorter stride and a new movement atlas increase cadence while keeping the controller's distance clock. A stable mask/head anchor prevents the floating enemy's cloth changes from moving its whole head. Generated near-duplicate frames must not be presented as eight distinct anatomical phases or60unique drawings/sec.

See the enemy implementation report and menu cleanup tests for final verification. Normal-speed feel, subjective preference and phone comfort require play review; numerical layout or anchor tests alone do not certify them. Rams UI review is requested but may remain blocked by exhausted credits.

## Verified result

Menu cleanup tests cover stable row heights, safe viewport bounds, scroll fallback, focus scrolling, separate START/CONTINUE behavior and narrow-title fallback. Native title/touch/audio screenshots were inspected, and docs/qa/menu-cleanup.mp4 records those menus with gameplay. The project uses the generated icon256PNG; icon1024PNG is the standalone export.

Enemy movement now consumes eight movement records in roughly1.2seconds at84worldpixels/sec. The registration test covers a common support anchor and bounded mask displacement through hover/windup/contact/hurt. Some generated movement poses remain near-duplicates; faster cadence and stable anchors do not constitute a fully polished anatomical walk cycle. Existing attack drawings remain sparse.
