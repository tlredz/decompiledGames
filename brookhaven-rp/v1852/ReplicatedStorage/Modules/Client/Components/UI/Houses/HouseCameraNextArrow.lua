local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseCameraNextArrow"
})
local HouseCameraView = require(ReplicatedStorage.Modules.Client.Components.UI.Houses.HouseCameraView)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.houseCameraView = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"HouseCameraView",
		HouseCameraView
	)

	if not self.houseCameraView then
		return
	end

	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		local increment = self.Instance:GetAttribute("Increment")
		self.houseCameraView:NextCamera((tonumber(increment)))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v