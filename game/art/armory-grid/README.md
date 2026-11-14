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
