local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	UserId = t.number,
	Name = t.string,
	ValueText = t.string
})
local array = t.array(interface)
return {
	SchemaValidation = {
		Entry = interface,
		Leaderboard = array,
		LeaderboardsByKey = t.map(t.string, array)
	}
}