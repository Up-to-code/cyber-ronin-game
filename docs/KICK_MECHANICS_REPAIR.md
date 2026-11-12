# Kick input, geometry and gravity

Reviewed Godot's CharacterBody2D documentation: https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html. CharacterBody2D uses script-controlled velocity and move_and_slide; gravity is not automatic. This game already integrates shared WorldRules gravity every airborne physics tick.

Verified source defects: kick taps during recovery were lost; crouch clearance was forcibly removed while attacking; action sockets were read before the contact drawing was applied; vertical attack eligibility compared feet origins rather than the kicking foot against a torso.

Repair: one queued kick survives recovery/short dash without held auto-repeat; crouch clearance remains during its kick; contact sockets use current action pose; kick vertical contact tests the torso span. Gravity continues through aerial kicks. A stone-wall ray blocks kicks through walls, emits contact feedback and imparts brief backward velocity. Enemies retain their existing mass/impulse hit responses. Walls remain static collision geometry, not arbitrarily translating with every hit.

The existing kick drawing is reused; a purpose-drawn low-kick and aerial-kick pose library is still needed for complete visual specificity. Collision and input improvements are not claims of finished animation.

Tests: kick_states exercises crouch clearance, crouch hit, recovery buffering, aerial foot/torso hit, continuing gravity, landing and wall recoil/blocking. authored_contact, combo_air_jump and power_actions also passed before the additive wall probe.
