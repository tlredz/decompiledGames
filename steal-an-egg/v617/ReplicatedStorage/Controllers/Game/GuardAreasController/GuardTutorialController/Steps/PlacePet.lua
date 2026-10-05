local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local StepUtils = require(script.Parent.Parent.StepUtils)
local color = Color3.fromRGB(255, 255, 255)
local PlacePet = {
	StepId = "PlacePet",
	IsSatisfied = function(object)
		return object:HasPlacedPet()
	end
}

function PlacePet.Bind(p, callback)
	return StepUtils.BindOnAdapterChanged(p, PlacePet.IsSatisfied, callback)
end

function PlacePet.Present(object, object2)
	local function refreshPresentation()
		if PlacePet.IsSatisfied(object2) or not object2:HasPetInInventory() then
			object:DropEverything()
			return
		end

		object:AnnounceTyped("Place your Pet!", color)
		object:SetScreenClickHint(object2:HasPetToolEquipped())
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)
	refreshPresentation()
	return function()
		changedConnection:Disconnect()
		object:DropEverything()
	end
end

return PlacePet