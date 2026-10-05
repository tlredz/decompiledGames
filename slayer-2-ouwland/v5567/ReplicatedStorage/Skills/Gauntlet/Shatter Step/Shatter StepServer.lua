local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local ShatterStepServer = {
	Id = {}
}
local name = script.Parent.Name

function ShatterStepServer.Hold(player, _: Vector3?, _)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "GauntletInit", character)
end

function ShatterStepServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShatterStepServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3, v4 = ManuelCancel.new(player, Config.STAGE1_END + 0.5)
	v3:Connect(function()
		ShatterStepServer.Id[player.UserId] = -1
		ShatterStepServer.Cancel(player, vector2, p)
	end)
	cleanIt:Add(v4)
	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"skillsdisabled",
		Config.STAGE1_END,
		"StringValue",
		(`all,except{name}`)
	))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.STAGE1_END))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "WalkSpeed", Config.STAGE1_END, "NumberValue", Config.WALK_SPEED))
	task.wait(Config.PUNCH_AT)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Shatter Step VFX", character, "Punch", humanoidRootPart.CFrame)
	local diveTarget = nil
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = humanoidRootPart.CFrame * Config.PUNCH_HITBOX_OFFSET,
		hitboxSize = Config.PUNCH_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p2, p3)
			local humanoid = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or humanoidRootPart2 == nil then
				return
			end

			if p3 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.PUNCH_BLOCK_BREAK)
			elseif p3 == true then
				diveTarget = diveTarget or instance
				table.insert(instances, instance)
				Combat_Util.Damage(script, character, instance, {
					Base = Config.PUNCH_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p2, Config.PUNCH_STUN)
				Combat_Util.RagDoll(script, character, p2, Config.PUNCH_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					humanoidRootPart.CFrame.LookVector * Config.PUNCH_KNOCKBACK + Vector3.new(0, Config.PUNCH_UPWARD, 0),
					0.25
				)
				Combat_presets.PlayReactAnim(humanoid, nil, nil)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})
	p.diveTarget = diveTarget
	p.capturedTargets = instances
	local shatterStepTarget = getvaluesfolder:FindFirstChild("ShatterStepTarget")

	if shatterStepTarget then
		shatterStepTarget:Destroy()
	end

	if diveTarget then
		Utility.AddValue(getvaluesfolder, "ShatterStepTarget", Config.SWITCH_WINDOW + 1, "ObjectValue", diveTarget)
		Skill_Switch_Adder.Add(player, name, Config.SWITCH_WINDOW)
	end

	task.wait(Config.STAGE1_END - Config.PUNCH_AT)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function ShatterStepServer.Switch(player, _: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = ShatterStepServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3, v4 = ManuelCancel.new(player, 1.7833333333333334 + Config.SWITCH_ENDLAG + 0.5)
	v3:Connect(function()
		ShatterStepServer.Id[player.UserId] = -1
		ShatterStepServer.Cancel(player, nil, state)
	end)
	cleanIt:Add(v4)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", 1.7833333333333334 + Config.SWITCH_ENDLAG))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", 1.0333333333333334))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "skill_stand_still", 1.0333333333333334))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NR", 1.0333333333333334))
	local cFrame = humanoidRootPart.CFrame
	Server_Mouse_Pos.Create_Pos_Part(character, name, 2)
	cleanIt:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, name)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function aimPosition()
		local diveTarget = state.diveTarget
		local humanoidRootPart2 = diveTarget and diveTarget:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart2 then
			return humanoidRootPart2.Position
		end

		return Server_Mouse_Pos.Find(character, name).Position
	end

	task.wait(0.03333333333333333)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Shatter Step VFX", character, "Jump", cFrame)
	task.wait(0.9333333333333333)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function diveDirection()
		local safeDirection = Utility.SafeDirection
		local v5 = cFrame.Position * createVector(1, 0, 1)
		local v6 = aimPosition() -- equivalent call inferred; original call site unknown
		return safeDirection(v5, v6 * createVector(1, 0, 1)) or (cFrame.LookVector * createVector(1, 0, 1)).Unit
	end

	local v5 = diveDirection() -- equivalent call inferred; original call site unknown
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Shatter Step VFX",
		character,
		"Air",
		CFrame.lookAt(cFrame.Position, cFrame.Position + v5)
	)
	task.wait(0.06666666666666667)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	local v6 = diveDirection() -- equivalent call inferred; original call site unknown
	local v7 = cFrame.Position + Vector3.new(0, Config.JUMP_HEIGHT, 0)
	local v8 = cFrame.Position.Y - Config.DIVE_MAX_DROP

	local function groundGoal(vector2: Vector3)
		local raycastResult = workspace:Raycast(
			Vector3.new(vector2.X, v7.Y, vector2.Z),
			createVector(0, -80, 0),
			RaycastHelper.Crater
		)
		local vector3 = (raycastResult and raycastResult.Position or vector2 - Vector3.new(0, Config.JUMP_HEIGHT, 0)) + Vector3.new(
			0,
			humanoid.HipHeight + humanoidRootPart.Size.Y / 2,
			0
		)

		if vector3.Y < v8 then
			vector3 = Vector3.new(vector3.X, v8, vector3.Z)
		end

		return vector3
	end

	local v9 = groundGoal(cFrame.Position + v6 * Config.DIVE_FORWARD)
	local spherecast = workspace:Spherecast(v7, Config.DIVE_PROBE_RADIUS, v9 - v7, RaycastHelper.Crater)

	if spherecast then
		v9 = groundGoal(spherecast.Position + spherecast.Normal * Config.DIVE_WALL_OFFSET)
	end

	local cframe = CFrame.lookAt(v9, v9 + v6)
	EffectsEvent.ToAllInRange(humanoidRootPart, "Shatter Step VFX", character, "End", cframe)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = cframe * Config.CRASH_HITBOX_OFFSET,
		hitboxSize = Config.CRASH_HITBOX_SIZE,
		targets = state.capturedTargets,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid2 = instance:FindFirstChild("Humanoid")
			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if humanoid2 == nil or humanoidRootPart2 == nil then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.CRASH_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.CRASH_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p, Config.CRASH_STUN)
				Combat_Util.RagDoll(script, character, p, Config.CRASH_RAGDOLL)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					cframe.LookVector * Config.CRASH_KNOCKBACK + Vector3.new(0, Config.CRASH_UPWARD, 0),
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})
	task.wait(Config.SWITCH_ENDLAG)

	if ShatterStepServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function ShatterStepServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Shatter Step VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return ShatterStepServer