local Uishelf = {}
local class = {}
local class2 = {}
local class3 = {}
class2.__index = class2
class.__index = class
class3.__index = class3
Uishelf.__index = Uishelf
Uishelf.CreatedIcons = {}
Uishelf.TopBarEnabled = true
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local uIElements = script.UIElements
local currentCamera = workspace.CurrentCamera
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local TopBarApp = require(uIElements.TopBarApp)
local clone = TopBarApp:Clone()
local TooltipLayer = require(uIElements.TooltipLayer)
local clone2 = TooltipLayer:Clone()
local leftFrame = clone.TopBarFrame.LeftFrame
local rightFrame = clone.TopBarFrame.RightFrame
local Badge = require(uIElements.Badge)
local Icon = require(uIElements.Icon)
local Spacer = require(uIElements.Spacer)
local Tooltip = require(uIElements.Tooltip)
local MenuObject = require(uIElements.MenuObject)
local SelectionImageObject = require(uIElements.SelectionImageObject)
local SelectionImageObjectMenu = require(uIElements.SelectionImageObjectMenu)
local Signal = require(script.Parent.Signal)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	},
	MouseDown = {
		BackgroundTransparency = 0.7,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	},
	MouseUpHovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	}
}
local v2 = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	},
	MouseDown = {
		BackgroundTransparency = 0.7,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	}
}
local _ = {
	Default = {
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	},
	Hovering = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	},
	Open = {
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	}
}
local v3 = {
	MouseButton1Up = "MouseUpHovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default",
	SelectionGained = "Hovering",
	SelectionLost = "Default"
}
local v4 = {
	MouseButton1Up = "Hovering",
	MouseButton1Down = "MouseDown",
	MouseEnter = "Hovering",
	MouseLeave = "Default"
}
local _ = {
	MouseButton1Up = "Hovering",
	MouseButton1Down = "Hovering",
	MouseEnter = "Hovering",
	MouseLeave = "Default"
}
local v5 = { "LeftFrame", "RightFrame", "Layout" }
local v6 = {
	[Enum.KeyCode.Escape] = "Esc",
	[Enum.KeyCode.Backquote] = "`"
}
local uDim = UDim2.fromOffset(44, 44)
local uDim2 = UDim.new(0, 42)
UDim.new(0, 12)
local uDim3 = UDim.new(0, 12)
local uDim4 = UDim.new(0, 12)
local uDim5 = UDim2.fromOffset(0, 44)
Uishelf.HorizontalAlignment = {
	Left = 1,
	Right = 2
}
clone.Parent = playerGui
clone2.Parent = playerGui
assert(RunService:IsClient(), "UI can only be handled on the client")

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateTopbar()
	local topbarInset = GuiService.TopbarInset
	clone.TopBarFrame.Size = UDim2.fromOffset(topbarInset.Width, clone.TopBarFrame.Size.Y.Offset)
end

