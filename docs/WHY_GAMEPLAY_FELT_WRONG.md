# What was wrong, and what each system should do

The game combined several different kinds of problems. A working collision solver did not make the drawn action convincing, and bigger effects could not hide contradictory inputs.

## Airborne sword input

Previously `_start_attack()` automatically selected plunge whenever the character was off the floor. The downward motion was deliberate code, not missing gravity. J now preserves the jump's vertical velocity and performs a normal sword action; DOWN+J explicitly requests a plunge. X fires an energy blade with a single damage path, avoiding two hits when the target is close enough for both a melee hit and a projectile.

## Animation and 60 FPS

Physics advances at 60Hz. Rendering can present movement at 60 FPS, but each cel is an authored drawing held for a chosen duration. Repeating a drawing sixty times does not create sixty new poses. Smooth movement needs appropriate spacing, planted feet, anticipation, contact, follow-through and recovery. The old six-record kick still needs better intermediate drawings and dedicated low/aerial silhouettes. The source jump now uses its full sixteen drawings. We do not label this a complete 60-drawing-per-second redraw.

Global physics interpolation is left off because the current camera follows in render time while moving platforms update separately. Switching it on without aligning those clocks can introduce a new camera/actor mismatch. A fixed-rate movie is a presentation artifact, not a physical-phone performance benchmark.

## Layers and camera movement

Sky was oscillating slowly rather than visibly travelling. It now continuously scrolls with repeated mirrored coverage. A new transparent cloud asset has independent wind and camera-relative motion. Architecture follows a stronger camera ratio, while snowfall uses multiple depth speeds. These are separate layers, not one image moving as a block. Snow bursts are short world-space effects at the feet.

## Combat feedback

A swing should sound and look different from contact. Hits trigger material/body sound, recoil and a brief contact effect; misses show the weapon motion. Stone blocks attacks through walls and produces recoil. Static buildings remain solid architecture. Treating an entire castle as a freely moving rigid body would undermine footing and route clarity.

## Mobile controls and settings

The primary sword sits at the center of the combat cluster; less frequent skills surround it. Touch regions stay fixed while press artwork animates. Saved layout controls let the player adapt size, hand preference and visual opacity. Settings include privacy information and configurable approved policy links; an unconfigured link is not presented as a published policy.

## What remains to judge by playing

The regression tests establish input behavior, costs, hit counts, clearance and landing. They do not prove enjoyment or animation appeal. Dedicated low/air attack artwork, normal-speed audio review, and physical-phone thumb comfort remain separate work. Use the source library's reading path to compare actual sequences, not isolated joint diagrams or API assertions.
