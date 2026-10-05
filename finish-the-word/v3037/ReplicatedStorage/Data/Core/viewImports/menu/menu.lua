local _ = game.Players.LocalPlayer
game:GetService("MarketplaceService")
local import = _G.import("sync")
local import2 = _G.import("romodel")
local import3 = _G.import("iterator")
_G.import("event")
local import4 = _G.import("clientUtil")
local import5 = _G.import("iconData")
local import6 = _G.import("rewardListData")
local import7 = _G.import("rewardData")
local import8 = _G.import("viewImports")
local basic = import8:get("basic")
local react = import8:get("react")
local ux = import8:get("ux")
local model = import2.model(basic.ImageButton, ux.Button)

function model.init()
	return {
		Image = "rbxassetid://139260875194032",
		MouseButton1Down = function(p)
			p.Ui.Container:tween(TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0.5, 0, -1, 0)
			})
			task.wait(0.2)
			p.Ui:Destroy()
		end
	}
end

local model2 = import2.model("ImageButton", basic.Corner, ux.Button)

function model2.init(data)
	return {
		BackgroundColor3 = data.ShadowColor or Color3.new(0, 0.560784, 0),
		Size = UDim2.new(0.25, 0, 0.25, 0),
		StrokeWidth = 5,
		CornerRadius = UDim.new(0.12, 0)
	}, {
		Stroke = import2.make(basic.Corner, {
			ZIndex = -1,
			Location = "Center",
			Size = UDim2.new(1.055, 0, 1.18, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			CornerRadius = UDim.new(0.19, 0)
		}),
		Inner = import2.make(basic.Corner, {
			BackgroundColor3 = data.Color or Color3.new(0, 1, 0),
			Size = UDim2.new(1, 0, 0.925, 0),
			CornerRadius = UDim.new(0.16, 0)
		}, data.Contents)
	}
end

local model3 = import2.model(model2)

function model3.init(data)
	return {
		Color = data.Color,
		ShadowColor = data.ShadowColor,
		Contents = {
			TextLabel = import2.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.85, 0, 0.8, 0),
				Text = data.Text,
				TextXAlignment = Enum.TextXAlignment.Center,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				StrokeWidth = 0.1
			})
		}
	}
end

local model4 = import2.model(model2)

function model4.init(p)
	return {
		Contents = {
			RobuxIcon = import2.make(basic.ImageLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.025, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Image = "rbxassetid://103861268601422"
			}),
			TextLabel = import2.make(basic.TextLabel, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0.9, 0, 0.5, 0),
				Size = UDim2.new(0.9, 0, 0.9, 0),
				Text = p.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
				StrokeWidth = 4
			})
		}
	}
end

local model5 = import2.model(basic.Corner)

function model5.init(p)
	return {
		BorderStrokePosition = Enum.BorderStrokePosition.Inner,
		CornerRadius = p.CornerRadius or UDim.new(0.03, 0)
	}, {
		Stroke = import2.make(basic.Corner, {
			BackgroundColor3 = Color3.new(0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			CornerRadius = p.CornerRadius or UDim.new(0.05, 0),
			ZIndex = -1
		})
	}
end

local model6 = import2.model("ImageLabel", basic.EmptyElement, basic.Corner)

function model6.prespawn(object)
	import4.sound("QuickTransition1")
	object:tween(TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
end

function model6.init(p)
	return {
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, -1, 0),
		Size = UDim2.new(1, 0, 1, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Vertical,
		Image = "rbxassetid://120822935454304",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0.5, 0, 0.8885, 0),
		CornerRadius = UDim.new(0.035, 0)
	}, {
		Gradient = import2.make("UIGradient", {
			Color = ColorSequence.new(
				Color3.fromHSV(0.16666666666666666, 1, 1),
				Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
			),
			Rotation = 90
		}),
		Title = import2.make(basic.TextLabel, {
			Position = UDim2.new(0.03, 0, 0.02, 0),
			Size = UDim2.new(1, 0, 0.15, 0),
			StrokeWidth = 0.06,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = p.Title
		}),
		XButton = import2.make(model, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(0.985, 0, 0.095, 0),
			Size = UDim2.new(0.14, 0, 0.14, 0)
		}),
		Stroke = import2.make(basic.Corner, {
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1.0140686550365785, 0, 1.025, 0),
			CornerRadius = UDim.new(0.045, 0),
			ZIndex = -1
		}, {
			Outer = import2.make(basic.Corner, {
				BackgroundColor3 = Color3.new(0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1.0140686550365785, 0, 1.025, 0),
				CornerRadius = UDim.new(0.055, 0),
				ZIndex = -1
			})
		})
	}
end

local model7 = import2.model(basic.Corner)

