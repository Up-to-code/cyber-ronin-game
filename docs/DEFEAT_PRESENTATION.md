# Defeat presentation

A dedicated dark card replaces the generic two-button result menu. It identifies the current route, gives a clear FALLEN RONIN outcome, connects to the monastery story, and presents Retry this route as the primary action. Main menu is secondary. The card fades in over a stronger scene scrim after the actor death sequence; its tween runs while paused. Retry owns initial focus and both actions have explicit focus neighbors. When the player is defeated, the HUD also hides the touch pad for the whole death beat and restores it on the next route, so no live-looking controls sit over a dead actor.

The HUD still emits existing retry/menu signals; it does not reset gameplay or trigger death sounds. Actual death audio belongs at the controller event, before the delayed result card.

`defeat_ui.gd` verifies route text, initial focus, gameplay hiding, single action dispatch, safe-area containment and nonoverlap at three window sizes, and `death_presentation.gd` verifies that defeat hides the touch pad at the lethal hit and that retry restores it. A standalone native capture was inspected and saved to `qa/defeat-card.png`. Integrated scene timing/audio remains the parent capture's responsibility.

Rams quick_review was requested with via rules; it could not run because workspace review credits are exhausted. No Rams approval claimed.
