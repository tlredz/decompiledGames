local color = Color3.fromRGB(0, 162, 255)
local color2 = Color3.fromRGB(78, 84, 96)
local color3 = Color3.fromRGB(204, 204, 204)
local color4 = Color3.fromRGB(255, 255, 255)
local color5 = Color3.fromRGB(150, 150, 150)
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local playerGui = game.Players.LocalPlayer.PlayerGui
playerGui:WaitForChild("BackpackGui")
local ContextActionService = game:GetService("ContextActionService")
local VRService = game:GetService("VRService")
local success, result = pcall(function()
	return false
end)
local v = success and result
local v2 = {
	Create = function(className)
		return function(items)
			local instance = Instance.new(className)
			local parent = nil

			for k, item in pairs(items) do
				if type(k) == "number" then
					item.Parent = instance
				elseif k == "Parent" then
					parent = item
				else
					instance[k] = item
				end
			end

			if parent then
				instance.Parent = parent
			end

			return instance
		end
	end
}
local v3 = {}
setmetatable(v3, {
	__mode = "k"
})
local selectionImageObject = v2.Create("ImageLabel")({
	Image = "",
	BackgroundTransparency = 1
})

function clamp(p, p2, p3)
	return (math.max(p, (math.min(p2, p3))))
end

function ClampVector2(p, p2, p3)
	return Vector2.new(clamp(p.x, p2.x, p3.x), clamp(p.y, p2.y, p3.y))
end

local function Linear(p, p2, p3, p4)
	if p4 <= p then
		return p2 + p3
	end

	return p3 * p / p4 + p2
end

local function EaseOutQuad(p, p2, p3, p4)
	if p4 <= p then
		return p2 + p3
	end

	local v5 = p / p4
	return p2 - p3 * v5 * (v5 - 2)
end

local function EaseInOutQuad(p, p2, p3, p4)
	if p4 <= p then
		return p2 + p3
	end

	local v5 = p / p4

	if v5 < 0.5 then
		return 2 * p3 * v5 * v5 + p2
	end

	return p2 + p3 * (2 * (2 - v5) * v5 - 1)
end

function PropertyTweener(p, p2, p3, p4, p5, callback, callback2)
	local v5 = {
		StartTime = tick()
	}
	v5.EndTime = v5.StartTime + p5
	v5.Cancelled = false
	local v6 = false
	local clamped = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function finalize()
		if p then
			p[p2] = callback(1, p3, p4 - p3, 1)
		end

		v6 = true
		clamped = 1

		if callback2 then
			callback2()
		end
	end

	p[p2] = callback(0, p3, p4 - p3, p5)
	coroutine.wrap(function()
		local now = tick()

		while now < v5.EndTime and p do
			if v5.Cancelled then
				return
			end

			p[p2] = callback(now - v5.StartTime, p3, p4 - p3, p5)
			clamped = clamp(0, 1, (now - v5.StartTime) / p5)
			RunService.RenderStepped:wait()
			now = tick()
		end

		if v5.Cancelled == false and p then
			finalize() -- equivalent call inferred; original call site unknown
		end
	end)()

	function v5.GetFinal(_)
		return p4
	end

	function v5.GetPercentComplete(_)
		return clamped
	end

	function v5.IsFinished(_)
		return v6
	end

	function v5:Finish()
		if not v6 then
			self:Cancel()
			finalize() -- equivalent call inferred; original call site unknown
		end
	end

	function v5:Cancel()
		v5.Cancelled = true
	end

	return v5
end

local function CreateSignal()
	local bindableEvent = Instance.new("BindableEvent")
	local v6 = nil
	local v7 = nil
	return {
		fire = function(_, ...)
			v6 = { ... }
			v7 = select("#", ...)
			bindableEvent:Fire()
		end,
		connect = function(_, callback)
			if not callback then
				error("connect(nil)", 2)
			end

			return bindableEvent.Event:Connect(function()
				callback(unpack(v6, 1, v7))
			end)
		end,
		wait = function(self)
			bindableEvent.Event:wait()

			if not v6 then
				error("Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
			end

			return unpack(v6, 1, v7)
		end
	}
end

local function getViewportSize()
	while not workspace.CurrentCamera do
		workspace.Changed:wait()
	end

	while workspace.CurrentCamera.ViewportSize == Vector2.new(0, 0) or workspace.CurrentCamera.ViewportSize == Vector2.new(
		1,
		1
	) do
		workspace.CurrentCamera.Changed:wait()
	end

	return workspace.CurrentCamera.ViewportSize
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSmallTouchScreen()
	local viewportSize = getViewportSize()
	return UserInputService.TouchEnabled and (viewportSize.Y < 500 or viewportSize.X < 700)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPortrait()
	local viewportSize = getViewportSize()
	return viewportSize.Y > viewportSize.X
end

local function isTenFootInterface()
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function usesSelectedObject()
	if VRService.VREnabled then
		return false
	end

	return not (UserInputService.TouchEnabled and not UserInputService.GamepadEnabled)
end

local function isPosOverGui(p, p2, _)
	local x = p2.AbsolutePosition.x
	local y = p2.AbsolutePosition.y
	local x2 = p2.AbsoluteSize.x
	local y2 = p2.AbsoluteSize.y
	local v5 = x + x2
	local v6 = y + y2
	return x < p.x and p.x < v5 and y < p.y and p.y < v6
end

local function isPosOverGuiWithClipping(p, parent)
	local x = parent.AbsolutePosition.x
	local y = parent.AbsolutePosition.y
	local x2 = parent.AbsoluteSize.x
	local y2 = parent.AbsoluteSize.y
	local v5 = x + x2
	local v6 = y + y2
	local v7

	if x < p.x and p.x < v5 and y < p.y then
		v7 = p.y < v6
	else
		v7 = false
	end

	if not v7 then
		return false
	end

	local v8

	while true do
		if parent == nil or not (parent:IsA("GuiObject") or parent:IsA("LayerCollector")) then
			v8 = not (parent and parent:IsA("CoreGui"))
			break
		end

		if parent:IsA("GuiObject") and not parent.Visible then
			v8 = true
			break
		end

		if parent:IsA("LayerCollector") or parent.ClipsDescendants then
			local x3 = parent.AbsolutePosition.x
			local y3 = parent.AbsolutePosition.y
			local x4 = parent.AbsoluteSize.x
			local y4 = parent.AbsoluteSize.y
			local v9 = x3 + x4
			local v10 = y3 + y4
			local v11

			if x3 < p.x and p.x < v9 and y3 < p.y then
				v11 = p.y < v10
			else
				v11 = false
			end

			if not v11 then
				v8 = true
				break
			end
		end

		parent = parent.Parent
	end

	return not v8
end

local function areGuisIntersecting(p, p2)
	local x = p.AbsolutePosition.x
	local y = p.AbsolutePosition.y
	local x2 = p.AbsoluteSize.x
	local y2 = p.AbsoluteSize.y
	local v5 = x + x2
	local v6 = y + y2
	local x3 = p2.AbsolutePosition.x
	local y3 = p2.AbsolutePosition.y
	local x4 = p2.AbsoluteSize.x
	local y4 = p2.AbsoluteSize.y
	local v7 = x3 + x4
	local v8 = y3 + y4
	return x < v7 and x3 < v5 and y < v8 and y3 < v6
end

local function isGuiVisible(p, _)
	local parent = p
	local v5

	while true do
		if parent == nil or not (parent:IsA("GuiObject") or parent:IsA("LayerCollector")) then
			v5 = not (parent and parent:IsA("CoreGui"))
			break
		end

		if parent:IsA("GuiObject") and not parent.Visible then
			v5 = true
			break
		end

		if parent:IsA("LayerCollector") or parent.ClipsDescendants then
			local x = parent.AbsolutePosition.x
			local y = parent.AbsolutePosition.y
			local x2 = parent.AbsoluteSize.x
			local y2 = parent.AbsoluteSize.y
			local v6 = x + x2
			local v7 = y + y2
			local x3 = p.AbsolutePosition.x
			local y3 = p.AbsolutePosition.y
			local x4 = p.AbsoluteSize.x
			local y4 = p.AbsoluteSize.y
			local v8 = x3 + x4
			local v9 = y3 + y4
			local v10

			if x < v8 then
				v10 = x3 < v6
			else
				v10 = false
			end

			local v11

			if y < v9 then
				v11 = y3 < v7
			else
				v11 = false
			end

			if not (v10 and v11) then
				v5 = true
				break
			end
		end

		parent = parent.Parent
	end

	return not v5
end

local function addHoverState(data, p, fn, fn2)
	local function onNormalButtonStateCallback()
		if data.Active then
			fn(p)
		end
	end

	local function onHoverButtonStateCallback()
		if data.Active then
			fn2(p)
		end
	end

	data.MouseEnter:Connect(onHoverButtonStateCallback)
	data.SelectionGained:Connect(onHoverButtonStateCallback)
	data.MouseLeave:Connect(onNormalButtonStateCallback)
	data.SelectionLost:Connect(onNormalButtonStateCallback)
	fn(p)
end

local function addOnResizedCallback(p, callback)
	v3[p] = callback
	callback(getViewportSize(), isPortrait())
end

local v5 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}

