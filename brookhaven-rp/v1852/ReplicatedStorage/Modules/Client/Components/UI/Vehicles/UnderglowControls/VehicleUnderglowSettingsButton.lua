local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowSettingsButton"
})
local v2 = nil

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		local value = self.Instance.Panel.Value

		if v2 then
			if v2 == value then
				v2.Visible = false
				v2 = nil
				return
			else
				v2.Visible = false
			end
		end

		v2 = value
		value.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v