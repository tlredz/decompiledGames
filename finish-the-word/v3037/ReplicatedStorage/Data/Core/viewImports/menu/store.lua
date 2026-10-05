local localPlayer = game.Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("global")
local import4 = _G.import("event")
local import5 = _G.import("iconData")
_G.import("rewardData")
_G.import("iterUtil")
local import6 = _G.import("dictUtil")
local import7 = _G.import("viewImports")
local basic = import7:get("basic")
local react = import7:get("react")
local menu = import7:get("menu")
import7:get("ux")
local pages = {
	{
		Id = "GamePasses",
		Label = "Passes",
		Icon = "Time"
	},
	{
		Id = "Boosts",
		Label = "Boosts",
		Icon = "Potion"
	},
	{
		Id = "DeveloperProducts",
		Label = "Currency",
		Icon = "Cash"
	},
	{
		Id = "Keys",
		Label = "Keys",
		Icon = "SpecialKey"
	}
}
local v2 = {
	gamePasses = function(_)
		return {
			Vip = {
				ProductType = "Large",
				LayoutOrder = 1,
				ProductId = 1854105063,
				Type = Enum.InfoType.GamePass,
				Color = ColorSequence.new(Color3.new(0.509804, 0.0196078, 1), Color3.new(0.670588, 0.00784314, 1))
			},
			SpinFaster = {
				LayoutOrder = 2,
				ProductId = 1860766842,
				Type = Enum.InfoType.GamePass
			},
			Roll10x = {
				LayoutOrder = 3,
				ProductId = 1862924369,
				Type = Enum.InfoType.GamePass
			}
		}
	end,
	developerProducts = function()
		return {
			Cash800 = {
				LayoutOrder = 1,
				ProductId = 3601069119
			},
			Cash2000 = {
				LayoutOrder = 2,
				ProductId = 3596878075
			},
			Cash5000 = {
				LayoutOrder = 3,
				ProductId = 3596878436
			},
			Cash15000 = {
				LayoutOrder = 4,
				ProductId = 3596878448
			},
			Cash25000 = {
				LayoutOrder = 5,
				ProductId = 3601066646
			},
			TimeBoost = {
				LayoutOrder = 9,
				ProductId = 3598839294
			},
			TimeBoost10 = {
				LayoutOrder = 10,
				ProductId = 3598839604
			},
			TimeBoost80 = {
				LayoutOrder = 11,
				ProductId = 3598840201
			}
		}
	end,
	keys = function()
		return {
			SecretKey = {
				LayoutOrder = 6,
				ProductId = 3599608851
			},
			SecretKey10 = {
				LayoutOrder = 7,
				ProductId = 3599608848
			},
			SecretKey50 = {
				LayoutOrder = 8,
				ProductId = 3601067833
			}
		}
	end,
	boosts = function()
		return {
			CashBoost1hr = {
				LayoutOrder = 1,
				ProductId = 3601532792
			},
			CashBoost1day = {
				LayoutOrder = 2,
				ProductId = 3601532791
			},
			CashBoost1wk = {
				LayoutOrder = 3,
				ProductId = 3601532790
			},
			StreakBoost1hr = {
				LayoutOrder = 4,
				ProductId = 3601532138
			},
			StreakBoost1day = {
				LayoutOrder = 5,
				ProductId = 3601532137
			},
			StreakBoost1wk = {
				LayoutOrder = 6,
				ProductId = 3601532136
			},
			WinsBoost1hr = {
				LayoutOrder = 7,
				ProductId = 3601531474
			},
			WinsBoost1day = {
				LayoutOrder = 8,
				ProductId = 3601531475
			},
			WinsBoost1wk = {
				LayoutOrder = 9,
				ProductId = 3601531472
			}
		}
	end
}
local merged = nil
local model = import.model(basic.EmptyList)

function model.init(p)
	return {
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Size = UDim2.new(0.22, 0, 1, 0),
		Padding = UDim.new(0.06, 0)
	}, {
		Icon = import.make(basic.ImageLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Image = import5[p.Stat]
		}),
		Text = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			Size = UDim2.new(0.5, 0, 0.75, 0),
			StrokeWidth = 4,
			Text = "Hello",
			TextXAlignment = Enum.TextXAlignment.Left,
			KeyChains = { string.format("Statistics.%s", p.Stat) },
			TextSavedChanged = function(_, p2)
				return p2.Statistics[p.Stat]
			end
		})
	}
end

local model2 = import.model(menu.RoundedCorner, basic.ConstrainedElement, basic.Padding)