local function MakeDefaultButton(p, size, callback, p3, p4)
	local selectionImageObject2 = v2.Create("ImageLabel")({
		Image = "",
		BackgroundTransparency = 1
	})
	local parent = v2.Create("ImageButton")({
		Name = p .. "Button",
		Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 6, 46, 44),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = size,
		ZIndex = 2,
		SelectionImageObject = selectionImageObject2
	})
	v2.Create("BoolValue")({
		Name = "Enabled",
		Parent = parent,
		Value = true
	})

	if callback then
		parent.MouseButton1Click:Connect(function()
			callback(v5[UserInputService:GetLastInputType()] or false)
		end)
	end

	local function isPointerInput(p5)
		return p5.UserInputType == Enum.UserInputType.MouseMovement or p5.UserInputType == Enum.UserInputType.Touch
	end

	local v8 = nil

	local function setRowRef(p5)
		v8 = p5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function selectButton()
		local hubRef = p4

		if hubRef == nil and p3 then
			hubRef = p3.HubRef
		end

		if hubRef and hubRef.Active or hubRef == nil then
			parent.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButtonSelected.png"
			local v9 = parent

			if v8 then
				v9 = v8
			end

			if hubRef then
				hubRef:ScrollToFrame(v9)
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function deselectButton()
		parent.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
	end

	parent.InputBegan:Connect(function(input)
		if parent.Selectable and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			selectButton() -- equivalent call inferred; original call site unknown
		end
	end)
	parent.InputEnded:Connect(function(input)
		if parent.Selectable and GuiService.SelectedCoreObject ~= parent and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			deselectButton() -- equivalent call inferred; original call site unknown
		end
	end)
	parent.SelectionGained:Connect(function()
		selectButton() -- equivalent call inferred; original call site unknown
	end)
	parent.SelectionLost:Connect(function()
		deselectButton() -- equivalent call inferred; original call site unknown
	end)
	GuiService.Changed:Connect(function(p5)
		if p5 ~= "SelectedCoreObject" then
			return
		end

		-- equivalent call inferred; original call site unknown
		if not usesSelectedObject() then
			return
		end

		if GuiService.SelectedCoreObject == nil or GuiService.SelectedCoreObject ~= parent then
			deselectButton() -- equivalent call inferred; original call site unknown
		elseif parent.Selectable then
			selectButton() -- equivalent call inferred; original call site unknown
		end
	end)
	return parent, setRowRef
end

local function MakeButton(p, text, size, p4, p5, p6)
	local parent, v7 = MakeDefaultButton(p, size, p4, p5, p6)
	local v8 = v2.Create("TextLabel")({
		Name = p .. "TextLabel",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -8),
		Position = UDim2.new(0, 0, 0, 0),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextYAlignment = Enum.TextYAlignment.Center,
		Font = Enum.Font.SourceSansBold,
		TextSize = 24,
		Text = text,
		TextScaled = true,
		TextWrapped = true,
		ZIndex = 2,
		Parent = parent
	})
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint", v8)

	if isSmallTouchScreen() then
		v8.TextSize = 18
	end

	uITextSizeConstraint.MaxTextSize = v8.TextSize
	return parent, v8, v7
end

local function MakeImageButton(p, image, size, size2, p5, p6, p7)
	local parent, v7 = MakeDefaultButton(p, size, p5, p6, p7)
	return parent, v2.Create("ImageLabel")({
		Name = p .. "ImageLabel",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = size2,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = image,
		ZIndex = 2,
		Parent = parent
	}), v7
end

local function AddButtonRow(p, p2, text, size, p5, p6)
	local v6, v7, v8 = MakeButton(p2, text, size, p5, p, p6)
	local parent = v2.Create("Frame")({
		Name = p2 .. "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, size.Y.Scale, size.Y.Offset),
		Parent = p.Page
	})
	v6.Parent = parent
	v6.AnchorPoint = Vector2.new(1, 0)
	v6.Position = UDim2.new(1, -20, 0, 0)
	return parent, v6, v7, v8
end

