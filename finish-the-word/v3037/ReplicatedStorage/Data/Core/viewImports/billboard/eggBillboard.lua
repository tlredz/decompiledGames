local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("sync")
local import3 = _G.import("global")
local import4 = _G.import("event")
local import5 = _G.import("iconData")
_G.import("itemModules")
local import6 = _G.import("eggCollection")
local import7 = _G.import("iterUtil")
_G.import("dictUtil")
local import8 = _G.import("mathUtil")
local import9 = _G.import("viewImports")
local basic = import9:get("basic")
local react = import9:get("react")
local menu = import9:get("menu")
local petRewardFrame = import9:get("item").PetRewardFrame
local restrictedEggPopup = import9:get("restrictedEggPopup").RestrictedEggPopup
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local playerGui = not plugin and localPlayer.PlayerGui
local _ = game.ReplicatedStorage.ReplicatedAssets
local v = {
	Cash = "Cash1000",
	SpecialKey = "SpecialKey"
}
local model = import.model("BillboardGui")

function model.init(p)
	local v2 = not p.Cost and "??" or import8.formatNumber(p.Cost) or "??"
	return {
		Name = "EggPriceBillboard",
		StudsOffsetWorldSpace = createVector(0, 6, 0),
		Size = UDim2.new(6, 0, 1.3, 0)
	}, {
		CashLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(90, 255, 120),
			Font = Enum.Font.FredokaOne,
			Text = p.Prefix .. v2,
			StrokeWidth = 4
		})
	}
end

local model_2 = import.model("BillboardGui")

function model_2.init(p)
	local v2 = not p.Cost and "??" or import8.formatNumber(p.Cost) or "??"
	return {
		Name = "EggPriceBillboard",
		StudsOffsetWorldSpace = createVector(0, 6, 0),
		Size = UDim2.new(6, 0, 1.3, 0),
		MaxDistance = 40
	}, {
		CashLabel = import.make(basic.TextLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.fromRGB(90, 255, 120),
			Font = Enum.Font.FredokaOne,
			Text = p.Prefix .. v2,
			StrokeWidth = 4
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init(data)
	return {
		Position = UDim2.new(0, 0, -0.05, 0),
		AnchorPoint = Vector2.new(0, 1),
		Size = UDim2.new(0.5, 0, 0.2, 0),
		VerticalAlignment = data.VerticalAlignment or Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = data.HorizontalAlignment or Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0.05, 0)
	}, {
		CostLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.2, 0, 0.5, 0),
			Size = UDim2.new(0.35, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Text = data.Cost,
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeWidth = 3
		}),
		IconLabel = import.make(basic.ImageLabel, {
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0.8, 0, 0.9, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = import5[data.Currency]
		})
	}
end

local model3 = import.model(basic.EmptyElement, basic.ConstrainedElement)

function model3.init(p)
	local eggData = p.EggData
	return {
		Location = "Center",
		Size = UDim2.new(1, 0, 1, 0),
		AspectRatio = 1.5
	}, {
		UnlockButton = import.make(menu.Button, {
			Position = UDim2.new(0.5, 0, 0.75, 0),
			Size = UDim2.new(0.5, 0, 0.2, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Unlock",
			MouseButton1Down = function(_)
				import2.request("unlockEgg", nil, function(p2)
					if not p2 then
						return
					end

					if p2 == "Not enough cash" then
						import4.fire("openMenu", "Store", {
							PageId = "DeveloperProducts"
						})
					end

					import4.fire("signal", p2)
				end)(p.EggId)
			end
		}, {
			CostLabel = import.make(model2, {
				Position = UDim2.new(0.5, 0, -1.3, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				Cost = eggData.UnlockCost,
				Currency = "Cash"
			})
		})
	}
end

local model4 = import.model(basic.EmptyGrid)

function model4.init(p)
	local v2 = {}

	for k, reward in pairs(p.Rewards) do
		table.insert(v2, {
			Id = k,
			Chance = reward
		})
	end

	table.sort(v2, function(a, b)
		return a.Chance > b.Chance
	end)
	local result = {}

	for i, v3 in ipairs(v2) do
		result[i] = import.make(petRewardFrame, {
			Id = v3.Id,
			Chance = v3.Chance,
			ItemType = "Pet",
			LayoutOrder = i,
			Hoverable = true
		})
	end

	return {
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		CellPadding = UDim2.new(0.05, 0, 0.06, 0),
		CellSize = UDim2.new(0.2733333333333333, 0, 0.41, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, result
end

local model5 = import.model(basic.ImageButton, basic.Corner, basic.Stroke)

function model5.init(data)
	return {
		CornerRadius = UDim.new(0.225, 0),
		AspectRatio = 2,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0,
		StrokeWidth = 0.04,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		ImageColor3 = Color3.fromRGB(26, 255, 72),
		Image = "rbxassetid://120822935454304",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(2, 0, 4, 0),
		_Events = {
			MouseButton1Down = function(p)
				p.Parent.OnOpen(data.Count)
			end
		},
		MouseEnter = function(p)
			TweenService:Create(p.Instance, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1.1, 0, 1.1, 0)
			}):Play()
		end,
		MouseLeave = function(p)
			TweenService:Create(p.Instance, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 1, 0)
			}):Play()
		end
	}, {
		KeyLabel = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.8, 0, 0.5, 0),
			Text = data.Label,
			StrokeWidth = 2
		}),
		ActionLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0, 0, 0.8, 0),
			Size = UDim2.new(1, 0, 0.5, 0),
			Text = data.ActionLabel,
			StrokeWidth = 2,
			Visible = UserInputService.KeyboardEnabled
		})
	}
