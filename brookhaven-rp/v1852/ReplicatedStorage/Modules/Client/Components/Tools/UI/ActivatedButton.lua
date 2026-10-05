local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ActivatedButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._heldInputObject = nil
end

function v:Start()
	local value = self.Instance:FindFirstAncestorOfClass("ScreenGui"):WaitForChild("ToolReference").Value

	if not value then
		warn("ActivatedButton:Start() - ToolReference has no Value")
		return
	end

	local component = self.Instance:GetAttribute("Component")
	local waitForComponent = ComponentUtil.FindAndWaitForComponentByTag(value, component, false)

	if not waitForComponent then
		warn("ActivatedButton:Start() - Component class not found:", component)
		return
	end

	local component2 = ComponentUtil.GetComponentFromInstance(value, waitForComponent, 10)
	local buttonName = self.Instance:GetAttribute("ButtonName")

	if not component2 then
		return
	end

	if not component2.ActivatedButton then
		warn("ActivatedButton:Start() - Component does not have an ActivatedButton method")
		return
	end

	self._Janitor:Add(self.Instance.InputBegan:Connect(function(heldInputObject)
		if heldInputObject.UserInputType == Enum.UserInputType.Touch and heldInputObject.UserInputState == Enum.UserInputState.Begin then
			component2.ActivatedButton(component2, buttonName, "Begin", heldInputObject)
			self._heldInputObject = heldInputObject
		end
	end))
	self._Janitor:Add(self.Instance.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.End then
			component2.ActivatedButton(component2, buttonName, "End", input)
			self._heldInputObject = nil
		end
	end))
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		component2.ActivatedButton(component2, buttonName, "Activated", nil)
	end))
	self._Janitor:Add(UserInputService.TouchEnded:Connect(function(otherPart)
		if self._heldInputObject == otherPart then
			component2.ActivatedButton(component2, buttonName, "End", otherPart)
			self._heldInputObject = nil
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v