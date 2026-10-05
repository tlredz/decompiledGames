require(script.Parent.Types)
local utility = {}
return function(state)
	utility.GuiService = game:GetService("GuiService")
	utility.RunService = game:GetService("RunService")
	utility.UserInputService = game:GetService("UserInputService")
	utility.ContextActionService = game:GetService("ContextActionService")
	utility.TextService = game:GetService("TextService")
	utility.ICONS = {
		BLANK_SQUARE = "rbxassetid://83265623867126",
		RIGHT_POINTING_TRIANGLE = "rbxassetid://105541346271951",
		DOWN_POINTING_TRIANGLE = "rbxassetid://95465797476827",
		MULTIPLICATION_SIGN = "rbxassetid://133890060015237",
		BOTTOM_RIGHT_CORNER = "rbxassetid://125737344915000",
		CHECKMARK = "rbxassetid://109638815494221",
		BORDER = "rbxassetid://133803690460269",
		ALPHA_BACKGROUND_TEXTURE = "rbxassetid://114090016039876",
		UNKNOWN_TEXTURE = "rbxassetid://95045813476061"
	}
	utility.IS_STUDIO = utility.RunService:IsStudio()

	function utility.getTime()
		if utility.IS_STUDIO then
			return os.clock()
		end

		return time()
	end

	local v7 = utility
	local guiOffset

	if state._config.IgnoreGuiInset then
		guiOffset = -utility.GuiService:GetGuiInset()
	else
		guiOffset = Vector2.zero
	end

	v7.GuiOffset = guiOffset
	local v9 = utility
	local mouseOffset

	if state._config.IgnoreGuiInset then
		mouseOffset = Vector2.zero
	else
		mouseOffset = utility.GuiService:GetGuiInset()
	end

	v9.MouseOffset = mouseOffset
	local topbarInsetChangedConnection = nil
	topbarInsetChangedConnection = utility.GuiService:GetPropertyChangedSignal("TopbarInset"):Once(function()
		local v11 = utility
		local mouseOffset2

		if state._config.IgnoreGuiInset then
			mouseOffset2 = Vector2.zero
		else
			mouseOffset2 = utility.GuiService:GetGuiInset()
		end

		v11.MouseOffset = mouseOffset2
		local v13 = utility
		local guiOffset2

		if state._config.IgnoreGuiInset then
			guiOffset2 = -utility.GuiService:GetGuiInset()
		else
			guiOffset2 = Vector2.zero
		end

		v13.GuiOffset = guiOffset2
		topbarInsetChangedConnection:Disconnect()
	end)
	task.delay(5, function()
		topbarInsetChangedConnection:Disconnect()
	end)

	function utility.getMouseLocation()
		return utility.UserInputService:GetMouseLocation() - utility.MouseOffset
	end

	function utility.isPosInsideRect(point: Vector2, point2: Vector2, point3: Vector2)
		return point.X >= point2.X and point.X <= point3.X and point.Y >= point2.Y and point.Y <= point3.Y
	end

	function utility.findBestWindowPosForPopup(point: Vector2, point2: Vector2, point3: Vector2, point4: Vector2)
		local v11

		if point.X + point2.X + 20 > point4.X then
			if point.Y + point2.Y + 20 > point4.Y then
				v11 = point + Vector2.new(0, -(20 + point2.Y))
			else
				v11 = point + Vector2.new(0, 20)
			end
		else
			v11 = point + Vector2.new(20)
		end

		return Vector2.new(
			math.max(math.min(v11.X + point2.X, point4.X) - point2.X, point3.X),
			(math.max(math.min(v11.Y + point2.Y, point4.Y) - point2.Y, point3.Y))
		)
	end

	function utility.getScreenSizeForWindow(p)
		if p.Instance:IsA("GuiBase2d") then
			return p.Instance.AbsoluteSize
		end

		local parent = p.Instance.Parent

		if parent:IsA("GuiBase2d") or parent.Parent:IsA("GuiBase2d") then
			return parent.AbsoluteSize
		end

		return workspace.CurrentCamera.ViewportSize
	end

	function utility.extend(p, items)
		local clone = table.clone(p)

		for k, item in items do
			clone[k] = item
		end

		return clone
	end

	function utility.UIPadding(parent, point: Vector2)
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingLeft = UDim.new(0, point.X)
		uIPadding.PaddingRight = UDim.new(0, point.X)
		uIPadding.PaddingTop = UDim.new(0, point.Y)
		uIPadding.PaddingBottom = UDim.new(0, point.Y)
		uIPadding.Parent = parent
		return uIPadding
	end

	function utility.UIListLayout(parent, fillDirection, padding: UDim)
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Padding = padding
		uIListLayout.FillDirection = fillDirection
		uIListLayout.Parent = parent
		return uIListLayout
	end

	function utility.UIStroke(parent, thickness: number, color: Color3, transparency: number)
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Thickness = thickness
		uIStroke.Color = color
		uIStroke.Transparency = transparency
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.LineJoinMode = Enum.LineJoinMode.Round
		uIStroke.Parent = parent
		return uIStroke
	end

	function utility.UICorner(parent, value: number?)
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(value and 0 or 1, value or 0)
		uICorner.Parent = parent
		return uICorner
	end

	function utility.UISizeConstraint(parent, point: Vector2?, point2: Vector2?)
		local uISizeConstraint = Instance.new("UISizeConstraint")
		uISizeConstraint.MinSize = point or uISizeConstraint.MinSize
		uISizeConstraint.MaxSize = point2 or uISizeConstraint.MaxSize
		uISizeConstraint.Parent = parent
		return uISizeConstraint
	end

	function utility:applyTextStyle()
		self.FontFace = state._config.TextFont
		self.TextSize = state._config.TextSize
		self.TextColor3 = state._config.TextColor
		self.TextTransparency = state._config.TextTransparency
		self.TextXAlignment = Enum.TextXAlignment.Left
		self.TextYAlignment = Enum.TextYAlignment.Center
		self.RichText = state._config.RichText
		self.TextWrapped = state._config.TextWrapped
		self.AutoLocalize = false
	end

	function utility.applyInteractionHighlights(p: string, p2, p3, data)
		local v11 = false
		utility.applyMouseEnter(p2, function()
			p3[p .. "Color3"] = data.HoveredColor
			p3[p .. "Transparency"] = data.HoveredTransparency
			v11 = false
		end)
		utility.applyMouseLeave(p2, function()
			p3[p .. "Color3"] = data.Color
			p3[p .. "Transparency"] = data.Transparency
			v11 = true
		end)
		utility.applyInputBegan(p2, function(p4)
			if p4.UserInputType ~= Enum.UserInputType.MouseButton1 and p4.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			p3[p .. "Color3"] = data.ActiveColor
			p3[p .. "Transparency"] = data.ActiveTransparency
		end)
		utility.applyInputEnded(p2, function(p4)
			if p4.UserInputType ~= Enum.UserInputType.MouseButton1 and p4.UserInputType ~= Enum.UserInputType.Gamepad1 or v11 then
				return
			end

			if p4.UserInputType == Enum.UserInputType.MouseButton1 then
				p3[p .. "Color3"] = data.HoveredColor
				p3[p .. "Transparency"] = data.HoveredTransparency
			end

			if p4.UserInputType == Enum.UserInputType.Gamepad1 then
				p3[p .. "Color3"] = data.Color
				p3[p .. "Transparency"] = data.Transparency
			end
		end)
		p2.SelectionImageObject = state.SelectionImageObject
	end

	function utility.applyInteractionHighlightsWithMultiHighlightee(p: string, p2, items)
		local v11 = false
		utility.applyMouseEnter(p2, function()
			for _, item in items do
				item[1][p .. "Color3"] = item[2].HoveredColor
				item[1][p .. "Transparency"] = item[2].HoveredTransparency
				v11 = false
			end
		end)
		utility.applyMouseLeave(p2, function()
			for _, item in items do
				item[1][p .. "Color3"] = item[2].Color
				item[1][p .. "Transparency"] = item[2].Transparency
				v11 = true
			end
		end)
		utility.applyInputBegan(p2, function(p3)
			if p3.UserInputType ~= Enum.UserInputType.MouseButton1 and p3.UserInputType ~= Enum.UserInputType.Gamepad1 then
				return
			end

			for _, item in items do
				item[1][p .. "Color3"] = item[2].ActiveColor
				item[1][p .. "Transparency"] = item[2].ActiveTransparency
			end
		end)
		utility.applyInputEnded(p2, function(p3)
			if p3.UserInputType ~= Enum.UserInputType.MouseButton1 and p3.UserInputType ~= Enum.UserInputType.Gamepad1 or v11 then
				return
			end

			for _, item in items do
				if p3.UserInputType == Enum.UserInputType.MouseButton1 then
					item[1][p .. "Color3"] = item[2].HoveredColor
					item[1][p .. "Transparency"] = item[2].HoveredTransparency
				end

				if p3.UserInputType ~= Enum.UserInputType.Gamepad1 then
					continue
				end

				item[1][p .. "Color3"] = item[2].Color
				item[1][p .. "Transparency"] = item[2].Transparency
			end
		end)
		p2.SelectionImageObject = state.SelectionImageObject
	end

	function utility:applyFrameStyle(flag: boolean?, flag2: boolean?)
		local frameBorderSize = state._config.FrameBorderSize
		local frameRounding = state._config.FrameRounding
		self.BorderSizePixel = 0

		if frameBorderSize > 0 then
			utility.UIStroke(self, frameBorderSize, state._config.BorderColor, state._config.BorderTransparency)
		end

		if frameRounding > 0 and not flag2 then
			utility.UICorner(self, frameRounding)
		end

		if not flag then
			utility.UIPadding(self, state._config.FramePadding)
		end
	end

	function utility.applyButtonClick(p, callback)
		p.MouseButton1Click:Connect(function()
			callback()
		end)
	end

	function utility.applyButtonDown(p, callback)
		p.MouseButton1Down:Connect(function(p2: number, p3: number)
			local v11 = Vector2.new(p2, p3) - utility.MouseOffset
			callback(v11.X, v11.Y)
		end)
	end

	function utility.applyMouseEnter(p, callback)
		p.MouseEnter:Connect(function(p2: number, p3: number)
			local v11 = Vector2.new(p2, p3) - utility.MouseOffset
			callback(v11.X, v11.Y)
		end)
	end

	function utility.applyMouseMoved(p, callback)
		p.MouseMoved:Connect(function(p2: number, p3: number)
			local v11 = Vector2.new(p2, p3) - utility.MouseOffset
			callback(v11.X, v11.Y)
		end)
	end

	function utility.applyMouseLeave(p, callback)
		p.MouseLeave:Connect(function(p2: number, p3: number)
			local v11 = Vector2.new(p2, p3) - utility.MouseOffset
			callback(v11.X, v11.Y)
		end)
	end

	function utility.applyInputBegan(p, callback)
		p.InputBegan:Connect(function(...)
			callback(...)
		end)
	end

	function utility.applyInputEnded(p, callback)
		p.InputEnded:Connect(function(...)
			callback(...)
		end)
	end

	function utility.discardState(p)
		for _, v11 in p.state do
			v11.ConnectedWidgets[p.ID] = nil
		end
	end

	function utility.registerEvent(p: string, callback)
		table.insert(state._initFunctions, function()
			table.insert(state._connections, utility.UserInputService[p]:Connect(callback))
		end)
	end

	utility.EVENTS = {
		hover = function(callback)
			return {
				Init = function(p)
					local v11 = callback(p)
					utility.applyMouseEnter(v11, function()
						p.isHoveredEvent = true
					end)
					utility.applyMouseLeave(v11, function()
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
					local v11 = callback(p)
					p.lastClickedTick = -1
					utility.applyButtonClick(v11, function()
						p.lastClickedTick = state._cycleTick + 1
					end)
				end,
				Get = function(p)
					return p.lastClickedTick == state._cycleTick
				end
			}
		end,
		rightClick = function(callback)
			return {
				Init = function(p)
					local v11 = callback(p)
					p.lastRightClickedTick = -1
					v11.MouseButton2Click:Connect(function()
						p.lastRightClickedTick = state._cycleTick + 1
					end)
				end,
				Get = function(p)
					return p.lastRightClickedTick == state._cycleTick
				end
			}
		end,
		doubleClick = function(callback)
			return {
				Init = function(state2)
					local v11 = callback(state2)
					state2.lastClickedTime = -1
					state2.lastClickedPosition = Vector2.zero
					state2.lastDoubleClickedTick = -1
					utility.applyButtonDown(v11, function(p: number, p2: number)
						local time2 = utility.getTime()

						if time2 - state2.lastClickedTime < state._config.MouseDoubleClickTime and (Vector2.new(p, p2) - state2.lastClickedPosition).Magnitude < state._config.MouseDoubleClickMaxDist then
							state2.lastDoubleClickedTick = state._cycleTick + 1
							return
						end

						state2.lastClickedTime = time2
						state2.lastClickedPosition = Vector2.new(p, p2)
					end)
				end,
				Get = function(p)
					return p.lastDoubleClickedTick == state._cycleTick
				end
			}
		end,
		ctrlClick = function(callback)
			return {
				Init = function(p)
					local v11 = callback(p)
					p.lastCtrlClickedTick = -1
					utility.applyButtonClick(v11, function()
						if utility.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or utility.UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
							p.lastCtrlClickedTick = state._cycleTick + 1
						end
					end)
				end,
				Get = function(p)
					return p.lastCtrlClickedTick == state._cycleTick
				end
			}
		end
	}
	state._utility = utility
	local Root = require(script.Root)
	Root(state, utility)
	local Window = require(script.Window)
	Window(state, utility)
	local Menu = require(script.Menu)
	Menu(state, utility)
	local Format = require(script.Format)
	Format(state, utility)
	local Text = require(script.Text)
	Text(state, utility)
	local Button = require(script.Button)
	Button(state, utility)
	local Checkbox = require(script.Checkbox)
	Checkbox(state, utility)
	local RadioButton = require(script.RadioButton)
	RadioButton(state, utility)
	local Image = require(script.Image)
	Image(state, utility)
	local Tree = require(script.Tree)
	Tree(state, utility)
	local Tab = require(script.Tab)
	Tab(state, utility)
	local Input = require(script.Input)
	Input(state, utility)
	local Combo = require(script.Combo)
	Combo(state, utility)
	local Plot = require(script.Plot)
	Plot(state, utility)
	local Table = require(script.Table)
	Table(state, utility)
end