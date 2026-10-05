local GamepadService = game:GetService("GamepadService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local ActivePanels = require(ReplicatedStorage.Modules.Client.UI.ActivePanels)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local ConsoleControls = require(ReplicatedStorage.Modules.Client.Input.ConsoleControls)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local v = Component.new({
	Tag = "SelectionGroup",
	Extensions = { ConsoleControlsConstructGate }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	instance.SelectionGroup = true
	instance.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
	instance.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
	instance.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
	instance.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible then
			self:onPanelVisible()
		else
			ActivePanels.Remove(self.Instance)
		end
	end))
end

function v:onPanelVisible()
	local v2, v3 = ABTest.GetExperimentVariable("console-controls", "dpadNavigation"):timeout(7):await()

	if (not v2 or v3) and not ConsoleControls.isUsingCustomNavigation then
		if not GamepadService.GamepadCursorEnabled then
			GamepadService:EnableGamepadCursor(self.Instance)
		end
	else
		Platform.Select(self.Instance)
	end

	ActivePanels.Push(self.Instance)
end

function v:Stop()
	self._Janitor:Destroy()
	ActivePanels.Remove(self.Instance)
end

return v