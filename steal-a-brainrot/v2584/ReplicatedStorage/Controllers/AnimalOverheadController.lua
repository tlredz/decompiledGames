local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.Trove)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Rarities = require(ReplicatedStorage.Datas.Rarities)
local Traits = require(ReplicatedStorage.Datas.Traits)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local AnimalOverheadController = {}

function AnimalOverheadController:ResolveDisplayName(displayName: string, items)
	local animal = Animals[displayName]

	if animal then
		displayName = animal.DisplayName
	end

	if not items then
		return displayName
	end

	for _, item in items do
		local trait = Traits[item]

		if trait and trait.OverheadDisplayName then
			displayName = trait.OverheadDisplayName(displayName)
		end
	end

	return displayName
end

function AnimalOverheadController:PopulateTraits(instance, items, instance2)
	local traits = instance:FindFirstChild("Traits")

	if not traits then
		FastOverheadController.setStudsOffsetY(instance, 2.5)
		return
	end

	local total = 0

	if items then
		local template = traits.Template

		for _, item in items do
			local trait = Traits[item]

			if not trait then
				continue
			end

			if trait.OverheadYOffset then
				total += trait.OverheadYOffset
			end

			local clone = instance2:Clone(template)
			clone.Image = trait.Icon
			clone.Visible = true
			clone.Parent = traits
		end

		traits.Visible = true
		FastOverheadController.setStudsOffsetY(instance, total + 2.5)
	else
		traits.Visible = false
		FastOverheadController.setStudsOffsetY(instance, 2.5)
	end
end

function AnimalOverheadController:Populate(data)
	local overhead = data.Overhead
	local index = data.Index
	local traits = data.Traits
	local mutation = data.Mutation
	local player = data.Player
	local trove = data.Trove
	local animal = Animals[index]
	local rarity = Rarities[animal.Rarity]
	local hidePrice

	if data.HidePrice == nil then
		hidePrice = animal.HidePrice
	else
		hidePrice = data.HidePrice
	end

	local hideRarity

	if data.HideRarity == nil then
		hideRarity = animal.HideRarity
	else
		hideRarity = data.HideRarity
	end

	overhead.DisplayName.Text = self:ResolveDisplayName(index, traits)
	overhead.Price.Text = `${NumberUtils:ToString(Animals2:GetPrice(index, player))}`
	overhead.Price.Visible = not hidePrice
	overhead.Rarity.Text = animal.Rarity
	overhead.Rarity.TextColor3 = rarity.Color
	overhead.Rarity.Visible = not hideRarity
	overhead.Mutation.Visible = mutation ~= nil
	local v = mutation and MutationText.apply(overhead.Mutation, mutation, "Auto")

	if v then
		trove:Add(v)
	end

	if rarity.StrokeColor then
		overhead.Rarity.UIStroke.Color = rarity.StrokeColor
	end

	if rarity.GradientPreset then
		trove:Add(Gradients.apply(overhead.Rarity, rarity.GradientPreset))
	end

	local _1OF1Banner = overhead:FindFirstChild("1OF1Banner")

	if _1OF1Banner then
		trove:Add(BrainrotCard.ObserveOneOfOne({
			Index = index,
			Mutation = mutation
		}, function(visible)
			_1OF1Banner.Visible = visible
		end))
	end

	self:PopulateTraits(overhead, traits, trove)
end

return AnimalOverheadController