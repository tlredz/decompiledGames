local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local global = ReplicatedStorage2:WaitForChild("CAM"):WaitForChild("Global")
local hit_priority_handler = require(ServerStorage.SAM.Game_Play.hit_priority_handler)
local v = hit_priority_handler.new(script)
local Combat_Util = require(ServerStorage.SAM.Services.Combat_Util)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Combat_presets = require(ReplicatedStorage.CAM.Global.Combat_presets)
local Skill_Switch_Adder = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Skill_Switch_Adder)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Utility = require(global.Utility)
local ServerClientPortal = require(global.ServerClientPortal)
local Config = require(script.Parent.Config)
local gameSettings = require(global.gameSettings)
local ExplodingBeadsServer = {
	Id = {}
}
local TweenService = game:GetService("TweenService")

local function clearBeadParts(state)
	if state == nil or state.BeadParts == nil then
		return
	end

	for _, beadPart in state.BeadParts do
		if beadPart ~= nil and beadPart.Parent ~= nil then
			beadPart:Destroy()
		end
	end

	state.BeadParts = nil
end

function ExplodingBeadsServer.Hold(player, p, state)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local getvaluesfolder = Utility.getvaluesfolder(character)
	local v2 = ExplodingBeadsServer.Id[player.UserId]

	if Utility.SinglePartHitbox({
		Caster = character,
		ParamsName = `{player.Name}-{script.Parent.Name}-detect`,
		Origin = humanoidRootPart.CFrame * Config.DETECT_OFFSET,
		BoxSize = Config.DETECT_SIZE
	}) then
		state.branch = "Close"
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.CLOSE_TOTAL_DURATION)
		ServerClientPortal.ToClient(player, script.Parent.Name, "Close")
		EffectsEvent.ToAllInRange(player, "Exploding BeadsVFX", character, "CloseStart")
		local hitboxCFrame = humanoidRootPart.CFrame * Config.CLOSE_BOMB_OFFSET
		task.wait(Config.CLOSE_PLACE_AT)

		if ExplodingBeadsServer.Id[player.UserId] ~= v2 then
			return
		end

		EffectsEvent.ToAllInRange(player, "Exploding BeadsVFX", character, "Placebomb", hitboxCFrame)
		Utility.CreateHitbox({
			caster = character,
			hitboxCFrame = hitboxCFrame,
			hitboxSize = Config.LIFT_HITBOX_SIZE,
			checker = Checker,
			hitPriorityHandler = {
				callback = v.Exists,
				data = "Choosing_3"
			},
			hitDetected = function(instance, p2, p3)
				if p3 == "Perfect" then
					Combat_Util.Perfect(script, character, instance)
				elseif p3 == "Blocking" then
					Combat_Util.Block(script, character, instance, Config.LIFT_BLOCK_BREAK)
				elseif p3 == true then
					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
					Combat_Util.Knockback(
						script,
						character,
						humanoidRootPart2,
						Vector3.new(0, Config.LIFT_KNOCKBACK, 0),
						Config.LIFT_DURATION
					)
					Combat_Util.AddStun(script, character, p2, Config.LIFT_STUN)
					Combat_presets.PlayReactAnim(instance:FindFirstChild("Humanoid"), nil, 0.2)
				end
			end
		})
		local hitboxCFrame2 = hitboxCFrame * Config.CLOSE_HITBOX_OFFSET
		task.delay(Config.CLOSE_DETONATE_DELAY, function()
			Utility.CreateHitbox({
				caster = character,
				hitboxCFrame = hitboxCFrame2,
				hitboxSize = Config.CLOSE_HITBOX_SIZE,
				checker = Checker,
				hitPriorityHandler = {
					callback = v.Exists,
					data = "Choosing_3"
				},
				hitDetected = function(instance, p2, p3)
					local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

					if p3 == "Perfect" then
						Combat_Util.Perfect(script, character, instance)
					elseif p3 == "Blocking" then
						Combat_Util.Block(script, character, instance, Config.CLOSE_BLOCK_BREAK)
					elseif p3 == true then
						Combat_Util.Damage(script, character, instance, {
							Base = Config.CLOSE_DAMAGE,
							Skill = script.Parent.Name
						})
						Combat_Util.AddStun(script, character, p2, Config.CLOSE_STUN)
						Combat_Util.RagDoll(script, character, p2, Config.CLOSE_RAGDOLL)
						local v5 = vector.normalize(humanoidRootPart2.Position - hitboxCFrame2.Position) * Config.CLOSE_KNOCKBACK
						Combat_Util.Knockback(
							script,
							character,
							humanoidRootPart2,
							vector.create(v5.X, Config.CLOSE_KNOCKUP, v5.Z),
							Config.CLOSE_KNOCKBACK_DURATION
						)
					end
				end
			})
		end)
	else
		state.branch = "Far"
		Utility.AddValue(getvaluesfolder, "pause_gameplay", Config.FAR_LOCK_DURATION)
		ServerClientPortal.ToClient(player, script.Parent.Name, "Far")
		task.wait(Config.FAR_THROW_AT)

		if ExplodingBeadsServer.Id[player.UserId] ~= v2 then
			return
		end

		state.thrown = true
		state.armedAt = os.clock()
		local cFrame = humanoidRootPart.CFrame

		if p ~= nil then
			local vector2 = Vector3.new(p.X, humanoidRootPart.Position.Y, p.Z)
			cFrame = Utility.SafeLookAt(humanoidRootPart.Position, vector2, humanoidRootPart.CFrame)
		end

		local singlePartHitbox = Utility.SinglePartHitbox({
			Caster = character,
			ParamsName = `{player.Name}-{script.Parent.Name}-far-detect`,
			Origin = cFrame * Config.FAR_DETECT_OFFSET,
			BoxSize = Config.FAR_DETECT_SIZE
		})
		state.BeadPlan = {}
		state.BeadCFrames = {}
		state.Timings = {}
		local count = 0
		local v3

		if singlePartHitbox then
			local cFrame2 = singlePartHitbox.CFrame
			v3 = math.random(Config.FAR_TARGET_BEADS_MIN, Config.FAR_TARGET_BEADS_MAX)

			for _ = 1, v3 do
				count += 1
				state.BeadPlan[count] = {
					Absolute = true,
					Offset = cFrame2 * CFrame.new(math.random(-3, 3), math.random(-1, 3), math.random(-3, 3))
				}
				state.Timings[count] = math.random(1, 5) * Config.BEAD_STAGGER_UNIT
			end
		else
			v3 = 0
		end

		for _ = 1, Config.FAR_TOTAL_BEADS - v3 do
			count += 1
			state.BeadPlan[count] = {
				Absolute = false,
				Offset = CFrame.new(
					math.random(-Config.BEAD_SIDE_SPREAD, Config.BEAD_SIDE_SPREAD),
					math.random(-Config.BEAD_HEIGHT_SPREAD, Config.BEAD_HEIGHT_SPREAD),
					-math.random(Config.BEAD_RANGE_MIN, Config.BEAD_RANGE_MAX)
				)
			}
			state.Timings[count] = math.random(1, 5) * Config.BEAD_STAGGER_UNIT
		end

		Skill_Switch_Adder.Add(player, script.Parent.Name, Config.FAR_DETONATE_WINDOW)
		EffectsEvent.ToAllInRange(player, "Exploding BeadsVFX", character, "BeadsPlacement")
		state.BeadParts = {}
		local tweenInfo = TweenInfo.new(Config.BEAD_TRAVEL_TIME)
		local v4 = Config.FAR_DETONATE_WINDOW + Config.BEAD_TRAVEL_TIME + 1
		local total = 0

		for k, v5 in state.BeadPlan do
			total += state.Timings[k]
			local v6 = v5
			local v7 = k
			task.delay(total, function()
				if state.exploded or state.cancelled or humanoidRootPart.Parent == nil then
					return
				end

				local cFrame2 = humanoidRootPart.CFrame
				local offset

				if v6.Absolute then
					offset = v6.Offset
				else
					offset = cFrame2 * v6.Offset
				end

				state.BeadCFrames[v7] = offset
				local v8 = cFrame2 * Config.BEAD_THROW_ORIGIN
				EffectsEvent.ToAllInRange(player, "Exploding BeadsVFX", character, "BeadThrow", v7, {
					Start = v8,
					Goal = offset
				})
				local part = Instance.new("Part")
				part.Name = `{player.Name}-{script.Parent.Name}-Trip{v7}`
				part.Size = Config.BEAD_TRIGGER_SIZE
				part.CFrame = v8
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = true

				if gameSettings.hitboxVisualiserEnabled == true then
					part.Transparency = gameSettings.HitBoxTransparency or 0.85
					part.Color = Color3.fromRGB(255, 0, 0)
				else
					part.Transparency = 1
				end

				part.Massless = true
				part.Parent = workspace.Debree
				state.BeadParts[v7] = part
				DebrisModule:AddItem(part, v4)
				TweenService:Create(part, tweenInfo, {
					CFrame = offset
				}):Play()
				part.Touched:Connect(function(otherPart)
					if state.exploded or state.cancelled or not otherPart:IsDescendantOf(workspace.Humanoids) then
						return
					end

					local find_character_from_descendant = Utility.find_character_from_descendant(otherPart)

					if find_character_from_descendant == nil or find_character_from_descendant == character or Checker.check_victim(
						script,
						character,
						find_character_from_descendant
					) == nil then
						return
					end

					state.Tripper = find_character_from_descendant
					ExplodingBeadsServer.Switch(player, nil, state, v7)
				end)
			end)
		end

		task.delay(Config.FAR_DETONATE_WINDOW, function()
			if state.exploded or state.cancelled then
				return
			end

			ExplodingBeadsServer.Switch(player, nil, state)
		end)
	end
