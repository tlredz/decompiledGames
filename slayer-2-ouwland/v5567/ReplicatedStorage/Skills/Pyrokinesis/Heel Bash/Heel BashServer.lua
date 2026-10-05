local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local EffectsEvent = require(ReplicatedStorage2.Communication.ServerAndClient.Effects.EffectsEvent)
local CAM = ReplicatedStorage.CAM
local SAM = ServerStorage.SAM
local Checker = require(CAM.Global.Checker)
local Utility = require(CAM.Global.Utility)
require(CAM.Global.Combat_presets)
local DebrisModule = require(CAM.DebrisModule)
local ManuelCancel = require(CAM.Global.Subsets.Gameplay.ManuelCancel)
require(SAM.Utility.SkillStorage)
local Combat_Util = require(SAM.Services.Combat_Util)
local hit_priority_handler = require(SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Config = require(script.Parent.Config)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Map }
local script2 = script

local function fn(character, lookVector: Vector3)
	local primaryPart = character.PrimaryPart
	local tagged = CollectionService:GetTagged("Humanoids")
	local index = table.find(tagged, character)

	if index then
		table.remove(tagged, index)
	end

	raycastParams.FilterDescendantsInstances = tagged
	local spherecast = workspace:Spherecast(
		primaryPart.Position - lookVector * 5,
		4,
		lookVector * (Config.RADIUS + 5),
		raycastParams
	)

	if spherecast then
		local find_character_from_descendant = Utility.find_character_from_descendant(spherecast.Instance)

		if not Checker.check_can_select(script, character, find_character_from_descendant) then
			return
		end

		local humanoidRootPart = find_character_from_descendant.HumanoidRootPart
		local v2 = (humanoidRootPart.Position - primaryPart.Position).Magnitude - (spherecast.Distance - 4.5)
		local primaryPart2 = character.PrimaryPart
		local v3 = math.clamp((humanoidRootPart.Position - primaryPart2.Position).Magnitude - v2, 0, Config.RADIUS)
		return
			Utility.SafeLookAt(primaryPart2.Position, humanoidRootPart.Position, primaryPart2.CFrame) * CFrame.new(
				0,
				0,
				-v3
			),
			find_character_from_descendant,
			v2
	else
		local raycastResult = workspace:Raycast(
			primaryPart.Position - lookVector * 5,
			lookVector * (Config.RADIUS + 5),
			raycastParams2
		)

		if raycastResult then
			return Utility.SafeLookAt(primaryPart.Position, raycastResult.Position, primaryPart.CFrame) * CFrame.new(
				0,
				character.Humanoid.HipHeight,
				-(raycastResult.Distance - 10)
			)
		end
	end
end

local HeelBashServer = {
	Id = {},
	Hold = function(player, _: Vector3, state)
		state.stage = "Hold"
		local character = player.Character
		local rootPart = character:FindFirstChild("Humanoid").RootPart
		EffectsEvent.ToAllInRange(player, "Heel Bash VFX", character, "Start")
		state.lock = nil
		task.spawn(function()
			while state.stage == "Hold" and rootPart.Parent ~= nil do
				local lock = state.lock

				if lock ~= nil then
					local character2 = character
					local target = lock.Target
					local v3

					if target == nil or not target:IsDescendantOf(workspace) or target:FindFirstChild("HumanoidRootPart") == nil then
						v3 = false
					else
						v3 = Checker.check_can_select(script, character2, target) and true or false
					end

					if not v3 then
						state.lock = nil
						lock = nil
					end
				end

				local _, target2, standoff = fn(character, rootPart.CFrame.LookVector)

				if target2 ~= nil and standoff ~= nil and (lock == nil or lock.Target ~= target2) then
					state.lock = {
						Target = target2,
						Standoff = standoff
					}
				end

				task.wait(Config.AIM_TICK)
			end
		end)
	end
}
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))

