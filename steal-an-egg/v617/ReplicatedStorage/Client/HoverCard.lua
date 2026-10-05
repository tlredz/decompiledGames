local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Audio = require(ReplicatedStorage.Shared.Audio)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local ViewportSize = require(ReplicatedStorage.Client.ViewportSize)
local hoverCard = ReplicatedStorage.Assets.UI.Misc.HoverCard
local card = hoverCard.Card
local rows = hoverCard.Rows
local rarityGradients = ReplicatedStorage.Assets.UI.RarityGradients
local rarities = Rarity.Rarities
local v = {
	ClipToDeviceSafeArea = false,
	DisplayOrder = 16384,
	Name = "HoverCardLayer",
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.None,
	ZIndexBehavior = Enum.ZIndexBehavior.Global
}
local color = Color3.new(1, 1, 1)
local v2 = {
	body = "Body",
	heading = "Heading",
	rule = "Rule",
	tier = "Tier"
}
local v3 = {
	body = 190,
	heading = 240,
	tier = 280
}
local HoverCard = {}
local v4 = nil
local v5 = nil

local function child(instance, childName: string)
	local child2 = instance:FindFirstChild(childName)
	assert(child2, (`{instance:GetFullName()} is missing {childName}`))
	return child2
end

local function layer()
	local v6 = v4

	if v6 then
		return v6
	end

	local screenGui = Instance.new("ScreenGui")

	for k, v7 in v do
		screenGui[k] = v7
	end

	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v4 = screenGui
	return screenGui
end

local function origin()
	local v6 = v4

	if v6 then
		return v6.AbsolutePosition
	end

	v6 = Instance.new("ScreenGui")

	for k, v7 in v do
		v6[k] = v7
	end

	v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v4 = v6
	return v6.AbsolutePosition
end

local function room()
	local v6 = v4

	if not v6 then
		v6 = Instance.new("ScreenGui")

		for k, v7 in v do
			v6[k] = v7
		end

		v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v6
	end

	local absoluteSize = v6.AbsoluteSize

	if absoluteSize.X > 0 and absoluteSize.Y > 0 then
		return absoluteSize
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		return currentCamera.ViewportSize
	end

	return Vector2.one
end

local function rectOf(p)
	local v6 = {
		origin = 0,
		size = 0
	}
	local absolutePosition = p.AbsolutePosition
	local v7 = v4

	if not v7 then
		v7 = Instance.new("ScreenGui")

		for k, v8 in v do
			v7[k] = v8
		end

		v7.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v7
	end

	v6.origin = absolutePosition - v7.AbsolutePosition
	v6.size = p.AbsoluteSize
	return v6
end

local function pointer()
	local mouseLocation = UserInputService:GetMouseLocation()
	local v6 = v4

	if v6 then
		return mouseLocation - v6.AbsolutePosition
	end

	v6 = Instance.new("ScreenGui")

	for k, v7 in v do
		v6[k] = v7
	end

	v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v4 = v6
	return mouseLocation - v6.AbsolutePosition
end

local function contains(p, point: Vector2)
	local v6 = point - p.origin
	return v6.X >= 0 and v6.Y >= 0 and v6.X <= p.size.X and v6.Y <= p.size.Y
end

local function overlaps(p, p2)
	if p.origin.X < p2.origin.X + p2.size.X and p2.origin.X < p.origin.X + p.size.X and p.origin.Y < p2.origin.Y + p2.size.Y then
		return p2.origin.Y < p.origin.Y + p.size.Y
	else
		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fitInside(point: Vector2, point2: Vector2, absoluteSize: Vector2)
	local max = (absoluteSize - point2):Max(Vector2.zero)
	return point:Max(Vector2.zero):Min(max)
end

