local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	Uid = t.string,
	Egg = Eggs.SchemaValidation.SerializedSavedEgg
})
local checks = {}
local blanks = {}

for k, v in {
	Egg = {
		check = t.union(t.literal(false), interface),
		blank = false
	},
	Unlocked = {
		check = t.boolean,
		blank = false
	},
	TutorialSeen = {
		check = t.boolean,
		blank = false
	},
	Deposited = {
		check = t.number,
		blank = 0
	},
	LuckBoost = {
		check = t.number,
		blank = 0
	},
	Uses = {
		check = t.number,
		blank = 0
	},
	CostResetAt = {
		check = t.number,
		blank = 0
	},
	TotalMutations = {
		check = t.number,
		blank = 0
	}
} do
	checks[k] = v.check
	blanks[k] = v.blank
end

table.freeze(blanks)
return {
	IncubatorEgg = interface,
	State = t.interface(checks),
	MutateResult = t.interface({
		Uid = t.string,
		Egg = Eggs.SchemaValidation.SerializedSavedEgg,
		Mutation = t.string
	}),
	Blank = function()
		return (table.clone(blanks))
	end
}