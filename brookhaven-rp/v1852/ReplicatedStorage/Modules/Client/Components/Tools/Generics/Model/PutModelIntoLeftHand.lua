local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local DontRunUnderStarterGear = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.DontRunUnderStarterGear)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local ToolRoot = require(ReplicatedStorage.Modules.Client.Components.Tools.ToolRoot)
local v = Component.new({
	Tag = "PutModelIntoLeftHand",
	Extensions = { DontRunUnderStarterGear }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._Janitor:Add(self._equipJanitor)
end

function v:_SetHidden(flag: boolean)
	local localTransparencyModifier = flag and 1 or 0

	for _, part in self.Instance:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

function v:_OnEquip()
	self._equipJanitor:Cleanup()

	if self.Instance:GetAttribute("ModelWelded") == true then
		return
	end

	self:_SetHidden(true)
	self._equipJanitor:Add(self.Instance:GetAttributeChangedSignal("ModelWelded"):Connect(function()
		if self.Instance:GetAttribute("ModelWelded") == true then
			self:_SetHidden(false)
			self._equipJanitor:Cleanup()
		end
	end))
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "ToolRoot", ToolRoot)

	if waitForAncestorComponent == nil then
		return
	end

	local toolInstance = waitForAncestorComponent:GetToolInstance()
	self._Janitor:Add(toolInstance.Equipped:Connect(function()
		self:_OnEquip()
	end))
	self._Janitor:Add(toolInstance.Unequipped:Connect(function()
		self._equipJanitor:Cleanup()
		self:_SetHidden(false)
	end))

	if toolInstance.Parent ~= nil and Players:GetPlayerFromCharacter(toolInstance.Parent) ~= nil then
		self:_OnEquip()
	end
end

function v:Stop()
	self:_SetHidden(false)
	self._Janitor:Destroy()
end

return v