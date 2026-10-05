local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseSignTextBox"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local _1RPHous1eEven1t = ReplicatedStorage.RE:WaitForChild("1RPHous1eEven1t")

	if _1RPHous1eEven1t then
		self._Janitor:Add(instance.FocusLost:Connect(function()
			_1RPHous1eEven1t:FireServer("BusinessName", instance.Text)
		end))
	else
		warn("RPHouseEvent not found")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v