-----[    Player Shield Mod Version 1.2a    ]-----

-- Variables
CATEGORY_NAME = "Shield"
ShieldCooldownDB = {}
SpawnProtectedDB = {}

-- Colors
local yellow = Color(255, 255, 0)
local cyan = Color(0, 255, 255)
local red = Color(255, 0, 0)
local green = Color(0, 255, 0)

-- Helper Functions
local function CSay(t, m, c)
	ULib.csay(t, m, c)
end

local function GetCooldown(Player)
	return ShieldCooldownDB[Player:Nick()]
end

local function SetCooldown(Player, Initialize)
	if Initialize then
		ShieldCooldownDB[Player:Nick()]=0
	else
		ShieldCooldownDB[Player:Nick()]=os.time()
	end
end

local function UpdateCooldownDB()
	for _, v in pairs(player.GetAll()) do
		if GetCooldown(v) == nil then
			SetCooldown(v, true)
		end
	end
end

local function ExpireProtection(Player)
	if SpawnProtectedDB[Player:Nick()] then
		SpawnProtectedDB[Player:Nick()]=false
		Player:GodDisable()
		CSay(Player, "Your protection has expired.", red)
	end
end

local function ActivateShield(Player)
	UpdateCooldownDB()
	local waittime = 45*60
	local diff = os.time() - GetCooldown(Player)
	local dm = 45 - math.floor(diff / 60)
	local msg = "You are currently on shield cooldown. You may declare shielded in "..dm.." minutes."
	local to = Player
	if GetCooldown(Player) == 0 or diff >= waittime or GetCooldown(Player) == nil then
		Player:GodEnable()
		msg = Player:Nick().." has shielded, you cannot kill them unless they kill someone else!"
		to = nil
		SpawnProtectedDB[Player:Nick()]=false
	end
	CSay(to, msg, yellow)
end

-- ULX Commands
function ulx.shield(Player)
	UpdateCooldownDB()
	ActivateShield(Player)
end

local shield = ulx.command(CATEGORY_NAME, "ulx shield", ulx.shield, "!shield")
shield:defaultAccess(ULib.ACCESS_ALL)
shield:help("Declare yourself as a shielded player. You may not attack or be attacked when shielded.")

function ulx.listshielded(Player)
	UpdateCooldownDB()
	local msg = "Shielded Players:"
	for _, v in pairs(player.GetAll()) do
		if v:HasGodMode() then
			msg=msg.." "..tostring(v:Nick())..","
		end
	end
	msg=string.sub(msg, 0, -2)
	CSay(Player, msg, cyan)
end

local ls = ulx.command(CATEGORY_NAME, "ulx listshielded", ulx.listshielded, "!listshielded")
ls:defaultAccess(ULib.ACCESS_ALL)
ls:help("List all players that are shielded.")

function ulx.resetshields(Player)
	UpdateCooldownDB()
	CSay(nil, "All shield cooldown timers have been reset and shields have been revoked.", red)
	for _, v in pairs(player.GetAll()) do
		if v:HasGodMode() then
			v:GodDisable()
		end
		SetCooldown(Player, true)
	end
end

local resetshields = ulx.command(CATEGORY_NAME, "ulx resetshields", ulx.resetshields, "!resetshields")
resetshields:defaultAccess(ULib.ACCESS_SUPERADMIN)
resetshields:help("Reset shield cooldown timers and revokes all shields.")

function ulx.resetcooldowntimers(Player)
	UpdateCooldownDB()
	CSay(nil, "All shield cooldown timers have been reset.", red)
	for _, v in pairs(player.GetAll()) do
		SetCooldown(Player, true)
	end
end

local resetcooldowntimers = ulx.command(CATEGORY_NAME, "ulx resetcooldowntimers", ulx.resetcooldowntimers, "!resetcooldowntimers")
resetcooldowntimers:defaultAccess(ULib.ACCESS_SUPERADMIN)
resetcooldowntimers:help("Reset shield cooldown timers.")

function ulx.disableshield(Admin, Player)
	UpdateCooldownDB()
	CSay(Player, "Your shield has been removed.", red)
	Player:GodDisable()
end

local disableshield = ulx.command(CATEGORY_NAME, "ulx disableshield", ulx.disableshield, "!disableshield")
disableshield:defaultAccess(ULib.ACCESS_SUPERADMIN)
disableshield:addParam{ type=ULib.cmds.PlayerArg }
disableshield:help("Revoke shield from the given player.")

function ulx.removecooldown(Admin, Player)
	UpdateCooldownDB()
	CSay(Player, "Your shield cooldown timer has been zeroed.", red)
	SetCooldown(Player, true)
end

local removecooldown = ulx.command(CATEGORY_NAME, "ulx removecooldown", ulx.removecooldown, "!removecooldown")
removecooldown:defaultAccess(ULib.ACCESS_SUPERADMIN)
removecooldown:addParam{ type=ULib.cmds.PlayerArg }
removecooldown:help("Reset shield cooldown from the given player.")

-- Legacy Commands
local neutral = ulx.command(CATEGORY_NAME, "ulx neutral", ulx.shield, "!neutral")
neutral:defaultAccess(ULib.ACCESS_ALL)
neutral:help("<LEGACY> Declare yourself as a neutral player. You may not attack or be attacked during neutrality.")

local ls = ulx.command(CATEGORY_NAME, "ulx lsneutral", ulx.listshielded, "!lsneutral")
ls:defaultAccess(ULib.ACCESS_ALL)
ls:help("<LEGACY> List all players that are neutral.")

-- Register for Events
gameevent.Listen("PlayerDeath")
gameevent.Listen("PlayerSpawn")
gameevent.Listen("PlayerHurt")

-- Event Functions
local function Killed(Victim, Weapon, Killer)
	UpdateCooldownDB()
	for _, v in pairs(player.GetAll()) do
		if v:EntIndex() == Killer:EntIndex() then
			Killer=v
		end
	end
	if Killer:IsPlayer() and Killer:HasGodMode() then
		if Killer ~= Victim then
			local msg = Killer:Nick().."'s shield has been revoked for killing "..Victim:Nick().." and may not be activated again for 45 minutes."
			CSay(nil, msg, red)
			Killer:GodDisable()
			SetCooldown(Killer, false)
		end
	end
end

local function Spawn(Player)
	UpdateCooldownDB()
	CSay(Player, "You are protected for 60 seconds or until you attack someone.", green)
	SpawnProtectedDB[Player:Nick()]=true
	Player:GodEnable()
	timer.Simple(60, function() ExpireProtection(Player) end)
end

local function Damaged(Victim, Attacker)
	UpdateCooldownDB()
	for _, v in pairs(player.GetAll()) do
		if v:EntIndex() == Attacker:EntIndex() then
			Attacker=v
		end
	end
	if Attacker:IsPlayer() and Attacker:HasGodMode() then
		ExpireProtection(Attacker)
	end
end

-- Add Event Hook
hook.Add("PlayerDeath", "ShieldMod_DEATH", Killed)
hook.Add("PlayerSpawn", "ShieldMod_SPAWN", Spawn)
hook.Add("PlayerHurt", "ShieldMod_HURT", Damaged)
