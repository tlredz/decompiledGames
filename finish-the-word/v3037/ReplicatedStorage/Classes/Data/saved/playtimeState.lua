local import = _G.import("class")
game:GetService("MarketplaceService")
local v = import.new()

function v:new()
	self.Playtime = 0
	self.SessionTime = 0
	self.LastLoginDay = 0
	self.LoginStreak = 1
	self.StreakClaim = {}
end

function v:postShell()
	self.Playtime += self.SessionTime
	self.SessionTime = 0
	local lastLoginDay = self.LastLoginDay
	self.LastLoginDay = math.floor(os.time() / 86400)
	local v2 = self.LastLoginDay - lastLoginDay

	if v2 > 1 then
		self.LoginStreak = 1
		self.StreakClaim = {}
	elseif v2 == 1 then
		self.LoginStreak = math.min(self.LoginStreak + 1, 7)
	end
end

return v