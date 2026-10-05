local import = _G.import("class")
_G.import("global")
_G.import("event")
local import2 = _G.import("inventoryState")
local import3 = _G.import("timedState")
local import4 = _G.import("passState")
local import5 = _G.import("playtimeState")
local import6 = _G.import("afkState")
local import7 = _G.import("rankedState")
local import8 = _G.import("monthlyState")
local import9 = _G.import("dailyQuestState")
local import10 = _G.import("battlepassState")
local import11 = _G.import("itemModules")
local import12 = _G.import("dictUtil")
_G.import("signalUtil")
local v = import.new(import2, import3, import4, import5, import7, import8, import9, import10)

function v.player(p)
	return game.Players:GetPlayerByUserId(p.UserId)
end

function v:new(p2, p3)
	self.UserId = p2.UserId
	self._Meta = p3._Meta
	self.Statistics = {
		Cash = 100,
		Wins = 0,
		Streak = 0,
		LastStreak = 0,
		HighestStreak = 0,
		TimeBoost = 2,
		SpecialKey = 0,
		XP = 0
	}
	self.Flags = {
		_Insertable = true
	}
	self.Pity = {
		_Insertable = true
	}
	self.Eggs = {
		Starter = true,
		Expensive = true,
		_Insertable = true
	}
	self.InvitedPlayers = {
		_Insertable = true
	}
	self.RewardListsClaimed = {
		_Insertable = true
	}
	import2.new(self)
	import3.new(self)
	import4.new(self)
	import5.new(self)
	import6.new(self)
	import7.new(self)
	import8.new(self)
	import9.new(self)
	import10.new(self)
	import12.fillDict(self, p3)

	for _, v2 in pairs({ "Inventory", "Equip" }) do
		for k, list in pairs(self[v2]) do
			for _, v3 in pairs(list) do
				local id = v3.Config.Id

				if import11:getItem(k, id) then
					continue
				end

				for k2, v5 in pairs(list) do
					if v5.Config.Id ~= id then
						continue
					end

					table.remove(list, k2)
					break
				end
			end
		end
	end
end

function v.postShell(p)
	import9.postShell(p)
	import5.postShell(p)
	import6.postShell(p)
	import7.postShell(p)
	import8.postShell(p)
end

return v