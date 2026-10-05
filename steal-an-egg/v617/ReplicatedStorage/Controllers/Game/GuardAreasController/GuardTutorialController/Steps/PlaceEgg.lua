local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Client.GuardTutorialPresentation)
require(script.Parent.Types.Interface)
local StepUtils = require(script.Parent.Parent.StepUtils)
local color = Color3.fromRGB(255, 255, 255)
local PlaceEgg = {
	StepId = "PlaceEgg",
	IsSatisfied = function(object)
		return object:HasPlacedEgg()
	end
}

function PlaceEgg.Bind(p, callback)
	return StepUtils.BindOnAdapterChanged(p, PlaceEgg.IsSatisfied, callback)
end

function PlaceEgg.Present(object, object2)
	local function refreshPresentation()
		if PlaceEgg.IsSatisfied(object2) then
			object:DropEverything()
			return
		end

		object:AnnounceTyped("Place your Egg!", color)
		local eggPlacementBillboardCFrame = object2:GetEggPlacementBillboardCFrame()

		if eggPlacementBillboardCFrame ~= nil then
			object:PinWorldClickHint(eggPlacementBillboardCFrame)
		end
	end

	local changedConnection = object2.Changed:Connect(refreshPresentation)

	if PlaceEgg.IsSatisfied(object2) then
		object:DropEverything()
	else
		object:AnnounceTyped("Place your Egg!", color)
		local eggPlacementBillboardCFrame = object2:GetEggPlacementBillboardCFrame()

		if eggPlacementBillboardCFrame ~= nil then
			object:PinWorldClickHint(eggPlacementBillboardCFrame)
		end
	end

	return function()
		changedConnection:Disconnect()
		object:DropEverything()
	end
end

return PlaceEgg