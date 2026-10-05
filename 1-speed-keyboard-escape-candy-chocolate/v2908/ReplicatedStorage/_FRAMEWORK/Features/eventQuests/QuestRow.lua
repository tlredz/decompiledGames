local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local Button = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.Button)
local VideUtil = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VideUtil)
require(script.Parent.Types)
local create = Vide.create
local read = VideUtil.read
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local rbxassetfontsfamiliesGothamSSmjson2 = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

local function QuestRow(data)
	local function theme()
		return read(data.Theme)
	end

	local function state()
		return read(data.State)
	end

	local function ratio()
		return (math.clamp(read(data.Progress) / math.max(read(data.Target), 1), 0, 1))
	end

	return create("Frame")({
		Name = data.Name or "QuestRow",
		LayoutOrder = data.LayoutOrder or 0,
		Size = data.Size or UDim2.fromScale(1, 0.31),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		create("UIGradient")({
			Color = function()
				return read(data.Theme).cardGradient
			end,
			Rotation = 90
		}),
		create("UIStroke")({
			Color = function()
				return read(data.Theme).cardStroke
			end,
			Thickness = 0.015,
			StrokeSizingMode = 1
		}),
		create("UICorner")({
			CornerRadius = UDim.new(0.1, 0)
		}),
		create("TextLabel")({
			Name = "QuestLabel",
			Position = UDim2.fromScale(0.03, 0.1),
			Size = UDim2.fromScale(0.57, 0.34),
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesGothamSSmjson,
			Text = data.Label,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			create("UIStroke")({
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 0.05,
				StrokeSizingMode = 1
			})
		}),
		create("Frame")({
			Name = "ProgressBar",
			Position = UDim2.fromScale(0.03, 0.56),
			Size = UDim2.fromScale(0.57, 0.3),
			BackgroundColor3 = function()
				return read(data.Theme).barColor
			end,
			BackgroundTransparency = 0.25,
			create("UICorner")({
				CornerRadius = UDim.new(0.5, 0)
			}),
			create("Frame")({
				Name = "Fill",
				Size = function()
					return UDim2.fromScale(math.clamp(read(data.Progress) / math.max(read(data.Target), 1), 0, 1), 1)
				end,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				create("UIGradient")({
					Color = function()
						return read(data.Theme).fillGradient
					end,
					Rotation = 90
				}),
				create("UICorner")({
					CornerRadius = UDim.new(0.5, 0)
				})
			}),
			create("TextLabel")({
				Name = "ProgressText",
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0, 0.1),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesGothamSSmjson2,
				Text = function()
					return read(data.Progress) .. "/" .. read(data.Target)
				end,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				ZIndex = 2,
				create("UIStroke")({
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 0.06,
					StrokeSizingMode = 1
				})
			})
		}),
		create("Frame")({
			Name = "Reward",
			Position = UDim2.fromScale(0.62, 0.25),
			Size = UDim2.fromScale(0.16, 0.5),
			BackgroundTransparency = 1,
			create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.04, 0),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			create("TextLabel")({
				Name = "RewardText",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.62, 1),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = function()
					return "+" .. Numbers.formatNumber(read(data.Reward))
				end,
				TextColor3 = function()
					return read(data.Theme).rewardTextColor
				end,
				TextScaled = true,
				create("UIStroke")({
					Color = Color3.fromRGB(0, 0, 0),
					Thickness = 0.05,
					StrokeSizingMode = 1
				})
			}),
			create("ImageLabel")({
				Name = "RewardIcon",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.34, 1),
				BackgroundTransparency = 1,
				Image = data.RewardIcon,
				ScaleType = Enum.ScaleType.Fit
			})
		}),
		create("Frame")({
			Name = "ButtonZone",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.8, 0.5),
			Size = UDim2.fromScale(0.17, 0.64),
			BackgroundTransparency = 1,
			Button({
				Name = "SkipButton",
				Text = "SKIP",
				Gradient = function()
					return read(data.Theme).skipGradient
				end,
				StrokeColor = function()
					return read(data.Theme).skipStroke
				end,
				Visible = function()
					return read(data.State) == "InProgress"
				end,
				OnActivated = data.OnSkip
			}),
			Button({
				Name = "ClaimButton",
				Text = "CLAIM",
				Gradient = function()
					return read(data.Theme).claimGradient
				end,
				StrokeColor = function()
					return read(data.Theme).claimStroke
				end,
				Visible = function()
					return read(data.State) == "Completed"
				end,
				OnActivated = data.OnClaim
			})
		}),
		create("Frame")({
			Name = "ClaimedOverlay",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.55,
			ZIndex = 3,
			Visible = function()
				return read(data.State) == "Claimed"
			end,
			create("UICorner")({
				CornerRadius = UDim.new(0.1, 0)
			}),
			create("TextLabel")({
				Name = "ClaimedCheck",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.8, 0.5),
				Size = UDim2.fromScale(0.17, 0.64),
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesGothamSSmjson,
				Text = "✓",
				TextColor3 = Color3.fromRGB(140, 255, 140),
				TextScaled = true,
				create("UIStroke")({
					Color = Color3.fromRGB(0, 60, 0),
					Thickness = 0.05,
					StrokeSizingMode = 1
				})
			})
		})
	})
end

return QuestRow