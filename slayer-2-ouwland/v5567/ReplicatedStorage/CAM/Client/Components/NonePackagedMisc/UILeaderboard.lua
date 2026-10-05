local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local Row = require(script.Row)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.85, 0),
	NumberSequenceKeypoint.new(1, 1)
})
return function(object, parent, data, p2: number, p3: number)
	local v = object:Create("Frame")
	local v2 = {
		Name = "Leaderboard",
		Parent = parent,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.2
	}
	local v3 = object:Create("UICorner")({
		CornerRadius = UDim.new(0.03)
	})
	local v4 = object:Create("UIGradient")({
		Rotation = 90,
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.45) })
	})
	local v5 = object:Create("UIStroke")({
		Thickness = 2,
		BorderOffset = UDim.new(0, -4),
		Color = Color3.new(1, 1, 1),
		Transparency = 0.75,
		object:Create("UIGradient")({
			Rotation = 140,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.5) })
		})
	})
	local v6 = object:Create("Frame")
	local v7 = {
		Name = "Holder",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.92),
		BackgroundTransparency = 1
	}
	local v8 = object:Create("UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8)
	})
	local v9 = object:Create("TextLabel")({
		Name = "Title",
		LayoutOrder = 1,
		Size = UDim2.fromScale(1, 0.09),
		BackgroundTransparency = 1,
		RichText = true,
		Text = `<b>{data.Title}</b>`,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = gameSettings.preferedFont,
		object:Create("UIStroke")({
			Thickness = 2,
			Transparency = 0.85
		})
	})
	local v10 = object:Create("TextLabel")({
		Name = "Season",
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0.045),
		BackgroundTransparency = 1,
		RichText = true,
		Text = data.Season,
		TextScaled = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = 0.35,
		FontFace = gameSettings.preferedFont
	})
	local v11 = object:Create("CanvasGroup")({
		Name = "RowsFade",
		LayoutOrder = 3,
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		object:Create("UIFlexItem")({
			FlexMode = Enum.UIFlexMode.Fill
		}),
		object:Create("UIGradient")({
			Rotation = 90,
			Transparency = numberSequence
		}),
		object:Create("ScrollingFrame")({
			Name = "Rows",
			ClipsDescendants = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 0,
			object:Create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			After = function(p4)
				object:Spawn(function()
					for i = 1, p3 do
						Row(object, data.Entries, p2 + i - 1, 10, p4)

						if i % 10 == 0 and i < p3 then
							task.wait()
						end
					end
				end)
			end
		})
	})
	local v12

	if data.Mine ~= nil then
		v12 = object:Create("Frame")({
			Name = "Mine",
			LayoutOrder = 4,
			Size = UDim2.fromScale(1, 0.08),
			BackgroundColor3 = Color3.new(0.1, 0.1, 0.1),
			BackgroundTransparency = 0.35,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("UIStroke")({
				BorderOffset = UDim.new(0, -4),
				Color = Color3.new(1, 1, 1),
				Transparency = 0.75
			}),
			object:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 6)
			}),
			object:Create("UIPadding")({
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 10)
			}),
			object:Create("ImageLabel")({
				Name = "Tier",
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.8, 0.8),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = data.MineIcon == nil and "" or data.MineIcon
			}),
			object:Create("TextLabel")({
				Name = "Txt",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 0.6),
				object:Create("UIFlexItem")({
					FlexMode = Enum.UIFlexMode.Fill
				}),
				BackgroundTransparency = 1,
				RichText = true,
				Text = object:Do(function(callback)
					local v13 = callback(data.Mine)
					local v14

					if data.MineRank ~= nil then
						v14 = callback(data.MineRank)
					end

					local v15

					if data.Share ~= nil then
						v15 = callback(data.Share)
					end

					local v16 = v13 == nil and "no score yet" or Utility.addCommasToNumber(v13)
					local v17

					if v14 == nil then
						v17 = v15 == nil and "" or `  Top {v15}%`
					else
						v17 = `  #{v14}`
					end

					return (`Your best  <b><font {gameSettings.RichTextPopularConfigs.SoroundColorRBX}>{v16}</font></b>{v17}`)
				end),
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = gameSettings.preferedFont,
				object:Create("UIStroke")({
					Thickness = 2,
					Transparency = 0.85
				})
			})
		})
	end

	v7[1], v7[2], v7[3], v7[4], v7[5] = v8, v9, v10, v11, v12
	do local _values = table.pack(v3, v4, v5, v6(v7)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end