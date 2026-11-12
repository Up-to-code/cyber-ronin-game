# Samurai attack research and button review

## Targeted research

Queries included “samurai attack”, katana attack/sword sound effects, kesa-giri, gyaku kesa-giri, kirioroshi, nukitsuke/iai draw, tsuki thrust and tachikaze. These search terms distinguish cut direction, draw, thrust and contact instead of treating every action as a generic whoosh.

Sources:

- [Taira Komori: Samurai/Ninja sound effects](https://taira-komori.net/jidaigeki01en.html): actual catalog entries for sword attacks, katana cuts and sword extraction. Four source recordings are now used in edited gameplay cues; the extraction recording remains a reference because the character has no authored draw-from-sheath move. [Creator terms](https://taira-komori.net/freesounden.html) permit game use but prohibit standalone sample redistribution. This source is **not CC0**. Terms/provenance: `game/licenses/tk-samurai-terms.txt`; creator credit and homepage link are in Credits.
- [Kenshin Dojo sword-work glossary, page 8](https://kenshindojo.ca/wp-content/uploads/2018/02/IAIDO_Terms_KSD.pdf): downward diagonal, upward diagonal, vertical cut, draw-cut and thrust are different motions. These are research references; this pass does not claim to turn the existing sparse cels into authentic iai forms.
- [Yasuragi Dojo: Gyaku Kesa Giri demonstration](https://www.youtube.com/watch?v=-CFtTt8r1kE): practitioner demonstration describing an upward diagonal path and controlled finish. Reference only; no video/audio ripped into the game.
- [OGAWA SOUND: KATANA](https://www.ogawasound-online.com/en/katana): specialist commercial reference for separate cutting, piercing, empty-swing and draw layers. Not purchased or shipped.
- [VD Sounds free sample pack](https://vdsounds.itch.io/medieval-combat-swords-sfx-lite): researched alternative with separate draws, hits and clashes; not integrated. Its description states synthetic production; no quality verdict is inferred from that.

## Sound changes

`tools/build_katana_audio.py` prepares normal/alternate/reverse/heavy cut motion from TK's two sword-attack recordings and contact/alternate-contact from two katana-cut recordings. Armor contact combines the katana contact with the existing quieter steel layer. Charged motion uses the heavier cut. Each action still owns its contact/launch phase and the measured envelope lead; double taps emit two separately timed cuts rather than a pre-recorded two-hit sequence.

Other packs remain by role: artisticdude for kick/enemy air strokes, SpritePilot for selected body/energy layers, MentalSanityOff and qubodup for ground contact, Kenney for walking and other Foley. Ground sounds and physics from the previous pass were not modified here. Device/headphone listening is still needed; resource/timing checks do not establish artistic approval.

No standalone audition of TK's licensed sounds is distributed. The evidence is a game/menu recording, `docs/qa/katana-ui.mp4`.

## Verified UI defects and fixes

- **MAIN MENU on the defeat card used a panel style**, adding 26 px above and 20 px below the label despite a 40 px requested row. It now shares the actual button style with Retry: 9 px above/below, the same 17 px font and 44 px row.
- A single `PixelUI.button_style()` defines navigation text insets and preserved artwork corners. HUD, map cards, defeat actions and story Continue use it. Pressed art remains crimson; hover has the same art as rest. Disabled map buttons retain pixel artwork.
- Standard menu text is 17 px, row height at least 44, and stack gap 8. Map cards have enough width for their actual labels. Redundant breadcrumb text is removed.
- Touch Layout uses a two-column grid when at least 560 logical px are available and one column below that. On the wide layout, Back is visible without the previous small scroll. Narrow layouts scroll instead of squeezing the rows.
- Combat touch targets form a tighter fan, with a 60-unit primary sword target and 44-unit skill targets, responsive scaling, and clearer faces occupying 82% of the target. Desktop desired skill size is 52 output pixels; the mobile 48-point/density policy is retained. Visible face and input bounds remain separate. Physical-phone comfort still needs a play pass.
- Direction-pad centers now have a small real gap; previously just-touching edges could overlap by floating-point rounding at some output scales. Independent multi-touch and handed layouts remain supported.

## Verification

Passing checks: `button_metrics`, `menu_clean_layout`, `mobile_ui`, `defeat_ui`, `pixel_menu_components`, `motion_audio_sync`, `attack_resource_roles`. The metrics check covers all eleven menu states at four sizes, tests every text label against the style's available content width, minimum row size and matching defeat actions. Mobile tests cover seven output sizes, three scale settings, both handed layouts, target bounds, actual multi-touch, pause release and saved settings.

Native captures inspected: defeat, touch controls and Touch Layout. Full menu/attack recording: `docs/qa/katana-ui.mp4`. Frame screenshots sit in `docs/qa/katana-ui/`. These are desktop engine captures, not physical iOS/Android evidence.

Rams `quick_review` was requested with `via: rules` after UI edits, including the final grid/layout changes. It returned `ran:false` because the workspace's 15 review credits were exhausted. There is no Rams approval. Local geometry/interaction checks and image inspection were completed independently.