local function CreateDropDown(p, p2, object)
	local color6 = Color3.fromRGB(178, 178, 178)
	local color7 = Color3.fromRGB(229, 229, 229)
	local color8 = Color3.fromRGB(255, 255, 255)
	local dropDownFrame = nil
	local result2 = {
		CurrentIndex = nil
	}
	local bindableEvent_2 = Instance.new("BindableEvent")
	bindableEvent_2.Name = "IndexChanged"

	if type(p) ~= "table" then
		error("CreateDropDown dropDownStringTable (first arg) is not a table", 2)
		return result2
	end

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "IndexChanged"
	local selectable = true
	local GUID = HttpService:GenerateGUID(false)
	local enabled = nil
	local v7 = p
	local parent = v2.Create("ImageButton")({
		Name = "DropDownFullscreenFrame",
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 10,
		Active = true,
		Visible = false,
		Selectable = false,
		AutoButtonColor = false,
		Parent = playerGui.RobloxGui
	})

	local function onVREnabled(p3)
		if p3 ~= "VREnabled" then
			return
		end

		if VRService.VREnabled then
			local Panel3D = require(playerGui.RobloxGui.Modules.VR.Panel3D)
			parent.Parent = Panel3D.Get("SettingsMenu"):GetGUI()
			parent.BackgroundTransparency = 1
		else
			parent.Parent = playerGui.RobloxGui
			parent.BackgroundTransparency = 0.2
		end

		if result2.UpdateDropDownList then
			result2:UpdateDropDownList(v7)
		end
	end

	VRService.Changed:Connect(onVREnabled)
	onVREnabled("VREnabled")
	local parent2 = v2.Create("ImageLabel")({
		Name = "DropDownSelectionFrame",
		Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 6, 46, 44),
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 0.9, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 10,
		Parent = parent
	})
	local parent3 = v2.Create("ScrollingFrame")({
		Name = "DropDownScrollingFrame",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -20, 1, -25),
		Position = UDim2.new(0, 10, 0, 10),
		ZIndex = 10,
		Parent = parent2
	})
	local selectedCoreObjectChangedConnection = nil
	local v11 = false

	local function onMouseButton1Click(p3, p4)
		if p3 ~= nil and p4 ~= Enum.UserInputState.Begin then
			return
		end

		result2.DropDownFrame.Selectable = selectable
		object:SetActive(true)

		if parent.Visible then
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = dropDownFrame
			end
		end

		parent.Visible = false

		if selectedCoreObjectChangedConnection then
			selectedCoreObjectChangedConnection:Disconnect()
		end

		ContextActionService:UnbindAction(GUID .. "Action")
		ContextActionService:UnbindAction(GUID .. "FreezeAction")
		enabled.Value = selectable
		v11 = false

		if VRService.VREnabled then
			local Panel3D = require(playerGui.RobloxGui.Modules.VR.Panel3D)
			Panel3D.Get("SettingsMenu"):SetSubpanelDepth(parent, 0)
		end
	end

	local function fn() end

	local function fn2()
		if not selectable then
			return
		end

		result2.DropDownFrame.Selectable = false
		v11 = true
		parent.Visible = true

		if VRService.VREnabled then
			local Panel3D = require(playerGui.RobloxGui.Modules.VR.Panel3D)
			Panel3D.Get("SettingsMenu"):SetSubpanelDepth(parent, 0.5)
		end

		dropDownFrame = result2.DropDownFrame

		if result2.CurrentIndex and result2.CurrentIndex > 0 then
			GuiService.SelectedCoreObject = result2.Selections[result2.CurrentIndex]
		end

		selectedCoreObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedCoreObject"):Connect(function()
			for i = 1, #result2.Selections do
				if GuiService.SelectedCoreObject == result2.Selections[i] then
					result2.Selections[i].TextColor3 = color8
				else
					result2.Selections[i].TextColor3 = VRService.VREnabled and color7 or color6
				end
			end
		end)
		ContextActionService:BindActionAtPriority(
			GUID .. "FreezeAction",
			fn,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.UserInputType.Keyboard,
			Enum.UserInputType.Gamepad1
		)
		ContextActionService:BindActionAtPriority(
			GUID .. "Action",
			onMouseButton1Click,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.ButtonB,
			Enum.KeyCode.Escape
		)
		object:SetActive(false)
		enabled.Value = false
	end

	result2.DropDownFrame = MakeButton("DropDownFrame", "Choose One", UDim2.new(0.6, 0, 0, 50), fn2, nil, object)
	result2.DropDownFrame.Position = UDim2.new(1, 0, 0.5, 0)
	result2.DropDownFrame.AnchorPoint = Vector2.new(1, 0.5)
	enabled = result2.DropDownFrame.Enabled
	local dropDownFrameTextLabel = result2.DropDownFrame.DropDownFrameTextLabel
	dropDownFrameTextLabel.Position = UDim2.new(0, 15, 0, 0)
	dropDownFrameTextLabel.Size = UDim2.new(1, -50, 1, -8)
	dropDownFrameTextLabel.ClipsDescendants = true
	dropDownFrameTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	local dropDownImage = v2.Create("ImageLabel")({
		Name = "DropDownImage",
		Image = "rbxasset://textures/ui/Settings/DropDown/DropDown.png",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 15, 0, 10),
		Position = UDim2.new(1, -12, 0.5, 0),
		ZIndex = 2,
		Parent = result2.DropDownFrame
	})
	result2.DropDownImage = dropDownImage

	local function setSelection(p3)
		local flag = false

		for k, selection in pairs(result2.Selections) do
			if k ~= p3 then
				continue
			end

			dropDownFrameTextLabel.Text = selection.Text
			result2.CurrentIndex = k
			flag = true
		end

		if flag then
			bindableEvent:Fire(p3)
		end
	end

	local function setSelectionByValue(p3)
		local flag = false

		for k, selection in pairs(result2.Selections) do
			if selection.Text ~= p3 then
				continue
			end

			dropDownFrameTextLabel.Text = selection.Text
			result2.CurrentIndex = k
			flag = true
		end

		if flag then
			bindableEvent:Fire(result2.CurrentIndex)
		end

		return flag
	end

	local v13 = false

	local function processInput(p3)
		if p3.UserInputState == Enum.UserInputState.Begin then
			if p3.KeyCode == Enum.KeyCode.Return and (GuiService.SelectedCoreObject == result2.DropDownFrame or result2.SelectionInfo and result2.SelectionInfo[GuiService.SelectedCoreObject]) then
				v13 = true
			end
		elseif p3.UserInputState == Enum.UserInputState.End and p3.KeyCode == Enum.KeyCode.Return and v13 then
			v13 = false

			if GuiService.SelectedCoreObject == result2.DropDownFrame then
				fn2()
			elseif result2.SelectionInfo and result2.SelectionInfo[GuiService.SelectedCoreObject] then
				result2.SelectionInfo[GuiService.SelectedCoreObject].Clicked()
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setIsFaded(vREnabled)
		if vREnabled then
			result2.DropDownFrame.DropDownFrameTextLabel.TextTransparency = 0.5
			result2.DropDownFrame.ImageTransparency = 0.5
			result2.DropDownImage.ImageTransparency = 0.5
		else
			result2.DropDownFrame.DropDownFrameTextLabel.TextTransparency = 0
			result2.DropDownFrame.ImageTransparency = 0
			result2.DropDownImage.ImageTransparency = 0
		end
	end

	result2.IndexChanged = bindableEvent.Event

	function result2:SetSelectionIndex(p3)
		setSelection(p3)
	end

	function result2.SetSelectionByValue(_, p3)
		return (setSelectionByValue(p3))
	end

	function result2.ResetSelectionIndex(_)
		result2.CurrentIndex = nil
		dropDownFrameTextLabel.Text = "Choose One"
		onMouseButton1Click()
	end

	function result2.GetSelectedIndex(_)
		return result2.CurrentIndex
	end

	function result2:SetZIndex(zIndex)
		result2.DropDownFrame.ZIndex = zIndex
		dropDownImage.ZIndex = zIndex
		dropDownFrameTextLabel.ZIndex = zIndex
	end

	function result2.SetInteractable(_, p3)
		selectable = p3
		result2.DropDownFrame.Selectable = selectable

		if selectable then
			result2.DropDownFrame.DropDownFrameTextLabel.TextTransparency = 0
			result2.DropDownFrame.ImageTransparency = 0
			result2.DropDownImage.ImageTransparency = 0

			if not VRService.VREnabled then
				result2:SetZIndex(2)
			end
		else
			onMouseButton1Click()
			setIsFaded(VRService.VREnabled) -- equivalent call inferred; original call site unknown

			if not VRService.VREnabled then
				result2:SetZIndex(1)
			end
		end

		enabled.Value = p3 and not v11
	end

	function result2:UpdateDropDownList(list)
		v7 = list

		if result2.Selections then
			for i = 1, #result2.Selections do
				result2.Selections[i]:Destroy()
			end
		end

		result2.Selections = {}
		result2.SelectionInfo = {}
		local vREnabled = VRService.VREnabled
		local sourceSansBold = vREnabled and Enum.Font.SourceSansBold or Enum.Font.SourceSans
		local v14 = vREnabled and 70 or 50
		local v15 = v14 + 1
		local textSize = vREnabled and 36 or 24
		local v17 = vREnabled and 600 or 400

		for k, text in pairs(list) do
			local selectionImageObject2 = v2.Create("Frame")({
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0)
			})
			local selectedCoreObject = v2.Create("TextButton")({
				Name = "Selection" .. tostring(k),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Size = UDim2.new(1, -28, 0, v14),
				Position = UDim2.new(0, 14, 0, (k - 1) * v15),
				TextColor3 = VRService.VREnabled and color7 or color6,
				Font = sourceSansBold,
				TextSize = textSize,
				Text = text,
				ZIndex = 10,
				SelectionImageObject = selectionImageObject2,
				Parent = parent3
			})

			if k == p2 then
				result2.CurrentIndex = k
				dropDownFrameTextLabel.Text = text
				selectedCoreObject.TextColor3 = color8
			elseif not p2 and k == 1 then
				selectedCoreObject.TextColor3 = color8
			end

			local currentIndex = k

			local function onMouseButton1Click2()
				dropDownFrameTextLabel.Text = selectedCoreObject.Text
				onMouseButton1Click()
				result2.CurrentIndex = currentIndex
				bindableEvent:Fire(currentIndex)
			end

			selectedCoreObject.MouseButton1Click:Connect(onMouseButton1Click2)
			local selectedCoreObject2 = selectedCoreObject
			selectedCoreObject.MouseEnter:Connect(function()
				-- equivalent call inferred; original call site unknown
				if usesSelectedObject() then
					GuiService.SelectedCoreObject = selectedCoreObject2
				end
			end)
			result2.Selections[k] = selectedCoreObject
			result2.SelectionInfo[selectedCoreObject] = {
				Clicked = onMouseButton1Click2
			}
		end

		GuiService:RemoveSelectionGroup(GUID)
		GuiService:AddSelectionTuple(GUID, unpack(result2.Selections))
		parent3.CanvasSize = UDim2.new(1, -20, 0, #list * v15)

		local function updateDropDownSize()
			if parent3.CanvasSize.Y.Offset < parent.AbsoluteSize.Y - 10 then
				parent2.Size = UDim2.new(0, v17, 0, parent3.CanvasSize.Y.Offset + 25)
			else
				parent2.Size = UDim2.new(0, v17, 0.9, 0)
			end
		end

		parent.Changed:Connect(function(p3)
			if p3 ~= "AbsoluteSize" then
				return
			end

			updateDropDownSize()
		end)
		updateDropDownSize()
	end

	result2:UpdateDropDownList(p)
	parent.MouseButton1Click:Connect(onMouseButton1Click)
	object.PoppedMenu:Connect(function(p3)
		if p3 == parent then
			onMouseButton1Click()
		end
	end)
	return result2
end

local function CreateSelector(p, p2)
	local v6 = 0
	local result2 = {
		HubRef = nil
	}

	if type(p) ~= "table" then
		error("CreateSelector selectionStringTable (first arg) is not a table", 2)
		return result2
	end

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "IndexChanged"
	local v7 = true
	result2.CurrentIndex = 0
	result2.SelectorFrame = v2.Create("ImageButton")({
		Name = "Selector",
		Image = "",
		AutoButtonColor = false,
		NextSelectionLeft = result2.SelectorFrame,
		NextSelectionRight = result2.SelectorFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ZIndex = 2,
		SelectionImageObject = selectionImageObject
	})
	local parent2 = v2.Create("ImageButton")({
		Name = "LeftButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "",
		ZIndex = 3,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Parent = result2.SelectorFrame
	})
	local parent3 = v2.Create("ImageButton")({
		Name = "RightButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "",
		ZIndex = 3,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Parent = result2.SelectorFrame
	})
	local v10 = v2.Create("ImageLabel")({
		Name = "LeftButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 30),
		Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
		ImageColor3 = color3,
		ZIndex = 4,
		Parent = parent2
	})
	local v11 = v2.Create("ImageLabel")({
		Name = "RightButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 30),
		Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
		ImageColor3 = color3,
		ZIndex = 4,
		Parent = parent3
	})

	if not UserInputService.TouchEnabled then
		local function fn(p3)
			p3.ImageColor3 = color3
		end

		local function fn2(p3)
			p3.ImageColor3 = color4
		end

		addHoverState(parent2, v10, fn, fn2)
		addHoverState(parent3, v11, fn, fn2)
	end

	result2.Selections = {}
	local v12 = {}
	local v13 = {}
	local v14 = v2.Create("ImageButton")({
		Name = "AutoSelectButton",
		BackgroundTransparency = 1,
		Image = "",
		Position = UDim2.new(0, parent2.Size.X.Offset, 0, 0),
		Size = UDim2.new(1, parent2.Size.X.Offset * -2, 1, 0),
		Parent = result2.SelectorFrame,
		ZIndex = 2,
		SelectionImageObject = selectionImageObject
	})
	v14.MouseButton1Click:Connect(function()
		if not v7 or #result2.Selections <= 1 then
			return
		end

		local v15 = result2.CurrentIndex + 1
		result2:SetSelectionIndex(#result2.Selections < v15 and 1 or v15)

		-- equivalent call inferred; original call site unknown
		if usesSelectedObject() then
			GuiService.SelectedCoreObject = result2.SelectorFrame
		end
	end)
	v13[v14] = true

	local function setSelection(p3, p4)
		for k, selection in pairs(result2.Selections) do
			local v15 = k == p3
			local uDim = UDim2.new(0, parent2.Size.X.Offset, 0, 0)
			local uDim2 = UDim2.new(0, parent2.Size.X.Offset * p4 * 3, 0, 0)

			if v12[selection] then
				uDim2 = UDim2.new(0, parent2.Size.X.Offset * -p4 * 3, 0, 0)
			end

			if uDim2.X.Offset < 0 then
				uDim2 = UDim2.new(0, uDim2.X.Offset + selection.AbsoluteSize.X / 4, 0, 0)
			end

			if v15 then
				v12[selection] = true
				selection.Position = uDim2
				selection.Visible = true
				PropertyTweener(selection, "TextTransparency", 1, 0, 0.165, EaseOutQuad)

				if selection:IsDescendantOf(game) then
					selection:TweenPosition(uDim, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.15, true)
				else
					selection.Position = uDim
				end

				result2.CurrentIndex = k
				bindableEvent:Fire(p3)
			elseif v12[selection] then
				v12[selection] = false
				PropertyTweener(selection, "TextTransparency", 0, 1, 0.165, EaseOutQuad)

				if selection:IsDescendantOf(game) then
					selection:TweenPosition(uDim2, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.135, true)
				else
					selection.Position = UDim2.new(uDim2)
				end
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stepFunc(input, p3)
		if not v7 then
			return
		end

		if input ~= nil and input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Gamepad2 and input.UserInputType ~= Enum.UserInputType.Gamepad3 and input.UserInputType ~= Enum.UserInputType.Gamepad4 and input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		-- equivalent call inferred; original call site unknown
		if usesSelectedObject() then
			GuiService.SelectedCoreObject = result2.SelectorFrame
		end

		local v15 = p3 + result2.CurrentIndex
		local v16 = result2.CurrentIndex < v15 and 1 or -1
		setSelection(#result2.Selections < v15 and 1 or v15 < 1 and #result2.Selections or v15, v16)
	end

	local selectedCoreObjectChangedConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function connectToGuiService()
		selectedCoreObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedCoreObject"):Connect(function()
			if #result2.Selections <= 0 then
				return
			end

			if GuiService.SelectedCoreObject == result2.SelectorFrame then
				result2.Selections[result2.CurrentIndex].TextTransparency = 0
			elseif GuiService.SelectedCoreObject == nil or not v13[GuiService.SelectedCoreObject] then
				result2.Selections[result2.CurrentIndex].TextTransparency = 0.5
			elseif VRService.VREnabled then
				result2.Selections[result2.CurrentIndex].TextTransparency = 0
			else
				GuiService.SelectedCoreObject = result2.SelectorFrame
			end
		end)
	end

	result2.IndexChanged = bindableEvent.Event

	function result2:SetSelectionIndex(p3)
		setSelection(p3, 1)
	end

	function result2.GetSelectedIndex(_)
		return result2.CurrentIndex
	end

	function result2:SetZIndex(zIndex)
		parent2.ZIndex = zIndex
		parent3.ZIndex = zIndex
		v10.ZIndex = zIndex
		v11.ZIndex = zIndex

		for i = 1, #result2.Selections do
			result2.Selections[i].ZIndex = zIndex
		end
	end

	function result2.SetInteractable(_, p3)
		v7 = p3
		result2.SelectorFrame.Selectable = v7
		parent2.Active = v7
		parent3.Active = v7

		if v7 then
			for _, selection in pairs(result2.Selections) do
				selection.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			v10.ImageColor3 = color3
			v11.ImageColor3 = color3
		else
			for _, selection in pairs(result2.Selections) do
				selection.TextColor3 = Color3.fromRGB(49, 49, 49)
			end

			v10.ImageColor3 = color5
			v11.ImageColor3 = color5
		end
	end

	function result2:UpdateOptions(items)
		for _, selection in pairs(result2.Selections) do
			selection:Destroy()
		end

		v12 = {}
		result2.Selections = {}

		for k, item in pairs(items) do
			local v15 = v2.Create("TextLabel")({
				Name = "Selection" .. tostring(k),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, parent2.Size.X.Offset * -2, 1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextYAlignment = Enum.TextYAlignment.Center,
				TextTransparency = 0.5,
				Font = Enum.Font.SourceSans,
				TextSize = 24,
				Text = item,
				ZIndex = 2,
				Visible = false,
				Parent = result2.SelectorFrame
			})

			if k == p2 then
				result2.CurrentIndex = k
				v15.Position = UDim2.new(0, parent2.Size.X.Offset, 0, 0)
				v15.Visible = true
				v12[v15] = true
			else
				v12[v15] = false
			end

			result2.Selections[k] = v15
		end

		local visible = #result2.Selections > 1
		parent2.Visible = visible
		parent3.Visible = visible
	end

	local function onVREnabled(p3)
		if p3 ~= "VREnabled" then
			return
		end

		local vREnabled = VRService.VREnabled
		parent2.Selectable = vREnabled
		parent3.Selectable = vREnabled
		v14.Selectable = vREnabled
	end

	VRService.Changed:Connect(onVREnabled)
	local vREnabled = VRService.VREnabled
	parent2.Selectable = vREnabled
	parent3.Selectable = vREnabled
	v14.Selectable = vREnabled
	parent2.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if not v7 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = result2.SelectorFrame
			end

			local v15 = -1 + result2.CurrentIndex
			local v16 = result2.CurrentIndex < v15 and 1 or -1
			setSelection(#result2.Selections < v15 and 1 or v15 < 1 and #result2.Selections or v15, v16)
		end
	end)
	parent2.MouseButton1Click:Connect(function()
		if not UserInputService.TouchEnabled then
			if not v7 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = result2.SelectorFrame
			end

			local v15 = -1 + result2.CurrentIndex
			local v16 = result2.CurrentIndex < v15 and 1 or -1
			setSelection(#result2.Selections < v15 and 1 or v15 < 1 and #result2.Selections or v15, v16)
		end
	end)
	parent3.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			if not v7 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = result2.SelectorFrame
			end

			local v15 = 1 + result2.CurrentIndex
			local v16 = result2.CurrentIndex < v15 and 1 or -1
			setSelection(#result2.Selections < v15 and 1 or v15 < 1 and #result2.Selections or v15, v16)
		end
	end)
	parent3.MouseButton1Click:Connect(function()
		if not UserInputService.TouchEnabled then
			if not v7 then
				return
			end

			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = result2.SelectorFrame
			end

			local v15 = 1 + result2.CurrentIndex
			local v16 = result2.CurrentIndex < v15 and 1 or -1
			setSelection(#result2.Selections < v15 and 1 or v15 < 1 and #result2.Selections or v15, v16)
		end
	end)
	local v15 = true
	result2:UpdateOptions(p)
	UserInputService.InputBegan:Connect(function(input)
		if not v7 or not v15 or input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Keyboard or GuiService.SelectedCoreObject ~= result2.SelectorFrame then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.A then
			stepFunc(input, -1) -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.DPadRight or input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.D then
			stepFunc(input, 1) -- equivalent call inferred; original call site unknown
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not v7 then
			return
		end

		if not v15 then
			v6 = 0
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		local selectedCoreObject = GuiService.SelectedCoreObject

		if not (selectedCoreObject and selectedCoreObject:IsDescendantOf(result2.SelectorFrame.Parent) and input.KeyCode == Enum.KeyCode.Thumbstick1) then
			return
		end

		if input.Position.X > 0.8 and input.Delta.X > 0 and v6 ~= 1 then
			v6 = 1
			stepFunc(input, v6)
		elseif input.Position.X < -0.8 and input.Delta.X < 0 and v6 ~= -1 then
			v6 = -1
			stepFunc(input, v6)
		elseif math.abs(input.Position.X) < 0.8 then
			v6 = 0
		end
	end)
	result2.SelectorFrame.AncestryChanged:Connect(function(_, parent)
		v15 = parent

		if v15 then
			connectToGuiService() -- equivalent call inferred; original call site unknown
		elseif selectedCoreObjectChangedConnection then
			selectedCoreObjectChangedConnection:Disconnect()
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onResized(_, p3)
		local textSize = p3 and 16 or 24

		for _, selection in pairs(result2.Selections) do
			selection.TextSize = textSize
		end
	end

	local selectorFrame = result2.SelectorFrame
	v3[selectorFrame] = onResized
	getViewportSize()
	onResized(nil, isPortrait()) -- equivalent call inferred; original call site unknown
	selectedCoreObjectChangedConnection = GuiService:GetPropertyChangedSignal("SelectedCoreObject"):Connect(function()
		if #result2.Selections <= 0 then
			return
		end

		if GuiService.SelectedCoreObject == result2.SelectorFrame then
			result2.Selections[result2.CurrentIndex].TextTransparency = 0
		elseif GuiService.SelectedCoreObject == nil or not v13[GuiService.SelectedCoreObject] then
			result2.Selections[result2.CurrentIndex].TextTransparency = 0.5
		elseif VRService.VREnabled then
			result2.Selections[result2.CurrentIndex].TextTransparency = 0
		else
			GuiService.SelectedCoreObject = result2.SelectorFrame
		end
	end)
	return result2
end

local function ShowAlert(text, p2, object, callback, p3)
	local robloxGui = playerGui.RobloxGui

	if robloxGui:FindFirstChild("AlertViewFullScreen") then
		return
	end

	local parent = nil

	local function onVREnabled(p4)
		if p4 ~= "VREnabled" then
			return
		end

		local settingsMenu = nil

		if VRService.VREnabled then
			local Panel3D = require(playerGui.RobloxGui.Modules.VR.Panel3D)
			settingsMenu = Panel3D.Get("SettingsMenu")
			robloxGui = settingsMenu:GetGUI()
		else
			robloxGui = playerGui.RobloxGui
		end

		if parent and parent.Parent ~= nil then
			parent.Parent = robloxGui

			if VRService.VREnabled then
				settingsMenu:SetSubpanelDepth(parent, 0.5)
			end
		end
	end

	local changedConnection = VRService.Changed:Connect(onVREnabled)
	Color3.fromRGB(59, 166, 241)
	Color3.fromRGB(255, 255, 255)
	parent = v2.Create("ImageLabel")({
		Name = "AlertViewBacking",
		Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8, 6, 46, 44),
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Size = UDim2.new(0, 400, 0, 350),
		Position = UDim2.new(0.5, -200, 0.5, -175),
		ZIndex = 9,
		Parent = robloxGui
	})
	onVREnabled("VREnabled")

	if p3 or VRService.VREnabled then
		parent.ImageTransparency = 0
	else
		parent.Size = UDim2.new(0.8, 0, 0, 350)
		parent.Position = UDim2.new(0.1, 0, 0.1, 0)
	end

	if playerGui.RobloxGui.AbsoluteSize.Y <= parent.Size.Y.Offset then
		parent.Size = UDim2.new(
			parent.Size.X.Scale,
			parent.Size.X.Offset,
			parent.Size.Y.Scale,
			playerGui.RobloxGui.AbsoluteSize.Y
		)
		parent.Position = UDim2.new(parent.Position.X.Scale, -parent.Size.X.Offset / 2, 0.5, -parent.Size.Y.Offset / 2)
	end

	v2.Create("TextLabel")({
		Name = "AlertViewText",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.95, 0, 0.6, 0),
		Position = UDim2.new(0.025, 0, 0.05, 0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 36,
		Text = text,
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 10,
		Parent = parent
	})
	v2.Create("ImageLabel")({
		Image = "",
		BackgroundTransparency = 1
	})
	local GUID = HttpService:GenerateGUID(false)

	local function fn(_, p4)
		if VRService.VREnabled and (p4 == Enum.UserInputState.Begin or p4 == Enum.UserInputState.Cancel) or not parent then
			return
		end

		if VRService.VREnabled then
			local Panel3D = require(playerGui.RobloxGui.Modules.VR.Panel3D)
			Panel3D.Get("SettingsMenu"):SetSubpanelDepth(parent, 0)
		end

		parent:Destroy()
		parent = nil

		if callback then
			callback()
		end

		ContextActionService:UnbindAction(GUID)
		GuiService.SelectedCoreObject = nil

		if object then
			object:ShowBar()
		end

		if changedConnection then
			changedConnection:Disconnect()
		end
	end

	local uDim = UDim2.new(1, -20, 0, 60)
	local uDim2 = UDim2.new(0, 10, 0.65, 0)

	if not p3 then
		uDim = UDim2.new(0, 200, 0, 50)
		uDim2 = UDim2.new(0.5, -100, 0.65, 0)
	end

	local v7, v8 = MakeButton("AlertViewButton", p2, uDim, fn)
	v7.Position = uDim2
	v7.NextSelectionLeft = v7
	v7.NextSelectionRight = v7
	v7.NextSelectionUp = v7
	v7.NextSelectionDown = v7
	v7.ZIndex = 9
	v8.ZIndex = v7.ZIndex
	v7.Parent = parent

	-- equivalent call inferred; original call site unknown
	if usesSelectedObject() then
		GuiService.SelectedCoreObject = v7
	end

	GuiService.SelectedCoreObject = v7
	ContextActionService:BindActionAtPriority(
		GUID,
		fn,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.Escape,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonA
	)

	if object and not VRService.VREnabled then
		object:HideBar()
		object.Pages.CurrentPage:Hide(1, 1)
	end
end

local function CreateNewSlider(p, p2, p3)
	local v6 = {}
	local v7 = tonumber(p)
	local v8 = p2
	local v9 = 0
	local lastTime = nil
	local v10 = true
	local GUID = HttpService:GenerateGUID(false)

	if v7 <= 0 then
		error(
			"CreateNewSlider failed because numOfSteps (first arg) is 0 or negative, please supply a positive integer",
			2
		)
		return
	end

	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Name = "ValueChanged"
	v6.SliderFrame = v2.Create("ImageButton")({
		Name = "Slider",
		Image = "",
		AutoButtonColor = false,
		NextSelectionLeft = v6.SliderFrame,
		NextSelectionRight = v6.SliderFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		SelectionImageObject = selectionImageObject,
		ZIndex = 2
	})
	v6.StepsContainer = v2.Create("Frame")({
		Name = "StepsContainer",
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -100, 1, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = v6.SliderFrame
	})
	local parent2 = v2.Create("ImageButton")({
		Name = "LeftButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "",
		ZIndex = 3,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Active = true,
		Parent = v6.SliderFrame
	})
	local parent3 = v2.Create("ImageButton")({
		Name = "RightButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "",
		ZIndex = 3,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Active = true,
		Parent = v6.SliderFrame
	})
	local v13 = v2.Create("ImageLabel")({
		Name = "LeftButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 30, 0, 30),
		Image = "rbxasset://textures/ui/Settings/Slider/Less.png",
		ZIndex = 4,
		Parent = parent2,
		ImageColor3 = UserInputService.TouchEnabled and color4 or color3
	})
	local v14 = v2.Create("ImageLabel")({
		Name = "RightButton",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 30, 0, 30),
		Image = "rbxasset://textures/ui/Settings/Slider/More.png",
		ZIndex = 4,
		Parent = parent3,
		ImageColor3 = UserInputService.TouchEnabled and color4 or color3
	})

	if not UserInputService.TouchEnabled then
		local function fn(p4)
			p4.ImageColor3 = color3
		end

		local function fn2(p4)
			p4.ImageColor3 = color4
		end

		addHoverState(parent2, v13, fn, fn2)
		addHoverState(parent3, v14, fn, fn2)
	end

	v6.Steps = {}
	local _ = isSmallTouchScreen() -- equivalent call inferred; original call site unknown
	local v15 = 1 / v7

	for i = 1, v7 do
		local v16 = v2.Create("ImageButton")({
			Name = "Step" .. tostring(i),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.36,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Active = false,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new((i - 1) * v15, 2, 0.5, 0),
			Size = UDim2.new(v15, -4, 0.48, 0),
			Image = "",
			ZIndex = 3,
			Selectable = false,
			ImageTransparency = 0.36,
			Parent = v6.StepsContainer,
			SelectionImageObject = selectionImageObject
		})

		if v8 < i then
			v16.BackgroundColor3 = color2
		end

		if i == 1 or i == v7 then
			v16.BackgroundTransparency = 1
			v16.ScaleType = Enum.ScaleType.Slice
			v16.SliceCenter = Rect.new(3, 3, 32, 21)

			if i <= v8 then
				if i == 1 then
					v16.Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarLeft.png"
				else
					v16.Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarRight.png"
				end
			elseif i == 1 then
				v16.Image = "rbxasset://textures/ui/Settings/Slider/BarLeft.png"
			else
				v16.Image = "rbxasset://textures/ui/Settings/Slider/BarRight.png"
			end
		end

		v6.Steps[#v6.Steps + 1] = v16
	end

	local function hideSelection()
		for i = 1, v7 do
			v6.Steps[i].BackgroundColor3 = color2

			if i == 1 then
				v6.Steps[1].Image = "rbxasset://textures/ui/Settings/Slider/BarLeft.png"
			elseif i == v7 then
				v6.Steps[i].Image = "rbxasset://textures/ui/Settings/Slider/BarRight.png"
			end
		end
	end

	local function showSelection()
		for i = 1, v7 do
			if v8 < i then
				break
			end

			v6.Steps[i].BackgroundColor3 = color

			if i == 1 then
				v6.Steps[1].Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarLeft.png"
			elseif i == v7 then
				v6.Steps[i].Image = "rbxasset://textures/ui/Settings/Slider/SelectedBarRight.png"
			end
		end
	end

	local function modifySelection(p4)
		for i = 1, v7 do
			if i == 1 or i == v7 then
				v6.Steps[i].ImageTransparency = p4
			else
				v6.Steps[i].BackgroundTransparency = p4
			end
		end
	end

	local function setCurrentStep(p4)
		if not p3 then
			p3 = 0
		end

		parent2.Visible = true
		parent3.Visible = true

		if p4 <= p3 then
			p4 = p3
			parent2.Visible = false
		end

		if v7 <= p4 then
			p4 = v7
			parent3.Visible = false
		end

		if v8 == p4 then
			return
		end

		v8 = p4
		hideSelection()
		showSelection()
		lastTime = tick()
		bindableEvent:Fire(v8)
	end

	local function isActivateEvent(p4)
		if not p4 then
			return false
		end

		if p4.UserInputType == Enum.UserInputType.MouseButton1 or p4.UserInputType == Enum.UserInputType.Touch then
			return true
		elseif p4.UserInputType == Enum.UserInputType.Gamepad1 then
			return p4.KeyCode == Enum.KeyCode.ButtonA
		else
			return false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mouseDownFunc(p4, p5, p6)
		if not (v10 and p4 ~= nil) then
			return
		end

		local v16

		if p4 then
			if p4.UserInputType == Enum.UserInputType.MouseButton1 or p4.UserInputType == Enum.UserInputType.Touch then
				v16 = true
			elseif p4.UserInputType == Enum.UserInputType.Gamepad1 then
				v16 = p4.KeyCode == Enum.KeyCode.ButtonA
			else
				v16 = false
			end
		else
			v16 = false
		end

		if not v16 then
			return
		end

		local v17 = usesSelectedObject() -- equivalent call inferred; original call site unknown

		if v17 and not VRService.VREnabled then
			GuiService.SelectedCoreObject = v6.SliderFrame
		end

		if VRService.VREnabled then
			v9 = 0
		elseif p6 then
			v9 = p5 - v8
		else
			v9 = 0
			local inputEndedConnection = nil
			local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseMovement then
					return
				end

				local X = input.Position.X

				for i = 1, v7 do
					local X2 = v6.Steps[i].AbsolutePosition.X
					local X3 = v6.Steps[i].AbsoluteSize.X

					if X2 <= X and X <= X2 + X3 then
						setCurrentStep(i)
						break
					end

					if i == 1 and X < X2 then
						setCurrentStep(0)
						break
					end

					if not (i == v7 and X2 <= X) then
						continue
					end

					setCurrentStep(i)
					break
				end
			end)
			inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
				local v18

				if input then
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						v18 = true
					elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
						v18 = input.KeyCode == Enum.KeyCode.ButtonA
					else
						v18 = false
					end
				else
					v18 = false
				end

				if not v18 then
					return
				end

				v9 = 0
				inputEndedConnection:Disconnect()
				inputChangedConnection:Disconnect()
			end)
		end

		setCurrentStep(p5)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function mouseUpFunc(input)
		if not v10 then
			return
		end

		local v16

		if input then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v16 = true
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
				v16 = input.KeyCode == Enum.KeyCode.ButtonA
			else
				v16 = false
			end
		else
			v16 = false
		end

		if not v16 then
			return
		end

		v9 = 0
	end

	local function touchClickFunc(p4, p5, p6)
		mouseDownFunc(p4, p5, p6)
	end

	v6.ValueChanged = bindableEvent.Event

	function v6.SetValue(_, p4)
		setCurrentStep(p4)
	end

	function v6.GetValue(_)
		return v8
	end

	function v6.SetInteractable(_, selectable)
		v9 = 0
		v10 = selectable
		v6.SliderFrame.Selectable = selectable

		if v10 then
			showSelection()
		else
			hideSelection()
		end
	end

	function v6:SetZIndex(zIndex)
		parent2.ZIndex = zIndex
		parent3.ZIndex = zIndex
		v13.ZIndex = zIndex
		v14.ZIndex = zIndex

		for i = 1, #v6.Steps do
			v6.Steps[i].ZIndex = zIndex
		end
	end

	function v6.SetMinStep(_, p4)
		if p4 >= 0 and p4 <= v7 then
			p3 = p4
		end

		if v8 <= p3 then
			v8 = p3
			parent2.Visible = false
		end

		if v7 <= v8 then
			v8 = v7
			parent3.Visible = false
		end
	end

	parent2.InputBegan:Connect(function(input)
		mouseDownFunc(input, v8 - 1, true) -- equivalent call inferred; original call site unknown
	end)
	parent2.InputEnded:Connect(function(input)
		if not v10 then
			return
		end

		local v16

		if input then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v16 = true
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
				v16 = input.KeyCode == Enum.KeyCode.ButtonA
			else
				v16 = false
			end
		else
			v16 = false
		end

		if not v16 then
			return
		end

		v9 = 0
	end)
	parent3.InputBegan:Connect(function(input)
		mouseDownFunc(input, v8 + 1, true) -- equivalent call inferred; original call site unknown
	end)
	parent3.InputEnded:Connect(function(input)
		if not v10 then
			return
		end

		local v16

		if input then
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v16 = true
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
				v16 = input.KeyCode == Enum.KeyCode.ButtonA
			else
				v16 = false
			end
		else
			v16 = false
		end

		if not v16 then
			return
		end

		v9 = 0
	end)

	local function onVREnabled(p4)
		if p4 ~= "VREnabled" then
			return
		end

		if VRService.VREnabled then
			parent2.Selectable = v10
			parent3.Selectable = v10
			v6.SliderFrame.Selectable = v10

			for i = 1, v7 do
				v6.Steps[i].Selectable = v10
				v6.Steps[i].Active = v10
			end
		else
			parent2.Selectable = false
			parent3.Selectable = false
			v6.SliderFrame.Selectable = v10

			for i = 1, v7 do
				v6.Steps[i].Selectable = false
				v6.Steps[i].Active = false
			end
		end
	end

	VRService.Changed:Connect(onVREnabled)
	onVREnabled("VREnabled")

	for i = 1, v7 do
		local v16 = i
		v6.Steps[i].InputBegan:Connect(function(input)
			mouseDownFunc(input, v16)
		end)
		v6.Steps[i].InputEnded:Connect(function(input)
			if not v10 then
				return
			end

			local v17

			if input then
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					v17 = true
				elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
					v17 = input.KeyCode == Enum.KeyCode.ButtonA
				else
					v17 = false
				end
			else
				v17 = false
			end

			if not v17 then
				return
			end

			v9 = 0
		end)
	end

	v6.SliderFrame.InputBegan:Connect(function(input)
		if VRService.VREnabled then
			local selectedCoreObject = GuiService.SelectedCoreObject

			if not (selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent)) then
				return
			end
		end

		mouseDownFunc(input, v8)
	end)
	v6.SliderFrame.InputEnded:Connect(function(input)
		if VRService.VREnabled then
			local selectedCoreObject = GuiService.SelectedCoreObject

			if not (selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent)) then
				return
			end
		end

		mouseUpFunc(input) -- equivalent call inferred; original call site unknown
	end)

	local function fn()
		if lastTime == nil then
			return
		end

		if tick() - lastTime >= 0.2 then
			setCurrentStep(v8 + v9)
		end
	end

	local v16 = true
	local v17 = {
		[Enum.KeyCode.Thumbstick1] = true,
		[Enum.KeyCode.DPadLeft] = -1,
		[Enum.KeyCode.DPadRight] = 1,
		[Enum.KeyCode.Left] = -1,
		[Enum.KeyCode.Right] = 1,
		[Enum.KeyCode.A] = -1,
		[Enum.KeyCode.D] = 1,
		[Enum.KeyCode.ButtonA] = true
	}
	UserInputService.InputBegan:Connect(function(input)
		if not v10 or not v16 or input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local selectedCoreObject = GuiService.SelectedCoreObject

		if not (selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent)) then
			return
		end

		if v17[input.KeyCode] == -1 then
			v9 = -1
			setCurrentStep(v8 - 1)
		elseif v17[input.KeyCode] == 1 then
			v9 = 1
			setCurrentStep(v8 + 1)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not v10 or input.UserInputType ~= Enum.UserInputType.Gamepad1 and input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		local selectedCoreObject = GuiService.SelectedCoreObject

		if selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent) and v17[input.KeyCode] then
			v9 = 0
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not v10 then
			v9 = 0
			return
		end

		if not v16 then
			v9 = 0
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		local selectedCoreObject = GuiService.SelectedCoreObject

		if not (selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent) and input.KeyCode == Enum.KeyCode.Thumbstick1) then
			return
		end

		if input.Position.X > 0.8 and input.Delta.X > 0 and v9 ~= 1 then
			v9 = 1
			setCurrentStep(v8 + 1)
		elseif input.Position.X < -0.8 and input.Delta.X < 0 and v9 ~= -1 then
			v9 = -1
			setCurrentStep(v8 - 1)
		elseif math.abs(input.Position.X) < 0.8 then
			v9 = 0
		end
	end)
	local flag = false
	GuiService.Changed:Connect(function(p4)
		if p4 ~= "SelectedCoreObject" then
			return
		end

		local selectedCoreObject = GuiService.SelectedCoreObject

		if selectedCoreObject and selectedCoreObject:IsDescendantOf(v6.SliderFrame.Parent) then
			modifySelection(0)

			if not flag then
				flag = true
				lastTime = tick()
				RunService:BindToRenderStep(GUID, Enum.RenderPriority.Input.Value + 1, fn)
			end
		else
			modifySelection(0.36)

			if flag then
				flag = false
				RunService:UnbindFromRenderStep(GUID)
			end
		end
	end)
	v6.SliderFrame.AncestryChanged:Connect(function(_, parent)
		v16 = parent
	end)
	setCurrentStep(v8)
	return v6
