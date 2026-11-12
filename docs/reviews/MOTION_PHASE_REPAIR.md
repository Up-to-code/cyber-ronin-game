# Jump phase and kick pacing repair

Research consulted before edits:

- [Animation Mentor: body mechanics](https://www.animationmentor.com/blog/animation-tips-tricks-what-makes-or-breaks-a-good-body-mechanics-shot/): breakdown poses explain lead/follow and the force behind a movement. Correct coordinates alone do not supply the missing drawings.
- [Maddy Makes Games: Celeste and Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/): coyote time and buffered jump input improve tolerance. Existing 120ms coyote and 140ms input buffer were retained. These assist mechanics, not animation quality.

Source evidence: ronin_cel's jump/apex/fall clips previously each contained one held frame. The source sheet contains 16 jump drawings, but only isolated frames were being displayed. This made upward and downward motion slide a frozen silhouette through the world.

Changes: takeoff uses source frames 0–2; ascent 3–6; apex 7–9; descent 10–12; landing 13–15. Ascent/apex/descent progress follows velocity, so an air jump or released short hop updates the displayed phase immediately. Takeoff and landing remain tied to their existing controller windows. Acceleration/deceleration below walk speed now selects the available walk cycle before entering run. Neither collision geometry nor gravity was changed.

Kick's six pose records were held for 470ms with 135ms before contact. New timing is 15ms rest, 65ms chamber, 35ms contact, 65ms recoil, 85ms recovery, 35ms rest (300ms total; contact starts at 80ms). Damage and effects inherit contact timing from the profile rather than a second timing constant. Reach/damage/cost remain unchanged.

Limits: kick still has four unique action drawings plus a shared rest pose; faster pacing does not create missing in-betweens. The source jump/walk art is still compatibility art and differs from the new idle/kick redraw. A coherent full redraw is still needed. No full-body interpolation or fake additional poses were added, and these tests do not establish perceived smoothness.

Validation: authored_contact.gd passes displayed-contact timing, once-only hits and planted support. New aerial_motion.gd runs a real held jump and verifies multiple distinct displayed frames in all five aerial phases, followed by ground contact. Native audiovisual review should cover short/full/double jump, walking into a kick, standing kick and interruption before claiming artistic completion.
