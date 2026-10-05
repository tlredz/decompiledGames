local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "UIColorPicker"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function getConsoleControlsEnabled()
	local v2, v3 = ABTest.GetExperimentVariable("console-controls", "enabled"):timeout(7):await()
	return not v2 or v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clampPalettePosition(point: Vector2)
	return Vector2.new(math.clamp(point.X, 0, 1), (math.clamp(point.Y, 0, 1)))
end

local function clampPaletteColorPosition(point: Vector2)
	local v2 = point - Vector2.new(0.5, 0.5)

	if v2.Magnitude > 0.5 then
		v2 = v2.Unit * 0.5
	end

	return Vector2.new(0.5, 0.5) + v2
end

local function isSelectedOrDescendant(instance, ancestor)
	return instance ~= nil and (instance == ancestor or instance:IsDescendantOf(ancestor))
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._InputJanitor = Janitor.new()
	self.OnColorPicked = Signal.new()
	self.OnColorConfirmed = Signal.new()
	self.OnColorPanelRequestClose = Signal.new()
	self._Janitor:Add(self.OnColorPicked)
	self._Janitor:Add(self.OnColorConfirmed)
	self._Janitor:Add(self.OnColorPanelRequestClose)
	local colorPicksFrame = self.Instance:WaitForChild("ColorPicks"):WaitForChild("ColorPicksFrame")
	self.finalColorButton = colorPicksFrame:WaitForChild("FinalColorButton")
	self.palettePicker = colorPicksFrame:WaitForChild("PalettePicker")
	self.blocker = colorPicksFrame:WaitForChild("Blocker")
	self.blocker.Selectable = false
	self.darknessBar = colorPicksFrame:WaitForChild("DarknessBar")
	self.gradient = self.darknessBar:WaitForChild("UIGradient")
	self.palettePicker.SelectionOrder = -100
	self.darknessBar.SelectionOrder = -99
	self.finalColorButton.SelectionOrder = -98
	self.darknessBar.ClipsDescendants = false
	self.palettePicker.ClipsDescendants = false
	self.closeButton = colorPicksFrame:WaitForChild("Background"):WaitForChild("Close")
	self.hue = 0
	self.saturation = 0
	self.value = 1
	self._consoleControlsEnabled = true
	self._consoleThumbstick = Vector2.zero
	self._consoleDragMode = nil
	self._isConsoleDragModeEnabled = false
	self._paletteMarker = nil
	self._darknessMarker = nil
	self._palettePosition = Vector2.new(0.5, 0.5)
	self._darknessPosition = 0
	self._isUpdatingColorInternally = false
	self._consoleDragSelectionTarget = nil
	self._isStopped = false
	self._consoleMovementBlocked = false
end

function v:_isConsoleThumbstickPickerEnabled()
	return self._consoleControlsEnabled and Platform.IsConsole()
end

function v:_isConsoleVirtualCursorEnabled()
	return Platform.IsConsole() and GamepadService.GamepadCursorEnabled
end

function v:_setConsoleMovementBlocked(consoleMovementBlocked: boolean)
	if self._consoleMovementBlocked == consoleMovementBlocked then
		return
	end

	self._consoleMovementBlocked = consoleMovementBlocked

	if consoleMovementBlocked then
		ContextActionService:BindActionAtPriority("UIColorPickerBlockMove", function()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value + 100, Enum.KeyCode.Thumbstick1)
	else
		ContextActionService:UnbindAction("UIColorPickerBlockMove")
	end
end

function v:_updateIndicatorPositions(flag: boolean?)
	if flag ~= true then
		local v2 = math.clamp(self.saturation, 0, 1)
		local v3 = self.hue * 3.141592653589793 * 2
		local v4 = 3.141592653589793 - v3
		local v5 = v2 * 0.5
		local v6 = math.cos(v4) * v5 + 0.5
		local v7 = math.sin(v4) * v5 + 0.5
		self._palettePosition = Vector2.new(v6, v7)
	end

	local darknessPosition = math.clamp(1 - self.value, 0, 1)
	self._darknessPosition = darknessPosition

	if self._paletteMarker then
		self._paletteMarker.Position = UDim2.fromScale(self._palettePosition.X, self._palettePosition.Y)
	end

	if self._darknessMarker then
		self._darknessMarker.Position = UDim2.fromScale(0.5, darknessPosition)
	end
end

function v:_syncHSVFromCurrentColor()
	local HSV, saturation, v3 = self.finalColorButton.BackgroundColor3:ToHSV()
	self.hue = HSV
	self.saturation = saturation
	self.value = v3
	self.gradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(self.hue, self.saturation, 1))
	self:_updateIndicatorPositions()
end

