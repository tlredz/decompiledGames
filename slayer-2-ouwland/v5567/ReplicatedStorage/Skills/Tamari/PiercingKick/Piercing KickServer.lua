local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local ProjectileHoming = require(CAM.Global.Subsets.Gameplay.ProjectileHoming)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local Config = require(script.Parent.Config)
local PiercingKickServer = {
	Id = {},
	Hold = function(player, _: Vector3?, state)
		if state.CleanIt then
			state.CleanIt:Destroy()
		end

		local maid = cleanit.new()
		state.CleanIt = maid
		local character = player.Character
		local getvaluesfolder = Utility.getvaluesfolder(character)
		state.standStillValue = Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.SKILL_MAX_DURATION)
		maid:Add(state.standStillValue)
		maid:Add(Utility.AddValue(getvaluesfolder, "NOMouvementlines", Config.SKILL_MAX_DURATION))
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart ~= nil then
			Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.SKILL_MAX_DURATION)
			maid:Add(function()
				Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
			end)
			state.holding = true
			maid:Add(function()
				state.holding = false
			end)
			state.lock = ProjectileHoming.HoldLock({
				Pick = {
					Script = script,
					Caster = character,
					Origin = humanoidRootPart.Position,
					Range = Config.MOUSE_RANGE,
					Radius = Config.AIM_PICK_RADIUS,
					Downcast = Config.AIM_DOWNCAST,
					Select = true
				},
				Origin = function()
					return humanoidRootPart.Position
				end,
				Aim = function()
					return Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.MOUSE_RANGE)
				end,
				While = function()
					return state.holding == true and humanoidRootPart.Parent ~= nil
				end
			})
		end
	end
}

