local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local InputUtils = require(script.Parent.InputUtils)
local Motion = require(script.Parent.Motion)
local ResizeGrip = require(script.Parent.ResizeGrip)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local v = {
	Position = Vector2.zero,
	Size = Vector2.zero
}

-- equivalent calls inferred from this helper; original call sites unknown
local function guiInsetOffset()
	return GuiService:GetGuiInset()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anchorSnapshot(current)
	if current and current.Parent then
		local v2 = guiInsetOffset() -- equivalent call inferred; original call site unknown
		return {
			Position = current.AbsolutePosition + v2,
			Size = current.AbsoluteSize
		}
	else
		return nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function viewportSize()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return currentCamera.ViewportSize
	end

	return (Vector2.new(1280, 720))
end

local function popoutPosition(p, p2: number, p3: number, offsetY: number, horizontalAlign: string?)
	local v2 = viewportSize() -- equivalent call inferred; original call site unknown
	local v3

	if horizontalAlign == "right" then
		v3 = p.Position.X + p.Size.X - p2
	else
		v3 = p.Position.X
	end

	local v4 = math.clamp(v3, 0, (math.max(0, v2.X - p2)))
	local v5 = p.Position.Y + p.Size.Y + offsetY
	local v6 = p.Position.Y - p3 - offsetY

	if v5 + p3 > v2.Y and v6 >= 0 then
		v5 = v6
	elseif v5 + p3 > v2.Y then
		v5 = math.max(0, v2.Y - p3)
	end

	return Vector2.new(v4, v5)
end

local function isInAnyPopout(position: Vector2)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	for _, parent in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		while parent do
			if CollectionService:HasTag(parent, "IrisLogPopoutGui") then
				return true
			else
				parent = parent.Parent
			end
		end
	end

	return false
end

local function isInAnchor(position: Vector2, current)
	if not current then
		return false
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return false
	end

	for _, v2 in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
		if v2 == current or v2:IsDescendantOf(current) then
			return true
		end
	end

	return false
end

