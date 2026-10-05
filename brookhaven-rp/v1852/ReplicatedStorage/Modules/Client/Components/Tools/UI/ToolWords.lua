local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ToolWords"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.opened = false
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local value = self.Instance:WaitForChild("Gui").Value
		value.Visible = not value.Visible

		if not self.opened then
			self._Janitor:Add(value:WaitForChild("A"):WaitForChild("B"):WaitForChild("C"):WaitForChild("Close").Activated:Connect(function()
				value.Visible = not value.Visible
			end))
			self.opened = true
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v