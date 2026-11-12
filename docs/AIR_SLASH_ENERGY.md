# Air slash and X energy blade

The previous `_start_attack()` converted every airborne J press into a plunge. The plunge loop then forced downward velocity, overriding the jump arc. J now starts the ordinary sword action while gravity continues from the existing velocity. DOWN + J retains an intentional plunge. This preserves a deliberate downward action without trapping every airborne sword input.

X invokes a 35-power energy slash: a 65-damage projectile moving at 1100 world pixels/second for up to 0.8 seconds, with a cyan/ivory core and purple outer trail. The projectile starts close to the actor to reach nearby enemies, and the action never also applies melee damage. I remains the 25-power blade. It is a stylized energy blade, not a physical optical laser simulation. Stone collision stops it.

Damage uses swept ray collision each physics step to avoid tunnelling past a target at high speed. The physical simulation explicitly runs at 60Hz. This does not manufacture 60 unique drawn poses per second; animation drawings still use their intentional holds. Air sword reuses authored sword poses, with gravity independent of their timeline.

Primary references researched:
- [Godot CharacterBody2D/3D](https://docs.godotengine.org/en/4.7/tutorials/physics/using_character_body_2d.html): velocity controls character movement and gravity must be supplied by game code.
- [Godot physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html): physics callback and collision response separation.

Regression test `air_slash_energy.gd` verifies upward momentum after J, exactly one 65-damage hit at close and distant positions, 35-power cost and rejection without power. Existing explicit plunge test now holds DOWN. Projectile trail is transient presentation and has no second damage channel.