return function(props)
	local state, setState = React.useState(nil)
	local ref = React.useRef(nil)
	local state2, setState2 = React.useState(nil)
	local v2, v3, v4 = Motion.useNumberMotion(props.InitialVisibleHeightPx or 0)
	local ref2 = React.useRef(false)

	local function currentLayout()
		local v5 = viewportSize() -- equivalent call inferred; original call site unknown
		local v6 = anchorSnapshot(props.AnchorRef.current) -- equivalent call inferred; original call site unknown
		local v7 = v6 or v
		local minWidthPx = props.MinWidthPx or Theme.PopoutMinWidth
		local minHeightPx = props.MinHeightPx or Theme.DropdownRowHeight
		local X

		if state2 then
			X = state2.X
		else
			X = props.WidthPx or v7.Size.X
		end

		local Y

		if state2 then
			Y = state2.Y
		else
			Y = props.HeightPx
		end

		local v8 = math.clamp(X, minWidthPx, v5.X)
		local v9 = math.clamp(Y, minHeightPx, v5.Y)
		local offsetY = props.OffsetY or 2
		local vector

		if props.ConstrainHeightToViewportBottom then
			local v10

			if props.HorizontalAlign == "right" then
				v10 = v7.Position.X + v7.Size.X - v8
			else
				v10 = v7.Position.X
			end

			local v11 = math.clamp(v10, 0, (math.max(0, v5.X - v8)))
			local v12 = math.clamp(v7.Position.Y + v7.Size.Y + offsetY, 0, (math.max(0, v5.Y - minHeightPx)))
			v9 = math.min(v9, (math.max(minHeightPx, v5.Y - v12)))
			vector = Vector2.new(v11, v12)
		else
			vector = popoutPosition(v7, v8, v9, offsetY, props.HorizontalAlign)
		end

		return UDim2.fromOffset(vector.X, vector.Y), UDim2.fromOffset(v8, v9)
	end

	local function beginResize(p)
		if not (props.Resizable and InputUtils.isPrimaryPointer(p)) then
			return
		end

		local _, v5 = currentLayout()
		local position = InputUtils.position(p)
		local vector = Vector2.new(v5.X.Offset, v5.Y.Offset)
		local minWidthPx = props.MinWidthPx or Theme.PopoutMinWidth
		local minHeightPx = props.MinHeightPx or Theme.DropdownRowHeight
		local inputEndedConnection = nil
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if not InputUtils.isPointerMove(input) then
				return
			end

			local v6 = viewportSize() -- equivalent call inferred; original call site unknown
			local v7 = vector + (InputUtils.position(input) - position)
			setState2(Vector2.new(math.clamp(v7.X, minWidthPx, v6.X), (math.clamp(v7.Y, minHeightPx, v6.Y))))
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= p.UserInputType then
				return
			end

			if inputChangedConnection then
				inputChangedConnection:Disconnect()
			end

			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end)
	end

	React.useEffect(function()
		if not props.Open then
			setState(nil)
			return
		end

		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 100)

		if not playerGui then
			return
		end

		local screenGui = Instance.new("ScreenGui")
		CollectionService:AddTag(screenGui, "IrisLogPopoutGui")
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = props.DisplayOrder or 101
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = playerGui
		setState(screenGui)
		return function()
			screenGui:Destroy()
		end
	end, { props.Open, props.DisplayOrder or 101 })
	local useEffect = React.useEffect

	local function fn()
		if not props.Open then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSnapshot()
			local current = ref.current

			if current then
				local position, size = currentLayout()
				current.Position = position

				if ref2.current then
					current.Size = size
				else
					local v7 = math.clamp(v2:getValue(), 0, size.Y.Offset)
					current.Size = UDim2.fromOffset(size.X.Offset, v7)
				end
			end
		end

		updateSnapshot() -- equivalent call inferred; original call site unknown
		task.defer(updateSnapshot)
		local renderSteppedConnection = RunService.RenderStepped:Connect(updateSnapshot)
		return function()
			renderSteppedConnection:Disconnect()
		end
	end

	local open = props.Open
	local anchorRef = props.AnchorRef
	local widthPx = props.WidthPx or false
	local heightPx = props.HeightPx
	local initialVisibleHeightPx = props.InitialVisibleHeightPx or false
	local constrainHeightToViewportBottom = props.ConstrainHeightToViewportBottom == true
	local offsetY = props.OffsetY or false
	local horizontalAlign = props.HorizontalAlign or false
	local v6

	if state2 then
		v6 = state2.X or false
	else
		v6 = false
	end

	useEffect(fn, {
		open,
		anchorRef,
		widthPx,
		heightPx,
		initialVisibleHeightPx,
		constrainHeightToViewportBottom,
		offsetY,
		horizontalAlign,
		v6,
		state2 and state2.Y or false
	})
	React.useEffect(function()
		if props.Open and props.OnOutsideInput then
			local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
				if not InputUtils.isPrimaryPointer(input) then
					return
				end

				local position = InputUtils.position(input)

				if isInAnyPopout(position) or isInAnchor(position, props.AnchorRef.current) then
					return
				end

				props.OnOutsideInput()
			end)
			return function()
				inputBeganConnection:Disconnect()
			end
		end
	end, { props.Open, props.OnOutsideInput or false })
	React.useLayoutEffect(function()
		if not (props.Open and state) then
			return
		end

		local _, v7 = currentLayout()
		local v8 = math.clamp(props.InitialVisibleHeightPx or 0, 0, v7.Y.Offset)
		ref2.current = false
		v4(v8)
		v3(v7.Y.Offset, Motion.Collapse, function()
			ref2.current = true
		end)
		local current = ref.current

		if current then
			current.Size = UDim2.fromOffset(v7.X.Offset, v8)
			current.BackgroundTransparency = 1
			Motion.to(current, Motion.Fade, {
				BackgroundTransparency = 0.02
			})
		end
	end, { props.Open, state, props.InitialVisibleHeightPx or false })

	if not (props.Open and state) then
		return nil
	end

	local position2, v8 = currentLayout()
	local v9 = math.clamp(props.InitialVisibleHeightPx or 0, 0, v8.Y.Offset)
	local resizeHandleSize = props.ResizeHandleSize or Theme.TreeResizeHandleSize
	local createPortal = ReactRoblox.createPortal
	local v12 = {
		ref = ref,
		Active = true,
		BackgroundColor3 = Theme.PanelDark,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = position2,
		Size = UDim2.fromOffset(v8.X.Offset, v9),
		ZIndex = props.ZIndex or 100
	}
	local v13 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		Content = createElement(React.Fragment, {}, props.children),
		ResizeHandle = 0
	}
	local resizeHandle

	if props.Resizable then
		resizeHandle = createElement(ResizeGrip, {
			SizePx = resizeHandleSize,
			ZIndex = (props.ZIndex or 100) + 5,
			OnInputBegan = beginResize
		})
	end

	v13.ResizeHandle = resizeHandle
	return createPortal(createElement("Frame", v12, v13), state)
end