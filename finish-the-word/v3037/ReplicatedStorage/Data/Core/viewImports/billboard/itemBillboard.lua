local replicatedAssets = game.ReplicatedStorage.ReplicatedAssets
local import = _G.import("romodel")
local import2 = _G.import("iconData")
local import3 = _G.import("itemModules")
local import4 = _G.import("viewImports")
local basic = import4:get("basic")
local react = import4:get("react")
local v = import4:get("item")
local v2 = {
	Common = Color3.fromRGB(0, 255, 0),
	Uncommon = Color3.fromRGB(0, 170, 255),
	Rare = Color3.fromRGB(255, 128, 0),
	Legendary = Color3.fromRGB(238, 0, 255)
}
local model = import.model("Frame")

function model.init(p)
	return {
		BackgroundColor3 = v2[p.Rarity],
		BorderSizePixel = 0,
		Size = UDim2.new(p.Rarity == "Rare" and 0.7 or p.Rarity == "Common" and 0.9 or 1.3, 0, 0.2, 0)
	}, {
		TextLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(0.95, 0, 0.9, 0),
			Text = string.upper(p.Rarity),
			Font = Enum.Font.GothamBlack,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.15
		})
	}
end

local model2 = import.model(basic.TextLabel)

function model2.init()
	return {
		Size = UDim2.new(1, 0, 0.25, 0),
		Text = "Metal",
		Font = Enum.Font.GothamBlack,
		StrokeWidth = 0.125,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	}
end

local model3 = import.model(basic.EmptyList)

function model3.init(p)
	local v3 = p.Currency[1] == "SpecialKey"
	return {
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0.2, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, {
		Icon = import.make(basic.ImageLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			Image = import2[p.Currency[1]]
		}),
		TextLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(0.2, 0, 0.8, 0),
			Font = Enum.Font.GothamBlack,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = v3 and 0.15 or 0.07,
			Text = p.Currency[2]
		}, {
			InnerText = import.make(basic.TextLabel, {
				Location = "Center",
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBlack,
				Text = p.Currency[2],
				TextColor3 = v3 and Color3.new(1, 1, 1) or Color3.new(0, 1, 0)
			}, {
				UIStrokeInner = v3 and import.make(import.wrap("UIStroke", basic.Gradient), {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.05,
					Color = Color3.new(1, 1, 1),
					GradientColor = replicatedAssets.Ui.Gradients.Secret.Color,
					RotSpeed = 90
				}) or nil
			})
		})
	}
end

local model4 = import.model(basic.TextLabel, react.LinkedText)

function model4.init(data)
	return {
		Size = UDim2.new(1, 0, 0.2, 0),
		TextColor3 = Color3.new(0, 1, 0),
		Font = Enum.Font.GothamBlack,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		StrokeWidth = 0.125,
		KeyChains = { "Inventory.Chair" },
		TextSavedChanged = function(_, object)
			local has = object:has("Inventory", "Chair", data.Id)

			if data.Prompt then
				data.Prompt.ActionText = has and "View" or "Buy"
			end

			if has then
				return "Owned"
			end

			return (data.Robux and "R$ " or "$") .. data.Cost
		end
	}
end

local model5 = import.model(basic.ImageLabel, basic.Padding)

function model5.init(p)
	return {
		Size = UDim2.new(0.5, 0, 0.5, 0),
		ImageColor3 = Color3.new(1, 1, 1),
		PaddingTop = UDim.new(0.1, 0)
	}, {
		OuterStroke = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Image = "rbxassetid://139739896343392"
		}),
		InnerStroke = import.make(import.wrap(basic.ImageLabel, basic.Gradient), {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Image = "rbxassetid://133912884954077",
			GradientColor = replicatedAssets.Ui.Gradients.Secret.Color,
			RotSpeed = 90,
			ZIndex = 2
		}),
		Inner = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Image = "rbxassetid://139624400769032",
			ZIndex = 3
		}),
		PetViewport = import.make(v.PetViewport, {
			Id = p.Pet,
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(1.2, 0, 1.2, 0),
			ZIndex = 4
		})
	}
end

local model6 = import.model("BillboardGui", basic.List)

function model6.init(data)
	local cost = data.Cost
	local robux = data.Robux
	local itemId = data.ItemId
	local item = data.Item or import3:getItem("Chair", itemId)
	local v3 = {
		BackgroundTransparency = 1,
		StudsOffset = Vector3.new(0, data.Height or 5.5, 0),
		Size = UDim2.new(7, 0, 7, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		AlwaysOnTop = true
	}
	local currencyLabel

	if data.Currency then
		currencyLabel = import.make(model3, {
			LayoutOrder = 0,
			Currency = data.Currency,
			Cost = cost
		}) or nil
	end

	local v4 = {
		CurrencyLabel = currencyLabel,
		PetIcon = data.Pet and import.make(model5, {
			LayoutOrder = 4,
			Pet = data.Pet,
			Currency = data.Currency
		}),
		RarityLabel = 0,
		ItemLabel = 0,
		CostLabel = 0
	}
	local rarityLabel

	if not data.Pet then
		rarityLabel = import.make(model, {
			Rarity = item.Rarity
		}) or nil
	end

	v4.RarityLabel = rarityLabel
	v4.ItemLabel = import.make(model2, {
		Text = item.DisplayName
	}) or nil
	local costLabel

	if not data.Pet then
		costLabel = import.make(model4, {
			Prompt = data.Prompt,
			Cost = cost or item.Cost,
			Id = itemId,
			Robux = robux
		}) or nil
	end

	v4.CostLabel = costLabel
	return v3, v4
end

return {
	ItemBillboard = model6
}