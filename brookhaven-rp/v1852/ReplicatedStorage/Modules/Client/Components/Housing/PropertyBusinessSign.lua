local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropertyBusinessSign"
})
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)

function v.ToggleVipTextEffect(p, p2: number, p3: number)
	Remotes.fireServerComponent(p.Instance, "PropertyBusinessSign:ToggleVipTextEffect", p2, p3)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.propertyRoot = ComponentUtil.FindAndWaitForAncestorComponent(self.Instance, "PropertyRoot", PropertyRoot)

	if self.propertyRoot == nil then
		return
	end

	self.propertyRoot:SetPropertyBusinessSignComponent(self)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v