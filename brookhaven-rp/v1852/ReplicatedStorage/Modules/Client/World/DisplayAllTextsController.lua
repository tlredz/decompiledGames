local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local DisplayAllTextsController = {}
local color = Color3.fromRGB(0, 255, 70)
local color2 = Color3.fromRGB(0, 8, 0)
local color3 = Color3.fromRGB(0, 16, 0)
local color4 = Color3.fromRGB(0, 200, 60)
local localPlayer = Players.LocalPlayer
local v = nil
local v2 = nil
local v3 = nil
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function isTextObject(instance)
	return instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getInstanceText(instance)
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		return instance.Text
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sanitizeCapturedText(text: string)
	local v4 = string.gsub(text, "[\r\n\t]+", " ")
	local v5 = string.gsub(v4, "%s+", " ")
	local v6 = string.gsub(v5, "^%s*(.-)%s*$", "%1")

	if v6 == "" then
		return "(empty)"
	end

	return v6
end

local function formatCapturedEntry(k: number, p)
	return string.format("[%d] \"%s\" | %s", k, sanitizeCapturedText(p.text), p.path)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sortCapturedTexts(list)
	table.sort(list, function(a, b)
		return a.path < b.path
	end)
end

local function isAncestorVisible(parent)
	while parent ~= nil do
		if parent:IsA("GuiObject") then
			if parent.Visible ~= true then
				return false
			end
		elseif parent:IsA("LayerCollector") and parent.Enabled ~= true then
			return false
		end

		parent = parent.Parent
	end

	return true
end

local function getWorldAnchor(instance)
	if instance.Adornee ~= nil then
		return instance.Adornee
	end

	local parent = instance.Parent

	if parent == nil or not (parent:IsA("BasePart") or parent:IsA("Model") or parent:IsA("Attachment")) then
		return nil
	end

	return parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAnchorPosition(parent)
	if parent:IsA("BasePart") then
		return parent.Position
	end

	if parent:IsA("Model") then
		return parent:GetPivot().Position
	end

	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	return nil
end

local function collectVisibleGuiTexts(folder, ui)
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if not ((ui == nil or not descendant:IsDescendantOf(ui)) and isTextObject(descendant)) then
			continue
		end

		local screenGui = descendant:FindFirstAncestorOfClass("ScreenGui") or descendant:FindFirstAncestorOfClass("BillboardGui") or descendant:FindFirstAncestorOfClass("SurfaceGui")

		if not (screenGui ~= nil and screenGui:IsA("ScreenGui") and isAncestorVisible(descendant)) then
			continue
		end

		table.insert(result, {
			path = descendant:GetFullName(),
			text = getInstanceText(descendant)
		})
	end

	sortCapturedTexts(result) -- equivalent call inferred; original call site unknown
	return result
end

local function buildNearbyPartSet(humanoidRootPart)
	local part = Instance.new("Part")
	part.Name = "DisplayAllTextsSearchVolume"
	part.Size = createVector(100, 100, 100)
	part.CFrame = humanoidRootPart.CFrame
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	part.Transparency = 1
	part.CastShadow = false
	part.Parent = workspace
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { part, localPlayer.Character }
	local result = {}

	for _, v4 in workspace:GetPartsInPart(part, overlapParams) do
		result[v4] = true
	end

	return result, part
end

local function isWorldGuiInRange(folder, items, vector2: Vector3)
	local parent

	if folder.Adornee == nil then
		parent = folder.Parent

		if parent == nil or not (parent:IsA("BasePart") or parent:IsA("Model") or parent:IsA("Attachment")) then
			parent = nil
		end
	else
		parent = folder.Adornee
	end

	if parent == nil then
		return false
	end

	if parent:IsA("BasePart") and items[parent] == true then
		return true
	end

	if parent:IsA("Model") then
		for _, part in parent:GetDescendants() do
			if part:IsA("BasePart") and items[part] == true then
				return true
			end
		end
	end

	local anchorPosition = getAnchorPosition(parent) -- equivalent call inferred; original call site unknown
	return anchorPosition ~= nil and (anchorPosition - vector2).Magnitude <= 50
end

