local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local ProfileFlagController = require(ReplicatedStorage.Modules.Client.PlayerData.ProfileFlagController)
local NewUserDataController = require(ReplicatedStorage.Modules.Client.Util.NewUserDataController)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local BreadcrumbConfig = require(ReplicatedStorage.Modules.Shared.DB.Breadcrumbs.BreadcrumbConfig)
local ProfileFlags = require(ReplicatedStorage.Modules.Shared.PlayerData.ProfileFlags)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local uDim = UDim2.new(0, 0, 0, 0)
local uDim2 = UDim2.fromScale(0.7, 0)
local newFlag = ReplicatedStorage.UiClone.NewFlag
local v = Component.new({
	Tag = "MainButtonPopout"
})

function v.Close()
	for _, v2 in v:GetAll() do
		v2:setState(false)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._isOpen = false
	self._animJanitor = Janitor.new()
	self._isPulsing = false
	self._pulseTime = 0
	self._restPosition = nil
	self._pulseArrow = nil
	self._indicator = nil
end

function v:IsOpen()
	return self._isOpen
end

local function validateSecondsAttribute(instance, p: string, startsOpenExpiresAt)
	if startsOpenExpiresAt == nil then
		return nil
	end

	if typeof(startsOpenExpiresAt) ~= "number" then
		warn((`MainButtonPopout on {instance:GetFullName()}: attribute "{p}" must be a number, got {typeof(startsOpenExpiresAt)}`))
		return nil
	end

	if startsOpenExpiresAt > 32503680000 then
		warn((`MainButtonPopout on {instance:GetFullName()}: attribute "{p}" value {startsOpenExpiresAt} looks like milliseconds; expected Unix seconds`))
		return nil
	else
		return startsOpenExpiresAt
	end
end

function v:_resolveStartsOpenFlag()
	local startsOpenFlag = self.Instance:GetAttribute("StartsOpenFlag")

	if startsOpenFlag == nil or startsOpenFlag == "" then
		return nil
	end

	if typeof(startsOpenFlag) ~= "string" then
		warn((`MainButtonPopout on {self.Instance:GetFullName()}: invalid "StartsOpenFlag" attribute`))
		return nil
	end

	local v2 = ProfileFlags.GetByKey(startsOpenFlag)

	if v2 ~= nil then
		return v2
	end

	warn((`MainButtonPopout on {self.Instance:GetFullName()}: unknown ProfileFlag key "{startsOpenFlag}"`))
	return nil
end

function v:_shouldStartOpen()
	local v2 = validateSecondsAttribute(
		self.Instance,
		"StartsOpenExpiresAt",
		self.Instance:GetAttribute("StartsOpenExpiresAt")
	)

	if v2 ~= nil and v2 <= os.time() then
		return false
	end

	local _resolveStartsOpenFlag = self:_resolveStartsOpenFlag()

	if _resolveStartsOpenFlag ~= nil and ProfileFlagController.IsCompleted(_resolveStartsOpenFlag) then
		return false
	end

	if self.Instance:GetAttribute("StartsOpenForReturningUsers") == true then
		return not NewUserDataController.IsFirstSession()
	end

	return false
end

function v:_offsetStarterInstructions()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local mainGUIHandler = playerGui and playerGui:WaitForChild("MainGUIHandler", 10)
	local starterInstructions = mainGUIHandler and mainGUIHandler:WaitForChild("StarterInstructions", 10)
	local new = starterInstructions and starterInstructions:WaitForChild("New", 10)
	local rightSide = new and new:WaitForChild("RightSide", 10)

	if rightSide ~= nil then
		rightSide.Position = uDim2
	end
end

function v:_startPulse()
	local arrow = self.Instance:FindFirstChild("Arrow")

	if arrow == nil then
		return
	end

	local clone = newFlag:Clone()
	clone.Parent = arrow
	self._Janitor:Add(clone)
	self._indicator = clone
	self._pulseArrow = arrow
	self._restPosition = arrow.Position
	self._pulseTime = 0
	self._isPulsing = true
end

function v:_stopPulse()
	if self._isPulsing ~= true then
		return
	end

	self._isPulsing = false
	local _restPosition = self._restPosition
	local _pulseArrow = self._pulseArrow

	if _restPosition ~= nil and _pulseArrow ~= nil then
		_pulseArrow.Position = _restPosition
	end

	self._pulseArrow = nil
	local _indicator = self._indicator
	self._indicator = nil

	if _indicator ~= nil then
		_indicator:Destroy()
	end
end

