local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.CameraShaker
local sound = Util.Sound
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = workspace.CurrentCamera
local _ = workspace.Map
local debris = Util.Debris
local particleScaler = Util.ParticleScaler
local numberRange = particleScaler.NumberRange
local _ = particleScaler.Acceleration
local v = {
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
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
	local primaryPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local v3 = primaryPart.CFrame * CFrame.Angles(-0.1, 0.075, 0)

	if (workspace.CurrentCamera.CFrame.Position - primaryPart.Position).magnitude > 500 then
		return
	end

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

	sound:Play("RubberJetPistolFire", primaryPart, nil, 1.15)
	local cFrame = primaryPart.CFrame
	local clone = script.Orbie:Clone()
	clone.Name = clone.Name
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Size = character.RightUpperArm.Size * 1.01
	local motor6D = Instance.new("Motor6D", clone)
	motor6D.Part0 = character.RightUpperArm
	motor6D.Part1 = clone
	local _ = clone.Size
	local vector2 = Vector3.new(clone.Size.X, 140, clone.Size.Z)
	local _ = motor6D.Part0.CFrame:inverse() * character.RightUpperArm.CFrame
	local v4 = motor6D.Part0.CFrame:inverse() * (character.RightUpperArm.CFrame * CFrame.new(0, -72.72727272727272, 0))
	TweenService:Create(clone, v[1], {
		CFrame = v4,
		Size = vector2
	}):Play()
	TweenService:Create(motor6D, v[1], {
		C0 = v4
	}):Play()
	local cFrame3 = v3 * CFrame.new(0, 0, -7) * CFrame.Angles(0, 1.57, 1.57)
	local clone2 = script.Shockwave:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame3
	clone2.Parent = _WorldOrigin
	TweenService:Create(clone2, v[3], {
		CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
		Size = Vector3.new(clone2.Size.X * 4, 0, clone2.Size.Z * 4),
		Transparency = 1
	}):Play()
	debris:AddItem(clone2, 0.5)

	for i = 1, 2 do
		local cFrame4 = v3 * CFrame.new(0, 0, 50 / i + -140) * CFrame.Angles(0, 1.57, 1.57)
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

		debris:AddItem(clone3, 0.5)
	end

	local cFrame5 = v3 * CFrame.new(0.35, -0.5, -2) * CFrame.Angles(0, -1.57, 0)
	local clone3 = script.release:Clone()
	clone3.Name = clone3.Name
	clone3.CFrame = cFrame5
	clone3.Parent = _WorldOrigin
	debris:AddItem(clone3, 1)

	for _, child in pairs(clone3.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local cFrame6 = v3 * CFrame.new(0, -115, 0)
	local clone4 = script.HollowCylinder:Clone()
	clone4.Name = clone4.Name
	clone4.CFrame = cFrame6
	clone4.Parent = _WorldOrigin
	TweenService:Create(clone4, v[4], {
		CFrame = clone4.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(0, 4.71238898038469, 0),
		Size = createVector(8, 75, 8),
		Transparency = 1
	}):Play()
	debris:AddItem(clone4, 0.2)
	local cFrame7 = v3 * CFrame.new(0, -115, 0)
	local clone5 = script.shock2:Clone()
	clone5.Name = clone5.Name
	clone5.CFrame = cFrame7
	clone5.Parent = _WorldOrigin
	TweenService:Create(clone5, v[4], {
		CFrame = clone5.CFrame * CFrame.new(0, -15, 0) * CFrame.Angles(0, 0, 0),
		Size = createVector(0, 55, 0),
		Transparency = 1
	}):Play()
	debris:AddItem(clone5, 0.25)
	local cFrame8 = v3 * CFrame.new(0.35, -2, -130) * CFrame.Angles(0, -1.57, 0)
	local clone6 = script.poke:Clone()
	clone6.Name = clone6.Name
	clone6.CFrame = cFrame8
	clone6.Parent = _WorldOrigin
	debris:AddItem(clone6, 2)

	for _, child in pairs(clone6.Attachment:GetChildren()) do
		child.Lifetime = numberRange(child.Lifetime, 0.5)
		child.Rate *= 1.5
		child.Speed = numberRange(child.Speed, 4)
	end

	task.wait(0.05)

	for _, child in pairs(clone6.Attachment:GetChildren()) do
		child.Enabled = false
	end

	motor6D:Destroy()
	clone.Anchored = true
	TweenService:Create(clone, v[2], {
		Size = Vector3.new(0, clone.Size.Y, 0),
		Transparency = 1
	}):Play()
	task.wait(0.1)
	clone:Destroy()
	sound:Play("RubberReturn", primaryPart, nil, 1.6)

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

	local cFrame2 = character.RightUpperArm.CFrame
	local clone7 = script.returnn:Clone()
	clone7.Name = clone7.Name
	clone7.CFrame = cFrame2
	clone7.Parent = _WorldOrigin
	debris:AddItem(clone7, 0.5)
	local motor6D2 = Instance.new("Motor6D", clone7)
	motor6D2.Part0 = character.RightHand
	motor6D2.Part1 = clone7

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

	for _, child in pairs(clone7.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end
end