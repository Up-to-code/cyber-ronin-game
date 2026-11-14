# Generated buttons, event audio and defeat

The user explicitly requested image-generated pixel-art controls. The runtime now uses a coordinated dark-red lacquer/brass atlas with ivory directional/melee icons and turquoise ability icons. The procedural polygon/glyph faces are removed. Combat buttons form two aligned rows: ranged/power above kick/sword/energy. Directional controls retain their cross with tighter spacing. Stable touch targets remain larger than artwork; responsive sizing and saved preferences continue to work.

Five viewport checks pass for independent touches, alignment, safe-area containment, nonoverlap, fixed output size and persisted customization. Generated source and packing notes are in assets/art/pixel/buttons-v3. Native action/defeat screenshots were inspected.

Landing audio selects light/heavy cues from actual impact velocity. Sword combo stages and enemy blade/fire attacks have distinct cues. The once-only defeat event suppresses combat audio and fades music; level population and return to title restore the audio state. Tests exercise actual falls and combo contacts, not just existence of filenames. See AUDIO_EVENT_REDESIGN.md.

The defeat card provides current-route context, primary retry and secondary main menu, focus navigation and a paused-safe transition. See DEFEAT_PRESENTATION.md. Native visual checks and functional audio tests are not subjective listening approval. Rams rules review was requested for changed UI but could not run because review credits are exhausted.
