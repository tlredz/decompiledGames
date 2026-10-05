local createVector = vector.create
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local ColorsUtil = require(ReplicatedStorage.Common.ColorsUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Utils = require(ReplicatedStorage.Common.Utils)
local _ = { workspace.Map, workspace.Runtime }
local invert = Lighting.Invert
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local v = true
task.spawn(function()
	FFlagClient:WaitForData()
	v = FFlagClient:GetKey("TIME_HOLE_V2_EFFECTS_ENABLED") and true or false
	FFlagClient.DataUpdatedEvent:Connect(function()
		v = FFlagClient:GetKey("TIME_HOLE_V2_EFFECTS_ENABLED") and true or false
	end)
end)
local v2 = true
task.spawn(function()
	FFlagClient:WaitForData()
	v2 = FFlagClient:GetKey("TIME_HOLE_V2_SFX_ENABLED") and true or false
	FFlagClient.DataUpdatedEvent:Connect(function()
		v2 = FFlagClient:GetKey("TIME_HOLE_V2_SFX_ENABLED") and true or false
	end)
end)
local timeHole = ReplicatedStorage.Assets.Abilities.TimeHole
invert.Enabled = false
local v3 = {}

local function getInstanceTrove(instance, p: string, callback)
	local maid = v3[instance]

	if maid then
		return maid
	end

	maid = Trove.new()

	if p == "Destroying" then
		maid:AttachToInstance(instance)
	else
		local v4 = nil
		v4 = maid:Add(function(_, p2)
			if callback and not callback(p2) or not callback and p2 == nil then
				return
			end

			maid:Remove(v4)
			maid:Destroy()
			v3[instance] = nil
		end)
	end

	maid:Add(function()
		v3[instance] = nil
	end)
	v3[instance] = maid
	return maid
end

local function getEffects(folder)
	local effects = {}

	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
			table.insert(effects, effect)
		end
	end

	return effects
end

local v4 = 0

local function updateLocalTransparency(head, items, aura)
	local now = tick()

	if now - v4 < 0.1 then
		return
	end

	v4 = now
	local localTransparencyModifier = math.clamp(
		not head and 20 or (head.Position - currentCamera.CFrame.Position).Magnitude,
		10,
		20
	) * -0.1 + 2

	for _, item in items do
		if item then
			item.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	if aura then
		aura.Rate = (1 - localTransparencyModifier) * -80 + 20
	end
end

return function(instance, data)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local range = data.range
	local halfRange = range / 2
	local instanceTrove = getInstanceTrove(instance, "Ancestry")
	local clone = instanceTrove:Clone(timeHole.Sphere)

	if v2 then
		clone.Activate:Play()
		clone.Loop:Play()
	end

	Utils.Physics.ResizePart(clone, range / 50)
	clone.GroundEffect.Position = createVector(-0, -2.7, -0)
	clone.CFrame = humanoidRootPart:GetPivot()
	clone.Anchored = true
	clone.Size = createVector(0, 0, 0)
	clone.ForceField.Size = createVector(0, 0, 0)
	local effects = getEffects(clone)

	for _, effect in effects do
		if not effect:IsDescendantOf(clone.Start) then
			effect.Enabled = false
		end
	end

	clone.Parent = currentCamera
	local clone2 = instanceTrove:Clone(timeHole.Cylinder)
	clone2.Anchored = true
	clone2.Size = createVector(0, 0.5, 0)
	clone2.Parent = currentCamera
	local raycastParams = RaycastParams.new()
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = true
	raycastParams.FilterDescendantsInstances = { workspace.Alive, workspace.Dead }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterDescendantsInstances = { clone }
	raycastParams2.FilterType = Enum.RaycastFilterType.Include
	local head = instance:FindFirstChild("Head")
	local aura = clone:FindFirstChild("Aura", true)
	local v6 = { clone, clone2 }
	instanceTrove:Add(RunService.PostSimulation:Connect(function(_: number)
		local pivot = humanoidRootPart:GetPivot()
		local v7 = math.clamp(pivot.Y - halfRange, data.floorY, (math.max(pivot.Y, data.floorY)))
		clone:PivotTo(CFrame.new(pivot.Position))
		local raycastResult = workspace:Raycast(
			Vector3.new(pivot.X, v7, pivot.Z) + createVector(0, 0, 1) * halfRange,
			createVector(-0, -0, -1) * range,
			raycastParams2
		)
		local v8

		if raycastResult then
			v8 = (raycastResult.Position.Z - pivot.Z) / halfRange * range
		else
			v8 = (halfRange + (v7 - pivot.Y)) * 2
		end

		local v9 = math.min(clone.Size.X, v8) + 0.1
		clone2.Size = Vector3.new(v9, 0.5, v9)
		clone2.CFrame = CFrame.new(pivot.X, math.max(v7 + 0.25 - 3, data.floorY), pivot.Z)

		if playerFromCharacter == localPlayer then
			updateLocalTransparency(head, v6, aura)
		end
	end))

	if data.isUpgraded and v then
		ColorsUtil:YellowToPurpleInstance(clone)
	end

	for _, v7 in v6 do
		v7.Transparency = 0.4
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	instanceTrove:Add(TweenService:Create(clone, tweenInfo, {
		Size = createVector(1, 1, 1) * range
	})):Play()
	instanceTrove:Add(TweenService:Create(clone.ForceField, tweenInfo, {
		Size = createVector(1, 1, 1) * (range + 0.75)
	})):Play()

	for _, texture in clone:GetChildren() do
		if not texture:IsA("Texture") then
			continue
		end

		texture.Transparency = 1
		instanceTrove:Add(TweenService:Create(texture, tweenInfo, {
			Transparency = 0.7
		})):Play()
	end

	if instance == localPlayer.Character or localPlayer.Character and localPlayer:DistanceFromCharacter(instance:GetPivot().Position) <= range * 1.5 then
		invert.Enabled = true
		Lighting.ExposureCompensation = -7
		instanceTrove:Add(TweenService:Create(
			Lighting,
			TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				ExposureCompensation = 0
			}
		)):Play()
		instanceTrove:Add(task.delay(0.5, function()
			invert.Enabled = false
		end))
	end

	local extended = instanceTrove:Extend()

	local function updateCharacterVFX()
		extended:Clean()

		if playerFromCharacter:GetAttribute("TimeHoleHoldBall") then
			for _, child in timeHole.BallHoldCharacterEffect:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if not child2 then
					continue
				end

				for _, child3 in child:GetChildren() do
					local clone3 = extended:Clone(child3)

					if data.isUpgraded and v then
						ColorsUtil:YellowToPurpleInstance(clone3)
					end

					clone3.Parent = child2
				end
			end
		end
	end

	instanceTrove:Add(playerFromCharacter:GetAttributeChangedSignal("TimeHoleHoldBall"):Connect(updateCharacterVFX))
	task.spawn(updateCharacterVFX)
	Utils.Visual:PlayEffects(clone.Start)

	for _, emitter in effects do
		if emitter:IsDescendantOf(clone.Start) then
			continue
		end

		if emitter:IsA("ParticleEmitter") then
			local timeScale = emitter.TimeScale
			emitter.TimeScale = 1
			instanceTrove:Add(TweenService:Create(emitter, tweenInfo, {
				TimeScale = timeScale
			})):Play()
		end

		emitter.Enabled = true
	end

	local function onEnd()
		if instanceTrove._cleaning then
			return
		end

		instanceTrove:Add(TweenService:Create(clone, tweenInfo2, {
			Transparency = 1
		})):Play()
		instanceTrove:Add(TweenService:Create(clone.ForceField, tweenInfo2, {
			Transparency = 1
		})):Play()
		instanceTrove:Add(TweenService:Create(clone2, tweenInfo2, {
			Transparency = 1
		})):Play()

		for _, texture in clone:GetChildren() do
			if texture:IsA("Texture") then
				instanceTrove:Add(TweenService:Create(texture, tweenInfo2, {
					Transparency = 1
				})):Play()
			end
		end

		for _, emitter in getEffects(clone) do
			emitter.Enabled = false

			if emitter:IsA("ParticleEmitter") then
				emitter:Clear()
			end
		end

		instanceTrove:Add(task.delay(1, function()
			instanceTrove:Destroy()
		end))
	end

	local maid = instanceTrove:Extend()
	maid:Add(onEnd)
	maid:Add(task.delay(data.endTime - workspace:GetServerTimeNow(), function()
		maid:Destroy()
	end))
	return maid
end