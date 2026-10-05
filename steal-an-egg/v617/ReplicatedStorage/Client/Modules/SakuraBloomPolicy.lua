local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local v = {
	HasBloomUnlocked = function(flag: boolean, p)
		if not GameFlags.GreatBloomEnabled:Get() then
			return false
		end

		if flag and p ~= nil then
			return p.Sakura.Unlocked == true
		end

		return false
	end
}

function v.CanShowBloom(flag: boolean, flag2: boolean, p)
	return flag and v.HasBloomUnlocked(flag2, p)
end

return table.freeze(v)