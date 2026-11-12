# Enemy movement registration and cadence

Source/runtime review found two specific causes of the reported jumping/stutter:

- The old four-record gait used a180-world-pixel stride. At the guards'84px/s travel speed this advanced only1.9 drawings per second, with roughly half-second holds. This stride had been carried across from a faster-moving hero.
- Wraith frames were placed using the lowest cloth pixel. Cloth lengths and mask poses vary, so the ivory face moved from y68 to y82 in the128px cell during a hover/action change, even when the actor did not move. This was an artwork-registration defect, not physical hovering.

The new generated movement sheet supplies eight source drawings per type. Several are near repeats, so it is not a claim of eight carefully differentiated gait phases. One open-jaw wraith drawing was omitted from the quiet hover loop because it reads as attack. No scripted in-between poses or crossfade blur were created.

`tools/pack_enemy_movement.py` applies binary transparency, uniform scale per character, a shared palette and nearest-neighbor packing. Guard/fire heads register against their existing idle positions; soles remain at y112. The wraith's mask is registered at(64,68), independently of its changing cloth bottom. Existing wraith windup/contact/hurt drawings receive the same correction in `tools/pack_enemy_redraw.py`, including a post-palette anchor check. The fallen death drawing retains its deliberately lowered pose.

The distance-driven gait now uses a96-world-pixel stride: at84px/s it changes drawings about7 times per second instead of1.9. Simulation/render transforms remain60Hz; this does not imply60unique drawings. The normal idle-to-walk change preserves head placement instead of introducing a horizontal reset. Attack timings, contacts, collision, hover physics, damage and sound rules are unchanged.

Tests passed: enemy_movement, enemy_pixel_visuals, body_physics and animation_library. The new regression checks eight records consumed within one gait cycle, maximum9physics-tick holds, stable drawn foot origins, and mask-center continuity across hover/windup/contact/hurt within3.5worldpixels. Native three-enemy movement capture is `docs/qa/enemy-movement-repair.mp4`; extracted frames were inspected, continuous subjective playback remains unverified. More authored breakdown poses and a human motion review remain necessary.
