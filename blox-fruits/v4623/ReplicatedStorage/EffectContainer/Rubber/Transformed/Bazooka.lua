local createVector = vector.create
local TweenService = game:GetService("TweenService")
local resume = coroutine.resume
local create = coroutine.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = workspace.CurrentCamera
local _ = workspace.Map
local debris = Util.Debris
local sound = Util.Sound
local particleScaler = Util.ParticleScaler
local numberRange = particleScaler.NumberRange
local _ = particleScaler.Acceleration
local v = {
	TweenInfo.new(0.0833333335, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.0833333335, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
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

local v2 = {
	"RightLowerArm",
	"LeftLowerArm",
	"RightHand",
	"LeftHand",
	"RightUpperArm",
	"LeftUpperArm"
}
return function(player)
	local character = player.Character
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).magnitude > 500 then
		return
	end

	task.wait(0.17777)

	for _, childName in pairs(v2) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 1
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 1
		end

		if child3 then
			child3.Transparency = 1
		end
	end

	sound:Play("RubberBazookaStretch", primaryPart, nil, 2)

	for i = 1, 2 do
		local v3 = i
		resume(create(function()
			local rightUpperArm

			if v3 == 1 then
				rightUpperArm = character.RightUpperArm
			else
				rightUpperArm = character.LeftUpperArm
			end

			local cFrame = primaryPart.CFrame
			local clone = script.Orbie:Clone()
			clone.Name = clone.Name
			clone.CFrame = cFrame
			clone.Parent = _WorldOrigin
			clone.Size = rightUpperArm.Size
			local motor6D = Instance.new("Motor6D", clone)
			motor6D.Part0 = rightUpperArm
			motor6D.Part1 = clone
			local size = clone.Size
			local vector2 = Vector3.new(clone.Size.X, 52.5, clone.Size.Z)
			local v4 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
			local v5 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -27.272727272727273, 0))
			TweenService:Create(clone, v[3], {
				CFrame = v5,
				Size = vector2
			}):Play()
			TweenService:Create(motor6D, v[3], {
				C0 = v5
			}):Play()
			task.wait(0.05)
			motor6D:Destroy()
			clone.Anchored = true
			TweenService:Create(clone, v[4], {
				Size = Vector3.new(0, clone.Size.Y, 0),
				Transparency = 1
			}):Play()
			debris:AddItem(clone, 0.4)
		end))
	end

	sound:Play("RubberJetBazookaFire", primaryPart, nil, 1.1)

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

	local cFrame2 = primaryPart.CFrame * CFrame.new(0.35, -0.5, -2) * CFrame.Angles(0, -1.57, 0)
	local clone = script.release:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame2
	clone.Parent = _WorldOrigin
	debris:AddItem(clone, 2)

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	for i = 1, 2 do
		local cFrame = primaryPart.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, 1.57, 1.57)
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		clone2.Size *= 0.75
		clone2.Color = Color3.new(1, 0.47451, 0.47451)
		debris:AddItem(clone2, 0.5)
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
		local cFrame = primaryPart.CFrame * CFrame.new(0, 0, -35 / i) * CFrame.Angles(0, 1.57, 1.57)
		local clone2 = script.Shockwave:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame
		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 0.5)

		if i == 1 then
			clone2.Size *= 0.5
		end

		TweenService:Create(clone2, v[6], {
			CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
			Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
			Transparency = 1
		}):Play()
	end

	local cFrame3 = primaryPart.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, 4.71, 0)
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
	debris:AddItem(clone2, 0.2)
	local cFrame4 = primaryPart.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, 4.71, 0)
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
	debris:AddItem(clone3, 0.2)
	local cFrame5 = primaryPart.CFrame * CFrame.new(0, -2, -45) * CFrame.Angles(0, -1.57, 0)
	local clone4 = script.poke:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame5
	clone4.Parent = _WorldOrigin
	debris:AddItem(clone4, 2)

	for _, child in pairs(clone4.Attachment:GetChildren()) do
		child.Lifetime = numberRange(child.Lifetime, 0.5)
		child.Rate *= 0.75
		child.Speed = numberRange(child.Speed, 4)
	end

	task.wait(0.05)

	for _, child in pairs(clone4.Attachment:GetChildren()) do
		child.Enabled = false
	end

	task.wait(0.08335)
	sound:Play("RubberReturn", primaryPart, nil, 1.7)

	for _, childName in pairs(v2) do
		local child = character:FindFirstChild(childName)

		if child then
			child.Transparency = 0
		end

		local child2 = humanoid:FindFirstChild(childName .. "_BusoLayer1")
		local child3 = humanoid:FindFirstChild(childName .. "_BusoLayer2")

		if child2 then
			child2.Transparency = 0
		end

		if child3 then
			child3.Transparency = 0
		end
	end

	for i = 1, 2 do
		local v7 = i == 1 and "Right" or "Left"
		local cFrame = character[v7 .. "UpperArm"].CFrame
		local clone5 = script.returnn:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cFrame
		clone5.Parent = _WorldOrigin
		debris:AddItem(clone5, 0.5)
		local motor6D = Instance.new("Motor6D", clone5)
		motor6D.Part0 = character[v7 .. "Hand"]
		motor6D.Part1 = clone5

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

		for _, child in pairs(clone5.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end
	end
end