local createVector = vector.create
require(game.ReplicatedStorage.MovesetTypes)
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local RunService = game:GetService("RunService")
local isRunning = RunService:IsRunning()
local UserInputService = game:GetService("UserInputService")
local RunService2 = game:GetService("RunService")
local Anims = require(game.ReplicatedStorage.Util.Anims)
local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
local Ray = require(game.ReplicatedStorage.Util.Ray)
local ogCooldown = {
	Z = 5,
	X = 8,
	C = 12.5,
	V = 16.5,
	F = 4.25
}
local object = setmetatable({}, {
	__mode = "k"
})

local function copyCooldowns()
	local result = {}

	for k, v2 in ogCooldown do
		result[k] = v2
	end

	return result
end

local function fakeTool(object2)
	local v2 = {
		Connect = function()
			return {
				Disconnect = function() end
			}
		end
	}
	return {
		Parent = object2.character,
		Equipped = v2,
		Unequipped = v2,
		Activated = v2,
		AncestryChanged = v2,
		IsDescendantOf = function()
			return object2.character.Parent ~= nil
		end
	}
end

local function createRuntime(object2)
	local tool = object2.tool or fakeTool(object2)
	local character = object2.character
	local rootPart = object2.rootPart
	local humanoid = object2.humanoid
	local player = object2.player
	local data = object2.data

	if not data then
		local cooldown = {}
		data = {
			Cooldown = 0
		}

		for k, v3 in ogCooldown do
			cooldown[k] = v3
		end

		data.Cooldown = cooldown
	end

	local interactiveEffects = workspace._WorldOrigin:FindFirstChild("InteractiveEffects")

	if interactiveEffects then
		local v4

		if player then
			v4 = player.Name
		else
			v4 = character.Name
		end

		interactiveEffects = interactiveEffects:FindFirstChild("GhostProxyStorage_" .. v4)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
	local v3 = {}

	for _, v4 in pairs({
		"PainCHold",
		"PainCFire",
		"PainZTap",
		"PainDeathAnim",
		"PainBigGhostRoar",
		"PainZHold",
		"PainVFire",
		"PainVHold",
		"PainVSpiritHold",
		"PainVSpiritRelease",
		"PainVSpiritActivate",
		"PainXHold",
		"PainXDash",
		"PainXSuccess",
		"PainXBeamSuccess",
		"PainFHold",
		"PainFDash",
		"PainFSuccess",
		"PainAura",
		"PainM1_1",
		"PainM1_2",
		"PainM1_3",
		"PainM1_4",
		"PainFAirHold",
		"PainFKick",
		"PainFLand",
		"PainFStart",
		"PainDashBack",
		"PainDashForwardL",
		"PainDashForwardR",
		"PainDashL",
		"PainDashR",
		"PainSkyJumpL",
		"PainSkyJumpR",
		"PainAwakenedIdle",
		"PainRevive",
		"PainGhostSpawn",
		"PainGhost",
		"PainGhost2",
		"PainRun"
	}) do
		Anims:Preload(v4)
	end

	local v4 = {}
	v3.LASTSTAND = false
	local v5 = {}
	local v6 = false
	v5.Equipped = tool.Equipped:Connect(function()
		v6 = true
	end)
	v5.Unequipped = tool.Unequipped:Connect(function()
		v6 = false
	end)
	v5.Equipped = tool.Equipped:Connect(function()
		v6 = true
	end)
	v5.Unequipped = tool.Unequipped:Connect(function()
		v6 = false
	end)
	v5.ChildAdded = character.ChildAdded:Connect(function(child)
		if child.Name == "PainTransformed" then
			v3.LASTSTAND = true
			local v7 = 0
			local v8 = 0
			task.wait()
			task.wait()
			local painAwakenedIdle = Anims:Get(character, "PainAwakenedIdle")
			painAwakenedIdle.Priority = Enum.AnimationPriority.Idle
			painAwakenedIdle:Play()
			local painRun = nil
			v4.Running = humanoid.Running:Connect(function(p)
				if p > 0.1 and object2.holdingInstance.Value == false then
					if painRun == nil then
						painRun = Anims:Get(character, "PainRun")
						painRun.Priority = Enum.AnimationPriority.Movement
						painRun.Looped = true
						painRun:Play()
					end

					painRun:AdjustSpeed(p / 48)
				elseif painRun ~= nil then
					painRun:Stop()
					painRun = nil
				end
			end)
			v4.StateChanged = humanoid.StateChanged:Connect(function(_, _)
				if humanoid.MoveDirection.Magnitude == 0 and painRun ~= nil then
					painRun:Stop()
					painRun = nil
				end
			end)
			local lastTime = tick()

			local function onJumped(p)
				if tick() - lastTime < 0.05 then
					return
				end

				lastTime = tick()
				local v9, _, _ = Ray(
					rootPart.Position,
					createVector(-0, -1, -0) * (rootPart.Size.Y * 0.5 + humanoid.HipHeight + 2),
					{ workspace.Characters, workspace.Enemies },
					false
				)
				local v10 = v8 == 0 and "PainSkyJumpR" or "PainSkyJumpL"
				v8 = v8 == 0 and 1 or 0

				if not p and not v9 then
					return
				end

				local v11 = Anims:Get(character, v10)
				v11.Priority = Enum.AnimationPriority.Action
				v11.Looped = false
				v11:Play(0.2)
				v11:AdjustWeight(1, 0.0001)
				v11:AdjustSpeed(1)
			end

			v4.IsJumping = humanoid.Jumping:Connect(function()
				onJumped()
			end)
			local v9 = v4
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			v9.Dodged = ReplicatedStorage.PlayerDodged.Event:Connect(function()
				local camera = object2.camera

				if not camera then
					return
				end

				local vector2 = CFrame.lookAt(
					createVector(0, 0, 0),
					camera.CFrame.LookVector * createVector(1, 0.001, 1)
				):VectorToObjectSpace(humanoid.MoveDirection)
				local v10 = vector2:Dot(createVector(1, 0, 0)) > 0.7071067811865476
				local v11 = vector2:Dot(createVector(-1, 0, 0)) > 0.7071067811865476
				local _ = vector2:Dot(createVector(0, 0, -1)) > 0.7071067811865476
				local v12 = vector2:Dot(createVector(0, 0, 1)) > 0.7071067811865476
				local v13 = v7 == 0 and "PainDashForwardR" or "PainDashForwardL"
				v7 = v7 == 0 and 1 or 0
				local Global = require(game.ReplicatedStorage.Global)

				if Global.Shiftlock or UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
					v13 = v12 and "PainDashBack" or v10 and "PainDashR" or v11 and "PainDashL" or v13
				end

				local v14 = Anims:Get(character, v13)
				v14.Priority = Enum.AnimationPriority.Action
				v14.Looped = false
				v14:Play(0.1)
				v14:AdjustWeight(1, 0.0001)
			end)
			local ancestryChangedConnection = nil
			ancestryChangedConnection = child.AncestryChanged:Connect(function()
				if child:IsDescendantOf(character) then
					return
				end

				ancestryChangedConnection:Disconnect()
				v3.LASTSTAND = false

				for _, connection in pairs(v4) do
					connection:Disconnect()
				end

				if painAwakenedIdle then
					painAwakenedIdle:Stop()
				end

				if painRun then
					painRun:Stop()
				end

				if child then
					child:Destroy()
				end
			end)
		end
	end)
	game:GetService("UserInputService")
	local thread = nil
	local v7 = 1
	local time2 = time
	local v8 = time2()
	v5.Activated = tool.Activated:Connect(function()
		local Global = require(game.ReplicatedStorage.Global)

		if Global.mobileSoru or tool.Parent:FindFirstChildOfClass("Humanoid") == nil or humanoid.Sit or object2.holdingInstance.Value then
			return
		end

		if player.Character.Busy.Value or player.Character.Stun.Value > 0 then
			return
		end

		if time2() - v8 > 0 then
			local v9 = workspace:Raycast(
				rootPart.Position,
				-(humanoid.HipHeight + rootPart.Size.Y * 0.5 + 4) * createVector(0, 1, 0),
				raycastParams
			) ~= nil
			tool:WaitForChild("LeftClickRemote"):FireServer(
				((object2:aim() - rootPart.Position) * createVector(1, 0, 1)).Unit,
				v7,
				v9
			)
			local v10 = Anims:Get(
				character,
				v3.LASTSTAND and "AwakenedPainM1_" .. tostring(v7) or "PainM1_" .. tostring(v7)
			)
			v10.Looped = false
			v10:Play()
			local combo = v7
			task.delay(0.08, function()
				local new = Effect.new
				local v12

				if isRunning then
					v12 = v3.LASTSTAND and game.ReplicatedStorage.EffectContainer.Pain.M1_Awakened or game.ReplicatedStorage.EffectContainer.Pain.M1
				else
					v12 = require(v3.LASTSTAND and game.ReplicatedStorage.EffectContainer.Pain.M1_Awakened or game.ReplicatedStorage.EffectContainer.Pain.M1)
				end

				new(v12):play({
					origin = rootPart.Position,
					player = player,
					Combo = combo,
					Character = character,
					Root = rootPart
				})
			end)
			local duration = 0.3
			local unit = ((object2:aim() - rootPart.Position) * createVector(1, 0, 1)).Unit
			local v13 = v7 < 4 and 0.3 or 1
			local FruitM1Speed = require(game.ReplicatedStorage.Modules.FruitM1Speed)
			local v14 = v13 * FruitM1Speed.getCooldownScale(character)

			if thread then
				task.cancel(thread)
			end

			thread = task.delay(1, function()
				v7 = 1
			end)
			local Global2 = require(game.ReplicatedStorage.Global)

			if not Global2.Dodging then
				duration = v7 == 4 and 0.7 or duration
				local v15

				if v7 == 3 then
					v15 = BodyMover.new(character):Create("BodyVelocity", {
						Priority = -100,
						Velocity = unit * 1 + createVector(0, 60, 0),
						Duration = duration
					})
				else
					v15 = BodyMover.new(character):Create("BodyVelocity", {
						Priority = -100,
						Velocity = unit * 20 * 2,
						Duration = duration
					})
				end

				task.spawn(function()
					local lastTime = tick()
					local v16 = false

					while tick() - lastTime < duration do
						if tick() - lastTime > 0.15 and not v16 then
							v15:SetForce(createVector(0, 100000, 0))
							v16 = true
						end

						local Global3 = require(game.ReplicatedStorage.Global)

						if Global3.Dodging then
							v15:Destroy()
							break
						else
							task.wait()
						end
					end
				end)
			end

			local v15 = BodyMover.new(character):Create("BodyGyro", {
				Priority = -100,
				CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + unit)
			})
			humanoid.AutoRotate = false
			task.delay(duration, function()
				v15:Destroy()
				humanoid.AutoRotate = true
			end)

			if v7 < 4 then
				v7 += 1
			else
				v7 = 1
			end

			v8 = time2() + v14
		end
	end)
	v5.Died = humanoid.Died:Connect(function()
		for _, connection in pairs(v5) do
			connection:Disconnect()
		end
	end)
	v5.AncestryChanged = tool.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			for _, connection in pairs(v5) do
				connection:Disconnect()
			end
		end
	end)
	v3.lastF = 0
	v3.divedF = 0
	v3.Tool = tool
	v3.data = data
	v3.ogCooldown = ogCooldown
	v3.auraCdBuff = 0.777
	v3.lastStandCdBuff = 0.333
	v3.GhostProxyStorage = interactiveEffects
	v3.bloxFruitsRaycastParams = raycastParams

	function v3.aim()
		return object2:aim()
	end

	function v3.toolActive()
		if object2.tool then
			return object2.tool:IsDescendantOf(character)
		end

		return character.Parent ~= nil
	end

	function v3.closestGhostInRange(vector2: Vector3, p: number)
		local v3 = nil

		if not interactiveEffects then
			return nil
		end

		for _, child in pairs(interactiveEffects:GetChildren()) do
			if child:GetAttribute("Active") ~= true then
				continue
			end

			local magnitude = (child.Position - vector2).Magnitude

			if not (magnitude <= p) then
				continue
			end

			v3 = child
			p = magnitude
		end

		return v3
	end

	return v3
end

local function getRuntime(p)
	local tool = p.tool or p.character
	local v2 = object[tool]

	if not v2 then
		v2 = createRuntime(p)
		object[tool] = v2
	end

	return v2
end

local PainPain = {}

function PainPain.setup(p)
	if not RunService2:IsClient() then
		return nil
	end

	local tool = p.tool or p.character

	if not object[tool] then
		object[tool] = createRuntime(p)
	end

	return nil
end

function PainPain.getRuntime(p)
	if not RunService2:IsClient() then
		return nil
	end

	local tool = p.tool or p.character
	local v2 = object[tool]

	if not v2 then
		v2 = createRuntime(p)
		object[tool] = v2
	end

	return v2
end

return PainPain