local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sound = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function CreatePart()
	local part = Instance.new("Part")
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Anchored = true
	part.CanCollide = false
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Brick
	specialMesh.Scale = createVector(5, 5, 5)
	specialMesh.Parent = part
	return part, specialMesh
end

function RandomCFRot()
	return CFrame.Angles(math.rad((math.random(360))), math.rad((math.random(360))), (math.rad((math.random(360)))))
end

function RandomV3(value)
	return Vector3.new(math.random(-10, 10) / 10, math.random(-10, 10) / 10, math.random(-10, 10) / 10) * (value or 1)
end

return function(data)
	local cFrame = data.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1500 then
		return
	end

	local hitbox = data.Hitbox
	local maxTime = data.MaxTime or 10

	if not hitbox then
		return
	end

	local value = hitbox:WaitForChild("Value", 0.5)

	if not value then
		return print("return")
	end

	local connections = {}
	local clone = FX:WaitForChild("SerpentBow").SnakeHead:Clone()
	local clone2 = FX:WaitForChild("SerpentBow").SnakeHead:Clone()
	local clone3 = FX:WaitForChild("SerpentBow").SnakeHead:Clone()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endmove()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end

	local lastTime = tick()
	local v = hitbox.CFrame * CFrame.Angles(0, 0, 0.08726646259971647)
	local cFrame2 = hitbox.CFrame * CFrame.Angles(0, 0, 0.08726646259971647) * CFrame.new(3, 0, 0)
	local cFrame3 = hitbox.CFrame * CFrame.Angles(0, 0, 3.141592653589793) * CFrame.new(3, 0, 0)
	local clone4 = FX:WaitForChild("SerpentBow").ShockRing:Clone()
	clone4.CFrame = hitbox.CFrame * CFrame.new(0, 0, 2) * CFrame.Angles(-1.5707963267948966, 0, 0)
	local tween = TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		Transparency = 1,
		Color = Color3.fromRGB(122, 122, 124),
		Size = createVector(30.532, 1.952, 30.532)
	})
	table.insert(connections, tween.Completed:Connect(function()
		clone4:Destroy()
	end))
	clone4.Parent = _WorldOrigin
	sound:Play("BowLaunch2", cFrame, nil, 1.5, 2)
	local total = 2

	for _ = 1, 20 do
		local v2, v3 = CreatePart()
		v2.CFrame = hitbox.CFrame * RandomCFRot()
		v2.Transparency = 0.25
		v2.Material = Enum.Material.Neon
		v2.Color = Color3.fromRGB(104, 0, 189)
		v3.Scale = createVector(10, 10, 10)
		local tween2 = TweenService:Create(v3, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = createVector(0, 0, 0)
		})
		local tween3 = TweenService:Create(v2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v2.Position + RandomV3(15) + hitbox.CFrame.LookVector * 10) * RandomCFRot()
		})
		table.insert(connections, tween2.Completed:Connect(function()
			v2:Destroy()
		end))
		v2.Parent = _WorldOrigin
		tween2:Play()
		tween3:Play()
	end

	for _ = 1, 11 do
		local v2, v3 = CreatePart()
		v3.MeshType = Enum.MeshType.Sphere
		v3.Scale = createVector(1, 2, 1)
		v2.CFrame = CFrame.new(
			(hitbox.CFrame * CFrame.new(math.random(-5, 5) / 10, math.random(-5, 5) / 10, 0)).Position,
			hitbox.Position
		) * CFrame.Angles(
			math.rad((math.random(-60, 60))),
			math.rad((math.random(-60, 60))),
			(math.rad((math.random(-60, 60))))
		)
		v2.Transparency = 0.25
		v2.Material = Enum.Material.Neon
		v2.Color = Color3.fromRGB(173, 58, 255)
		local tween2 = TweenService:Create(v3, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = createVector(0, 0, 0)
		})
		local tween3 = TweenService:Create(v2, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = v2.CFrame * CFrame.new(0, 0, 10)
		})
		table.insert(connections, tween2.Completed:Connect(function()
			v2:Destroy()
		end))
		v2.Parent = _WorldOrigin
		tween2:Play()
		tween3:Play()
	end

	tween:Play()
	clone.Size = createVector(3.559, 4.07, 7.822)
	clone.Color = Color3.fromRGB(189, 83, 255)
	clone.CFrame = hitbox.CFrame
	clone2.CFrame = hitbox.CFrame * CFrame.new(3, 0, 0)
	clone3.CFrame = hitbox.CFrame * CFrame.new(-3, 0, 0)
	clone.Parent = _WorldOrigin
	clone2.Parent = _WorldOrigin
	clone3.Parent = _WorldOrigin
	local v2 = sound:Play("HissLoop2", clone, nil, nil, 1.25)

	while tick() - lastTime < maxTime and value.Value == false do
		RunService.RenderStepped:Wait()

		if value.Value == true then
			break
		end

		local magnitude = (v.Position - hitbox.Position).Magnitude
		local position = (v * CFrame.Angles(0, 0, 0.13962634015954636) * CFrame.new(3, 0, 0)).Position
		local magnitude2 = (position - cFrame2.Position).Magnitude
		local v3, v4 = CreatePart()
		v4.MeshType = Enum.MeshType.Cylinder
		v3.CFrame = CFrame.new(position, cFrame2.Position) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
			magnitude2 / 2,
			0,
			0
		)
		clone3.CFrame = v3.CFrame * CFrame.new(-magnitude2, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		cFrame2 = v3.CFrame
		v3.Transparency = 0
		v3.Anchored = true
		v3.Color = Color3.fromRGB(193, 47, 255)
		v3.Material = Enum.Material.Neon
		v4.Scale = Vector3.new(magnitude2 * 3.5, 7, 7)
		local position2 = (v * CFrame.Angles(0, 0, 3.141592653589793) * CFrame.new(3, 0, 0)).Position
		local magnitude3 = (position2 - cFrame3.Position).Magnitude
		local v5, v6 = CreatePart()
		v6.MeshType = Enum.MeshType.Cylinder
		v5.CFrame = CFrame.new(position2, cFrame3.Position) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
			magnitude3 / 2,
			0,
			0
		)
		clone2.CFrame = v5.CFrame * CFrame.new(-magnitude3, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		cFrame3 = v5.CFrame
		v5.Transparency = 0
		v5.Anchored = true
		v5.Color = Color3.fromRGB(193, 47, 255)
		v5.Material = Enum.Material.Neon
		v6.Scale = Vector3.new(magnitude3 * 3.5, 7, 7)
		local position3 = hitbox.Position
		local v7, v8 = CreatePart()
		v8.MeshType = Enum.MeshType.Cylinder
		v7.CFrame = CFrame.new(position3, hitbox.Position + hitbox.CFrame.LookVector * 1) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		) * CFrame.new(-magnitude / 2, 0, 0)
		clone.CFrame = v7.CFrame * CFrame.new(-magnitude, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		v7.Transparency = 0
		v7.Anchored = true
		v7.Color = Color3.fromRGB(189, 83, 255)
		v7.Material = Enum.Material.Neon
		v8.Scale = Vector3.new(magnitude * 5.5, 12, 12)
		local tween2 = TweenService:Create(
			v4,
			TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false),
			{
				Scale = Vector3.new(v4.Scale.X, 0, 0)
			}
		)
		local tween3 = TweenService:Create(
			v6,
			TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false),
			{
				Scale = Vector3.new(v6.Scale.X, 0, 0)
			}
		)
		local tween4 = TweenService:Create(
			v8,
			TweenInfo.new(0.72, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false),
			{
				Scale = Vector3.new(v8.Scale.X, 0, 0)
			}
		)
		table.insert(connections, tween2.Completed:Connect(function()
			v3:Destroy()
		end))
		table.insert(connections, tween4.Completed:Connect(function()
			v7:Destroy()
		end))
		table.insert(connections, tween3.Completed:Connect(function()
			v5:Destroy()
		end))
		v3.Parent = _WorldOrigin
		v7.Parent = _WorldOrigin
		v5.Parent = _WorldOrigin
		tween2:Play()
		tween4:Play()
		tween3:Play()
		v = hitbox.CFrame * CFrame.Angles(0, 0, (math.rad(total * 5)))
		total += 2
	end

	sound:Kill(v2)
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	Util.Debris:AddItem(clone, 0.41)
	Util.Debris:AddItem(clone2, 0.41)
	Util.Debris:AddItem(clone3, 0.41)
	wait(1.6)
	endmove() -- equivalent call inferred; original call site unknown
end