function v:_applyCurrentColor(flag: boolean?)
	local color = Color3.fromHSV(self.hue, self.saturation, self.value)
	self._isUpdatingColorInternally = true
	self.finalColorButton.BackgroundColor3 = color
	self._isUpdatingColorInternally = false
	self.gradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(self.hue, self.saturation, 1))
	self:_updateIndicatorPositions(flag)
end

function v:_setPalettePosition(p: number, p2: number)
	local palettePosition = clampPalettePosition(Vector2.new(p, p2)) -- equivalent call inferred; original call site unknown
	local v3 = palettePosition - Vector2.new(0.5, 0.5)

	if v3.Magnitude > 0.5 then
		v3 = v3.Unit * 0.5
	end

	local v4 = Vector2.new(0.5, 0.5) + v3
	local v5 = v4.X - 0.5
	local v6 = v4.Y - 0.5
	local v7 = math.sqrt(v5 * v5 + v6 * v6)
	local v8 = math.atan2(v6, v5)
	local hue = (3.141592653589793 - v8) / 6.283185307179586
	self._palettePosition = palettePosition
	self.hue = hue
	self.saturation = math.clamp(v7 * 2, 0, 1)
	self:_applyCurrentColor(true)
end

function v:_setDarknessPosition(value: number)
	self.value = 1 - math.clamp(value, 0, 1)
	self:_applyCurrentColor(true)
end

function v:_createPaletteMarker()
	if self._paletteMarker then
		return
	end

	local imageButton = Instance.new("ImageButton")
	imageButton.Name = "ConsolePaletteMarker"
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.BackgroundColor3 = Color3.new(1, 1, 1)
	imageButton.BackgroundTransparency = 0
	imageButton.BorderSizePixel = 0
	imageButton.AutoButtonColor = false
	imageButton.ImageTransparency = 1
	imageButton.Size = UDim2.fromOffset(12, 12)
	imageButton.ZIndex = self.palettePicker.ZIndex + 2
	imageButton.SelectionOrder = self.palettePicker.SelectionOrder
	imageButton.Active = true
	imageButton.Selectable = true
	imageButton.NextSelectionDown = self.Instance
	imageButton.NextSelectionRight = self.Instance.Parent:FindFirstChild("FinalColorButton")
	imageButton.NextSelectionUp = self.Instance.Parent:FindFirstChild("DarknessBar")
	imageButton.Parent = self.palettePicker
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = imageButton
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 1
	uIStroke.Parent = imageButton
	self._paletteMarker = imageButton
end

function v:_createDarknessMarker()
	if self._darknessMarker then
		return
	end

	local imageButton = Instance.new("ImageButton")
	imageButton.Name = "ConsoleDarknessMarker"
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imageButton.BackgroundColor3 = Color3.new(1, 1, 1)
	imageButton.BackgroundTransparency = 0
	imageButton.BorderSizePixel = 0
	imageButton.AutoButtonColor = false
	imageButton.ImageTransparency = 1
	imageButton.Size = UDim2.new(1, 0, 0, 8)
	imageButton.ZIndex = self.darknessBar.ZIndex + 2
	imageButton.SelectionOrder = self.darknessBar.SelectionOrder
	imageButton.Active = true
	imageButton.Selectable = true
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Thickness = 1
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = imageButton
	uIStroke.Parent = imageButton
	imageButton.Parent = self.darknessBar
	self._darknessMarker = imageButton
end

function v:_destroyConsoleMarkers()
	if self._paletteMarker then
		self._paletteMarker:Destroy()
		self._paletteMarker = nil
	end

	if self._darknessMarker then
		self._darknessMarker:Destroy()
		self._darknessMarker = nil
	end
end

function v:_startConsoleDrag(consoleDragMode: string)
	if not self._isConsoleDragModeEnabled then
		return
	end

	local consoleDragSelectionTarget

	if consoleDragMode == "Palette" then
		consoleDragSelectionTarget = self._paletteMarker or self.palettePicker
	else
		consoleDragSelectionTarget = self._darknessMarker or self.darknessBar
	end

	self._consoleDragSelectionTarget = consoleDragSelectionTarget
	Platform.Select(nil)
	self:_setConsoleMovementBlocked(true)
	self._consoleDragMode = consoleDragMode
end

function v:_setConsoleNavigationTargets()
	local _isConsoleDragModeEnabled = self._isConsoleDragModeEnabled
	self.palettePicker.Selectable = not _isConsoleDragModeEnabled
	self.darknessBar.Selectable = not _isConsoleDragModeEnabled

	if self._paletteMarker then
		self._paletteMarker.Selectable = _isConsoleDragModeEnabled
	end

	if self._darknessMarker then
		self._darknessMarker.Selectable = _isConsoleDragModeEnabled
	end
end

