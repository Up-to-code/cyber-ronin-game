# Stop-to-idle follow-through

Run/walk → idle triggers a 4.5% maximum damped compression wave (18 rad/s, damping 9/s), applied around the existing foot anchor. Continuous breathing uses an independent clock so it does not restart on every state transition. The eight existing idle drawings continue looping. This adds presentation movement, not new generated frames or independent limb articulation.

Research: Animation Mentor, Follow-through and Overlapping Action: https://www.animationmentor.com/blog/follow-through-and-overlapping-action-the-12-basic-principles-of-animation/ ; tutorial: https://www.animationmentor.com/blog/tutorial-overlap-pendulum-motion-animation/ . Main takeaway: settle after locomotion; secondary parts should lag the main mass. Independent scarf/arm overlap remains future drawn-pose work.

Validation: aerial_motion passes; jumping still traverses takeoff/rise/apex/fall/landing drawings and returns to ground. No collider or input timing changes.
