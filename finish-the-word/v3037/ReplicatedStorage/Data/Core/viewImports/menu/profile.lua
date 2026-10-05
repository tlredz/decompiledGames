local localPlayer = game.Players.LocalPlayer
game:GetService("MarketplaceService")
local import = _G.import("romodel")
_G.import("iterator")
local import2 = _G.import("global")
local import3 = _G.import("event")
local import4 = _G.import("iconData")
_G.import("rewardData")
local import5 = _G.import("rankData")
local import6 = _G.import("rankedConstants")
local import7 = _G.import("rankedState")
_G.import("rankUtil")
local import8 = _G.import("configuration")
local import9 = _G.import("iterUtil")
_G.import("dictUtil")
local import10 = _G.import("mathUtil")
local import11 = _G.import("viewImports")
local basic = import11:get("basic")
local menu = import11:get("menu")
local ux = import11:get("ux")
local react = import11:get("react")
local rewardFrame = import11:get("item").RewardFrame
local searchBar = import11:get("searchBar").SearchBar
local LEVEL = import8.LEVEL
local _ = game.ReplicatedStorage.ReplicatedAssets
local _ = import6.RANK_BRACKETS
local fredokaOne = Enum.Font.FredokaOne
local v = {
	{
		PageId = "Profile",
		Label = "Profile",
		Icon = "Stats"
	}
}
local v2 = {
	{
		Id = "Lifetime",
		Label = "Lifetime",
		Labels = {
			{
				KeyChains = { "Statistics.Wins" },
				DisplayName = "Wins"
			},
			{
				KeyChains = { "Statistics.HighestStreak" },
				DisplayName = "Highest Streak"
			},
			{
				KeyChains = { "Playtime" },
				DisplayName = "Playtime",
				Format = import10.formatTime
			}
		}
	},
	{
		Id = "Monthly",
		Label = "Monthly",
		Labels = {
			{
				KeyChains = { "MonthlyData.Wins" },
				DisplayName = "Wins"
			},
			{
				KeyChains = { "MonthlyData.HighestStreak" },
				DisplayName = "Highest Streak"
			},
			{
				KeyChains = { "MonthlyData.CashEarned" },
				DisplayName = "Cash Earned"
			}
		}
	}
}

local function getNestedValue(p, value)
	for k in value:gmatch("[^%.]+") do
		if type(p) ~= "table" then
			return nil
		end

		p = p[k]
	end

	return p
end

local model = import.model(basic.ImageButton, basic.Corner, ux.Button)

function model.init(data)
	return {
		Scale = 1,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(0, 0, 0),
		_Events = {
			MouseButton1Down = function(p)
				p.Ui.Content.Main.Pages:open(data.PageId)
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
		InnerStroke = import.make(basic.Corner, {
			Location = "Center",
			CornerRadius = UDim.new(0.18, 0),
			Size = UDim2.new(0.89, 0, 0.89, 0),
			BackgroundColor3 = Color3.fromHSV(0.06975, 0.865034, 0.639216)
		}, {
			InnerColor = import.make(import.wrap(basic.Gradient, basic.Corner), {
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
		Icon = import.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(0.7, 0, 0.7, 0),
			Image = import4[data.Icon],
			Rotation = 6,
			ZIndex = 2
		}),
		ButtonLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.9, 0, 0.5, 0),
			Size = UDim2.new(2, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = data.Label,
			StrokeWidth = 2,
			Visible = false
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	return {
		Position = UDim2.new(1.03, 0, 0.113, 0),
		Size = UDim2.new(0.1, 0, 0.705, 0),
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.03, 0)
	}, import9.toDict(v, function(p, p2)
		return p, import.make(model, p2)
	end)
end

local model3 = import.model(basic.TextLabel)

function model3.init(_)
	return {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 1,
		StrokeWidth = 0.05,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}
end

local model4 = import.model(basic.TextLabel, basic.Gradient)

function model4.init(_)
	return {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0.2, 0),
		LayoutOrder = 2,
		StrokeWidth = 0.075,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		TextXAlignment = Enum.TextXAlignment.Left
	}
end

local model5 = import.model(basic.EmptyList)

function model5.init()
	local unranked = import5.Unranked
	return {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.01, 0)
	}, {
		RankIcon = import.make(basic.ImageLabel, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
			AspectRatio = 1,
			Image = unranked.Icon,
			ScaleType = Enum.ScaleType.Fit
		}),
		RankName = import.make(basic.TextLabel, {
			Size = UDim2.new(0, 0, 0.6, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Text = unranked.DisplayName,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Font = unranked.FontFace or fredokaOne,
			FontFace = unranked.FontFace,
			StrokeWidth = 0.08,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center
		})
	}
end

local model6 = import.model(basic.List)

function model6.init()
	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.82, 0, 1, 0),
		FillDirection = Enum.FillDirection.Vertical
	}, {
		NameRow = import.make(basic.EmptyList, {
			Size = UDim2.new(1, 0, 0.35, 0),
			LayoutOrder = 1,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0.01, 0)
		}, {
			NameLabel = import.make(model3),
			RankLabel = import.make(model5)
		}),
		UsernameLabel = import.make(model4, {
			LayoutOrder = 2
		})
	}
