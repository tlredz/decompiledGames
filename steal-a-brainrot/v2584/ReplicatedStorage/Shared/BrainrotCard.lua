local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = require(ReplicatedStorage.Shared.Animals)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local singletonBrainrotMutations = ReplicatorClient.get("SingletonBrainrotMutations")
local color = Color3.fromRGB(200, 50, 50)
local color2 = Color3.fromRGB(220, 160, 0)
local v = {
	OneOfOneBackground = color,
	OneOfOneStroke = color2,
	IsOneOfOne = function(data)
		if type(data.OneOfOne) == "boolean" then
			return data.OneOfOne
		end

		local data2 = singletonBrainrotMutations.Data
		local pairs = data2 and data2.pairs
		return type(pairs) == "table" and pairs[`{data.Index}:{data.Mutation or "Normal"}`] == true
	end
}

function v.ObserveOneOfOne(p, callback)
	local connection = singletonBrainrotMutations:ListenRaw(function()
		callback(v.IsOneOfOne(p))
	end)
	callback(v.IsOneOfOne(p))
	return function()
		connection:Disconnect()
	end
end

function v.ApplyOneOfOne(instance, visible: boolean, flag: boolean?)
	local spacer = instance:FindFirstChild("Spacer") or instance:FindFirstChild("Item") or instance
	local banner = instance:FindFirstChild("Banner") or spacer:FindFirstChild("Banner")

	if banner and banner:IsA("GuiObject") then
		banner.Visible = visible
	end

	local crowm = instance:FindFirstChild("Crowm") or spacer:FindFirstChild("Crowm")

	if crowm and crowm:IsA("GuiObject") then
		crowm.Visible = visible
	end

	local starburst = spacer:FindFirstChild("Starburst")

	if starburst and starburst:IsA("GuiObject") then
		starburst.Visible = visible
	end

	if visible and flag ~= false and spacer:IsA("GuiObject") then
		spacer.BackgroundColor3 = color
		spacer.BackgroundTransparency = 0
		local uIStroke = spacer:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = color2
			uIStroke.Transparency = 0
		end
	end
end

local function renderTraits(traits, traits2, instance)
	for _, name in traits2 or {} do
		local trait = Traits[name]

		if not trait then
			continue
		end

		local clone = instance:Clone(traits.Template)
		clone.Name = name
		clone.Visible = true
		clone.Image = trait.Icon
		clone.Parent = traits
	end
end

local function applyRarity(rarityLabel, rarity: string?, maid)
	rarityLabel.Text = rarity or ""
	local v2

	if rarity then
		v2 = Rarities[rarity]
	end

	if v2 and v2.GradientPreset then
		rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		maid:Add(Gradients.apply(rarityLabel, v2.GradientPreset))
	elseif v2 then
		rarityLabel.TextColor3 = v2.Color
	end
end

local function renderCanonical(p, data, object)
	local animal = Animals2[data.Index]
	local spacer = p.Spacer
	spacer.Title.Text = animal and animal.DisplayName or data.Index
	spacer.Cash.Text = `${NumberUtils:ToString(Animals:GetGeneration(data.Index, data.Mutation, data.Traits))}/s`
	local v2 = Animals:AttachOnViewportWithOptimizations(data.Index, spacer.ViewportFrame, nil, data.Mutation)

	if v2 then
		object:Add(v2)
	end

	renderTraits(spacer.Traits, data.Traits, object)
	v.ApplyOneOfOne(p, v.IsOneOfOne(data))
end

local function renderEquipBrainrots(data, data2, object)
	local animal = Animals2[data2.Index]
	data.NameLabel.Text = animal and animal.DisplayName or data2.Index
	applyRarity(data.RarityLabel, animal and animal.Rarity, object)
	local v2 = MutationText.apply(data.MutationLabel, data2.Mutation, "Auto")

	if v2 then
		object:Add(v2)
	end

	renderTraits(data.Traits, data2.Traits, object)
	v.ApplyOneOfOne(data, v.IsOneOfOne(data2), false)
end

local v2 = {
	EquipBrainrots = renderEquipBrainrots
}

function v.Register(p: string, callback)
	v2[p] = callback
end

function v.Render(p, p2, p3, value: string?)
	(v2[value or "LiveTrade"] or renderCanonical)(p, p2, p3)
end

return table.freeze(v)