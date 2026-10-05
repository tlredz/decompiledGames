local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local DontRunUnderStarterGear = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.DontRunUnderStarterGear)
local v = Component.new({
	Tag = "UIColorSet",
	Extensions = { DontRunUnderStarterGear }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Activated:Connect(function()
		Remotes.fireServerComponent(self.Instance, "ChangeColor", self.Instance:WaitForChild("Color").Value)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v