end

local model7 = import.model(basic.List)

function model7.init()
	return {
		Size = UDim2.new(1, 0, 0.35, 0),
		Padding = UDim.new(0.015, 0),
		BackgroundTransparency = 1
	}, {
		ProfileIcon = import.make(rewardFrame, {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0.35, 0, 1, 0),
			ItemType = "Player",
			NoInitialRig = true,
			LayoutOrder = 1
		}, {
			LevelLabel = import.make(basic.EmptyElement, {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1.03, 0),
				Size = UDim2.new(0.48, 0, 0.23, 0),
				ZIndex = 3
			}, {
				LevelLayer = import.make(import.wrap(basic.TextLabel, basic.Gradient, react.LinkedText), {
					Size = UDim2.new(1, 0, 1, 0),
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
					StrokeColor = Color3.new(0, 0, 0),
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					RichText = true,
					GradientRotation = 90,
					GradientColor = ColorSequence.new(
						Color3.fromHSV(0.16666666666666666, 1, 1),
						Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
					)
				}),
				NumberLayer = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
					Size = UDim2.new(1, 0, 1, 0),
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
					StrokeColor = Color3.new(0, 0, 0),
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					StrokeWidth = 0.12,
					RichText = true
				})
			})
		}),
		InfoFrame = import.make(model6, {
			LayoutOrder = 2
		})
	}
end

function model7:renderDisplayInfo(p2, p3, text, p4)
	local viewport = self.ProfileIcon.InnerStroke.InnerStroke2.Inner.Viewport

	if viewport then
		viewport:loadRig(p2 or localPlayer.UserId)
	end

	self.InfoFrame.NameRow.NameLabel.Text = text
	self.InfoFrame.UsernameLabel.Text = "@" .. p3
	local v3 = import5[import7.getHighestModeRank(p4)] or import5.Unranked
	self.InfoFrame.NameRow.RankLabel.RankIcon.Image = v3.Icon
	self.InfoFrame.NameRow.RankLabel.RankName.Text = v3.DisplayName
	self.InfoFrame.NameRow.RankLabel.RankName.TextColor3 = v3.Color or Color3.fromRGB(255, 255, 255)

	if v3.FontFace then
		self.InfoFrame.NameRow.RankLabel.RankName.FontFace = v3.FontFace
	else
		self.InfoFrame.NameRow.RankLabel.RankName.Font = fredokaOne
	end
end

local model8 = import.model("ImageButton", basic.Corner, basic.ConstrainedElement, basic.Gradient, basic.Stroke)

function model8.init()
	return {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0.3, 0, 0.3, 0),
		CornerRadius = UDim.new(0.1, 0),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		GradientColor = ColorSequence.new(
			Color3.fromHSV(0.16666666666666666, 1, 1),
			Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
		),
		GradientRotation = 90,
		StrokeWidth = 0.025,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		MouseButton1Down = function(p)
			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or import2.get("playerSession", localPlayer).Sitting then
				return
			end

			humanoidRootPart.CFrame = workspace.Meta.PetTeleport.CFrame
			p.Ui:Destroy()
		end
	}, {
		PlusLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0, 0, 0.09, 0),
			Size = UDim2.new(1, 0, 0.75, 0),
			Text = "+",
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.05
		})
	}