local function sideFacingCentre(point: Vector2)
	local v6 = v4

	if not v6 then
		v6 = Instance.new("ScreenGui")

		for k, v7 in v do
			v6[k] = v7
		end

		v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v6
	end

	local absoluteSize = v6.AbsoluteSize

	if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.one
		end
	end

	return Vector2.new(point.X <= absoluteSize.X / 2 and 1 or -1, point.Y <= absoluteSize.Y / 2 and 1 or -1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function settle(card2, point: Vector2, point2: Vector2)
	local v6 = v4

	if not v6 then
		v6 = Instance.new("ScreenGui")

		for k, v7 in v do
			v6[k] = v7
		end

		v6.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v6
	end

	local absoluteSize = v6.AbsoluteSize

	if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.one
		end
	end

	local v7 = fitInside(point, point2, absoluteSize) -- equivalent call inferred; original call site unknown
	card2.AnchorPoint = Vector2.zero
	card2.Position = UDim2.fromOffset(v7.X, v7.Y)
end

local function placeAtPointer(data, point: Vector2, point2: Vector2)
	local side = data.side
	local clearance = data.clearance
	local card2 = data.card
	local v6

	if side.X > 0 then
		v6 = point.X + clearance
	else
		v6 = point.X - clearance - point2.X
	end

	local v7

	if side.Y > 0 then
		v7 = point.Y + clearance
	else
		v7 = point.Y - clearance - point2.Y
	end

	settle(card2, Vector2.new(v6, v7), point2) -- equivalent call inferred; original call site unknown
end

local function hintsFrameFor(source)
	local screenGui = source:FindFirstAncestorOfClass("ScreenGui")
	local parent = source.Parent

	while parent ~= nil and parent ~= screenGui do
		local gamepadHintsFrame = parent:FindFirstChild("GamepadHintsFrame")

		if gamepadHintsFrame and gamepadHintsFrame:IsA("GuiObject") and gamepadHintsFrame.Visible then
			return gamepadHintsFrame
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function placeBeside(data, footprint: Vector2)
	local side = data.side
	local clearance = data.clearance
	local source = data.source
	local v6 = {
		origin = 0,
		size = 0
	}
	local absolutePosition = source.AbsolutePosition
	local v7 = v4

	if not v7 then
		v7 = Instance.new("ScreenGui")

		for k, v8 in v do
			v7[k] = v8
		end

		v7.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v7
	end

	v6.origin = absolutePosition - v7.AbsolutePosition
	v6.size = source.AbsoluteSize
	local v8 = v4

	if not v8 then
		v8 = Instance.new("ScreenGui")

		for k, v9 in v do
			v8[k] = v9
		end

		v8.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v8
	end

	local absoluteSize = v8.AbsoluteSize

	if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.one
		end
	end

	local v9 = v6.origin + (v6.size - footprint) / 2
	local v10 = v6.origin.Y + v6.size.Y + clearance
	local v11 = v6.origin.Y - clearance - footprint.Y
	local v12 = v6.origin.X + v6.size.X + clearance
	local v13 = v6.origin.X - clearance - footprint.X
	local X = v9.X
	local v15

	if side.Y > 0 then
		v15 = v10
	else
		v15 = v11
	end

	local vector = Vector2.new(X, v15)
	local X2 = v9.X

	if side.Y > 0 then
		v10 = v11
	end

	local vector2 = Vector2.new(X2, v10)
	local v16

	if side.X > 0 then
		v16 = v12
	else
		v16 = v13
	end

	local vector3 = Vector2.new(v16, v9.Y)

	if side.X > 0 then
		v12 = v13
	end

	local v14 = {
		vector,
		vector2,
		vector3,
		Vector2.new(v12, v9.Y)
	}
	local v17 = hintsFrameFor(data.source)
	local v18

	if v17 then
		v18 = {
			origin = 0,
			size = 0
		}
		local absolutePosition2 = v17.AbsolutePosition
		local v19 = v4

		if not v19 then
			v19 = Instance.new("ScreenGui")

			for k, v20 in v do
				v19[k] = v20
			end

			v19.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			v4 = v19
		end

		v18.origin = absolutePosition2 - v19.AbsolutePosition
		v18.size = v17.AbsoluteSize
	end

	for _, origin2 in v14 do
		local v20 = origin2 == fitInside(origin2, footprint, absoluteSize)
		local v21 = v18 == nil or not overlaps({
			origin = origin2,
			size = footprint
		}, v18)

		if not (v20 and v21) then
			continue
		end

		settle(data.card, origin2, footprint) -- equivalent call inferred; original call site unknown
		return
	end

	settle(data.card, v14[1], footprint) -- equivalent call inferred; original call site unknown
end

local function stripMarkup(value: string)
	return (string.gsub(value, "<[^<>]*>", ""))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function looksMarkedUp(value: string)
	return string.find(value, "<%a[^<>]*>") ~= nil
end

local function measure(title, value: string, width: number)
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = title.FontFace
	getTextBoundsParams.Size = title.TextSize
	getTextBoundsParams.Text = string.gsub(value, "<[^<>]*>", "")
	getTextBoundsParams.Width = width
	local success, result = pcall(function()
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if success and typeof(result) == "Vector2" then
		return result
	end

	return Vector2.new(width, title.TextSize)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cardScale()
	return (math.sqrt((math.min(ViewportSize.ReadScale(), 1))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function labelInset(title)
	local uIStroke = title:FindFirstChildOfClass("UIStroke")
	local v6 = not uIStroke and 0 or uIStroke.Thickness
	local v7 = math.round(title.TextSize / 4)
	return Vector2.new(v7, 0) * 2 + Vector2.one * (v6 * 2)
end

local function paintGradient(parent, instance)
	local uIGradient = parent:FindFirstChildOfClass("UIGradient")

	if uIGradient == nil then
		local clone = instance:Clone()
		clone.Parent = parent
		return
	end

	uIGradient.Color = instance.Color
	uIGradient.Enabled = instance.Enabled
	uIGradient.Offset = instance.Offset
	uIGradient.Rotation = instance.Rotation
	uIGradient.Transparency = instance.Transparency
end

local function gradientNamed(childName)
	if type(childName) ~= "string" then
		return nil
	end

	local uIGradient = rarityGradients:FindFirstChild(childName)

	if uIGradient and uIGradient:IsA("UIGradient") then
		return uIGradient
	end

	return nil
end

local function styleText(parent, data)
	local text = tostring(data.text or "")
	parent.RichText = looksMarkedUp(text)
	parent.Text = text

	if typeof(data.tint) == "Color3" then
		parent.TextColor3 = data.tint
	end

	local gradient = data.gradient
	local uIGradient

	if type(gradient) == "string" then
		uIGradient = rarityGradients:FindFirstChild(gradient)

		if not (uIGradient and uIGradient:IsA("UIGradient")) then
			uIGradient = nil
		end
	end

	if not uIGradient then
		return text
	end

	parent.TextColor3 = color
	local uIGradient2 = parent:FindFirstChildOfClass("UIGradient")

	if uIGradient2 == nil then
		local clone = uIGradient:Clone()
		clone.Parent = parent
		return text
	end

	uIGradient2.Color = uIGradient.Color
	uIGradient2.Enabled = uIGradient.Enabled
	uIGradient2.Offset = uIGradient.Offset
	uIGradient2.Rotation = uIGradient.Rotation
	uIGradient2.Transparency = uIGradient.Transparency
	return text
end

local function rarityConfig(p)
	local selected

	if type(p) == "table" then
		selected = p
	else
		selected = rarities[p]
	end

	assert(selected, (`Unknown rarity: {tostring(p)}`))
	return selected
end

local function styleTier(parent, p)
	local rarity = p.rarity
	local v6

	if type(rarity) == "table" then
		v6 = rarity
	else
		v6 = rarities[rarity]
	end

	assert(v6, (`Unknown rarity: {tostring(rarity)}`))
	parent.Text = v6.DisplayName
	local rarityGradient = v6.RarityGradient
	local uIGradient = parent:FindFirstChildOfClass("UIGradient")

	if uIGradient == nil then
		local clone = rarityGradient:Clone()
		clone.Parent = parent
	else
		uIGradient.Color = rarityGradient.Color
		uIGradient.Enabled = rarityGradient.Enabled
		uIGradient.Offset = rarityGradient.Offset
		uIGradient.Rotation = rarityGradient.Rotation
		uIGradient.Transparency = rarityGradient.Transparency
	end

	local uIStroke = parent:FindFirstChildOfClass("UIStroke")

	if not uIStroke then
		return v6.DisplayName
	end

	local rarityGradient2 = v6.RarityGradient
	local uIGradient2 = uIStroke:FindFirstChildOfClass("UIGradient")

	if uIGradient2 == nil then
		local clone_2 = rarityGradient2:Clone()
		clone_2.Parent = uIStroke
	else
		uIGradient2.Color = rarityGradient2.Color
		uIGradient2.Enabled = rarityGradient2.Enabled
		uIGradient2.Offset = rarityGradient2.Offset
		uIGradient2.Rotation = rarityGradient2.Rotation
		uIGradient2.Transparency = rarityGradient2.Transparency
	end

	return v6.DisplayName
end

local v6 = {
	body = styleText,
	heading = styleText,
	tier = styleTier
}

local function buildBlock(p, layoutOrder: number)
	local kind = tostring(p.kind)
	local v7 = v2[kind]
	assert(v7 ~= nil, (`Unknown hover card row kind: {kind}`))
	local guiObject = rows:FindFirstChild(v7)
	assert(guiObject and guiObject:IsA("GuiObject"), (`Missing hover card row template: {v7}`))
	local clone = guiObject:Clone()
	clone.LayoutOrder = layoutOrder
	local v8 = v6[kind]

	if v8 == nil then
		return {
			frame = clone,
			height = clone.Size.Y.Offset,
			width = 72
		}
	end

	local title = clone:FindFirstChild("title")
	assert(title and title:IsA("TextLabel"), (`Hover card row template {v7} needs a title label`))
	local v9 = v8(title, p)
	local width = v3[kind]
	local v12 = measure(title, v9, width) + labelInset(title)
	local height = math.max(math.ceil(v12.Y), title.TextSize)
	clone.Size = UDim2.new(1, 0, 0, height)
	return {
		frame = clone,
		height = height,
		width = math.clamp(math.ceil(v12.X), 72, width)
	}
end

local function follow(data, point: Vector2?)
	local source = data.source

	if not GamepadBindings.IsOnScreen(source) then
		HoverCard.Dismiss()
		return
	end

	local footprint = point or data.card.AbsoluteSize

	if footprint.X <= 0 or footprint.Y <= 0 then
		footprint = data.footprint
	end

	if data.viaSelection then
		placeBeside(data, footprint)
		return
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local v8 = v4

	if not v8 then
		v8 = Instance.new("ScreenGui")

		for k, v9 in v do
			v8[k] = v9
		end

		v8.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v8
	end

	placeAtPointer(data, mouseLocation - v8.AbsolutePosition, footprint)
end

local function stillHovered(p)
	if p.viaSelection then
		return GuiService.SelectedObject == p.source
	end

	local source = p.source
	local v7 = {
		origin = 0,
		size = 0
	}
	local absolutePosition = source.AbsolutePosition
	local v8 = v4

	if not v8 then
		v8 = Instance.new("ScreenGui")

		for k, v9 in v do
			v8[k] = v9
		end

		v8.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v8
	end

	v7.origin = absolutePosition - v8.AbsolutePosition
	v7.size = source.AbsoluteSize
	local mouseLocation = UserInputService:GetMouseLocation()
	local v9 = v4

	if not v9 then
		v9 = Instance.new("ScreenGui")

		for k, v10 in v do
			v9[k] = v10
		end

		v9.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v9
	end

	local v10 = mouseLocation - v9.AbsolutePosition - v7.origin
	return v10.X >= 0 and v10.Y >= 0 and v10.X <= v7.size.X and v10.Y <= v7.size.Y
end

local function dismissWhenLeft(data)
	local source = data.source
	local links = data.links
	local v7

	if data.viaSelection then
		v7 = source.SelectionLost
	else
		v7 = source.MouseLeave
	end

	links:Connect(v7, HoverCard.Dismiss)
	links:Connect(source.Destroying, HoverCard.Dismiss)

	if data.viaSelection then
		links:Connect(GuiService:GetPropertyChangedSignal("SelectedObject"), function()
			if GuiService.SelectedObject ~= source then
				HoverCard.Dismiss()
			end
		end)
	end
end

local function present(source2, list, viaSelection: boolean?)
	HoverCard.Dismiss()

	if #list == 0 then
		return
	end

	local clone = card:Clone()
	clone.Visible = false
	local frame = clone:FindFirstChild("Frame")
	assert(frame, (`{clone:GetFullName()} is missing Frame`))
	local rows2 = frame:FindFirstChild("Rows")
	assert(rows2, (`{frame:GetFullName()} is missing Rows`))
	local v7 = assert(
		rows2:FindFirstChildOfClass("UIListLayout"),
		"Hover card template needs a UIListLayout under Rows"
	)
	local v8 = assert(rows2:FindFirstChildOfClass("UIPadding"), "Hover card template needs a UIPadding under Rows")
	local v9 = {
		card = clone,
		clearance = 12,
		footprint = Vector2.zero,
		links = Trove.new(),
		side = Vector2.one,
		source = source2,
		viaSelection = 0
	}

	if viaSelection == nil then
		viaSelection = GuiService.SelectedObject == source2
	end

	v9.viaSelection = viaSelection
	v5 = v9
	v9.links:Add(clone)
	dismissWhenLeft(v9)
	local Y = v7.Padding.Offset * (#list - 1)
	local v10 = 72

	for k, v11 in list do
		local block = buildBlock(v11, k)

		if v5 ~= v9 then
			return
		end

		v10 = math.max(v10, block.width)
		Y += block.height
		block.frame.Parent = rows2
	end

	local parent = v4

	if not parent then
		parent = Instance.new("ScreenGui")

		for k, v12 in v do
			parent[k] = v12
		end

		parent.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = parent
	end

	clone.Parent = parent
	task.wait()

	if v5 ~= v9 then
		return
	end

	local absoluteContentSize = v7.AbsoluteContentSize
	local v12 = v10 + v8.PaddingLeft.Offset + v8.PaddingRight.Offset

	if absoluteContentSize.Y > 0 then
		Y = absoluteContentSize.Y
	end

	local v13 = Y + v8.PaddingTop.Offset + v8.PaddingBottom.Offset
	local scale = cardScale() -- equivalent call inferred; original call site unknown
	local uIScale = clone:FindFirstChild("UIScale")
	assert(uIScale, (`{clone:GetFullName()} is missing UIScale`))
	uIScale.Scale = scale
	clone.Size = UDim2.fromOffset(v12, v13)
	v9.clearance = scale * 12
	v9.footprint = Vector2.new(v12, v13) * scale
	local v15

	if v9.viaSelection then
		v15 = {
			origin = 0,
			size = 0
		}
		local absolutePosition = source2.AbsolutePosition
		local v16 = v4

		if not v16 then
			v16 = Instance.new("ScreenGui")

			for k, v17 in v do
				v16[k] = v17
			end

			v16.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			v4 = v16
		end

		v15.origin = absolutePosition - v16.AbsolutePosition
		v15.size = source2.AbsoluteSize
	end

	local v16

	if v15 then
		v16 = v15.origin + v15.size / 2
	else
		local mouseLocation = UserInputService:GetMouseLocation()
		local v17 = v4

		if not v17 then
			v17 = Instance.new("ScreenGui")

			for k, v18 in v do
				v17[k] = v18
			end

			v17.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			v4 = v17
		end

		v16 = mouseLocation - v17.AbsolutePosition
	end

	local v17 = v4

	if not v17 then
		v17 = Instance.new("ScreenGui")

		for k, v18 in v do
			v17[k] = v18
		end

		v17.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		v4 = v17
	end

	local absoluteSize = v17.AbsoluteSize

	if not (absoluteSize.X > 0 and absoluteSize.Y > 0) then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.one
		end
	end

	v9.side = Vector2.new(v16.X <= absoluteSize.X / 2 and 1 or -1, v16.Y <= absoluteSize.Y / 2 and 1 or -1)
	local v18

	if v9.viaSelection then
		v18 = GuiService.SelectedObject == v9.source
	else
		local source = v9.source
		local v19 = {
			origin = 0,
			size = 0
		}
		local absolutePosition = source.AbsolutePosition
		local v20 = v4

		if not v20 then
			v20 = Instance.new("ScreenGui")

			for k, v21 in v do
				v20[k] = v21
			end

			v20.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			v4 = v20
		end

		v19.origin = absolutePosition - v20.AbsolutePosition
		v19.size = source.AbsoluteSize
		local mouseLocation = UserInputService:GetMouseLocation()
		local v21 = v4

		if not v21 then
			v21 = Instance.new("ScreenGui")

			for k, v22 in v do
				v21[k] = v22
			end

			v21.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			v4 = v21
		end

		local v22 = mouseLocation - v21.AbsolutePosition - v19.origin

		if v22.X >= 0 and v22.Y >= 0 and v22.X <= v19.size.X then
			if v22.Y <= v19.size.Y then
				v18 = true
			else
				v18 = false
			end
		else
			v18 = false
		end
	end

	if not v18 then
		HoverCard.Dismiss()
		return
	end

	Audio.Play("rbxassetid://89944486811970", script, {
		Volume = 0.3
	})
	follow(v9, v9.footprint)

	if v5 ~= v9 then
		return
	end

	clone.Visible = true
	v9.links:Connect(RunService.RenderStepped, function()
		follow(v9)
	end)
end

function HoverCard.Show(source, p2)
	present(source, p2, nil)
end

function HoverCard.Attach(source, callback)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function reveal(flag: boolean)
		local v7

		if type(callback) == "function" then
			v7 = callback()
		else
			v7 = callback
		end

		if v7 then
			present(source, v7, flag)
		end
	end

	local maid = Trove.new()
	maid:Connect(source.MouseEnter, function()
		reveal(false) -- equivalent call inferred; original call site unknown
	end)
	maid:Connect(source.SelectionGained, function()
		reveal(true) -- equivalent call inferred; original call site unknown
	end)
	maid:Add(function()
		if v5 and v5.source == source then
			HoverCard.Dismiss()
		end
	end)
	return function()
		maid:Destroy()
	end
end

function HoverCard.Dismiss()
	local v7 = v5

	if v7 == nil then
		return
	end

	v5 = nil
	v7.links:Destroy()
end

Tabs.Deactivated:Connect(function()
	HoverCard.Dismiss()
end)
return HoverCard