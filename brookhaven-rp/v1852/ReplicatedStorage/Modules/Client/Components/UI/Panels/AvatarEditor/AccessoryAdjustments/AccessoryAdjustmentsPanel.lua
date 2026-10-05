local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)
local AccessoryAdjustmentsSoundManager = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsSoundManager)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local v = Component.new({
	Tag = "AccessoryAdjustmentsPanel"
})
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local v2 = nil
local v3 = false

function v:_notifyGamepad()
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input)
		if UserInputService.GamepadEnabled and input.UserInputType == Enum.UserInputType.Gamepad1 then
			if not (v3 ~= true and self.Instance.Visible ~= false) then
				return
			end

			v3 = true
			NotificationController.NotifyEditor(
				"Press and Hold A and move with D-PAD to adjust sliders",
				5,
				nil,
				"accessoryAdjustmentsConsoleControls"
			)
		end
	end))
end

function v:_setupSoundManager()
	local sounds = self.Instance:FindFirstChild("Sounds")

	if sounds == nil then
		warn("AccessoryAdjustmentsPanel: Sounds folder not found")
		return
	end

	self._soundManager = ComponentUtil.GetComponentFromInstance(sounds, AccessoryAdjustmentsSoundManager)

	if self._soundManager == nil then
		warn("AccessoryAdjustmentsPanel: Sound manager not found")
	end
end

function v:_setupSideButtons()
	local mainView = self.container:WaitForChild("MainView")

	if mainView == nil then
		warn("AvatarEditorAccessoryAdjustments: MainView not found")
		return
	end

	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		local avatarEditorSearch = self.Instance.Parent:FindFirstChild("AvatarEditorSearch")

		if avatarEditorSearch == nil then
			return
		end

		if self.Instance.Visible then
			NotificationController.AcknowledgeWarning("accessoryAdjustmentsNew")
		end

		avatarEditorSearch.Visible = not self.Instance.Visible
	end))
	self.views = {}
	local sideButtons = self.container:WaitForChild("SideButtons")

	for _, button in sideButtons:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local child = mainView:FindFirstChild(button.Name)

		if child ~= nil then
			self.views[button.Name] = child
		end

		local v4 = button
		button.Activated:Connect(function()
			for i, button2 in sideButtons:GetChildren() do
				if button2:IsA("ImageButton") == true then
					button2.Icon.GreenCheckMark.Visible = false
				end
			end

			v4.Icon.GreenCheckMark.Visible = true

			if v2 == nil or v2.Visible ~= true then
				for k, view in self.views do
					view.Visible = false
				end
			else
				v2.Visible = false
			end

			v2 = child

			if v2 == nil then
				warn("AvatarEditorAccessoryAdjustments: Current view not found")
			else
				v2.Visible = true
			end
		end)
	end
end

function v:PlaySound(p2: string, p3: number)
	if self._soundManager == nil then
		warn("AccessoryAdjustmentsPanel: Sound manager not found")
	else
		self._soundManager:PlaySound(p2, p3)
	end
end

function v:PlaySoundDragPreview(p2: string, p3: number)
	if self._soundManager == nil then
		warn("AccessoryAdjustmentsPanel: Sound manager not found")
	else
		self._soundManager:PlaySoundDragPreview(p2, p3)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnViewChanged = Signal.new()
	self._wasVisible = false
end

function v:Start()
	self.container = self.Instance:FindFirstChild("Container")
	self:_setupSideButtons()
	self:_setupSoundManager()
	self._wasVisible = self.Instance.Visible
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = self.Instance.Visible
		self.OnViewChanged:Fire(visible)

		if self._wasVisible == true and visible == false then
			WearingController.FlushAccessoryAdjustmentsTelemetry()
		end

		self._wasVisible = visible

		if not visible then
			task.delay(0.3, function()
				local character = Players.LocalPlayer.Character

				if character == nil then
					return
				end

				local humanoid = character:FindFirstChild("Humanoid")

				if humanoid == nil then
					return
				end

				local accessories = humanoid:GetAccessories()

				for _, accessory in accessories do
					if not accessory:IsA("Accessory") then
						continue
					end

					local accessoryWeld = accessory:FindFirstChild("AccessoryWeld", true)

					if accessoryWeld then
						accessoryWeld.Enabled = true
					end
				end
			end)
		end
	end))
	self:_notifyGamepad()
end

function v:Stop()
	if self._wasVisible == true then
		WearingController.FlushAccessoryAdjustmentsTelemetry()
	end

	if AccessoryAdjustmentsState.IsAccessoryAdjustmentsPanelOpen() == true then
		CameraController.SetAvatarEditorCamera(false)
	end

	AccessoryAdjustmentsState.SetAccessoryAdjustmentsPanelOpen(false)
	self._Janitor:Destroy()
end

return v