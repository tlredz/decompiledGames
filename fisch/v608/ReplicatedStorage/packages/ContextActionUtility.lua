local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local touchEnabled = UserInputService.TouchEnabled
local jumpButton

if touchEnabled then
	jumpButton = playerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
else
	jumpButton = nil
end

local v = {}
local v2 = {
	UDim2.new(-0.4169, 0, 0.715, 0),
	UDim2.new(-0.165, 0, -0.165, 0),
	UDim2.new(0.715, 0, -0.4169, 0),
	UDim2.new(-1.1077, 0, -0.0396, 0),
	UDim2.new(-0.858, 0, -0.858, 0),
	(UDim2.new(-0.0396, 0, -1.1077, 0))
}

local function GetNextSlot()
	local v3 = {}

	for _, v4 in pairs(v) do
		v3[v4.Slot] = true
	end

	for i = 1, #v2 do
		if not v3[i] then
			return i
		end
	end

	return nil
end

local function ConnectButton(p, callback)
	local v3 = v[p]
	local button = v3.Button
	local connections = v3.Connections or {}

	local function inputBeganHandler(p2)
		callback(p, Enum.UserInputState.Begin, p2)
		button.ImageColor3 = button.BorderColor3
		local title = button:FindFirstChild("title")

		if title then
			title.TextColor3 = button.BorderColor3
		end
	end

	connections.Begin = button.InputBegan:Connect(inputBeganHandler)

	local function inputChangedHandler(p2)
		callback(p, Enum.UserInputState.Change, p2)
	end

	connections.Changed = button.InputChanged:Connect(inputChangedHandler)

	local function inputEndedHandler(p2)
		callback(p, Enum.UserInputState.End, p2)
		button.ImageColor3 = button.BackgroundColor3
		local title = button:FindFirstChild("title")

		if title then
			title.TextColor3 = button.BackgroundColor3
		end
	end

	connections.MenuOpened = GuiService.MenuOpened:Connect(inputEndedHandler)
	connections.End = button.InputEnded:Connect(inputEndedHandler)

	local function mouseLeaveHandler()
		button.ImageColor3 = button.BackgroundColor3
		local title = button:FindFirstChild("title")

		if title then
			title.TextColor3 = button.BackgroundColor3
		end
	end

	button.MouseLeave:Connect(mouseLeaveHandler)
end

local function DisconnectButton(p)
	local v3 = v[p]

	if not v3.Connections then
		return
	end

	for _, connection in pairs(v3.Connections) do
		if connection then
			connection:Disconnect()
		end
	end

	v3.Connections = {}
end

local function newDefaultButton(p, slot)
	local imageButton = Instance.new("ImageButton")
	imageButton.Name = p .. "Button"
	imageButton.BackgroundTransparency = 1
	imageButton.Size = UDim2.new(0.8, 0, 0.8, 0)
	imageButton.Image = "rbxassetid://5713982324"
	imageButton.ImageTransparency = 0.5
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageButton.BorderColor3 = Color3.fromRGB(125, 125, 125)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = imageButton
	imageButton.Position = v2[slot]
	return imageButton
end