function Uishelf:CreateIcon()
	local object = setmetatable({}, class)
	local clone3 = Icon:Clone()
	table.insert(Uishelf.CreatedIcons, object)
	local background = clone3.Background
	local icon = background.Icon
	background.SelectionImageObject = SelectionImageObject
	object._Element = clone3
	object._Tooltip = nil
	object._TooltipTweens = nil
	object.TooltipText = ""
	object.Name = nil
	object.Image = nil
	object.Order = nil
	object.Area = nil
	object.Text = nil
	object.TextEnabled = self.Text and true or false
	object.ImageEnabled = self.Image and true or false
	object.StateChanged = Signal()
	object.Activated = Signal()
	object.NoticeAdded = Signal()
	object.NoticeRemoved = Signal()
	object.Notices = 0
	object.NoticeCap = "99+"
	object.NoticeCapNum = 99
	object.CurrentState = "Default"
	object._KeyCodeConnection = nil
	object._NoticeConnection = nil
	object._TooltipConnection = nil
	object._GuiBindConnection = nil
	object._SizeConnection = nil
	object._PositionConnection = nil

	if type(self.Image) == "number" then
		self.Image = `rbxassetid://{self.Image}`
	end

	if self.Order <= 0 then
		error("Order cannot be less than 0")
	end

	if self.Area == Uishelf.HorizontalAlignment.Right then
		self.Order = -self.Order
	end

	for k, v7 in self do
		object[k] = v7
	end

	background.Activated:Connect(function(p2)
		object.Activated:Fire(p2.UserInputType)
	end)
	object:SetText(self.Text, self.Font)
	object:SetImage(self.Image)

	for k, v7 in v3 do
		local v8 = v7
		background[k]:Connect(function()
			object:UpdateStateOverlay(v8)
		end)
	end

	object.StateChanged:Connect(function(p2)
		if not object._Tooltip then
			return
		end

		if p2 == "MouseUpHovering" or p2 ~= "Hovering" then
			object:SetTooltipEnabled(false)
			return
		end

		task.wait(0.75)

		if object.CurrentState == "Hovering" and object._Tooltip then
			object:SetTooltipEnabled(true)
		end
	end)
	object._SizeConnection = background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		clone3.Size = UDim2.fromOffset(background.AbsoluteSize.X, 44)
	end)

	if object.Area == 1 then
		assert(not leftFrame:FindFirstChild(self.Name), "Cannot have duplicate icon names in left frame")
		clone3.Parent = leftFrame
	elseif object.Area == 2 then
		assert(not rightFrame:FindFirstChild(self.Name), "Cannot have duplicate icon names in right frame")
		clone3.Parent = rightFrame
	end

	if table.find(v5, self.Name) then
		error((`{self.Name} is part of the reserved naming list`))
	end

	clone3:SetAttribute("Notices", 0)
	clone3.Name = self.Name
	clone3.LayoutOrder = self.Order

	if self.Image then
		icon.Image = self.Image
	end

	return object
end

function Uishelf.SetTopBarEnabled(flag: boolean)
	clone.Enabled = flag
	Uishelf.TopBarEnabled = flag
end

function class:SetIconEnabled(visible: boolean)
	self._Element.Visible = visible
end

function class:BindGuiObject(p)
	if not p then
		self._GuiBindConnection:Disconnect()
	elseif not self._GuiBindConnection then
		self._GuiBindConnection = self.Activated:Connect(function()
			p.Visible = not p.Visible
		end)
	end
end

function class:SetText(text: string?, font)
	local background = self._Element.Background
	local text2 = background.Text

	if text then
		self.TextEnabled = true
		background.Text.Visible = true
		background.Text.Text = text

		if font then
			local text3 = background.Text

			if typeof(font) ~= "Font" then
				font = Font.fromEnum(font)
			end

			text3.FontFace = font
		end

		if not self.ImageEnabled then
			self.ImageEnabled = false
			background.Text.Inset.PaddingLeft = uDim3
			background.Text.Inset.PaddingRight = uDim4
			background.Size = uDim5
		end

		UpdateTopbar() -- equivalent call inferred; original call site unknown
	else
		assert(self.ImageEnabled, "Must have at least image or text on icon")
		self.ImageEnabled = true
		text2.Visible = false
		UpdateTopbar() -- equivalent call inferred; original call site unknown
		self.TextEnabled = false
	end
end

function class:SetImage(image)
	local background = self._Element.Background
	local text = background.Text
	local icon = background.Icon

	if image then
		self.ImageEnabled = true
		text.Inset.PaddingLeft = uDim2

		if type(image) == "number" then
			image = `rbxassetid://{image}`
		end

		icon.Image = image
		background.Size = uDim
		UpdateTopbar() -- equivalent call inferred; original call site unknown
	else
		assert(self.TextEnabled, "Must have at least image or text on icon")
		icon.Image = ""
		self.TextEnabled = true
		text.Inset.PaddingLeft = uDim3
		text.Inset.PaddingRight = uDim4
		background.Size = uDim5
		UpdateTopbar() -- equivalent call inferred; original call site unknown
		self.ImageEnabled = false
	end
