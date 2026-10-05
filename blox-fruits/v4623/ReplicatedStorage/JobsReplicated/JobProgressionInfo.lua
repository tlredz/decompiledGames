local JobsEXP = require(script.Parent.JobsEXP)
local JobProgressionInfo = {
	Jobs = {}
}
JobProgressionInfo.Jobs.Fishing = {
	Stats = {
		{
			Name = "Control",
			Cap = 13000,
			Max = 13000,
			BaseGain = 10,
			SealRequirement = true,
			Effect = {
				Min = 0,
				Max = 1
			},
			SealBoost = 0.15
		},
		{
			Name = "Casting",
			Cap = 12000,
			Max = 12000,
			BaseGain = 10,
			SealRequirement = true,
			Effect = {
				Min = 0,
				Max = 0.06
			},
			SealBoost = 0.15
		},
		{
			Name = "Bait",
			Cap = 15000,
			Max = 15000,
			BaseGain = 10,
			SealRequirement = true,
			Effect = {
				Min = 0,
				Max = 0.15
			},
			SealBoost = 0.15
		}
	},
	MaxLevel = 100,
	JobSealId = "Angler's Seal",
	JobColor = Color3.new(0.388235, 0.623529, 1)
}

for _, job in JobProgressionInfo.Jobs do
	job.StatLookup = {}

	for k, v in job.Stats or {} do
		job.StatLookup[v.Name] = k
	end

	job.PassiveLookup = {}

	for k, v in job.Passives or {} do
		job.PassiveLookup[v.Name] = k
	end

	if job.MaxLevel then
		job.MaxExp = JobsEXP:getExpForLevel(job.MaxLevel)
	end
end

function JobProgressionInfo.GetStatInfo(p: string, p2: string)
	local job = JobProgressionInfo.Jobs[p]
	return job.Stats[job.StatLookup[p2]]
end

function JobProgressionInfo.CanEquipSeal(p: string, p2)
	local stats = p2.Stats

	for k, stat in JobProgressionInfo.Jobs[p].Stats do
		if not (stat.SealRequirement and (not stats[k] or stats[k] < stat.Max)) then
			continue
		end

		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGamePrint("Lacking required stat?", k, stats[k])
		return false
	end

	return true
end

return JobProgressionInfo