function PiercingKickServer.UnHold(player, vector2: Vector3?, state)
	local DISTANCE_EPSILON = 0.01
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	local v2 = PiercingKickServer.Id[player.UserId]
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = humanoid.RootPart
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v3 = Config.UPDRAFT_DURATION + Config.DASH_MAX_TIME + Config.LEG_KICK_DELAY + 0.15
	cleanIt:Add(Combat_Util.Add_No_GP(script, character, getvaluesfolder, v3))
	cleanIt:Add(ManuelCancel.new(player, Config.UNHOLD_DURATION + 0.5):Connect(function()
		PiercingKickServer.Id[player.UserId] = -1
		PiercingKickServer.Cancel(player, nil, state)
	end))
	EffectsEvent.ToAllInRange(rootPart, "Piercing Kick VFX", character, "kick")
	cleanIt:Add((Combat_Util.Add_air_combo_bp(rootPart, nil, Config.UPDRAFT_HEIGHT, nil, Config.UPDRAFT_DURATION)))
	task.wait(Config.UPDRAFT_DURATION)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	local position = rootPart.Position
	local v4 = vector2 or position + rootPart.CFrame.LookVector * Config.MOUSE_RANGE
	local v5 = RaycastHelper.MaximizeRayServer(character, position, v4, Config.MOUSE_RANGE, true, 3) or v4
	local v6 = position.Y + Config.UPDRAFT_HEIGHT
	local vector3 = Vector3.new(v5.X, math.min(v5.Y, v6), v5.Z)
	local raycastResult = workspace:Raycast(vector3, createVector(0, -10, 0), RaycastHelper.Crater)

	if raycastResult then
		vector3 = raycastResult.Position
	end

	local lock = state.lock
	local v7

	if lock == nil then
		v7 = nil
	else
		v7 = lock:Target()
	end

	state.holding = false

	local function feetOf(instance)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return nil
		end

		local v8 = (humanoidRootPart.Position - rootPart.Position) * createVector(1, 0, 1)

		if v8.Magnitude < 0.01 then
			return humanoidRootPart.Position - Vector3.new(0, humanoidRootPart.Size.Y / 2, 0)
		end

		local unit = v8.Unit
		local distance = math.min(v8.Magnitude, Config.MOUSE_RANGE)
		local raycastResult2 = workspace:Raycast(rootPart.Position, unit * distance, RaycastHelper.Crater)

		if raycastResult2 ~= nil then
			distance = raycastResult2.Distance
		end

		local v9 = math.max(distance - Config.TARGET_STANDOFF, 0)
		local v10 = rootPart.Position + unit * v9
		local raycastResult3 = workspace:Raycast(
			v10 + createVector(0, 5, 0),
			Vector3.new(0, -Config.UPDRAFT_HEIGHT - 15, 0),
			RaycastHelper.Crater
		)

		if raycastResult3 == nil then
			return (Vector3.new(v10.X, humanoidRootPart.Position.Y - humanoidRootPart.Size.Y / 2, v10.Z))
		end

		return raycastResult3.Position
	end

	if v7 == nil then
		vector3 = Utility.SnapAimToTarget({
			Caster = character,
			Aim = vector3,
			Radius = Config.AIM_SNAP_RADIUS,
			ParamsName = `{player.Name}-{Config.SKILL_NAME}-aimsnap`,
			Checker = Checker,
			Feet = true
		})
	else
		local v8 = feetOf(v7)

		if v8 ~= nil then
			vector3 = v8
		end
	end

	local v8 = (vector3 - rootPart.Position) * createVector(1, 0, 1)
	local unit

	if v8.Magnitude > DISTANCE_EPSILON then
		unit = v8.Unit
	else
		unit = rootPart.CFrame.LookVector
	end

	rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + unit)
	local attachment = Instance.new("Attachment")
	attachment.Name = "air_combo_bp"
	local v9 = Config.DASH_MAX_TIME + Config.LEG_KICK_DELAY + 0.1
	local position2 = vector3 + Vector3.new(0, humanoid.HipHeight + rootPart.Size.Y / 2, 0)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxAxesForce = createVector(20000, 20000, 20000)
	alignPosition.Responsiveness = Config.ALIGN_RESPONSIVENESS
	alignPosition.Attachment0 = attachment
	alignPosition.Position = position2
	alignPosition.Parent = attachment
	local position3 = position2
	attachment.Parent = rootPart

	if v7 ~= nil then
		task.spawn(function()
			local v12 = os.clock() + Config.TRACK_WINDOW

			while os.clock() < v12 and alignPosition.Parent ~= nil and rootPart.Parent ~= nil and PiercingKickServer.Id[player.UserId] == v2 and Checker.check_can_select(
				script,
				character,
				v7
			) do
				local v13 = feetOf(v7)

				if v13 == nil then
					break
				end

				position3 = v13 + Vector3.new(0, humanoid.HipHeight + rootPart.Size.Y / 2, 0)
				alignPosition.Position = position3
				task.wait(Config.TRACK_TICK)
			end
		end)
	end

	cleanIt:Add(function()
		if alignPosition then
			alignPosition:Destroy()
		end

		if attachment then
			attachment:Destroy()
		end

		if rootPart and rootPart.Parent then
			rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	task.delay(v9, function()
		if alignPosition and alignPosition.Parent then
			alignPosition:Destroy()
		end

		if attachment and attachment.Parent then
			attachment:Destroy()
		end

		if rootPart and rootPart.Parent and humanoid.FloorMaterial ~= Enum.Material.Air then
			rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	local v12 = math.clamp(
		(position2 - rootPart.Position).Magnitude / Config.DASH_SPEED,
		Config.DASH_MIN_TIME,
		Config.DASH_MAX_TIME
	)

	if v7 ~= nil then
		v12 = math.max(v12, Config.TRACK_WINDOW + Config.TRACK_SETTLE)
	end

	task.wait(v12)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	local v13 = position3
	local v14 = v13 - rootPart.Position
	local raycastResult2

	if v14.Magnitude > DISTANCE_EPSILON then
		raycastResult2 = workspace:Raycast(rootPart.Position, v14, RaycastHelper.Crater)
	end

	if raycastResult2 ~= nil then
		v13 = raycastResult2.Position - v14.Unit * (rootPart.Size.Z / 2 + 1)
	end

	local v15 = rootPart.CFrame.LookVector * createVector(1, 0, 1)

	if v15.Magnitude < DISTANCE_EPSILON then
		v15 = unit
	end

	local function boxAt(vector4: Vector3, unit2: Vector3, cframe: CFrame)
		if v7 == nil or not Checker.check_can_select(script, character, v7) then
			return CFrame.lookAt(vector4, vector4 + unit2) * cframe
		end

		local humanoidRootPart = v7:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			return CFrame.lookAt(vector4, vector4 + unit2) * cframe
		end

		local v16 = (humanoidRootPart.Position - vector4) * createVector(1, 0, 1)

		if v16.Magnitude > 0.01 then
			unit2 = v16.Unit
		end

		return CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit2) * cframe
	end

	local targets = {}

	if v7 ~= nil and v7.Parent ~= nil then
		table.insert(targets, v7)
	end

	local raycastResult3 = workspace:Raycast(v13, createVector(-0, -10, -0), RaycastHelper.Crater)

	if raycastResult3 then
		rootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		rootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	local cframe = CFrame.lookAt(v13, v13 + v15)
	local v17 = boxAt(v13, v15, CFrame.identity)
	local raycastResult4

	if raycastResult3 and (v17.Position - v13).Magnitude > 1 then
		raycastResult4 = workspace:Raycast(
			v17.Position + createVector(0, 2, 0),
			createVector(-0, -12, -0),
			RaycastHelper.Crater
		) or raycastResult3
	else
		raycastResult4 = raycastResult3
	end

	EffectsEvent.ToAllInRange(
		rootPart,
		"Piercing Kick VFX",
		character,
		"Slam",
		raycastResult4 and raycastResult4.Position,
		raycastResult4 and raycastResult4.Normal,
		raycastResult4 and raycastResult4.Instance,
		cframe
	)

	if raycastResult3 then
		local hitboxCFrame = boxAt(v13, v15, Config.SLAM_HITBOX_OFFSET)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = Config.SLAM_HITBOX_SIZE,
			checker = Checker,
			targets = targets,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_1"
			},
			hitDetected = function(instance, p, p2)
				if table.find(targets, instance) == nil then
					table.insert(targets, instance)
				end

				if p2 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p2 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SLAM_BLOCK_BREAK)
				elseif p2 == true then
					local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SLAM_DAMAGE,
						Skill = Config.SKILL_NAME
					})
					Combat_Util.AddStun(script, character, p, Config.SLAM_STUN)
					Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart,
						createVector(0, 1, 0) * Config.SLAM_KNOCKBACK,
						0.25
					)
				end
			end
		})
	end

	task.wait(Config.LEG_KICK_DELAY)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	local hitboxCFrame2 = boxAt(rootPart.Position, v15, Config.LEG_KICK_HITBOX_OFFSET)
	EffectsEvent.ToAllInRange(
		rootPart,
		"Piercing Kick VFX",
		character,
		"Kick",
		raycastResult3 and raycastResult3.Position,
		raycastResult3 and raycastResult3.Normal,
		raycastResult3 and raycastResult3.Instance,
		(boxAt(rootPart.Position, v15, CFrame.identity))
	)
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = hitboxCFrame2,
		hitboxSize = Config.LEG_KICK_HITBOX_SIZE,
		checker = Checker,
		targets = targets,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(legKickVictim, p, p2)
			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, legKickVictim)
			elseif p2 == "Blocking" then
				if Combat_Util.Block(script, character, legKickVictim, Config.LEG_KICK_BLOCK_BREAK) then
					state.legKickVictim = legKickVictim
				end
			elseif p2 == true then
				local humanoidRootPart = legKickVictim:FindFirstChild("HumanoidRootPart")
				Combat_Util.Damage(script, character, legKickVictim, {
					Base = Config.LEG_KICK_DAMAGE,
					Skill = Config.SKILL_NAME
				})
				Combat_Util.AddStun(script, character, p, Config.LEG_KICK_STUN)
				Combat_Util.RagDoll(script, character, p, Config.LEG_KICK_STUN)
				local lookVector = rootPart.CFrame.LookVector
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart,
					(lookVector + createVector(0, 0.2, 0)) * Config.LEG_KICK_KNOCKBACK,
					0.25
				)
				state.legKickVictim = legKickVictim
			end
		end,
		After = function()
			if state.legKickVictim then
				Skill_Switch_Adder.Add(player, "Piercing Kick", 5)
			end
		end
	})
	task.delay(Config.CLEANUP_DELAY, function()
		if PiercingKickServer.Id[player.UserId] ~= v2 then
			return
		end

		cleanIt:Clean()
	end)
