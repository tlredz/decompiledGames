game:GetService("ReplicatedStorage")
return function(object, list, p, value: string, flag: boolean?)
	local text = object:Value("")
	local value3 = object:Value()
	return object:Create("Frame")({
		Name = "Searchbar",
		Size = UDim2.fromScale(1, 1),
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
		object:Create("Frame")({
			Name = "IconHolder",
			Size = UDim2.fromScale(0.17, 1),
			BackgroundTransparency = 1,
			object:Create("ImageLabel")({
				Size = UDim2.fromScale(0.7, 0.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://17040049656",
				ImageTransparency = 0.25,
				ScaleType = Enum.ScaleType.Fit
			})
		}),
		object:Create("UIStroke")({
			Transparency = 0.95,
			Color = Color3.new(1, 1, 1)
		}),
		object:Create("Frame")({
			Name = "Textboxholder",
			Size = UDim2.fromScale(0.85, 0.6),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.15, 0.5),
			BackgroundTransparency = 1,
			object:Create("TextBox")({
				Name = "Textbox",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				PlaceholderText = value or "Item name here!",
				ClearTextOnFocus = false,
				object:SetTo(value3),
				function(p2)
					if p == nil then
						return
					end

					p2.Text = p.Value
					return {
						FocusLost = function(p3, p4)
							if p4 and text.Value ~= "" then
								p3.Text = text.Value
							end

							p.Value = p3.Text
							text:Set("")
						end
					}
				end,
				TextOnChanged = function(object2, value4: string)
					if not object2:IsFocused() then
						text:Set("")
						return
					end

					if flag == true and p ~= nil then
						p.Value = value4
					end

					local v = 9999
					local v2 = nil

					for i = 1, #list do
						local v3 = list[i]

						if not (value4 ~= "" and string.lower(value4) == string.sub(string.lower(v3), 0, #value4)) then
							continue
						end

						if not (#v3 < v) then
							continue
						end

						v = #v3
						v2 = v3
					end

					if v2 == nil then
						text:Set("")
					else
						text:Set(value4 .. string.sub(v2, #value4 + 1, #v2))
					end
				end
			}),
			object:Create("TextLabel")({
				Name = "AutoComplete",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				ZIndex = -1,
				Text = text,
				TextTransparency = 0.5,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		})
	}), value3:Get()
end