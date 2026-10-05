local createVector = vector.create
local import = _G.import("romodel")
local import2 = _G.import("rankData")
local import3 = _G.import("iconData")
local import4 = _G.import("configuration")
local import5 = _G.import("rankedState")
local import6 = _G.import("mathUtil")
game:GetService("CollectionService")
local import7 = _G.import("viewImports")
local basic = import7:get("basic")
local react = import7:get("react")
local LEVEL = import4.LEVEL
local model = import.model("UIStroke")

function model.init()
	return nil, {
		UIStroke = import.instance("UIStroke", nil, {
			UIGradient = import.instance("UIGradient")
		})
	}
end

local model2 = import.model(basic.TextLabel, react.LinkedText)

function model2.init(p)
	return {
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		StrokeColor = Color3.new(0, 0, 0),
		StrokeWidth = 0.05,
		StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
		KeyChains = { "Equip.Title", "Equip.Skin", "Statistics.XP" },
		Player = p.Player,
		TextSavedChanged = function(state, object)
			local v = object:get("Equip", "Skin", 1)
			local id = v and v.Config.Id

			if id then
				local clone = game.ReplicatedStorage.ReplicatedAssets.SkinTitles[id]:Clone()

				if clone.InnerStroke and clone.InnerStroke.UIStroke then
					local _ = clone.InnerStroke.UIStroke.UIGradient
				end

				import.apply(state, nil, {
					UIGradient = import.make(clone.UIGradient),
					UIStroke = import.make(clone.UIStroke),
					InnerStroke = import.make(model, {
						Instance = clone.InnerStroke
					})
				})
				state.FontFace = clone.FontFace
			end

			local equippedItemOfType = object:getEquippedItemOfType("Title", "Title")
			state.Visible = true
			local v2 = object:get("Equip", "Skin", 1)
			local id2 = v2 and v2.Config.Id
			state.Instance:SetAttribute("Skin", id2)
			local text = "Lvl." .. import6.xpToLevel(
				object.Statistics and object.Statistics.XP or 0,
				LEVEL.LEVEL_MAX_XP,
				LEVEL.LEVEL_XP_GROWTH
			)

			if equippedItemOfType then
				text = text .. " " .. equippedItemOfType.Value.DisplayName or text
			end

			if state.InnerStroke then
				state.InnerStroke.Text = text
			end

			return text
		end
	}
end

function model2.prespawn(p)
	p.Instance:AddTag("Sprite")
end

local model3 = import.model("Frame")

function model3.init(p)
	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.3333333333333333, 0, 0.3333333333333333, 0)
	}, {
		Icon = import.make(basic.ImageLabel, {
			Name = "Icon",
			BackgroundTransparency = 1,
			Location = "Center",
			Size = UDim2.fromScale(1, 1),
			Image = import3.Streak,
			ScaleType = Enum.ScaleType.Fit
		}),
		TextLabel = import.make(import.wrap(basic.TextLabel, react.LinkedText), {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.6, 0),
			Size = UDim2.new(0.65, 0, 0.65, 0),
			StrokeWidth = 2,
			KeyChains = { "Statistics.Streak" },
			Player = p.Player,
			TextSavedChanged = function(p2, p3)
				p2.Parent.Visible = p3.Statistics.Streak > 0
				return p3.Statistics.Streak
			end
		})
	}
end

function model3.prespawn(p)
	p.Instance:AddTag("HideNametagPartInGame")
end

local model4 = import.model("BillboardGui")

function model4.init(options)
	local v = options or {}
	local player = v.Player
	return {
		Name = "NameTag",
		AlwaysOnTop = true,
		MaxDistance = 75,
		Size = v.Size or UDim2.new(9, 0, 4.5, 0),
		StudsOffset = v.StudsOffset or createVector(0, 3.5, 0)
	}, {
		ListLayout = import.make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),
		Streak = import.make(model3, {
			LayoutOrder = 1,
			Player = player
		}),
		LevelTag = import.make(basic.EmptyList, {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, 0),
			Size = UDim2.new(1, 0, 0.15, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}, {
			RankIcon = import.make(import.wrap("ImageLabel", react.Reactive), {
				BackgroundTransparency = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				KeyChains = { "RankedData.Modes" },
				SavedChanged = function(p, object)
					local rankFromRating = import5.getRankFromRating(object:getPublicRating(2))
					p.Size = (rankFromRating == "Unranked" or rankFromRating == "Bronze" or rankFromRating == "Silver") and UDim2.new(
						0,
						0,
						0
					) or UDim2.new(1.35, 0, 1.35, 0)
					p.Image = import2[rankFromRating].Icon
				end,
				Player = player
			}),
			Level = import.make(model2, {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 2,
				Player = player,
				TextXAlignment = Enum.TextXAlignment.Left
			}) or nil
		}),
		DisplayName = import.make(basic.TextLabel, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.new(1, 0, 0.1, 0),
			Text = player and player.DisplayName or "Player",
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			StrokeWidth = 0.05,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			LayoutOrder = 3
		})
	}
end

function model4.spawn(p)
	p.LevelTag.Instance:AddTag("HideNametagPartInGame")
end

return {
	NameTag = model4
}