end

function PiercingKickServer.Switch(player, _: Vector3?, state)
	local cleanIt = state.CleanIt

	if not cleanIt then
		return
	end

	local v2 = PiercingKickServer.Id[player.UserId]
	local character = player.Character
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local legKickVictim = state.legKickVictim
	state.legKickVictim = nil

	if legKickVictim == nil then
		return
	end

	local humanoidRootPart = legKickVictim:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		cleanIt:Clean()
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	EffectsEvent.ToAllInRange(rootPart, "Piercing Kick VFX", character, "Throw", legKickVictim)

	if state.standStillValue and state.standStillValue.Parent then
		state.standStillValue:Destroy()
	end

	state.standStillValue = nil
	cleanIt:Add(Combat_Util.Add_No_GP(script, character, getvaluesfolder, Config.SWITCH_HIT1_DELAY + 0.1))
	cleanIt:Add(Utility.AddValue(
		getvaluesfolder,
		"NOMouvementlines",
		Config.SWITCH_TOTAL_DURATION + Config.CLEANUP_DELAY
	))
	cleanIt:Add(ManuelCancel.new(player, Config.SWITCH_TOTAL_DURATION + 0.5):Connect(function()
		PiercingKickServer.Id[player.UserId] = -1
		PiercingKickServer.Cancel(player, nil, state)
	end))
	local instances = {}
	local SWITCH_HIT_DROP_TIME = Config.SWITCH_HIT_DROP_TIME
	local SWITCH_FINAL_DROP_TIME = Config.SWITCH_FINAL_DROP_TIME

	local function victimValid()
		if legKickVictim and legKickVictim.Parent and legKickVictim:FindFirstChild("HumanoidRootPart") then
			return Checker.check_victim(script, character, legKickVictim) ~= nil
		end

		return false
	end

	local function intermediateHit(p: string)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = CFrame.new(humanoidRootPart.Position),
			hitboxSize = Config.SWITCH_HITBOX_SIZE,
			checker = Checker,
			targets = instances,
			hitPriorityHandler = {
				callback = v.Exists,
				data = p
			},
			hitDetected = function(instance, p2, p3)
				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.SWITCH_BLOCK_BREAK)
				elseif p3 == true then
					if table.find(instances, instance) == nil then
						table.insert(instances, instance)
					end

					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
					Combat_Util.Damage(script, character, instance, {
						Base = Config.SWITCH_DAMAGE,
						Skill = Config.SKILL_NAME
					})
					Combat_Util.AddStun(script, character, p2, Config.SWITCH_STUN)
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						vector.create(0, Config.SWITCH_HIT_LIFT, 0),
						Config.SWITCH_HIT_LIFT_DURATION
					)
					Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.275)
				end
			end
		})
	end

	local function syncedHit(p: string)
		local v3

		if legKickVictim and legKickVictim.Parent and legKickVictim:FindFirstChild("HumanoidRootPart") then
			v3 = Checker.check_victim(script, character, legKickVictim) ~= nil
		else
			v3 = false
		end

		if not v3 then
			return false
		end

		EffectsEvent.ToAllInRange(rootPart, "Piercing Kick VFX", character, "Hit", legKickVictim, SWITCH_HIT_DROP_TIME)
		task.wait(SWITCH_HIT_DROP_TIME)

		if PiercingKickServer.Id[player.UserId] ~= v2 then
			return false
		end

		intermediateHit(p)
		return true
	end

	task.wait(Config.SWITCH_HIT1_DELAY - SWITCH_HIT_DROP_TIME)

	if not (PiercingKickServer.Id[player.UserId] == v2 and syncedHit("Choosing_1")) then
		return
	end

	task.wait(Config.SWITCH_HIT2_DELAY - SWITCH_HIT_DROP_TIME)

	if not (PiercingKickServer.Id[player.UserId] == v2 and syncedHit("Choosing_2")) then
		return
	end

	task.wait(Config.SWITCH_HIT3_DELAY - SWITCH_FINAL_DROP_TIME)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	local v3

	if legKickVictim and legKickVictim.Parent and legKickVictim:FindFirstChild("HumanoidRootPart") then
		v3 = Checker.check_victim(script, character, legKickVictim) ~= nil
	else
		v3 = false
	end

	if not v3 then
		return
	end

	EffectsEvent.ToAllInRange(
		rootPart,
		"Piercing Kick VFX",
		character,
		"FinalDrop",
		legKickVictim,
		Config.SWITCH_EXPLOSION_DELAY
	)
	task.wait(SWITCH_FINAL_DROP_TIME)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.new(humanoidRootPart.Position),
		hitboxSize = Config.SWITCH_HITBOX_SIZE,
		checker = Checker,
		targets = instances,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_3"
		},
		hitDetected = function(instance, p, p2)
			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SWITCH_BLOCK_BREAK)
			elseif p2 == true then
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SWITCH_FINAL_DAMAGE,
					Skill = Config.SKILL_NAME
				})
				Combat_Util.AddStun(script, character, p, Config.SWITCH_FINAL_STUN)
				Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.275)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					vector.create(0, Config.SWITCH_HIT_LIFT, 0),
					Config.SWITCH_HIT_LIFT_DURATION
				)
			end
		end
	})
	task.wait(Config.SWITCH_EXPLOSION_DELAY)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.new(humanoidRootPart.Position),
		hitboxSize = Config.SWITCH_EXPLOSION_HITBOX_SIZE,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_4"
		},
		hitDetected = function(instance, p, p2)
			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.SWITCH_BLOCK_BREAK)
			elseif p2 == true then
				local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
				Combat_Util.Damage(script, character, instance, {
					Base = Config.SWITCH_EXPLOSION_DAMAGE,
					Skill = Config.SKILL_NAME
				})
				Combat_Util.AddStun(script, character, p, Config.SWITCH_EXPLOSION_STUN)
				Combat_Util.RagDoll(script, character, p, Config.SWITCH_EXPLOSION_STUN)
				local v4 = humanoidRootPart2.Position - humanoidRootPart.Position
				local v5 = not (v4.Magnitude > 0.01) and createVector(0, 1, 0) or v4.Unit
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					(v5 + createVector(0, 0.3, 0)) * Config.SWITCH_EXPLOSION_KNOCKBACK,
					0.25
				)
			end
		end
	})
	task.wait(Config.CLEANUP_DELAY)

	if PiercingKickServer.Id[player.UserId] ~= v2 then
		return
	end

	cleanIt:Clean()
end

function PiercingKickServer.Cancel(player, _: Vector3?, p)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "Piercing Kick VFX", character, "Cancel")
	end

	local cleanIt = p.CleanIt

	if cleanIt then
		cleanIt:Destroy()
		p.CleanIt = nil
	end

	if humanoidRootPart then
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

return PiercingKickServer