local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Effect = require(game.ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)

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
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.17, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local cFrame2 = humanoidRootPart.CFrame * CFrame.Angles(-0.1, 0.075, 0)

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	if character == game.Players.LocalPlayer.Character then
		Effect.new("ShakeCam"):replicate({
			2.5,
			4,
			0.1,
			0.75,
			createVector(0.15, 0.15, 0.15),
			createVector(1, 1, 1)
		})
	end

	Sound:Play("RubberStretch", humanoidRootPart, nil, 0.9)
	local rightUpperArm = character.RightUpperArm
	local child = humanoid:FindFirstChild(character.RightHand.Name .. "_BusoLayer1")
	local color = rightUpperArm.Color
	local material

	if child then
		color = child.Color
		material = child.Material
	else
		material = "SmoothPlastic"
	end

	local clone = script.Arm:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	clone.Size = rightUpperArm.Size * 1.01
	clone.Color = color
	clone.Material = material
	local motor6D = Instance.new("Motor6D", clone)
	motor6D.Part0 = rightUpperArm
	motor6D.Part1 = clone
	local size = clone.Size
	local vector2 = Vector3.new(clone.Size.X, 90, clone.Size.Z)
	local C0 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
	local v4 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -46.75324675324675, 0))
	TweenService:Create(clone, v[1], {
		CFrame = v4,
		Size = vector2
	}):Play()
	TweenService:Create(motor6D, v[1], {
		C0 = v4
	}):Play()
	local cFrame3 = cFrame2 * CFrame.new(0, 0, -7) * CFrame.Angles(0, 1.57, 1.57)
	local clone2 = script.Shockwave:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone2, v[3], {
		CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
		Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone2, 0.5)

	for i = 1, 2 do
		local cFrame4 = cFrame2 * CFrame.new(0, 0, 50 / i + -90) * CFrame.Angles(0, 1.57, 1.57)
		local clone3 = script.Shockwave:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame4
		clone3.Parent = _WorldOrigin

		if i == 1 then
			TweenService:Create(clone3, v[3], {
				CFrame = clone3.CFrame * CFrame.new(0, 10, 0),
				Size = Vector3.new(clone3.Size.X * 2, 0, clone3.Size.Z * 2),
				Transparency = 1
			}):Play()
		else
			TweenService:Create(clone3, v[3], {
				CFrame = clone3.CFrame * CFrame.new(0, 10, 0),
				Size = Vector3.new(clone3.Size.X * 3, 0, clone3.Size.Z * 3),
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone3, 0.5)
	end

	local cFrame5 = cFrame2 * CFrame.new(0.35, -0.5, -2) * CFrame.Angles(0, -1.57, 0)
	local clone3 = script.release:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame5
	clone3.Parent = _WorldOrigin
	Debris:AddItem(clone3, 2)

	for _, child2 in pairs(clone3.Attachment:GetChildren()) do
		child2:Emit(child2:GetAttribute("EmitCount"))
	end

	local cFrame6 = clone.CFrame * CFrame.new(0, -70, 0)
	local clone4 = script.HollowCylinder:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame6
	clone4.Parent = _WorldOrigin
	TweenService:Create(clone4, v[4], {
		CFrame = clone4.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(0, 4.71238898038469, 0),
		Size = createVector(8, 75, 8),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone4, 0.2)
	local cFrame7 = clone.CFrame * CFrame.new(0, -70, 0)
	local clone5 = script.shock2:Clone()
	clone5.Name = clone5.Name
	clone5.CFrame = cFrame7
	clone5.Parent = _WorldOrigin
	TweenService:Create(clone5, v[4], {
		CFrame = clone5.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(0, 0, 0),
		Size = createVector(0, 55, 0),
		Transparency = 1
	}):Play()
	Debris:AddItem(clone5, 0.25)
	local cFrame8 = cFrame2 * CFrame.new(0.35, -2, -90) * CFrame.Angles(0, -1.57, 0)
	local clone6 = script.poke:Clone()
	clone6.Name = clone6.Name
	clone6.CFrame = cFrame8
	clone6.Parent = _WorldOrigin
	Debris:AddItem(clone6, 2)

	for _, child2 in pairs(clone6.Attachment:GetChildren()) do
		local lifetime = child2.Lifetime
		child2.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		child2.Rate *= 1.5
		local speed = child2.Speed
		child2.Speed = NumberRange.new(speed.Min * 4, speed.Max * 4)
	end

	task.wait(0.1)

	for _, child2 in pairs(clone6.Attachment:GetChildren()) do
		child2.Enabled = false
	end

	task.wait(0.2)
	TweenService:Create(clone, v[2], {
		CFrame = rightUpperArm.CFrame,
		Size = size
	}):Play()
	TweenService:Create(motor6D, v[2], {
		C0 = C0
	}):Play()
	task.wait(0.2)
	clone:Destroy()
	Sound:Play("RubberReturn", humanoidRootPart, nil, 1)
	local cFrame = rightUpperArm.CFrame
	local clone7 = script.returnn:Clone()
	clone7.Name = clone7.Name
	clone7.CFrame = cFrame
	clone7.Parent = _WorldOrigin
	Debris:AddItem(clone7, 0.5)
	local motor6D2 = Instance.new("Motor6D", clone7)
	motor6D2.Part0 = character.RightHand
	motor6D2.Part1 = clone7

	if character == game.Players.LocalPlayer.Character then
		Effect.new("ShakeCam"):replicate({
			2.5,
			4,
			0.1,
			0.75,
			createVector(0.3, 0.3, 0.3),
			createVector(2, 2, 2)
		})
	end

	for _, child2 in pairs(clone7.Attachment:GetChildren()) do
		child2:Emit(child2:GetAttribute("EmitCount"))
	end
end