local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Skill_Switch_Adder = require(CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Utility = require(CAM.Global.Utility)
local cleanit = require(ReplicatedStorage.Packages.cleanit)
local ProjectileModeler = require(CAM.Global.ProjectileModeler)
local Server_Mouse_Pos = require(SAM.Services.Server_Mouse_Pos)
local CombatMode = require(CAM.Global.CombatMode)
local Combat_Util = require(SAM.Services.Combat_Util)
local Combat_presets = require(CAM.Global.Combat_presets)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local Config = require(script.Parent.Config)
local OrdainedFleshServer = {
	Id = {}
}

function OrdainedFleshServer.Hold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	state.cancelled = false
	local v2 = OrdainedFleshServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	Server_Mouse_Pos.Create_Pos_Part(character, script.Parent.Name, Config.SHOOT_DURATION + 2, vector2)
	cleanIt:Add(function()
		Server_Mouse_Pos.Delete_Pos_Part(character, script.Parent.Name)
	end)
	local v3 = typeof(vector2) ~= "Vector3" and 30 or math.min(30, (vector2 - humanoidRootPart.Position).Magnitude)
	local position, normal = RaycastHelper.MaximizeRayServer(character, humanoidRootPart.Position, vector2, v3, false)

	if not (position and normal) then
		position, normal = RaycastHelper.MaximizeRayServer(
			character,
			humanoidRootPart.Position,
			vector2,
			v3,
			false,
			nil,
			15
		)
	end

	if normal == nil then
		local v4 = vector2 - humanoidRootPart.Position
		local vector3 = Vector3.new(v4.X, 0, v4.Z)

		if vector3.Magnitude < 0.05 then
			vector3 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
		end

		if vector3.Magnitude >= 0.05 then
			local AIM_DROP_ANGLE = math.rad(Config.AIM_DROP_ANGLE)
			local v5 = vector3.Unit * math.cos(AIM_DROP_ANGLE) - createVector(0, 1, 0) * math.sin(AIM_DROP_ANGLE)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, v5 * 30, RaycastHelper.Crater)

			if raycastResult == nil then
				position = humanoidRootPart.Position + v5 * 30
			else
				position = raycastResult.Position
				normal = raycastResult.Normal
			end
		end
	end

	local position2 = position or vector2
	local raycastResult = workspace:Raycast(
		position2 + createVector(0, 3, 0),
		createVector(0, -60, 0),
		RaycastHelper.Crater
	)
	local normal2

	if raycastResult then
		position2 = raycastResult.Position
		normal2 = raycastResult.Normal
	else
		normal2 = normal or createVector(0, 1, 0)
	end

	local cframe = CFrame.lookAt(position2, position2 + normal2.Unit)
	state.FlowerCFrame = cframe
	EffectsEvent.ToAllInRange(humanoidRootPart, "OrdainedFlesh VFX", character, "Startup", cframe)
	task.wait(Config.FLOWER_STARTUP_DURATION)

	if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
	end
end

