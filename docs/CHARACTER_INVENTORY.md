# Ronin armory

The armory presents the current ronin's animated idle art on the left, current sword/health and Q/H stock underneath, and a scrollable skill shop on the right. Crimson/gold image frames, pixel font and pickup/relic icons reuse the game's art. Tab/focus navigation follows the scroll; Esc closes. Purchase refresh restores focus when the same action remains available.

`SkillInventory` owns ranks and consumable counts, never currency. `load_state(dictionary)` validates/clamps data; `export_state()` returns independent dictionaries. `purchase(id,wallet)` returns `{ok,wallet,message}`; caller owns committing both resulting wallet and model state together. Failed or capped purchases leave wallet/state unchanged. Charges cannot be topped up while stock remains.

Permanent blade discipline has five ranks at +15% sword damage each. Iron heart has three ranks at +20 maximum HP each. The tidal nova and crimson elixir packs each contain exactly three uses; Q deals 85 close-range damage and gives half a second of protection, H restores 55 health. H at full health does not consume a charge. Neither retry nor applying upgrades refills consumables. Both consumables work underwater.

Player API: `apply_skill_inventory(model, refill_health=false)` after purchase; pass true after level reset. `use_inventory_skill(id)` is available to mobile/controller UI; keyboard Q/H is already handled. `inventory_consumed(id)` fires after successful consumption so parent can persist immediately. Damage multiplier applies to grounded and swimming sword attacks/charged sword, not every projectile.

UI API: `setup(model,wallet)`, `refresh(wallet,message="")`, `purchase_requested(id)`, `closed`. Parent owns pause state, B/open button, wallet persistence and model lifetime. The component does not save a duplicate wallet.

Verification: skill_inventory.gd passed affordability/deduction, rank caps, pack caps, healthy-use rejection, consumption, retry persistence, state serialization/clamping. moving_sword_facing and swimming regressions pass. Native screenshot docs/qa/inventory-native.png was inspected at1152x648. Rams quick_review was attempted with rules context; tool has no via parameter and returned ran:false because review credits are exhausted. No Rams findings were available to fix.
