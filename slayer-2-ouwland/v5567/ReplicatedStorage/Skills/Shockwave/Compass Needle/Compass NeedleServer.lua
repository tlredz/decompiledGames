local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_Util2 = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(CAM.Global.Checker)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local StatTypes = require(CAM.Global.Types.StatTypes)
local Config = require(script.Parent.Config)
local ServerStorage2 = game:GetService("ServerStorage")
local SkillStorage = require(ServerStorage2.SAM.Utility.SkillStorage)
local CompassNeedleServer = {
	Id = {}
}

local function grantSurge(instance)
	if instance == nil then
		return
	end

	local child = instance:FindFirstChild(Config.BUFF_VALUE_NAME)

	if child ~= nil then
		child:Destroy()
	end

	local v2 = Utility.AddValue(instance, Config.BUFF_VALUE_NAME, Config.BUFF_DURATION)
	v2:AddTag(StatTypes.ValueStatTag)
	v2:SetAttribute(StatTypes.StatToAttribute("Movement Speed Factor"), Config.BUFF_MOVEMENT_FACTOR)
	v2:SetAttribute(StatTypes.StatToAttribute("Additional Damage Factor"), Config.BUFF_DAMAGE_FACTOR)
end

function CompassNeedleServer.Hold(player)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v2 = CompassNeedleServer.Id[player.UserId]
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Compass Needle VFX", character, "Start")
	task.wait(Config.SWEEP_AT)

	if CompassNeedleServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
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

function CompassNeedleServer.UnHold(player)
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Combat_Util.AddCustomSkillState(
		getvaluesfolder,
		Config.BUFF_SKILL_NAME,
		Config.BUFF_STATE_VALUE,
		Config.BUFF_DURATION
	)
	grantSurge(getvaluesfolder)
end

function CompassNeedleServer.Counter(player, _: Vector3, instance)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if not Checker.check_victim(script, character, instance) then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)
	Utility.AddValue(getvaluesfolder2, "pause_gameplay", Config.COUNTER_LOCK_DURATION)
	Utility.AddValue(getvaluesfolder2, "NR", Config.COUNTER_LOCK_DURATION)
	Combat_Util2.Cancel(script, getvaluesfolder2, true)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.COUNTER_CASTER_LOCK)
	Utility.AddValue(getvaluesfolder, "NR", Config.COUNTER_CASTER_LOCK)
	Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.COUNTER_CASTER_LOCK)
	task.wait(Config.COUNTER_TELEPORT_AT)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	local pivot = instance:GetPivot()
	humanoidRootPart:PivotTo(CFrame.lookAt((pivot * CFrame.new(0, 0, 3)).Position, humanoidRootPart2.Position))
	EffectsEvent.ToAllInRange(humanoidRootPart, "Compass Needle VFX", character, "Counter")
	Combat_Util.Add_air_combo_bp(humanoidRootPart2, humanoidRootPart)
	Combat_Util.Add_air_combo_bp(humanoidRootPart, humanoidRootPart)
	Combat_Util.Damage(script, character, instance, {
		Base = Config.COUNTER_DAMAGE,
		Skill = script.Parent.Name
	})
	Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.COUNTER_STUN_DURATION, true)
	Combat_Util.AddCustomSkillState(
		getvaluesfolder,
		Config.BUFF_SKILL_NAME,
		Config.BUFF_STATE_VALUE,
		Config.BUFF_DURATION
	)
	grantSurge(getvaluesfolder)
end

function CompassNeedleServer.Cancel(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Compass Needle VFX", character, "Cancel")
	end
end

return CompassNeedleServer