end

local v6 = 50
local v7 = {}

local function AddNewRow(object, text2, p2, p3, p4, p5)
	local v8 = p2 ~= "TextBox"
	local v9 = not v7[object] and 0 or v7[object]
	local parent = v2.Create("ImageButton")({
		Name = text2 .. "Frame",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxasset://textures/ui/VR/rectBackgroundWhite.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 18, 18),
		ImageTransparency = 1,
		Active = false,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, v6),
		Position = UDim2.new(0, 0, 0, v9),
		ZIndex = 2,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Parent = object.Page
	})
	parent.ImageColor3 = parent.BackgroundColor3

	if parent and p5 then
		parent.Position = UDim2.new(
			parent.Position.X.Scale,
			parent.Position.X.Offset,
			parent.Position.Y.Scale,
			parent.Position.Y.Offset + p5
		)
	end

	local parent2 = v2.Create("TextLabel")({
		Name = text2 .. "Label",
		Text = text2,
		Font = Enum.Font.SourceSansBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		ZIndex = 2,
		Parent = parent
	})
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")

	if v then
		parent2.Size = UDim2.new(0.35, 0, 1, 0)
		parent2.TextScaled = true
		parent2.TextWrapped = true
		uITextSizeConstraint.Parent = parent2
		uITextSizeConstraint.MaxTextSize = 16
	end

	if not v8 then
		parent2.Text = ""
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onResized(_, p6)
		if p6 then
			parent2.TextSize = 16
		else
			parent2.TextSize = 24
		end

		uITextSizeConstraint.MaxTextSize = parent2.TextSize
	end

	getViewportSize()
	onResized(nil, isPortrait()) -- equivalent call inferred; original call site unknown
	v3[parent] = onResized
	getViewportSize()
	onResized(nil, isPortrait()) -- equivalent call inferred; original call site unknown
	local sliderFrame = nil
	local v12 = nil

	if p2 == "Slider" then
		v12 = CreateNewSlider(p3, p4)
		v12.SliderFrame.Parent = parent
		sliderFrame = v12.SliderFrame
	elseif p2 == "Selector" then
		v12 = CreateSelector(p3, p4)
		v12.SelectorFrame.Parent = parent
		sliderFrame = v12.SelectorFrame
	elseif p2 == "DropDown" then
		v12 = CreateDropDown(p3, p4, object.HubRef)
		v12.DropDownFrame.Parent = parent
		sliderFrame = v12.DropDownFrame
	elseif p2 == "TextBox" then
		local v13 = false
		local v14 = false
		local selectionImageObject2 = v2.Create("ImageLabel")({
			Image = "",
			BackgroundTransparency = 1
		})
		v12 = {}
		v12.HubRef = nil
		local selectedCoreObject = v2.Create("TextBox")({
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.new(0.6, 0, 1, 0),
			Position = UDim2.new(1, 0, 0.5, 0),
			Text = text2,
			TextColor3 = Color3.fromRGB(49, 49, 49),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			ZIndex = 2,
			SelectionImageObject = selectionImageObject2,
			ClearTextOnFocus = false,
			Parent = parent
		})
		sliderFrame = selectedCoreObject
		selectedCoreObject.Focused:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = selectedCoreObject
			end

			if selectedCoreObject.Text == text2 then
				selectedCoreObject.Text = ""
			end
		end)
		selectedCoreObject.FocusLost:Connect(function(_, _)
			v14 = false
		end)

		if p5 then
			selectedCoreObject.Position = UDim2.new(
				selectedCoreObject.Position.X.Scale,
				selectedCoreObject.Position.X.Offset,
				selectedCoreObject.Position.Y.Scale,
				selectedCoreObject.Position.Y.Offset + p5
			)
		end

		sliderFrame.SelectionGained:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				selectedCoreObject.BackgroundTransparency = 0.1

				if v12.HubRef then
					v12.HubRef:ScrollToFrame(sliderFrame)
				end
			end
		end)
		sliderFrame.SelectionLost:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				selectedCoreObject.BackgroundTransparency = 0.5
			end
		end)

		local function onMouseEnter()
			local dropDownFullscreenFrame = playerGui.RobloxGui:FindFirstChild("DropDownFullscreenFrame")

			if dropDownFullscreenFrame and dropDownFullscreenFrame.Visible then
				return
			end

			local selectedCoreObject2 = sliderFrame

			if selectedCoreObject2 and selectedCoreObject2.Visible and selectedCoreObject2.ZIndex > 1 then
				local v18 = usesSelectedObject() -- equivalent call inferred; original call site unknown

				if v18 and object.Active then
					GuiService.SelectedCoreObject = selectedCoreObject2
					v13 = true
				end
			end
		end

		local function processInput(p6)
			if p6.UserInputState == Enum.UserInputState.Begin and p6.KeyCode == Enum.KeyCode.Return and GuiService.SelectedCoreObject == sliderFrame then
				v14 = true
				selectedCoreObject:CaptureFocus()
			end
		end

		selectedCoreObject.MouseEnter:Connect(onMouseEnter)
		UserInputService.InputBegan:Connect(processInput)
	elseif p2 == "TextEntry" then
		local v13 = false
		local v14 = false
		local selectionImageObject2 = v2.Create("ImageLabel")({
			Image = "",
			BackgroundTransparency = 1
		})
		v12 = {}
		v12.HubRef = nil
		local selectedCoreObject = v2.Create("TextBox")({
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.new(0.4, -10, 0, 40),
			Position = UDim2.new(1, 0, 0.5, 0),
			Text = text2,
			TextColor3 = Color3.fromRGB(178, 178, 178),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextWrapped = false,
			Font = Enum.Font.SourceSans,
			TextSize = 24,
			ZIndex = 2,
			SelectionImageObject = selectionImageObject2,
			ClearTextOnFocus = false,
			Parent = parent
		})
		sliderFrame = selectedCoreObject
		selectedCoreObject.Focused:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				GuiService.SelectedCoreObject = selectedCoreObject
			end

			if selectedCoreObject.Text == text2 then
				selectedCoreObject.Text = ""
			end
		end)
		selectedCoreObject.FocusLost:Connect(function(_, _)
			v14 = false
		end)

		if p5 then
			selectedCoreObject.Position = UDim2.new(
				selectedCoreObject.Position.X.Scale,
				selectedCoreObject.Position.X.Offset,
				selectedCoreObject.Position.Y.Scale,
				selectedCoreObject.Position.Y.Offset + p5
			)
		end

		sliderFrame.SelectionGained:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				selectedCoreObject.BackgroundTransparency = 0.8

				if v12.HubRef then
					v12.HubRef:ScrollToFrame(sliderFrame)
				end
			end
		end)
		sliderFrame.SelectionLost:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				selectedCoreObject.BackgroundTransparency = 1
			end
		end)

		local function onMouseEnter()
			local dropDownFullscreenFrame = playerGui.RobloxGui:FindFirstChild("DropDownFullscreenFrame")

			if dropDownFullscreenFrame and dropDownFullscreenFrame.Visible then
				return
			end

			local selectedCoreObject2 = sliderFrame

			if selectedCoreObject2 and selectedCoreObject2.Visible and selectedCoreObject2.ZIndex > 1 then
				local v18 = usesSelectedObject() -- equivalent call inferred; original call site unknown

				if v18 and object.Active then
					GuiService.SelectedCoreObject = selectedCoreObject2
					v13 = true
				end
			end
		end

		local function processInput(p6)
			if p6.UserInputState == Enum.UserInputState.Begin and p6.KeyCode == Enum.KeyCode.Return and GuiService.SelectedCoreObject == sliderFrame then
				v14 = true
				selectedCoreObject:CaptureFocus()
			end
		end

		parent.MouseEnter:Connect(onMouseEnter)

		function v12:SetZIndex(zIndex)
			selectedCoreObject.ZIndex = zIndex
		end

		function v12.SetInteractable(_, selectable)
			selectedCoreObject.Selectable = selectable

			if selectable then
				selectedCoreObject.TextColor3 = Color3.fromRGB(178, 178, 178)
				selectedCoreObject.ZIndex = 2
			else
				selectedCoreObject.TextColor3 = Color3.fromRGB(49, 49, 49)
				selectedCoreObject.ZIndex = 1
			end
		end

		function v12.SetValue(_, text)
			selectedCoreObject.Text = text
		end

		local bindableEvent = Instance.new("BindableEvent")
		bindableEvent.Name = "ValueChanged"
		selectedCoreObject.FocusLost:Connect(function()
			bindableEvent:Fire(selectedCoreObject.Text)
		end)
		v12.ValueChanged = bindableEvent.Event
		UserInputService.InputBegan:Connect(processInput)
	end

	v12.Name = text2 .. "ValueChanger"
	local v13 = v9 + v6

	if p5 then
		v13 += p5
	end

	v7[object] = v13

	if v8 then
		local function onMouseEnter()
			local dropDownFullscreenFrame = playerGui.RobloxGui:FindFirstChild("DropDownFullscreenFrame")

			if dropDownFullscreenFrame and dropDownFullscreenFrame.Visible then
				return
			end

			local sliderFrame2 = v12.SliderFrame or v12.SliderFrame or v12.DropDownFrame or v12.SelectorFrame

			if sliderFrame2 and sliderFrame2.Visible and sliderFrame2.ZIndex > 1 then
				local v14 = usesSelectedObject() -- equivalent call inferred; original call site unknown

				if v14 and object.Active then
					GuiService.SelectedCoreObject = sliderFrame2
				end
			end
		end

		parent.MouseEnter:Connect(onMouseEnter)

		local function onVREnabled(p6)
			if p6 == "VREnabled" then
				if VRService.VREnabled then
					parent.Selectable = true
					parent.Active = true
					sliderFrame.Active = true
					GuiService.Changed:Connect(function(p7)
						if p7 == "SelectedCoreObject" then
							local selectedCoreObject = GuiService.SelectedCoreObject

							if selectedCoreObject and (selectedCoreObject == parent or selectedCoreObject:IsDescendantOf(parent)) then
								parent.ImageTransparency = 0.5
								parent.BackgroundTransparency = 1
							else
								parent.ImageTransparency = 1
								parent.BackgroundTransparency = 1
							end
						end
					end)
				else
					parent.Selectable = false
					parent.Active = false
				end
			end
		end

		VRService.Changed:Connect(onVREnabled)

		if VRService.VREnabled then
			parent.Selectable = true
			parent.Active = true
			sliderFrame.Active = true
			GuiService.Changed:Connect(function(p6)
				if p6 == "SelectedCoreObject" then
					local selectedCoreObject = GuiService.SelectedCoreObject

					if selectedCoreObject and (selectedCoreObject == parent or selectedCoreObject:IsDescendantOf(parent)) then
						parent.ImageTransparency = 0.5
						parent.BackgroundTransparency = 1
					else
						parent.ImageTransparency = 1
						parent.BackgroundTransparency = 1
					end
				end
			end)
		else
			parent.Selectable = false
			parent.Active = false
		end

		sliderFrame.SelectionGained:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				if VRService.VREnabled then
					parent.ImageTransparency = 0.5
					parent.BackgroundTransparency = 1
				else
					parent.ImageTransparency = 1
					parent.BackgroundTransparency = 0.5
				end

				if v12.HubRef then
					v12.HubRef:ScrollToFrame(parent)
				end
			end
		end)
		sliderFrame.SelectionLost:Connect(function()
			-- equivalent call inferred; original call site unknown
			if usesSelectedObject() then
				parent.ImageTransparency = 1
				parent.BackgroundTransparency = 1
			end
		end)
	end

	object:AddRow(parent, parent2, v12, p5, false)
	v12.Selection = sliderFrame
	return parent, parent2, v12