function model7.init(data)
	local v = import7[data.Id]
	return {
		BackgroundColor3 = Color3.new(0, 0, 0),
		CornerRadius = UDim.new(0.075, 0)
	}, {
		Inner = import2.make(basic.Corner, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Location = "Center",
			Size = data.QuestReward and UDim2.new(0.92, 0, 0.92, 0) or UDim2.new(0.935, 0, 0.94, 0),
			CornerRadius = UDim.new(0.06, 0)
		}, {
			Gradient = import2.make("UIGradient", {
				Color = v.Color or ColorSequence.new(
					Color3.new(0.509804, 0.0196078, 1),
					Color3.new(0.670588, 0.00784314, 1)
				)
			}),
			Title = import2.make(basic.TextLabel, {
				ZIndex = 2,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0.075, 0),
				Size = data.QuestReward and UDim2.new(0.95, 0, 0.5, 0) or UDim2.new(0.9, 0, 0.4, 0),
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				StrokeWidth = 0.1,
				Text = data.Amount and string.format("%s x%d", v.DisplayName, data.Amount) or v.DisplayName
			}),
			Icon = import2.make(basic.ImageLabel, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				Image = import5[v.Type == "Chair" and "Chair" or v.Icon]
			})
		})
	}
end

local model8 = import2.model(model5)

function model8.init(data)
	local contentX = data.ContentX or 0.01
	local itemsPositionY = data.ItemsPositionY or 0.95
	local v = {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.9, 0, 0.43, 0),
		CornerRadius = UDim.new(0.1, 0)
	}
	local v2 = {
		Inner = import2.make(basic.Corner, {
			BackgroundColor3 = Color3.new(1, 1, 1),
			CornerRadius = UDim.new(0.075, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.988, 0, 0.95, 0)
		}, import2.merge({
			Gradient = import2.make("UIGradient", {
				Color = ColorSequence.new(
					Color3.fromHSV(0.16666666666666666, 1, 1),
					Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
				),
				Rotation = 90
			}),
			Items = import2.make(basic.EmptyList, {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(contentX, 0, itemsPositionY, 0),
				Size = data.ItemsSize or UDim2.new(1, 0, 0.8, 0),
				Padding = UDim.new(0.025, 0)
			}, import3.mapArr(data.Rewards, function(p, p2)
				local make = import2.make
				local v4 = {
					Size = UDim2.new(1, 0, 1, 0),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Id = 0,
					Amount = 0,
					QuestReward = 0
				}
				local id

				if type(p2) == "table" then
					id = p2.Id or p2
				else
					id = p2
				end

				v4.Id = id
				local amount

				if type(p2) == "table" then
					amount = p2.Amount or nil
				end

				v4.Amount = amount
				v4.QuestReward = data.QuestRewards
				return p, make(model7, v4)
			end)),
			ClaimButton = import2.make(model3, {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(0.985, 0, 0.925, 0),
				Size = UDim2.new(0.2, 0, 0.3, 0),
				Text = data.ClaimText,
				MouseButton1Down = data.Claim or function()
					import.request("claimRewardList", function() end)(data.Id)
				end
			})
		}, data.InnerChildren or {})),
		TitleLabel = 0
	}
	local titleLabel

	if not data.HideTitle then
		titleLabel = import2.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.3, 0),
			Text = "",
			StrokeWidth = 3
		}) or nil
	end

	v2.TitleLabel = titleLabel
	return v, v2
end

local model9 = import2.model("ScrollingFrame")

function model9.init(p)
	return {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ScrollPosition = UDim2.new(0, 0, 0, 0),
		ScrollBarImageTransparency = 1
	}, {
		Inner = import2.make(basic.EmptyList, {
			Position = UDim2.new(0, 0, 0.05 / (p.CanvasHeight or 1), 0),
			Size = UDim2.new(1, 0, 1 / (p.CanvasHeight or 1), 0),
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.075, 0)
		}, import3.mapArr(p.Rewards, function(p2, id)
			return p2, import2.make(model8, {
				Id = id,
				Rewards = import6[id].Rewards
			})
		end))
	}
end

function model9:prespawn()
	local canvasHeight = self.CanvasHeight
	local RunService = game:GetService("RunService")
	self.Con = RunService.RenderStepped:Connect(function()
		local absoluteSize = self.Instance.AbsoluteSize
		self.CanvasSize = UDim2.new(0, 0, 0, absoluteSize.Y * (canvasHeight or 1))
	end)
end

function model9.despawn(p)
	p.Con:Disconnect()
end

local model10 = import2.model(basic.Element)

function model10.init(p)
	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0)
	}, {
		RewardScroll = import2.make(model9, {
			CanvasHeight = p.CanvasHeight,
			Rewards = p.Rewards
		}),
		Scrollbar = import2.make(import2.wrap(basic.Stroke, basic.Corner), {
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 12, 0.15, 0),
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216),
			Thickness = 3
		})
	}
end

function model10:prespawn()
	local instance = self.RewardScroll.Instance
	local scale = instance.Position.Y.Scale
	local instance2 = self.Scrollbar.Instance
	local scale2 = instance2.Size.Y.Scale
	local RunService = game:GetService("RunService")
	self.Con = RunService.RenderStepped:Connect(function()
		local v = instance.AbsoluteCanvasSize.Y - instance.AbsoluteWindowSize.Y
		local v2 = v > 0 and instance.CanvasPosition.Y / v or 1
		instance2.Position = UDim2.new(1, 0, scale + v2 * (1 - scale2) * 0.93, 0)
	end)