local function BindButton(name, p2)
	local v3 = v[name]
	local slot, button

	if v3 then
		print("is Data")

		if v3.Connections then
			print("is Connections")
			DisconnectButton(name)
		end

		if v3.Slot then
			print("is Slot")
			slot = v3.Slot
		else
			slot = GetNextSlot()
		end

		if v3.Button then
			print("is Button")
			button = v3.Button
			button.ImageColor3 = button.BackgroundColor3
			local title = button:FindFirstChild("title")

			if title then
				title.TextColor3 = button.BackgroundColor3
			end
		else
			button = newDefaultButton(name, slot)
		end
	else
		slot = GetNextSlot()
		button = newDefaultButton(name, slot)
	end

	button.Parent = jumpButton
	v[name] = {
		Name = name,
		Button = button,
		Slot = slot,
		Connections = {}
	}
	ConnectButton(name, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UnbindButton(p)
	local v3 = v[p]

	if not v3 then
		return
	end

	DisconnectButton(p)

	if v3.Button then
		v3.Button:Destroy()
	end

	v[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisableButton(p)
	local v3 = v[p]
	DisconnectButton(p)
	local button = v3.Button
	button.ImageColor3 = button.BackgroundColor3
	local title = button:FindFirstChild("title")

	if title then
		title.TextColor3 = button.BackgroundColor3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FixDefaultJumpButton()
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = jumpButton
end

FixDefaultJumpButton() -- equivalent call inferred; original call site unknown
local ContextActionUtility = {}
ContextActionUtility.Archivable = ContextActionService.Archivable
ContextActionUtility.ClassName = ContextActionService.ClassName
ContextActionUtility.Name = ContextActionService.Name
ContextActionUtility.Parent = ContextActionService.Parent
ContextActionUtility.LocalToolEquipped = ContextActionService.LocalToolEquipped
ContextActionUtility.LocalToolUnequipped = ContextActionService.LocalToolUnequipped

function ContextActionUtility:BindAction(name, p2, p3, ...)
	ContextActionService:BindAction(name, p2, false, ...)

	if p3 and touchEnabled then
		BindButton(name, p2)
	end
end

function ContextActionUtility.BindActionAtPriority(_, name, p2, p3, p4, ...)
	ContextActionService:BindAction(name, p2, false, p4, ...)

	if p3 and touchEnabled then
		BindButton(name, p2)
	end
end

function ContextActionUtility:UnbindAction(p)
	ContextActionService:UnbindAction(p)

	if touchEnabled then
		UnbindButton(p) -- equivalent call inferred; original call site unknown
	end
end

function ContextActionUtility.DisableAction(_, p, _)
	ContextActionService:UnbindAction(p)

	if touchEnabled then
		DisableButton(p) -- equivalent call inferred; original call site unknown
	end
end

function ContextActionUtility.SetTitle(_, p, p2)
	local v3 = v[p]

	if not v3 then
		return
	end

	local button = v3.Button

	if not button then
		return
	end

	local v5 = button:FindFirstChild("title")

	if not v5 then
		v5 = Instance.new("TextLabel")
		v5.Name = "title"
		v5.AnchorPoint = Vector2.new(0.5, 0.5)
		v5.Position = UDim2.new(0.5, 0, 0.5, 0)
		v5.BackgroundTransparency = 1
		v5.Size = UDim2.new(0.75, 0, 0.45, 0)
		v5.Font = Enum.Font.SourceSansBold
		v5.TextScaled = true
		v5.TextTransparency = 0.5
		v5.TextColor3 = Color3.new(255, 255, 255)
		v5.TextXAlignment = Enum.TextXAlignment.Center
		v5.TextYAlignment = Enum.TextYAlignment.Center
	end

	v5.Visible = true
	v5.Text = p2 or p
	v5.Parent = button
end

function ContextActionUtility.SetImage(_, p, image)
	local v3 = v[p]

	if not v3 then
		return
	end

	v3.Button.Image = image
end

function ContextActionUtility.SetPressedColor(_, p, borderColor)
	local v3 = v[p]

	if not v3 then
		return
	end

	local button = v3.Button

	if not button then
		return
	end

	print("Setting Pressed Color")
	button.BorderColor3 = borderColor
end

function ContextActionUtility.SetReleasedColor(_, p, p2)
	local v3 = v[p]

	if not v3 then
		return
	end

	local button = v3.Button

	if not button then
		return
	end

	button.ImageColor3 = p2
	button.BackgroundColor3 = p2
	local title = button:FindFirstChild("title")

	if title then
		title.TextColor3 = p2
	end
end

function ContextActionUtility.MakeButtonSquare(_, p)
	local v3 = v[p]

	if not v3 then
		return
	end

	local button = v3.Button

	if not button then
		return
	end

	local uICorner = button:FindFirstChildOfClass("UICorner")

	if uICorner then
		uICorner.CornerRadius = UDim.new(0, 0)
	end
end

function ContextActionUtility.MakeButtonRound(_, p, value)
	local v3 = v[p]

	if not v3 then
		return
	end

	local button = v3.Button

	if not button then
		return
	end

	local uICorner = button:FindFirstChildOfClass("UICorner")

	if not uICorner then
		Instance.new("UICorner", button)
	end

	uICorner.CornerRadius = UDim.new(value or 0.5, 0)
end

function ContextActionUtility.GetButton(_, p)
	local v3 = v[p]

	if v3 then
		return v3.Button
	end

	return nil
end

return ContextActionUtility