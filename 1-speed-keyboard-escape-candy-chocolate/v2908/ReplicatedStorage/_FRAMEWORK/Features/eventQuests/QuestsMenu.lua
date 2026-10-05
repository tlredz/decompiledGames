local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Button = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.Button)
local ModalShell = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.ModalShell)
local ResetTimer = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.ResetTimer)
local QuestRow = require(script.Parent.QuestRow)
require(script.Parent.Types)
local create = Vide.create

local function QuestsMenu(data)
	local theme = data.Theme
	return ModalShell({
		Name = data.Name or "EventQuestsModal",
		Visible = data.Visible,
		Title = function()
			return theme().title
		end,
		TitleColor = function()
			return theme().titleColor
		end,
		TitleStrokeColor = function()
			return theme().titleStroke
		end,
		GradientColor = function()
			return theme().modalGradient
		end,
		StrokeColor = function()
			return theme().modalStroke
		end,
		BackgroundImageTransparency = function()
			return theme().modalPatternTransparency
		end,
		OnClose = data.OnClose
	}, { ResetTimer({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(0.4, 0.07),
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeColor = function()
				return theme().titleStroke
			end
		}), create("Frame")({
			Name = "QuestList",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.09),
			Size = UDim2.fromScale(1, 0.775),
			BackgroundTransparency = 1,
			create("UIListLayout")({
				Padding = UDim.new(0.02, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Vide.indexes(data.Quests, function(callback, layoutOrder: number)
				return QuestRow({
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1, 0.31),
					Theme = theme,
					RewardIcon = data.RewardIcon,
					Label = function()
						return callback().label
					end,
					Progress = function()
						return callback().progress
					end,
					Target = function()
						return callback().target
					end,
					Reward = function()
						return callback().reward
					end,
					State = function()
						return callback().state
					end,
					OnSkip = function()
						data.OnSkip(callback().id)
					end,
					OnClaim = function()
						data.OnClaim(callback().id)
					end
				})
			end)
		}), Button({
			Name = "RefreshButton",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.35, 0.11),
			Text = "REFRESH",
			Gradient = function()
				return theme().refreshGradient
			end,
			StrokeColor = function()
				return theme().refreshStroke
			end,
			OnActivated = data.OnRefresh
		}) })
end

return QuestsMenu