end

local function AddNewRowObject(object, text, state, p2)
	local v8 = not v7[object] and 0 or v7[object]
	local v9 = v2.Create("ImageButton")({
		Name = text .. "Frame",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "rbxasset://textures/ui/VR/rectBackgroundWhite.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 10, 10),
		ImageTransparency = 1,
		Active = false,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, v6),
		Position = UDim2.new(0, 0, 0, v8),
		ZIndex = 2,
		Selectable = false,
		SelectionImageObject = selectionImageObject,
		Parent = object.Page
	})
	v9.ImageColor3 = v9.BackgroundColor3
	v9.SelectionGained:Connect(function()
		v9.BackgroundTransparency = 0.5
	end)
	v9.SelectionLost:Connect(function()
		v9.BackgroundTransparency = 1
	end)
	local v10 = v2.Create("TextLabel")({
		Name = text .. "Label",
		Text = text,
		Font = Enum.Font.SourceSansBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		ZIndex = 2,
		Parent = v9
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onResized(_, p3)
		if p3 then
			v10.TextSize = 16
		else
			v10.TextSize = 24
		end
	end

	v3[v9] = onResized
	getViewportSize()

	if isPortrait() then
		onResized(nil, true) -- equivalent call inferred; original call site unknown
	else
		onResized(nil, false) -- equivalent call inferred; original call site unknown
	end

	if p2 then
		v9.Position = UDim2.new(
			v9.Position.X.Scale,
			v9.Position.X.Offset,
			v9.Position.Y.Scale,
			v9.Position.Y.Offset + p2
		)
	end

	local v11 = v8 + v6

	if p2 then
		v11 += p2
	end

	v7[object] = v11

	local function onMouseEnter()
		if v9.Visible then
			GuiService.SelectedCoreObject = v9
		end
	end

	v9.MouseEnter:Connect(onMouseEnter)
	state.SelectionImageObject = selectionImageObject
	state.SelectionGained:Connect(function()
		if VRService.VREnabled then
			v9.ImageTransparency = 0.5
			v9.BackgroundTransparency = 1
		else
			v9.ImageTransparency = 1
			v9.BackgroundTransparency = 0.5
		end
	end)
	state.SelectionLost:Connect(function()
		v9.ImageTransparency = 1
		v9.BackgroundTransparency = 1
	end)
	state.Parent = v9
	object:AddRow(v9, v10, state, p2, true)
	return v9
end

local Utility = {
	Create = function(_, className)
		return function(items)
			local instance = Instance.new(className)
			local parent = nil

			for k, item in pairs(items) do
				if type(k) == "number" then
					item.Parent = instance
				elseif k == "Parent" then
					parent = item
				else
					instance[k] = item
				end
			end

			if parent then
				instance.Parent = parent
			end

			return instance
		end
	end,
	RayPlaneIntersection = function(_, p, p2, p3)
		local unit = p2.unit
		local unit2 = p.Unit
		local dot = unit:Dot(unit2.Direction)

		if dot == 0 then
			return nil
		end

		local v8 = unit:Dot(p3 - unit2.Origin) / dot

		if v8 < 0 then
			return nil
		end

		return unit2.Origin + unit2.Direction * v8
	end,
	GetEaseLinear = function(_)
		return Linear
	end,
	GetEaseOutQuad = function(_)
		return EaseOutQuad
	end,
	GetEaseInOutQuad = function(_)
		return EaseInOutQuad
	end,
	CreateNewSlider = function(_, p, p2, p3)
		return CreateNewSlider(p, p2, p3)
	end,
	CreateNewSelector = function(_, p, p2)
		return (CreateSelector(p, p2))
	end,
	CreateNewDropDown = function(_, p, p2)
		return (CreateDropDown(p, p2, nil))
	end,
	AddNewRow = function(_, p, text, p3, p4, p5, p6)
		return AddNewRow(p, text, p3, p4, p5, p6)
	end,
	AddNewRowObject = function(_, p, text, p3, p4)
		return (AddNewRowObject(p, text, p3, p4))
	end,
	ShowAlert = function(_, text, p2, p3, p4, p5)
		ShowAlert(text, p2, p3, p4, p5)
	end,
	IsSmallTouchScreen = function(_)
		local viewportSize = getViewportSize()
		return UserInputService.TouchEnabled and (viewportSize.Y < 500 or viewportSize.X < 700)
	end,
	IsPortrait = function(self)
		local viewportSize = getViewportSize()
		return viewportSize.Y > viewportSize.X
	end,
	MakeStyledButton = function(_, p, text, size, p4, p5, p6)
		return MakeButton(p, text, size, p4, p5, p6)
	end,
	MakeStyledImageButton = function(_, p, image, size, size2, p5, p6, p7)
		return MakeImageButton(p, image, size, size2, p5, p6, p7)
	end,
	AddButtonRow = function(_, p, p2, text, size, p5, p6)
		return AddButtonRow(p, p2, text, size, p5, p6)
	end,
	CreateSignal = function(_)
		return (CreateSignal())
	end,
	UsesSelectedObject = function(_)
		if VRService.VREnabled then
			return false
		end

		return not (UserInputService.TouchEnabled and not UserInputService.GamepadEnabled)
	end,
	TweenProperty = function(_, p, p2, p3, p4, p5, p6, p7)
		return PropertyTweener(p, p2, p3, p4, p5, p6, p7)
	end,
	OnResized = function(_, p, p2)
		return addOnResizedCallback(p, p2)
	end
}

function Utility.FireOnResized(_)
	local viewportSize = getViewportSize()
	local isPortrait2 = Utility:IsPortrait()

	for _, v8 in pairs(v3) do
		v8(viewportSize, isPortrait2)
	end
end

function Utility.Lerp(_, p, p2, p3)
	return (1 - p) * p2 + p * p3
end

function Utility.Round(_, p)
	return p % 1 >= 0.5 and math.ceil(p) or math.floor(p)
end

return Utility