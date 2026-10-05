local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local stepIds = {
	TreadmillIntro = "TreadmillIntro",
	ExpandPen = "ExpandPen",
	PlacePet = "PlacePet",
	HatchEgg = "HatchEgg",
	PlaceEgg = "PlaceEgg",
	EquipEgg = "EquipEgg",
	HeadToPen = "HeadToPen",
	StealEgg = "StealEgg"
}
local runGuidanceStates = {
	Inactive = "Inactive",
	ForwardRun = "ForwardRun"
}
local v3 = {
	stepIds.StealEgg,
	stepIds.HeadToPen,
	stepIds.EquipEgg,
	stepIds.PlaceEgg,
	stepIds.HatchEgg,
	stepIds.PlacePet,
	stepIds.ExpandPen,
	stepIds.TreadmillIntro
}
local v4 = { runGuidanceStates.Inactive, runGuidanceStates.ForwardRun }

local function anyOf(list)
	local v5 = table.create(#list)

	for k, v6 in list do
		v5[k] = t.literal(v6)
	end

	return t.union(table.unpack(v5))
end

local stepId = anyOf(v3)
local runGuidanceState = anyOf(v4)
local interface = t.interface({
	Completed = t.boolean,
	CurrentStepId = t.optional(stepId)
})
local v7 = {
	Completed = false,
	CurrentStepId = nil
}
local GuardTutorial = {
	StepIds = stepIds,
	RunGuidanceStates = runGuidanceStates,
	DEFAULT_PROGRESS = v7,
	SchemaValidation = {
		StepId = stepId,
		RunGuidanceState = runGuidanceState,
		Progress = interface,
		ProgressUpdatePayload = interface,
		RuntimeState = t.interface({
			Enabled = t.boolean,
			PausedForAdminAbuse = t.boolean,
			Revision = t.number
		})
	},
	CopyProgress = function(p)
		return {
			Completed = p.Completed == true,
			CurrentStepId = p.CurrentStepId
		}
	end
}

function GuardTutorial.SanitizeProgress(p)
	if p == nil or not interface(p) then
		return GuardTutorial.CopyProgress(v7)
	end

	local copyProgress = GuardTutorial.CopyProgress(p)

	if copyProgress.Completed then
		copyProgress.CurrentStepId = nil
	end

	return copyProgress
end

function GuardTutorial.AcceptsStepId(p: string)
	return stepId(p)
end

function GuardTutorial.AcceptsGuidanceState(p: string)
	return runGuidanceState(p)
end

return GuardTutorial