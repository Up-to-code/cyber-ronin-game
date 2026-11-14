# Menu-session ownership

MenuSession owns whether the route is playing, paused, loading, showing an armory/chapter, or showing a result. The scene delegates lifecycle requests; HUD retains its internal screen stack and title/settings/artwork presentation. Existing route progression, purchases and skill preview isolation stay in their own modules.

Opening the armory records its origin and originating focus control. Closing restores title/settings pause and focus, or returns to playing with gameplay controls and no GUI focus. The player input buffers and touch actions are released at session transitions. Gameplay keeps the combined armory; title inventory/skills actions retain their filtered views.

Loading, retry, title return, story and defeat invalidate older session callbacks. A late armory Close cannot resume a loading/result session. A stale defeat or story callback cannot cover or resume a different route. Loading failure returns to a paused title session. The scene no longer assigns global pause state directly; its started/transitioning properties read the session state. Gate objective attempt cancellation remains owned by route progression.

Ten relevant headless suites passed: menu_session, citadel_menu, armory_grid, armory_integration, campaign_navigation, portal_passage, gate_runtime_audit, sequence_machine, underwater_integration, and mobile_ui. The new integration fixture uses real title/settings/armory controls and covers origin focus, input release, playing return, pause/back, retry interruption, death/result, stale callbacks and loading failure. Existing 100-gate lifecycles and physical underwater/portal checks pass. Logs/results are in qa/menu-session-refactor.

The native menu transition test also passed; its title-return capture was inspected. Headless touch tests cover simulated input and eight layouts; this is not a physical-phone comfort review. The existing portal-passage fixture still reports five ObjectDB instances during teardown.

Rams quick_review was requested with rules in context for the UI session coordinator. It returned ran:false because the workspace review credits are exhausted, so no Rams approval is claimed. Local focus, transition, layout and input checks passed.

CONTEXT.md defines Menu session. The existing artwork and active armory-grid work were retained. The macOS playtest build uses the installed signed Godot bundle and deep/strict verification.

Rebuilt packaged level-4 startup smoke passed without reported script errors.
