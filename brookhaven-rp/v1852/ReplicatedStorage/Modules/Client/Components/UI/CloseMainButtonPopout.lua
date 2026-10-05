local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local MainButtonPopout = require(ReplicatedStorage.Modules.Client.Components.UI.MainButtonPopout)
local v = Component.new({
	Tag = "CloseMainButtonPopout"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if instance:IsA("GuiButton") then
		self._Janitor:Add(instance.Activated:Connect(function()
			MainButtonPopout.Close()
		end))
	else
		warn("CloseMainButtonPopout: instance is not a GuiButton")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v