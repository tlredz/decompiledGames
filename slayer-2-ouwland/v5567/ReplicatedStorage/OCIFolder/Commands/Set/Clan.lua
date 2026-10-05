local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clans = require(ReplicatedStorage.CAM:WaitForChild("Clans"))
local SkillTreeholder = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(items, p: string)
	if p == nil then
		return
	end

	if p ~= "None" and Clans.GetClan(p) == nil then
		warn((`Set/Clan: no clan named "{p}"`))
		return
	end

	if Clans.TestClans[p] ~= nil then
		warn((`Set/Clan: "{p}" is granted by the testclan command, not here`))
		return
	end

	for _, item in items do
		local clan = Utility.GetData(item, true):FindFirstChild("Clan")

		if clan == nil then
			continue
		end

		SkillTreeholder.TransferBranch(item, clan.Value, p)
		clan.Value = p
	end
end