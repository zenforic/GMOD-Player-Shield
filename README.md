# Player Shield Mod
> Version 1.3a

Player Shield Mod is a server-side addon for GMod providing anti-griefing features.

**Features:**

- 120-second default modifiable Initial spawn kill protection (configure on variables section)
- 60-second default modifiable Spawn kill protection (configure on variables section)
- 45-minute default modifiable Shield loss cooldown (configure on variables section)
- "Peace" mode

**Dependencies:**

- Ulysses Mod (ULX + ULib)

**"Peace" Mode:**

Peace mode may be activated by sending `!shield` or `!neutral` in chat, disabled by typing `!forfeitshield` in chat. While activated, one is unable to be killed. If, however, they kill another player their shield will be removed and other players can kill them again with a 45 minute re-activation cooldown.

**Anti-Spawn Kill:**

The spawn kill protection works similar to the "peace" mode, but rather than when they kill a player it is stripped when they harm a player.

**To-do:**
- Add modifiable CVars for cooldown.

**Admin Commands:**
- `!disableshield player` - Revoke shield from the given player.
- `!removecooldown player` - Reset shield cooldown from the given player.
- `!resetcooldowntimers` - resets all cooldown timers.
- `!resetshields` - Reset shield cooldown timers and revokes all shields.