function v:_stopConsoleDrag(flag: boolean)
	if not self._consoleDragMode then
		return
	end

	local _consoleDragSelectionTarget = self._consoleDragSelectionTarget
	self._consoleDragMode = nil
	self._consoleDragSelectionTarget = nil
	self:_setConsoleMovementBlocked(false)

	if flag then
		self.OnColorPicked:Fire(self.finalColorButton.BackgroundColor3)
	end

	if self:_isConsoleThumbstickPickerEnabled() and _consoleDragSelectionTarget and _consoleDragSelectionTarget.Parent then
		task.defer(function()
			if not self:_isConsoleThumbstickPickerEnabled() then
				return
			end

			GuiService.SelectedObject = _consoleDragSelectionTarget

			if GuiService.SelectedObject == _consoleDragSelectionTarget then
				return
			end

			local parent = _consoleDragSelectionTarget.Parent

			if parent and parent:IsA("GuiObject") then
				Platform.Select(parent)
			end
		end)
	end
end

function v:_refreshConsoleDragMode()
	local isConsoleDragModeEnabled = self:_isConsoleThumbstickPickerEnabled() and not self:_isConsoleVirtualCursorEnabled()

	if isConsoleDragModeEnabled == self._isConsoleDragModeEnabled then
		if isConsoleDragModeEnabled then
			self:_updateIndicatorPositions()
		end
	else
		self._isConsoleDragModeEnabled = isConsoleDragModeEnabled

		if isConsoleDragModeEnabled then
			self:_createPaletteMarker()
			self:_createDarknessMarker()
			self._darknessMarker.NextSelectionLeft = self.palettePicker
			self._paletteMarker.NextSelectionRight = self.darknessBar
			self:_setConsoleNavigationTargets()
			self:_syncHSVFromCurrentColor()
		else
			self:_stopConsoleDrag(false)
			self:_setConsoleNavigationTargets()
			self:_destroyConsoleMarkers()
		end
	end
end

function v:_refreshConsoleThumbstickState()
	self._consoleThumbstick = Vector2.zero
	local success, result = pcall(function()
		return UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)
	end)

	if not (success and result) then
		return
	end

	for _, v2 in result do
		if v2.KeyCode ~= Enum.KeyCode.Thumbstick1 then
			continue
		end

		self._consoleThumbstick = Vector2.new(v2.Position.X, v2.Position.Y)
		break
	end
end

function v:_updateConsoleDrag(p: number)
	if not self._consoleDragMode then
		return
	end

	local _consoleThumbstick = self._consoleThumbstick

	if math.abs(_consoleThumbstick.X) < 0.1 and math.abs(_consoleThumbstick.Y) < 0.1 then
		return
	end

	if self._consoleDragMode == "Palette" then
		local v3 = clampPalettePosition(self._palettePosition + Vector2.new(_consoleThumbstick.X, -_consoleThumbstick.Y) * 0.9 * p) -- equivalent call inferred; original call site unknown
		self:_setPalettePosition(v3.X, v3.Y)
	elseif self._consoleDragMode == "Darkness" then
		self:_setDarknessPosition(self._darknessPosition - _consoleThumbstick.Y * 1.05 * p)
	end
end

