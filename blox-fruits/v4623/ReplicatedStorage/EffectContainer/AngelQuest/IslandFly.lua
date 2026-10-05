local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("AngelStyleQuest")
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")
return function()
	local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local currentCamera = workspace.CurrentCamera
	local v = { 1e999 }

	for _, child in pairs(workspace:GetChildren()) do
		if child.Name ~= "PrehistoricIsland" then
			continue
		end

		local magnitude = (child.Core.RockSpawn.Position - humanoidRootPart.Position).Magnitude

		if magnitude < v[1] then
			v = { magnitude, child }
		end
	end

	local v2 = v[2]

	if not v2 then
		return
	end

	local children = v2.Core.InteriorLava:GetChildren()
	table.sort(children, function(a, b)
		return b.Position.Y > a.Position.Y
	end)
	local position = children[3].Position
	local unit = (workspace.CurrentCamera.CFrame.RightVector * createVector(1, 0, 1)).Unit
	local cross = unit:Cross(createVector(0, -1, 0))
	local cframe = CFrame.fromMatrix(position, cross, unit, createVector(0, -1, 0))
	currentCamera.CameraType = Enum.CameraType.Scriptable
	local clones = {}

	for i = 1, 5 do
		local clone = game.ReplicatedStorage.BallWind.Wind:Clone()
		clone.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, math.random() * 2 * 3.141592653589793, 0) * CFrame.new(
			0,
			i * 200 + 1200,
			0
		)
		clone.Parent = workspace.Folder
		clone.Color = Color3.fromHSV(0, 0, math.random())
		Util.Debris:AddItem(clone, 5)
		table.insert(clones, clone)
	end

	local clones2 = {}

	for i = 1, 6 do
		local clone = game.ReplicatedStorage.Layer:Clone()
		clone.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, math.rad(i * 360 / 3), 0) * CFrame.new(
			0,
			i * 300 + 1200,
			0
		)
		clone.Parent = workspace.Folder
		clone.Color = Color3.fromHSV(0, 0, math.random())
		Util.Debris:AddItem(clone, 5)
		table.insert(clones2, clone)
		TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2.7), {
			Transparency = 1
		}):Play()
	end

	local tween = TweenService:Create(currentCamera, TweenInfo.new(0.6), {
		CFrame = cframe
	})
	tween:Play()
	tween.Completed:Wait()
	local count = 0
	local count2 = 0
	local cFrameChangedConnection = currentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		for _, v3 in pairs(clones) do
			if not (v3.Position.Y < currentCamera.CFrame.Position.Y - 267.84999999995) then
				continue
			end

			count += 1
			v3.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, math.random() * 2 * 3.141592653589793, 0) * CFrame.new(
				0,
				(count + 5) * 200 + 1200,
				0
			)
		end

		for k, v3 in pairs(clones2) do
			if not (v3.Position.Y < currentCamera.CFrame.Position.Y - 131.3495) then
				continue
			end

			count2 += 1
			v3.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, math.rad(k * 360 / 3), 0) * CFrame.new(
				0,
				(count2 + 3) * 300 + 1200,
				0
			)
		end
	end)
	TweenService:Create(
		game.Lighting.DepthOfField,
		TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 2.1),
		{
			FarIntensity = 1
		}
	):Play()
	TweenService:Create(currentCamera, TweenInfo.new(1.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		FieldOfView = 120
	}):Play()
	local tween2 = TweenService:Create(
		currentCamera,
		TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
		{
			CFrame = cframe * CFrame.new(0, 0, -2800)
		}
	)
	tween2:Play()
	tween2.Completed:Wait()
	cFrameChangedConnection:Disconnect()
	local cFrame = workspace.Map.AngelTrain.Spawn.CFrame * CFrame.Angles(0, -0.4363323129985824, 0) * CFrame.Angles(
		-0.4363323129985824,
		0,
		0
	) * CFrame.new(0, 0, 30)
	currentCamera.CFrame = cFrame * CFrame.new(0, 0, 300)
	TweenService:Create(game.Lighting.DepthOfField, TweenInfo.new(0.9), {
		FarIntensity = 0
	}):Play()
	local tween3 = TweenService:Create(currentCamera, TweenInfo.new(0.9, Enum.EasingStyle.Circular), {
		FieldOfView = 70,
		CFrame = cFrame
	})
	tween3:Play()
	tween3.Completed:Wait()
	currentCamera.CameraType = Enum.CameraType.Custom
end