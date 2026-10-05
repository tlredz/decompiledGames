local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TopBarPlus = require(ReplicatedStorage.Packages.TopBarPlus)
return {
	Start = function()
		local v = TopBarPlus.new()
		v:setName("Settings"):setImage(101403250204482):modifyTheme({ "IconImage", "ScaleType", Enum.ScaleType.Fit }):setImageScale(0.8)

		local function toggleUI()
			local Audio = require(ReplicatedStorage.Shared.Audio)
			local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
			local Tabs = require(ReplicatedStorage.Client.Tabs)
			Audio.Play(Constants.BUTTON_FX.BUTTON_MOUSE_DOWN_SOUND, script, {
				PlaybackSpeed = math.random(95, 105) / 100,
				Volume = 1.8
			})
			Tabs.Toggle("Settings")
		end

		v:bindEvent("toggled", toggleUI)
		local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
		local GUI = require(ReplicatedStorage.Client.GUI)
		local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
		local Preferences = require(ReplicatedStorage.Shared.Preferences)
		local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
		local TreadmillVideoGate = require(ReplicatedStorage.Client.TreadmillVideoGate)
		local AudioSettingsController = require(ReplicatedStorage.Controllers.Game.AudioSettingsController)
		local uDim = UDim2.fromScale(0.75, 0.5)
		local uDim2 = UDim2.fromScale(0.25, 0.5)
		local colorSequence = ColorSequence.new(Color3.fromRGB(212, 255, 0), Color3.fromRGB(0, 255, 8))
		local colorSequence2 = ColorSequence.new(Color3.fromRGB(255, 58, 61), Color3.fromRGB(255, 2, 6))
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateIconEnabled()
			v:setEnabled(not HiddenUIHandler.IsHidden())
		end

		HiddenUIHandler.Changed:Connect(updateIconEnabled)
		updateIconEnabled() -- equivalent call inferred; original call site unknown
		local scrollingFrame = GUI.Settings().Frame.ScrollingFrame
		assert(scrollingFrame:IsA("ScrollingFrame"), "Settings scrolling frame must be a ScrollingFrame")
		local v2 = {}
		local v3 = {}

		local function displayedState(p, flag: boolean)
			local isOn = Preferences.IsOn(p)

			if flag then
				return not isOn
			end

			return isOn
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyToggleVisuals(data, isOn: boolean, flag: boolean?)
			data.Status.Text = isOn and "ON" or "OFF"
			local knobGradient = data.KnobGradient
			local color

			if isOn then
				color = colorSequence
			else
				color = colorSequence2
			end

			knobGradient.Color = color
			local position

			if isOn then
				position = uDim
			else
				position = uDim2
			end

			if flag then
				data.Knob.Position = position
			else
				TweenService:Create(data.Knob, tweenInfo, {
					Position = position
				}):Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshToggle(p)
			local v5 = v3[p]

			if v5 then
				local inverted = v5.Inverted
				local isOn = Preferences.IsOn(p)

				if inverted then
					isOn = not isOn
				end

				applyToggleVisuals(v5, isOn)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function attemptToggle(p)
			if v2[p] then
				return
			end

			v2[p] = true
			local v5 = Preferences.Toggle(p)
			v2[p] = nil
			local v6 = not v5 and v3[p]

			if v6 then
				local inverted = v6.Inverted
				local isOn = Preferences.IsOn(p)

				if inverted then
					isOn = not isOn
				end

				applyToggleVisuals(v6, isOn)
			end
		end

		local function registerToggleRow(childName, inverted: boolean)
			local guiObject = scrollingFrame:FindFirstChild(childName)

			if not (guiObject and guiObject:IsA("GuiObject")) then
				return
			end

			local controlBar = guiObject:FindFirstChild("ControlBar")
			local btn

			if controlBar then
				btn = controlBar:FindFirstChild("Btn")
			end

			local description = guiObject:FindFirstChild("Description")

			if not (btn and btn:IsA("ImageButton") and description and description:IsA("TextLabel")) then
				return
			end

			local uIGradient = btn:FindFirstChildOfClass("UIGradient")

			if not uIGradient then
				return
			end

			local v5 = {
				Row = guiObject,
				Knob = btn,
				KnobGradient = uIGradient,
				Status = description,
				Inverted = inverted
			}
			v3[childName] = v5
			ButtonFX(btn, nil, function()
				attemptToggle(childName) -- equivalent call inferred; original call site unknown
			end)
			local isOn = Preferences.IsOn(childName)

			if inverted then
				isOn = not isOn
			end

			applyToggleVisuals(v5, isOn, true) -- equivalent call inferred; original call site unknown
		end

		local function applySliderVisuals(data, p: number)
			data.Fill.Size = UDim2.new(p, 0, 1, 0)
			data.Fill.Position = UDim2.new(p / 2, 0, 0.5, 0)
			data.Stick.Position = UDim2.new(p, 0, 0.4887853, 0)
			data.Handle.Position = data.Stick.Position
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function settleSliderBoolean(p, p2: number)
			local v5 = p2 > 0

			if Preferences.IsOn(p) ~= v5 then
				attemptToggle(p) -- equivalent call inferred; original call site unknown
			end
		end

		local function registerSliderRow(childName, category)
			local guiObject = scrollingFrame:FindFirstChild(childName)

			if not (guiObject and guiObject:IsA("GuiObject")) then
				return
			end

			local controlBar = guiObject:FindFirstChild("ControlBar")
			local fill

			if controlBar then
				fill = controlBar:FindFirstChild("Fill")
			end

			local stick

			if controlBar then
				stick = controlBar:FindFirstChild("Stick")
			end

			if not (controlBar and controlBar:IsA("GuiObject") and fill and fill:IsA("Frame") and stick and stick:IsA("Frame")) then
				return
			end

			local textButton = Instance.new("TextButton")
			textButton.Name = "VolumeDragHandle"
			textButton.Text = ""
			textButton.BackgroundTransparency = 1
			textButton.AnchorPoint = stick.AnchorPoint
			textButton.Size = stick.Size
			textButton.ZIndex = stick.ZIndex + 1
			textButton.Active = true
			textButton.Selectable = true
			textButton.Parent = controlBar
			local v5 = {
				Row = guiObject,
				Bar = controlBar,
				Fill = fill,
				Stick = stick,
				Handle = textButton,
				Category = category
			}
			local v6 = false
			local uIDragDetector = Instance.new("UIDragDetector")
			uIDragDetector.Name = "VolumeDragDetector"
			uIDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine
			uIDragDetector.DragAxis = Vector2.new(1, 0)
			uIDragDetector.ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale
			uIDragDetector.BoundingUI = controlBar
			uIDragDetector.BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.HitPoint
			uIDragDetector.SelectionModeDragSpeed = UDim2.fromScale(0.15, 0)
			uIDragDetector.Parent = textButton
			uIDragDetector.DragStart:Connect(function()
				v6 = true
			end)
			textButton:GetPropertyChangedSignal("Position"):Connect(function()
				if not v6 then
					return
				end

				local v7 = math.clamp(
					textButton.Position.X.Scale + textButton.Position.X.Offset / math.max(controlBar.AbsoluteSize.X, 1),
					0,
					1
				)
				applySliderVisuals(v5, v7)
				AudioSettingsController.Set(category, v7)
			end)
			uIDragDetector.DragEnd:Connect(function()
				v6 = false
				settleSliderBoolean(childName, AudioSettingsController.Get(category)) -- equivalent call inferred; original call site unknown
			end)
			local frame = Instance.new("Frame")
			frame.Name = "VolumeTrackInput"
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.fromScale(1, 1)
			frame.ZIndex = math.max(fill.ZIndex, stick.ZIndex) + 1
			frame.Active = true
			frame.Selectable = false
			frame.Parent = controlBar
			textButton.ZIndex = frame.ZIndex + 1
			local v7 = nil
			local position = createVector(0, 0, 0)
			local v8 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setFromPointer(position2: Vector3)
				local v9 = math.clamp(
					(position2.X - controlBar.AbsolutePosition.X) / math.max(controlBar.AbsoluteSize.X, 1),
					0,
					1
				)
				applySliderVisuals(v5, v9)
				AudioSettingsController.Set(category, v9)
			end

			frame.InputBegan:Connect(function(input)
				if v7 or v6 or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				v7 = input
				position = input.Position
				v8 = false

				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setFromPointer(input.Position) -- equivalent call inferred; original call site unknown
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				local v9 = v7

				if not v9 then
					return
				end

				if v9.UserInputType == Enum.UserInputType.MouseButton1 then
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						setFromPointer(input.Position) -- equivalent call inferred; original call site unknown
					end
				elseif input == v9 then
					if not v8 then
						local v10 = input.Position - position

						if v10.Magnitude < 8 then
							return
						end

						if math.abs(v10.Y) >= math.abs(v10.X) then
							v7 = nil
							return
						else
							v8 = true
						end
					end

					setFromPointer(input.Position) -- equivalent call inferred; original call site unknown
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input ~= v7 then
					return
				end

				v7 = nil

				if input.UserInputState == Enum.UserInputState.Cancel then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch then
					setFromPointer(input.Position) -- equivalent call inferred; original call site unknown
				end

				settleSliderBoolean(childName, AudioSettingsController.Get(category)) -- equivalent call inferred; original call site unknown
			end)
			Preferences.Observe(childName, function(flag: boolean)
				if v6 or v7 then
					return
				end

				if not flag then
					applySliderVisuals(v5, 0)
					return
				end

				if AudioSettingsController.Get(category) == 0 then
					AudioSettingsController.Set(category, 1)
				end

				applySliderVisuals(v5, AudioSettingsController.Get(category))
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyCreatorSettingVisibility()
			local creatorPanel = scrollingFrame:FindFirstChild("CreatorPanel")

			if creatorPanel and creatorPanel:IsA("GuiObject") then
				creatorPanel.Visible = Players.LocalPlayer:GetAttribute("CreatorPanelAccess") == true
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyVideoSettingVisibility()
			local disableVideos = scrollingFrame:FindFirstChild("DisableVideos")

			if disableVideos and disableVideos:IsA("GuiObject") then
				disableVideos.Visible = not TreadmillVideoGate.IsVideoPlayerDisabled()
			end
		end

		local function registerNavigationRow()
			local menuNavigation = scrollingFrame:WaitForChild("MenuNavigation")
			local buttons = menuNavigation:WaitForChild("Buttons")
			local cursor = menuNavigation:WaitForChild("Cursor")

			local function refresh()
				menuNavigation.Visible = UserInputService.GamepadEnabled
				local prefersCursor = MenuNavigation.PrefersCursor()

				for _, v5 in { buttons, cursor } do
					local v6 = v5 == cursor == prefersCursor
					local backgroundColor

					if v6 then
						backgroundColor = Color3.fromRGB(112, 255, 24)
					else
						backgroundColor = Color3.fromRGB(68, 68, 86)
					end

					v5.BackgroundColor3 = backgroundColor
					local caption = v5:FindFirstChild("Caption")
					caption.Text = v5.Name .. (v6 and " (Selected)" or "")
				end
			end

			ButtonFX(buttons, nil, function()
				MenuNavigation.SetPreference(false)
			end)
			ButtonFX(cursor, nil, function()
				MenuNavigation.SetPreference(true)
			end)
			MenuNavigation.Changed:Connect(refresh)
			UserInputService.GamepadConnected:Connect(refresh)
			UserInputService.GamepadDisconnected:Connect(refresh)
			refresh()
		end

		;({
			Init = function()
				registerNavigationRow()
				registerSliderRow("Music", "Music")
				registerSliderRow("SFX", "SFX")
				registerToggleRow("HideOtherPets", true)
				registerToggleRow("HideSelfPets", true)
				registerToggleRow("DisableVideos", true)
				registerToggleRow("CreatorPanel", false)

				for _, v5 in {
					"HideOtherPets",
					"HideSelfPets",
					"DisableVideos",
					"CreatorPanel"
				} do
					local v6 = v5
					Preferences.Observe(v5, function()
						refreshToggle(v6) -- equivalent call inferred; original call site unknown
					end)
				end

				TreadmillVideoGate.Changed:Connect(applyVideoSettingVisibility)
				applyVideoSettingVisibility() -- equivalent call inferred; original call site unknown
				Players.LocalPlayer:GetAttributeChangedSignal("CreatorPanelAccess"):Connect(applyCreatorSettingVisibility)
				applyCreatorSettingVisibility() -- equivalent call inferred; original call site unknown
			end
		}).Init()
	end
}