end

local model9 = import.model(basic.EmptyList, basic.Corner)

function model9.init()
	return {
		Size = UDim2.new(0.411, 0, 0.9, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, {
		Inner = import.make(basic.EmptyList, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Padding = UDim.new(0.04, 0),
			Wraps = true
		})
	}
end

function model9:renderPets(list, _)
	local v3 = {}

	for k, v4 in pairs(self.Inner._Children) do
		if k:match("^Pet") or k:match("^Slot") then
			table.insert(v3, v4)
		end
	end

	for _, v4 in ipairs(v3) do
		v4:Destroy()
	end

	local v4 = {}

	for i = 1, math.min(#list, 6) do
		local v5 = list[i]
		v4["Pet" .. i] = import.make(rewardFrame, {
			Size = UDim2.new(0.3, 0, 0.3, 0),
			Id = v5.Id,
			ItemType = "Pet",
			LayoutOrder = i,
			Hoverable = true
		})
	end

	for i = #list + 1, 6 do
		v4["Slot" .. i] = import.make(model8, {
			LayoutOrder = i
		})
	end

	import.apply(self.Inner, nil, v4)
end

local model10 = import.model(basic.Corner, basic.Stroke, basic.Gradient)

function model10.init(data)
	local v3 = data.KeyChains ~= nil
	local text = data.Value or 0
	local v4 = {
		Size = UDim2.new(0.98, 0, 0.2, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		CornerRadius = UDim.new(0.15, 0),
		StrokeWidth = 0.05,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		GradientRotation = 90,
		GradientColor = ColorSequence.new(
			Color3.fromHSV(0.16666666666666666, 1, 1),
			Color3.fromHSV(0.06944444444444445, 0.8627450980392157, 1)
		)
	}
	local v5 = {
		StatTitle = import.make(basic.TextLabel, {
			Size = UDim2.new(0.675, 0, 0.55, 0),
			Text = data.DisplayName or "Stat",
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.025, 0, 0.5, 0),
			StrokeWidth = 0.1,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}),
		StatValue = 0
	}
	local make = import.make
	local wrapped = import.wrap(basic.Stroke, basic.Corner, basic.Gradient)
	local v6 = {
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.new(1, 1, 1),
		GradientColor = ColorSequence.new(Color3.new(0.509804, 0.0196078, 1), Color3.new(0.670588, 0.00784314, 1)),
		GradientRotation = 90,
		RotSpeed = 90,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.98, 0, 0.5, 0),
		CornerRadius = UDim.new(0.2, 0),
		Size = UDim2.new(0.3, 0, 0.6, 0)
	}
	local make2 = import.make
	local wrapped2 = v3 and import.wrap(basic.TextLabel, react.LinkedText) or basic.TextLabel
	local v8 = {
		Location = "Center",
		Size = UDim2.new(1, 0, 0.8, 0),
		StrokeWidth = 0.1,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		KeyChains = data.KeyChains,
		TextSavedChanged = v3 and (function(_, value2)
			for k in data.KeyChains[1]:gmatch("[^%.]+") do
				if type(value2) == "table" then
					value2 = value2[k]
				else
					value2 = nil
					break
				end
			end

			local formatted = value2 or 0

			if data.Format then
				formatted = data.Format(formatted) or formatted
			end

			return formatted
		end or nil) or nil,
		Text = 0
	}

	if data.Format then
		text = data.Format(text) or text
	end

	v8.Text = text
	v5.StatValue = make(wrapped, v6, {
		Text = make2(wrapped2, v8)
	})
	return v4, v5
end

local model11 = import.model(basic.ScrollingList)

function model11.init()
	return {
		Size = UDim2.new(1, 0, 1, 0),
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.05, 0),
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}
end

local model12 = import.model(basic.ImageButton, basic.Corner)

function model12.init(data)
	return {
		Size = UDim2.new(0.48, 0, 1, 0),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = data.Selected and 0.2 or 0.6,
		CornerRadius = UDim.new(0.3, 0),
		NoAspectRatio = true,
		MouseButton1Down = function(p)
			p.Parent.Parent.Parent:selectTab(data.Id)
		end
	}, {
		TabLabel = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(0.9, 0, 0.7, 0),
			Text = data.Label,
			StrokeWidth = 3
		})
	}
