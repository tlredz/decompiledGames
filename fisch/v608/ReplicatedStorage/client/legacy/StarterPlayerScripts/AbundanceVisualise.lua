repeat
	task.wait()
until game:IsLoaded()

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules")
local library = modules:WaitForChild("library")
local fish = require(library:WaitForChild("fish"))
local mutations = require(modules:WaitForChild("fishing"):WaitForChild("mutations"))
local mutations2 = mutations.Mutations
local animatedgradient = require(modules:WaitForChild("fx"):WaitForChild("animatedgradient"))
local rarities = require(library.rarities)

local function build(instance)
	local abundance = instance:FindFirstChild("Abundance")

	if not (abundance and abundance.Value) then
		return
	end

	local v = abundance.Value == "Nuclear" or abundance.Value == "Atomic" or abundance.Value == "Heartburst" or abundance.Value == "Shady"
	local v2 = v or abundance:GetAttribute("ZoneStyle") == "Circle"

	if not v and abundance.Value ~= "Mutation" and not fish[abundance.Value] then
		return
	end

	for _, child in pairs(instance:GetChildren()) do
		if child.Name == "radar1" or child.Name == "radar1Circular" or child.Name == "radar2" or child.Name == "radar2Circular" then
			child:Destroy()
		end
	end

	local clone = v2 and script:FindFirstChild("radar1Circular") and script.radar1Circular:Clone() or script:FindFirstChild("radar1") and script.radar1:Clone()

	if not clone then
		warn("Failed to find radar1 or radar1Circular for cloning in script")
		return
	end

	local radar2Circular

	if v2 then
		radar2Circular = instance:FindFirstChild("radar2Circular") or script:FindFirstChild("radar2Circular") and script.radar2Circular:Clone()

		if not radar2Circular then
			warn("Failed to find radar2Circular for Circular abundance")
			return
		end
	else
		radar2Circular = script:FindFirstChild("radar2") and script.radar2:Clone()

		if not radar2Circular then
			warn("Failed to find radar2 for cloning in script")
			return
		end
	end

	local value

	if abundance.Value == "Mutation" then
		value = abundance:FindFirstChild("Mutation") and abundance.Mutation.Value
	else
		value = false
	end

	local value2 = abundance.Value

	if value then
		value2 = mutations2[value].Display or value
	end

	if instance:GetAttribute("AbundanceDisplayName") then
		value2 = instance:GetAttribute("AbundanceDisplayName")
	end

	clone.abundanceName.Text = "[" .. value2 .. "]"
	clone.abundanceName.TextColor3 = abundance.Value == "Nuclear" and Color3.fromRGB(4, 255, 0) or abundance.Value == "Atomic" and Color3.fromRGB(
		255,
		255,
		0
	) or abundance.Value == "Heartburst" and Color3.fromRGB(255, 0, 174) or abundance.Value == "Shady" and Color3.fromRGB(
		128,
		94,
		94
	) or value and mutations2[value].Color or rarities.StaticColors[fish[abundance.Value].Rarity]
	clone.Parent = instance
	radar2Circular.area.BackgroundColor3 = clone.abundanceName.TextColor3
	radar2Circular.area.border.Color = clone.abundanceName.TextColor3

	if v2 then
		radar2Circular.area.CanvasGroup.lines.ImageColor3 = clone.abundanceName.TextColor3
		radar2Circular.Adornee = instance

		if v then
			clone:AddTag("radarTagWithTimer")
			clone.abundanceName.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	else
		radar2Circular.area.lines.ImageColor3 = clone.abundanceName.TextColor3
	end

	animatedgradient.clearold(clone.abundanceName)
	animatedgradient.clearold(radar2Circular.area)
	animatedgradient.clearold(radar2Circular.area.border)

	if v2 then
		animatedgradient.clearold(radar2Circular.area.CanvasGroup.lines)
	else
		animatedgradient.clearold(radar2Circular.area.lines)
	end

	if fish[abundance.Value] and fish[abundance.Value].Rarity then
		if fish[abundance.Value].Rarity == "Exotic" then
			clone.abundanceName.TextColor3 = Color3.new(1, 1, 1)
			radar2Circular.area.BackgroundColor3 = Color3.new(1, 1, 1)
			radar2Circular.area.border.Color = Color3.new(1, 1, 1)
			radar2Circular.area.lines.ImageColor3 = Color3.new(1, 1, 1)
			local new = animatedgradient.new(animatedgradient._presets.Rainbow)
			new.Parent = clone.abundanceName
			local new_2 = animatedgradient.new(animatedgradient._presets.Rainbow)
			new_2.Parent = radar2Circular.area
			local new_3 = animatedgradient.new(animatedgradient._presets.Rainbow)
			new_3.Parent = radar2Circular.area.border
			local new_4 = animatedgradient.new(animatedgradient._presets.Rainbow)
			new_4.Parent = v2 and radar2Circular.area.CanvasGroup.lines or radar2Circular.area.lines
		elseif fish[abundance.Value].Rarity == "Secret" then
			clone.abundanceName.TextColor3 = Color3.new(1, 1, 1)
			radar2Circular.area.BackgroundColor3 = Color3.new(1, 1, 1)
			radar2Circular.area.border.Color = Color3.new(1, 1, 1)
			radar2Circular.area.lines.ImageColor3 = Color3.new(1, 1, 1)
			local new_5 = animatedgradient.new(animatedgradient._presets.Secret)
			new_5.Parent = clone.abundanceName
			local new_6 = animatedgradient.new(animatedgradient._presets.Secret)
			new_6.Parent = radar2Circular.area
			local new_7 = animatedgradient.new(animatedgradient._presets.Secret)
			new_7.Parent = radar2Circular.area.border
			local new_8 = animatedgradient.new(animatedgradient._presets.Secret)
			new_8.Parent = v2 and radar2Circular.area.CanvasGroup.lines or radar2Circular.area.lines
		end
	end

	radar2Circular.Parent = instance
	clone.Enabled = false
	radar2Circular.Enabled = false
end

task.wait(20)

for _, v in pairs(CollectionService:GetTagged("abundance")) do
	if v:FindFirstChild("Abundance") then
		build(v)
	end

	RunService.Heartbeat:Wait()
end

CollectionService:GetInstanceAddedSignal("abundance"):Connect(function(p)
	build(p)
end)