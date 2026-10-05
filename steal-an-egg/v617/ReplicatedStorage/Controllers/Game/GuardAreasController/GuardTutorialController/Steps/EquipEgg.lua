local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local StepUtils = require(script.Parent.Parent.StepUtils)
local EquipEgg = {
	StepId = "EquipEgg",
	IsSatisfied = function(object)
		return object:HasEquippedEgg()
	end
}

function EquipEgg.Bind(p, callback)
	return StepUtils.BindOnAdapterChanged(p, EquipEgg.IsSatisfied, callback)
end

function EquipEgg.Present(object, object2)
	local v = false

	local function refreshPresentation()
		if EquipEgg.IsSatisfied(object2) then
			object:DropEverything()
			return
		end

		if not v then
			v = true

			if object2:ForceBestEggIntoHotbar() == nil then
				v = false
			end
		end

		local eggHotbarTarget = object2:GetEggHotbarTarget()

		if eggHotbarTarget == nil then
			object:DropRing()
		else
			object:RingButton(eggHotbarTarget)
		end
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)
	refreshPresentation()
	return function()
		changedConnection:Disconnect()
		object:DropEverything()
	end
end

return EquipEgg