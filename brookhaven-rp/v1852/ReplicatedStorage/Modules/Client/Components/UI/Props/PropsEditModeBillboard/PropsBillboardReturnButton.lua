local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardReturnButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	self._Janitor:Add(instance.Activated:Connect(function()
		local parent = instance.Parent

		if not parent:IsA("Frame") then
			return
		end

		parent.Visible = false
		local value = instance.ReturnPanel.Value

		if value then
			value.Visible = true
		else
			warn("PropsBillboardReturnButton: No previous frame found")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v