end

function class:SetTooltip(text: string?)
	if text then
		if not self._Tooltip then
			self._Tooltip = Tooltip:Clone()
			self._Tooltip.Parent = clone2
			self._TooltipTweens = {
				[false] = TweenService:Create(self._Tooltip, tweenInfo, {
					GroupTransparency = 1
				}),
				[true] = TweenService:Create(self._Tooltip, tweenInfo2, {
					GroupTransparency = 0
				})
			}
		end

		local _Tooltip = self._Tooltip
		local header = _Tooltip.Box.Header
		local caret = _Tooltip.Caret
		local _Element = self._Element

		if header.Text == text then
			return
		end

		header.Text = text
		_Tooltip.Name = self.Name
		local v7 = _Element.AbsolutePosition.X + _Element.AbsoluteSize.X / 2
		local uDim6 = UDim2.fromOffset(self._Tooltip.Box.AbsoluteSize.X + 8, self._Tooltip.Box.AbsoluteSize.Y + 8)
		_Tooltip.Position = UDim2.fromOffset(v7, 56)
		_Tooltip.Size = UDim2.fromOffset(self._Tooltip.Box.AbsoluteSize.X + 8, 53)
		_Tooltip.DropShadow.Size = uDim6
		caret.Position = UDim2.fromOffset(v7 - _Tooltip.AbsolutePosition.X, 4)

		if self.Area == Uishelf.HorizontalAlignment.Right and self._Element.LayoutOrder <= -1 then
			caret.Position = UDim2.fromOffset(_Tooltip.Box.AbsoluteSize.X - 22, 4)
			_Tooltip.Position = UDim2.fromOffset(currentCamera.ViewportSize.X - 8 - _Tooltip.Box.AbsoluteSize.X / 2, 56)
		else
			self._PositionConnection = self._Element:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				_Tooltip.Position = UDim2.fromOffset(
					_Element.AbsolutePosition.X + _Element.AbsoluteSize.X / 2,
					_Tooltip.Visible and 60 or 56
				)
			end)
		end

		UpdateTopbar() -- equivalent call inferred; original call site unknown
	else
		self._Tooltip:Destroy()
		self._Tooltip = nil

		for _, _TooltipTween in self._TooltipTweens do
			_TooltipTween:Destroy()
		end

		table.clear(self._TooltipTweens)
	end
end

function class:SetTooltipEnabled(visible: boolean)
	assert(self._Tooltip, "Icon must already have a tooltip set")
	local _Tooltip = self._Tooltip
	local uDim6 = UDim2.fromOffset(self._Tooltip.Position.X.Offset, visible and 60 or 56)
	local v7

	if visible then
		v7 = Enum.EasingDirection.In
	else
		v7 = Enum.EasingDirection.Out
	end

	_Tooltip:TweenPosition(uDim6, v7, Enum.EasingStyle.Quad, 0.15)

	if visible then
		self._Tooltip.Visible = visible
		self._TooltipTweens[visible]:Play()
	else
		self._TooltipTweens[visible]:Play()
		task.wait(0.15)
		self._Tooltip.Visible = visible
	end
end