end

function model10.despawn(p)
	p.Con:Disconnect()
end

local model11 = import2.model(basic.EmptyElement)

function model11:hasExclam(p)
	for k in self:exclamItems(p) do
		if self:itemHasExclam(p, k) then
			return true
		end
	end

	return false
end

local model12 = import2.model(basic.EmptyElement)

function model12:getExclamKeyChains()
	local result = {}

	for _, v in ipairs(self:getExclamPages()) do
		for _, v2 in ipairs(v:getExclamKeyChains()) do
			table.insert(result, v2)
		end
	end

	return result
end

function model12:hasExclam(p)
	for _, v in ipairs(self:getExclamPages()) do
		if v:hasExclam(p) then
			return true
		end
	end

	return false
end

local model13 = import2.model("Frame", basic.ConstrainedElement, basic.Gradient)

function model13.init()
	return {
		AspectRatio = 1,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		GradientColor = ColorSequence.new(Color3.fromRGB(255, 50, 60), Color3.fromRGB(220, 0, 24)),
		GradientRotation = 90
	}, {
		Stroke = import2.make("UIStroke", {
			Color = Color3.new(0, 0, 0),
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.14
		}),
		TextLabel = import2.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.9, 0, 0.9, 0),
			StrokeColor = Color3.new(0, 0, 0),
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.12,
			Text = "!",
			TextColor3 = Color3.new(1, 1, 1)
		})
	}
end

local model14 = import2.model(basic.ImageButton, basic.Corner, ux.Button, react.Reactive)

function model14.init(data)
	return {
		Scale = 1,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		KeyChains = data.Page and data.Page:getExclamKeyChains(),
		SavedChanged = data.Page and function(p, p2)
			p.Exclam.Visible = data.Page:hasExclam(p2)
		end,
		_Events = {
			MouseButton1Down = function(p)
				if data.OpenPage then
					data.OpenPage(p, data.Id)
				else
					p.Ui.Content.Main.Pages:open(data.Id)
				end
			end,
			MouseEnter = function(p)
				p.ButtonLabel.Position = UDim2.new(1.15, 0, 0.5, 0)
				p.ButtonLabel.Visible = true
			end,
			MouseLeave = function(p)
				p.ButtonLabel.Visible = false
			end
		},
		CornerRadius = UDim.new(0.2, 0)
	}, {
		InnerStroke = import2.make(basic.Corner, {
			Location = "Center",
			CornerRadius = UDim.new(0.18, 0),
			Size = UDim2.new(0.89, 0, 0.89, 0),
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216)
		}, {
			InnerColor = import2.make(import2.wrap(basic.Gradient, basic.Corner), {
				Location = "Center",
				BackgroundColor3 = Color3.new(1, 1, 1),
				CornerRadius = UDim.new(0.18, 0),
				Size = UDim2.new(0.91, 0, 0.91, 0),
				GradientRotation = 90,
				GradientColor = ColorSequence.new(
					Color3.fromHSV(0.16666666666666666, 1, 1),
					Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
				)
			})
		}),
		Icon = import2.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Image = import5[data.Icon],
			Rotation = 6,
			ZIndex = 2
		}),
		ButtonLabel = import2.make(basic.TextLabel, {
			Position = UDim2.new(0.9, 0, 0.5, 0),
			Size = UDim2.new(2, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = data.Label,
			StrokeWidth = 2,
			Visible = false
		}),
		Exclam = data.Page and import2.make(model13, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.95, 0, 0.05, 0),
			Size = UDim2.new(0.35, 0, 0.35, 0),
			Visible = false,
			ZIndex = 3
		}) or nil
	}
end

local model15 = import2.model(basic.EmptyList)

function model15.init(p)
	return {
		Position = UDim2.new(1.03, 0, 0.113, 0),
		Size = UDim2.new(0.1, 0, 0.705, 0),
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.03, 0)
	}, import3.mapArr(p.Pages, function(p2, p3)
		return p2, import2.make(model14, p3)
	end)
end

local model16 = import2.model(basic.EmptyElement)

function model16.init()
	return {
		Size = UDim2.new(1, 0, 1, 0)
	}
end

function model16:open(selectedPage)
	self:closeAll()
	self[selectedPage].Visible = true
	self._selectedPage = selectedPage
end

function model16:closeAll()
	for _, child in pairs(self:GetChildren()) do
		child.Visible = false
	end
end

function model16:getOpenPage()
	return import3.values(self._Children):find(function(p2)
		return p2.Visible
	end)
end

function model16:spawn()
	self:open(self.DefaultPageId)
end

return {
	ExclamBadge = model13,
	MenuContainer = model6,
	PurchaseButton = model4,
	Button = model3,
	RoundedCorner = model5,
	Reward = model7,
	RewardList = model8,
	RewardPage = model10,
	Page = model11,
	Menu = model12,
	PageButton = model14,
	PagesList = model15,
	Pages = model16,
	XButton = model
}