function model2.init(p)
	local v3 = merged[p.Id]
	local productId = v3.ProductId
	local v4 = {
		LayoutOrder = v3.LayoutOrder,
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(0.95, 0, 1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		ClipsDescendants = false,
		AspectRatio = 3.276243093922652,
		CornerRadius = UDim.new(0.09, 0)
	}
	local make = import.make
	local corner = basic.Corner
	local v6 = {
		Position = UDim2.new(0, 0, -0.025, 0),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 1.05, 0),
		CornerRadius = UDim.new(0.03, 0)
	}
	local v7 = {
		ImageLabel = import.make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://110983256742954",
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 1
		}),
		Gradient = import.make("UIGradient", {
			Color = v3.Color
		}),
		Description = import.make(basic.TextLabel, {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.025, 0, 0.4, 0),
			Size = UDim2.new(1, 0, 0.525, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeWidth = 3
		}),
		ButtonList = 0
	}
	local make2 = import.make
	local emptyList = basic.EmptyList
	local v8 = {
		Position = UDim2.new(0.125, 0, 1.05, 0),
		Size = UDim2.new(0.9, 0, 0.2, 0),
		AnchorPoint = Vector2.new(0, 1),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0.3, 0)
	}
	local seeSkinsButton

	if p.Id == "Vip" then
		seeSkinsButton = import.make(menu.Button, {
			Size = UDim2.new(0.25, 0, 1, 0),
			Text = "See Skins",
			ZIndex = 4,
			MouseButton1Down = function(p2)
				local playerSession = import3.get("playerSession", localPlayer)

				if not playerSession then
					return
				end

				if playerSession.Sitting then
					import4.fire("signal", "You cannot do that while seated")
					return
				end

				p2.Ui:Destroy()
				import4.fire("openShop")
				import4.fire("setShopTab", "Skins")
			end
		}) or nil
	end

	v7.ButtonList = make2(emptyList, v8, {
		SeeSkinsButton = seeSkinsButton,
		Button = import.make(menu.PurchaseButton, {
			Size = UDim2.new(0.25, 0, 1, 0),
			ZIndex = 4,
			LayoutOrder = 2,
			MouseButton1Down = function()
				MarketplaceService:PromptGamePassPurchase(localPlayer, productId)
			end
		})
	})
	return v4, {
		Inner = make(corner, v6, v7)
	}
end

function model2.prespawn(p)
	task.defer(function()
		local productInfo = MarketplaceService:GetProductInfo(merged[p.Id].ProductId, Enum.InfoType.GamePass)
		p.Inner.ButtonList.Button.Inner.TextLabel.Text = productInfo.PriceInRobux
	end)
end

local model3 = import.model(basic.EmptyElement)

function model3.init(p)
	local v3 = merged[p.Id]
	local productId = v3.ProductId
	return {
		LayoutOrder = v3.LayoutOrder,
		Size = v3.Size or UDim2.new(0.27359999999999995, 0, 0.3135, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXX
	}, {
		Button = import.make(menu.PurchaseButton, {
			ZIndex = 5,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0.975, 0, 1, 0),
			Size = UDim2.new(0.75, 0, 0.25, 0),
			MouseButton1Down = function()
				if v3.Type == Enum.InfoType.GamePass then
					MarketplaceService:PromptGamePassPurchase(localPlayer, productId)
				else
					MarketplaceService:PromptProductPurchase(localPlayer, productId)
				end
			end
		})
	}
end

function model3.prespawn(p)
	task.defer(function()
		local v3 = merged[p.Id]
		local productId = v3.ProductId
		local type = v3.Type or Enum.InfoType.Product
		local productInfo = MarketplaceService:GetProductInfo(productId, type)
		p.Button.Inner.TextLabel.Text = productInfo and productInfo.PriceInRobux or "??"
		import.apply(p, nil, {
			InnerReward = import.make(menu.Reward, {
				Location = "Center",
				Size = UDim2.new(1, 0, 0.9, 0),
				Id = p.Id
			})
		})
	end)
end

local model4 = import.model("ScrollingFrame", basic.Corner)

function model4.init(p)
	return {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.03, 0, 0.21, 0),
		Size = UDim2.new(0.94, 0, 0.794, 0),
		ScrollPosition = UDim2.new(0, 0, 0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 12,
		ScrollBarImageColor3 = Color3.new(0, 0, 0),
		ScrollBarImageTransparency = 1
	}, {
		Inner = import.make(import.wrap(basic.Corner, basic.List), {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.5627462014631401, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Wraps = true,
			Padding = UDim.new(0.04, 0),
			ScrollPosition = UDim2.new(0, 0, 0, 0)
		}, import2.mapArr(p.Products, function(id, p3)
			return id, import.make(p3.ProductType and model2 or model3, {
				Id = id,
				InfoType = p.InfoType
			})
		end))
	}
