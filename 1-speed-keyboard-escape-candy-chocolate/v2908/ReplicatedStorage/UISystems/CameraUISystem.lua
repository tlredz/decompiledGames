local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local localPlayer = Players.LocalPlayer
local maid = Janitor.new()
local v = false
local v2 = false
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local cFrame = nil
local v7 = {}
local v8 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

local function getSortedCameraSpots()
	local parts = {}

	for _, part in ipairs(CollectionService:GetTagged("CameraSpot")) do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		local order = a:GetAttribute("Order")
		local order2 = b:GetAttribute("Order")

		if type(order) == "number" and type(order2) == "number" and order ~= order2 then
			return order < order2
		end

		if type(order) == "number" and type(order2) ~= "number" then
			return true
		end

		return (type(order2) ~= "number" or type(order) == "number") and a.Name < b.Name
	end)
	return parts
end

local function fetchButton(instance)
	local triggerButton = instance:FindFirstChild("TriggerButton")

	if triggerButton and triggerButton:IsA("GuiButton") then
		return triggerButton
	end

	return nil
end

local function buildArrowButton(frame, name: string, text: string, layoutOrder: number)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.fromOffset(32, 32)
	textButton.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
	textButton.BackgroundTransparency = 0.1
	textButton.AutoButtonColor = true
	textButton.Font = Enum.Font.GothamBold
	textButton.TextScaled = true
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Text = text
	textButton.ZIndex = 11
	textButton.Parent = frame
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0.5, 0)
	uICorner.Parent = textButton
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 5)
	uIPadding.PaddingBottom = UDim.new(0, 5)
	uIPadding.Parent = textButton
	return textButton
end

-- equivalent calls inferred from this helper; original call sites unknown
local function positionNavPanelUnderFrame(p, p2)
	local absolutePosition = p2.AbsolutePosition
	local absoluteSize = p2.AbsoluteSize
	p.Position = UDim2.fromOffset(absolutePosition.X + absoluteSize.X / 2 + 30, absolutePosition.Y + absoluteSize.Y + 8)
end

local function buildNavPanel(parent)
	local frame = Instance.new("Frame")
	frame.Name = "NavPanel"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.fromOffset(110, 42)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame.BackgroundTransparency = 0.25
	frame.Visible = false
	frame.ZIndex = 10
	frame.Parent = parent
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 14)
	uICorner.Parent = frame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 20)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame
	buildArrowButton(frame, "LeftArrow", "<", 1)
	buildArrowButton(frame, "RightArrow", ">", 2)
	return frame
end

local function getOrBuildNavPanel(instance)
	local v9 = v7[instance]

	if v9 and v9.Parent then
		return v9
	end

	v7[instance] = nil
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local v10 = playerGui:FindFirstChild("CameraNavGui")

	if not (v10 and v10:IsA("ScreenGui")) then
		v10 = Instance.new("ScreenGui")
		v10.Name = "CameraNavGui"
		v10.ResetOnSpawn = false
		v10.Parent = playerGui
	end

	local navPanel = buildNavPanel(v10)
	v7[instance] = navPanel

	local function update()
		positionNavPanelUnderFrame(navPanel, instance) -- equivalent call inferred; original call site unknown
	end

	positionNavPanelUnderFrame(navPanel, instance) -- equivalent call inferred; original call site unknown
	local absolutePositionChangedConnection = instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
	local absoluteSizeChangedConnection = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	navPanel.Destroying:Once(function()
		absolutePositionChangedConnection:Disconnect()
		absoluteSizeChangedConnection:Disconnect()
	end)
	return navPanel
end

