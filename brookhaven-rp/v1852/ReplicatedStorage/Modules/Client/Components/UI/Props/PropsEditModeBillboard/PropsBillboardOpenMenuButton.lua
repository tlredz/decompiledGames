local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardOpenMenuButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	local parent = self.Instance.Parent
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local value = self.Instance.Target.Value
		parent.Visible = false
		value.Visible = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v