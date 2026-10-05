local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local v = {}
RunService.Heartbeat:Connect(function()
	if next(v) then
		local rotation = math.sin(os.clock() * 3.141592653589793 * 2) * 15

		for k, v3 in pairs(v) do
			if v3 then
				k.Rotation = rotation
			end
		end
	end
end)
return Observers.observeTagNoAncestry("UI_WigglyWiggly", function(instance)
	local maid = Utils.Maid.new()
	maid:GiveTask(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		v[instance] = Utils.GuiUtils:IsGuiObjectVisible(instance)
	end))
	v[instance] = Utils.GuiUtils:IsGuiObjectVisible(instance)

	function maid.Remove()
		v[instance] = nil
	end

	return function()
		maid:Destroy()
	end
end)