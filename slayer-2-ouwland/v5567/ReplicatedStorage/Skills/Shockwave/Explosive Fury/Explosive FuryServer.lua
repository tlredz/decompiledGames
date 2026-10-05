local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_presets = require(CAM.Global.Combat_presets)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local ExplosiveFuryServer = {
	Id = {}
}

local function spawnBarrageWave(caster, p2, vector2: Vector3, targets)
	local v2 = {}
	local hitboxCFrame = CFrame.lookAt(p2.Position, p2.Position + vector2) * CFrame.new(0, 0, -6.5)
	Utility.CreateHitbox({
		caster = caster,
		hitboxCFrame = hitboxCFrame,
		hitboxSize = Config.BARRAGE_HITBOX_SIZE,
		targets = targets,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p4, p5)
			if v2[instance] then
				return
			end

			v2[instance] = true
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if p5 == "Perfect" then
				Combat_Util.Perfect(script, caster, instance)
			elseif p5 == "Blocking" then
				Combat_Util.Block(script, caster, instance, 0.25)
			elseif p5 == true then
				EffectsEvent.ToAllInRange(p2, "Normal_Punch_Effect", rootPart, -1)
				Combat_Util.Damage(script, caster, instance, {
					Base = Config.BARRAGE_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, caster, p4, Config.BARRAGE_STUN)
				Combat_Util.Knockback(
					script,
					caster,
					rootPart,
					vector2 * Config.BARRAGE_KNOCKBACK + createVector(0, 0.1, 0),
					0.5
				)
				Combat_presets.PlayReactAnim(humanoid)
			end
		end
	})
	EffectsEvent.ToAllInRange(p2, "Explosive Fury VFX", caster, "Wave", vector2, false)
end

local function spawnFinisherWave(character, humanoidRootPart, p, cframe: CFrame)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe,
		hitboxSize = Config.BARRAGE_FINISH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			if p[instance] then
				return
			end

			p[instance] = true
			local humanoid = instance:FindFirstChild("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, 1)
			elseif p3 == true then
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", rootPart, -1)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BARRAGE_FINISH_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.BARRAGE_FINISH_STUN)
				Combat_Util.Knockback(
					script,
					character,
					rootPart,
					cframe.lookVector * Config.BARRAGE_FINISH_KNOCKBACK,
					0.15
				)
				Combat_Util.RagDoll(script, character, p2, 1.5)
			end
		end
	})
end

function ExplosiveFuryServer.Hold(player, _: Vector3, p)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local v2 = ExplosiveFuryServer.Id[player.UserId]
	EffectsEvent.ToAllInRange(humanoidRootPart, "Explosive Fury VFX", character, "Start", humanoidRootPart.CFrame)
	local formatted = `{player.Name}-{script.Parent.Name}-{math.random(1, 99)}`
	task.wait(Config.PROBE_START_AT)

	if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
		return
	end

	p.probeVictim = nil

	while ExplosiveFuryServer.Id[player.UserId] == v2 do
		local cFrame = humanoidRootPart.CFrame
		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = formatted,
			Origin = cFrame * CFrame.new(Config.FRONT_STOP_OFFSET),
			BoxSize = Config.FRONT_STOP_SIZE
		})

		if singlePartHitbox then
			p.probeVictim = Utility.find_character_from_descendant(singlePartHitbox)
			EffectsEvent.ToClient(player, "force_skill_actions_server", script.Parent.Name, "UnHold", nil)
		end

		task.wait(0.1)
	end
end

function ExplosiveFuryServer.UnHold(player, vector2: Vector3, state)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = ExplosiveFuryServer.Id[player.UserId]
	local v3 = 1.15 / Config.BARRAGE_HIT_COUNT
	local v4, v5 = ManuelCancel.new(player, 1.75)
	v4:Connect(function()
		ExplosiveFuryServer.Id[player.UserId] = -1
		ExplosiveFuryServer.Cancel(player, vector2, state)
	end)
	state.airHold = Combat_Util.Add_air_combo_bp(humanoidRootPart, nil, 0, nil, 1.75)

	if getvaluesfolder then
		Utility.AddValue(getvaluesfolder, "skill_stand_still", 1.75)
		Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.75)
		Utility.AddValue(getvaluesfolder, "NR", 1.75)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function currentDirection()
		local v6 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

		if v6.Magnitude >= 0.01 then
			return v6.Unit
		end

		local v7 = (vector2 - humanoidRootPart.Position) * createVector(1, 0, 1)

		if v7.Magnitude < 0.01 then
			return humanoidRootPart.CFrame.LookVector
		end

		return v7.Unit
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Explosive Fury VFX", character, "Fury")
	task.wait(0.1)

	if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
		return
	end

	for i = 1, Config.BARRAGE_HIT_COUNT do
		if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
			return
		end

		local v7 = currentDirection() -- equivalent call inferred; original call site unknown
		local v8

		if i == 1 then
			v8 = state.probeVictim
		end

		spawnBarrageWave(character, humanoidRootPart, v7, v8)

		if i < Config.BARRAGE_HIT_COUNT then
			task.wait(v3)
		end
	end

	task.wait(0.10000000000000009)

	if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
		return
	end

	local v6 = {}
	local v7 = currentDirection() -- equivalent call inferred; original call site unknown
	EffectsEvent.ToAllInRange(humanoidRootPart, "Explosive Fury VFX", character, "Wave", v7, true)
	local cframe = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v7)
	local Z = Config.BARRAGE_FINISH_HITBOX_SIZE.Z

	for i = 0, 2 do
		if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
			return
		end

		spawnFinisherWave(character, humanoidRootPart, v6, cframe * CFrame.new(0, 0, -Z * i - 5))
		task.wait(0.19999999999999996)
	end

	if ExplosiveFuryServer.Id[player.UserId] ~= v2 then
		return
	end

	v5()

	if state.airHold then
		state.airHold:Destroy()
		state.airHold = nil
	end
end

function ExplosiveFuryServer.Cancel(player, _: Vector3?, state)
	EffectsEvent.ToAllInRange(player, "Explosive Fury VFX", player.Character, "Cancel")

	if state.airHold then
		state.airHold:Destroy()
		state.airHold = nil
	end

	if state.aimAttachment then
		state.aimAttachment:Destroy()
		state.aimAttachment = nil
	end
end

return ExplosiveFuryServer