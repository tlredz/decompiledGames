local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fireflyEgg = FX:WaitForChild("FireflyEgg")
return function(data)
	local parent = data.Egg.Parent

	local function hide()
		data.Egg.Parent = script
	end

	local function show()
		data.Egg.Parent = parent
	end

	local egg = data.Egg
	local primaryPart = egg.PrimaryPart

	if not primaryPart then
		warn("Egg has no PrimaryPart")
		return
	end

	local v = {}
	data.Maid:Add(primaryPart.Touched:Connect(function(otherPart)
		local parent2 = otherPart.Parent

		if not parent2 then
			return
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(parent2)

		if not playerFromCharacter or v[playerFromCharacter] then
			return
		end

		v[playerFromCharacter] = true
		task.delay(1, function()
			v[playerFromCharacter] = nil
		end)
		local EasterNetwork = require(ReplicatedStorage.Controllers.UI.EasterCodex.EasterNetwork)
		EasterNetwork.TryCollectEgg(data._UID)
	end))
	local pivot = egg:GetPivot()
	local position = pivot.Position
	local extentsSize = egg:GetExtentsSize()
	local v2 = position.Y - extentsSize.Y * 0.5

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getFPSFromDistance(p: number)
		return math.clamp((p - 150) / 250, 0, 1) * -35 + 40
	end

	local total = 0
	local v3 = time()
	data.Egg:SetAttribute("IgnoreRotationEffect", true)
	data.Maid:Add(RunService.Heartbeat:Connect(function(dt)
		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local v4 = 1 / math.max(getFPSFromDistance((currentCamera.CFrame.Position - position).Magnitude), 1)
		total += dt

		if total < v4 then
			return
		end

		total = 0
		local v5 = time() - v3
		local v6 = math.cos(v5 * 1.5) * 5
		local v7 = math.sin(v5 * 1.5) * 5
		local v8 = math.sin(v5 * 2.5) * 5
		local cframe = CFrame.new(v6, v8, v7)
		local cframe2 = CFrame.Angles(0, v5 * 2, 0)
		egg:PivotTo(pivot * cframe * cframe2)
	end))
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map") }
	local raycastResult = workspace:Raycast(position, createVector(0, -1000, 0), raycastParams)
	local Y = v2 - 25

	if raycastResult then
		Y = raycastResult.Position.Y
	end

	local v4 = math.max(0.25, v2 - Y)
	local v5 = Y + v4 * 0.5
	local parent3 = data.Maid:Add(Instance.new("Part"), "Destroy")
	parent3.Anchored = true
	parent3.CanCollide = false
	parent3.CanQuery = false
	parent3.CanTouch = false
	parent3.Transparency = 1
	parent3.Size = Vector3.new(10, v4, 10)
	parent3.Position = Vector3.new(position.X, v5, position.Z)
	parent3.Parent = workspace._WorldOrigin
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "ParticleEmitter"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 254, 69)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 254, 69))
	})
	particleEmitter.Acceleration = createVector(0, 20, 0)
	particleEmitter.Lifetime = NumberRange.new(1, 1.5)
	particleEmitter.LightEmission = 10
	particleEmitter.LightInfluence = 1
	particleEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
	particleEmitter.Rate = 500
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.155172, 0.375),
		NumberSequenceKeypoint.new(0.565517, 0),
		NumberSequenceKeypoint.new(0.597701, 0),
		NumberSequenceKeypoint.new(1, 0.2)
	})
	particleEmitter.Speed = NumberRange.new(1.5, 4)
	particleEmitter.SpreadAngle = Vector2.new(100, 100)
	particleEmitter.Texture = "rbxassetid://243664672"
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.239238, 0.296296),
		NumberSequenceKeypoint.new(0.875828, 0.425926),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Parent = parent3
	local clone = fireflyEgg.FireflyEggShardCollect:Clone()
	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 2)
	clone.Position = egg:GetPivot().Position
	clone.Parent = workspace._WorldOrigin

	for _, emitter in clone:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end