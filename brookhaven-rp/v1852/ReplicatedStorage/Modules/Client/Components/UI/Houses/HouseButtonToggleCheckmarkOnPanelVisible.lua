local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HouseButtonToggleCheckmarkOnPanelVisible"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageLabel") then
		return
	end

	local panel = self.Instance.Parent:FindFirstChild("Panel")

	if not panel then
		print("HouseButtonToggleCheckmarkOnPanelVisible: No panel found: " .. self.Instance:GetFullName())
	elseif panel.Value then
		self._Janitor:Add(panel.Value:GetPropertyChangedSignal("Visible"):Connect(function()
			instance.Visible = panel.Value.Visible
		end))
	else
		print("HouseButtonToggleCheckmarkOnPanelVisible: Panel is not visible: " .. self.Instance:GetFullName())
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v