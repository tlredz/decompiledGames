local import = _G.import("class")
local import2 = _G.import("seasonCollection")
local v = import.new()

function v:resetMonthly()
	self.MonthlyData = {
		Wins = 0,
		Streak = 0,
		HighestStreak = 0,
		CashEarned = 0
	}
end

function v:monthlyReset(p)
	self:auto_repl(p or false)
	self:resetMonthly()
	self:auto_repl(false)
end

function v:scheduleMonthlyReset()
	if self:hasTimedProcess("MonthlyReset") then
		return
	end

	self:timeProcess("MonthlyReset", import2:getSeasonTimeRemaining(), true)
end

function v:new()
	self:resetMonthly()
end

function v:postShell()
	self:scheduleMonthlyReset()
end

return v