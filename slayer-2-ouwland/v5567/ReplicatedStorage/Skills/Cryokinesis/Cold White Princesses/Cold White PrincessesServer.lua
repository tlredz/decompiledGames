local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local CombatMode = require(CAM.Global.CombatMode)
local Utility = require(CAM.Global.Utility)
local DebrisModule = require(CAM.DebrisModule)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local SkillStorage = require(ServerStorage2.SAM.Utility.SkillStorage)
local ColdWhitePrincessesServer = {
	Id = {}
}
local coldWhitePrincessesVictim = script.ColdWhitePrincessesVictim

function ColdWhitePrincessesServer.Hold(player, _: Vector3)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v2 = ColdWhitePrincessesServer.Id[player.UserId]
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Cold White Princesses VFX", character, "Start")
	task.wait(Config.SWEEP_AT)

	if ColdWhitePrincessesServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local counterTarget = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.SWEEP_HITBOX_OFFSET,
		hitboxSize = Config.SWEEP_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(p, _, p2)
			if counterTarget == nil and p2 == true then
				counterTarget = p
			end
		end
	})

	if counterTarget then
		local getID = SkillStorage.GetID(player, script.Parent.Name)
		getID.CounterTarget = counterTarget
		EffectsEvent.ToClient(
			player,
			"force_skill_actions_server",
			script.Parent.Name,
			"Counter",
			nil,
			true,
			counterTarget
		)
	end
end

function ColdWhitePrincessesServer.UnHold(player)
	local character = player.Character
	local v2 = character and Utility.getvaluesfolder(character)

	if v2 then
		Utility.AddValue(v2, "pause_gameplay", Config.MISS_RECOVERY)
		Utility.AddValue(v2, "skill_stand_still", Config.MISS_RECOVERY)
	end

	ColdWhitePrincessesServer.Cancel(player)
end

function ColdWhitePrincessesServer.Counter(player, _: Vector3, instance)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid.RootPart
	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not Checker.check_victim(script, character, instance) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder, "NR", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder, "iframe", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder, "noragdoll", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "NR", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "noragdoll", Config.FLOWERS_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "iframe", Config.FLOWERS_LOCK_DURATION, "StringValue", character.Name)
	Combat_Util.Cancel(script, getvaluesfolder2, true)
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Cold White Princesses VFX",
		character,
		"Flowers",
		instance,
		character:GetPivot()
	)
	local pivot = instance:GetPivot()
	Utility.lock(humanoidRootPart, pivot, Config.FLOWERS_LOCK_DURATION)
	Utility.lock(rootPart, pivot, Config.FLOWERS_LOCK_DURATION)
	local track = animator:LoadAnimation(coldWhitePrincessesVictim)
	track:Play()
	DebrisModule:AddItem(track, Config.FLOWERS_LOCK_DURATION)
	task.wait(Config.FLOWERS_LOCK_DURATION + 0.1)
	local RANKED_FLOWERS_STUN

	if CombatMode.IsRanked(player) then
		RANKED_FLOWERS_STUN = Config.RANKED_FLOWERS_STUN
	else
		RANKED_FLOWERS_STUN = Config.FLOWERS_STUN
	end

	Combat_Util.Damage(script, character, instance, {
		Base = Config.FLOWERS_DAMAGE,
		Skill = script.Parent.Name
	})
	Combat_Util.AddStun(script, character, getvaluesfolder2, RANKED_FLOWERS_STUN)
	Combat_Util.RagDoll(script, character, getvaluesfolder2, RANKED_FLOWERS_STUN)
end

function ColdWhitePrincessesServer.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Cold White Princesses VFX", character, "Cancel")
	end
end

return ColdWhitePrincessesServer