function HeelBashServer.UnHold(player, vector2: Vector3, state)
	state.stage = "Release"
	local character = player.Character
	local getvaluesfolder = Utility.getvaluesfolder(character)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local lock = state.lock
	local v2, target, standoff

	if lock == nil then
		v2, target, standoff = fn(character, rootPart.CFrame.LookVector)
	else
		local target2 = lock.Target
		local v3

		if target2 == nil or not target2:IsDescendantOf(workspace) or target2:FindFirstChild("HumanoidRootPart") == nil then
			v3 = false
		else
			v3 = Checker.check_can_select(script, character, target2) and true or false
		end

		if v3 then
			target = lock.Target
			standoff = lock.Standoff
			local humanoidRootPart = target.HumanoidRootPart
			local primaryPart = character.PrimaryPart
			local v4 = math.clamp(
				(humanoidRootPart.Position - primaryPart.Position).Magnitude - standoff,
				0,
				Config.RADIUS
			)
			v2 = Utility.SafeLookAt(primaryPart.Position, humanoidRootPart.Position, primaryPart.CFrame) * CFrame.new(
				0,
				0,
				-v4
			)
		else
			v2, target, standoff = fn(character, rootPart.CFrame.LookVector)
		end
	end

	local v3 = v2 or rootPart.CFrame + rootPart.CFrame.LookVector * (Config.RADIUS - 5)
	local v4, v5 = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v4:Connect(function()
		HeelBashServer.Cancel(player, vector2, state)
	end)
	state.values = {}
	local add_air_combo_bp = Combat_Util.Add_air_combo_bp(rootPart, nil, 0, nil, Config.RELEASE_LOCK_DUR)
	table.insert(state.values, add_air_combo_bp)
	table.insert(state.values, Utility.AddValue(getvaluesfolder, "NR", Config.RELEASE_LOCK_DUR))
	table.insert(state.values, Utility.AddValue(getvaluesfolder, "skill_stand_still", Config.RELEASE_LOCK_DUR))
	table.insert(state.values, Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.RELEASE_LOCK_DUR))
	task.wait(Config.TELEPORT_AT)

	if state.stage == "Cancel" then
		return
	end

	EffectsEvent.ToAllInRange(rootPart, "Heel Bash VFX", character, "Teleport")
	task.wait(0.05)

	if state.stage == "Cancel" then
		return
	end

	if target and standoff then
		local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and target:IsDescendantOf(workspace) and Checker.check_can_select(script, character, target) then
			local primaryPart = character.PrimaryPart
			local v6 = math.clamp(
				(humanoidRootPart.Position - primaryPart.Position).Magnitude - standoff,
				0,
				Config.RADIUS
			)
			v3 = Utility.SafeLookAt(primaryPart.Position, humanoidRootPart.Position, primaryPart.CFrame) * CFrame.new(
				0,
				0,
				-v6
			)
		end
	end

	rootPart:PivotTo(v3)
	task.wait(Config.PUNCH_AT)

	if state.stage == "Cancel" then
		return
	end

	EffectsEvent.ToAllInRange(rootPart, "Heel Bash VFX", character, "Punch")
	local clone = script.Success:Clone()
	clone.Parent = rootPart
	clone:Play()
	DebrisModule:AddItem(clone, clone.TimeLength + 3)
	local v6 = false
	local instances = {}
	Utility.CreateHitbox({
		caster = character,
		hitboxSize = Config.PUNCH_HITBOX_SIZE,
		hitboxCFrame = rootPart.CFrame * Config.PUNCH_HITBOX_OFFSET,
		targets = target and { target } or nil,
		checker = Checker,
		hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_1"
		},
		hitDetected = function(instance, p, p2)
			local humanoid = instance:FindFirstChild("Humanoid")

			if humanoid == nil then
				return
			end

			local rootPart2 = humanoid.RootPart

			if p2 == "Perfect" then
				Combat_Util.Perfect(script2, character, instance)
				return
			elseif p2 == "Blocking" then
				Combat_Util.Block(script2, character, instance, Config.PUNCH_BLOCK_BREAK)
				return
			end

			table.insert(instances, instance)
			v6 = true
			Combat_Util.Damage(script2, character, instance, {
				Base = Config.PUNCH_DAMAGE,
				Skill = script.Parent.Name
			})
			Combat_Util.AddStun(script2, character, p, Config.PUNCH_STUN)
			Combat_Util.RagDoll(script2, character, p, Config.PUNCH_RAGDOLL)
			local v7 = rootPart.CFrame.lookVector * Config.PUNCH_KNOCKBACK
			Combat_Util.Knockback(script2, character, rootPart2, Vector3.new(v7.X, 0.15, v7.Z), 1.75, "remove_airbp")
		end
	})

	if v6 == false then
		v5()
		HeelBashServer.Cancel(player, vector2, state)
		ServerClientPortal.ToClient(player, script.Parent.Name)
	end

	task.wait(Config.KICK_AT)

	if state.stage == "Cancel" then
		if clone then
			clone:Destroy()
		end
	else
		EffectsEvent.ToAllInRange(rootPart, "Heel Bash VFX", character, "Teleport")
		local position = rootPart.Position
		state.bp = Combat_Util.Add_air_combo_bp(rootPart, nil, Config.KICK_RISE_HEIGHT, position, Config.KICK_PIN_DUR, {
			Responsiveness = 100
		})
		task.wait(0.05)

		if state.stage == "Cancel" then
			if clone then
				clone:Destroy()
			end
		else
			EffectsEvent.ToAllInRange(rootPart, "Heel Bash VFX", character, "Kick")
			task.wait(Config.SLAM_AT)

			if state.stage == "Cancel" then
				if clone then
					clone:Destroy()
				end
			else
				state.bp.bpv.Position = position
				task.wait(Config.SLAM_FALL_DUR)

				if state.stage == "Cancel" then
					if clone then
						clone:Destroy()
					end
				else
					local position2 = rootPart.Position
					local raycastResult = workspace:Raycast(
						position2 + createVector(0, 1, 0),
						Vector3.new(0, -Config.SLAM_GROUND_CAST, 0),
						raycastParams2
					)

					if raycastResult ~= nil and raycastResult.Instance ~= nil then
						position2 = raycastResult.Position
					end

					local v7 = math.max(
						Config.SLAM_HITBOX_SIZE.Y,
						rootPart.Position.Y - position2.Y + Config.SLAM_HITBOX_SIZE.Y
					)
					local vector3 = Vector3.new(Config.SLAM_HITBOX_SIZE.X, v7, Config.SLAM_HITBOX_SIZE.Z)
					local hitboxCFrame = CFrame.new(position2 + Vector3.new(0, v7 * 0.5, 0)) * rootPart.CFrame.Rotation
					EffectsEvent.ToAllInRange(rootPart, "Heel Bash VFX", character, "Slam", position2)
					Utility.CreateHitbox({
						caster = character,
						hitboxSize = vector3,
						hitboxCFrame = hitboxCFrame,
						checker = Checker,
						hitPriorityHandler = {
							callback = v.Exists,
							data = "Choosing_1"
						},
						targets = instances,
						hitDetected = function(instance, p, p2)
							local humanoid = instance:FindFirstChild("Humanoid")

							if humanoid == nil then
								return
							end

							local rootPart2 = humanoid.RootPart

							if p2 == "Perfect" then
								Combat_Util.Perfect(script2, character, instance)
								return
							elseif p2 == "Blocking" then
								Combat_Util.Block(script2, character, instance, Config.SLAM_BLOCK_BREAK)
								return
							end

							Combat_Util.Damage(script2, character, instance, {
								Base = Config.SLAM_DAMAGE,
								Skill = script.Parent.Name
							})
							Combat_Util.RagDoll(script2, character, p, Config.SLAM_RAGDOLL)
							Combat_Util.Knockback(
								script2,
								character,
								rootPart2,
								rootPart.CFrame.LookVector * Config.SLAM_KNOCKBACK + Vector3.new(
									0,
									Config.SLAM_KNOCKUP,
									0
								),
								0.135
							)
							Combat_Util.Add_Strict_Stun(script2, character, p, Config.SLAM_STUN)
						end
					})

					if state.bp then
						state.bp:Destroy()
					end

					v5()
				end
			end
		end
	end
end

function HeelBashServer.Cancel(_, _: Vector3, state)
	state.stage = "Cancel"

	if state.values then
		for _, value in pairs(state.values) do
			game.Debris:AddItem(value, 0.25)
		end
	end

	if state.bp then
		game.Debris:AddItem(state.bp, 0.25)
	end
end

return HeelBashServer