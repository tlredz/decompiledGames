local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.Packages.ReactRoblox)
local Maid = require(ReplicatedStorage.Util.Maid)
local createElement = React.createElement
local TitleBar = require(script.TitleBar)
local PlayersFrame = require(script.PlayersFrame)
local Tile = require(script.Tile)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
require(game.ReplicatedStorage.Economy.ItemId)

local function DividerLine(_)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.75,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Position = UDim2.fromScale(0.498459, 0.508034),
		Size = UDim2.fromScale(0.949696, 0.00498073)
	})
end

local function ResultTextFrame(p)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.111935, 0.0672399),
		Rotation = -10,
		Size = UDim2.fromScale(0.283335, 0.096534)
	}, {
		brush = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://137145064370822",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1)
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.506923, 0.34131),
			Size = UDim2.fromScale(1, 1.14595),
			Text = p.resultText,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}, {
			victoryUIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
					ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
				})
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = 2
			}),
			defeatUIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 79, 79)),
					ColorSequenceKeypoint.new(0.222798, Color3.fromRGB(255, 80, 80)),
					ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 112, 112)),
					ColorSequenceKeypoint.new(0.806563, Color3.fromRGB(255, 80, 80)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 79, 79))
				}),
				Enabled = false
			})
		}),
		stat = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
			Position = UDim2.fromScale(0.525567, 1.03436),
			Size = UDim2.fromScale(0.786, 0.48),
			Text = p.matchTimeText,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 4.17924
		})
	})
end

