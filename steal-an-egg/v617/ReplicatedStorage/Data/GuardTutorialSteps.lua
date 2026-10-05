local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Shared.Types.GuardTutorial)
local frozen = table.freeze({
	"StealEgg",
	"HeadToPen",
	"EquipEgg",
	"PlaceEgg",
	"HatchEgg",
	"PlacePet",
	"ExpandPen",
	"TreadmillIntro"
})
local v = {}

for i, v2 in ipairs(frozen) do
	v[v2] = i
end

table.freeze(v)
local GuardTutorialSteps = {
	GetOrderedStepIds = function()
		return frozen
	end,
	GetFirstStepId = function()
		return frozen[1]
	end,
	GetIndex = function(p)
		return v[p]
	end
}

function GuardTutorialSteps.GetNextStepId(p)
	local index = GuardTutorialSteps.GetIndex(p)

	if index == nil then
		return nil
	end

	return frozen[index + 1]
end

return GuardTutorialSteps