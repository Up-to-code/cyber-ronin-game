# The Bell That Would Not Rest

Kuro returns to the monastery to recover its stolen shrine bell. Captain Ren used the bell to bind the shrine keepers into his fire guards and floating spirits, believing their unending service would preserve the sanctuary. Each opened shrine weakens that binding. Defeating Ren releases the keepers and lets Kuro bring the bell home.

The story uses two named characters and the existing six-level route. It does not add inventory, dialogue choices, escort tasks, a bell pickup mechanic, or new quest dependencies. Combat and shrine traversal remain the playable actions; the bell is the narrative reason for them.

| Chapter | Existing map | Narrative purpose |
| --- | --- | --- |
| 1 · The Missing Bell | Monastery Approach | Establish Kuro's goal and the route. |
| 2 · An Order in Embers | Ember Courtyard | Explain the fire guards as bound keepers. |
| 3 · Keepers Without Rest | Bamboo Ramparts | Reveal the floating spirits' former identity. |
| 4 · The Captain's Road | Castle Rooftops | Tie cleared shrines to weakened binding. |
| 5 · A Broken Oath | Broken Sanctuary | Reveal Ren's protective oath becoming captivity. |
| 6 · Let the Bell Rest | Crimson Castle Keep | Confront Ren and release the keepers. |

Narrative data lives in `game/data/story.json`. Every chapter has a title, three short authored lines and one objective; the longest body is under 150 characters. `StoryBook.get_chapter(index)`, `objective(index)`, `chapter_count()` and `completion()` return plain copied data. Missing chapter IDs return an empty dictionary.

`game/ui/story_card.gd` is an optional skippable CanvasLayer. Add it to the scene, then call `show_chapter(index, ending=false)`. It emits `continued` once when Continue, Enter or Escape closes it. `close()` hides it without emitting; `is_open()` exposes ownership state. It never pauses/resumes the SceneTree or stores progression. The game-flow owner should release pending gameplay inputs, pause as appropriate, and resume only after `continued`. Bypass story cards in isolated movement tests and allow replay without repeated narrative interruptions. Use the prologue on a fresh run, chapter cards at deliberate transitions, and the ending after the final captain is defeated.

The card uses the existing dark pixel panel and Pixelify font, a single 48-unit Continue target, explicit focus and a safe-area inset. It consumes action keys while open. These are logical game units, not a physical-phone usability claim.

After `continued`, wait one process frame before releasing pending action input and unpausing. This prevents the key that dismisses a card (for example Space, also bound to jump) from becoming an accidental gameplay action on the same frame. Pause or hide the underlying touch controls while the story owns input; GUI mouse filtering alone does not disable TouchScreenButton input.

Validation: isolated native and headless checks cover six chapter IDs, three body lines under 150 characters, copied data, invalid-ID fallback, focused Continue, safe panel bounds at 640×360, Escape dismissal, exactly one continued event, and epilogue display. Native `/tmp/story-card.png` inspected for typography and clipping. Rams quick_review with `via=rules` was attempted after editing the UI; it returned `ran:false` because the workspace has exhausted its review credits.
