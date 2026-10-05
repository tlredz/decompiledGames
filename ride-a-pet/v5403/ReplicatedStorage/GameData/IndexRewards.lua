local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pets = require(script.Parent:WaitForChild("Pets"))
local Main = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("FormatNumber"):WaitForChild("Main"))
local precision = Main.NumberFormatter.with():Notation(Main.Notation.compactWithSuffixThousands({
	"K",
	"M",
	"B",
	"T"
})):Precision(Main.Precision.maxSignificantDigits(3))
local IndexRewards = {
	Stages = {
		{
			Goal = 1,
			Reward = 1000
		},
		{
			Goal = 3,
			Reward = 5000
		},
		{
			Goal = 5,
			Reward = 15000
		},
		{
			Goal = 10,
			Reward = 75000
		},
		{
			Goal = 15,
			Reward = 250000
		},
		{
			Goal = 20,
			Reward = 1000000
		},
		{
			Goal = 24,
			Reward = 50000000
		},
		{
			Goal = 27,
			Reward = 1000000000
		},
		{
			Goal = 30,
			Reward = 30000000000
		},
		{
			Goal = 33,
			Reward = 99000000000
		},
		{
			Goal = 36,
			Reward = 1000000000000
		},
		{
			Goal = 38,
			Reward = 1000000000000000
		}
	}
}

function IndexRewards.Count()
	return #IndexRewards.Stages
end

function IndexRewards.StageAt(p)
	return IndexRewards.Stages[(tonumber(p) or 0) + 1]
end

function IndexRewards.DiscoveredCount(value)
	if type(value) ~= "string" or value == "" then
		return 0
	end

	local count = 0

	for k in Pets do
		if string.find(value, k .. ",", 1, true) then
			count += 1
		end
	end

	return count
end

function IndexRewards.FormatCash(p)
	return "$" .. precision:Format(tonumber(p) or 0)
end

return IndexRewards