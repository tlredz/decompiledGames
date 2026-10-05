local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local distributedLoop = Util.DistributedLoop
local misc = Util.Misc
local colorSequencer = Util.ColorSequencer
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local scaleModel = misc.ScaleModel

-- equivalent calls inferred from this helper; original call sites unknown
local function setColor(data, value)
	local v = value or 5
	return Color3.new(data.r * v, data.g * v, data.b * v)
end

return function(data)
	local cFrame = data.CFrame or CFrame.new()
	local scale = data.Scale or 1
	local fadeIn = data.FadeIn or data.Duration or 0.3
	local fadeOut = data.FadeOut or 1
	local lifetime = data.Lifetime or 0
	local colorSequence = data.ColorSequence or { Color3.fromRGB(22, 18, 17) }
	local brightness = data.Brightness or 5
	local mode = data.Mode or "Generic"
	local v = fadeIn * 2 + lifetime / 2
	local v2 = colorSequencer(colorSequence, v, v)
	local children = {}
	local clone = dough.Explosions.Floor:Clone()

	if mode == "Cracks" then
		local burntFloor = clone:FindFirstChild("BurntFloor")

		if burntFloor then
			burntFloor:Destroy()
		end
	else
		local cracks = mode == "Burn" and clone:FindFirstChild("Cracks")

		if cracks then
			cracks:Destroy()
		end
	end

	for _, child in pairs(clone:GetChildren()) do
		for _, child2 in pairs(child:GetChildren()) do
			table.insert(children, child2)
		end
	end

	for _, v3 in pairs(children) do
		if data.Transparency then
			v3.Transparency = data.Transparency
		end

		v3.Color3 = setColor(colorSequence[1], brightness)
	end

	scaleModel(clone, 0.1, 45)
	clone:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
		0,
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		0
	))
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		local v4

		if child.Name:find("Burn") then
			v4 = fadeIn * 0.91 or fadeIn
		else
			v4 = fadeIn
		end

		TweenService:Create(child, TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = child:GetAttribute("RawSize") / 45 * scale
		}):Play()
	end

	distributedLoop:add(function(p, p2)
		local v3 = math.min(1, p / v)
		local v4 = brightness * (1 - v3)
		v2:update(p2)

		for _, v5 in pairs(children) do
			v5.Color3 = setColor(v2:toColor3(), v4)
		end

		if v3 == 1 then
			return true
		end
	end)
	task.wait(lifetime + fadeIn)

	for _, child in pairs(clone:GetChildren()) do
		for _, child2 in pairs(child:GetChildren()) do
			TweenService:Create(child2, TweenInfo.new(fadeOut, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end
	end

	task.wait(fadeOut)
	clone:Destroy()
end