local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
require(ReplicatedStorage2.SmartBone.Dependencies.Iris.widgets.Root)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local ImpactSounds = require(ServerStorage.SAM.Utility.ImpactSounds)
local StatTypes = require(ReplicatedStorage.CAM.Global.Types.StatTypes)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local WaterSurfaceSlashServer = {
	Id = {}
}
local ManuelCancel = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("ManuelCancel"))

function WaterSurfaceSlashServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local v2 = WaterSurfaceSlashServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "WaterSurfaceSlashEff", character, "Init")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local runIframe = Utility.AddValue(getvaluesfolder, "iframe", Config.RUN_IFRAME_MAX)
	p.RunIframe = runIframe

	-- equivalent calls inferred from this helper; original call sites unknown
	local function dropIframe()
		if p.RunIframe == runIframe then
			p.RunIframe = nil
		end

		if runIframe ~= nil and runIframe.Parent ~= nil then
			runIframe:Destroy()
		end
	end

	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`

	while v2 == WaterSurfaceSlashServer.Id[player.UserId] do
		local cFrame = rootPart.CFrame
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * Config.DASH_HITBOX_OFFSET,
			BoxSize = Config.DASH_HITBOX_SIZE
		})

		if singlePartHitbox then
			p.CaughtVictim = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
			break
		elseif character.Parent == nil then
			break
		else
			task.wait(0.1)
		end
	end

	dropIframe() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropRunIframe(p)
	local runIframe = p.RunIframe
	p.RunIframe = nil

	if runIframe ~= nil and runIframe.Parent ~= nil then
		runIframe:Destroy()
	end
end

function WaterSurfaceSlashServer.UnHold(player, vector: Vector3, state)
	local character = player.Character

	if character == nil then
		return
	end

	dropRunIframe(state) -- equivalent call inferred; original call site unknown
	state.Cancelled = false
	local v2 = WaterSurfaceSlashServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(player, "WaterSurfaceSlashEff", character, "Cancel")
	local v4 = false
	ManuelCancel.new(player, 0.3):Connect(function()
		v4 = true
		WaterSurfaceSlashServer.Cancel(player, vector, state)
	end)
	task.wait(Config.SLASH_AT)

	if state.Cancelled or WaterSurfaceSlashServer.Id[player.UserId] ~= v2 or (v4 == true or character == nil) then
		return
	end

	EffectsEvent.ToAllInRange(player, "WaterSurfaceSlashEff", character, "Slash")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v5 = Utility.AddValue(getvaluesfolder, Config.SPEED_BUFF_VALUE, Config.SPEED_BUFF_DURATION)
	v5:AddTag(StatTypes.ValueStatTag)
	v5:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.SPEED_BUFF_FACTOR)
	local v6 = character.HumanoidRootPart.CFrame * Config.SLASH_HITBOX_OFFSET
	local modelInRegion = Utility.GetModelInRegion(v6, Config.SLASH_HITBOX_SIZE, nil, nil, false)
	local caughtVictim = state.CaughtVictim
	state.CaughtVictim = nil
	local humanoidRootPart

	if not (caughtVictim == nil or caughtVictim.Parent == nil) then
		humanoidRootPart = caughtVictim:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart ~= nil and (humanoidRootPart.Position - v6.Position).Magnitude <= Config.SLASH_HITBOX_SIZE.Magnitude / 2 + 50 and table.find(
		modelInRegion,
		caughtVictim
	) == nil then
		table.insert(modelInRegion, caughtVictim)
	end

	local v7 = not CombatMode.IsRanked(player) and 0 or Config.RANKED_STUN_CUT
	local v8 = false
	local v9 = nil

	for _, v10 in pairs(modelInRegion) do
		if v8 == true then
			break
		end

		if not (v10 ~= player.Character and v10:FindFirstChild("Humanoid") ~= nil) then
			continue
		end

		local humanoidRootPart2 = v10:FindFirstChild("HumanoidRootPart")
		local humanoid = v10:FindFirstChild("Humanoid")
		local check_victim, _ = Checker.check_victim(script, character, v10)
		local getvaluesfolder2 = Utility.getvaluesfolder(v10)

		if v.Both(getvaluesfolder2, {
			pv = getvaluesfolder,
			name = "Choosing_1"
		}) == true then
			continue
		end

		local humanoidRootPart3 = character:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 ~= nil and humanoid ~= nil and humanoidRootPart3 ~= nil) then
			continue
		end

		if check_victim == "Blocking" then
			Combat_Util.Block(script, character, v10, Config.SLASH_BLOCK_BREAK)
		elseif check_victim == "Perfect" then
			Combat_Util.Perfect(script, character, v10)
			v8 = true
		elseif check_victim == true then
			EffectsEvent.ToAllInRange(player, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
			Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.SLASH_RAGDOLL - v7)
			Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.SLASH_STUN - v7)
			Combat_Util.Damage(script, character, v10, {
				Base = Config.SLASH_DAMAGE,
				Skill = script.Parent.Name
			})
			local v11 = humanoidRootPart3.CFrame.lookVector * Config.SLASH_KNOCKBACK
			Combat_Util.Knockback(script, character, humanoidRootPart2, Vector3.new(v11.X, 0, v11.Z), 0.35)
			v9 = v9 or v10
		end
	end

	if v9 ~= nil then
		ImpactSounds.Play(character, script.Parent.Name, v9)
	end
end

function WaterSurfaceSlashServer.Cancel(player, _: Vector3, p)
	dropRunIframe(p) -- equivalent call inferred; original call site unknown
	local character = player.Character

	if character == nil then
		return
	end

	WaterSurfaceSlashServer.Id[player.UserId] = 3
	EffectsEvent.ToAllInRange(player, "WaterSurfaceSlashEff", character, "Cancel")
end

return WaterSurfaceSlashServer