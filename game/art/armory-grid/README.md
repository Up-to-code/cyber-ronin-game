# Approved grid inventory and skills

Reference: the user-selected `docs/references/armory-concepts/b-grid.png`.

## Runtime layers

- `stage.png`: reconstructed courtyard and dark wave-pattern catalog background, with no character or controls.
- `chrome.png`: transparent interface artwork. Tabs, currency plaque, replay, equipment medallions and detail/buy panels are sliced independently with AtlasTexture.
- `icons.png`: six individually selectable illustrated tiles, sliced independently.
- The perimeter uses the established `art/menu-approved/frame.png` so inventory and main menu share the same frame family.
- All labels, prices, ranks, charge counts, ownership, focus, selection and Buy enabled states are runtime controls.

Images were created with the built-in image-generation editor, with the exact selected reference supplied for each operation. The full production prompt set is in `prompts.json`.

## Gameplay preview

`ui/armory_preview.gd` renders the current player's actual `CelActorVisual` profile and `pixel_fx.gd` effects inside a transparent private World2D/SubViewport. Sword contact follows the shared attack specification and real combo clips; dash uses the existing dash animation and snapshot renderer; nova and healing use the exact gameplay effect families. Passive training displays current and projected stats. No illustrated substitute character or decorative water ring is rendered.

The preview creates no Player2D, input, enemies, projectiles, damage queries or gameplay groups. It has no inventory or wallet reference. Selection and Replay cannot change health, ranks, charges, currency or the live world. Hidden previews stop viewport rendering. The real player profile is supplied when the screen is built.

## Purchases and tabs

Skills includes the four existing offers, the already-learned core dash preview and a clearly unavailable sealed art. Inventory includes four read-only equipped-item inspections and the existing nova/healing packs. Equipped items do not imply a new equipment system.

Only Buy emits `purchase_requested`; existing main-scene purchase/save handling retains authority. Rank pricing, caps, pack counts and persistent progression are unchanged. Selecting an icon merely updates details and replays the local preview. Owned packs cannot be overwritten and unavailable/insufficient-funds offers cannot emit a purchase.

The landscape layout follows the approved half-character/half-grid composition. Tall screens stack these sections in a focus-following scroll container, preserving hit targets and aligning the character to the same courtyard coordinate system. Mobile controls respect display safe areas.

## Verification

- `tests/armory_grid.gd`: no spending on preview/replay, private world and no gameplay groups, actual character clips/effects, exact prices, pack caps, unaffordable and locked offers, both tabs, mobile layout bounds and hidden viewport shutdown.
- `tests/skill_inventory.gd`: existing purchase/consumption/persistence rules.
- `tests/citadel_menu.gd`: main menu navigation and opening/closing inventory/skills while the level remains paused.
- `-- --portrait` on the graphical grid test captures a tall layout; graphical captures go to `/tmp`.

Rams quick_review via rules was requested, but the workspace has exhausted its review credits, so it did not run.

## Motion and feedback refinement

The character preview now has a clearly framed native-pixel training stage using the game's own sky, castle, platform and animated torch textures. `ui/armory_stage.gd` adds low-intensity parallax and motes. A separate generated straw-target sprite (`training-dummy.png`) reacts to preview contact; it is presentation-only and never joins enemy groups.

Sword previews complete all four real attack clips and resolve each VFX socket from the displayed contact pose. The target receives local recoil/flash and a damage number derived from the attack specification and displayed upgrade. A short impact pause affects only the preview's rig/effects; global game time stays untouched. Nova and healing retain their gameplay effect families. Dash now brakes, walks back with the real walk clip and settles at its starting point instead of snapping back.

Complete demonstrations can auto-repeat after a rest. LOOP ON/OFF controls repetition without affecting the economy. Hidden previews stop stage animation and viewport rendering. Character selection cancels the previous sequence and local impact pause immediately.

Selection uses animated corner cues rather than a thick full rectangle. Icon taps have a small settling animation; detail content fades in; currency feedback runs only after an actual wallet deduction. Status badges are compact, and the current selection has initial keyboard focus with explicit grid/action navigation.

`tests/armory_motion.gd` checks dash trajectory continuity, return walking, all four sword clips, contact count, cancellation, local hit-stop, free auto-replay and hidden-stage shutdown. Graphical 60 Hz captures cover dash burst/brake/return and sword contact. These traces and rendered phase checks do not establish subjective motion appeal or audio quality.
