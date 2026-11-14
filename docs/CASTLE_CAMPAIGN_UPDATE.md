# Castle campaign update — 2026-11-11

The previous two-room prototype is now a six-map campaign. Runtime geometry is authoritative in game/data/campaign.gd. Each map has its own terraces/gaps/lifts, supported guard spawns, exit and camera width. The final captain has an elite health pool. The design remains a prototype rather than a finished boss system.

Generated additions: castle skyline, castle rooftops, bamboo moat parallax layers, castle rampart platform, and eight-frame torch loop. Raw sources and prompts: assets/art/pixel/castle-source. Exporter: tools/process_castle_assets.py. Runtime art: game/art/pixel. The existing generated torii gate remains the real exit object; the former line-drawn outline is not in current code.

Movement: A/D walks at180; Shift runs at300. Mobile RUN toggles sprint and accepts a separate finger while movement/attack are held. Walk/run clips advance separately, footsteps follow animation cycle markers, and takeoff/landing deformation keeps feet registered. See docs/LOCOMOTION.md.

Loading: thread-loaded map textures report their actual status, followed by route construction and a short fade. Loading blocks gameplay/back input. Map selection saves unlocks, Continue opens the latest unlocked map, and Retry rebuilds the current route. Required music attribution is in the Credits screen.

Audio: the rejected sword pack and old drone are removed from runtime. Exploration uses Mountain God's Shrine, battle uses Shamisen Samurai Rock, with a threat-driven1.2s crossfade. Original short cloth/stone/katana effects match takeoff, landing, foot contacts, attack release and confirmed hits. License/source details: docs/AUDIO_REVISION.md and game/audio/MUSIC_CREDITS.txt. Native output checks passed; recorded demo peak approximately-8.4dB, no clipping.

Subagents implemented audio, locomotion and map data/runtime checks. Parent integrated terrain, loading/menu/mobile controls, generated art and final verification.

Verification: Godot import/per-script parsing/smoke; distinct locomotion/animation test; coyote/buffer/variable-height/moving-platform tests; all six actual loading transitions and supported spawns; representative actual sprint jumps on every map and full first moving-bridge crossing; synthetic simultaneous movement/attack/sprint and pause release; native slash/sparks/dust/audio signal; rendered title, map selector, loading screen, rooftop/bamboo scenes and generated exit.

Tests inject approach positions before representative gap crossings; they do not constitute a full human playthrough. Desktop landscape/wide-phone layouts were checked; physical-device build/signing/testing remain pending. Rams was attempted with via=rules and could not run because review credits are exhausted.

Current demo: docs/qa/castle-campaign.mp4. The demo uses scripted input and freezes guard AI to isolate movement and contact. It includes the new music/effects and is not a complete campaign playthrough.