function class:CreateMenu(items)
	local menuContainer = self._Element.MenuContainer

	if menuContainer.ScrollingFrame:FindFirstChildOfClass("ImageButton") then
		for _, button in menuContainer.ScrollingFrame:GetChildren() do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end
	end

	for _, item in items do
		local clone3 = MenuObject:Clone()
		local styledTextLabel = clone3.StyledTextLabel
		local integrationIcon = clone3.IconHost.IntegrationIconFrame.IntegrationIcon

		for k, v7 in v4 do
			local v8 = k
			local v9 = item
			local v10 = v7
			local v11 = clone3
			clone3[k]:Connect(function()
				if v8 == "MouseButton1Up" then
					menuContainer.Visible = false
					v9.Activated:Fire()
				end

				self:UpdateStateOverlayMenu(v10, v11)
			end)
		end

		clone3.Name = string.lower(item.Name)
		clone3.SelectionImageObject = SelectionImageObjectMenu
		styledTextLabel.Text = item.Name
		integrationIcon.Image = item.Image
		clone3.Parent = menuContainer.ScrollingFrame
	end

	menuContainer.Position = UDim2.new(1, 0, 0, 54)

	if self.Area == Uishelf.HorizontalAlignment.Left then
		menuContainer.Position = UDim2.fromOffset(0, 54)
		menuContainer.AnchorPoint = Vector2.new(0, 0)
	end

	self.Activated:Connect(function()
		menuContainer.Visible = not menuContainer.Visible
	end)
end

function class:UpdateStateOverlayMenu(p: string, p2)
	for k, v7 in v2[p] do
		if p2[k] then
			p2[k] = v7
		end
	end
end

function class:UpdateStateOverlay(currentState: string)
	local stateOverlayRound = self._Element.Background.StateOverlayRound

	if currentState == "Hovering" and UserInputService.TouchEnabled then
		stateOverlayRound.Transparency = 0.7
		stateOverlayRound.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	else
		for k, v7 in v[currentState] do
			stateOverlayRound[k] = v7
		end

		self.CurrentState = currentState
		self.StateChanged:Fire(currentState)
	end
end

function class:SetImageRect(imageRectSize: Rect, imageRectOffset: Rect)
	local icon = self._Element.Background.Icon
	icon.ImageRectOffset = imageRectOffset
	icon.ImageRectSize = imageRectSize
end

function class:AddIconNotices(value: number?, value2: number?)
	local v7 = value2 or 99
	local v8 = value or 1

	if v8 and v8 <= 0 then
		error("Cannot notify 0 notifications")
		return
	end

	local _Element = self._Element
	local badgeContainer = _Element.BadgeContainer

	if not Icon:GetAttribute("Notices") then
		Icon:SetAttribute("Notices", 0)
	end

	if not badgeContainer:FindFirstChild("Badge") then
		local clone = Badge:Clone()
		clone.Parent = badgeContainer
	end

	local badge = badgeContainer.Badge
	local textLabel = badge.Inner.TextLabel

	if v7 and v7 ~= self.NoticeCapNum then
		self.NoticeCap = `{v7}+`
	end

	if not self._NoticeConnection then
		self._NoticeConnection = _Element:GetAttributeChangedSignal("Notices"):Connect(function()
			local notices = _Element:GetAttribute("Notices")
			textLabel.Text = notices

			if notices >= 1 then
				badgeContainer.Visible = true
			elseif notices == 0 then
				badgeContainer.Visible = false
				self.Notices = 0
			end

			if v7 < notices then
				textLabel.Text = self.NoticeCap
			end

			if notices <= 9 then
				badge.Size = UDim2.fromOffset(24, 24)
				badge.Position = UDim2.new(1, 0, 0, 0)
			else
				badge.Size = UDim2.fromOffset(textLabel.TextBounds.X + 14, 24)
				badge.Position = UDim2.new(1, textLabel.TextBounds.X + 14 - 24, 0, 0)
			end
		end)
	end

	_Element:SetAttribute("Notices", _Element:GetAttribute("Notices") + v8)
	self.NoticeAdded:Fire(_Element:GetAttribute("Notices"))
	self.Notices += v8
end

function class:RemoveIconNotices(p: number?)
	local _Element = self._Element

	if p then
		if p <= 0 then
			error("Cannot remove 0 notifications")
			return
		end

		_Element:SetAttribute("Notices", _Element:GetAttribute("Notices") - p)
		self.Notices -= p
	else
		_Element:SetAttribute("Notices", 0)
		self.Notices = 0
	end
