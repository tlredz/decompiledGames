local createVector = vector.create
local v = {
	"rbxassetid://9911742221",
	"rbxassetid://9911741863",
	"rbxassetid://9911741541",
	"rbxassetid://9911741307",
	"rbxassetid://9911741114",
	"rbxassetid://9911740959",
	"rbxassetid://9911740727",
	"rbxassetid://9911740519",
	"rbxassetid://9911740304",
	"rbxassetid://9911740020"
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local distributedLoop = Util.DistributedLoop
local _ = Util.Tween
local colorSequencer = Util.ColorSequencer
local loadTexture = misc.LoadTexture
local scaleModel = misc.ScaleModel
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function setColor(data, value)
	local v2 = value or 5
	return Color3.new(data.r * v2, data.g * v2, data.b * v2)
end

return function(data)
	local cFrame = data.CFrame or CFrame.new()
	local scale = data.Scale or 1
	local fadeIn = data.FadeIn or data.Duration or 0.3
	local fadeOut = data.FadeOut or 1
	local lifetime = data.Lifetime or 0
	local brightness = data.Brightness or 1
	local color = data.Color and (typeof(data.Color) == "table" and data.Color or { data.Color })

	if not color then
		local rayCastWhitelist = Util.RayCastWhitelist(
			cFrame * createVector(0, 1, 0),
			-cFrame.UpVector * (2 + scale),
			{ workspace.Map }
		)
		color = rayCastWhitelist and { rayCastWhitelist.Color } or color
	end

	local v2 = fadeIn * 2 + lifetime / 2
	local v3 = colorSequencer(color, v2, v2)
	local clone = dough.Explosions.Cracks:Clone()
	local decals = {}

	for _, child in pairs(clone:GetChildren()) do
		for _, decal in pairs(child:GetChildren()) do
			if decal:IsA("Decal") then
				table.insert(decals, decal)
			end
		end
	end

	for _, v4 in pairs(decals) do
		if data.Transparency then
			v4.Transparency = data.Transparency
		end

		v4.Color3 = setColor(color[1], brightness)
	end

	scaleModel(clone, 0.1, 25)
	clone:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
		0,
		Random.new():NextNumber(-3.141592653589793, 3.141592653589793),
		0
	))
	clone.Parent = _WorldOrigin

	for _, child in pairs(clone:GetChildren()) do
		TweenService:Create(child, TweenInfo.new(fadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = child:GetAttribute("RawSize") / 25 * scale
		}):Play()
	end

	distributedLoop:add(function(p, p2)
		local v4 = math.min(1, p / v2)
		local v5 = brightness * (1 - v4)
		v3:update(p2)

		for _, v6 in pairs(decals) do
			v6.Color3 = setColor(v3:toColor3(), v5)
		end

		if v4 == 1 then
			return true
		end
	end)
	task.spawn(function()
		loadTexture(clone.PrimaryPart, v, (math.max(0.016666666666666666, fadeIn / #v)))
	end)
	task.wait(lifetime + fadeIn)

	for _, v4 in pairs(decals) do
		TweenService:Create(v4, TweenInfo.new(fadeOut, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end

	loadTexture(clone.PrimaryPart, v, math.max(0.016666666666666666, fadeOut / #v), true)
	clone:Destroy()
end