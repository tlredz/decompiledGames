local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local Checker = require(CAM.Global.Checker)
local StatTypes = require(CAM.Global.Types.StatTypes)
local manage_cd = require(CAM.Global.Subsets.Gameplay.manage_cd)
local Config = require(script.Parent.Config)
local WarChantServer = {
	Id = {},
	Hold = function(player)
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return
		end

		Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
		EffectsEvent.ToAllInRange(humanoidRootPart, "War Chant VFX", character, "Start")
	end
}

local function grantBuff(player, character, humanoidRootPart)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Combat_Util.AddCustomSkillState(
		getvaluesfolder,
		Config.BUFF_SKILL_NAME,
		Config.BUFF_STATE_VALUE,
		Config.BUFF_DURATION
	)
	local child = getvaluesfolder:FindFirstChild(Config.BUFF_MARK_VALUE)

	if child ~= nil then
		child:Destroy()
	end

	local v = Utility.AddValue(getvaluesfolder, Config.BUFF_MARK_VALUE, Config.BUFF_DURATION)
	v:AddTag(StatTypes.ValueStatTag)
	v:SetAttribute(StatTypes.StatToAttribute("Additional Damage Factor"), Config.BUFF_DAMAGE_FACTOR)
	v:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.BUFF_SPEED_FACTOR)
	local SHCS = character:FindFirstChild("SHCS")
	local child2

	if SHCS == nil then
		child2 = false
	else
		child2 = SHCS:FindFirstChild(manage_cd.filter_cd_name(player, Config.BUFF_SKILL_NAME))
	end

	if child2 then
		child2:Destroy()
	end

	EffectsEvent.ToClient(player, "reset_skill_cooldown", Config.BUFF_SKILL_NAME)
	EffectsEvent.ToAllInRange(humanoidRootPart, "War Chant VFX", character, "Buff")
end

function WarChantServer.UnHold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "War Chant VFX", character, "Cancel")
	grantBuff(player, character, humanoidRootPart)
end

function WarChantServer.Counter(player, _: Vector3, instance)
	local character = player.Character

	if character == nil or instance == nil or not Checker.check_victim(script, character, instance) then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoidRootPart == nil or humanoidRootPart2 == nil or humanoid == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)
	local v = WarChantServer.Id[player.UserId]
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.COUNTER_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "NR", Config.COUNTER_LOCK_DURATION)
	Combat_Util.Cancel(script, getvaluesfolder2, true)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.COUNTER_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder, "NR", Config.COUNTER_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.COUNTER_LOCK_DURATION)
	task.wait(0.3)

	if v ~= WarChantServer.Id[player.UserId] or humanoidRootPart.Parent == nil or (instance.Parent == nil or humanoidRootPart2.Parent == nil) then
		return
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	local pivot = instance:GetPivot()
	humanoidRootPart:PivotTo(CFrame.lookAt((pivot * CFrame.new(0, 0, 3)).Position, humanoidRootPart2.Position))
	EffectsEvent.ToAllInRange(humanoidRootPart, "War Chant VFX", character, "Counter")
	Combat_Util.Damage(script, character, instance, {
		Base = Config.COUNTER_DAMAGE,
		Skill = script.Parent.Name
	})
	Combat_Util.AddStun(script, character, getvaluesfolder2, Config.COUNTER_STUN_DURATION)
	Combat_presets.PlayReactAnim(humanoid)
	grantBuff(player, character, humanoidRootPart)
end

function WarChantServer.Cancel(player)
	EffectsEvent.ToAllInRange(player, "War Chant VFX", player.Character, "Cancel")
end

return WarChantServer