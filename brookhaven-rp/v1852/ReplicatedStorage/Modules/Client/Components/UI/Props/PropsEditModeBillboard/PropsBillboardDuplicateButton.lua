local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardDuplicateButton"
})
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	self._Janitor:Add(instance.Activated:Connect(function()
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable then
			currentSelectedPropEditable:Duplicate()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v