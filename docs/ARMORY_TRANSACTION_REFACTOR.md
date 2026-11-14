# Armory transaction ownership

Reproduced the cancelled-purchase leak: after a failed sword purchase save, the inventory returned to rank 0 and coins to 1,000, but the shared ConfigFile still contained rank 1. A later HUD settings save could persist that cancelled purchase. The before-fix reproduction is retained in qa/armory-transactions/before-fix-reproduction.log.

ArmoryTransactions now owns the purchase outcome. It prepares a separate inventory candidate, checks existing prices/caps, and asks SaveStore to commit the candidate wallet and skill state. Only a successful write publishes those values to the live inventory and the shared ConfigFile. The scene receives the outcome and applies player upgrades/messages; it no longer snapshots or rolls back purchases.

SaveStore retains atomic sibling-temp-file replacement and now cleans the temp file after a failed rename. Its default disk writer and a controlled failing writer exercise the same persistence seam. Settings sections are copied into the candidate and preserved. State returned or accepted by SaveStore is copied to avoid shared mutable dictionaries.

Already-consumed charges cannot undo their gameplay effect. A failed consumption save keeps those charges spent in the current session and stages them in shared settings for a later successful save, preserving the existing behavior. A disk failure can still prevent persistence across an immediate process exit; this refactor does not promise durability without a successful write.

Seven suites passed: armory_transactions, armory_integration, save_store, skill_inventory, citadel_menu, rewards_missions, and run_progression. New coverage includes controlled write failure, actual rename failure and temp cleanup, cancelled purchase followed by settings save/reload, exact wallet deduction, pack cap, settings preservation, consumed-charge retry and restart state. Integration checks cover the real scene, player upgrades, armory pause, charge persistence and level-4 gate guidance. Logs/results are in qa/armory-transactions.

The macOS playtest was rebuilt and passed deep/strict signature verification. No UI files were edited by this refactor. Existing menu and route-progression work was retained. CONTEXT.md defines Armory purchase and Consumed charge.

Packaged native level-4 startup smoke passed without reported script errors.