end

local v2 = {
	{
		Count = 1,
		Label = "Open 1",
		ActionLabel = "E",
		Key = Enum.KeyCode.E
	},
	{
		Count = 10,
		Label = "Open 10",
		ActionLabel = "R",
		Key = Enum.KeyCode.R
	}
}
local model6 = import.model(basic.EmptyList)

function model6.init(data)
	return {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 1.075, 0),
		Size = UDim2.new(1, 0, 0.2, 0),
		FillDirection = data.FillDirection or Enum.FillDirection.Horizontal,
		HorizontalAlignment = data.HorizontalAlignment or Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0.04, 0)
	}, import7.toDict(v2, function(layoutOrder, data2)
		return layoutOrder, import.make(model5, {
			Count = data2.Count,
			Label = data2.Label,
			ActionLabel = data.NoInput and "" or data2.ActionLabel,
			LayoutOrder = layoutOrder
		})
	end)
end

local model7 = import.model(basic.Corner, basic.Stroke)

function model7.init(data)
	local config = data.Config
	return {
		Position = UDim2.new(data.NoButtons and -0.05 or 1.02, 0, 1.05, 0),
		AnchorPoint = Vector2.new(data.NoButtons and 1 or 0, 0),
		Size = UDim2.new(0.65, 0, 0.32, 0),
		BackgroundColor3 = Color3.fromRGB(15, 15, 25),
		CornerRadius = UDim.new(0.08, 0),
		StrokeWidth = 2,
		StrokeColor = Color3.fromRGB(80, 80, 120),
		Visible = false
	}, {
		DescriptionLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			Location = "Center",
			Size = UDim2.new(0.92, 0, 0.88, 0),
			TextWrapped = true,
			StrokeWidth = 1,
			Text = "",
			RichText = true,
			KeyChains = { "Pity" },
			TextSavedChanged = function(_, p)
				if not config then
					return
				end

				local v3 = p.Pity and p.Pity[data.EggId]
				local v4 = not v3 and 0 or v3.Soft or 0
				local hard = v3 and v3.Hard or 0

				if hard < config.Soft then
					return "Roll <font color=\"#FFD700\">" .. config.Soft - v4 .. "</font> times and guarantee one of the 2 rarest pets!"
				end

				return "Roll <font color=\"#FFD700\">" .. config.Hard - hard .. "</font> times and guarantee the rarest pet!"
			end
		})
	}
end

local model8 = import.model(
	basic.ImageLabel,
	basic.ConstrainedElement,
	basic.Gradient,
	basic.Corner,
	basic.Stroke,
	react.Reactive
)

function model8.init(data)
	local eggData = data.EggData
	local eggId = data.EggId
	local pity = eggData.Pity
	local v3 = {
		AnchorPoint = data.AnchorPoint or Vector2.new(0.5, 0.5),
		Position = data.Position or UDim2.new(0.5, 0, 0.5, 0),
		CornerRadius = UDim.new(0.04, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0,
		AspectRatio = 1.5,
		StrokeWidth = 3,
		Image = "rbxassetid://120822935454304",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(1, 0, 1.5, 0),
		GradientColor = eggData.GradientColor or ColorSequence.new(
			Color3.fromRGB(191, 0, 255),
			Color3.fromRGB(49, 33, 171)
		),
		StrokeColor = Color3.fromRGB(0, 0, 0),
		KeyChains = { "Pity" },
		SavedChanged = function(p, p2)
			if not pity then
				return
			end

			local v4 = p2.Pity and p2.Pity[eggId]
			local v5 = not v4 and 0 or v4.Soft or 0
			local hard = v4 and v4.Hard or 0

			if hard < pity.Soft then
				p.PityLabel.Text = v5 .. " / " .. pity.Soft
				p.PityDesc.Text = "Normal Pity"
			else
				p.PityLabel.Text = hard .. " / " .. pity.Hard
				p.PityDesc.Text = "Secret Pity"
			end
		end
	}
	local costContainer

	if not data.NoButtons then
		costContainer = import.make(model2, {
			Cost = eggData.Cost,
			Currency = eggData.Currency
		}) or nil
	end

	local title

	if not data.NoButtons then
		title = import.make(basic.TextLabel, {
			Position = UDim2.new(1, 0, -0.05, 0),
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(0.5, 0, 0.2, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			StrokeWidth = 3,
			Text = eggData.DisplayName
		}) or nil
	end

	local v4 = {
		CostContainer = costContainer,
		Title = title,
		PityLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(data.NoButtons and 0 or 1, 0, 1.05, 0),
			AnchorPoint = Vector2.new(data.NoButtons and 0 or 1, 0),
			Size = UDim2.new(0.5, 0, 0.125, 0),
			TextXAlignment = Enum.TextXAlignment[data.NoButtons and "Left" or "Right"],
			StrokeWidth = 2,
			Text = "0/" .. pity.Soft or "?" .. "  ·  0/" .. pity.Hard or "?",
			_Events = {
				MouseEnter = function(p)
					p.Parent.PityTooltip.Visible = true
				end,
				MouseLeave = function(p)
					p.Parent.PityTooltip.Visible = false
				end
			}
		}),
		PityDesc = import.make(basic.TextLabel, {
			Position = UDim2.new(data.NoButtons and 0.25 or 1, 0, 1.19, 0),
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0.5, 0, 0.08, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = "Normal Pity",
			StrokeWidth = 2
		}),
		PityTooltip = import.make(model7, {
			Config = pity,
			EggId = eggId,
			NoButtons = data.NoButtons
		}),
		RewardList = import.make(model4, {
			Rewards = eggData.Pets
		}),
		Buttons = 0
	}
	local buttons

	if not data.NoButtons then
		buttons = import.make(model6) or nil
	end

	v4.Buttons = buttons
	return v3, v4
