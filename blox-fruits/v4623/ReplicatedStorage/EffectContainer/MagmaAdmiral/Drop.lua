local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local debris = Util.Debris
local color = Color3.fromRGB(255, 94, 20)
local v = nil

local function getPuddle()
	if v then
		return v
	end

	local effectContainer = game.ReplicatedStorage:FindFirstChild("EffectContainer")
	local magma1 = effectContainer and effectContainer:FindFirstChild("Magma1")
	local magmaPuddle = magma1 and magma1:FindFirstChild("MagmaPuddle")

	if magmaPuddle and magmaPuddle:IsA("ModuleScript") then
		local module = require(magmaPuddle)
		v = module
	end

	return v
end

return function(data)
	local position = data.Position or data.position

	if typeof(position) ~= "Vector3" or (position - workspace.CurrentCamera.CFrame.Position).Magnitude > 700 then
		return
	end

	local size = data.Size or 3
	local fallTime = data.FallTime or 0.45
	local fallHeight = data.FallHeight or 40
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Size = createVector(1.8, 1.8, 1.8)
	part.CFrame = CFrame.new(position + createVector(0, 1, 0) * fallHeight)
	part.Parent = workspace._WorldOrigin
	debris:AddItem(part, fallTime + 0.3)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 2
	pointLight.Range = 9
	pointLight.Parent = part
	TweenService:Create(part, TweenInfo.new(fallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = CFrame.new(position),
		Size = createVector(2.34, 1.08, 2.34)
	}):Play()
	task.delay(fallTime, function()
		if part.Parent then
			part.Transparency = 1
			pointLight.Enabled = false
		end

		local puddle = getPuddle()

		if puddle then
			pcall(puddle, position, size, data.Smoke ~= false, data.Lifetime)
		end

		local v2 = math.clamp(size, 0.4, 2)

		for i = 1, 3 do
			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
			part2.Material = Enum.Material.Neon
			part2.Color = color
			part2.Size = Vector3.new(v2 * 1.6, 1, v2 * 1.6)
			local cframe = CFrame.Angles(
				math.rad((math.random(-14, 14))),
				math.rad((math.random(-180, 180))),
				(math.rad((math.random(-14, 14))))
			)
			local v3 = (i - 1) * 1.1 * v2
			local cframe2 = CFrame.new(position + Vector3.new(
				math.random(-10, 10) / 10 * v3,
				0,
				math.random(-10, 10) / 10 * v3
			))
			part2.CFrame = cframe2 * cframe
			part2.Parent = workspace._WorldOrigin
			debris:AddItem(part2, 0.75)
			local v4 = v2 * 22 * (0.55 + math.random() * 0.6)
			TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = Vector3.new(v2 * 1.6 * 0.35, v4, v2 * 1.6 * 0.35),
				CFrame = cframe2 * cframe * CFrame.new(0, v4 * 0.5, 0),
				Transparency = 1
			}):Play()
		end
	end)
end