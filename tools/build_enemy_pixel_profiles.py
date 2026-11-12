"""Pack metadata for the registered 8-pose enemy atlas; never synthesize drawings."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
for row, kind in enumerate(("guard", "fire", "wraith")):
    def frame(column, duration, contact=False):
        record = {"rect": [column * 128, row * 128, 128, 128], "duration_ms": duration}
        if contact:
            record["events"] = ["foot_contact"]
        return record
    clips = {
        "idle": {"frames": [frame(0, 600)], "loop": True},
        "walk": {"frames": [frame(1, 120, True), frame(2, 120), frame(3, 120, True), frame(2, 120)], "loop": True, "stride_world": 180},
        "float": {"frames": [frame(i, 180) for i in (0, 1, 2, 3)], "loop": True},
        "windup": {"frames": [frame(4, 320)]},
        "attack": {"frames": [frame(4, 100), frame(5, 50), frame(4, 90), frame(0, 80)]},
        "hurt": {"frames": [frame(6, 420)]},
        "death": {"frames": [frame(7, 1300)]},
        "air": {"frames": [frame(6, 100)]},
    }
    profile = {
        "id": kind + "_pixel", "display_name": {"guard": "Crimson guard", "fire": "Ember keeper", "wraith": "Bell wraith"}[kind],
        "status": "Generated authored key-pose redraw, eight drawings per enemy; sparse motion proof, not a finished high-frame-count animation.",
        "atlas": "res://art/pixel/enemies-redraw.png", "scale": 2, "feet_origin": [64, 112],
        "body_center_height": 58, "max_visual_roll": 0.3,
        "sockets": {"hand": [84, 82], "foot": [80, 108], "weapon_tip": [109, 76], "chest": [64, 73], "pelvis": [64, 87]},
        "state_map": {"run": "walk", "walk": "walk", "charged": "windup", "jump": "air", "fall": "air"},
        "clips": clips,
        "attacks": {key: {"clip": "attack", "contact_frame": 1, "active_end_frame": 1, "duration": 0.32, "damage": 15, "reach": 90, "cost": 0, "provisional_contact": True} for key in ("sword1", "kick")},
    }
    if (ROOT / "game/art/pixel/enemy-movement.png").exists():
        def movement_frame(column, contact=False):
            record=frame(column,100,contact)
            return record
        profile["clips"]["walk"]={"atlas":"res://art/pixel/enemy-movement.png","frames":[movement_frame(i,i in (0,4)) for i in range(8)],"loop":True,"stride_world":96}
        profile["clips"]["float"]={"atlas":"res://art/pixel/enemy-movement.png","frames":[movement_frame(i) for i in (0,1,2,3,4,6,7)],"loop":True}
        profile["status"]="Whole-character pixel enemy with separate movement atlas and action key poses; several generated movement drawings are near repeats, not a complete high-frame animation."
        profile["movement_status"]="Eight source movement drawings, several near repeats; uniform per-character scale, registered head/mask and ground baseline; distance cadence96worldpx."
    path = ROOT / "game/animation/profiles" / (kind + "_pixel.json")
    path.write_text(json.dumps(profile, indent=2) + "\n")
