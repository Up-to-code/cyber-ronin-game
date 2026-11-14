# Sentinel override

Level 11 retains its patrol traversal and adds a sentinel cockpit on the exit terrace. Clear patrols, stand centered on the pad for two seconds, then enter UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT SPACE. Arrow keys or the corresponding movement bindings work. Wrong gameplay actions reset progress; the sixty-second countdown continues. Pause freezes the encounter. Timeout kills the player through the normal retry flow. Success fires a beam, shatters the sentinel, lowers the tethered platform, opens the glass, and allows the exit once patrols are cleared.

Art now uses generated crimson-and-gold cockpit, glass, piston, sentinel and four impact frames from assets/archive/crimson-gold, with the existing Pixelify font. The supplied drawing rendered black. The sentinel is an encounter prop, separate from the campaign's regular combat bosses. Keyboard input is supported; dedicated touch sequence buttons remain future work.

Follow-on level ideas (not implemented):
- A pressure forge: alternate left/right pumps, then release at a visible heat mark to launch a bridge.
- A mirror relay: rotate three reflectors while safe zones move, then redirect the boss beam into its shield.
- A freight elevator: memorize a short symbol sequence during stops; successful inputs restore power to the next floor.

Validation: Godot editor import and tests/sequence_machine.gd cover wrong-input reset, unchanged deadline, exact sequence, laser phase, player release and timeout death. Rams quick_review was attempted; workspace credits were exhausted. The tool schema has no via argument.
