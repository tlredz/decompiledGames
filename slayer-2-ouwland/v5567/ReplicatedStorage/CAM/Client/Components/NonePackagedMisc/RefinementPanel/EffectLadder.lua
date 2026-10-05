local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Refinement = require(ReplicatedStorage.CAM.Global.Refinement)
local faye = require(ReplicatedStorage.Packages.faye)
require(script.Parent.Types)
local v = {
	FishLuck = "Luck",
	["Additional Damage"] = "Damage",
	["Additional Damage Factor"] = "Dmg",
	["Block Points"] = "Block",
	["Block Regen"] = "Regen",
	["Max Health"] = "HP",
	["Movement Speed Factor"] = "Speed",
	["Stamina Regen Speed"] = "Stam"
}
local info = faye.Info(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.new(1, 0.803922, 0.305882)
local color2 = Color3.fromRGB(85, 170, 255)
local maxLevel = Refinement.MaxLevel
local v2 = (1 - (maxLevel - 1) * 0.008) / maxLevel
local v3 = 0.8712 / (5 * v2 + 0.032)
return function(object, p, flag: boolean)
	return object:State(function(callback, object2)
		local v4 = callback(p.Selected)
		local v5

		if v4 ~= 0 then
			v5 = Character_info_provider.GetItemFromId(Players.LocalPlayer, v4)
		end

		if v5 == nil then
			return object2:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1
			})
		end

		local name = v5.Name
		local activeToolStats = Items[name].ActiveToolStats or Items[name].Stats or {}
		local refineLevel = v5:FindFirstChild("RefineLevel")
		local v6 = refineLevel == nil and 0 or refineLevel.Value
		local refineStats = Refinement.GetRefineStats(name)

		local function rung(p2: number, _, object3)
			local v7 = {}

			for _, refineStat in refineStats do
				local v8 = v[refineStat] or refineStat
				local activeToolStat = activeToolStats[refineStat]
				local statMultiplier = Refinement.GetStatMultiplier(name, refineStat, p2)

				if typeof(activeToolStat) == "number" and activeToolStat ~= 0 then
					if string.find(refineStat, "Factor") == nil then
						local v9 = math.floor(activeToolStat * statMultiplier * 100 + 0.5) / 100
						table.insert(
							v7,
							(`{v8} {v9} (+{math.floor((v9 - math.floor(activeToolStat * 100 + 0.5) / 100) * 100 + 0.5) / 100})`)
						)
					else
						local v9 = math.floor(activeToolStat * statMultiplier * 1000 + 0.5) / 10
						table.insert(
							v7,
							(`{v8} {v9}% (+{math.floor((v9 - math.floor(activeToolStat * 1000 + 0.5) / 10) * 10 + 0.5) / 10}%)`)
						)
					end
				else
					table.insert(v7, (`{v8} x{statMultiplier}`))
				end
			end

			local v8 = p2 <= v6
			local v9 = p2 == v6 + 1
			local backgroundColor

			if maxLevel <= p2 then
				backgroundColor = color
			else
				backgroundColor = color2:Lerp(Color3.new(), 0.45):Lerp(color2, (p2 - 1) / (maxLevel - 1))
			end

			local v11 = object3:Create("Frame")
			local v12 = {
				Name = `Rung{p2}`,
				LayoutOrder = maxLevel - p2 + 1,
				Size = UDim2.fromScale(1, not flag and 0.08 or v2)
			}
			local backgroundColor2

			if v8 then
				backgroundColor2 = backgroundColor
			else
				backgroundColor2 = Color3.new()
			end

			v12.BackgroundColor3 = backgroundColor2
			v12.BackgroundTransparency = v8 and 0.55 or 0.72
			local v14 = object3:Create("UICorner")({
				CornerRadius = UDim.new(0, 4)
			})
			local v15

			if v9 then
				v15 = object3:Create("UIStroke")({
					Color = color,
					Thickness = 1.5,
					Transparency = 0.3
				})
			end

			local v16

			if v9 then
				v16 = object3:Create("Frame")({
					Name = "Ember",
					ZIndex = 2,
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = backgroundColor,
					BackgroundTransparency = object3:Animation(0.15, info, {
						From = 1
					}),
					object3:Create("UICorner")({
						CornerRadius = UDim.new(0, 4)
					})
				})
			end

			local v17 = object3:Create("TextLabel")
			local v18 = {
				Name = "Tag",
				ZIndex = 3,
				AnchorPoint = Vector2.new(0, 0.5)
			}
			local position

			if flag then
				position = UDim2.new(0, 6, 0.5, 0)
			else
				position = UDim2.new(0, 8, 0.5, 0)
			end

			v18.Position = position
			local size

			if flag then
				size = UDim2.new(0, 26, 0.72, 0)
			else
				size = UDim2.fromScale(0.2, 0.72)
			end

			v18.Size = size
			v18.BackgroundTransparency = 1
			v18.Text = `+{p2}`
			v18.TextScaled = true
			v18.TextXAlignment = Enum.TextXAlignment.Left
			v18.Font = Enum.Font.SourceSansBold
			v18.TextColor3 = Color3.new(1, 1, 1)
			v18.TextTransparency = (v8 or v9) and 0 or 0.45
			do local _values = table.pack(object3:Create("UITextSizeConstraint")({
	MaxTextSize = 18
}), object3:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.35
})); for _k = 1, _values.n do v18[_k] = _values[_k] end end
			local v21 = v17(v18)
			local v22 = object3:Create("TextLabel")
			local v23 = {
				Name = "Value",
				ZIndex = 3,
				AnchorPoint = Vector2.new(1, 0.5)
			}
			local position2

			if flag then
				position2 = UDim2.new(1, -6, 0.5, 0)
			else
				position2 = UDim2.new(1, -8, 0.5, 0)
			end

			v23.Position = position2
			local size2

			if flag then
				size2 = UDim2.new(1, -44, 0.62, 0)
			else
				size2 = UDim2.fromScale(0.72, 0.62)
			end

			v23.Size = size2
			v23.BackgroundTransparency = 1
			v23.Text = table.concat(v7, "\n")
			v23.TextScaled = true
			v23.TextXAlignment = Enum.TextXAlignment.Right
			local font

			if v9 then
				font = Enum.Font.SourceSansBold
			else
				font = Enum.Font.SourceSansSemibold
			end

			v23.Font = font
			v23.TextColor3 = Color3.new(1, 1, 1)
			v23.TextTransparency = (v8 or v9) and 0 or 0.42
			do local _values = table.pack(object3:Create("UITextSizeConstraint")({
	MaxTextSize = 14
}), object3:Create("UIStroke")({
	Thickness = 1.5,
	Transparency = 0.35
})); for _k = 1, _values.n do v23[_k] = _values[_k] end end
			do local _values = table.pack(v14, v15, v16, v21, v22(v23)); for _k = 1, _values.n do v12[_k] = _values[_k] end end
			return v11(v12)
		end

		local v7

		if flag then
			v7 = object2:Create("ScrollingFrame")({
				Name = "Rungs",
				Position = UDim2.fromScale(0, 0.12000000000000001),
				Size = UDim2.fromScale(1, 0.88),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 3,
				ScrollBarImageTransparency = 0.5,
				CanvasSize = UDim2.fromScale(0, v3),
				object2:Create("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.008, 0)
				}),
				object2:Create("UIPadding")({
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6)
				}),
				object2:Iterate(maxLevel, rung)
			})
		else
			v7 = nil
		end

		if v7 ~= nil then
			object2:Spawn(function()
				task.wait()
				local v8 = typeof(v7) == "Instance" and v7 or v7.Instance

				if v8 == nil then
					return
				end

				local v9 = (v2 + 0.008) * v8.AbsoluteCanvasSize.Y
				v8.CanvasPosition = Vector2.new(0, (math.max(0, (maxLevel - v6 - 2) * v9)))
			end)
		end

		local v8 = object2:Create("Frame")
		local v9 = {
			Name = "EffectLadder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		}
		local v10

		if not flag then
			v10 = object2:Create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0.012, 0)
			})
		end

		local v11 = object2:Create("TextLabel")({
			Name = "Header",
			LayoutOrder = 0,
			Size = UDim2.fromScale(1, flag and 0.1 or 0.06),
			BackgroundTransparency = 1,
			Text = "Per level",
			TextScaled = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.5
		})
		local v12

		if not flag then
			v12 = object2:Iterate(maxLevel, rung)
		end

		v9[1], v9[2], v9[3], v9[4] = v10, v11, v12, v7
		return v8(v9)
	end)
end