function v:_completePulse()
	if self._isPulsing ~= true then
		return
	end

	Remotes.fireServer("MarkBreadcrumbsAsViewed", {
		MainButtonPopout = true
	})
	self:_stopPulse()
end

function v:_tryStartPulse()
	if NewUserDataController.IsFirstSession() or not BreadcrumbConfig.ContainsItem("MainButtonPopout") then
		return
	end

	self._Janitor:AddPromise(ReplicatedDataController.GetClientReplicaPromise():andThen(function(object2)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePulse()
			local breadcrumbs = object2.Data.breadcrumbs

			if breadcrumbs ~= nil and breadcrumbs.MainButtonPopout == true then
				self:_stopPulse()
			elseif self._isPulsing ~= true then
				self:_startPulse()
			end
		end

		updatePulse() -- equivalent call inferred; original call site unknown
		self._Janitor:Add(object2:OnChange(function(p: string, list)
			if list[1] ~= "breadcrumbs" or p ~= "Set" and p ~= "SetValues" then
				return
			end

			updatePulse() -- equivalent call inferred; original call site unknown
		end), "Disconnect")
	end))
end

function v:RenderSteppedUpdate(p)
	if self._isPulsing ~= true then
		return
	end

	self._pulseTime += p
	local v2 = 0

	if self._pulseTime >= 3 then
		while self._pulseTime >= 3 do
			self._pulseTime -= 3
		end
	elseif self._pulseTime >= 2.9 then
		v2 = 1 - TweenService:GetValue(
			(self._pulseTime - 2.9) / 0.1,
			Enum.EasingStyle.Circular,
			Enum.EasingDirection.Out
		)
	elseif self._pulseTime >= 2.7 then
		v2 = TweenService:GetValue((self._pulseTime - 2.7) / 0.2, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut) * 2 - 1
	elseif self._pulseTime >= 2.6 then
		v2 = -TweenService:GetValue((self._pulseTime - 2.6) / 0.1, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
	end

	local _pulseArrow = self._pulseArrow
	local _restPosition = self._restPosition

	if _pulseArrow == nil or _restPosition == nil then
		return
	end

	_pulseArrow.Position = _restPosition + UDim2.fromScale(v2 * 0.1, 0)
end

function v:setState(isOpen: boolean)
	if self._isOpen == isOpen then
		return
	end

	self._isOpen = isOpen

	if isOpen then
		PanelController.ToggleGroup("RightSide", false)
		PanelController.ToggleGroup("MainButtonPopoutBlocking", false)
	elseif #PanelController.GetOpenPanelsByGroup("RightSide") == 0 then
		PanelController.ToggleGroup("MainButtonPopoutBlocking", true)
	end

	local closedPosition

	if isOpen then
		closedPosition = uDim
	else
		closedPosition = self.closedPosition
	end

	self._animJanitor:Cleanup()
	local instance = self.Instance
	local parent = instance.Parent
	local arrow = instance:WaitForChild("Arrow")
	self._animJanitor:Add(task.delay(0.15, function()
		arrow.Image = isOpen and "rbxassetid://124451590044086" or "rbxassetid://122880277432053"
	end))
	local tween = TweenService:Create(parent, tweenInfo, {
		Position = closedPosition
	})
	self._animJanitor:Add(tween, "Cancel")
	tween:Play()
end

function v:Start()
	local instance = self.Instance
	local parent = instance.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		warn("MainButtonPopout: parent is not a GuiObject")
		return
	end

	local buttons = parent:WaitForChild("Buttons")
	local slide = parent:WaitForChild("Slide")

	local function collectSortedButtons(instance2)
		local buttons2 = {}

		for _, button in instance2:GetChildren() do
			if button:IsA("GuiButton") then
				table.insert(buttons2, button)
			end
		end

		table.sort(buttons2, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		return buttons2
	end

	local v2 = collectSortedButtons(buttons)
	local v3 = collectSortedButtons(slide)
	local inputSink = parent.Parent.Parent:WaitForChild("InputSink")
	self.closedPosition = parent.Position
	self._Janitor:Add(instance.Activated:Connect(function()
		self:_completePulse()
		self:setState(not self._isOpen)
	end))

	for k, v4 in v2 do
		local v5 = math.min(k, #v3)
		local v6 = Janitor.new()
		self._Janitor:Add(v6, "Destroy")
		local v7 = v4
		local maid = v6
		self._Janitor:Add(v4.SelectionGained:Connect(function()
			task.delay(0, function()
				if GuiService.SelectedObject ~= v7 then
					return
				end

				maid:Add(UserInputService.InputBegan:Connect(function(input)
					if input.KeyCode ~= Enum.KeyCode.DPadRight then
						return
					end

					self:_completePulse()
					self:setState(true)
					task.delay(0, function()
						GuiService.SelectedObject = v3[v5]
					end)
					local character = Players.LocalPlayer.Character
					local humanoid

					if character == nil then
						humanoid = false
					else
						humanoid = character:FindFirstChild("Humanoid")
					end

					local seatPart

					if humanoid == nil then
						seatPart = false
					else
						seatPart = humanoid.SeatPart
					end

					local inVehicle

					if seatPart == nil then
						inVehicle = false
					else
						inVehicle = seatPart:HasTag("TrackTimeSpentInVehicleSeat")
					end

					TelemetryController.SendClientInteraction("uiInteraction", {
						buttonName = "PopoutController",
						inVehicle = inVehicle
					})
				end))
			end)
		end))
		self._Janitor:Add(v4.SelectionLost:Connect(function()
			v6:Cleanup()
		end))
	end

	self._Janitor:Add(BackActionRouter.Bind(function()
		self:setState(false)
	end, function()
		return self._isOpen
	end))

	local function isPointInTarget(vector: Vector2)
		for _, v4 in {
			parent.Buttons,
			parent.Slide,
			parent.ArrowButton,
			inputSink
		} do
			local absolutePosition = v4.AbsolutePosition
			local absoluteSize = v4.AbsoluteSize

			if vector.X >= absolutePosition.X and vector.X <= absolutePosition.X + absoluteSize.X and vector.Y >= absolutePosition.Y and vector.Y <= absolutePosition.Y + absoluteSize.Y then
				return true
			end
		end

		return false
	end

	local buttons2 = {}

	for _, button in ipairs(parent:GetDescendants()) do
		if button:IsA("GuiButton") then
			table.insert(buttons2, button)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setButtonsInteractable(interactable: boolean)
		for _, v4 in ipairs(buttons2) do
			v4.Interactable = interactable
		end
	end

	local v4 = nil
	local X = 0
	local v5 = 0
	local flag = false
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, _: boolean)
		if not PanelController.IsOpen("MainGUIHandler", "MainButtons") or v4 ~= nil or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local vector = Vector2.new(input.Position.X, input.Position.Y)

		if not isPointInTarget(vector) then
			return
		end

		v4 = input
		X = vector.X
		v5 = parent.AbsoluteSize.X * 0.2
		flag = false
	end))
	self._Janitor:Add(UserInputService.InputChanged:Connect(function(input)
		if not PanelController.IsOpen("MainGUIHandler", "MainButtons") or (input ~= v4 or flag) then
			return
		end

		local v6 = math.abs(input.Position.X - X)

		if v5 <= v6 then
			flag = true
			setButtonsInteractable(false) -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input)
		if not (PanelController.IsOpen("MainGUIHandler", "MainButtons") and input == v4) then
			return
		end

		local v6 = input.Position.X - X
		v4 = nil

		if flag then
			flag = false
			task.defer(function()
				setButtonsInteractable(true) -- equivalent call inferred; original call site unknown
			end)
		end

		local character = Players.LocalPlayer.Character
		local humanoid

		if character ~= nil then
			humanoid = character:FindFirstChildWhichIsA("Humanoid")
		end

		local seatPart

		if humanoid ~= nil then
			seatPart = humanoid.SeatPart
		end

		local inVehicle

		if seatPart == nil then
			inVehicle = false
		else
			inVehicle = seatPart:HasTag("TrackTimeSpentInVehicleSeat")
		end

		if v6 <= -v5 then
			PanelController.Close("MainGUIHandler", "StarterInstructions")
			TelemetryController.SendClientInteraction("uiInteraction", {
				buttonName = "PopoutSlide",
				inVehicle = inVehicle
			})
			self:_completePulse()
			self:setState(true)
		elseif v5 <= v6 then
			TelemetryController.SendClientInteraction("uiInteraction", {
				buttonName = "PopoutSlide",
				inVehicle = inVehicle
			})
			self:_completePulse()
			self:setState(false)
		end
	end))
	self._Janitor:Add(function()
		setButtonsInteractable(true) -- equivalent call inferred; original call site unknown
	end, true)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://124451590044086"
	ContentProvider:PreloadAsync({ imageLabel })

	if self:_shouldStartOpen() then
		self:setState(true)
		self:_offsetStarterInstructions()
	end

	self:_tryStartPulse()
end

function v:Stop()
	self:_stopPulse()
	self._Janitor:Destroy()
end

return v