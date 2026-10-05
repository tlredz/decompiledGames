local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local UpwardOrbies = require(game.ReplicatedStorage.Util.UpwardOrbies)
local CraterModule = require(game.ReplicatedStorage.Util.CraterModule)
local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)
local Effect = require(game.ReplicatedStorage.Effect)
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
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
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
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

return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid
	local cFrame = player.CFrame

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	local rightUpperLeg = character.RightUpperLeg
	local child = humanoid:FindFirstChild(character.RightFoot.Name .. "_BusoLayer1")
	local color = rightUpperLeg.Color
	local material

	if child then
		color = child.Color
		material = child.Material
	else
		material = "SmoothPlastic"
	end

	local clone = script.Arm:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Size = rightUpperLeg.Size * 1.01
	clone.Color = color
	clone.Material = material
	local motor6D = Instance.new("Motor6D", clone)
	motor6D.Part0 = rightUpperLeg
	motor6D.Part1 = clone
	local size = clone.Size
	local vector2 = Vector3.new(clone.Size.X, 35, clone.Size.Z)
	local C0 = motor6D.Part0.CFrame:inverse() * rightUpperLeg.CFrame
	local v3 = motor6D.Part0.CFrame:inverse() * (rightUpperLeg.CFrame * CFrame.new(0, -18.18181818181818, 0))
	TweenService:Create(clone, v[1], {
		CFrame = v3,
		Size = vector2
	}):Play()
	TweenService:Create(motor6D, v[1], {
		C0 = v3
	}):Play()

	for _ = 1, 10 do
		UpwardOrbies({
			Quantity = 1,
			Pos = cFrame * CFrame.new(Random.new():NextNumber(-0.75, 0.75), 1, math.random(-2, 0)).Position,
			Properties = {
				Material = Enum.Material.Neon,
				Transparency = 0.5,
				Color = Color3.fromRGB(0, 0, 0),
				Size = Vector3.new(0.125, 0.125, math.random(4, 5))
			},
			Offsets = {
				X = { 0, 0 },
				Y = { -10, 10 },
				Z = { 0, 0 },
				Offset = { 15, 35 }
			},
			TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			Goal = {
				Transparency = 1
			}
		})
	end

	Sound:Play("RubberAxeStretch", humanoidRootPart, nil, 1.3)
	task.wait(0.3)
	TweenService:Create(clone, v[2], {
		CFrame = character.RightUpperArm.CFrame,
		Size = size
	}):Play()
	TweenService:Create(motor6D, v[2], {
		C0 = C0
	}):Play()
	Debris:AddItem(clone, 0.25)
	task.wait(0.1)

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

	local cFrame2 = cFrame * CFrame.new(0, 3, -2) * CFrame.Angles(0, 0, 1.57)
	local clone2 = script.MiddleShock:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame2
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)
	TweenService:Create(clone2, v[3], {
		CFrame = clone2.CFrame * CFrame.new(15, 0, 0)
	}):Play()
	TweenService:Create(clone2.Mesh, v[4], {
		Scale = clone2.Mesh.Scale * createVector(8.1, 0, 0) * 1.5
	}):Play()
	local cFrame3 = cFrame * CFrame.new(0, -1, -2) * CFrame.Angles(0, math.rad((math.random(-180, 180))), 1.57)
	local clone3 = script.Shockwave:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame3
	clone3.Parent = _WorldOrigin
	Debris:AddItem(clone3, 1)
	TweenService:Create(clone3, v[5], {
		CFrame = clone3.CFrame * CFrame.new(-2, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone3.Mesh, v[6], {
		Scale = createVector(0.3, 1.2, 1.2)
	}):Play()
	TweenService:Create(clone3.Decal, v[6], {
		Transparency = 1
	}):Play()
	local cFrame4 = cFrame * CFrame.new(0, 1.5, -2) * CFrame.Angles(
		0,
		math.rad((math.random(-180, 180))),
		1.5707963267948966
	)
	local clone4 = script.Shockwave2:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame4
	clone4.Parent = _WorldOrigin
	Debris:AddItem(clone4, 1)
	TweenService:Create(clone4, v[7], {
		CFrame = clone4.CFrame * CFrame.new(-3.7, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone4.Mesh, v[8], {
		Scale = createVector(0, 0.90000004, 0.90000004)
	}):Play()
	TweenService:Create(clone4.Decal, v[9], {
		Transparency = 1
	}):Play()
	local cFrame5 = cFrame * CFrame.new(0, -2.5, -2)
	local clone5 = script.Shock:Clone()
	clone5.Name = clone5.Name
	clone5.CFrame = cFrame5
	clone5.Parent = _WorldOrigin
	Debris:AddItem(clone5, 1)
	TweenService:Create(clone5, v[11], {
		CFrame = clone5.CFrame * CFrame.new(0, 14, 0),
		Size = Vector3.new(clone5.Size.X * 3 * 1.5, 0, clone5.Size.Z * 3 * 1.5),
		Transparency = 1
	}):Play()
	local raycastResult = workspace:Raycast(
		(cFrame * CFrame.new(0, 0, -2)).Position,
		createVector(0, -10, 0),
		raycastParams
	)
	local cFrame6 = cFrame * CFrame.new(0, 0, -2)
	local clone6 = script.eff:Clone()
	clone6.Name = clone6.Name
	clone6.CFrame = cFrame6
	clone6.Parent = _WorldOrigin
	Debris:AddItem(clone6, 1)

	for _, child2 in pairs(clone6.Attachment:GetChildren()) do
		local speed = child2.Speed
		child2.Speed = NumberRange.new(speed.Min * 1.5, speed.Max * 1.5)
		ScaleParticle({
			Emitter = child2,
			Scale = 1.5,
			Time = 0.05,
			EasingStyle = Enum.EasingStyle.Sine,
			EasingDirection = Enum.EasingDirection.Out
		})

		if child2.Name == "GroundStuff" then
			if raycastResult then
				child2.Color = ColorSequence.new(raycastResult.Instance.Color)
				child2:Emit(child2:GetAttribute("EmitCount"))
			end
		else
			child2:Emit(child2:GetAttribute("EmitCount"))
		end
	end

	Sound:Play("RubberAxeImpact", cFrame.p, nil, 0.75)

	if raycastResult then
		Sound:Play("DestructDebris", raycastResult.Position, nil, 1.3, 0.3)
		local cFrame7 = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal * 10) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, math.random(-10, 10) / 10 * 3.141592653589793, 0)
		local clone7 = script.Scar:Clone()
		clone7.Name = clone7.Name
		clone7.CFrame = cFrame7
		clone7.Parent = _WorldOrigin

		for _, child2 in pairs(clone7:GetChildren()) do
			TweenService:Create(child2, v[10], {
				Transparency = 1
			}):Play()
		end

		Debris:AddItem(clone7, 1.26)
	end

	CraterModule({
		Cframe = cFrame * CFrame.new(0, 0, -2),
		Size = 4,
		Ammount = 7,
		Despawn = 1,
		Distance = 9
	})
end