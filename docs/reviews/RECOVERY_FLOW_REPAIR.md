# Gameplay transition review: hit, death and retry

Scope: actor code and isolated runtime sequence, 11 November 2026. This is a gameplay transition review, not a certificate of animation appeal or a full six-map playthrough. Existing default slim-ronin identity, damage values, gravity, jump assists and power costs are preserved.

## Confirmed defects and repairs

| ID | Evidence | Mismatch | Repair | Verification |
|---|---|---|---|---|
| FLOW-01 | Source + runtime visible cel frame index | Death animation used progress zero for the visible character while the hidden legacy sprite advanced | Actor-owned death elapsed time, visible profile duration, clamped progression | Frame index advances after lethal hit |
| FLOW-02 | Source + runtime rendered-node modulation | Invulnerability indication changed only the hidden sprite | Gentle alternating opacity on the active cel during the existing 0.7s grace period | Visible rig alpha changes; repeated hit is rejected |
| FLOW-03 | Source + isolated reset | Retry helper left kick buffer, low-crouch and death state populated | Clear pending inputs, posture, death timer, hit state and immunity; restore standing collider | Seeded stale states cleared; living cel resumes |
| FLOW-04 | Source + directional hit case | Hit push always used negative player facing, which reverses response when struck from behind | Optional signed hit direction; guard passes attack facing | Back hit pushes away from attacker |
| FLOW-05 | Source + combined action case | Buffered jump could survive damage and trigger after interruption | Damage cancels pending action inputs | Pending kick/jump cleared by hit |

`player.death_duration()` exposes the visible clip duration to the main scene's defeat delay. Projectile damage should pass its signed horizontal direction into `take_damage` too; main integrator owns that system.

## Evidence coverage

- Movement/jump and power action regression suites: runtime mechanics only; full normal-speed animation playback remains unreviewed here.
- Hit, immunity, death and reset: isolated runtime reviewed, including actual visible cel state/frame indices. Native visual appearance is for the integration capture.
- Mobile UI, art consistency, audio mix, VFX and camera: owned by other workstreams, not reviewed by this actor pass.
- Late-map progression, boss balance, phone comfort and enjoyment: not reviewed.

## Primary mechanism reference

[Godot physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) describes fixed physics updates and explicit collision response for character bodies. [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) distinguishes requested velocity from the actual motion after sliding. These references explain the mechanism; they do not validate animation taste.
