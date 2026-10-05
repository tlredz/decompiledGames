local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
return function(data)
	local position0 = data.Position0
	local position1 = data.Position1
	local length = data.Length or 10
	local offset = data.Offset or 5
	local color = data.Color or Color3.new(0, 1, 1)
	local thickness = data.Thickness or 0.25
	local lifetime = data.Lifetime or 0.5
	local magnitude = (position0 - currentCamera.CFrame.p).magnitude

	if 200 + length * 10 < magnitude then
		return
	end

	if data.Sound then
		local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
		local sound = Util.Sound
		sound:Play("SlightZap", position1, nil, 1.5)
		sound:FadeOut(sound:Play("Thunder", position1), 1)
	end

	local magnitude2 = (position0 - position1).magnitude
	local v = magnitude2 / length

	for i = 0, math.floor(v - 0.5) do
		local part = Instance.new("Part")
		part.Anchored = true
		part.Color = color
		part.Transparency = data.Transparency or 0.5
		part.CanCollide = false
		part.Material = "Neon"
		part.Size = createVector(0.2, 0.2, 0.2)
		local blockMesh = Instance.new("BlockMesh", part)
		blockMesh.Name = "Mesh"
		local v2 = Vector3.new(
			offset * (math.random() - 0.5),
			offset * (math.random() - 0.5),
			offset * (math.random() - 0.5)
		) * (v - 1 <= i and 0 or 1)
		local v3 = CFrame.new(position0, position1) * CFrame.new(0, 0, magnitude2 / v).p + v2
		blockMesh.Scale = Vector3.new(thickness, thickness, magnitude2 / v) / 0.2
		part.CFrame = CFrame.new(position0, v3) * CFrame.new(0, 0, magnitude2 / v / 2)
		position0 = part.CFrame * Vector3.new(0, 0, magnitude2 / v / 2)
		part.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(part, TweenInfo.new(lifetime), {
			Transparency = 1
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
		TweenService:Create(blockMesh, TweenInfo.new(lifetime), {
			Scale = blockMesh.Scale * createVector(0, 0, 1)
		}):Play()

		if not data.Step or i % data.Step == 0 then
			RunService.RenderStepped:wait()
		end
	end
end