end

local model13 = import.model(basic.EmptyList)

function model13.init()
	return {
		Position = UDim2.new(0.5, 0, -0.22, 0),
		Size = UDim2.new(0.94, 0, 0.16, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0.03, 0)
	}, import9.toDict(v2, function(layoutOrder, p2)
		return "Tab" .. layoutOrder, import.make(model12, {
			Id = p2.Id,
			Label = p2.Label,
			Selected = layoutOrder == 1,
			LayoutOrder = layoutOrder
		})
	end)
end

local model14 = import.model(basic.EmptyElement)

function model14.init()
	return {
		Size = UDim2.new(0.585, 0, 1, 0)
	}, {
		Inner = import.make(import.wrap(basic.Stroke, basic.Corner, basic.Gradient), {
			Location = "Center",
			BackgroundColor3 = Color3.new(1, 1, 1),
			GradientRotation = 90,
			GradientColor = ColorSequence.new(Color3.fromHSV(0.130722, 1, 1), Color3.fromHSV(0.0696944, 0.862745, 1)),
			Size = UDim2.new(0.96, 0, 0.9, 0),
			CornerRadius = UDim.new(0.05, 0),
			StrokeWidth = 0.0125,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}, {
			TabBar = import.make(model13),
			StatPages = import.make(menu.Pages, {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.96, 0, 0.96, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				DefaultPageId = v2[1].Id
			}, import9.toDict(v2, function(_, p)
				return p.Id, import.make(model11)
			end))
		})
	}
end

function model14:renderPage(object, list, p, p2)
	local v3 = {
		PadStart = import.make(basic.EmptyElement, {
			LayoutOrder = -999
		}),
		PadEnd = import.make(basic.EmptyElement, {
			LayoutOrder = 999
		})
	}

	for i, v4 in ipairs(list) do
		local v5 = "Stat" .. i
		local make = import.make
		local v7 = {
			DisplayName = v4.DisplayName,
			KeyChains = 0,
			Format = 0,
			Value = 0,
			LayoutOrder = 0
		}
		local keyChains

		if p2 then
			keyChains = v4.KeyChains or nil
		end

		v7.KeyChains = keyChains
		v7.Format = v4.Format
		local v9

		if not p2 then
			v9 = p

			for k in v4.KeyChains[1]:gmatch("[^%.]+") do
				if type(v9) == "table" then
					v9 = v9[k]
				else
					v9 = nil
					break
				end
			end

			if not v9 then
				v9 = nil
			end
		end

		v7.Value = v9
		v7.LayoutOrder = i
		v3[v5] = make(model10, v7)
	end

	object:ClearAllChildren("Frame")
	import.apply(object, nil, v3)
end

function model14:renderStats(p, p2)
	for _, v3 in ipairs(v2) do
		self:renderPage(self.Inner.StatPages[v3.Id], v3.Labels, p, p2)
	end

	self:selectTab(v2[1].Id)
end

function model14:selectTab(p2)
	self.Inner.StatPages:open(p2)

	for i, v3 in ipairs(v2) do
		self.Inner.TabBar["Tab" .. i].BackgroundTransparency = v3.Id == p2 and 0.2 or 0.6
	end
end

local model15 = import.model(basic.EmptyList)

function model15.init()
	return {
		Size = UDim2.new(1, 0, 0.6, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.015, 0)
	}, {
		PetContainer = import.make(model9),
		Stats = import.make(model14)
	}
end

local model16 = import.model(basic.EmptyList)

function model16.init()
	return {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.19, 0),
		Size = UDim2.new(0.94, 0, 0.81, 0),
		Padding = UDim.new(0.02, 0),
		FillDirection = Enum.FillDirection.Vertical
	}, {
		ProfileFrame = import.make(model7, {
			LayoutOrder = 1
		}),
		MainFrame = import.make(model15, {
			LayoutOrder = 2
		})
	}
end

local model17 = import.model(menu.MenuContainer)

