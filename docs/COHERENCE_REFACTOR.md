# Whole-game coherence refactor

## Why this pass is broader

User screenshots confirmed a conflicting new cloud style over existing sky clouds, noisy mixed control frames and heavy architectural repetition. The reported poor motion/audio experience requires full action sequences rather than isolated numerical tests.

## Presentation direction

One stepped pixel language: dark ink controls with ivory glyphs, cyan/ivory player blade effects, coral enemy attacks. Remove the second cloud overlay. New separated mountains and near castle art permit independent depth motion; the original sky supplies its own coherent clouds. Early castle maps use the new near architecture; other themed maps retain their themed artwork over the shared far layer.

Camera uses damped horizontal look-ahead, bounded vertical jump tracking, and short impact offset. Neither camera shake nor parallax moves collision bodies. Level loads reset camera tracking to prevent a fly-through from the previous map.

## Source-backed decisions

- [Itay Keren: Scroll Back](https://www.gdcvault.com/play/1022243/) covers camera behavior tailored to platformer mechanics; look-ahead and vertical tracking here are project-specific choices, not universal copied constants.
- [Saint11: Consistency](https://saint11.art/blog/consistency/) explains palette and pixel-scale coherence. The rejected cloud overlay is preserved on disk but no longer instantiated.
- [Godot parallax](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html) explains independent layer response and repeat coverage.
- [Halo Infinite audio team](https://www.halowaypoint.com/en-us/news/inside-infinite-march-2021) describes prioritizing clear sound feedback; our implementation separates motion from confirmed contact and replaces synthetic movement cues with recorded material sounds.

## Confirmed gameplay faults repaired

Visible death animation did not advance; invulnerability flashing affected only the hidden legacy sprite; retry left stale state; and enemy strikes from behind could knock the player the wrong way. These are source/runtime defects, unlike subjective claims that an art or music choice is enjoyable. Main scene now derives death delay from the visible cel profile and enemy projectiles pass their actual travel direction into damage handling.

The independent gameplay audit documents the sampled play loop and its limits. A native movie and frame inspection establish the applied presentation, not human enjoyment, phone performance, or a complete audit of every encounter.

## Validation

Passed recovery_flow, power_actions, kick_states, air_slash_energy, mobile_ui, feedback_separation, effects, audio_palette and native audio_combat. Native 60 FPS capture `qa/coherence-play-loop.mp4` samples movement, jump/slash, energy, kick, injected lethal hit, defeat screen and retry. Injection is deliberate to make defeat repeatable; this is not a claim that a human played a complete campaign. Rendered action/defeat frames were inspected. Audio clipping tests do not establish perceived sound quality. Phone speaker listening, thumb comfort, and complete authored character redraw remain open. Rams review was attempted but credits are exhausted.
