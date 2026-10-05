local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Bezier = require(script.Bezier)
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
		return
	end

	local connections = {}
	local clone = FX:WaitForChild("SerpentBow").SnakeHead:Clone()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function endmove()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end
	end

	clone.Size = createVector(1.05, 1.201, 2.308)
	clone.Color = Color3.fromRGB(179, 26, 255)
	clone.Transparency = 0.15
	clone.CFrame = data.OriginalCF
	clone.Parent = _WorldOrigin
	local lastTime = tick()
	local v = Bezier.new(
		data.OriginalCF.Position,
		(data.CFrame * CFrame.new(math.random(-80, 80), math.random(10, 35), math.random(25, 50))).Position,
		(data.CFrame * CFrame.new(math.random(-35, 35), math.random(-3, 10), math.random(10, 15))).Position,
		data.CFrame.Position
	)
	local v2 = data.OriginalCF.Position + createVector(1, 1, 1) * math.random(-3, 3)
	wait()
	local v3 = math.random(-3, 8) / 10 + 1.5
	sound:Play("HissIn", cFrame, nil, v3, 0.5)

	while tick() - lastTime < data.StartTime do
		wait()
		local v4 = v:Get((math.clamp((tick() - lastTime) / data.StartTime, 0, 1)))
		local cframe = CFrame.new(v4, v2)
		clone.CFrame = cframe
		local magnitude = (v2 - v4).Magnitude
		local v5, v6 = CreatePart()
		v6.MeshType = Enum.MeshType.Cylinder
		v5.CFrame = CFrame.new(v4, cframe.Position + cframe.LookVector * -1) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
			-magnitude / 2,
			0,
			0
		)
		v5.Transparency = 0
		v5.Anchored = true
		v5.Color = Color3.fromRGB(179, 26, 255)
		v5.Material = Enum.Material.Neon
		v6.Scale = Vector3.new(magnitude * 5, 3.5, 3.5)
		local tween = TweenService:Create(v6, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Scale = Vector3.new(v6.Scale.X, 0, 0)
		})
		table.insert(connections, tween.Completed:Connect(function()
			v5:Destroy()
		end))
		v5.Parent = _WorldOrigin
		tween:Play()
		v2 = v4
	end

	local lastTime2 = tick()
	local cFrame2 = hitbox.CFrame
	sound:Play("HissOut", cFrame, nil, v3, 0.5)

	while tick() - lastTime2 < maxTime and value.Value == false do
		RunService.RenderStepped:Wait()

		if value.Value == true then
			break
		end

		local magnitude = (cFrame2.Position - hitbox.Position).Magnitude
		local position = hitbox.Position
		local v4, v5 = CreatePart()
		v5.MeshType = Enum.MeshType.Cylinder
		v4.CFrame = CFrame.new(position, hitbox.Position + hitbox.CFrame.LookVector * 1) * CFrame.Angles(
			0,
			1.5707963267948966,
			0
		) * CFrame.new(-magnitude / 2, 0, 0)
		clone.CFrame = v4.CFrame * CFrame.new(-magnitude, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		v4.Transparency = 0
		v4.Anchored = true
		v4.Color = Color3.fromRGB(179, 26, 255)
		v4.Material = Enum.Material.Neon
		v5.Scale = Vector3.new(magnitude * 5, 3.5, 3.5)
		local tween = TweenService:Create(v5, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Scale = Vector3.new(v5.Scale.X, 0, 0)
		})
		table.insert(connections, tween.Completed:Connect(function()
			v4:Destroy()
		end))
		v4.Parent = _WorldOrigin
		tween:Play()
		cFrame2 = hitbox.CFrame
	end

	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new()
	}):Play()
	Util.Debris:AddItem(clone, 0.41)
	wait(1.6)
	endmove() -- equivalent call inferred; original call site unknown
end