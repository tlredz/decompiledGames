local createVector = vector.create
require(script.Parent.Parent.Types)
return function(data, data2)
	local numberChanged = {
		Init = function(_) end,
		Get = function(p)
			return p.lastNumberChangedTick == data._cycleTick
		end
	}

	local function getValueByIndex(data3, p: number, arguments)
		local typeName = typeof(data3)

		if typeName == "number" then
			return data3
		end

		if typeName == "Vector2" then
			if p == 1 then
				return data3.X
			elseif p == 2 then
				return data3.Y
			end
		elseif typeName == "Vector3" then
			if p == 1 then
				return data3.X
			elseif p == 2 then
				return data3.Y
			elseif p == 3 then
				return data3.Z
			end
		elseif typeName == "UDim" then
			if p == 1 then
				return data3.Scale
			elseif p == 2 then
				return data3.Offset
			end
		elseif typeName == "UDim2" then
			if p == 1 then
				return data3.X.Scale
			elseif p == 2 then
				return data3.X.Offset
			elseif p == 3 then
				return data3.Y.Scale
			elseif p == 4 then
				return data3.Y.Offset
			end
		elseif typeName == "Color3" then
			local v2 = arguments.UseHSV and { data3:ToHSV() } or { data3.R, data3.G, data3.B }

			if p == 1 then
				return v2[1]
			elseif p == 2 then
				return v2[2]
			elseif p == 3 then
				return v2[3]
			end
		elseif typeName == "Rect" then
			if p == 1 then
				return data3.Min.X
			elseif p == 2 then
				return data3.Min.Y
			elseif p == 3 then
				return data3.Max.X
			elseif p == 4 then
				return data3.Max.Y
			end
		elseif typeName == "table" then
			return data3[p]
		end

		error((`Incorrect datatype or value: {data3} {typeof(data3)} {p}.`))
	end

	local function updateValueByIndex(value, p: number, p2: number, arguments)
		if typeof(value) == "number" then
			return p2
		end

		if typeof(value) == "Vector2" then
			if p == 1 then
				return (Vector2.new(p2, value.Y))
			elseif p == 2 then
				return (Vector2.new(value.X, p2))
			end
		elseif typeof(value) == "Vector3" then
			if p == 1 then
				return (Vector3.new(p2, value.Y, value.Z))
			elseif p == 2 then
				return (Vector3.new(value.X, p2, value.Z))
			elseif p == 3 then
				return (Vector3.new(value.X, value.Y, p2))
			end
		elseif typeof(value) == "UDim" then
			if p == 1 then
				return (UDim.new(p2, value.Offset))
			elseif p == 2 then
				return (UDim.new(value.Scale, p2))
			end
		elseif typeof(value) == "UDim2" then
			if p == 1 then
				return (UDim2.new(UDim.new(p2, value.X.Offset), value.Y))
			elseif p == 2 then
				return (UDim2.new(UDim.new(value.X.Scale, p2), value.Y))
			elseif p == 3 then
				return (UDim2.new(value.X, UDim.new(p2, value.Y.Offset)))
			elseif p == 4 then
				return (UDim2.new(value.X, UDim.new(value.Y.Scale, p2)))
			end
		elseif typeof(value) == "Rect" then
			if p == 1 then
				return (Rect.new(Vector2.new(p2, value.Min.Y), value.Max))
			elseif p == 2 then
				return (Rect.new(Vector2.new(value.Min.X, p2), value.Max))
			elseif p == 3 then
				return (Rect.new(value.Min, Vector2.new(p2, value.Max.Y)))
			elseif p == 4 then
				return (Rect.new(value.Min, Vector2.new(value.Max.X, p2)))
			end
		elseif typeof(value) == "Color3" then
			if arguments.UseHSV then
				local HSV, v2, v3 = value:ToHSV()

				if p == 1 then
					return (Color3.fromHSV(p2, v2, v3))
				elseif p == 2 then
					return (Color3.fromHSV(HSV, p2, v3))
				elseif p == 3 then
					return (Color3.fromHSV(HSV, v2, p2))
				end
			end

			if p == 1 then
				return (Color3.new(p2, value.G, value.B))
			elseif p == 2 then
				return (Color3.new(value.R, p2, value.B))
			elseif p == 3 then
				return (Color3.new(value.R, value.G, p2))
			end
		end

		error((`Incorrect datatype or value {value} {typeof(value)} {p}.`))
	end

	local v2 = {
		Num = { 1 },
		Vector2 = { 1, 1 },
		Vector3 = { 1, 1, 1 },
		UDim = { 0.01, 1 },
		UDim2 = {
			0.01,
			1,
			0.01,
			1
		},
		Color3 = { 1, 1, 1 },
		Color4 = {
			1,
			1,
			1,
			1
		},
		Rect = {
			1,
			1,
			1,
			1
		}
	}
	local v3 = {
		Num = { 0 },
		Vector2 = { 0, 0 },
		Vector3 = { 0, 0, 0 },
		UDim = { 0, 0 },
		UDim2 = {
			0,
			0,
			0,
			0
		},
		Rect = {
			0,
			0,
			0,
			0
		}
	}
	local v4 = {
		Num = { 100 },
		Vector2 = { 100, 100 },
		Vector3 = { 100, 100, 100 },
		UDim = { 1, 960 },
		UDim2 = {
			1,
			960,
			1,
			960
		},
		Rect = {
			960,
			960,
			960,
			960
		}
	}
	local v5 = {
		Num = { "" },
		Vector2 = { "X: ", "Y: " },
		Vector3 = { "X: ", "Y: ", "Z: " },
		UDim = { "", "" },
		UDim2 = {
			"",
			"",
			"",
			""
		},
		Color3_RGB = { "R: ", "G: ", "B: " },
		Color3_HSV = { "H: ", "S: ", "V: " },
		Color4_RGB = {
			"R: ",
			"G: ",
			"B: ",
			"T: "
		},
		Color4_HSV = {
			"H: ",
			"S: ",
			"V: ",
			"T: "
		},
		Rect = {
			"X: ",
			"Y: ",
			"X: ",
			"Y: "
		}
	}
	local v6 = {
		Num = { 0 },
		Vector2 = { 0, 0 },
		Vector3 = { 0, 0, 0 },
		UDim = { 3, 0 },
		UDim2 = {
			3,
			0,
			3,
			0
		},
		Color3 = { 0, 0, 0 },
		Color4 = {
			0,
			0,
			0,
			0
		},
		Rect = {
			0,
			0,
			0,
			0
		}
	}

	local function generateButtons(state, frame, p: number, p2: number)
		local v7 = p + (2 * data._config.ItemInnerSpacing.X + p2 * 2)
		local generate = data2.abstractButton.Generate(state)
		generate.Name = "SubButton"
		generate.ZIndex = 5
		generate.LayoutOrder = 5
		generate.TextXAlignment = Enum.TextXAlignment.Center
		generate.Text = "-"
		generate.Size = UDim2.fromOffset(data._config.TextSize + 2 * data._config.FramePadding.Y, data._config.TextSize)
		generate.Parent = frame
		data2.applyButtonClick(generate, function()
			local v8 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			local v9 = (state.arguments.Increment and getValueByIndex(state.arguments.Increment, 1, state.arguments) or 1) * (v8 and 100 or 1)
			local v10 = state.state.number.value - v9

			if state.arguments.Min ~= nil then
				v10 = math.max(v10, getValueByIndex(state.arguments.Min, 1, state.arguments))
			end

			if state.arguments.Max ~= nil then
				v10 = math.min(v10, getValueByIndex(state.arguments.Max, 1, state.arguments))
			end

			state.state.number:set(v10)
			state.lastNumberChangedTick = data._cycleTick + 1
		end)
		local generate2 = data2.abstractButton.Generate(state)
		generate2.Name = "AddButton"
		generate2.ZIndex = 6
		generate2.LayoutOrder = 6
		generate2.TextXAlignment = Enum.TextXAlignment.Center
		generate2.Text = "+"
		generate2.Size = UDim2.fromOffset(
			data._config.TextSize + 2 * data._config.FramePadding.Y,
			data._config.TextSize
		)
		generate2.Parent = frame
		data2.applyButtonClick(generate2, function()
			local v8 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			local v9 = (state.arguments.Increment and getValueByIndex(state.arguments.Increment, 1, state.arguments) or 1) * (v8 and 100 or 1)
			local v10 = state.state.number.value + v9

			if state.arguments.Min ~= nil then
				v10 = math.max(v10, getValueByIndex(state.arguments.Min, 1, state.arguments))
			end

			if state.arguments.Max ~= nil then
				v10 = math.min(v10, getValueByIndex(state.arguments.Max, 1, state.arguments))
			end

			state.state.number:set(v10)
			state.lastNumberChangedTick = data._cycleTick + 1
		end)
		return v7
	end

	local function generateInputScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				numberChanged = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				local frame = Instance.new("Frame")
				frame.Name = "Iris_Input" .. p
				frame.Size = UDim2.fromScale(1, 0)
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uIListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				local v7 = 0
				local v8 = data._config.TextSize + 2 * data._config.FramePadding.Y

				if p2 == 1 then
					v7 = generateButtons(state, frame, v7, v8)
				end

				local uDim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1) - v7) / p2
				)
				local uDim2 = UDim.new(
					uDim.Scale * (p2 - 1),
					uDim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1) + v7
				)
				local v9 = data._config.ContentWidth - uDim2

				for i = 1, p2 do
					local textBox = Instance.new("TextBox")
					textBox.Name = "InputField" .. tostring(i)
					textBox.LayoutOrder = i

					if i == p2 then
						textBox.Size = UDim2.new(v9, data._config.ContentHeight)
					else
						textBox.Size = UDim2.new(uDim, data._config.ContentHeight)
					end

					textBox.AutomaticSize = Enum.AutomaticSize.Y
					textBox.BackgroundColor3 = data._config.FrameBgColor
					textBox.BackgroundTransparency = data._config.FrameBgTransparency
					textBox.ClearTextOnFocus = false
					textBox.TextTruncate = Enum.TextTruncate.AtEnd
					textBox.ClipsDescendants = true
					data2.applyFrameStyle(textBox)
					data2.applyTextStyle(textBox)
					data2.UISizeConstraint(textBox, Vector2.xAxis)
					textBox.Parent = frame
					local v11 = i
					textBox.FocusLost:Connect(function()
						local v12 = tonumber(textBox.Text:match("-?%d*%.?%d*"))

						if v12 ~= nil then
							if state.arguments.Min ~= nil then
								v12 = math.max(v12, getValueByIndex(state.arguments.Min, v11, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v12 = math.min(v12, getValueByIndex(state.arguments.Max, v11, state.arguments))
							end

							if state.arguments.Increment then
								v12 = math.round(v12 / getValueByIndex(state.arguments.Increment, v11, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									v11,
									state.arguments
								)
							end

							state.state.number:set(updateValueByIndex(
								state.state.number.value,
								v11,
								v12,
								state.arguments
							))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local v13 = state.arguments.Format[v11] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v13 = state.arguments.Prefix[v11] .. v13
						end

						textBox.Text = string.format(
							v13,
							getValueByIndex(state.state.number.value, v11, state.arguments)
						)
						state.state.editingText:set(0)
					end)
					local v12 = textBox
					local v13 = i
					textBox.Focused:Connect(function()
						v12.CursorPosition = #v12.Text + 1
						v12.SelectionStart = 1
						state.state.editingText:set(v13)
					end)
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 7
				textLabel.AutomaticSize = Enum.AutomaticSize.XY
				data2.applyTextStyle(textLabel)
				textLabel.Parent = frame
				return frame
			end,
			Update = function(p4)
				local instance = p4.Instance
				instance.TextLabel.Text = p4.arguments.Text or `Input {p}`

				if p2 == 1 then
					instance.SubButton.Visible = not p4.arguments.NoButtons
					instance.AddButton.Visible = not p4.arguments.NoButtons
				end

				if p4.arguments.Format and typeof(p4.arguments.Format) ~= "table" then
					p4.arguments.Format = { p4.arguments.Format }
				elseif not p4.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v8 = v6[p][i]

						if p4.arguments.Increment then
							local valueByIndex = getValueByIndex(p4.arguments.Increment, i, p4.arguments)
							v8 = math.max(v8, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v8)
						end

						if p4.arguments.Max then
							local valueByIndex = getValueByIndex(p4.arguments.Max, i, p4.arguments)
							v8 = math.max(v8, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v8)
						end

						if p4.arguments.Min then
							local valueByIndex = getValueByIndex(p4.arguments.Min, i, p4.arguments)
							v8 = math.max(v8, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v8)
						end

						if v8 > 0 then
							format[i] = `%.{v8}f`
						else
							format[i] = "%d"
						end
					end

					p4.arguments.Format = format
					p4.arguments.Prefix = v5[p]
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", 0)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local child = instance:FindFirstChild("InputField" .. tostring(i))
					local v7 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v7 = data3.arguments.Prefix[i] .. v7
					end

					child.Text = string.format(v7, getValueByIndex(data3.state.number.value, i, data3.arguments))
				end
			end
		}
	end

	local v7 = 0
	local v8 = false
	local v9 = nil
	local v10 = 0
	local v11 = ""

	local function updateActiveDrag()
		local X = data2.getMouseLocation().X
		local v12 = X - v7
		v7 = X

		if not (v8 ~= false and v9 ~= nil) then
			return
		end

		local number = v9.state.number

		if v11 == "Color3" or v11 == "Color4" then
			local v13 = v9
			number = v13.state.color

			if v10 == 4 then
				number = v13.state.transparency
			end
		end

		local v13 = (v9.arguments.Increment and getValueByIndex(v9.arguments.Increment, v10, v9.arguments) or v2[v11][v10]) * ((data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1) * ((data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1) * ((v11 == "Color3" or v11 == "Color4") and 5 or 1)
		local v14 = getValueByIndex(number.value, v10, v9.arguments) + v12 * v13

		if v9.arguments.Min ~= nil then
			v14 = math.max(v14, getValueByIndex(v9.arguments.Min, v10, v9.arguments))
		end

		if v9.arguments.Max ~= nil then
			v14 = math.min(v14, getValueByIndex(v9.arguments.Max, v10, v9.arguments))
		end

		number:set(updateValueByIndex(number.value, v10, v14, v9.arguments))
		v9.lastNumberChangedTick = data._cycleTick + 1
	end

	local function DragMouseDown(state, p: string, p2: number, p3: number, p4: number)
		local time = data2.getTime()
		local v12 = time - state.lastClickedTime < data._config.MouseDoubleClickTime
		local v13 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if v12 and (Vector2.new(p3, p4) - state.lastClickedPosition).Magnitude < data._config.MouseDoubleClickMaxDist or v13 then
			state.state.editingText:set(p2)
			return
		end

		state.lastClickedTime = time
		state.lastClickedPosition = Vector2.new(p3, p4)
		v8 = true
		v9 = state
		v10 = p2
		v11 = p
		updateActiveDrag()
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		updateActiveDrag()
	end)
	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v8 then
			v8 = false
			v9 = nil
			v10 = 0
		end
	end)

	local function generateDragScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				numberChanged = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				state.lastClickedTime = -1
				state.lastClickedPosition = Vector2.zero
				local frame = Instance.new("Frame")
				frame.Name = "Iris_Drag" .. p
				frame.Size = UDim2.fromScale(1, 0)
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uIListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				local total = 0
				local v12 = data._config.TextSize + 2 * data._config.FramePadding.Y

				if p == "Color3" or p == "Color4" then
					total += data._config.ItemInnerSpacing.X + v12
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = "ColorBox"
					imageLabel.BorderSizePixel = 0
					imageLabel.Size = UDim2.fromOffset(v12, v12)
					imageLabel.LayoutOrder = 5
					imageLabel.Image = data2.ICONS.ALPHA_BACKGROUND_TEXTURE
					imageLabel.ImageTransparency = 1
					data2.applyFrameStyle(imageLabel, true)
					imageLabel.Parent = frame
				end

				local uDim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1) - total) / p2
				)
				local uDim2 = UDim.new(
					uDim.Scale * (p2 - 1),
					uDim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1) + total
				)
				local v13 = data._config.ContentWidth - uDim2

				for i = 1, p2 do
					local textButton = Instance.new("TextButton")
					textButton.Name = "DragField" .. tostring(i)
					textButton.LayoutOrder = i

					if i == p2 then
						textButton.Size = UDim2.new(v13, data._config.ContentHeight)
					else
						textButton.Size = UDim2.new(uDim, data._config.ContentHeight)
					end

					textButton.AutomaticSize = Enum.AutomaticSize.Y
					textButton.BackgroundColor3 = data._config.FrameBgColor
					textButton.BackgroundTransparency = data._config.FrameBgTransparency
					textButton.AutoButtonColor = false
					textButton.Text = ""
					textButton.ClipsDescendants = true
					data2.applyFrameStyle(textButton)
					data2.applyTextStyle(textButton)
					data2.UISizeConstraint(textButton, Vector2.xAxis)
					textButton.TextXAlignment = Enum.TextXAlignment.Center
					textButton.Parent = frame
					data2.applyInteractionHighlights("Background", textButton, textButton, {
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					})
					local textBox = Instance.new("TextBox")
					textBox.Name = "InputField"
					textBox.Size = UDim2.new(1, 0, 1, 0)
					textBox.BackgroundTransparency = 1
					textBox.ClearTextOnFocus = false
					textBox.TextTruncate = Enum.TextTruncate.AtEnd
					textBox.ClipsDescendants = true
					textBox.Visible = false
					data2.applyFrameStyle(textBox, true)
					data2.applyTextStyle(textBox)
					textBox.Parent = textButton
					local v15 = i
					textBox.FocusLost:Connect(function()
						local v16 = tonumber(textBox.Text:match("-?%d*%.?%d*"))
						local number = state.state.number
						local v17 = state

						if p == "Color4" and v15 == 4 then
							number = v17.state.transparency
						elseif p == "Color3" or p == "Color4" then
							number = v17.state.color
						end

						if v16 ~= nil then
							if p == "Color3" or p == "Color4" and not v17.arguments.UseFloats then
								v16 /= 255
							end

							if state.arguments.Min ~= nil then
								v16 = math.max(v16, getValueByIndex(state.arguments.Min, v15, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v16 = math.min(v16, getValueByIndex(state.arguments.Max, v15, state.arguments))
							end

							if state.arguments.Increment then
								v16 = math.round(v16 / getValueByIndex(state.arguments.Increment, v15, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									v15,
									state.arguments
								)
							end

							number:set(updateValueByIndex(number.value, v15, v16, state.arguments))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local valueByIndex = getValueByIndex(number.value, v15, state.arguments)

						if p == "Color3" or p == "Color4" and not v17.arguments.UseFloats then
							valueByIndex = math.round(valueByIndex * 255)
						end

						local v18 = state.arguments.Format[v15] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v18 = state.arguments.Prefix[v15] .. v18
						end

						textBox.Text = string.format(v18, valueByIndex)
						state.state.editingText:set(0)
						textBox:ReleaseFocus(true)
					end)
					local v16 = textBox
					local v17 = i
					textBox.Focused:Connect(function()
						v16.CursorPosition = #v16.Text + 1
						v16.SelectionStart = 1
						state.state.editingText:set(v17)
					end)
					local v18 = i
					data2.applyButtonDown(textButton, function(p4: number, p5: number)
						DragMouseDown(state, p, v18, p4, p5)
					end)
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 6
				textLabel.AutomaticSize = Enum.AutomaticSize.XY
				data2.applyTextStyle(textLabel)
				textLabel.Parent = frame
				return frame
			end,
			Update = function(p4)
				p4.Instance.TextLabel.Text = p4.arguments.Text or `Drag {p}`

				if p4.arguments.Format and typeof(p4.arguments.Format) ~= "table" then
					p4.arguments.Format = { p4.arguments.Format }
				elseif not p4.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v13 = v6[p][i]

						if p4.arguments.Increment then
							local valueByIndex = getValueByIndex(p4.arguments.Increment, i, p4.arguments)
							v13 = math.max(v13, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v13)
						end

						if p4.arguments.Max then
							local valueByIndex = getValueByIndex(p4.arguments.Max, i, p4.arguments)
							v13 = math.max(v13, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v13)
						end

						if p4.arguments.Min then
							local valueByIndex = getValueByIndex(p4.arguments.Min, i, p4.arguments)
							v13 = math.max(v13, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v13)
						end

						if v13 > 0 then
							format[i] = `%.{v13}f`
						else
							format[i] = "%d"
						end
					end

					p4.arguments.Format = format
					p4.arguments.Prefix = v5[p]
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", false)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local number = data3.state.number

					if p == "Color3" or p == "Color4" then
						number = data3.state.color

						if i == 4 then
							number = data3.state.transparency
						end
					end

					local child = instance:FindFirstChild("DragField" .. tostring(i))
					local inputField = child.InputField
					local valueByIndex = getValueByIndex(number.value, i, data3.arguments)

					if (p == "Color3" or p == "Color4") and not data3.arguments.UseFloats then
						valueByIndex = math.round(valueByIndex * 255)
					end

					local v12 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v12 = data3.arguments.Prefix[i] .. v12
					end

					child.Text = string.format(v12, valueByIndex)
					inputField.Text = tostring(valueByIndex)

					if data3.state.editingText.value == i then
						inputField.Visible = true
						inputField:CaptureFocus()
						child.TextTransparency = 1
					else
						inputField.Visible = false
						child.TextTransparency = data._config.TextTransparency
					end
				end

				if p == "Color3" or p == "Color4" then
					local colorBox = instance.ColorBox
					colorBox.BackgroundColor3 = data3.state.color.value

					if p == "Color4" then
						colorBox.ImageTransparency = 1 - data3.state.transparency.value
					end
				end
			end
		}
	end

	local function generateColorDragScalar(p: string, ...)
		local v12 = { ... }
		local v13 = generateDragScalar(p, p == "Color4" and 4 or 3, v12[1])
		return data2.extend(v13, {
			Args = {
				Text = 1,
				UseFloats = 2,
				UseHSV = 3,
				Format = 4
			},
			Update = function(data3)
				data3.Instance.TextLabel.Text = data3.arguments.Text or `Drag {p}`

				if data3.arguments.Format and typeof(data3.arguments.Format) ~= "table" then
					data3.arguments.Format = { data3.arguments.Format }
				elseif not data3.arguments.Format then
					if data3.arguments.UseFloats then
						data3.arguments.Format = { "%.3f" }
					else
						data3.arguments.Format = { "%d" }
					end

					data3.arguments.Prefix = v5[p .. (data3.arguments.UseHSV and "_HSV" or "_RGB")]
				end

				data3.arguments.Min = {
					0,
					0,
					0,
					0
				}
				data3.arguments.Max = {
					1,
					1,
					1,
					1
				}
				data3.arguments.Increment = {
					0.001,
					0.001,
					0.001,
					0.001
				}

				if data3.state then
					data3.state.color.lastChangeTick = data._cycleTick

					if p == "Color4" then
						data3.state.transparency.lastChangeTick = data._cycleTick
					end

					data._widgets[data3.type].UpdateState(data3)
				end
			end,
			GenerateState = function(p2)
				if p2.state.color == nil then
					p2.state.color = data._widgetState(p2, "color", v12[1])
				end

				if p == "Color4" and p2.state.transparency == nil then
					p2.state.transparency = data._widgetState(p2, "transparency", v12[2])
				end

				if p2.state.editingText == nil then
					p2.state.editingText = data._widgetState(p2, "editingText", false)
				end
			end
		})
	end

	local v12 = false
	local v13 = nil
	local v14 = 0
	local v15 = ""

	local function updateActiveSlider()
		if not (v12 ~= false and v13 ~= nil) then
			return
		end

		local child = v13.Instance:FindFirstChild("SliderField" .. tostring(v14))
		local grabBar = child.GrabBar
		local v16 = v13.arguments.Increment and getValueByIndex(v13.arguments.Increment, v14, v13.arguments) or v2[v15][v14]
		local v17 = v13.arguments.Min and getValueByIndex(v13.arguments.Min, v14, v13.arguments) or v3[v15][v14]
		local v18 = v13.arguments.Max and getValueByIndex(v13.arguments.Max, v14, v13.arguments) or v4[v15][v14]
		local X = grabBar.AbsoluteSize.X
		local v19 = math.clamp(
			math.round((data2.getMouseLocation().X - (child.AbsolutePosition.X - data2.GuiOffset.X + X / 2)) / (child.AbsoluteSize.X - X) * math.floor((v18 - v17) / v16)) * v16 + v17,
			v17,
			v18
		)
		v13.state.number:set(updateValueByIndex(v13.state.number.value, v14, v19, v13.arguments))
		v13.lastNumberChangedTick = data._cycleTick + 1
	end

	local function SliderMouseDown(state, p: string, p2: number)
		if data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
			state.state.editingText:set(p2)
			return
		end

		v12 = true
		v13 = state
		v14 = p2
		v15 = p
		updateActiveSlider()
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		updateActiveSlider()
	end)
	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v12 then
			v12 = false
			v13 = nil
			v14 = 0
			v15 = ""
		end
	end)

	local function generateSliderScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				numberChanged = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				local frame = Instance.new("Frame")
				frame.Name = "Iris_Slider" .. p
				frame.Size = UDim2.fromScale(1, 0)
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uIListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				local uDim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1)) / p2
				)
				local uDim2 = UDim.new(
					uDim.Scale * (p2 - 1),
					uDim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1)
				)
				local v16 = data._config.ContentWidth - uDim2

				for i = 1, p2 do
					local textButton = Instance.new("TextButton")
					textButton.Name = "SliderField" .. tostring(i)
					textButton.LayoutOrder = i

					if i == p2 then
						textButton.Size = UDim2.new(v16, data._config.ContentHeight)
					else
						textButton.Size = UDim2.new(uDim, data._config.ContentHeight)
					end

					textButton.AutomaticSize = Enum.AutomaticSize.Y
					textButton.BackgroundColor3 = data._config.FrameBgColor
					textButton.BackgroundTransparency = data._config.FrameBgTransparency
					textButton.AutoButtonColor = false
					textButton.Text = ""
					textButton.ClipsDescendants = true
					data2.applyFrameStyle(textButton)
					data2.applyTextStyle(textButton)
					data2.UISizeConstraint(textButton, Vector2.xAxis)
					textButton.Parent = frame
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "OverlayText"
					textLabel.Size = UDim2.fromScale(1, 1)
					textLabel.BackgroundTransparency = 1
					textLabel.BorderSizePixel = 0
					textLabel.ZIndex = 10
					textLabel.ClipsDescendants = true
					data2.applyTextStyle(textLabel)
					textLabel.TextXAlignment = Enum.TextXAlignment.Center
					textLabel.Parent = textButton
					data2.applyInteractionHighlights("Background", textButton, textButton, {
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					})
					local textBox = Instance.new("TextBox")
					textBox.Name = "InputField"
					textBox.Size = UDim2.new(1, 0, 1, 0)
					textBox.BackgroundTransparency = 1
					textBox.ClearTextOnFocus = false
					textBox.TextTruncate = Enum.TextTruncate.AtEnd
					textBox.ClipsDescendants = true
					textBox.Visible = false
					data2.applyFrameStyle(textBox, true)
					data2.applyTextStyle(textBox)
					textBox.Parent = textButton
					local v18 = i
					textBox.FocusLost:Connect(function()
						local v19 = tonumber(textBox.Text:match("-?%d*%.?%d*"))

						if v19 ~= nil then
							if state.arguments.Min ~= nil then
								v19 = math.max(v19, getValueByIndex(state.arguments.Min, v18, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v19 = math.min(v19, getValueByIndex(state.arguments.Max, v18, state.arguments))
							end

							if state.arguments.Increment then
								v19 = math.round(v19 / getValueByIndex(state.arguments.Increment, v18, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									v18,
									state.arguments
								)
							end

							state.state.number:set(updateValueByIndex(
								state.state.number.value,
								v18,
								v19,
								state.arguments
							))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local v20 = state.arguments.Format[v18] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v20 = state.arguments.Prefix[v18] .. v20
						end

						textBox.Text = string.format(
							v20,
							getValueByIndex(state.state.number.value, v18, state.arguments)
						)
						state.state.editingText:set(0)
						textBox:ReleaseFocus(true)
					end)
					local v19 = textBox
					local v20 = i
					textBox.Focused:Connect(function()
						v19.CursorPosition = #v19.Text + 1
						v19.SelectionStart = 1
						state.state.editingText:set(v20)
					end)
					local v21 = i
					data2.applyButtonDown(textButton, function()
						SliderMouseDown(state, p, v21)
					end)
					local frame2 = Instance.new("Frame")
					frame2.Name = "GrabBar"
					frame2.ZIndex = 5
					frame2.AnchorPoint = Vector2.new(0.5, 0.5)
					frame2.Position = UDim2.new(0, 0, 0.5, 0)
					frame2.BorderSizePixel = 0
					frame2.BackgroundColor3 = data._config.SliderGrabColor
					frame2.Transparency = data._config.SliderGrabTransparency

					if data._config.GrabRounding > 0 then
						data2.UICorner(frame2, data._config.GrabRounding)
					end

					data2.UISizeConstraint(frame2, Vector2.new(data._config.GrabMinSize, 0))
					frame2.Parent = textButton
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 5
				textLabel.AutomaticSize = Enum.AutomaticSize.XY
				data2.applyTextStyle(textLabel)
				textLabel.Parent = frame
				return frame
			end,
			Update = function(data3)
				local instance = data3.Instance
				instance.TextLabel.Text = data3.arguments.Text or `Slider {p}`

				if data3.arguments.Format and typeof(data3.arguments.Format) ~= "table" then
					data3.arguments.Format = { data3.arguments.Format }
				elseif not data3.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v17 = v6[p][i]

						if data3.arguments.Increment then
							local valueByIndex = getValueByIndex(data3.arguments.Increment, i, data3.arguments)
							v17 = math.max(v17, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v17)
						end

						if data3.arguments.Max then
							local valueByIndex = getValueByIndex(data3.arguments.Max, i, data3.arguments)
							v17 = math.max(v17, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v17)
						end

						if data3.arguments.Min then
							local valueByIndex = getValueByIndex(data3.arguments.Min, i, data3.arguments)
							v17 = math.max(v17, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v17)
						end

						if v17 > 0 then
							format[i] = `%.{v17}f`
						else
							format[i] = "%d"
						end
					end

					data3.arguments.Format = format
					data3.arguments.Prefix = v5[p]
				end

				for i = 1, p2 do
					local grabBar = instance:FindFirstChild("SliderField" .. tostring(i)).GrabBar
					local v16 = data3.arguments.Increment and getValueByIndex(
						data3.arguments.Increment,
						i,
						data3.arguments
					) or v2[p][i]
					local v17 = data3.arguments.Min and getValueByIndex(data3.arguments.Min, i, data3.arguments) or v3[p][i]
					local v18 = 1 / math.floor(((data3.arguments.Max and getValueByIndex(
						data3.arguments.Max,
						i,
						data3.arguments
					) or v4[p][i]) + 1 - v17) / v16)
					grabBar.Size = UDim2.new(v18, 0, 1, 0)
				end

				local v16 = #data._postCycleCallbacks + 1
				local v17 = data._cycleTick + 1

				data._postCycleCallbacks[v16] = function()
					if v17 <= data._cycleTick then
						if data3.lastCycleTick ~= -1 then
							data3.state.number.lastChangeTick = data._cycleTick
							data._widgets[`Slider{p}`].UpdateState(data3)
						end

						data._postCycleCallbacks[v16] = nil
					end
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", false)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local child = instance:FindFirstChild("SliderField" .. tostring(i))
					local inputField = child.InputField
					local overlayText = child.OverlayText
					local grabBar = child.GrabBar
					local valueByIndex = getValueByIndex(data3.state.number.value, i, data3.arguments)
					local v16 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v16 = data3.arguments.Prefix[i] .. v16
					end

					overlayText.Text = string.format(v16, valueByIndex)
					inputField.Text = tostring(valueByIndex)
					local v17 = data3.arguments.Increment and getValueByIndex(
						data3.arguments.Increment,
						i,
						data3.arguments
					) or v2[p][i]
					local v18 = data3.arguments.Min and getValueByIndex(data3.arguments.Min, i, data3.arguments) or v3[p][i]
					local v19 = data3.arguments.Max and getValueByIndex(data3.arguments.Max, i, data3.arguments) or v4[p][i]
					local X = child.AbsoluteSize.X
					local v20 = X - grabBar.AbsoluteSize.X
					local v21 = (valueByIndex - v18) / (v19 - v18)
					local v22 = math.floor((v19 - v18) / v17)
					local v23 = math.clamp(math.floor(v21 * v22) / v22, 0, 1)
					local v24 = v20 / X * v23 + (1 - v20 / X) / 2
					grabBar.Position = UDim2.new(v24, 0, 0.5, 0)

					if data3.state.editingText.value == i then
						inputField.Visible = true
						overlayText.Visible = false
						grabBar.Visible = false
						inputField:CaptureFocus()
					else
						inputField.Visible = false
						overlayText.Visible = true
						grabBar.Visible = true
					end
				end
			end
		}
	end

	local function generateEnumSliderScalar(object, p)
		local v16 = generateSliderScalar("Enum", 1, p.Value)
		local v17 = { string }

		for _, v18 in object:GetEnumItems() do
			v17[v18.Value] = v18.Name
		end

		return data2.extend(v16, {
			Args = {
				Text = 1
			},
			Update = function(p2)
				local instance = p2.Instance
				instance.TextLabel.Text = p2.arguments.Text or "Input Enum"
				p2.arguments.Increment = 1
				p2.arguments.Min = 0
				p2.arguments.Max = #object:GetEnumItems() - 1
				local grabBar = instance:FindFirstChild("SliderField1").GrabBar
				local v18 = 1 / math.floor(#object:GetEnumItems())
				grabBar.Size = UDim2.new(v18, 0, 1, 0)
			end,
			GenerateState = function(p2)
				if p2.state.number == nil then
					p2.state.number = data._widgetState(p2, "number", p.Value)
				end

				if p2.state.enumItem == nil then
					p2.state.enumItem = data._widgetState(p2, "enumItem", p)
				end

				if p2.state.editingText == nil then
					p2.state.editingText = data._widgetState(p2, "editingText", false)
				end
			end
		})
	end

	local v16 = generateInputScalar("Num", 1, 0)
	v16.Args.NoButtons = 6
	data.WidgetConstructor("InputNum", v16)
	data.WidgetConstructor("InputVector2", generateInputScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("InputVector3", generateInputScalar("Vector3", 3, createVector(0, 0, 0)))
	data.WidgetConstructor("InputUDim", generateInputScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("InputUDim2", generateInputScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("InputRect", generateInputScalar("Rect", 4, Rect.new(0, 0, 0, 0)))
	data.WidgetConstructor("DragNum", generateDragScalar("Num", 1, 0))
	data.WidgetConstructor("DragVector2", generateDragScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("DragVector3", generateDragScalar("Vector3", 3, createVector(0, 0, 0)))
	data.WidgetConstructor("DragUDim", generateDragScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("DragUDim2", generateDragScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("DragRect", generateDragScalar("Rect", 4, Rect.new(0, 0, 0, 0)))
	data.WidgetConstructor("InputColor3", generateColorDragScalar("Color3", Color3.fromRGB(0, 0, 0)))
	data.WidgetConstructor("InputColor4", generateColorDragScalar("Color4", Color3.fromRGB(0, 0, 0), 0))
	data.WidgetConstructor("SliderNum", generateSliderScalar("Num", 1, 0))
	data.WidgetConstructor("SliderVector2", generateSliderScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("SliderVector3", generateSliderScalar("Vector3", 3, createVector(0, 0, 0)))
	data.WidgetConstructor("SliderUDim", generateSliderScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("SliderUDim2", generateSliderScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("SliderRect", generateSliderScalar("Rect", 4, Rect.new(0, 0, 0, 0)))
	data.WidgetConstructor("InputText", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			TextHint = 2,
			ReadOnly = 3,
			MultiLine = 4
		},
		Events = {
			textChanged = {
				Init = function(p)
					p.lastTextChangedTick = 0
				end,
				Get = function(p)
					return p.lastTextChangedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local frame = Instance.new("Frame")
			frame.Name = "Iris_InputText"
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.Size = UDim2.fromScale(1, 0)
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.ZIndex = state.ZIndex
			frame.LayoutOrder = state.ZIndex
			local uIListLayout = data2.UIListLayout(
				frame,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			local textBox = Instance.new("TextBox")
			textBox.Name = "InputField"
			textBox.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
			textBox.AutomaticSize = Enum.AutomaticSize.Y
			textBox.BackgroundColor3 = data._config.FrameBgColor
			textBox.BackgroundTransparency = data._config.FrameBgTransparency
			textBox.Text = ""
			textBox.TextYAlignment = Enum.TextYAlignment.Top
			textBox.PlaceholderColor3 = data._config.TextDisabledColor
			textBox.ClearTextOnFocus = false
			textBox.ClipsDescendants = true
			data2.applyFrameStyle(textBox)
			data2.applyTextStyle(textBox)
			data2.UISizeConstraint(textBox, Vector2.xAxis)
			textBox.Parent = frame
			textBox.FocusLost:Connect(function()
				state.state.text:set(textBox.Text)
				state.lastTextChangedTick = data._cycleTick + 1
			end)
			local v17 = data._config.TextSize + 2 * data._config.FramePadding.Y
			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, v17)
			textLabel.AutomaticSize = Enum.AutomaticSize.X
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1
			data2.applyTextStyle(textLabel)
			textLabel.Parent = frame
			return frame
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local inputField = instance.InputField
			textLabel.Text = p.arguments.Text or "Input Text"
			inputField.PlaceholderText = p.arguments.TextHint or ""
			inputField.TextEditable = not p.arguments.ReadOnly
			inputField.MultiLine = p.arguments.MultiLine or false
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.text == nil then
				p.state.text = data._widgetState(p, "text", "")
			end
		end,
		UpdateState = function(p)
			p.Instance.InputField.Text = p.state.text.value
		end
	})
end