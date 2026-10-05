local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local ImpactSounds = require(SAM.Utility.ImpactSounds)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Combat_presets = require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local Config = require(script.Parent.Config)
local SliceAndDiceServer = {
	Id = {}
}
local name = script.Parent.Name
local dash = script.Parent["Slice and Dice"].Dash

function SliceAndDiceServer.Hold(_, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
end

function SliceAndDiceServer.UnHold(player, vector2: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FLIGHT_LOCK))
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "iframe", Config.FLIGHT_LOCK))
	local position = humanoidRootPart.Position
	local position2 = position + humanoidRootPart.CFrame.LookVector * Config.AIM_RANGE

	if vector2 ~= nil then
		local maximizeRayServer, _, _, v2 = RaycastHelper.MaximizeRayServer(
			character,
			position,
			vector2,
			Config.AIM_RANGE,
			true,
			5,
			15,
			3
		)
		local humanoidRootPart2 = v2 and v2:FindFirstChild("HumanoidRootPart")
		position2 = humanoidRootPart2 and humanoidRootPart2.Position or maximizeRayServer or position2
	end

	local v2 = (position2 - position) * createVector(1, 0, 1)
	local unit

	if v2.Magnitude > 0.01 then
		unit = v2.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	end

	local v3 = unit.Magnitude < 0.01 and createVector(0, 0, 1) or unit
	local cframe = CFrame.fromOrientation(0, math.atan2(-v3.X, -v3.Z), 0)
	p.startRotation = cframe
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Slice and Dice VFX",
		character,
		"Jump",
		CFrame.new(position) * cframe,
		position2
	)
end