function OrdainedFleshServer.UnHold(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	local v2 = OrdainedFleshServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local flowerCFrame = state.FlowerCFrame
	cleanIt:Add(Skill_Switch_Adder.Add(player, script.Parent.Name, Config.SHOOT_DURATION))
	EffectsEvent.ToAllInRange(humanoidRootPart, "OrdainedFlesh VFX", character, "ShootStart")

	for i = 1, Config.ORB_COUNT do
		if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
			return
		end

		local v3 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.BEAM_RANGE, vector2) or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.BEAM_RANGE
		local vector3 = Vector3.new(
			math.random(-Config.ORB_SCATTER, Config.ORB_SCATTER),
			0,
			math.random(-Config.ORB_SCATTER, Config.ORB_SCATTER)
		)
		local formatted = `{player.Name} OrdainedFlesh Orb {i}`
		local lookVector = flowerCFrame.LookVector
		local vector4 = v3 - flowerCFrame.Position
		local v4 = vector4 - lookVector * vector4:Dot(lookVector)
		local v5 = flowerCFrame.Position + lookVector * 21.5

		if v4.Magnitude > 0.01 then
			v5 += v4.Unit * 5.5
		end

		local unit = (v3 + vector3 - v5).Unit
		local flag = false
		local v6 = ProjectileModeler.new({
			Name = formatted,
			Size = Config.ORB_SIZE,
			CFrame = CFrame.new(v5),
			Mover = {
				MaxForce = 1000000000,
				VectorVelocity = unit * Config.ORB_SPEED
			},
			Rotator = {
				Responsiveness = 75,
				CFrame = CFrame.lookAt(v5, v5 + unit)
			}
		}, function(_, _, p)
			if flag or (state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId]) or p == nil then
				return false
			end

			local find_character_from_descendant = Utility.find_character_from_descendant(p)

			if find_character_from_descendant == nil then
				return false
			end

			local humanoidRootPart2 = find_character_from_descendant:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				return false
			end

			local check_victim = Checker.check_victim(script, character, find_character_from_descendant)

			if check_victim == "Perfect" then
				Combat_Util.Perfect(script, character, find_character_from_descendant)
				flag = true
			elseif check_victim == "Blocking" then
				Combat_Util.Block(script, character, find_character_from_descendant, Config.ORB_BLOCK_BREAK)
				flag = true
			elseif check_victim == true then
				Combat_Util.Damage(script, character, find_character_from_descendant, {
					Base = Config.ORB_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.Aggro(script, character, find_character_from_descendant, script.Parent.Name)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
				flag = true
			end

			return false
		end, Config.ORB_LIFETIME, ProjectileModeler.WhitelistType.HumanoidsAndMap, character, RaycastHelper.Crater)
		v6.Instance:SetNetworkOwner(player)
		cleanIt:Add(v6)
		EffectsEvent.ToAllInRange(
			humanoidRootPart,
			"OrdainedFlesh VFX",
			character,
			"FlowerProjectile",
			formatted,
			v3,
			v6.Instance
		)
		task.wait(Config.ORB_INTERVAL)
	end

	if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
		return
	end

	cleanIt:Clean()
end

function OrdainedFleshServer.Switch(player, vector2: Vector3?, state)
	local cleanIt = state.CleanIt or cleanit.new()
	state.CleanIt = cleanIt
	cleanIt:Clean()
	local v2 = OrdainedFleshServer.Id[player.UserId]
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local flowerCFrame = state.FlowerCFrame
	local v3 = Server_Mouse_Pos.Aim(character, script.Parent.Name, Config.BEAM_RANGE, vector2) or humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * Config.BEAM_RANGE
	local lookVector = flowerCFrame.LookVector
	local vector3 = v3 - flowerCFrame.Position
	local v4 = vector3 - lookVector * vector3:Dot(lookVector)
	local v5 = flowerCFrame.Position + lookVector * 21.5

	if v4.Magnitude > 0.01 then
		v5 += v4.Unit * 5.5
	end

	local unit = (v3 - v5).Unit
	local magnitude = (v3 - v5).Magnitude
	local v6 = v5 + unit * (magnitude / 2)
	EffectsEvent.ToAllInRange(humanoidRootPart, "OrdainedFlesh VFX", character, "BeamFire", v5, v3)
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.lookAt(v6, v3),
		hitboxSize = Vector3.new(Config.BEAM_WIDTH, Config.BEAM_WIDTH, magnitude),
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
				return
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
			table.insert(instances, instance)

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BEAM_BLOCK_BREAK)
			elseif p2 == true then
				local unit2 = (humanoidRootPart2.Position - v5).Unit
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BEAM_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p, Config.BEAM_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					(unit2 + createVector(0, 1, 0)) * Config.BEAM_KNOCKBACK,
					0.25
				)
				Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})
	local v7 = magnitude / (Config.BEAM_RANGE * (1 / Config.BEAM_DEFAULT_TRAVEL_TIME))
	task.wait(v7)

	if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
		return
	end

	EffectsEvent.ToAllInRange(humanoidRootPart, "OrdainedFlesh VFX", character, "BeamImpact", v3)
	task.wait(0.5)

	if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
		return
	end

	local RANKED_BEAM_IMPACT_BLOCK_BREAK

	if CombatMode.IsRanked(player) then
		RANKED_BEAM_IMPACT_BLOCK_BREAK = Config.RANKED_BEAM_IMPACT_BLOCK_BREAK
	else
		RANKED_BEAM_IMPACT_BLOCK_BREAK = Config.BEAM_IMPACT_BLOCK_BREAK
	end

	Utility.CreateHitbox({
		caster = character,
		hitboxCFrame = CFrame.new(v3),
		hitboxSize = Config.BEAM_IMPACT_SIZE,
		targets = instances,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			if state.cancelled or v2 ~= OrdainedFleshServer.Id[player.UserId] then
				return
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if p2 == "Perfect" then
				Combat_Util.Perfect(script, character, instance)
			elseif p2 == "Blocking" then
				Combat_Util.Block(script, character, instance, RANKED_BEAM_IMPACT_BLOCK_BREAK)
			elseif p2 == true then
				local v8 = humanoidRootPart2.Position - v3
				local v9 = not (v8.Magnitude > 0.1) and createVector(0, 1, 0) or v8.Unit
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BEAM_IMPACT_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p, Config.BEAM_IMPACT_STUN)
				Combat_Util.RagDoll(script, character, p, Config.BEAM_IMPACT_STUN)
				Combat_Util.Knockback(
					script,
					character,
					humanoidRootPart2,
					v9 * Config.BEAM_IMPACT_KNOCKBACK + createVector(0, 0.1, 0),
					0.3
				)
				EffectsEvent.ToAllInRange(humanoidRootPart, "Normal_Punch_Effect", humanoidRootPart2, -1)
			end
		end
	})
	cleanIt:Clean()
end

function OrdainedFleshServer.Cancel(player, _: Vector3?, p)
	p.cancelled = true
	local cleanIt = p.CleanIt or cleanit.new()
	p.CleanIt = cleanIt
	cleanIt:Clean()
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and character then
		EffectsEvent.ToAllInRange(humanoidRootPart, "OrdainedFlesh VFX", character, "Cancel")
	end
end

return OrdainedFleshServer