local function collectWorldTexts(nearbyPartSet, position: Vector3, ui)
	local v4 = {}
	local v5 = {}

	local function tryAddText(descendant)
		if v5[descendant] == true or ui ~= nil and descendant:IsDescendantOf(ui) or not isTextObject(descendant) or not isAncestorVisible(descendant) then
			return
		end

		v5[descendant] = true
		table.insert(v4, {
			path = descendant:GetFullName(),
			text = getInstanceText(descendant)
		})
	end

	local function collectFromLayerCollector(folder)
		if not (isWorldGuiInRange(folder, nearbyPartSet, position) and folder.Enabled == true) then
			return
		end

		for _, descendant in folder:GetDescendants() do
			tryAddText(descendant)
		end
	end

	for folder in nearbyPartSet do
		for _, child in folder:GetChildren() do
			if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
				collectFromLayerCollector(child)
			end
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
				collectFromLayerCollector(descendant)
			elseif isTextObject(descendant) then
				local surfaceGui = descendant:FindFirstAncestorOfClass("SurfaceGui") or descendant:FindFirstAncestorOfClass("BillboardGui")

				if surfaceGui ~= nil then
					collectFromLayerCollector(surfaceGui)
				end
			end
		end
	end

	for _, folder in { workspace, localPlayer:FindFirstChildOfClass("PlayerGui") } do
		if folder == nil then
			continue
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
				collectFromLayerCollector(descendant)
			end
		end
	end

	sortCapturedTexts(v4) -- equivalent call inferred; original call site unknown
	return v4
end

