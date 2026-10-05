local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local TitleController = require(ReplicatedStorage.CAM.Client.Controllers.TitleController)
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
local Categories = require(script.Categories)
local EquippedFrame = require(script.EquippedFrame)
local TitleGrid = require(script.TitleGrid)
local TitleSlots = require(script.TitleSlots)
require(script.Types)
local info = faye.Info(0.35, Enum.EasingStyle.Back)

local function loadTitles()
	local currentsByCounter = {}
	local result = {}

	for _, v in TitleController.List() do
		local thresholdsByCounter = {}

		for _, v2 in v.Progress do
			thresholdsByCounter[v2.counter] = v2.threshold
			currentsByCounter[v2.counter] = v2.current
		end

		table.insert(result, {
			Id = v.Id,
			Name = v.Def.displayName,
			Description = v.Def.description,
			Category = v.Def.category,
			Rarity = v.Def.rarity,
			Unlocked = v.Unlocked,
			Prerequisite = v.Prerequisite,
			Vanity = v.Vanity,
			Boost = v.Boost,
			Requirements = thresholdsByCounter,
			Buffs = v.Def.buffs or {},
			Passives = v.Def.collection or {}
		})
	end

	table.sort(result, function(a, b)
		if a.Unlocked ~= b.Unlocked then
			return a.Unlocked
		end

		local index = table.find(Rarities.Order, a.Rarity) or 0
		local index2 = table.find(Rarities.Order, b.Rarity) or 0

		if index == index2 then
			return a.Name < b.Name
		end

		return index < index2
	end)
	return result, currentsByCounter
end

return function(object, p)
	local v, v2 = loadTitles()
	local value = object:Value("All")
	local stringValue = Instance.new("StringValue")
	local names = {}

	for _, v3 in v do
		table.insert(names, v3.Name)
	end

	local value2 = object:Value("")
	local v3 = {}

	for _, v4 in v do
		v3[v4.Id] = v4
	end

	local v4 = {}
	local value3 = object:Value(v4)

	local function updateShown()
		table.clear(v4)
		local v5 = value:Get()
		local value4 = string.lower(stringValue.Value)
		local v6

		if v5 == "Equipped" then
			v6 = TitleController.Boost()
		end

		local v7

		if v5 == "Equipped" then
			v7 = TitleController.Vanity()
		end

		for _, v8 in v do
			if v5 == "Equipped" then
				if v7 ~= v8.Id and table.find(v6, v8.Id) == nil then
					continue
				end
			elseif v5 ~= "All" and v8.Category ~= v5 then
				continue
			end

			if not (value4 == "" or string.sub(string.lower(v8.Name), 1, #value4) == value4) then
				continue
			end

			table.insert(v4, v8)
		end

		value3:Refresh()
		local v8 = value2:Get()

		if v8 ~= "" then
			local v9 = false

			for _, v11 in v4 do
				if v11.Id ~= v8 then
					continue
				end

				v9 = true
				break
			end

			if not v9 then
				value2:Set("")
			end
		end
	end

	updateShown()
	object:Connect(value.Changed, updateShown)
	object:Connect(stringValue:GetPropertyChangedSignal("Value"), updateShown)
	object:Connect(TitleController.Updated, function()
		if value:Get() == "Equipped" then
			updateShown()
		end
	end)
	local flag = false
	return object:Create("Frame")({
		Name = "Titles",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = object:Do(function(callback)
			local uDim

			if callback(value2) == "" then
				uDim = UDim2.fromScale(0.5, 0.5)
			else
				uDim = UDim2.fromScale(0.45, 0.5)
			end

			if flag then
				return object:Animation(uDim, info)
			end

			flag = true
			return uDim
		end),
		Size = object:Animation(UDim2.fromScale(0.625, 0.625), object.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.5625, 0.5625)
		}),
		BackgroundTransparency = 1,
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 1.8
		}),
		EquippedFrame(object, p, value2, v3, v2),
		object:Create("Frame")({
			Name = "SearchbarHolder",
			Size = UDim2.fromScale(0.3, 0.065),
			Position = UDim2.fromScale(0, -0.015),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			(Searchbar(object, names, stringValue, "Search titles", true))
		}),
		Categories(object, p, value, v, "All", "Equipped"),
		TitleGrid(object, p, value3, value2),
		TitleSlots(object, value2, v3)
	})
end