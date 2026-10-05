local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "HouseUIColorPicker"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local component = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	local _1RPHous1eEven1tColo1r = ReplicatedStorage.RE:WaitForChild("1RPHous1eEven1tColo1r")
	self._Janitor:Add(component.OnColorConfirmed:Connect(function(p2)
		_1RPHous1eEven1tColo1r:FireServer("PickingBusinessNameColor", p2)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v