end

function class:BindKeyCode(p)
	if p then
		if self._Tooltip then
			local hotkeys = self._Tooltip.Box.Hotkeys
			local _1 = hotkeys["1"]
			local name

			if v6[p] then
				name = v6[p]
			else
				name = p.Name
			end

			hotkeys.Visible = true
			_1.LabelContent.Text = name
			local uDim6 = UDim2.fromOffset(self._Tooltip.Box.AbsoluteSize.X + 8, self._Tooltip.Box.AbsoluteSize.Y + 8)
			self._Tooltip.DropShadow.Size = uDim6
		end

		self._KeyCodeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
			if gameProcessed then
				return
			end

			if input.KeyCode == p then
				self.Activated:Fire(input.UserInputType)
			end
		end)
	else
		if self._Tooltip then
			local hotkeys = self._Tooltip.Box.Hotkeys
			local _1 = hotkeys["1"]
			hotkeys.Visible = false
			_1.LabelContent.Text = "nil"
		end

		if self._KeyCodeConnection then
			self._KeyCodeConnection:Disconnect()
		end
	end
end

function class:SetImageSize(point: Vector2)
	self._Element.Background.Icon.Size = UDim2.fromOffset(point.X, point.Y)
end

function class:Destroy()
	if self._KeyCodeConnection then
		self._KeyCodeConnection:Disconnect()
	end

	if self._NoticeConnection then
		self._NoticeConnection:Disconnect()
	end

	for _, v7 in self do
		if typeof(v7) == "Instance" then
			v7:Destroy()
		else
			self[v7] = nil
		end
	end

	table.remove(Uishelf.CreatedIcons, table.find(Uishelf.CreatedIcons, self))
	setmetatable(self, nil)
end

function Uishelf:CreateSpacer(flag: boolean?)
	local object = setmetatable({}, class2)
	local clone3 = Spacer:Clone()

	if self.Order <= 0 and not flag then
		error("Order cannot be less than 0")
	end

	if self.Area == 2 then
		self.Order = -self.Order
	end

	object._Element = clone3
	object.Name = self.Name
	object.Order = self.Order
	object.Area = self.Area

	if object.Area == 1 then
		clone3.Parent = leftFrame
	elseif object.Area == 2 then
		clone3.Parent = rightFrame
	end

	clone3.Name = self[1]
	clone3.LayoutOrder = self[3]
	return object
end

function class2:SetSpacerEnabled(visible: boolean)
	self._Element.Visible = visible
end

function class2:SetSpacerSize(p2: number)
	local _Element = self._Element
	_Element.Size = UDim2.fromOffset(p2, _Element.Size.Y.Offset)
end

function class2:Destroy()
	for _, item in self do
		if typeof(item) == "Instance" then
			item:Destroy()
		else
			self[item] = nil
		end
	end

	setmetatable(self, nil)
end

function Uishelf:CreateMenuItem()
	if type(self.Image) == "number" then
		self.Image = `rbxassetid://{self.Image}`
	end

	return {
		Name = self.Name,
		Image = self.Image,
		Activated = Signal()
	}
end

GuiService.MenuOpened:Connect(function()
	clone.Enabled = false
	clone2.Enabled = false
end)
GuiService.MenuClosed:Connect(function()
	clone.Enabled = Uishelf.TopBarEnabled
	clone2.Enabled = Uishelf.TopBarEnabled
end)
GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(UpdateTopbar)
RunService.Heartbeat:Connect(function()
	if not GuiService.SelectedObject then
		return
	end

	SelectionImageObjectMenu.UIStroke.GradientChild.Rotation += 1
	SelectionImageObject.UIStroke.GradientChild.Rotation += 1
end)
UpdateTopbar() -- equivalent call inferred; original call site unknown
return Uishelf