local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropertyCamera"
})
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.propertyRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "PropertyRoot", PropertyRoot)

	if self.propertyRoot then
		self.propertyRoot:RegisterCamera(self.Instance)
	else
		warn("No property root found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v