function model17.init(p)
	return {
		Title = "Profile"
	}, {
		Pages = import.make(menu.Pages, {
			DefaultPageId = p.DefaultPageId or "Profile"
		}, {
			Profile = import.make(model16)
		}),
		PagesList = import.make(model2),
		SearchBar = import.make(searchBar, {
			Position = UDim2.new(0, 0, -0.16, 0),
			Size = UDim2.new(1, 0, 0.125, 0),
			AspectRatio = 8.00615385,
			Image = "rbxassetid://89935116127687",
			PlaceholderText = "Search...",
			InputPosition = UDim2.new(0.16, 0, 0.5, 0),
			InputSize = UDim2.new(0.8, 0, 0.6, 0),
			ZIndex = 3,
			OnEnterPressed = function(instance)
				local success, userIdFromNameAsync = pcall(
					game.Players.GetUserIdFromNameAsync,
					game.Players,
					instance.Text
				)

				if success then
					instance.Parent.Button.Visible = true
					instance.Ui:loadProfile(userIdFromNameAsync, true)
				else
					warn(userIdFromNameAsync)
					import3.fire("signal", "Player not found")
				end
			end
		}, {
			Button = import.make(menu.Button, {
				Position = UDim2.new(1.03, 0, 0.5, 0),
				Size = UDim2.new(0.3, 0, 0.7, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Text = "Back",
				Visible = false,
				MouseButton1Down = function(p2)
					p2.Visible = false
					p2.Ui:loadProfile()
				end
			})
		})
	}
end

local model18 = import.model("ScreenGui", basic.Ui)

function model18.init(p)
	return {
		IgnoreGuiInset = true,
		Name = "Profile",
		DisplayOrder = 5,
		Scale = 0.55,
		MinSize = 500,
		AspectRatio = 1.777,
		Location = "Center",
		Content = {
			Main = import.make(model17, {
				DefaultPageId = p.PageId
			})
		}
	}
end

function model18:prespawn()
	self:loadProfile()
end

function model18:loadProfile(p2, p3)
	local v3 = p2 or self.TargetUserId
	local v4 = not (v3 or p3)
	local v5

	if v3 or p3 then
		v5 = import3.remoteFire("fetchProfileData", v3)

		if not v5 then
			import3.fire("signal", "Player has not played yet")
			return
		end
	else
		local playerSave = import2.get("playerSave", localPlayer)

		if playerSave then
			v5 = playerSave:getTable()
		else
			import3.fire("signal", "Could not load profile")
			return
		end
	end

	local displayName, name

	if v4 then
		displayName = localPlayer.DisplayName
		name = localPlayer.Name
	else
		local success, nameFromUserIdAsync = pcall(game.Players.GetNameFromUserIdAsync, game.Players, v3)
		name = success and nameFromUserIdAsync or "Unknown"
		displayName = name
	end

	local pet = v5.Equip.Pet or {}
	local pet2 = v5.Inventory.Pet or {}
	local v6 = {}

	for _, v7 in pairs(pet) do
		v6[v7.Config.Id] = true
	end

	local v7 = {}

	for _, v8 in pairs(pet) do
		table.insert(v7, {
			Id = v8.Config.Id,
			Equipped = true
		})
	end

	for _, v8 in pairs(pet2) do
		if not v6[v8.Config.Id] then
			table.insert(v7, {
				Id = v8.Config.Id,
				Equipped = false
			})
		end
	end

	local profile = self.Container.Content.Main.Pages.Profile
	profile.ProfileFrame:renderDisplayInfo(v3, name, displayName, v5)
	profile.MainFrame.PetContainer:renderPets(v7)
	profile.MainFrame.Stats:renderStats(v5, v4)
	local XP = v5.Statistics and v5.Statistics.XP or 0
	local xpToLevel = import10.xpToLevel(XP, LEVEL.LEVEL_MAX_XP, LEVEL.LEVEL_XP_GROWTH)
	local levelLabel = profile.ProfileFrame.ProfileIcon.LevelLabel
	levelLabel.LevelLayer.Text = string.format("Lvl. <font transparency=\"1\">%s</font>", xpToLevel)
	levelLabel.NumberLayer.Text = string.format("<font transparency=\"1\">Lvl. </font>%s", xpToLevel)
end

return {
	Profile = model18
}