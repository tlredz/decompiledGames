local import = _G.import("romodel")
local import2 = _G.import("sync")
local import3 = _G.import("event")
local import4 = _G.import("global")
local import5 = _G.import("iconData")
local import6 = _G.import("itemModules")
local import7 = _G.import("eggCollection")
local import8 = _G.import("viewImports")
local basic = import8:get("basic")
local react = import8:get("react")
local menu = import8:get("menu")
local ux = import8:get("ux")
local petRewardFrame = import8:get("item").PetRewardFrame
local import9 = _G.import("mathUtil")
local localPlayer = game.Players.LocalPlayer
local replicatedAssets = game.ReplicatedStorage.ReplicatedAssets
local model = import.model(basic.ImageButton, basic.Corner, ux.Button)

function model.init(p)
	return {
		BackgroundColor3 = Color3.new(0, 0.560784, 0),
		CornerRadius = UDim.new(0.12, 0),
		AspectRatio = 3
	}, {
		Stroke = import.make(basic.Corner, {
			ZIndex = -1,
			Location = "Center",
			Size = UDim2.new(1.055, 0, 1.18, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			CornerRadius = UDim.new(0.19, 0)
		}),
		Inner = import.make(basic.Corner, {
			BackgroundColor3 = Color3.new(0, 1, 0),
			Size = UDim2.new(1, 0, 0.925, 0),
			CornerRadius = UDim.new(0.16, 0)
		}, {
			KeyIcon = import.make(basic.ImageLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.025, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Image = import5[p.Currency]
			}),
			TextLabel = import.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0.9, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Text = tostring(import9.formatNumber(p.Price) or "??"),
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 4
			})
		})
	}
end

local model2 = import.model(basic.EmptyElement, basic.Corner, basic.Stroke, react.Reactive)

function model2.init(p)
	local petId = p.PetId
	local eggId = p.EggId
	local v = import7:get(eggId)
	local item = import6:getItem("Pet", petId)
	local directPrice = item.DirectPrice
	local currency = v.Currency
	return {
		Position = UDim2.new(0.63, 0, 0.04, 0),
		Size = UDim2.new(0.34, 0, 0.92, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 25),
		CornerRadius = UDim.new(0.04, 0),
		StrokeThickness = 2,
		ZIndex = 2,
		KeyChains = { "Inventory.Pet", "Equip.Pet" },
		SavedChanged = function(object, object2)
			local has = object2:has("Inventory", "Pet", petId)
			local v2 = has and object2:getEquippedItemOfType("Pet", "Pet")
			local v3 = v2 and v2.Name == petId
			object:ClearReactiveChildren()
			return nil, {
				ActionButton = has and import.make(menu.Button, {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 0.96, 0),
					Size = UDim2.new(0.85, 0, 0.15, 0),
					ZIndex = 3,
					Text = v3 and "Unequip" or "Equip",
					MouseButton1Down = function()
						local equippedItemOfType = import4.get("playerSave", localPlayer):getEquippedItemOfType(
							"Pet",
							"Pet"
						)
						local v4 = equippedItemOfType and equippedItemOfType.Name == petId
						import3.remoteFire("toggleEquip", "Pet", petId, v4)
					end
				}) or import.make(model, {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.new(0.5, 0, 0.96, 0),
					Size = UDim2.new(0.85, 0, 0.15, 0),
					ZIndex = 3,
					Currency = currency,
					Price = directPrice,
					MouseButton1Down = function(p2)
						import2.request("buyRestrictedPet", nil, function(p3)
							if not (p3 and p3 == "Not enough " .. currency) then
								return
							end

							p2.Ui:Destroy()
							import3.fire("openMenu", "Store", {
								PageId = currency == "SpecialKey" and "Keys" or "DeveloperProducts"
							})
						end)(eggId, petId)
					end
				})
			}
		end
	}, {
		Viewport = import.make(petRewardFrame, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0.04, 0),
			Size = UDim2.new(0.82, 0, 0.48, 0),
			ItemType = "Pet",
			Id = petId
		}),
		NameLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.05, 0, 0.57, 0),
			Size = UDim2.new(0.9, 0, 0.12, 0),
			Text = item.DisplayName,
			StrokeWidth = 3,
			ZIndex = 3
		}),
		RarityLabel = import.make(import.wrap(basic.TextLabel, basic.Gradient), {
			Position = UDim2.new(0.05, 0, 0.69, 0),
			Size = UDim2.new(0.9, 0, 0.09, 0),
			Text = item.Rarity,
			GradientColor = replicatedAssets.Ui.Gradients[item.Rarity].Color,
			StrokeWidth = 2,
			ZIndex = 3
		})
	}
end

local model3 = import.model(basic.ImageButton)

function model3.init(p)
	return {
		Size = UDim2.new(0.285, 0, 0.285, 0),
		LayoutOrder = p.LayoutOrder,
		MouseButton1Down = function(p2)
			p2.Ui.Panel:selectPet(p.PetId)
		end
	}, {
		RewardFrame = import.make(petRewardFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			Id = p.PetId,
			ItemType = "Pet",
			Hoverable = true
		})
	}
end

local model4 = import.model(basic.ConstrainedElement, basic.Corner, basic.Stroke)

function model4.init(p)
	local v = import7:get(p.EggId)
	local v2 = {}

	for k, pet in pairs(v.Pets) do
		table.insert(v2, {
			Id = k,
			Chance = pet
		})
	end

	table.sort(v2, function(a, b)
		return a.Chance > b.Chance
	end)
	local v3 = {}

	for i, v4 in ipairs(v2) do
		v3[i] = import.make(model3, {
			PetId = v4.Id,
			LayoutOrder = i
		})
	end

	local id = v2[1] and v2[1].Id
	return {
		Location = "Center",
		AspectRatio = 1.5,
		Size = UDim2.new(0.6, 0, 0.8, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 35),
		CornerRadius = UDim.new(0.04, 0),
		StrokeWidth = 3,
		EggId = p.EggId
	}, {
		CloseButton = import.make(menu.XButton, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0.985, 0, 0.03, 0),
			Size = UDim2.new(0.07, 0, 0.11, 0),
			ZIndex = 10,
			MouseButton1Down = function(p2)
				p2.Ui:Destroy()
			end
		}),
		Grid = import.make(basic.EmptyGrid, {
			Position = UDim2.new(0.02, 0, 0.04, 0),
			Size = UDim2.new(0.58, 0, 0.92, 0),
			CellPadding = UDim2.new(0.03, 0, 0.04, 0),
			CellSize = UDim2.new(0.285, 0, 0.285, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}, v3),
		Detail = id and import.make(model2, {
			PetId = id,
			EggId = p.EggId
		}) or nil
	}
end

function model4:selectPet(petId)
	local detail = self.Detail

	if detail then
		detail:destroy()
	end

	import.apply(self, nil, {
		Detail = import.make(model2, {
			PetId = petId,
			EggId = self.EggId
		})
	})
end

local model5 = import.model("ScreenGui", basic.Ui)

function model5.init(p)
	return {
		IgnoreGuiInset = true,
		DisplayOrder = 6,
		Name = "RestrictedEggPopup"
	}, {
		Panel = import.make(model4, {
			EggId = p.EggId
		})
	}
end

return {
	RestrictedEggPopup = model5
}