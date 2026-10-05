local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local SkillStorage = require(SAM.Utility.SkillStorage)
local Config = require(script.Parent.Config)
local CrazyCuttingServer = {
	Id = {}
}
local counter = script.Counter

function CrazyCuttingServer.Hold(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = CrazyCuttingServer.Id[player.UserId]
	Utility.AddValue(Utility.getvaluesfolder(character), "CounterWindup", Config.WINDUP)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Crazy Cutting VFX", character, "Start")
	task.wait(Config.WINDUP)

	if CrazyCuttingServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	local counterTarget = nil
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame,
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

function CrazyCuttingServer.UnHold(p, vector2: Vector3?, p2)
	CrazyCuttingServer.Cancel(p, vector2, p2)
end

function CrazyCuttingServer.Counter(player, _: Vector3?, instance, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid and humanoid.RootPart

	if character == nil or humanoidRootPart == nil or rootPart == nil or not Checker.check_victim(
		script,
		character,
		instance
	) then
		return
	end

	if p ~= nil then
		p.countered = true
	end

	local position = humanoidRootPart.Position
	local position2 = rootPart.Position
	local v2 = (position - position2) * createVector(1, 0, 1)
	local unit

	if v2.Magnitude > 0.01 then
		unit = v2.Unit
	else
		unit = rootPart.CFrame.LookVector * createVector(1, 0, 1)
	end

	local unit2 = (unit.Magnitude < 0.01 and createVector(0, 0, 1) or unit).Unit
	local v3 = position2 + unit2 * Config.TELEPORT_OFFSET
	local v4 = -unit2
	local v5 = CFrame.new(v3) * CFrame.fromOrientation(0, math.atan2(-v4.X, -v4.Z), 0)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	character:PivotTo(v5)
	local getvaluesfolder = Utility.getvaluesfolder(character)

	if getvaluesfolder ~= nil then
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.LOCK_DURATION)
		Utility.AddValue(getvaluesfolder, "NR", Config.LOCK_DURATION)
		Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.LOCK_DURATION)
		Utility.AddValue(getvaluesfolder, "iframe", Config.LOCK_DURATION)
	end

	Utility.lock(humanoidRootPart, v5, Config.LOCK_DURATION)
	local getvaluesfolder2 = Utility.getvaluesfolder(instance)

	if getvaluesfolder2 ~= nil then
		Combat_Util.Cancel(script, getvaluesfolder2, true)
		Combat_Util.Add_Strict_Stun(script, character, getvaluesfolder2, Config.SLASH_AT)
	end

	Combat_Util.Knockback(
		script,
		character,
		rootPart,
		Vector3.new(0, Config.RISE_SPEED, 0),
		Config.SLASH_AT,
		"remove_airbp"
	)
	Combat_presets.PlayReactAnim(humanoid, nil, Config.REACT_SPEED)
	task.spawn(function()
		task.wait(Config.BARRAGE_START)
		local v6 = os.clock() + (Config.BARRAGE_END - Config.BARRAGE_START)

		while os.clock() < v6 do
			if instance.Parent == nil or rootPart.Parent == nil then
				return
			end

			if Checker.check_victim(script, character, instance) == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BARRAGE_DAMAGE,
					Skill = script.Parent.Name
				})
				ImpactSounds.Play(character, script.Parent.Name, instance)
				Combat_presets.PlayReactAnim(humanoid)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", rootPart, -1)
			end

			task.wait(Config.BARRAGE_INTERVAL)
		end

		if instance.Parent == nil then
			return
		end

		Combat_presets.PlayReactAnim(humanoid, nil, Config.REACT_SPEED)
	end)
	task.delay(Config.SLASH_AT, function()
		if instance.Parent == nil or rootPart.Parent == nil or Checker.check_victim(script, character, instance) ~= true then
			return
		end

		Combat_Util.Damage(script, character, instance, {
			Base = Config.SLASH_DAMAGE,
			Skill = script.Parent.Name
		})
		ImpactSounds.Play(character, script.Parent.Name, instance)
		EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", rootPart, -1)
		Utility.ClearMovers(rootPart)
		local child = Players:FindFirstChild(character.Name)

		if child then
			EffectsEvent.ToClient(
				Players:FindFirstChild(instance.Name) or child,
				"Add_Velocity",
				rootPart,
				createVector(0, 0, 0),
				0,
				"delete"
			)
		end

		local v6 = v5.LookVector * Config.SLASH_KNOCKBACK
		Combat_Util.Knockback(script, character, rootPart, v6, Config.SLASH_KNOCKBACK_DURATION, "remove_airbp")
		local getvaluesfolder3 = Utility.getvaluesfolder(instance)

		if getvaluesfolder3 ~= nil then
			Combat_Util.AddStun(script, character, getvaluesfolder3, Config.SLASH_STUN)
			Combat_Util.RagDoll(script, character, getvaluesfolder3, Config.SLASH_RAGDOLL)
		end
	end)
	local humanoid2 = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")

	if animator ~= nil then
		animator:LoadAnimation(counter):Play()
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Crazy Cutting VFX", character, "Counter", instance)
end

function CrazyCuttingServer.Cancel(player, _: Vector3?, p)
	if p ~= nil and p.countered == true then
		return
	end

	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Crazy Cutting VFX", character, "Cancel")
end

return CrazyCuttingServer