local function moveToSpot(p: number)
	local sortedCameraSpots = getSortedCameraSpots()
	print("[CameraUISystem] moveToSpot index=" .. tostring(p) .. " spotsFound=" .. #sortedCameraSpots)

	if #sortedCameraSpots == 0 then
		return
	end

	local v9 = (p - 1) % #sortedCameraSpots + 1
	local sortedCameraSpot = sortedCameraSpots[v9]
	v3 = v9
	v6 = sortedCameraSpot
	cFrame = sortedCameraSpot.CFrame
	workspace.CurrentCamera.CFrame = sortedCameraSpot.CFrame
	print("[CameraUISystem] camera moved to spot #" .. v9 .. " (" .. sortedCameraSpot:GetFullName() .. ")")
end

local function exitCameraMode()
	print("[CameraUISystem] exitCameraMode called, isCameraModeActive=" .. tostring(v))

	if not v then
		return
	end

	v = false
	v3 = nil
	v6 = nil
	cFrame = nil
	maid:Cleanup()

	if v4 then
		v4.Visible = false
	end

	v4 = nil
	v5 = nil
	print("[CameraUISystem] camera mode exited")
end

local function enterCameraMode(instance)
	print("[CameraUISystem] enterCameraMode called, navPanel=" .. instance:GetFullName())

	if #getSortedCameraSpots() == 0 then
		warn("[CameraUISystem] Aucun BasePart taggé 'CameraSpot' trouvé")
		return
	end

	v = true
	v4 = instance
	instance.Visible = not v2
	moveToSpot(1)
	RunService:BindToRenderStep("CameraUISystem_CameraSpot", Enum.RenderPriority.Camera.Value + 1, function()
		if not v then
			return
		end

		local camera = getCamera() -- equivalent call inferred; original call site unknown
		local v9 = v6

		if v9 and v9.Parent then
			cFrame = v9.CFrame
		end

		local cFrame2 = cFrame

		if cFrame2 then
			camera.CFrame = cFrame2
		end
	end)
	maid:Add(function()
		RunService:UnbindFromRenderStep("CameraUISystem_CameraSpot")
	end)
	local leftArrow = instance:FindFirstChild("LeftArrow")
	local rightArrow = instance:FindFirstChild("RightArrow")
	print("[CameraUISystem] leftArrow found=" .. tostring(leftArrow ~= nil) .. " rightArrow found=" .. tostring(rightArrow ~= nil))

	if leftArrow and leftArrow:IsA("GuiButton") then
		maid:Add(leftArrow.Activated:Connect(function()
			print("[CameraUISystem] LeftArrow clicked")
			moveToSpot((v3 or 1) - 1)
		end))
	end

	if rightArrow and rightArrow:IsA("GuiButton") then
		maid:Add(rightArrow.Activated:Connect(function()
			print("[CameraUISystem] RightArrow clicked")
			moveToSpot((v3 or 1) + 1)
		end))
	end
end

local function wireFrame(guiObject)
	print("[CameraUISystem] wireFrame called for '" .. guiObject:GetFullName() .. "' (class=" .. guiObject.ClassName .. ")")

	if v8[guiObject] then
		print("[CameraUISystem] frame is already wired, skipping")
		return
	end

	if not guiObject:IsA("GuiObject") then
		print("[CameraUISystem] frame is not a GuiObject, skipping")
		return
	end

	print("[CameraUISystem] concert camera retired, canPlay = " .. tostring(false))
	guiObject.Visible = false
	print("[CameraUISystem] not world 4, hiding frame '" .. guiObject:GetFullName() .. "'")
end

local CameraUISystem = {
	SwitchCamera = function()
		print("[CameraUISystem] exitCameraMode called, isCameraModeActive=" .. tostring(v))

		if not v then
			return
		end

		v = false
		v3 = nil
		v6 = nil
		cFrame = nil
		maid:Cleanup()

		if v4 then
			v4.Visible = false
		end

		v4 = nil
		v5 = nil
		print("[CameraUISystem] camera mode exited")
	end,
	SetUIHidden = function(flag: boolean)
		v2 = flag

		if v4 then
			v4.Visible = v and not v2
		end
	end
}
local tagged = CollectionService:GetTagged("CameraButton")
print("[CameraUISystem] module loaded, found " .. #tagged .. " frame(s) tagged 'CameraButton'")

for _, v9 in ipairs(tagged) do
	wireFrame(v9)
end

CollectionService:GetInstanceAddedSignal("CameraButton"):Connect(wireFrame)

if localPlayer then
	localPlayer.CharacterAdded:Connect(exitCameraMode)
end

return CameraUISystem