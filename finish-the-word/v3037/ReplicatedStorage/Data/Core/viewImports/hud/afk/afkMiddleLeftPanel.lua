local import = _G.import("romodel")
local import2 = _G.import("iterUtil")
local import3 = _G.import("iconData")
local import4 = _G.import("rewardData")
local import5 = _G.import("viewImports")
local basic = import5:get("basic")
local react = import5:get("react")
import5:get("item")
local afkRewardPanel = import5:get("afkRewardPanel")
local model = import.model(basic.ImageLabel)

function model.init(p)
	local v = import4[p.Reward.Reward]
	return {
		Size = UDim2.new(0.3, 0, 0.3, 0),
		Image = import3[v.Icon]
	}, {
		AmountLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.1, 0),
			Size = UDim2.new(0.9, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = v.Amount,
			StrokeWidth = 1
		})
	}
end

local model2 = import.model(basic.EmptyElement, basic.ConstrainedElement)

function model2.init(data)
	return {
		Size = UDim2.new(1, 0, 1, 0),
		AspectRatio = 3.92857143
	}, {
		Background = import.make(basic.ImageLabel, {
			Location = "Center",
			Size = UDim2.new(1.4, 0, 1.4, 0),
			AspectRatio = 3.92857143,
			Image = "rbxassetid://133776942961966",
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = Color3.new(0, 0, 0)
		}),
		Icon = import.make(basic.ImageLabel, {
			Position = UDim2.new(0.075, 0, 0.54, 0),
			Size = UDim2.new(0.6, 0, 0.6, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://101239071338041"
		}),
		CurrencyLabel = import.make(import.wrap(basic.TextLabel, basic.Gradient, react.Reactive), {
			Location = "Center",
			Size = UDim2.new(0.83, 0, 0.45, 0),
			Text = "85,000",
			TextXAlignment = Enum.TextXAlignment.Right,
			GradientRotation = 90,
			GradientColor = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 38)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(12, 158, 90)),
				ColorSequenceKeypoint.new(0.85, Color3.fromRGB(0, 255, 128)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 81))
			}),
			StrokeWidth = 1,
			ZIndex = 5,
			KeyChains = data.KeyChains,
			SavedChanged = data.SavedChanged,
			SessionChanged = data.SessionChanged
		}),
		Subtitle = import.make(basic.TextLabel, {
			Position = UDim2.new(0, 0, -0.15, 0),
			Size = UDim2.new(1, 0, 0.4, 0),
			Text = data.Subtitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			StrokeWidth = 2,
			ZIndex = 5
		})
	}
end

local model3 = import.model(basic.Ui, basic.EmptyList)

function model3.init()
	return {
		Position = UDim2.new(0.013, 0, 0.37, 0),
		Size = UDim2.new(0.2, 0, 0.2, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0.1)
	}, {
		CashCurrency = import.make(model2, {
			Subtitle = "Cash",
			LayoutOrder = 1,
			KeyChains = { "Statistics" },
			SavedChanged = function(_, p)
				return {
					Text = p.Statistics.Cash
				}
			end
		}),
		CashCurrencyEarned = import.make(model2, {
			Subtitle = "Cash Earned",
			LayoutOrder = 2,
			KeyChains = { "AfkRewards" },
			SavedChanged = function(_, p)
				local total = 0

				for _, v in p.AfkRewards:pairs() do
					if typeof(v) ~= "table" then
						continue
					end

					local v2 = import4[v.Reward]

					if v2.Type == "Stat" and v2.Currency == "Cash" then
						total += v2.Amount or 1
					end
				end

				return {
					Text = total
				}
			end
		}),
		RewardsFrame = import.make(afkRewardPanel.RewardList, {
			Position = UDim2.new(0.5, 0, 0.06, 0),
			Size = UDim2.new(1, 0, 4, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			LayoutOrder = 3,
			Title = "Rewards Recieved",
			KeyChains = { "AfkRewards" },
			SavedChanged = function(object, p)
				object:ClearReactiveChildren()
				return nil, import2.toDict(p.AfkRewards:getTable(), function(p2, reward)
					return p2, import.make(model, {
						Reward = reward
					})
				end)
			end
		})
	}
end

return {
	MiddleLeftPanel = model3
}