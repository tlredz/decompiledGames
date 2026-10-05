require(script.Parent.Types)
local v = {}
return function(data)
	v.GuiService = game:GetService("GuiService")
	v.RunService = game:GetService("RunService")
	v.UserInputService = game:GetService("UserInputService")
	v.ContextActionService = game:GetService("ContextActionService")
	v.TextService = game:GetService("TextService")
	v.ICONS = {
		RIGHT_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_right.png",
		DOWN_POINTING_TRIANGLE = "rbxasset://textures/DeveloperFramework/button_arrow_down.png",
		MULTIPLICATION_SIGN = "rbxasset://textures/AnimationEditor/icon_close.png",
		BOTTOM_RIGHT_CORNER = "◢",
		CHECK_MARK = "rbxasset://textures/AnimationEditor/icon_checkmark.png",
		ALPHA_BACKGROUND_TEXTURE = "rbxasset://textures/meshPartFallback.png"
	}
	v.GuiInset = v.GuiService:GetGuiInset()
	v.IS_STUDIO = v.RunService:IsStudio()

	function v.getTime()
		if v.IS_STUDIO then
			return os.clock()
		end

		return time()
	end

	function v.getMouseLocation()
		return v.UserInputService:GetMouseLocation() - v.GuiInset
	end

	function v.findBestWindowPosForPopup(point: Vector2, point2: Vector2, point3: Vector2, point4: Vector2)
		local v7

		if point.X + point2.X + 20 > point4.X then
			if point.Y + point2.Y + 20 > point4.Y then
				v7 = point + Vector2.new(0, -(20 + point2.Y))
			else
				v7 = point + Vector2.new(0, 20)
			end
		else
			v7 = point + Vector2.new(20, 0)
		end

		return (Vector2.new(
			math.max(math.min(v7.X + point2.X, point4.X) - point2.X, point3.X),
			(math.max(math.min(v7.Y + point2.Y, point4.Y) - point2.Y, point3.Y))
		))
	end

	function v.isPosInsideRect(point: Vector2, point2: Vector2, point3: Vector2)
		return point.X > point2.X and point.X < point3.X and point.Y > point2.Y and point.Y < point3.Y
	end

	function v.extend(p, items)
		local clone = table.clone(p)

		for k, item in items do
			clone[k] = item
		end

		return clone
	end

	function v.UIPadding(parent, point: Vector2)
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingLeft = UDim.new(0, point.X)
		uIPadding.PaddingRight = UDim.new(0, point.X)
		uIPadding.PaddingTop = UDim.new(0, point.Y)
		uIPadding.PaddingBottom = UDim.new(0, point.Y)
		uIPadding.Parent = parent
		return uIPadding
	end

	function v.UIListLayout(parent, fillDirection, padding: UDim)
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Padding = padding
		uIListLayout.FillDirection = fillDirection
		uIListLayout.Parent = parent
		return uIListLayout
	end

	function v.UIStroke(parent, thickness: number, color: Color3, transparency: number)
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = thickness
		uIStroke.Color = color
		uIStroke.Transparency = transparency
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.LineJoinMode = Enum.LineJoinMode.Round
		uIStroke.Parent = parent
		return uIStroke
	end

	function v.UICorner(parent, value: number?)
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(value and 0 or 1, value or 0)
		uICorner.Parent = parent
		return uICorner
	end

	function v.UISizeConstraint(parent, point: Vector2?, point2: Vector2?)
		local uISizeConstraint = Instance.new("UISizeConstraint")
		uISizeConstraint.MinSize = point or uISizeConstraint.MinSize
		uISizeConstraint.MaxSize = point2 or uISizeConstraint.MaxSize
		uISizeConstraint.Parent = parent
		return uISizeConstraint
	end

	function v.UIReference(parent, p, name: string)
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = name
		objectValue.Value = p
		objectValue.Parent = parent
		return objectValue
	end

	function v.getScreenSizeForWindow(p)
		if p.usesScreenGUI then
			return p.Instance.AbsoluteSize
		end

		local parent = p.Instance.Parent

		if parent:IsA("GuiBase2d") or parent.Parent:IsA("GuiBase2d") then
			return parent.AbsoluteSize
		end

		return workspace.CurrentCamera.ViewportSize
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = data._config.TextFont
	getTextBoundsParams.Size = data._config.TextSize
	getTextBoundsParams.Width = 1e999

	function v.calculateTextSize(text: string, width: number?)
		if width then
			getTextBoundsParams.Width = width
		end

		getTextBoundsParams.Text = text
		local textBoundsAsync = v.TextService:GetTextBoundsAsync(getTextBoundsParams)

		if width then
			getTextBoundsParams.Width = 1e999
		end

		return textBoundsAsync
	end

	function v:applyTextStyle()
		self.FontFace = data._config.TextFont
		self.TextSize = data._config.TextSize
		self.TextColor3 = data._config.TextColor
		self.TextTransparency = data._config.TextTransparency
		self.TextXAlignment = Enum.TextXAlignment.Left
		self.AutoLocalize = false
		self.RichText = false
	end

	function v:applyInteractionHighlights(p, data2)
		local v7 = false
		self.MouseEnter:Connect(function()
			p.BackgroundColor3 = data2.ButtonHoveredColor
			p.BackgroundTransparency = data2.ButtonHoveredTransparency
			v7 = false
		end)
		self.MouseLeave:Connect(function()
			p.BackgroundColor3 = data2.ButtonColor
			p.BackgroundTransparency = data2.ButtonTransparency
			v7 = true
		end)
		self.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			p.BackgroundColor3 = data2.ButtonActiveColor
			p.BackgroundTransparency = data2.ButtonActiveTransparency
		end)
		self.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 or v7 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				p.BackgroundColor3 = data2.ButtonHoveredColor
				p.BackgroundTransparency = data2.ButtonHoveredTransparency
			end

			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				p.BackgroundColor3 = data2.ButtonColor
				p.BackgroundTransparency = data2.ButtonTransparency
			end
		end)
		self.SelectionImageObject = data.SelectionImageObject
	end

	function v:applyInteractionHighlightsWithMultiHighlightee(items)
		local v7 = false
		self.MouseEnter:Connect(function()
			for _, item in items do
				item[1].BackgroundColor3 = item[2].ButtonHoveredColor
				item[1].BackgroundTransparency = item[2].ButtonHoveredTransparency
				v7 = false
			end
		end)
		self.MouseLeave:Connect(function()
			for _, item in items do
				item[1].BackgroundColor3 = item[2].ButtonColor
				item[1].BackgroundTransparency = item[2].ButtonTransparency
				v7 = true
			end
		end)
		self.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			for _, item in items do
				item[1].BackgroundColor3 = item[2].ButtonActiveColor
				item[1].BackgroundTransparency = item[2].ButtonActiveTransparency
			end
		end)
		self.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 or v7 then
				return
			end

			for _, item in items do
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					item[1].BackgroundColor3 = item[2].ButtonHoveredColor
					item[1].BackgroundTransparency = item[2].ButtonHoveredTransparency
				end

				if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
					continue
				end

				item[1].BackgroundColor3 = item[2].ButtonColor
				item[1].BackgroundTransparency = item[2].ButtonTransparency
			end
		end)
		self.SelectionImageObject = data.SelectionImageObject
	end

	function v:applyTextInteractionHighlights(p, data2)
		local v7 = false
		self.MouseEnter:Connect(function()
			p.TextColor3 = data2.ButtonHoveredColor
			p.TextTransparency = data2.ButtonHoveredTransparency
			v7 = false
		end)
		self.MouseLeave:Connect(function()
			p.TextColor3 = data2.ButtonColor
			p.TextTransparency = data2.ButtonTransparency
			v7 = true
		end)
		self.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			p.TextColor3 = data2.ButtonActiveColor
			p.TextTransparency = data2.ButtonActiveTransparency
		end)
		self.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 or v7 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				p.TextColor3 = data2.ButtonHoveredColor
				p.TextTransparency = data2.ButtonHoveredTransparency
			end

			if input.UserInputType == Enum.UserInputType.Gamepad1 then
				p.TextColor3 = data2.ButtonColor
				p.TextTransparency = data2.ButtonTransparency
			end
		end)
		self.SelectionImageObject = data.SelectionImageObject
	end

	function v:applyFrameStyle(flag: boolean?, flag2: boolean?)
		local framePadding = data._config.FramePadding
		local frameBorderSize = data._config.FrameBorderSize
		local borderColor = data._config.BorderColor
		local buttonTransparency = data._config.ButtonTransparency
		local frameRounding = data._config.FrameRounding

		if frameBorderSize > 0 and frameRounding > 0 then
			self.BorderSizePixel = 0
			local uIStroke = Instance.new("UIStroke")
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uIStroke.LineJoinMode = Enum.LineJoinMode.Round
			uIStroke.Transparency = buttonTransparency
			uIStroke.Thickness = frameBorderSize
			uIStroke.Color = borderColor
			v.UICorner(self, frameRounding)
			uIStroke.Parent = self

			if not flag then
				v.UIPadding(self, data._config.FramePadding)
			end
		elseif frameBorderSize < 1 and frameRounding > 0 then
			self.BorderSizePixel = 0
			v.UICorner(self, frameRounding)

			if not flag then
				v.UIPadding(self, data._config.FramePadding)
			end
		elseif frameRounding < 1 then
			self.BorderSizePixel = frameBorderSize
			self.BorderColor3 = borderColor
			self.BorderMode = Enum.BorderMode.Inset

			if flag then
				if not flag2 then
					v.UIPadding(self, -Vector2.new(frameBorderSize, frameBorderSize))
				end
			else
				v.UIPadding(self, framePadding - Vector2.new(frameBorderSize, frameBorderSize))
			end
		end
	end

	function v.discardState(p)
		for _, v7 in p.state do
			v7.ConnectedWidgets[p.ID] = nil
		end
	end

	v.EVENTS = {
		hover = function(callback)
			return {
				Init = function(p)
					local v7 = callback(p)
					v7.MouseEnter:Connect(function()
						p.isHoveredEvent = true
					end)
					v7.MouseLeave:Connect(function()
						p.isHoveredEvent = false
					end)
					p.isHoveredEvent = false
				end,
				Get = function(p)
					return p.isHoveredEvent
				end
			}
		end,
		click = function(callback)
			return {
				Init = function(p)
					local v7 = callback(p)
					p.lastClickedTick = -1
					v7.MouseButton1Click:Connect(function()
						p.lastClickedTick = data._cycleTick + 1
					end)
				end,
				Get = function(p)
					return p.lastClickedTick == data._cycleTick
				end
			}
		end,
		rightClick = function(callback)
			return {
				Init = function(p)
					local v7 = callback(p)
					p.lastRightClickedTick = -1
					v7.MouseButton2Click:Connect(function()
						p.lastRightClickedTick = data._cycleTick + 1
					end)
				end,
				Get = function(p)
					return p.lastRightClickedTick == data._cycleTick
				end
			}
		end,
		doubleClick = function(callback)
			return {
				Init = function(state)
					local v7 = callback(state)
					state.lastClickedTime = -1
					state.lastClickedPosition = Vector2.zero
					state.lastDoubleClickedTick = -1
					v7.MouseButton1Down:Connect(function(p: number, p2: number)
						local time2 = v.getTime()

						if time2 - state.lastClickedTime < data._config.MouseDoubleClickTime and (Vector2.new(p, p2) - state.lastClickedPosition).Magnitude < data._config.MouseDoubleClickMaxDist then
							state.lastDoubleClickedTick = data._cycleTick + 1
							return
						end

						state.lastClickedTime = time2
						state.lastClickedPosition = Vector2.new(p, p2)
					end)
				end,
				Get = function(p)
					return p.lastDoubleClickedTick == data._cycleTick
				end
			}
		end,
		ctrlClick = function(callback)
			return {
				Init = function(p)
					local v7 = callback(p)
					p.lastCtrlClickedTick = -1
					v7.MouseButton1Click:Connect(function()
						if v.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or v.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
							p.lastCtrlClickedTick = data._cycleTick + 1
						end
					end)
				end,
				Get = function(p)
					return p.lastCtrlClickedTick == data._cycleTick
				end
			}
		end,
		shortcut = function(callback)
			return {
				Init = function(p)
					local v7, v8 = callback(p)
					p.lastShortcutTick = -1
					v.ContextActionService:BindAction(p.ID, function(_, p2, object)
						if p2 == Enum.UserInputState.Begin and object:IsModifierKeyDown(v8) then
							p.lastShortcutTick = data._cycleTick + 1
						end
					end, false, v7)
				end,
				Get = function(p)
					return p.lastShortcutTick == data._cycleTick
				end
			}
		end
	}
	local Root = require(script.Root)
	Root(data, v)
	local Window = require(script.Window)
	Window(data, v)
	local Menu = require(script.Menu)
	Menu(data, v)
	local Format = require(script.Format)
	Format(data, v)
	local Text = require(script.Text)
	Text(data, v)
	local Button = require(script.Button)
	Button(data, v)
	local Checkbox = require(script.Checkbox)
	Checkbox(data, v)
	local RadioButton = require(script.RadioButton)
	RadioButton(data, v)
	local Tree = require(script.Tree)
	Tree(data, v)
	local Input = require(script.Input)
	Input(data, v)
	local Combo = require(script.Combo)
	Combo(data, v)
	local Table = require(script.Table)
	Table(data, v)
end