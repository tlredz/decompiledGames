local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local FlameUndulationServer = {
	Id = {}
}
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
require(ReplicatedStorage.CAM.Global.Combat_presets)
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local ImpactSounds = require(ServerStorage.SAM.Utility.ImpactSounds)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local SkillStats = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.StatsFetch.Modules.SkillStats)
local Config = require(script.Parent.Config)

local function interrupted(instance)
	if instance == nil then
		return false
	end

	local v2 = SkillStats.Get(script.Parent.Name)

	if v2 ~= nil and v2.cancel_bypass then
		return false
	end

	for _, child in ipairs(instance:GetChildren()) do
		if Utility.Cancel_Values[child.Name] then
			return true
		end
	end

	return false
end

function FlameUndulationServer.Hold(player, _, _)
	local character = player.Character
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(player, "Flame UdulationVFX", character, "Start")
end

function FlameUndulationServer.UnHold(player, p, p2)
	local character = player.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or interrupted(Utility.getvaluesfolder(character)) then
		return
	end

	local v2 = FlameUndulationServer.Id[player.UserId]
	local v3, v4 = ManuelCancel.new(player, Config.RELEASE_HIT_AT, nil, script.Parent.Name)
	v3:Connect(function()
		v2 = -1
		FlameUndulationServer.Cancel(player, p, p2)
		v4()
	end)
	task.wait(Config.RELEASE_HIT_AT)

	if v2 ~= FlameUndulationServer.Id[player.UserId] or humanoidRootPart.Parent == nil then
		v4()
		return
	end

	v4()
	EffectsEvent.ToAllInRange(player, "Flame UdulationVFX", character, "Release")
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.RELEASE_HITBOX_OFFSET,
		hitboxSize = Config.RELEASE_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		TreeDestruction = true,
		hitDetected = function(instance, p3, p4)
			if instance then
				local rootPart = instance:FindFirstChild("Humanoid").RootPart

				if p4 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.RELEASE_BLOCK_BREAK)
				elseif p4 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p4 == true then
					local v5 = humanoidRootPart.CFrame.LookVector * Config.RELEASE_KNOCKBACK + vector.create(
						0,
						Config.RELEASE_KNOCKUP,
						0
					)
					Combat_Util.AddStun(script, character, p3, Config.RELEASE_STUN)
					Combat_Util.Damage(script, character, instance, {
						Base = Config.RELEASE_DAMAGE,
						Skill = script.Parent.Name
					})
					Combat_Util.Knockback(script, character, rootPart, v5, 0.2)
					Combat_Util.RagDoll(script, character, p3, Config.RELEASE_RAGDOLL)
				end
			end
		end,
		After = function(p3, list)
			if p3 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})
end

function FlameUndulationServer.Cancel(_, _, _) end

function FlameUndulationServer.Counter(player, _, instance)
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(instance)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.COUNTER_VICTIM_PAUSE)
	Combat_Util.Cancel(script, getvaluesfolder, true)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 == nil or humanoidRootPart == nil then
		return
	end

	task.wait(Config.COUNTER_HIT_AT)

	if Checker.check_victim(script, character, instance) == nil then
		return
	end

	EffectsEvent.ToAllInRange(player, "Flame UdulationVFX", character, "Counter")
	local v2 = humanoidRootPart.CFrame.LookVector * Config.COUNTER_KNOCKBACK + vector.create(
		0,
		Config.COUNTER_KNOCKUP,
		0
	)
	Combat_Util.AddStun(script, character, getvaluesfolder, Config.COUNTER_STUN)
	Combat_Util.Damage(script, character, instance, {
		Base = Config.COUNTER_DAMAGE,
		Skill = script.Parent.Name
	})
	ImpactSounds.Play(character, script.Parent.Name, instance)
	Combat_Util.Knockback(script, character, humanoidRootPart2, v2, 0.2)
	Combat_Util.RagDoll(script, character, getvaluesfolder, Config.COUNTER_RAGDOLL)
end

return FlameUndulationServer