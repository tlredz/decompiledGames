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
	TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.2, Enum.EasingStyle.Sine),
	TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine),
	TweenInfo.new(0.3, Enum.EasingStyle.Sine)
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
	local position = player.Position
	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 1500 then
		return
	end

	local magnitude = (position - humanoidRootPart.Position).magnitude

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

	if player.Launch then
		humanoidRootPart.Anchored = true
		humanoidRootPart.CFrame = player.Direction
		local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 1.57, 1.57)
		local clone = script.Shockwave:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		clone.Size = createVector(7.766, 6, 7.766)
		TweenService:Create(clone, v[5], {
			CFrame = clone.CFrame * CFrame.new(0, 7, 0),
			Size = Vector3.new(clone.Size.X * 3, 0, clone.Size.Z * 3),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone, 0.5)
		local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 0, -25) * CFrame.Angles(1.57, 0, 0)
		local clone2 = script.shock2:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame3
		clone2.Parent = _WorldOrigin
		TweenService:Create(clone2, v[6], {
			Size = createVector(0, 55, 0),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone2, 0.25)
		local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0.35, -0.5, -2) * CFrame.Angles(0, -1.57, 0)
		local clone3 = script.release:Clone()
		clone3.Name = clone3.Name
		clone3.CFrame = cFrame4
		clone3.Parent = _WorldOrigin
		Debris:AddItem(clone3, 2)

		for _, child in pairs(clone3.Attachment:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		for i = 1, 2 do
			local cFrame5 = humanoidRootPart.CFrame * CFrame.new(0, 0, -25)
			local clone4 = script["HollowCylinder" .. i]:Clone()
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame5
			clone4.Parent = _WorldOrigin
			Debris:AddItem(clone4, 0.2)
			clone4.CFrame *= CFrame.Angles(1.57, 0, 0)

			if i == 1 then
			end

			TweenService:Create(clone4, v[5], {
				Size = Vector3.new(0, clone4.Size.Y * 2, 0),
				Transparency = 1
			}):Play()
		end

		for i = 1, 2 do
			local v5 = i
			resume(create(function()
				local rightUpperArm, rightHand

				if v5 == 1 then
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
				local clone4 = script.Arm:Clone()
				clone4.Name = clone4.Name
				clone4.CFrame = cFrame
				clone4.Parent = _WorldOrigin
				clone4.Size = rightUpperArm.Size * 1.01
				clone4.Color = color
				clone4.Material = material
				local motor6D = Instance.new("Motor6D", clone4)
				motor6D.Part0 = rightUpperArm
				motor6D.Part1 = clone4
				local size = clone4.Size
				local vector2 = Vector3.new(clone4.Size.X, magnitude, clone4.Size.Z)
				local C0 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
				local v8 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -magnitude / 2, 0))
				TweenService:Create(clone4, v[2], {
					CFrame = v8,
					Size = vector2
				}):Play()
				TweenService:Create(motor6D, v[2], {
					C0 = v8
				}):Play()
				task.wait(0.2)
				TweenService:Create(clone4, v[1], {
					CFrame = character.RightUpperArm.CFrame,
					Size = size
				}):Play()
				TweenService:Create(motor6D, v[1], {
					C0 = C0
				}):Play()
				Debris:AddItem(clone4, 0.5)
			end))
		end

		Sound:Play("RubberStretch", humanoidRootPart, nil, 1.5277777777777777)
		task.wait(0.2)
		local tween = TweenService:Create(humanoidRootPart, v[1], {
			CFrame = CFrame.new(position - player.Direction.LookVector * 5) * humanoidRootPart.CFrame - humanoidRootPart.Position
		})
		tween.Completed:Connect(function()
			if character == game.Players.LocalPlayer.Character then
				local velocity = player.Direction.LookVector * (75 + magnitude * 1.25) * 1.1
				local BodyMover = require(game.ReplicatedStorage.Util.BodyMover)
				BodyMover.new(character):Create("BodyVelocity", {
					Priority = 2,
					Duration = 0.125,
					Velocity = velocity
				})
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end

			humanoidRootPart.Anchored = false
			local Ray = require(game.ReplicatedStorage.Util.Ray)
			local v5, _, _ = Ray(
				humanoidRootPart.CFrame.p,
				humanoidRootPart.CFrame.LookVector * 10,
				{ workspace.Enemies, workspace.Characters }
			)

			if v5 then
				local Ray2 = require(game.ReplicatedStorage.Util.Ray)
				local _, v6, _ = Ray2(
					humanoidRootPart.CFrame.p,
					humanoidRootPart.CFrame.UpVector * 12.5,
					{ workspace.Enemies, workspace.Characters }
				)
				local v7 = v6.Y - humanoidRootPart.Position.Y - 2.5
				humanoidRootPart.CFrame *= CFrame.new(0, v7, 0)
			end
		end)
		tween:Play()
		task.wait(0.05)
		local cFrame = humanoidRootPart.CFrame
		local clone4 = script.Lines:Clone()
		clone4.Name = clone4.Name
		clone4.CFrame = cFrame
		clone4.Parent = _WorldOrigin
		Debris:AddItem(clone4, 1)
		local weld = Instance.new("Weld", clone4)
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone4
		task.wait(0.45)
		Sound:Play("RubberReturn", humanoidRootPart, nil, 1.868)
		Sound:Play("RubberRocketFling", humanoidRootPart, nil, 1.25)
		local cFrame6 = humanoidRootPart.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 1.57, 1.57)
		local clone5 = script.Shockwave:Clone()
		clone5.Name = clone5.Name
		clone5.CFrame = cFrame6
		clone5.Parent = _WorldOrigin
		clone5.Size = createVector(7.5, 7, 7.5)
		TweenService:Create(clone5, v[5], {
			CFrame = clone5.CFrame * CFrame.new(0, 7, 0),
			Size = Vector3.new(clone5.Size.X * 3, 0, clone5.Size.Z * 3),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone5, 0.5)

		for _, emitter in pairs(clone4:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	else
		Sound:Play("RubberStretch", humanoidRootPart, nil, 1.5277777777777777)

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
				local vector2 = Vector3.new(clone.Size.X, magnitude, clone.Size.Z)
				local C0 = motor6D.Part0.CFrame:inverse() * rightUpperArm.CFrame
				local v5 = motor6D.Part0.CFrame:inverse() * (rightUpperArm.CFrame * CFrame.new(0, -magnitude / 2, 0))
				TweenService:Create(clone, v[3], {
					CFrame = v5,
					Size = vector2
				}):Play()
				TweenService:Create(motor6D, v[3], {
					C0 = v5
				}):Play()
				task.wait(0.2)
				TweenService:Create(clone, v[4], {
					CFrame = character.RightUpperArm.CFrame,
					Size = size
				}):Play()
				TweenService:Create(motor6D, v[4], {
					C0 = C0
				}):Play()
				Debris:AddItem(clone, 0.2)
			end))
		end

		local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, -7) * CFrame.Angles(0, 1.57, 1.57)
		local clone = script.Shockwave:Clone()
		clone.Name = clone.Name
		clone.CFrame = cFrame2
		clone.Parent = _WorldOrigin
		TweenService:Create(clone, v[5], {
			CFrame = clone.CFrame * CFrame.new(0, 10, 0),
			Size = Vector3.new(clone.Size.X * 2, 0, clone.Size.Z * 2),
			Transparency = 1
		}):Play()
		Debris:AddItem(clone, 0.5)

		for i = 1, 3 do
			local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -magnitude / i - 5) * CFrame.Angles(0, 1.57, 1.57)
			local clone2 = script.Shockwave:Clone()
			clone2.Name = clone2.Name
			clone2.CFrame = cFrame
			clone2.Parent = _WorldOrigin
			clone2.Size *= 0.6
			Debris:AddItem(clone2, 0.5)

			if i == 1 then
				TweenService:Create(clone2, v[3], {
					CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
					Size = Vector3.new(clone2.Size.X * 1.5, 0, clone2.Size.Z * 1.5),
					Transparency = 1
				}):Play()
			else
				if i == 2 then
				end

				TweenService:Create(clone2, v[3], {
					CFrame = clone2.CFrame * CFrame.new(0, 10, 0),
					Size = Vector3.new(clone2.Size.X * i, 0, clone2.Size.Z * i),
					Transparency = 1
				}):Play()
			end
		end

		local cFrame3 = humanoidRootPart.CFrame * CFrame.new(0, 0, -7) * CFrame.Angles(0, 4.71, 0)
		local clone2 = script.TexturedShockwave1:Clone()
		clone2.Name = clone2.Name
		clone2.CFrame = cFrame3
		clone2.Parent = _WorldOrigin
		TweenService:Create(clone2, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.new(-30, 0, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(
			clone2.Mesh,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0),
			{
				Scale = createVector(2.4, 0.2, 0.2)
			}
		):Play()
		TweenService:Create(clone2.Texture, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		Debris:AddItem(clone2, 0.2)
		local cFrame4 = humanoidRootPart.CFrame * CFrame.new(0, 0, -7) * CFrame.Angles(0, 4.71, 0)
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

		for i = 1, 2 do
			local cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -25)
			local clone4 = script["HollowCylinder" .. i]:Clone()
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame
			clone4.Parent = _WorldOrigin
			Debris:AddItem(clone4, 0.2)
			clone4.CFrame *= CFrame.Angles(1.57, 0, 0)

			if i == 1 then
			end

			TweenService:Create(clone4, v[3], {
				Size = Vector3.new(0, clone4.Size.Y * 2, 0),
				Transparency = 1
			}):Play()
		end

		task.wait(0.5)
		Sound:Play("RubberReturn", humanoidRootPart, nil, 1.868)

		for i = 1, 2 do
			local v5 = i == 1 and "Right" or "Left"
			local cFrame = character[v5 .. "UpperArm"].CFrame
			local clone4 = script.returnn:Clone()
			clone4.Name = clone4.Name
			clone4.CFrame = cFrame
			clone4.Parent = _WorldOrigin
			Debris:AddItem(clone4, 0.5)
			local motor6D = Instance.new("Motor6D", clone4)
			motor6D.Part0 = character[v5 .. "Hand"]
			motor6D.Part1 = clone4

			for _, child in pairs(clone4.Attachment:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end
	end
end