local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clans = require(ReplicatedStorage.CAM:WaitForChild("Clans"))
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local suggester = {}

for k in Clans.TestClans do
	table.insert(suggester, k)
end

table.sort(suggester)
return {
	Clearance = 6,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Which",
			Name = "Which",
			Required = false,
			Suggester = suggester,
			Completer = function(value: string)
				if value == nil then
					return nil
				end

				for _, v2 in ipairs(suggester) do
					if v2:lower() == value:lower() then
						return v2
					end
				end

				return nil
			end
		}
	},
	Server = function(_, list, TEST_CLAN: string?)
		if TEST_CLAN == nil or Clans.TestClans[TEST_CLAN] == nil or not TEST_CLAN then
			TEST_CLAN = Clans.TEST_CLAN
		end

		for _, v2 in ipairs(list) do
			local clan = Utility.GetData(v2, true):FindFirstChild("Clan")

			if clan ~= nil then
				clan.Value = TEST_CLAN
			end
		end
	end
}