local function buildOutputLines(list, list2, flag2: boolean)
	local result = {
		"========================================",
		"  TEXT SCANNER // TERMINAL",
		"  LEFT SHIFT + R  |  REFRESH / RERUN",
		"========================================",
		"",
		string.format("== GUI (%d) ==", #list)
	}

	if #list == 0 then
		table.insert(result, "(none)")
	else
		for k, v4 in list do
			table.insert(result, formatCapturedEntry(k, v4))
		end
	end

	table.insert(result, "")
	table.insert(result, string.format("== WORLD (%d) [radius=%d studs] ==", #list2, 50))

	if #list2 == 0 then
		table.insert(result, "(none)")
	else
		for k, v4 in list2 do
			table.insert(result, formatCapturedEntry(k, v4))
		end
	end

	table.insert(result, "")
	table.insert(result, "========================================")
	table.insert(result, "  SCAN COMPLETE")
	table.insert(result, "========================================")

	if flag2 then
		table.insert(result, "> WARN: no HumanoidRootPart — world scan skipped")
	end

	return result
end

local function clearOutputLines()
	local v4 = v2

	if v4 == nil then
		return
	end

	for _, label in v4:GetChildren() do
		if label:IsA("TextLabel") then
			label:Destroy()
		end
	end
end

local function syncScrollerCanvas()
	local v4 = v2
	local v5 = v3

	if v4 == nil or v5 == nil then
		return
	end

	v4.CanvasSize = UDim2.new(0, 0, 0, v5.AbsoluteContentSize.Y + 16)
end

local function createLineLabel(text: string, layoutOrder: number)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Line"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -4, 0, 18)
	textLabel.AutomaticSize = Enum.AutomaticSize.Y
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 13
	textLabel.TextColor3 = color
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.TextWrapped = true
	textLabel.RichText = false
	textLabel.Text = text
	textLabel.LayoutOrder = layoutOrder
	textLabel.ZIndex = 12
	return textLabel
end

local function setOutputLines(items)
	local parent = v2

	if parent == nil then
		return
	end

	clearOutputLines()

	for k, item in items do
		local lineLabel = createLineLabel(item == "" and " " or item, k)
		lineLabel.Parent = parent
	end

	local v5 = v2
	local v6 = v3

	if v5 ~= nil and v6 ~= nil then
		v5.CanvasSize = UDim2.new(0, 0, 0, v6.AbsoluteContentSize.Y + 16)
	end

	task.defer(syncScrollerCanvas)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyUi()
	if v ~= nil then
		v:Destroy()
		v = nil
		v2 = nil
		v3 = nil
	end
end

local function createUi()
	destroyUi() -- equivalent call inferred; original call site unknown
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DisplayAllTextsScanner"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 2147483647
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Terminal"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(0.75, 0.75)
	frame.BackgroundColor3 = color2
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.ZIndex = 10
	frame.Parent = screenGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 4)
	uICorner.Parent = frame
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = color4
	uIStroke.Thickness = 2
	uIStroke.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Header"
	frame2.Size = UDim2.new(1, 0, 0, 44)
	frame2.BackgroundColor3 = color3
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 11
	frame2.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Position = UDim2.fromOffset(12, 0)
	textLabel.Size = UDim2.new(1, -180, 1, 0)
	textLabel.Font = Enum.Font.Code
	textLabel.Text = "> TEXT_SCANNER.exe  //  TERMINAL"
	textLabel.TextColor3 = color
	textLabel.TextSize = 16
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 12
	textLabel.Parent = frame2
	local textButton = Instance.new("TextButton")
	textButton.Name = "Refresh"
	textButton.AnchorPoint = Vector2.new(1, 0.5)
	textButton.Position = UDim2.new(1, -88, 0.5, 0)
	textButton.Size = UDim2.fromOffset(72, 28)
	textButton.BackgroundColor3 = color3
	textButton.BorderSizePixel = 0
	textButton.Font = Enum.Font.Code
	textButton.Text = "REFRESH"
	textButton.TextColor3 = color
	textButton.TextSize = 12
	textButton.AutoButtonColor = true
	textButton.ZIndex = 12
	textButton.Parent = frame2
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Color = color4
	uIStroke2.Thickness = 1
	uIStroke2.Parent = textButton
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "Close"
	textButton2.AnchorPoint = Vector2.new(1, 0.5)
	textButton2.Position = UDim2.new(1, -8, 0.5, 0)
	textButton2.Size = UDim2.fromOffset(72, 28)
	textButton2.BackgroundColor3 = color3
	textButton2.BorderSizePixel = 0
	textButton2.Font = Enum.Font.Code
	textButton2.Text = "CLOSE"
	textButton2.TextColor3 = color
	textButton2.TextSize = 12
	textButton2.AutoButtonColor = true
	textButton2.ZIndex = 12
	textButton2.Parent = frame2
	local uIStroke3 = Instance.new("UIStroke")
	uIStroke3.Color = color4
	uIStroke3.Thickness = 1
	uIStroke3.Parent = textButton2
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "Scroller"
	scrollingFrame.Position = UDim2.fromOffset(0, 44)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -44)
	scrollingFrame.BackgroundColor3 = color2
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 10
	scrollingFrame.ScrollBarImageColor3 = color
	scrollingFrame.ScrollingEnabled = true
	scrollingFrame.Active = true
	scrollingFrame.Selectable = true
	scrollingFrame.ClipsDescendants = true
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Always
	scrollingFrame.ZIndex = 11
	scrollingFrame.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 8)
	uIPadding.PaddingBottom = UDim.new(0, 8)
	uIPadding.PaddingLeft = UDim.new(0, 10)
	uIPadding.PaddingRight = UDim.new(0, 18)
	uIPadding.Parent = scrollingFrame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Vertical
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Padding = UDim.new(0, 2)
	uIListLayout.Parent = scrollingFrame
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local v4 = v2
		local v5 = v3

		if v4 ~= nil then
			if v5 == nil then
				return
			else
				v4.CanvasSize = UDim2.new(0, 0, 0, v5.AbsoluteContentSize.Y + 16)
			end
		end
	end)
	textButton2.MouseButton1Click:Connect(function()
		destroyUi() -- equivalent call inferred; original call site unknown
	end)
	textButton.MouseButton1Click:Connect(function()
		DisplayAllTextsController.RunScan()
	end)
	v = screenGui
	v2 = scrollingFrame
	v3 = uIListLayout
	return screenGui
end

function DisplayAllTextsController.RunScan()
	if flag then
		return
	end

	flag = true
	local ui = createUi()
	setOutputLines({ "> INITIALIZING SCAN...", "> Gathering visible GUI + WORLD texts..." })
	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local v4 = playerGui == nil and {} or collectVisibleGuiTexts(playerGui, ui)
	local v5

	if humanoidRootPart == nil then
		v5 = {}
	else
		local nearbyPartSet, v6 = buildNearbyPartSet(humanoidRootPart)
		v5 = collectWorldTexts(nearbyPartSet, humanoidRootPart.Position, ui)
		v6:Destroy()
	end

	if v == ui then
		setOutputLines(buildOutputLines(v4, v5, humanoidRootPart == nil))
	end

	flag = false
end

function DisplayAllTextsController.FrameworkInit() end

function DisplayAllTextsController.FrameworkStart() end

return DisplayAllTextsController