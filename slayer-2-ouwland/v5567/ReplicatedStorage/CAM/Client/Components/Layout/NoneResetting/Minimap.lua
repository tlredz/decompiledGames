local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local localPlayer = Players.LocalPlayer
local faye = require(ReplicatedStorage.Packages.faye)
local uidragger = require(ReplicatedStorage.Packages.uidragger)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Skills_Provider = require(ReplicatedStorage.CAM.Client.Controllers.Skills_Provider)
local SkillTreeZoomSlider = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.Pages["Skill Tree"].MiscComponents.SkillTreeZoomSlider)
local Bosses = require(script.Pins.Bosses)
local Regions = require(script.Pins.Regions)
local Recommended = require(script.Pins.Recommended)
local Markers = require(script.Pins.Markers)
local Shrines = require(script.Pins.Shrines)
local SidePanel = require(script.SidePanel)
local Question = require(script.Question)
local Placed = require(script.Pins.Placed)
local MarkerHandler = require(ReplicatedStorage.CAM.Client.Modules.MarkerHandler)
local UserInputService = game:GetService("UserInputService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local visibility = ReplicatedStorage.CAM.Client.Components.Layout.Visibility
local v = Worlds.ById[game.PlaceId]
local minimap

if v == nil then
	minimap = nil
else
	minimap = v.Minimap
end

if minimap == nil then
	return function() end
end

local image

if typeof(minimap.Image) == "string" then
	image = {
		{ minimap.Image }
	}
else
	image = minimap.Image
end

local v2 = image[1] == nil and 0 or #image[1]
local vector2 = Vector2.new(minimap.BottomRight.X - minimap.TopLeft.X, minimap.BottomRight.Z - minimap.TopLeft.Z)

if vector2.X == 0 or vector2.Y == 0 then
	return function() end
end

local isRunning = RunService:IsRunning()

-- equivalent calls inferred from this helper; original call sites unknown
local function focusPosition()
	if not isRunning then
		return workspace.CurrentCamera.CFrame.Position
	end

	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil then
		return nil
	end

	return humanoidRootPart.Position
end

local rotation = minimap.Rotation or 0
local pointerRotation = minimap.PointerRotation or 0
local v3 = vector2.X < 0 and -1 or 1
local v4 = vector2.Y < 0 and 1 or -1

-- equivalent calls inferred from this helper; original call sites unknown
local function mapPoint(vector3: Vector3)
	return Vector2.new((vector3.X - minimap.TopLeft.X) / vector2.X, (vector3.Z - minimap.TopLeft.Z) / vector2.Y)
end

local function worldAt(point: Vector2)
	local v5 = minimap.TopLeft.X + point.X * vector2.X
	local v6 = minimap.TopLeft.Z + point.Y * vector2.Y
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local character

	if localPlayer ~= nil then
		character = localPlayer.Character
	end

	if character ~= nil then
		raycastParams.FilterDescendantsInstances = { character }
	end

	local raycastResult = workspace:Raycast(Vector3.new(v5, 1000, v6), createVector(0, -2000, 0), raycastParams)

	if raycastResult ~= nil then
		return raycastResult.Position + createVector(0, 0.2, 0), true
	end

	local v7 = focusPosition() -- equivalent call inferred; original call site unknown
	return Vector3.new(v5, v7 == nil and 0 or v7.Y, v6), false
end

local info = faye.Info(0.25)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.14, 0),
	NumberSequenceKeypoint.new(0.86, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local color = Color3.new(0.25, 0.25, 0.25)
local playerArrow = BunchaIcons.PlayerArrow
local uDim = UDim2.new(1, -5, 0, 5)
local uDim2 = UDim2.fromScale(0.63, 0.63)
local uDim3 = UDim2.fromScale(0.5, 0.5)
local color2 = Color3.new(0.3, 0.3, 0.3)
local uDim4 = UDim.new(1, 0)
local uDim5 = UDim.new(0.6, 0)
local uDim6 = UDim2.fromScale(0.05, 0.05)
local uDim7 = UDim2.fromScale(0.12, 0.12)
local color3 = Color3.new(0.443, 0.746, 1)
local info2 = faye.Info(0.2)
local numberSequence2 = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.8, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local colorSequence = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0.55, 0.55, 0.55))
local info3 = faye.Info(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local v5 = nil
local value = nil
return function(instance)
	local maid = faye.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onMobile()
		return Platform_Handler.Platform.Value == "Mobile"
	end

	local value2 = maid:Value(onMobile())
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		value2:Set(onMobile())
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closedSide()
		local absoluteSize = instance.AbsoluteSize
		return math.min(absoluteSize.X, absoluteSize.Y) * 0.2
	end

	local function closedSize()
		return UDim2.fromScale(0.2, 0.2)
	end

	local function closedPosition()
		local v6 = closedSide() -- equivalent call inferred; original call site unknown
		return UDim2.new(uDim.X.Scale, uDim.X.Offset - v6 / 2, uDim.Y.Scale, uDim.Y.Offset + v6 / 2)
	end

	local function openSize()
		local v6 = onMobile() and 1.2 or 1
		return UDim2.fromScale(uDim2.X.Scale * v6, uDim2.Y.Scale * v6)
	end

	local image2 = maid:Value("")
	local v6 = closedSide() * 0.138
	local side = closedSide() * 0.16
	local value4 = maid:Value(1)
	local value5 = maid:Value(closedPosition())
	local value6 = maid:Value(closedSize())
	local value7 = maid:Value(UDim2.fromScale(3, 3))
	local v8 = 0
	local zero = Vector2.zero
	local v9 = nil

	local function zoomAlpha(p: number)
		return (p - 0.8) / 11.2
	end

	local value8 = maid:Value(0.19642857142857145)
	local value9 = maid:Value(3)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshHolder()
		if v8 <= 0 then
			return
		end

		local v10 = v8 * value9.Value
		value7:Set(UDim2.fromOffset(v10, v10))
	end

	local size = maid:Value(UDim2.new())
	local position = maid:Value(UDim2.new())
	local size2 = maid:Value(UDim2.new())
	local position2 = maid:Value(UDim2.new())
	local value14 = maid:Value(UDim2.new())
	local value15 = maid:Value(UDim2.new())
	local value16 = maid:Value(UDim2.new())
	local value17 = maid:Value(UDim2.new())
	local size3 = maid:Value(UDim2.new())
	local position3 = maid:Value(UDim2.new())
	local value20 = maid:Value(false)

	local function refreshSlider(p)
		local v10 = p.AbsolutePosition - instance.AbsolutePosition
		local absoluteSize = p.AbsoluteSize
		local v11 = v10.Y + absoluteSize.Y + 18
		size:Set(UDim2.fromOffset(absoluteSize.X * 0.25 * 0.65, absoluteSize.Y * 0.09 * 0.65))
		position:Set(UDim2.fromOffset(v10.X, v11))
		local v12 = absoluteSize.Y * 0.11
		size2:Set(UDim2.fromOffset(v12, v12))
		position2:Set(UDim2.fromOffset(v10.X + absoluteSize.X - 12 - v12 / 2, v10.Y + absoluteSize.Y - 12 - v12 / 2))
		local v13 = absoluteSize.Y * 0.12
		value14:Set(UDim2.fromOffset(v13, v13))
		local v14 = absoluteSize.Y * 0.054
		value15:Set(UDim2.fromOffset(v14, v14))
		local v15 = math.max(0, v10.X - 8 - 8)
		local v16 = math.min(absoluteSize.X * 0.336, v15)
		size3:Set(UDim2.fromOffset(v16, absoluteSize.Y))
		position3:Set(UDim2.fromOffset(v10.X - 8, v10.Y + absoluteSize.Y / 2))
		value16:Set(UDim2.fromOffset(v10.X - 8 - v16 - 8, v10.Y))
		value17:Set(UDim2.fromOffset(v10.X + absoluteSize.X / 2, v10.Y + absoluteSize.Y + 8))
	end

	local value21 = maid:Value(UDim2.fromScale(0.5, 0.5))
	local anchorPoint = maid:Value(Vector2.new(0.5, 0.5))
	local position4 = maid:Value(UDim2.fromScale(0.5, 0.5))
	local rotation2 = maid:Value(pointerRotation)
	local clickable = maid:Value(false)
	local value26 = maid:Value(nil)
	local value27 = maid:Value(nil)

	local function syncWorldMarker(point: Vector2?)
		MarkerHandler.removeMarker("PlacedMarker")

		if point == nil then
			return
		end

		local position5 = worldAt(point)
		MarkerHandler.addMarker("PlacedMarker", {
			markerType = MarkerHandler.markerType.Regular,
			style = "Simple",
			img = "rbxassetid://140481492902657",
			position = position5,
			tag = "Default",
			minDistance = 20,
			margin = 10,
			displayDistance = true,
			indicator = true,
			indicatorColor = color3
		})
	end

	maid:Connect(value27.Changed, syncWorldMarker)
	maid:Spawn(function()
		while true do
			task.wait(3)
			local value28 = value27.Value
			local placedMarker = MarkerHandler.currentMarkers.PlacedMarker

			if not (value28 ~= nil and placedMarker ~= nil) then
				continue
			end

			local position5, v11 = worldAt(value28)

			if v11 then
				placedMarker.position = position5
			end
		end
	end)
	maid:Add(function()
		MarkerHandler.removeMarker("PlacedMarker")
	end)

	local function clampPan()
		if not clickable.Value or v8 <= 0 or zero.X <= 0 or zero.Y <= 0 then
			return
		end

		local v10 = v8 * value9.Value
		local value28 = anchorPoint.Value
		local value29 = value21.Value

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bounded(offset: number, p: number, p2: number)
			local v11 = p * v10 - v10 + p2 * 0.30000000000000004
			local v12 = p * v10 + p2 * -0.30000000000000004

			if v12 < v11 then
				return (v11 + v12) / 2
			end

			return (math.clamp(offset, v11, v12))
		end

		local v11 = bounded(value29.X.Offset, value28.X, zero.X) -- equivalent call inferred; original call site unknown
		local v12 = bounded(value29.Y.Offset, value28.Y, zero.Y) -- equivalent call inferred; original call site unknown

		if v11 ~= value29.X.Offset or v12 ~= value29.Y.Offset then
			value21:Set(UDim2.new(0.5, v11, 0.5, v12))
		end
	end

	local value28 = maid:Value(1)
	local value29 = maid:Value(0)
	local size4 = maid:Value(UDim2.fromScale(1, 1))
	local position6 = maid:Value(UDim2.new())

	local function refreshInset()
		local Y = GuiService:GetGuiInset().Y
		size4:Set(UDim2.new(1, 0, 1, Y))
		position6:Set(UDim2.fromOffset(0, -Y))
	end

	refreshInset()
	maid:Connect(GuiService:GetPropertyChangedSignal("TopbarInset"), refreshInset)
	local v10 = visibility:FindFirstChild("Minimap")

	if v10 == nil then
		v10 = Instance.new("BoolValue")
		v10.Name = "Minimap"
		v10.Value = true
		v10.Parent = visibility
	end

	local instancePropertySync = maid:InstancePropertySync(v10, "Value")
	local v11 = false
	local gamepadCursorEnabled = false
	local gamepadCursorEnabledChangedConnection = nil

	local function cursor(mapOpened: boolean)
		if mapOpened == v11 then
			return
		end

		if mapOpened then
			if not Platform_Handler.IsGamepad() or v9 == nil then
				return
			end

			local v12 = v9
			v11 = true
			gamepadCursorEnabled = GamepadService.GamepadCursorEnabled
			GamepadService:EnableGamepadCursor(v12)
			gamepadCursorEnabledChangedConnection = GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
				if v11 and not GamepadService.GamepadCursorEnabled then
					GamepadService:EnableGamepadCursor(v12)
				end
			end)
		else
			v11 = false

			if gamepadCursorEnabledChangedConnection ~= nil then
				gamepadCursorEnabledChangedConnection:Disconnect()
				gamepadCursorEnabledChangedConnection = nil
			end

			if not gamepadCursorEnabled then
				GamepadService:DisableGamepadCursor()
			end
		end
	end

	local function setOpen(mapOpened: boolean)
		clickable:Set(mapOpened)

		if not mapOpened then
			value26:Set(nil)
		end

		cursor(mapOpened)

		if localPlayer ~= nil then
			localPlayer:SetAttribute("MapOpened", mapOpened)
		end

		if mapOpened then
			value4:Set(1.6)
			value6:Set(openSize())
			value5:Set(uDim3)

			if v5 ~= nil then
				value8:Set(v5)
			end

			if value ~= nil then
				value21:Set(value)
			end

			refreshInset()
			value28:Set(0.15)
			value29:Set(20)
			image2:Set("rbxassetid://87028346613151")
		else
			value4:Reset()
			value6:Set(closedSize())
			value5:Set(closedPosition())
			value28:Reset()
			value29:Reset()
			image2:Reset()
			value21:Reset()
			value8:Reset()
		end
	end

	maid:Connect(v10.Changed, function(flag: boolean)
		if flag == false and clickable.Value then
			setOpen(false)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchMenu(p)
		maid:Connect(p.Changed, function(p2: string)
			if p2 ~= "" and clickable.Value then
				setOpen(false)
			end
		end)
	end

	maid:Add(InputHandler.ScreenClicked(function(p: string, flag: boolean)
		if p ~= "Down" or flag or not clickable.Value then
			return
		end

		ScreenEffects.CircleClick()
		setOpen(false)
	end))

	if localPlayer ~= nil then
		local menuDestination = localPlayer:FindFirstChild("MenuDestination")

		if menuDestination == nil then
			maid:Connect(localPlayer.ChildAdded, function(p)
				if p.Name == "MenuDestination" then
					watchMenu(p) -- equivalent call inferred; original call site unknown
				end
			end)
		else
			maid:Connect(menuDestination.Changed, function(p: string)
				if p ~= "" and clickable.Value then
					setOpen(false)
				end
			end)
		end
	end

	local initial = value8.Initial
	local initial2 = value21.Initial

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshRecentre()
		local value32 = value21.Value
		value20:Set(value8.Value ~= initial or value32.X.Offset ~= initial2.X.Offset or value32.Y.Offset ~= initial2.Y.Offset)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function recentre()
		value8:Reset()
		value21:Reset()
		v5 = nil
		value = nil
		refreshRecentre() -- equivalent call inferred; original call site unknown
	end

	local function refreshClosed()
		if clickable.Value then
			return
		end

		value6:Set(closedSize())
		value5:Set(closedPosition())
	end

	maid:Connect(instance:GetPropertyChangedSignal("AbsoluteSize"), refreshClosed)
	maid:Connect(Platform_Handler.Platform.Changed.Event, refreshClosed)
	local v12 = false
	local v13 = false
	local v14 = nil
	maid:Connect(RunService.RenderStepped, function(p: number)
		local v15 = (v12 and 1 or 0) - (v13 and 1 or 0)

		if v15 ~= 0 and clickable.Value then
			value8:Set((math.clamp(value8.Value + v15 * 0.6 * p, 0, 1)))
		end

		local v16 = focusPosition() -- equivalent call inferred; original call site unknown

		if v16 == nil then
			return
		end

		local v17 = mapPoint(v16) -- equivalent call inferred; original call site unknown
		anchorPoint:Set(v17)
		position4:Set(UDim2.fromScale(v17.X, v17.Y))
		local lookVector = workspace.CurrentCamera.CFrame.LookVector
		local v18 = pointerRotation + math.deg((math.atan2(lookVector.X * v3, lookVector.Z * v4)))

		if v14 == nil then
			v14 = v18
		else
			local v19 = (v18 - v14 + 180) % 360 - 180
			v14 += v19 * (1 - math.exp(p * -10))
		end

		rotation2:Set(v14)
		clampPan()
	end)
	local v15 = maid:Add(uidragger.new())
	local v16 = nil
	local mouseLocation = nil
	local now = 0
	local v17 = nil

	local function spotAt(mouseLocation2: Vector2)
		local v18 = v17

		if v18 == nil or v18.AbsoluteSize.X <= 0 then
			return nil
		end

		local Y = GuiService:GetGuiInset().Y
		local v19 = (mouseLocation2 - Vector2.new(0, Y) - v18.AbsolutePosition) / v18.AbsoluteSize

		if rotation == 0 then
			return v19
		end

		local value32 = anchorPoint.Value
		local v20 = v19 - value32
		local v21 = math.rad(-rotation)
		local v22 = math.cos(v21)
		local v23 = math.sin(v21)
		return value32 + Vector2.new(v20.X * v22 - v20.Y * v23, v20.X * v23 + v20.Y * v22)
	end

	local function updateDrag(p)
		if p == nil or not clickable.Value then
			return
		end

		if v16 == nil then
			v16 = {
				X = p.X,
				Y = p.Y
			}
			return
		end

		local v18 = v16
		local v19 = p.X - v18.X
		local v20 = p.Y - v18.Y
		local X = p.X
		local Y = p.Y
		v18.X = X
		v18.Y = Y
		value21 += UDim2.fromOffset(v19, v20)
		clampPan()
		value = value21.Value
		refreshRecentre() -- equivalent call inferred; original call site unknown
	end

	v15.Changed:Connect(updateDrag)
	v15.Ended:Connect(updateDrag)

	local function zoomAt(point: Vector2, p, value32: number, value33: UDim2)
		if value32 <= 0 or value9.Value == value32 then
			return
		end

		local v18 = point - (p.AbsolutePosition + p.AbsoluteSize / 2)
		local v19 = value9.Value / value32
		local v20 = v18 - (v18 - Vector2.new(value33.X.Offset, value33.Y.Offset)) * v19
		value21:Set(UDim2.new(0.5, v20.X, 0.5, v20.Y))
		clampPan()
		value = value21.Value
	end

	local function trigger(flag: boolean, p: string)
		if p == "In" then
			v12 = flag
		else
			v13 = flag
		end
	end

	maid:Add(InputHandler.ListenTo("Zoom_In", function(p: string)
		v12 = p == "Down"
	end))
	maid:Add(InputHandler.ListenTo("Zoom_Out", function(p: string)
		v13 = p == "Down"
	end))
	local v18 = {
		"Skills_1st",
		"Skills_2nd",
		"Skills_3rd",
		"Skills_4th",
		"Skills_5th",
		"Skills_6th",
		"Skills_7th",
		"Skills_8th",
		"Skills_9th",
		"Skills_10th"
	}

	local function pressTakenBySkill()
		local padBinding, v19 = InputHandler.PadBinding("Map")

		if padBinding == nil then
			return false
		end

		local get_current_keys = Skills_Provider.get_current_keys()

		if get_current_keys == nil then
			return false
		end

		for k, v20 in v18 do
			if get_current_keys[k] == nil then
				continue
			end

			local padBinding2, v21 = InputHandler.PadBinding(v20)

			if padBinding2 == padBinding and v21 == v19 then
				return true
			end
		end

		return false
	end

	maid:Add(InputHandler.ListenTo("Map", function(p: string, flag: boolean)
		if p ~= "Down" or flag or clickable.Value or not v10.Value then
			return
		end

		if Platform_Handler.IsGamepad() and pressTakenBySkill() then
			return
		end

		ScreenEffects.CircleClick()
		setOpen(true)
	end))
	maid:Add(InputHandler.ListenTo("Map_Close", function(p: string, flag: boolean)
		if p ~= "Down" or flag or not clickable.Value then
			return
		end

		ScreenEffects.CircleClick()
		setOpen(false)
	end))
	maid:Add(InputHandler.Pinched(function(p: string, p2: number, point: Vector2, p3: number?)
		if not clickable.Value then
			return
		end

		if p == "Began" then
			v15:End()
		elseif p == "Ended" then
			if p3 == 1 then
				v15:Start()
				v16 = nil
			end
		else
			if p2 <= 0 or v9 == nil then
				return
			end

			local value32 = value9.Value
			local value33 = value21.Value
			value8:Set((math.clamp((math.clamp(value9.Value * p2, 0.8, 12) - 0.8) / 11.2, 0, 1)))
			zoomAt(point, v9, value32, value33)
		end
	end))
	maid:Connect(value8.Changed, function(p: number)
		value9:Set(p * 11.2 + 0.8)
		refreshHolder() -- equivalent call inferred; original call site unknown
		clampPan()
		refreshRecentre() -- equivalent call inferred; original call site unknown

		if clickable.Value then
			v5 = p
			value = value21.Value
		end
	end)
	local v19 = {}

	for k, v20 in image do
		for k2, image3 in v20 do
			table.insert(v19, maid:Create("ImageLabel")({
				Name = `Tile{k}_{k2}`,
				Image = image3,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1 / v2, 1 / #image),
				Position = UDim2.fromScale((k2 - 1) / v2, (k - 1) / #image)
			}))
		end
	end

	local function settle()
		local flag = false
		return function(p)
			if flag then
				return maid:Animation(p, info)
			end

			flag = true
			return p
		end
	end

	local flag = false

	local function fn(p)
		if flag then
			return maid:Animation(p, info)
		end

		flag = true
		return p
	end

	local flag2 = false

	local function fn2(p)
		if flag2 then
			return maid:Animation(p, info)
		end

		flag2 = true
		return p
	end

	local flag3 = false

	local function fn3(p)
		if flag3 then
			return maid:Animation(p, info)
		end

		flag3 = true
		return p
	end

	maid:Create("CanvasGroup")({
		Name = "Minimap",
		Parent = instance,
		Visible = maid:Do(function(callback)
			return callback(instancePropertySync) == true and (not callback(value2) or callback(clickable))
		end),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(0.05)
		}),
		maid:Create("UIShadow")({
			Color = color2,
			Transparency = maid:Do(function(callback)
				return fn(callback(clickable) and 0.3 or 0.55)
			end),
			BlurRadius = maid:Do(function(callback)
				local v21

				if callback(clickable) then
					v21 = uDim5
				else
					v21 = uDim4
				end

				return fn2(v21)
			end),
			Spread = maid:Do(function(callback)
				local v21

				if callback(clickable) then
					v21 = uDim7
				else
					v21 = uDim6
				end

				return fn3(v21)
			end)
		}),
		maid:Create("UIGradient")({
			Transparency = numberSequence
		}),
		Size = maid:Animation(value6, info),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = maid:Animation(value5, info),
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = maid:Animation(value4, info)
		}),
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		AbsoluteSizeOnChangedInit = function(p, point: Vector2)
			v9 = p
			zero = point
			v8 = math.max(point.X, point.Y)
			refreshHolder() -- equivalent call inferred; original call site unknown
			clampPan()
			refreshSlider(p)
		end,
		AbsolutePositionOnChangedInit = function(p)
			refreshSlider(p)
		end,
		maid:Create("CanvasGroup")({
			Name = "FadeMask",
			ZIndex = 2,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			maid:Create("UIGradient")({
				Rotation = 90,
				Transparency = numberSequence
			}),
			maid:Create("Frame")({
				Name = "ImageHolder",
				AnchorPoint = anchorPoint,
				Rotation = rotation,
				Position = maid:Lerp(value21, 0.35),
				Size = maid:Lerp(value7, 0.35),
				function(p)
					v17 = p
				end,
				v19
			}),
			maid:Create("Frame")({
				Name = "PinsHolder",
				ZIndex = 2,
				AnchorPoint = anchorPoint,
				Rotation = rotation,
				Position = maid:Lerp(value21, 0.35),
				Size = maid:Lerp(value7, 0.35),
				BackgroundTransparency = 1,
				Regions(maid, {
					Point = mapPoint,
					Rotation = rotation,
					Side = side
				}),
				Bosses(maid, {
					Point = mapPoint,
					Rotation = rotation,
					Side = side
				}),
				Recommended(maid, {
					Point = mapPoint,
					Rotation = rotation,
					Side = side
				}),
				Markers(maid, {
					Point = mapPoint,
					Rotation = rotation,
					Side = side
				}),
				Shrines(maid, {
					Point = mapPoint,
					Rotation = rotation,
					Side = side
				}, {
					Clickable = clickable,
					OnTravel = function()
						setOpen(false)
					end
				}),
				maid:State(function(callback, p)
					local v20 = callback(value26)
					local preview

					if v20 ~= nil then
						preview = v20.Preview
					end

					if preview == nil then
						return
					else
						return Placed(p, {
							Point = mapPoint,
							Rotation = rotation,
							Side = side
						}, {
							Spot = preview,
							Preview = true,
							Clickable = clickable,
							Clicked = function() end
						})
					end
				end),
				maid:State(function(callback, p)
					local spot = callback(value27)

					if spot == nil then
						return
					else
						return Placed(p, {
							Point = mapPoint,
							Rotation = rotation,
							Side = side
						}, {
							Spot = spot,
							Clickable = clickable,
							Clicked = function()
								value27:Set(nil)
							end
						})
					end
				end)
			}),
			maid:Create("Frame")({
				Name = "PointerHolder",
				ZIndex = 3,
				AnchorPoint = anchorPoint,
				Position = maid:Lerp(value21, 0.35),
				Size = maid:Lerp(value7, 0.35),
				BackgroundTransparency = 1,
				maid:Create("ImageLabel")({
					Name = "Player",
					Image = playerArrow,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = position4,
					Size = UDim2.fromOffset(v6, v6),
					Rotation = rotation2,
					BackgroundTransparency = 1
				})
			})
		}),
		maid:Create("ImageLabel")({
			Name = "Overlay",
			ZIndex = 4,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1.15, 1.15),
			BackgroundTransparency = 1,
			Image = image2,
			ImageColor3 = color,
			ImageTransparency = 0.4
		}),
		maid:State(function(callback, object)
			local v20 = callback(value26)

			if v20 == nil or not callback(clickable) then
				return
			else
				return object:Create("Frame")({
					Name = "QuestionStrip",
					ZIndex = 5,
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Question(object, v20)
				})
			end
		end),
		maid:Create("TextButton")({
			Name = "Open",
			ZIndex = 1,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			function(parent)
				local frame = Instance.new("Frame")
				frame.Name = "NoSelection"
				frame.BackgroundTransparency = 1
				frame.Size = UDim2.new()
				frame.Parent = parent
				parent.SelectionImageObject = frame
			end,
			MouseButton1Click = function()
				if clickable.Value then
					local mouseLocation2 = UserInputService:GetMouseLocation()

					if mouseLocation ~= nil and (mouseLocation2 - mouseLocation).Magnitude > 6 or os.clock() - now > 0.1 then
						return
					end

					local preview = spotAt(mouseLocation2)

					if preview == nil then
						return
					end

					value26:Set({
						Text = "Place a marker here?",
						Preview = preview,
						Answer = function(p: string)
							if p == "Yes" then
								value27:Set(preview)
							end

							value26:Set(nil)
						end
					})
				else
					ScreenEffects.CircleClick()
					setOpen(true)
				end
			end,
			MouseButton1Down = function(UI)
				if not clickable.Value then
					return
				end

				mouseLocation = UserInputService:GetMouseLocation()
				now = os.clock()

				if v15.UI == nil then
					v15.UI = UI
				end

				v16 = nil
				updateDrag(v15:Start())
			end,
			InputChanged = function(p, p2)
				if not (clickable.Value and p2.UserInputType == Enum.UserInputType.MouseWheel) then
					return
				end

				local value32 = value9.Value
				local value33 = value21.Value
				value8:Set((math.clamp(value8.Value + p2.Position.Z * 0.03124999999999999, 0, 1)))
				zoomAt(Vector2.new(p2.Position.X, p2.Position.Y), p, value32, value33)
			end
		})
	})
	maid:Create("Frame")({
		Name = "MapControls",
		Parent = instance,
		Visible = instancePropertySync,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		maid:State(function(callback, object)
			if callback(clickable) then
				return object:Create("CanvasGroup")({
					Name = "SidePanel",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = position3,
					Size = size3,
					BackgroundTransparency = 1,
					GroupTransparency = object:Animation(0, info2, {
						From = 1
					}),
					CleanDelay = 0.2,
					CleanFunction = function(object2, p)
						object2:Configure(p)({
							GroupTransparency = object2:Animation(1, info2)
						})
					end,
					object:Create("UIGradient")({
						Rotation = 90,
						Transparency = numberSequence2
					}),
					SidePanel(object, instance)
				})
			end
		end),
		maid:State(function(callback, object)
			if callback(clickable) then
				return object:Create("Frame")({
					Name = "ZoomSlider",
					Position = position,
					Size = size,
					BackgroundTransparency = 1,
					SkillTreeZoomSlider(object, value8)
				})
			end
		end),
		maid:State(function(callback, object)
			local v20 = callback(clickable)
			local v21 = object:Create("Frame")
			local v22 = {
				Name = v20 and "Map_Close" or "Map"
			}
			local anchorPoint2

			if v20 then
				anchorPoint2 = Vector2.new(1, 0)
			else
				anchorPoint2 = Vector2.new(0.5, 0)
			end

			v22.AnchorPoint = anchorPoint2
			local position5

			if v20 then
				position5 = value16
			else
				position5 = value17
			end

			v22.Position = position5
			local size5

			if v20 then
				size5 = value15
			else
				size5 = value14
			end

			v22.Size = size5
			v22.BackgroundTransparency = 1
			v22[1] = function(instance2)
	instance2:SetAttribute("OnlyOn", "Xbox,Playstation")
	instance2:AddTag("UIkey")
end
			return v21(v22)
		end),
		maid:State(function(callback, object)
			if callback(clickable) and callback(value20) then
				return object:Create("ImageLabel")({
					Name = "Recentre",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = position2,
					Size = size2,
					Image = "rbxassetid://85742448064430",
					BackgroundTransparency = 1,
					ImageTransparency = object:Animation(0, info, {
						From = 1
					}),
					CleanDelay = 0.2,
					CleanFunction = function(object2, p)
						object2:Configure(p)({
							ImageTransparency = object2:Animation(1, object2.Info(0.2)),
							Size = object2:Animation(UDim2.fromScale(0, 0), object2.Info(0.2))
						})
					end,
					object:Create("UIScale")({
						Scale = object:Animation(1.18, info3, {
							From = 1
						})
					}),
					object:Create("UIGradient")({
						Rotation = 90,
						Color = colorSequence
					}),
					object:Create("TextButton")({
						Name = "Hitbox",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(2, 2),
						BackgroundTransparency = 1,
						function(parent)
							local frame = Instance.new("Frame")
							frame.Name = "NoSelection"
							frame.BackgroundTransparency = 1
							frame.Size = UDim2.new()
							frame.Parent = parent
							parent.SelectionImageObject = frame
						end,
						MouseButton1Click = function()
							ScreenEffects.CircleClick()
							recentre() -- equivalent call inferred; original call site unknown
						end
					})
				})
			end
		end)
	})
	maid:Create("Frame")({
		Name = "MapBackground",
		Parent = instance,
		Visible = instancePropertySync,
		ZIndex = -1,
		Size = size4,
		Position = position6,
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = maid:Animation(value28, info),
		maid:State(function(callback, object)
			if callback(clickable) then
				return object:Create("TextButton")({
					Name = "CloseCatcher",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					function(parent)
						local frame = Instance.new("Frame")
						frame.Name = "NoSelection"
						frame.BackgroundTransparency = 1
						frame.Size = UDim2.new()
						frame.Parent = parent
						parent.SelectionImageObject = frame
					end,
					MouseButton1Click = function()
						ScreenEffects.CircleClick()
						setOpen(false)
					end
				})
			end
		end),
		maid:Create("BlurEffect")({
			Parent = workspace.CurrentCamera,
			Size = maid:Animation(value29, info)
		})
	})

	if not isRunning and onMobile() then
		setOpen(true)
	end

	return function()
		if localPlayer ~= nil then
			localPlayer:SetAttribute("MapOpened", nil)
		end

		if v11 ~= false then
			v11 = false

			if gamepadCursorEnabledChangedConnection ~= nil then
				gamepadCursorEnabledChangedConnection:Disconnect()
				gamepadCursorEnabledChangedConnection = nil
			end

			if not gamepadCursorEnabled then
				GamepadService:DisableGamepadCursor()
			end
		end

		maid:Destroy()
	end
end