local function MainFrame(p)
	local v = math.max(0, (math.floor(p.matchTime or 0)))
	local v2 = math.floor(v / 60)
	local v3 = v % 60
	local matchTimeText = string.format("%02d:%02d", v2, v3)
	local v5 = nil

	for _, allPlayer in pairs(p.allPlayers) do
		if not allPlayer.isMainPlayer then
			continue
		end

		v5 = allPlayer
		break
	end

	local state, setState = React.useState(v5.portraitUserId)
	local children2 = React.useMemo(function()
		local children = {}

		for _, allPlayer in p.allPlayers do
			if allPlayer.portraitUserId ~= state then
				continue
			end

			for _, v8 in pairs(allPlayer.Rewards or {
				{
					ItemId = math.random(100, 600),
					NetworkedUID = tostring(math.random(1000, 9999))
				},
				{
					Beli = 1,
					ItemId = math.random(100, 600),
					NetworkedUID = tostring(math.random(1000, 9999))
				},
				{
					Fragments = 324324,
					ItemId = math.random(100, 600),
					NetworkedUID = tostring(math.random(1000, 9999))
				},
				{
					SimulationData = 52,
					ItemId = math.random(100, 600),
					NetworkedUID = tostring(math.random(1000, 9999))
				},
				{
					Amount = 52,
					ItemId = 597,
					NetworkedUID = tostring(math.random(1000, 9999))
				}
			}) do
				if v8.Beli then
					local v9 = v8
					table.insert(children, (createElement(function()
						local ref = React.useRef({ nil })
						React.useLayoutEffect(function()
							local thread = task.spawn(function()
								local current = ref.current
								current.Icon.Size = UDim2.fromScale(1.2, 1.2)
								current.ImageColor3 = Color3.fromRGB(7, 199, 0)
								current.Count.Label.Text = tostring("$" .. TextUtil.commaValue(v9.Beli))
								current.Count.Gradient.Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 1)
								})
								current.Details.Visible = false
							end)
							return function()
								task.cancel(thread)
							end
						end, { state })
						local v12 = {
							DrawContext = "Default",
							ForcedQuantity = (typeof(v9.Beli) ~= "number" or not (v9.Beli and v9.Beli > 100)) and 100 or v9.Beli or 100,
							ref = ref,
							Variant = "Elevated",
							IsSelected = false,
							Info = 0
						}
						local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
						v12.Info = {
							ItemId = ItemId.getId("305K Money", "Redeemable"):unwrap(),
							NetworkedUID = nil
						}
						return createElement(Tile, v12)
					end, {})))
				elseif v8.SimulationData then
					local v9 = v8
					table.insert(children, (createElement(function()
						local ref = React.useRef({ nil })
						React.useLayoutEffect(function()
							local thread = task.spawn(function()
								local current = ref.current
								current.Icon.Size = UDim2.fromScale(0.8, 0.8)
								current.ImageColor3 = Color3.fromRGB(0, 196, 255)
								current.Count.Label.Text = tostring(TextUtil.commaValue(v9.SimulationData)) .. " Data"
								current.Count.Gradient.Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 1)
								})
								current.Details.Visible = false
							end)
							return function()
								task.cancel(thread)
							end
						end, { state })
						local v12 = {
							DrawContext = "Default",
							ForcedQuantity = v9.SimulationData,
							ref = ref,
							Variant = "Elevated",
							IsSelected = false,
							Info = 0
						}
						local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
						v12.Info = {
							ItemId = ItemId.getId("10000 Simulation Data", "Redeemable"):unwrap(),
							NetworkedUID = nil
						}
						return createElement(Tile, v12)
					end, {})))
				elseif v8.Fragments then
					local v9 = v8
					table.insert(children, (createElement(function()
						local ref = React.useRef({ nil })
						React.useLayoutEffect(function()
							local thread = task.spawn(function()
								local current = ref.current
								current.Count.Label.Text = tostring(TextUtil.commaValue(v9.Fragments))
								current.Count.Gradient.Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 1)
								})
								current.Details.Visible = false
							end)
							return function()
								task.cancel(thread)
							end
						end, { state })
						local v12 = {
							DrawContext = "Default",
							ForcedQuantity = v9.Fragments,
							ref = ref,
							Variant = "Elevated",
							IsSelected = false,
							Info = 0
						}
						local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
						v12.Info = {
							ItemId = ItemId.getId("4.5K Fragments", "Redeemable"):unwrap(),
							NetworkedUID = nil
						}
						return createElement(Tile, v12)
					end, {})))
				else
					local v9 = v8
					table.insert(children, (createElement(function()
						local ref = React.useRef({ nil })
						React.useLayoutEffect(function()
							local maid = Maid.new()
							maid:GiveTask(task.spawn(function() end))
							return function()
								maid:DoCleaning()
							end
						end, { state })
						local forcedQuantity

						if typeof(v9.Amount) == "number" then
							forcedQuantity = v9.Amount or nil
						end

						return createElement(Tile, {
							ForcedQuantity = forcedQuantity,
							ref = ref,
							Variant = "Elevated",
							DrawContext = "Default",
							IsSelected = false,
							Info = {
								ItemId = v9.ItemId,
								NetworkedUID = v9.NetworkedUID
							}
						})
					end, {})))
				end
			end
		end

		return children
	end, { state })
	local v10 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 0.11846),
		Size = UDim2.fromScale(1, 0.88154),
		ZIndex = 2
	}
	local v11 = {
		DividerLine = createElement(DividerLine, {}),
		Players = React.useMemo(function()
			return createElement(PlayersFrame, {
				allPlayers = p.allPlayers,
				updateSelectedPlayer = setState
			})
		end, { p.allPlayers, setState }),
		Result = React.useMemo(function()
			return createElement(ResultTextFrame, {
				resultText = "Victory!",
				matchTimeText = matchTimeText
			})
		end, { matchTimeText }),
		Rewards = 0,
		RewardTier = 0
	}
	local RewardsFrame = require(script.RewardsFrame)
	local v13 = {
		children = children2,
		Text = 0,
		BackgroundColor3 = 0
	}
	local text

	if state == v5.portraitUserId then
		text = "Rewards"
	else
		local flag = true
		local displayName

		for _, allPlayer in p.allPlayers do
			if allPlayer.portraitUserId ~= state then
				continue
			end

			displayName = allPlayer.displayName
			flag = false
			break
		end

		if flag then
			displayName = "Player"
		end

		text = `{displayName}'s Rewards`
	end

	v13.Text = text

	if state == v5.portraitUserId then
	end

	v13.BackgroundColor3 = Color3.fromRGB(18, 20, 21)
	v11.Rewards = createElement(RewardsFrame, v13)
	local rewardTier

	if v5.Tier then
		local RewardTier = require(script.RewardTier)
		rewardTier = createElement(RewardTier, {
			Tier = v5.Tier
		})
	end

	v11.RewardTier = rewardTier
	return createElement("Frame", v10, v11)
end

local function DungeonResultsUI(props)
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(23, 23, 23),
		BackgroundTransparency = 0.1,
		Position = UDim2.fromScale(0.499281, 0.499377),
		Size = UDim2.fromScale(0.9, 0.9),
		ZIndex = 2
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.01, 0)
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = 2
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.25522
		}),
		uISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(600, 600)
		}),
		Main = createElement(MainFrame, {
			allPlayers = props.allPlayers,
			matchTime = props.matchTime,
			onClose = props.onClose
		}),
		Title = createElement(TitleBar, {
			onClose = props.onClose
		})
	})
end

return DungeonResultsUI