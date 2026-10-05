local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "HideUIOnPlatform"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._platformsToHide = self.Instance:GetAttribute("Platforms"):split(",")
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function(p)
		self:PlatformChanged(p)
	end))
	self:PlatformChanged(Platform.Mode)
end

function v:PlatformChanged(p2)
	self.Instance.Visible = not table.find(self._platformsToHide, p2)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v