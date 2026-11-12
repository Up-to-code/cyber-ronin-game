# Menu spacing and flat settings repair

The touch-settings screen previously required more height than the safe content area at the640×360 logical viewport. Six40px actions plus the heading and9px gaps overflowed the centered menu; changing scale would compress artwork instead of solving the content budget.

Menus now use a bounded ScrollContainer while rows retain their minimum heights. Standard-height menus use6px consistent gaps and fit without scrolling; smaller logical viewports scroll, including automatic keyboard-focus scrolling. Action textures retain the red/ivory pixel style. Toggle rows no longer inherit the ornamental Button outline: they use flat label rows and a compact borderless pixel track/knob, with a subtle bottom focus indicator. The volume meter also drops its external ornamental frame.

The start screen has a left identity column with the app icon/title and a right action column in landscape layouts. Its generated START image is one interactive Button without a second nested button frame. START always starts the first route; a separately labeled CONTINUE resumes saved progress. Narrow layouts stack the columns and scroll instead of shrinking buttons.

Verification:
- menu_clean_layout passes4physical window sizes, stable row heights/nonoverlap, safe scroll bounds, flat setting styles, Start/Continue semantics, a480×280 logical fallback and keyboard-focus scrolling.
- mobile_ui, defeat_ui and pixel_menu_components pass.
- Native screenshots were inspected: docs/qa/menu-clean/title-after.png, settings-after.png, touch-after.png and audio-after.png. settings-before.png is copied from the prior shipped component screenshot, not reconstructed.
- Rams quick_review requested with via=rules for final UI files; ran:false because workspace review credits are exhausted. No Rams approval is claimed.

Phone comfort remains unverified; tests establish layout and input behavior rather than subjective appearance.