end

function model4:prespawn()
	if self.SizeCon then
		return
	end

	local uIListLayout = self.Inner.Instance:FindFirstChildOfClass("UIListLayout")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local Y = uIListLayout.AbsoluteContentSize.Y
		self.Inner.Instance.Size = UDim2.new(1, 0, 0, Y)
		self.Instance.CanvasSize = UDim2.new(0, 0, 0, Y + 16)
	end

	self.SizeCon = uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
	task.spawn(function()
		if not self.ScrollToId then
			return
		end

		task.wait(0.1)
		local child = self.Inner.Instance:FindFirstChild(self.ScrollToId)

		if not child then
			return
		end

		local v3 = child.AbsolutePosition.Y - self.Instance.AbsolutePosition.Y
		self.Instance.CanvasPosition = Vector2.new(0, v3)
	end)
end

function model4:despawn()
	if not self.SizeCon then
		return
	end

	self.SizeCon:Disconnect()
	self.SizeCon = nil
end

local model5 = import.model(menu.MenuContainer)

function model5.init(p)
	local playerSave = import3.get("playerSave", localPlayer)
	local gamePasses = v2.gamePasses(playerSave)
	local developerProducts = v2.developerProducts(playerSave)
	local boosts = v2.boosts(playerSave)
	local keys = v2.keys(playerSave)
	merged = import6.merge(gamePasses, developerProducts, boosts, keys)
	return {
		Title = "Store"
	}, {
		Pages = import.make(menu.Pages, {
			DefaultPageId = p.DefaultPageId or "GamePasses"
		}, {
			GamePasses = import.make(model4, {
				Products = gamePasses,
				InfoType = Enum.InfoType.GamePass
			}),
			DeveloperProducts = import.make(model4, {
				Products = developerProducts,
				InfoType = Enum.InfoType.Product,
				ScrollToId = p.ScrollToId
			}),
			Boosts = import.make(model4, {
				Products = boosts,
				InfoType = Enum.InfoType.Product,
				ScrollToId = p.ScrollToId
			}),
			Keys = import.make(model4, {
				Products = keys,
				InfoType = Enum.InfoType.Product,
				ScrollToId = p.ScrollToId
			})
		}),
		PagesList = import.make(menu.PagesList, {
			Pages = pages
		}),
		Scrollbar = import.make(import.wrap(basic.Stroke, basic.Corner), {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 12, 0.15, 0),
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216),
			Thickness = 3
		}),
		Currencies = import.make(basic.EmptyList, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, -0.05, 0),
			Size = UDim2.new(1, 0, 0.125, 0),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 0)
		}, {
			TimeBoostLabel = import.make(model, {
				Stat = "TimeBoost",
				LayoutOrder = 1
			}),
			SpecialKeyLabel = import.make(model, {
				Stat = "SpecialKey",
				LayoutOrder = 2
			})
		})
	}
end

function model5:prespawn()
	local RunService = game:GetService("RunService")
	self.Con = RunService.RenderStepped:Connect(function()
		local openPage = self.Pages:getOpenPage()

		if not openPage then
			return
		end

		local Y = openPage.CanvasPosition.Y
		local Y2 = openPage.AbsoluteCanvasSize.Y
		local Y3 = openPage.AbsoluteSize.Y

		if Y2 == 0 then
			return
		end

		local scale = openPage.Position.Y.Scale
		local scale2 = openPage.Size.Y.Scale
		local v3 = math.min(1, Y3 / Y2)
		self.Scrollbar.Visible = v3 < 0.95
		self.Scrollbar.Size = UDim2.new(0, 12, scale2 * v3, 0)
		self.Scrollbar.Position = UDim2.new(0.97, 0, scale + Y / Y2 * scale2, 0)
	end)
end

function model5.despawn(p)
	p.Con:Disconnect()
end

local model6 = import.model("ScreenGui", basic.Ui)

function model6.init(p)
	import3.get("playerSave", localPlayer)
	return {
		IgnoreGuiInset = true,
		Name = "Store",
		DisplayOrder = 5,
		Scale = 0.55,
		MinSize = 500,
		AspectRatio = 1.777,
		Location = "Center",
		Content = {
			Main = import.make(model5, {
				DefaultPageId = p.PageId,
				ScrollToId = p.ScrollToId
			})
		}
	}
end

return {
	Store = model6
}