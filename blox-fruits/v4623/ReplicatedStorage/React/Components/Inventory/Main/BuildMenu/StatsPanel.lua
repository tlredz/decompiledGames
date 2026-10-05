local React = require(game.ReplicatedStorage.Packages.React)
local StatRow = require(script.StatRow)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useStats = require(game.ReplicatedStorage.React.Hooks.Item.useStats)
local useTrinkets = require(game.ReplicatedStorage.React.Hooks.Player.useTrinkets)
local useAccessory = require(game.ReplicatedStorage.React.Hooks.Player.useAccessory)
require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return function(_)
	local v, v2 = useAccessory()
	local v3 = useMatch(v)
	local v5

	if v3 then
		v5 = v3.Index.StorageKey
	end

	local v6 = useStats(v5, "Accessory", v2)
	local v7 = {}
	local titles = {}

	if v6 and v3 then
		table.insert(v7, v6)
		table.insert(titles, v3.Display.Title or v3.Display.Name or v3.Index.StorageKey)
	end

	local v8 = useTrinkets()
	local v9 = React.useMemo(function()
		if not v8 then
			return table.freeze({})
		end

		local v10 = {}

		for k, _ in v8 do
			table.insert(v10, k)
		end

		table.sort(v10)
		return table.freeze(v10)
	end, { v8 })
	local v10 = v9[1]
	local v11

	if v10 and v8 then
		v11 = v8[v10]
	end

	local v12 = v9[2]
	local v13

	if v12 and v8 then
		v13 = v8[v12]
	end

	local v14 = useMatch(v11)
	local v15 = useStats(v11, v10)

	if v15 and v14 then
		local title = v14.Display.Title or v14.Display.Name or v14.Index.StorageKey
		table.insert(v7, v15)
		table.insert(titles, title)
	end

	local v16 = useMatch(v13)
	local v17 = useStats(v13, v12)

	if v17 and v16 then
		local title = v16.Display.Title or v16.Display.Name or v16.Index.StorageKey
		table.insert(v7, v17)
		table.insert(titles, title)
	end

	local layoutOrder = 1
	local children = {}

	for k, v19 in v7 do
		if not (v19 ~= nil and #v19 ~= 0) then
			continue
		end

		local text = titles[k]
		layoutOrder += 1
		children["Label" .. tostring(k)] = createElement("Frame", {
			LayoutOrder = layoutOrder,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		}, {
			Label = createElement("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Bold),
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0, 0.1),
				Text = text,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextScaled = true,
				TextStrokeTransparency = 0.6
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingLeft = UDim.new(0.05, 0)
				})
			})
		})

		for k2, statValue in v19 do
			if statValue.Index.StatType == "Complex" then
				local count = 0

				for _, v22 in v19 do
					if v22.Index.StatType == "Complex" and v22.Index.Type == statValue.Index.Type then
						count += 1
					end
				end

				layoutOrder += 1
				children[`Stat{k}-{k2}` .. tostring(statValue.Index.StatType) .. "_" .. tostring(statValue.Index.Variant)] = createElement(
					StatRow,
					{
						LayoutOrder = layoutOrder,
						StatValue = statValue
					}
				)
			else
				layoutOrder += 1
				children[`Stat{k}-{k2}` .. tostring(statValue.Index.StatType)] = createElement(StatRow, {
					LayoutOrder = layoutOrder,
					StatValue = statValue
				})
			end
		end
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.999999, 4.16508e-8),
		Size = UDim2.fromScale(0.510946, 0.988126)
	}, {
		SubHeader = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(77, 77, 77),
			BorderColor3 = Color3.new(),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1.002, 0.09)
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.298879, 0.24375),
					NumberSequenceKeypoint.new(0.500623, 0.075),
					NumberSequenceKeypoint.new(0.699875, 0.2375),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			Title = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = Font.new(
					"rbxasset://fonts/families/HighwayGothic.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				Position = UDim2.fromScale(0.5, 0.565),
				Size = UDim2.fromScale(0.9, 0.825),
				Text = "Build Stats",
				TextColor3 = Color3.new(),
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1.7
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					FontFace = Font.new(
						"rbxasset://fonts/families/HighwayGothic.json",
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					Position = UDim2.fromScale(0.5, 0.44),
					Size = UDim2.fromScale(1, 1),
					Text = "Build Stats",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = 1.7
					})
				})
			})
		}),
		Stats = createElement("ScrollingFrame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.0945933),
			ScrollBarImageColor3 = Color3.fromRGB(217, 217, 217),
			ScrollBarThickness = 4,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.905)
		}, {
			UIListLayout = createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Container = createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			}, {
				UIListLayout = createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Rows = createElement(React.Fragment, {}, children)
			}),
			Block = createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1000,
				Size = UDim2.fromScale(1, 0.05)
			})
		})
	})
end