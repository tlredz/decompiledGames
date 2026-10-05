local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HotAirBalloonChangeColorButton"
})
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)

function v:UpdateGreenCheckVisibility(p2)
	local visible = tostring(p2.Instance:GetAttribute("CurrentSkin")) == tostring(self.Instance.Name)
	self.Instance.GreenCheck.Visible = visible
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._index = self.Instance.Name
	self._Janitor:Add(HotAirBalloon.OnTakeControl:Connect(function(object2)
		self:UpdateGreenCheckVisibility(object2)
		self._Janitor:Add(object2.Instance.Collision.Balloon:GetPropertyChangedSignal("MeshId"):Connect(function()
			self:UpdateGreenCheckVisibility(object2)
		end))
		self._connection = self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
			object2:ChangeSkin(self._index)
		end))
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function(_)
		if self._connection then
			self._connection:Disconnect()
			self._connection = nil
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v