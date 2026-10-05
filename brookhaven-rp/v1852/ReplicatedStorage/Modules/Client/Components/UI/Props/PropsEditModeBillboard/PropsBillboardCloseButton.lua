local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardCloseButton"
})
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)

local function onButtonActivated()
	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

	if currentSelectedPropEditable then
		currentSelectedPropEditable:Deselect()
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(onButtonActivated))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v