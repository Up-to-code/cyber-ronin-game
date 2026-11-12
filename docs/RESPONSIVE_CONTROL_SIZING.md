# Responsive control sizing repair

The old sword used72 logical game units. At the native1152×648 window's1.8 render scale, that became129.6 output pixels, with an almost full-size opaque panel. Resizing the game also enlarged controls with the world.

The new layout separates three quantities: base hit region, desired output target, and smaller visual face. Desktop touch preview aims for56 output pixels for movement/skills and71.3 for sword; visual faces use72% of those regions (40.3/51.3 pixels before their small inset). Anchored compact groups retain distinct nonoverlapping targets. Screen-transform changes are detected after resize, so a delayed stretch update cannot leave controls twice as large. Saved settings now offer Compact0.8, Standard1.0 and Large1.15. Existing saved Standard becomes smaller automatically.

Mobile sizing uses48 multiplied by the OS display scale as the output target before conversion back to game coordinates. This is a density-aware approximation, not a certified physical point measurement on every Android/iOS backend. Actual phone thumb comfort remains unverified. On very small viewports the layout also fits within safe bounds. Desktop touch controls remain opt-in; normal desktop play uses keyboard input.

Research: [Apple WWDC24 Design advanced games for Apple platforms](https://developer.apple.com/videos/play/wwdc2024/10085/) recommends independently anchored groups and device-appropriate sizes rather than scaling the entire game interface indiscriminately. Its44pt guidance is not44 game pixels. This implementation explicitly distinguishes output pixels from game coordinates; physical-device validation remains needed.

Verification: mobile_ui passed at1280×720,1600×720,960×540,1920×1080 and1024×768. Standard sword target remained71.3 outputpixels and visual canvas51.3 across those desktop tests; skill target remained56.0. Tests also cover Compact/Standard/Large, mirrored layouts, complete target containment and nonoverlap, multitouch, pause release, privacy navigation and settings persistence. Native1152×648 capture confirmed1.8 screen scale,71.27 sword hit region and51.32 visual canvas; screenshot inspected at docs/qa/responsive-controls.png.

Rams quick_review was called with via rules after edits; it returned ran:false due to exhausted credits. No automated design approval is claimed.
