local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardDeleteButton"
})
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local props = nil

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	props = ReplicatedStorage.RE:WaitForChild("Props")
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	self._Janitor:Add(instance.Activated:Connect(function()
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable then
			currentSelectedPropEditable:Deselect("Delete")
			props:FireServer("DeleteProp")
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v