function v:Start()
	self._isStopped = false
	self._consoleControlsEnabled = true
	self:_syncHSVFromCurrentColor()
	self:_refreshConsoleThumbstickState()
	self:_refreshConsoleDragMode()
	task.defer(function()
		while not ABTest._initialized do
			task.wait(0.1)
		end

		if self._isStopped then
			return
		end

		self._consoleControlsEnabled = getConsoleControlsEnabled()
		self:_refreshConsoleDragMode()
	end)
	self._Janitor:Add(self.OnColorConfirmed:Connect(function(p, p2)
		Remotes.fireServerComponent(self.Instance, "SetColor", p, p2)
	end))
	self._Janitor:Add(self.closeButton.Activated:Connect(function()
		self.OnColorPanelRequestClose:Fire()
	end))
	self._Janitor:Add(self.finalColorButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		if self._isUpdatingColorInternally then
			return
		end

		self:_syncHSVFromCurrentColor()
	end))

	if UserInputService.GamepadEnabled then
		self._Janitor:Add(self.palettePicker.InputBegan:Connect(function(input)
			if self._isConsoleDragModeEnabled then
				return
			end

			local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

			for _, v2 in gamepadState do
				if v2.KeyCode == Enum.KeyCode.ButtonA and v2.UserInputState == Enum.UserInputState.Begin then
					self:_setPalettePosition(
						(input.Position.X - self.palettePicker.AbsolutePosition.X) / self.palettePicker.AbsoluteSize.X,
						(input.Position.Y - self.palettePicker.AbsolutePosition.Y) / self.palettePicker.AbsoluteSize.Y
					)
				elseif v2.KeyCode == Enum.KeyCode.ButtonB and v2.UserInputState == Enum.UserInputState.End then
					self.OnColorPicked:Fire(self.finalColorButton.BackgroundColor3)
				end
			end
		end))
	end

	if UserInputService.GamepadEnabled then
		self._Janitor:Add(self.darknessBar.InputBegan:Connect(function(input)
			if self._isConsoleDragModeEnabled then
				return
			end

			local gamepadState = UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

			for _, v2 in gamepadState do
				if v2.KeyCode == Enum.KeyCode.ButtonA and v2.UserInputState == Enum.UserInputState.Begin then
					self:_setDarknessPosition((math.clamp(
						(input.Position.Y - self.darknessBar.AbsolutePosition.Y) / self.darknessBar.AbsoluteSize.Y,
						0,
						1
					)))
				elseif v2.KeyCode == Enum.KeyCode.ButtonB and v2.UserInputState == Enum.UserInputState.End then
					self.OnColorPicked:Fire(self.finalColorButton.BackgroundColor3)
				end
			end
		end))
	end

	self._Janitor:Add(self.palettePicker.MouseButton1Down:Connect(function(p: number, p2: number)
		self:_setPalettePosition(
			(p - self.palettePicker.AbsolutePosition.X) / self.palettePicker.AbsoluteSize.X,
			(p2 - self.palettePicker.AbsolutePosition.Y) / self.palettePicker.AbsoluteSize.Y
		)
		self._InputJanitor:Add(UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:_setPalettePosition(
				(input.Position.X - self.palettePicker.AbsolutePosition.X) / self.palettePicker.AbsoluteSize.X,
				(input.Position.Y - self.palettePicker.AbsolutePosition.Y) / self.palettePicker.AbsoluteSize.Y
			)
		end))
		self._InputJanitor:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self._InputJanitor:Cleanup()
			self.OnColorPicked:Fire(self.finalColorButton.BackgroundColor3)
		end))
	end))
	self._Janitor:Add(self.darknessBar.MouseButton1Down:Connect(function()
		self._InputJanitor:Add(UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self:_setDarknessPosition((math.clamp(
				(input.Position.Y - self.darknessBar.AbsolutePosition.Y) / self.darknessBar.AbsoluteSize.Y,
				0,
				1
			)))
		end))
		self._InputJanitor:Add(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			self._InputJanitor:Cleanup()
			self.OnColorPicked:Fire(self.finalColorButton.BackgroundColor3)
		end))
	end))
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			self._consoleThumbstick = Vector2.new(input.Position.X, input.Position.Y)
			return
		end

		if not (input.KeyCode == Enum.KeyCode.ButtonA and self._isConsoleDragModeEnabled) then
			return
		end

		local selectedObject = GuiService.SelectedObject
		local palettePicker = self.palettePicker
		local v2

		if selectedObject == nil then
			v2 = false
		else
			v2 = selectedObject == palettePicker or selectedObject:IsDescendantOf(palettePicker)
		end

		if v2 then
			self:_startConsoleDrag("Palette")
			return
		end

		local darknessBar = self.darknessBar
		local v3

		if selectedObject == nil then
			v3 = false
		else
			v3 = selectedObject == darknessBar or selectedObject:IsDescendantOf(darknessBar)
		end

		if v3 then
			self:_startConsoleDrag("Darkness")
		end
	end))
	self._Janitor:Add(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			self._consoleThumbstick = Vector2.new(input.Position.X, input.Position.Y)
		end
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return
		end

		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			self._consoleThumbstick = Vector2.zero
		elseif input.KeyCode == Enum.KeyCode.ButtonA then
			self:_stopConsoleDrag(true)
		end
	end))
	self._Janitor:Add(UserInputService.GamepadDisconnected:Connect(function(p)
		if p ~= Enum.UserInputType.Gamepad1 then
			return
		end

		self._consoleThumbstick = Vector2.zero
		self:_stopConsoleDrag(false)
	end))
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:_refreshConsoleDragMode()
	end))
	self._Janitor:Add(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
		self:_refreshConsoleDragMode()
	end))
	self._Janitor:Add(RunService.RenderStepped:Connect(function(dt)
		if not self._isConsoleDragModeEnabled then
			return
		end

		self:_updateConsoleDrag(dt)
	end))
	self._Janitor:Add(self.finalColorButton.MouseButton1Click:Connect(function()
		if self.isDebouncing then
			return
		end

		self.isDebouncing = true
		self.OnColorConfirmed:Fire(self.finalColorButton.BackgroundColor3, false)
		task.wait(0.2)
		self.isDebouncing = false
	end))
end

function v:Stop()
	self._isStopped = true
	self:_setConsoleMovementBlocked(false)
	self:_destroyConsoleMarkers()
	self._Janitor:Destroy()
	self._InputJanitor:Destroy()
end

return v