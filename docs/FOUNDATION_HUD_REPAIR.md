# Foundation and guidance repair

Underground and citadel solid platforms now render existing masonry textures over the collider footprint instead of large plain color rectangles. Textures tile at native pixel scale; a short recessed shadow joins them to the existing cap. Cloud platforms, collision dimensions and platform topology are unchanged. Each foundation uses at most three visual children.

The objective guide uses content-measured width, a smaller translucent backing and tighter two-line spacing. Typical guidance is 148 logical pixels wide and 35 high (previously300×56). Detailed laser/cloud/cockpit cues remain readable, with the full objective retained in tooltip/accessibility metadata. Narrow safe parents position guidance alongside the health cluster rather than under it.

Validation: `foundation_hud_repair.gd` passes four safe-parent sizes × five objective kinds, checks compact bounds, and verifies textured foundation geometry/node bounds. Native staged captures on routes3,6,26 were inspected (`docs/qa/foundation-hud-{3,6,26}.jpg`). No packaged build produced by this task.

Rams quick_review was called after UI edits with `via: rules` in context (tool schema exposes no via argument). Both requests returned `ran:false`: workspace15 one-time review credits exhausted. No Rams review approval is claimed. Local runtime layout checks completed instead.
