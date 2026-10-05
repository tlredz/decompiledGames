local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
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
	TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
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
	local _ = humanoidRootPart.CFrame

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
		return
	end

	Sound:Play("RubberBazookaStretch", humanoidRootPart, nil, 1.3)

	for i = 1, 2 do
		local v2 = i
		resume(create(function()
			local rightUpperArm, rightHand

			if v2 == 1 then
				rightUpperArm = character.RightUpperArm
				rightHand = character.RightHand
			else
				rightUpperArm = character.LeftUpperArm
				rightHand = character.LeftHand
			end

			local child = humanoid:FindFirstChild(rightHand.Name .. "_BusoLayer1")
			local color = rightUpperArm.Color
			local material

			if child then
				color = child.Color
				material = child.Material
			else
				material = "SmoothPlastic"
			end

			local cFrame = humanoidRootPart.CFrame
			local clone = script.Arm:Clone()
			clone.Name = clone.Name
			clone.CFrame = cFrame
			clone.Parent = _WorldOrigin
			clone.Size = rightUpperArm.Size * 1.01
			clone.Color = color
			clone.Material = material
			local motor6D = Instance.new("Motor6D", clone)
			motor6D.Part0 = rightUpperArm
			motor6D.Part1 = clone
			local size = clone.Size
			local vector2 = Vector3.new(clone.Size.X, 35, clone.Size.Z)
			local C0 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
			local v5 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -18.18181818181818, 0))
			TweenService:Create(clone, v[1], {
				CFrame = v5,
				Size = vector2
			}):Play()
			TweenService:Create(motor6D, v[1], {
				C0 = v5
			}):Play()
			task.wait(0.13333333333333333)
			TweenService:Create(clone, v[2], {
				CFrame = character.RightUpperArm.CFrame,
				Size = size
			}):Play()
			TweenService:Create(motor6D, v[2], {
				C0 = C0
			}):Play()
			task.wait(0.2333333333333333)
			local size2 = clone.Size
			local vector3 = Vector3.new(clone.Size.X, 35, clone.Size.Z)
			local C02 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
			local v7 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -18.18181818181818, 0))
			TweenService:Create(clone, v[3], {
				CFrame = v7,
				Size = vector3
			}):Play()
			TweenService:Create(motor6D, v[3], {
				C0 = v7
			}):Play()
			task.wait(0.06666666666666667)
			TweenService:Create(clone, v[4], {
				CFrame = character.RightUpperArm.CFrame,
				Size = size2
			}):Play()
			TweenService:Create(motor6D, v[4], {
				C0 = C02
			}):Play()
			Debris:AddItem(clone, 0.15)
		end))
	end

	task.wait(0.3666666666666667)
	Sound:Play("RubberBazookaFire", humanoidRootPart, nil, 1.3)

	if character == game.Players.LocalPlayer.Character then
		Effect.new("ShakeCam"):replicate({
			3.5,
			8,
			0,
			1.5,
			createVector(0.25, 0.25, 0.25),
			createVector(1, 1, 1)
		})
	end

	local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0.35, -0.5, -2) * CFrame.Angles(0, -1.57, 0)
	local clone = script.release:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	Debris:AddItem(clone, 2)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	for i = 1, 2 do
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, 1.57, 1.57)
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		clone2.Size *= 0.75
		clone2.Color = Color3.new(1, 0.47451, 0.47451)
		Debris:AddItem(clone2, 0.5)
		clone2.Size = Vector3.new(clone2.Size.X, clone2.Size.Y * 2, clone2.Size.Z)

		if i == 1 then
			TweenService:Create(clone2, v[5], {
				CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
				Size = Vector3.new(clone2.Size.X * 3, 0, clone2.Size.Z * 3),
				Transparency = 1
			}):Play()
		else
			clone2.Size *= 0.75
			clone2.CFrame *= CFrame.new(0, -15, 0)
			TweenService:Create(clone2, v[5], {
				CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
				Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
				Transparency = 1
			}):Play()
		end
	end

	for i = 1, 2 do
		local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -35 / i) * CFrame.Angles(0, 1.57, 1.57)
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		Debris:AddItem(clone2, 0.5)

		if i == 1 then
			clone2.Size *= 0.5
		end

		TweenService:Create(clone2, v[6], {
			CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
			Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
			Transparency = 1
		}):Play()
	end

	local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, 4.71, 0)
	local clone2 = script.TexturedShockwave1:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone2, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * CFrame.new(-30, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
	}):Play()
	TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), {
		Scale = createVector(2.4, 0.2, 0.2)
	}):Play()
	TweenService:Create(clone2.Texture, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	Debris:AddItem(clone2, 0.2)
	local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, 4.71, 0)
	local clone3 = script.TexturedShockwave2:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame4
	clone3.Parent = _WorldOrigin
	TweenService:Create(clone3, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.new(-43, 0, 0)
	}):Play()
	TweenService:Create(clone3.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Scale = createVector(1.5, 0.25, 0.25)
	}):Play()
	TweenService:Create(clone3.Texture, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	Debris:AddItem(clone3, 0.2)
	local cFrame5 = humanoidRootPart.CFrame * CFrame.new(0, -2, -45) * CFrame.Angles(0, -1.57, 0)
	local clone4 = script.poke:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame5
	clone4.Parent = _WorldOrigin
	Debris:AddItem(clone4, 2)

	for _, child in pairs(clone4.Attachment:GetChildren()) do
		local lifetime = child.Lifetime
		child.Lifetime = NumberRange.new(lifetime.Min * 0.5, lifetime.Max * 0.5)
		child.Rate *= 0.75
		local speed = child.Speed
		child.Speed = NumberRange.new(speed.Min * 4, speed.Max * 4)
	end

	task.wait(0.1)

	for _, child in pairs(clone4.Attachment:GetChildren()) do
		child.Enabled = false
	end

	task.wait(0.1667)
	Sound:Play("RubberReturn", humanoidRootPart, nil, 1.3)

	for i = 1, 2 do
		local v6 = i == 1 and "Right" or "Left"
		local cFrame = character[v6 .. "UpperArm"].CFrame
		local clone5 = script.returnn:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cFrame
		clone5.Parent = _WorldOrigin
		Debris:AddItem(clone5, 0.5)
		local motor6D = Instance.new("Motor6D", clone5)
		motor6D.Part0 = character[v6 .. "Hand"]
		motor6D.Part1 = clone5

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

		for _, child in pairs(clone5.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end