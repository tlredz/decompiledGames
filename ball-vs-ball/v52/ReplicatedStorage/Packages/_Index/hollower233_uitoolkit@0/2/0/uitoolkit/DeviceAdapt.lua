local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local v = {}
local object = setmetatable({}, {
	__mode = "k"
})
local viewportSizeChangedConnection = nil
local v2 = {
	ProductPurchaseGui = true
}
local v3 = {
	Frame = true,
	ScrollingFrame = true,
	ImageLabel = true,
	CanvasGroup = true,
	ViewportFrame = true,
	VideoFrame = true
}

local function isContainerLike(instance)
	return v3[instance.ClassName] == true
end

local function isFullSize(p)
	return p.Size.X.Scale == 1 and p.Size.Y.Scale == 1
end

local function resolveOriginalSize(parent, items)
	local guiObject = StarterGui

	for _, childName in items do
		guiObject = guiObject and guiObject:FindFirstChild(childName)
	end

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject.Size
	end

	return parent.Size
end

local function applyScale(p)
	local v4 = v[p]
	local parent = p.Parent

	if not (v4 and parent and parent:IsA("GuiObject")) then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local viewportSize = currentCamera.ViewportSize

	if viewportSize.X <= 0 or viewportSize.Y <= 0 then
		return
	end

	local absoluteSize = parent.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local X = absoluteSize.X
	local Y = absoluteSize.Y

	if p.SizeConstraint == Enum.SizeConstraint.RelativeXX then
		Y = absoluteSize.X
	elseif p.SizeConstraint == Enum.SizeConstraint.RelativeYY then
		X = absoluteSize.Y
	end

	local originalSize = v4.originalSize
	local v5 = originalSize.X.Scale * X + originalSize.X.Offset
	local v6 = originalSize.Y.Scale * Y + originalSize.Y.Offset

	if v5 <= 0 or v6 <= 0 then
		return
	end

	local v7 = viewportSize.X * 0.92
	local v8 = viewportSize.Y * 0.85
	local scale = math.min(1, v7 / v5, v8 / v6)
	v4.uiScale.Scale = scale
end

local function updateAllTargets()
	for k in v do
		applyScale(k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAfterViewportSettles()
	task.defer(updateAllTargets)
	task.delay(0.2, updateAllTargets)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindCurrentCamera()
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateAllTargets)
	end

	refreshAfterViewportSettles() -- equivalent call inferred; original call site unknown
end

local function bindTarget(parent, p)
	if v[parent] then
		return
	end

	local uiScale = parent:FindFirstChildOfClass("UIScale")

	if uiScale and uiScale.Name ~= "DeviceAdaptScale" then
		warn((`[DeviceAdapt] ${parent:GetFullName()} 已存在其他 UIScale（${uiScale.Name}），跳过自动适配避免冲突`))
		return
	end

	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Name = "DeviceAdaptScale"
		uiScale.Parent = parent
	end

	local parentSizeConnection

	if parent.Parent and parent.Parent:IsA("GuiObject") then
		parentSizeConnection = parent.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			applyScale(parent)
		end)
	end

	v[parent] = {
		originalSize = resolveOriginalSize(parent, p),
		uiScale = uiScale,
		parentSizeConnection = parentSizeConnection
	}
	parent.Destroying:Once(function()
		local v6 = v[parent]

		if v6 and v6.parentSizeConnection then
			v6.parentSizeConnection:Disconnect()
		end

		v[parent] = nil
	end)
	applyScale(parent)
	refreshAfterViewportSettles() -- equivalent call inferred; original call site unknown
end

local function scanScreenGui(screenGui)
	for _, child in screenGui:GetChildren() do
		if v3[child.ClassName] ~= true then
			continue
		end

		local v4

		if child.Size.X.Scale == 1 then
			v4 = child.Size.Y.Scale == 1
		else
			v4 = false
		end

		if v4 then
			for _, child2 in child:GetChildren() do
				if v3[child2.ClassName] ~= true then
					continue
				end

				local v5

				if child2.Size.X.Scale == 1 then
					v5 = child2.Size.Y.Scale == 1
				else
					v5 = false
				end

				if not v5 then
					bindTarget(child2, { screenGui.Name, child.Name, child2.Name })
				end
			end
		else
			bindTarget(child, { screenGui.Name, child.Name })
		end
	end
end

local function onPlayerGuiChildAdded(screenGui)
	if screenGui:IsA("ScreenGui") and not (object[screenGui] or v2[screenGui.Name]) then
		object[screenGui] = true
		scanScreenGui(screenGui)
	end
end

return {
	Init = function()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		playerGui.ChildAdded:Connect(onPlayerGuiChildAdded)

		for _, screenGui in playerGui:GetChildren() do
			if not screenGui:IsA("ScreenGui") or (object[screenGui] or v2[screenGui.Name]) then
				continue
			end

			object[screenGui] = true
			scanScreenGui(screenGui)
		end

		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCurrentCamera)
		bindCurrentCamera() -- equivalent call inferred; original call site unknown
	end
}