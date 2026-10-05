local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

if not localPlayer then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	localPlayer = Players.LocalPlayer
end

local function waitForChildOfClass(localPlayer2, className: string)
	local firstChildOfClass = localPlayer2:FindFirstChildOfClass(className)

	while not firstChildOfClass or firstChildOfClass.ClassName ~= className do
		firstChildOfClass = localPlayer2.ChildAdded:Wait()
	end

	return firstChildOfClass
end

local parent2 = waitForChildOfClass(localPlayer, "PlayerGui")
local uDim = UDim2.new(0, 326, 0, 58)
local uDim2 = UDim2.new(0, 80, 0, 58)
local color = Color3.fromRGB(32, 32, 32)
local color2 = Color3.fromRGB(200, 200, 200)

-- equivalent calls inferred from this helper; original call sites unknown
local function create(className: string)
	return function(p)
		local instance = Instance.new(className)
		local parent = p.Parent
		p.Parent = nil

		for k, v2 in pairs(p) do
			if type(k) == "string" then
				instance[k] = v2
			else
				v2.Parent = instance
			end
		end

		instance.Parent = parent
		return instance
	end
end

local v2 = false
local v3 = nil
local toast = nil
local icon = nil
local upper = nil
local lower = nil

local function initializeUI()
	assert(not v2, "initializeUI called when already initialized")
	local v5 = create("ScreenGui") -- equivalent call inferred; original call site unknown
	local v6 = {
		Name = "RbxCameraUI",
		AutoLocalize = false,
		Enabled = true,
		DisplayOrder = -1,
		IgnoreGuiInset = false,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
	local v8 = create("ImageLabel") -- equivalent call inferred; original call site unknown
	local v9 = {
		Name = "Toast",
		Visible = false,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = uDim2,
		Image = "rbxasset://textures/ui/Camera/CameraToast9Slice.png",
		ImageColor3 = color,
		ImageRectSize = Vector2.new(6, 6),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(3, 3, 3, 3),
		ClipsDescendants = true
	}
	local v11 = create("Frame") -- equivalent call inferred; original call site unknown
	local v12 = {
		Name = "IconBuffer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 80, 1, 0)
	}
	local v13 = "ImageLabel"
	do local _values = table.pack((function(p)
	local instance = Instance.new(v13)
	local parent = p.Parent
	p.Parent = nil

	for k, v14 in pairs(p) do
		if type(k) == "string" then
			instance[k] = v14
		else
			v14.Parent = instance
		end
	end

	instance.Parent = parent
	return instance
end)({
	Name = "Icon",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 48, 0, 48),
	ZIndex = 2,
	Image = "rbxasset://textures/ui/Camera/CameraToastIcon.png",
	ImageColor3 = color2,
	ImageTransparency = 1
})); for _k = 1, _values.n do v12[_k] = _values[_k] end end
	local v14 = v11(v12)
	local v16 = create("Frame") -- equivalent call inferred; original call site unknown
	local v17 = {
		Name = "TextBuffer",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 80, 0, 0),
		Size = UDim2.new(1, -80, 1, 0),
		ClipsDescendants = true
	}
	local v18 = "TextLabel"
	local v19 = "TextLabel"
	do local _values = table.pack((function(p)
	local instance = Instance.new(v18)
	local parent = p.Parent
	p.Parent = nil

	for k, v20 in pairs(p) do
		if type(k) == "string" then
			instance[k] = v20
		else
			v20.Parent = instance
		end
	end

	instance.Parent = parent
	return instance
end)({
	Name = "Upper",
	AnchorPoint = Vector2.new(0, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0.5, 0),
	Size = UDim2.new(1, 0, 0, 19),
	Font = Enum.Font.GothamMedium,
	Text = "Camera control enabled",
	TextColor3 = color2,
	TextTransparency = 1,
	TextSize = 19,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center
}), (function(p)
	local instance = Instance.new(v19)
	local parent = p.Parent
	p.Parent = nil

	for k, v20 in pairs(p) do
		if type(k) == "string" then
			instance[k] = v20
		else
			v20.Parent = instance
		end
	end

	instance.Parent = parent
	return instance
end)({
	Name = "Lower",
	AnchorPoint = Vector2.new(0, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0.5, 3),
	Size = UDim2.new(1, 0, 0, 15),
	Font = Enum.Font.Gotham,
	Text = "Right mouse button to toggle",
	TextColor3 = color2,
	TextTransparency = 1,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center
})); for _k = 1, _values.n do v17[_k] = _values[_k] end end
	do local _values = table.pack(v14, v16(v17)); for _k = 1, _values.n do v9[_k] = _values[_k] end end
	v6[1] = (v8(v9))
	v6.Parent = parent2
	v3 = v5(v6)
	toast = v3.Toast
	icon = toast.IconBuffer.Icon
	upper = toast.TextBuffer.Upper
	lower = toast.TextBuffer.Lower
	v2 = true
end

local CameraUI = {}

function CameraUI.setCameraModeToastEnabled(visible: boolean)
	if not (visible or v2) then
		return
	end

	if not v2 then
		initializeUI()
	end

	toast.Visible = visible

	if not visible then
		CameraUI.setCameraModeToastOpen(false)
	end
end

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function CameraUI.setCameraModeToastOpen(flag: boolean)
	assert(v2)
	TweenService:Create(toast, tweenInfo, {
		Size = flag and uDim or uDim2,
		ImageTransparency = flag and 0.4 or 1
	}):Play()
	TweenService:Create(icon, tweenInfo, {
		ImageTransparency = flag and 0 or 1
	}):Play()
	TweenService:Create(upper, tweenInfo, {
		TextTransparency = flag and 0 or 1
	}):Play()
	TweenService:Create(lower, tweenInfo, {
		TextTransparency = flag and 0 or 1
	}):Play()
end

return CameraUI