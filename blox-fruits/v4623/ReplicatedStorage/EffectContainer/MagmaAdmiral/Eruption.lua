local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local color = Color3.fromRGB(255, 94, 20)
return function(data)
	local position = data.Position or data.position

	if typeof(position) ~= "Vector3" or (position - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local riseTime = data.RiseTime or 0.55
	local height = data.Height or 40
	local v = math.clamp(data.Size or 1, 0.4, 2)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Size = createVector(2.34, 1.08, 2.34)
	part.CFrame = CFrame.new(position)
	part.Parent = workspace._WorldOrigin
	debris:AddItem(part, riseTime + 0.15)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 2
	pointLight.Range = 9
	pointLight.Parent = part
	TweenService:Create(part, TweenInfo.new(riseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(position + createVector(0, 1, 0) * height),
		Size = createVector(1.8, 1.8, 1.8)
	}):Play()

	for i = 1, 5 do
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CanTouch = false
		part2.Material = Enum.Material.Neon
		part2.Color = color
		part2.Size = Vector3.new(v * 1.7, 1, v * 1.7)
		local cframe = CFrame.Angles(
			math.rad((math.random(-18, 18))),
			math.rad((math.random(-180, 180))),
			(math.rad((math.random(-18, 18))))
		)
		local v2 = (i - 1) * 1.1 * v
		local cframe2 = CFrame.new(position + Vector3.new(
			math.random(-10, 10) / 10 * v2,
			0,
			math.random(-10, 10) / 10 * v2
		))
		part2.CFrame = cframe2 * cframe
		part2.Parent = workspace._WorldOrigin
		debris:AddItem(part2, 0.7)
		local v3 = v * 18 * (0.55 + math.random() * 0.6)
		TweenService:Create(part2, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = Vector3.new(v * 1.7 * 0.35, v3, v * 1.7 * 0.35),
			CFrame = cframe2 * cframe * CFrame.new(0, v3 * 0.5, 0),
			Transparency = 1
		}):Play()
	end
end