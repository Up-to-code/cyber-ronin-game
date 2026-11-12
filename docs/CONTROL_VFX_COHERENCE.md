# Control and VFX coherence repair

The rejected screenshots mixed textured masonry buttons, colored raster icons and a smooth circular primary button. This pass gives all nine controls one stepped ink-and-ivory frame vocabulary and clean code-authored pixel glyphs. Energy skills use cyan; movement and physical attacks use ivory. Press animation moves only presentation, preserving stable touch shapes, safe areas, mirrored layouts and saved preferences. The primary sword remains larger and central.

These are native UI drawing primitives rather than generated raster replacements. The old icon files remain in the project but are no longer loaded by touch controls.

VFX keeps motion separate from confirmed contact. Removed the duplicate reversed slash overlay and second double-jump dust ring, which previously stacked simultaneous shapes over the actor. Confirmed-hit contour and sparks remain; player blade effects share cyan/ivory, enemy swings use coral. Powerful attacks retain larger silhouettes without unrelated extra arcs. Effects still expire and remain bounded.

Research: [Saint11 on consistency](https://saint11.art/blog/consistency/) supports an internally coherent UI palette/shape system; it does not require UI and world art to be identical. [Game Accessibility Guidelines on target size and spacing](https://gameaccessibilityguidelines.com/ensure-interactive-elements-virtual-controls-are-large-and-well-spaced-particularly-on-small-or-touch-screens/) supports retaining generous fixed hit areas while simplifying the artwork.

Validation: mobile UI behavior/layout tests and feedback-separation expiry test pass. Rams quick_review was requested with via=rules and returned ran:false because workspace credits are exhausted. No subjective player comfort or audio judgment is inferred from these tests.

Native screenshot inspected: `qa/coherent-controls.png`, 1152×648. All nine glyphs are readable with consistent panel shapes and no overlapping hit bounds. Background assets were being rebuilt concurrently; this image is evidence for controls only. Gameplay effect test also passed; final whole-scene capture belongs to integration review.