end

function model8:prespawn()
	if not self.Buttons then
		return
	end

	function self.Buttons.OnOpen(p)
		self:openEgg(p)
	end
end

function model8:openEgg(p2, callback, onClose)
	local eggId = self.EggId
	local v3 = import6:get(eggId)

	if not v3 then
		return
	end

	local v4 = nil
	local playerSession = import3.get("playerSession", localPlayer)

	if not playerSession then
		return
	end

	local arePaidRandomItemsRestricted = playerSession.Policies.ArePaidRandomItemsRestricted

	if arePaidRandomItemsRestricted then
		import.mount(import.make(restrictedEggPopup, {
			EggId = eggId
		}), playerGui)
		return
	end

	local playerSave = import3.get("playerSave", localPlayer)

	if not playerSave then
		return
	end

	if playerSave.Statistics[v3.Currency] < v3.Cost * p2 then
		local scrollToId = v[v3.Currency]
		local pageId = v3.Currency == "Cash" and "DeveloperProducts" or "Keys"
		import4.fire("openMenu", "Store", {
			PageId = pageId,
			ScrollToId = scrollToId
		})
		import4.fire("signal", v3.Currency == "Cash" and "Not enough cash" or "Not enough keys")
	elseif playerSave:hasPass(1862924369) or p2 == 1 or arePaidRandomItemsRestricted then
		import2.request("purchaseEgg", function(_, _, _)
			if callback then
				callback()
			end

			local eggOpeningOverlay = import9:get("eggOpeningOverlay").EggOpeningOverlay
			v4 = import.make(eggOpeningOverlay, {
				EggId = eggId,
				OnClose = onClose
			})
			import.mount(v4, playerGui)
		end, function(p4)
			if not p4 then
				return
			end

			import4.fire("signal", p4)

			if not v4 then
				return
			end

			v4.OnClose = nil
			v4:Destroy()
		end, function(p4)
			v4:setRewards(p4)
		end)(eggId, p2)
	else
		MarketplaceService:PromptGamePassPurchase(localPlayer, 1862924369)
	end
end

local model9 = import.model("BillboardGui", basic.Ui, react.Reactive)

function model9.init(p)
	local eggData = p.EggData
	local eggId = p.EggId
	local egg = import3.get("playerSave", localPlayer).Eggs[eggId]
	return {
		Name = "EggViewer",
		AlwaysOnTop = true,
		Active = true,
		Size = UDim2.new(10, 0, 10, 0),
		StudsOffsetWorldSpace = createVector(0, 5, 0),
		Scale = 1,
		AspectRatio = 1.777,
		Location = "Center",
		EggId = eggId,
		Content = {
			Main = egg and import.make(model8, {
				EggData = eggData,
				EggId = eggId
			}) or import.make(model3, {
				EggData = eggData,
				EggId = eggId
			})
		},
		KeyChains = { "Eggs" },
		SavedChanged = function(p2, p3)
			local egg2 = p3.Eggs[eggId]

			if p2.Content.Main then
				p2.Content.Main:Destroy()
			end

			import.apply(p2.Content, nil, {
				Main = egg2 and import.make(model8, {
					EggData = eggData,
					EggId = eggId
				}) or import.make(model3, {
					EggData = eggData,
					EggId = eggId
				})
			})
		end
	}
end

return {
	EggViewer = model9,
	PriceBillboard = model,
	Container = model8,
	CostContainer = model2,
	ButtonBar = model6
}