end

function ExplodingBeadsServer.Switch(player, _, state, p)
	if state.exploded or state.cancelled then
		return
	end

	state.exploded = true

	if state.BeadParts ~= nil then
		for k, beadPart in state.BeadParts do
			if beadPart ~= nil and beadPart.Parent ~= nil then
				state.BeadCFrames[k] = beadPart.CFrame
			end
		end
	end

	clearBeadParts(state)
	local child = player:FindFirstChild(script.Parent.Name .. Skill_Switch_Adder.extension)

	if child ~= nil then
		child:Destroy()
	end

	EffectsEvent.ToAllInRange(
		player,
		"Exploding BeadsVFX",
		player.Character,
		"BeadsExplode",
		state.BeadCFrames,
		state.Timings,
		p
	)
	local character = player.Character

	if not character then
		return
	end

	for k, v2 in Config.DetonationOrder(#state.Timings, p) do
		if k > 1 then
			task.wait(state.Timings[v2])
		end

		if state.cancelled then
			break
		end

		local beadCFrame = state.BeadCFrames[v2]

		if beadCFrame == nil then
			continue
		end

		local createHitbox = Utility.CreateHitbox
		local v3 = {
			caster = character,
			hitboxCFrame = beadCFrame,
			hitboxSize = Config.BEAD_HITBOX_SIZE,
			targets = 0,
			checker = 0,
			hitPriorityHandler = 0,
			hitDetected = 0
		}
		local targets

		if v2 == p then
			targets = state.Tripper
		end

		v3.targets = targets
		v3.checker = Checker
		v3.hitPriorityHandler = {
			callback = v.Exists,
			data = "Choosing_3"
		}

		function v3.hitDetected(instance, p2, p3)
			if p3 == "Perfect" or p3 == "Blocking" then
				Combat_Util.Block(script, character, instance, Config.BEAD_BLOCK_BREAK)
			elseif p3 == true then
				Combat_Util.Damage(script, character, instance, {
					Base = Config.BEAD_DAMAGE,
					Skill = script.Parent.Name
				})
				Combat_Util.AddStun(script, character, p2, Config.BEAD_STUN)
				Combat_presets.PlayReactAnim(instance.Humanoid)
			end
		end

		createHitbox(v3)
	end
end

function ExplodingBeadsServer.Cancel(player, _, state)
	if not player then
		return
	end

	if state ~= nil then
		if state.thrown then
			local v2 = Config.FAR_DETONATE_WINDOW - (os.clock() - (state.armedAt or 0))

			if not state.exploded and v2 > 0 and player:FindFirstChild(script.Parent.Name .. Skill_Switch_Adder.extension) == nil then
				Skill_Switch_Adder.Add(player, script.Parent.Name, v2)
			end
		else
			state.cancelled = true
			clearBeadParts(state)
		end
	end

	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	EffectsEvent.ToAllInRange(player, "Exploding BeadsVFX", character, "Cancel")
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
end

return ExplodingBeadsServer