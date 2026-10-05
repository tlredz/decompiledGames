local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
require(game.ReplicatedStorage.Util.UpwardOrbies)
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = workspace.CurrentCamera
local map = workspace.Map
local debris = Util.Debris
local sound = Util.Sound

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.3, Enum.EasingStyle.Linear),
	TweenInfo.new(0.4, Enum.EasingStyle.Quint),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.35, Enum.EasingStyle.Quad),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine),
	TweenInfo.new(0.4, Enum.EasingStyle.Quart),
	TweenInfo.new(0.6, Enum.EasingStyle.Quad),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.4, Enum.EasingStyle.Sine)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local v2 = { "RightLowerArm", "RightHand", "RightUpperArm" }
return function(player)
	local character = player.Character
	local previousPosition = player.PreviousPosition
	local position = player.Position
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	character:FindFirstChildOfClass("Humanoid")

	if (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).magnitude > 500 then
		return
	end

	if previousPosition then
		sound:Play("RubberSmashTeleport", previousPosition, nil, 1.25)
	end

	if previousPosition then
		for _, childName in pairs(v2) do
			local child = character:FindFirstChild(childName)

			if child then
				child.Transparency = 0
			end
		end
	end

	if previousPosition then
		local cframe = CFrame.new(previousPosition)
		local clone = script.Lines:Clone()
		clone.Name = clone.Name
		clone.CFrame = cframe
		clone.Parent = _WorldOrigin
		clone.Attachment.ParticleEmitter:Emit(1)
		debris:AddItem(clone, 1)
		local cFrame = primaryPart.CFrame
		local clone2 = script.Appear:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 1)

		for _, child in pairs(clone2:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		task.wait(0.2)
	end

	if character and character == game.Players.LocalPlayer.Character then
		Effect.new("ShakeCam"):replicate({
			3.5,
			8,
			0,
			1.5,
			createVector(0.25, 0.25, 0.25),
			createVector(1, 1, 1)
		})
	end

	local cFrame2 = CFrame.new(position) * CFrame.new(0, 3, -2) * CFrame.Angles(0, 0, 1.57)
	local clone = script.MiddleShock:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	debris:AddItem(clone, 1)
	TweenService:Create(clone, v[3], {
		CFrame = clone.CFrame * CFrame.new(15, 0, 0)
	}):Play()
	TweenService:Create(clone.Mesh, v[4], {
		Scale = clone.Mesh.Scale * createVector(8.1, 0, 0) * 1.5
	}):Play()
	local cFrame3 = CFrame.new(position) * CFrame.new(0, -1, -2) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		1.57
	)
	local clone2 = script.Shockwave:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	debris:AddItem(clone2, 1)
	TweenService:Create(clone2, v[5], {
		CFrame = clone2.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone2.Mesh, v[6], {
		Scale = createVector(0.3, 1.2, 1.2)
	}):Play()
	TweenService:Create(clone2.Decal, v[6], {
		Transparency = 1
	}):Play()
	local cFrame4 = CFrame.new(position) * CFrame.new(0, 1.5, -2) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		1.5707963267948966
	)
	local clone3 = script.Shockwave2:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame4
	clone3.Parent = _WorldOrigin
	debris:AddItem(clone3, 1)
	TweenService:Create(clone3, v[7], {
		CFrame = clone3.CFrame * CFrame.new(-3.7, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone3.Mesh, v[8], {
		Scale = createVector(0, 0.90000004, 0.90000004)
	}):Play()
	TweenService:Create(clone3.Decal, v[9], {
		Transparency = 1
	}):Play()
	local cFrame5 = CFrame.new(position) * CFrame.new(0, -2.5, -2)
	local clone4 = script.Shock:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame5
	clone4.Parent = _WorldOrigin
	debris:AddItem(clone4, 1)
	TweenService:Create(clone4, v[11], {
		CFrame = clone4.CFrame * CFrame.new(0, 14, 0),
		Size = Vector3.new(clone4.Size.X * 3 * 1.5, 0, clone4.Size.Z * 3 * 1.5),
		Transparency = 1
	}):Play()
	local raycastResult = workspace:Raycast(position + createVector(0, 5, 0), createVector(0, -18, 0), raycastParams)
	local cFrame6 = CFrame.new(position) * CFrame.new(0, 0, -2)
	local clone5 = script.eff:Clone()
	clone5.Name = clone5.Name
	clone5.CFrame = cFrame6
	clone5.Parent = _WorldOrigin
	debris:AddItem(clone5, 1)

	for _, child in pairs(clone5.Attachment:GetChildren()) do
		local speed = child.Speed
		child.Speed = NumberRange.new(speed.Min * 1.5, speed.Max * 1.5)
		ScaleParticle({
			Emitter = child,
			Scale = 1.5,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Sine,
			EasingDirection = Enum.EasingDirection.Out
		})

		if child.Name == "GroundStuff" then
			if raycastResult then
				child.Color = ColorSequence.new(raycastResult.Instance.Color)
				child:Emit(child:GetAttribute("EmitCount"))
			end
		else
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end

	if previousPosition then
		sound:Play("RubberSmashImpact", position, nil, 1.5)
	else
		sound:Play("RubberAxeImpact", position)
	end

	if raycastResult then
		if previousPosition then
			sound:Play("DestructDebris", raycastResult.Position, nil, 1.15, 0.3)
		end

		local cFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone6 = script.Scar:Clone()
		clone6.Name = clone6.Name
		clone6.CFrame = cFrame
		clone6.Parent = _WorldOrigin
		clone6.Size *= 1.35

		for _, child in pairs(clone6:GetChildren()) do
			TweenService:Create(child, v[10], {
				Transparency = 1
			}):Play()
		end

		debris:AddItem(clone6, 1.26)
	end

	CraterModule({
		Cframe = CFrame.new(position),
		Size = 5,
		Ammount = 7,
		Despawn = 1,
		Distance = 11
	})

	if previousPosition then
		task.wait(0.1)

		for _, childName in pairs(v2) do
			local child = character:FindFirstChild(childName)

			if child then
				child.Transparency = 0
			end
		end
	end
end