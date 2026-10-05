local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local modules = ReplicatedStorage.shared.modules
require(modules:WaitForChild("every"))
local rarities = require(modules:WaitForChild("library"):WaitForChild("rarities"))
local rarities2 = rarities.Rarities
local Animatedgradient = {}
Animatedgradient.__index = Animatedgradient

local function clampValue(value)
	return (math.clamp(value, 0, 1))
end

Animatedgradient._presets = {
	Default = ColorSequence.new(Color3.fromHSV(255, 255, 255)),
	Rainbow = rarities2.Exotic.ColorGradient
}
local v = {}

for _, rarity in rarities2 do
	if rarity.ColorGradient and rarity.Name ~= "Exotic" then
		Animatedgradient._presets[rarity.Name] = rarity.ColorGradient
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nameFromPreset(p)
	for k, _preset in pairs(Animatedgradient._presets) do
		if _preset == p then
			return k
		end
	end

	return "Default"
end

function Animatedgradient.new(p, p2, value)
	local v2 = p or Animatedgradient._presets.Default
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Name = "AnimatedGradient"
	uIGradient.Rotation = 0
	uIGradient.Color = v2

	if p2 then
		return uIGradient
	end

	HttpService:GenerateGUID(false)
	local name = nameFromPreset(v2) -- equivalent call inferred; original call site unknown
	table.insert(v, {
		gradient = uIGradient,
		preset = v2,
		name = name,
		speed = value or 1
	})
	return uIGradient
end

function Animatedgradient.clearold(instance)
	for _, uIGradient in pairs(instance:GetChildren()) do
		if uIGradient:IsA("UIGradient") and uIGradient.Name == "AnimatedGradient" then
			uIGradient:Destroy()
		end
	end
end

RunService.Heartbeat:Connect(function(_)
	debug.profilebegin("animatedgradient::Heartbeat")

	for k, v2 in pairs(v) do
		local gradient = v2.gradient

		if gradient then
			if gradient:IsDescendantOf(game) then
				local preset = v2.preset
				local v3 = 2 / (v2.speed or 1)
				local v4 = tick() % v3 / v3

				if rarities2[v2.name] then
					gradient.Offset = Vector2.new(v4 * 2 - 1, 0)
				else
					local count = #preset.Keypoints
					local colorSequenceKeypoints = {}

					for i = 1, count do
						local _, v5, v6 = preset.Keypoints[i].Value:ToHSV()
						local color = Color3.fromHSV(math.clamp(v4 - i / count, 0, 1), v5, v6)

						if v4 - i / count < 0 then
							color = Color3.fromHSV(math.clamp(v4 - i / count + 1, 0, 1), v5, v6)
						end

						colorSequenceKeypoints[i] = ColorSequenceKeypoint.new((i - 1) / (count - 1), color)
					end

					gradient.Color = ColorSequence.new({ table.unpack(colorSequenceKeypoints) })
				end
			else
				table.remove(v, k)
			end
		else
			table.remove(v, k)
		end
	end

	debug.profileend()
end)
return Animatedgradient