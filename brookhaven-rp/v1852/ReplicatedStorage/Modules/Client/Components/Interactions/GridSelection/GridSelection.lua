local ContextActionService = game:GetService("ContextActionService")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local ProximityPromptShared = require(ReplicatedStorage.Modules.Client.Interactables.ProximityPromptShared)
local GamepassController = require(ReplicatedStorage.Modules.Client.UI.Gamepass.GamepassController)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ActivePanels = require(ReplicatedStorage.Modules.Client.UI.ActivePanels)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local GridSelectionUI = require(script.Parent.GridSelectionUI)
local v = Component.new({
	Tag = "GridSelection"
})
local v2 = nil
local v3 = Enum.ContextActionPriority.High.Value + 10

local function getClickScreenPosition(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local function isClickOnOption(gui, point: Vector2)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui == nil then
		return false
	end

	for _, button in playerGui:GetGuiObjectsAtPosition(point.X, point.Y) do
		if not button:IsDescendantOf(gui) then
			continue
		end

		if button:IsA("GuiButton") then
			return true
		end

		local name = button.Name

		if (name == "ItemDisplay" or name == "ToolIcon" or name == "GamepassIcon" or name == "ItemWrapper") and (button.Name ~= "ItemWrapper" or button.Visible == true) then
			return true
		end
	end

	return false
end

local function getRequiredGamepass(instance)
	local gamepass = instance:FindFirstChild("Gamepass")

	if gamepass == nil or not gamepass:IsA("NumberValue") or gamepass.Value <= 0 then
		return nil
	end

	local value = gamepass.Value

	if Gamepasses.Exists(value) then
		return Gamepasses.GetById(value)
	end

	warn("GridSelection: unknown Gamepass id", value, "on", instance:GetFullName())
	return nil
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._openJanitor = Janitor.new()
	self._Janitor:Add(self._openJanitor)
	self.OptionSelected = self._Janitor:Add(Signal.new())
	self._isOpen = false
	self._optionsFolder = nil
	self._previousHideInteractionUI = nil
end

function v._CanSelectOption(_, _) end

function v.IsAnyOpen()
	return v2 ~= nil and v2._isOpen == true
end

function v:Close()
	local _isOpen = self._isOpen
	self._openJanitor:Cleanup()
	self._isOpen = false

	if v2 == self then
		v2 = nil
	end

	if _isOpen then
		self.Instance:SetAttribute("HideInteractionUI", self._previousHideInteractionUI)
		self._previousHideInteractionUI = nil
	end
end

function v:Open()
	if self._isOpen then
		return
	end

	local _optionsFolder = self._optionsFolder

	if _optionsFolder == nil then
		return
	end

	if v2 ~= nil and v2 ~= self then
		v2:Close()
	end

	local v4 = GridSelectionUI.Create(self.Instance, _optionsFolder, function(instance)
		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeAfterClick()
			task.defer(function()
				self:Close()
			end)
		end

		local requiredGamepass = getRequiredGamepass(instance)
		local name = instance.Name

		if requiredGamepass == nil or UnlockableController.IsFeatureUnlocked(name, requiredGamepass) then
			self.OptionSelected:Fire(instance)
			Remotes.fireServerComponent(self.Instance, "SelectOption", instance.Name)
			closeAfterClick() -- equivalent call inferred; original call site unknown
		else
			local telemetrySource = self.Instance:GetAttribute("TelemetrySource")
			local v5 = (typeof(telemetrySource) ~= "string" or string.len(telemetrySource) == 0) and "Grid Selection" or telemetrySource
			local icon = GridSelectionUI.ResolveIcon(name, instance)
			GamepassController.Show(requiredGamepass, icon, "GridSelection", nil, {
				id = name,
				icon = icon
			}, nil, v5, name, function()
				if self.Instance.Parent == nil or instance.Parent ~= _optionsFolder then
					return
				end

				self.OptionSelected:Fire(instance)
				Remotes.fireServerComponent(self.Instance, "SelectOption", instance.Name)
			end)
			closeAfterClick() -- equivalent call inferred; original call site unknown
		end
	end)
	self._openJanitor:Add(function()
		v4:Destroy()
	end)
	self._previousHideInteractionUI = self.Instance:GetAttribute("HideInteractionUI") == true or nil
	self.Instance:SetAttribute("HideInteractionUI", true)
	self._isOpen = true
	v2 = self
	local container = v4.Gui:FindFirstChild("Container")

	if container ~= nil and container:IsA("GuiObject") then
		ActivePanels.Push(container)
		self._openJanitor:Add(function()
			ActivePanels.Remove(container)
		end)
	end

	if Platform.IsConsole() then
		ContextActionService:BindActionAtPriority("GridSelectionSinkButtonX", function()
			return Enum.ContextActionResult.Sink
		end, false, v3, Enum.KeyCode.ButtonX)
		self._openJanitor:Add(function()
			ContextActionService:UnbindAction("GridSelectionSinkButtonX")
		end)
		self._openJanitor:Add(BackActionRouter.Bind(function()
			self:Close()
		end, function()
			return self._isOpen
		end))
	end

	local v5 = 0
	self._openJanitor:Add(RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if now - v5 < 0.1 then
			return
		end

		v5 = now
		local character = Players.LocalPlayer.Character

		if character == nil then
			self:Close()
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
			self:Close()
			return
		end

		local targetPosition = ProximityPromptShared.getTargetPosition(self.Instance)

		if targetPosition == nil then
			self:Close()
		elseif ProximityPromptShared.getInteractDistance(self.Instance) < (humanoidRootPart.Position - targetPosition).Magnitude then
			self:Close()
		end
	end))
	task.defer(function()
		if not self._isOpen then
			return
		end

		self._openJanitor:Add(UserInputService.InputBegan:Connect(function(input, _)
			if not self._isOpen then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if isClickOnOption(v4.Gui, getClickScreenPosition(input)) then
					return
				end

				self:Close()
			elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonA and GamepadService.GamepadCursorEnabled then
				local selectedObject = GuiService.SelectedObject

				if selectedObject == nil or not selectedObject:IsDescendantOf(v4.Gui) then
					self:Close()
				end
			end
		end))
	end)
end

function v:Toggle()
	if self.Instance:GetAttribute("GridSelectionDisabled") == true then
		return
	end

	if self._isOpen then
		self:Close()
	else
		self:Open()
	end
end

function v:Start()
	local options = self.Instance:WaitForChild("Options", 10)

	if options == nil or not options:IsA("Folder") then
		warn("GridSelection: Options folder not found for", self.Instance:GetFullName())
		return
	end

	self._optionsFolder = options
	local expect = InteractionPrompt:WaitForInstance(self.Instance):expect()
	self._Janitor:Add(expect.Interacted:Connect(function()
		self:Toggle()
	end))
end

function v:Stop()
	self:Close()
	self._Janitor:Destroy()
end

return v