function SliceAndDiceServer.UnHoldAfterClient(player, _: Vector3?, _, p, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = SliceAndDiceServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if typeof(p) ~= "CFrame" then
		SliceAndDiceServer.Cancel(player, nil, state)
		return
	end

	local clamped = Server_Mouse_Pos.Clamp(character, p.Position, Config.AIM_RANGE + 15)

	if clamped == nil then
		SliceAndDiceServer.Cancel(player, nil, state)
		return
	end

	local v3 = p.Rotation + clamped
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v4, v5 = ManuelCancel.new(player, Config.RECOVERY + 0.5)
	v4:Connect(function()
		SliceAndDiceServer.Id[player.UserId] = -1
		SliceAndDiceServer.Cancel(player, nil, state)
	end)
	cleanIt:Add(v5)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RECOVERY))
	EffectsEvent.ToAllInRange(
		humanoidRootPart,
		"Slice and Dice VFX",
		character,
		"Land",
		CFrame.new(v3.Position) * (state.startRotation or v3.Rotation)
	)
	state.Targets = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v3 * Config.LAND_HITBOX_OFFSET,
		hitboxSize = Config.LAND_HITBOX_SIZE,
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
				Combat_Util.Block(script, character, instance, Config.LAND_BLOCK_BREAK)
			elseif p3 == true then
				local v6 = (humanoidRootPart2.Position - v3.Position) * createVector(1, 0, 1)
				local unit

				if v6.Magnitude > 0.01 then
					unit = v6.Unit
				else
					unit = v3.LookVector * createVector(1, 0, 1)
				end

				Combat_Util.Damage(script, character, instance, {
					Base = Config.LAND_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p2, Config.LAND_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					unit * Config.LAND_KNOCKBACK + Vector3.new(0, Config.LAND_KNOCKUP, 0),
					0.25
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				table.insert(state.Targets, instance)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Slice and Dice VFX", character, "Mark", instance)
			end
		end,
		After = function(p2, list)
			if p2 then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})

	if #state.Targets > 0 then
		Skill_Switch_Adder.Add(player, name, Config.SWITCH_WINDOW)
	end

	task.wait(Config.RECOVERY)

	if SliceAndDiceServer.Id[player.UserId] ~= v2 or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function SliceAndDiceServer.Switch(player, _: Vector3?, state)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v2 = nil
	local v3 = nil
	local v4 = nil

	for _, v6 in state.Targets or {} do
		if v6.Parent == nil then
			continue
		end

		local humanoidRootPart2 = v6:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart2 ~= nil and Checker.check_victim(script, character, v6) ~= nil) then
			continue
		end

		local v7 = (humanoidRootPart2.Position - humanoidRootPart.Position) * createVector(1, 0, 1)
		local unit

		if v7.Magnitude > 0.0001 then
			unit = v7.Unit
		else
			unit = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
		end

		local unit2 = (unit.Magnitude < 0.0001 and createVector(0, 0, 1) or unit).Unit
		local v8 = humanoidRootPart2.Position - unit2 * Config.SWITCH_FRONT_OFFSET

		if workspace:Raycast(humanoidRootPart.Position, v8 - humanoidRootPart.Position, RaycastHelper.Crater) then
			continue
		end

		v4 = unit2
		v3 = humanoidRootPart2
		v2 = v6
		break
	end

	state.Targets = nil

	if v2 == nil or v3 == nil or v4 == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if animator ~= nil then
		animator:LoadAnimation(dash):Play()
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "Slice and Dice VFX", character, "Toggle", humanoidRootPart.CFrame)
	local v6 = SliceAndDiceServer.Id[player.UserId]
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v7, v8 = ManuelCancel.new(player, Config.SWITCH_DURATION + 0.5)
	v7:Connect(function()
		SliceAndDiceServer.Id[player.UserId] = -1
		SliceAndDiceServer.Cancel(player, nil, state)
	end)
	cleanIt:Add(v8)
	local getvaluesfolder = Utility.getvaluesfolder(character)
	Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.SWITCH_DURATION)
	Utility.AddValue(getvaluesfolder, "NR", Config.SWITCH_DURATION)
	cleanIt:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.SWITCH_DURATION))
	local air_combo_bp = humanoidRootPart:FindFirstChild("air_combo_bp")

	if air_combo_bp then
		air_combo_bp:Destroy()
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local v9 = math.atan2(-v4.X, -v4.Z)
	local cframe = CFrame.fromOrientation(0, v9, 0)
	local v10 = v3.Position - v4 * Config.SWITCH_FRONT_OFFSET
	local v11 = CFrame.new(v10) * cframe
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	character:PivotTo(v11)
	local attachment = Instance.new("Attachment")
	attachment.Name = "slice_and_dice_face_lock"
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = attachment
	alignOrientation.CFrame = cframe
	alignOrientation.MaxTorque = 1000000
	alignOrientation.Responsiveness = 200
	alignOrientation.Parent = attachment
	attachment.Parent = humanoidRootPart
	cleanIt:Add(attachment)
	DebrisModule:AddItem(attachment, Config.SWITCH_DURATION)

	if Config.SWITCH_BLINK_DELAY > 0 then
		task.wait(Config.SWITCH_BLINK_DELAY)

		if SliceAndDiceServer.Id[player.UserId] ~= v6 or humanoidRootPart.Parent == nil then
			return
		end
	end

	local raycastResult = workspace:Raycast(v10, v4 * Config.DASH_DISTANCE, RaycastHelper.Crater)
	local position

	if raycastResult then
		position = raycastResult.Position + raycastResult.Normal * Config.TELEPORT_WALL_OFFSET
	else
		position = v10 + v4 * Config.DASH_DISTANCE
	end

	local magnitude = ((position - v10) * createVector(1, 0, 1)).Magnitude
	local v13 = CFrame.new(position) * cframe
	EffectsEvent.ToAllInRange(humanoidRootPart, "Slice and Dice VFX", character, "Dash", v11, v13)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "slice_and_dice_dash"
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.Attachment0 = attachment2
	alignPosition.Responsiveness = Config.DASH_RESPONSIVENESS
	alignPosition.MaxForce = Config.DASH_MAX_FORCE
	alignPosition.Position = position
	alignPosition.Parent = attachment2
	attachment2.Parent = humanoidRootPart
	cleanIt:Add(attachment2)
	DebrisModule:AddItem(attachment2, Config.ENDLAG_DASH)
	local vector2 = Vector3.new(Config.BLINK_HITBOX_WIDTH, Config.BLINK_HITBOX_HEIGHT, magnitude + 8)
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = v11 * CFrame.new(0, 0, -(magnitude / 2 + 3)),
		hitboxSize = vector2,
		targets = { v2 },
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_2"
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
				Combat_Util.Block(script, character, instance, Config.BLINK_BLOCK_BREAK)
			elseif p2 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BLINK_DAMAGE,
					Skill = name
				})
				Combat_Util.AddStun(script, character, p, Config.DASH_IMPACT_AT)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					Vector3.new(0, Config.BLINK_KNOCKUP, 0),
					Config.DASH_IMPACT_AT
				)
				Combat_presets.PlayReactAnim(humanoid2, nil, 0.35)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Sword_Slash_Effect", humanoidRootPart2, -1)
				table.insert(instances, instance)
			end
		end,
		After = function(p, list)
			if p then
				ImpactSounds.Play(character, script.Parent.Name, list[1])
			end
		end
	})

	if #instances > 0 then
		task.delay(Config.DASH_IMPACT_AT, function()
			for _, v14 in instances do
				if not (v14.Parent ~= nil and Checker.check_victim(script, character, v14) == true) then
					continue
				end

				local getvaluesfolder2 = Utility.getvaluesfolder(v14)

				if getvaluesfolder2 == nil then
					continue
				end

				Combat_Util.AddStun(script, character, getvaluesfolder2, Config.IMPACT_STUN)
				Combat_Util.RagDoll(script, character, getvaluesfolder2, Config.IMPACT_RAGDOLL)
			end
		end)
	end

	task.wait((math.max(0, Config.SWITCH_DURATION - Config.SWITCH_BLINK_DELAY)))

	if SliceAndDiceServer.Id[player.UserId] ~= v6 or humanoidRootPart.Parent == nil then
		return
	end

	cleanIt:Clean()
end

function SliceAndDiceServer.Cancel(player, _: Vector3?, p)
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	p.Targets = nil
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Slice and Dice VFX", character, "Cancel")
	end

	cleanIt:Clean()
end

return SliceAndDiceServer