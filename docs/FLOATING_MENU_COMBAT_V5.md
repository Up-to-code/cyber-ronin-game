# Floating title and combat audio pass

## Menu
Generated a separate ASHEN VEIL wordmark with built-in imagegen, reduced to 240 × 150 maximum using nearest-neighbor sampling and thresholded alpha. Runtime title artwork floats ±2 logical pixels over a 5.2-second cycle; action hitboxes remain stationary. Asset: `game/art/pixel/ui-kit/ashen-wordmark.png`.

Prompt: “Transparent pixel-art title wordmark for a dark red samurai game; exact two-line text ASHEN / VEIL, ivory angular katana-cut lettering, oxblood shadow, restrained crimson slash and ash flecks, no frame or background scene, limited palette.”

Volume track is now 8px tall, thumb 6 × 12 rather than 10 × 20. Removed the long yellow focus underline; the thumb brightens on keyboard focus. Native slider input remains intact. Vertical scrollbar width reduced from 10 to 6 logical pixels.

## References and sound direction
- Katana ZERO official Netflix Games trailer: https://www.youtube.com/watch?v=9TpUyq8Ms1I — comparable mobile pixel-art slash/dash game. Research reference, not a source of ripped audio. This pass does not claim a listening comparison against its soundtrack.
- VD Sounds: https://vdsounds.itch.io/medieval-combat-swords-sfx-lite — downloaded free pack, read its included license, commercial game use and processing allowed; standalone redistribution forbidden. License copied to `game/licenses/vd-swords-license.txt`.
- SF Audio Guild: https://sfaudioguild.com/weaponpackfree/ — researched weapon motion/contact categories; demo is personal/noncommercial, so not integrated.
- Existing artisticdude swishes and SpritePilot contact/effect sources remain licensed inputs (see attack-resources-cc0.txt).

New `combat-v5` build replaces TK katana takes for ordinary/reverse/heavy cuts and body/armor contacts. Distinct short light and medium swings; short body transients; metal cue reserved for armor. Kicks use filtered artisticdude air movement plus SpritePilot contact; energy and power use separately filtered SpritePilot effects. No changes to walking, takeoff, double-jump or landing resources. Timing metadata is rebuilt from each cue's energy peak. Random pitch removed from sword/impact playback so motion-lead calculations match playback pitch.

The choice is a new audition candidate, not proof that subjective sound quality is solved. Headless timing tests verify event alignment and role separation, not what listeners enjoy.

## Review
Rams quick_review requested with via=rules for all edited UI files; it returned ran=false because workspace credits are exhausted. No Rams approval claimed.

Validation: button_metrics, menu_clean_layout, mobile_ui, motion_audio_sync and attack_resource_roles passed. Native capture rendered successfully, 16.43 seconds including menu screens and staged combat; title/audio screenshots inspected. Evidence: `docs/qa/menu-v5.mp4`, `docs/qa/menu-v5/title.png`, `docs/qa/menu-v5/audio.png`. Capture uses the level backdrop to exercise overlays; normal welcome artwork remains unchanged.
