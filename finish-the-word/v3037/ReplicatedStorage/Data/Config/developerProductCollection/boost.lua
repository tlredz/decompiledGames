local v = {
	["1hr"] = 3600,
	["1day"] = 86400,
	["1wk"] = 604800
}
local Boost = {}

for k, v2 in pairs({
	p3601531474 = { "WinBoost", "1hr" },
	p3601531475 = { "WinBoost", "1day" },
	p3601531472 = { "WinBoost", "1wk" },
	p3601532138 = { "StreakBoost", "1hr" },
	p3601532137 = { "StreakBoost", "1day" },
	p3601532136 = { "StreakBoost", "1wk" },
	p3601532792 = { "CashBoost", "1hr" },
	p3601532791 = { "CashBoost", "1day" },
	p3601532790 = { "CashBoost", "1wk" },
	p3601533195 = { "XpBoost", "1hr" },
	p3601533196 = { "XpBoost", "1day" },
	p3601533191 = { "XpBoost", "1wk" }
}) do
	local v5 = v2[1]
	local v6 = v2[2]
	Boost[k] = {
		Server = function(p, p2, object, p3)
			object:auto_repl(true)
			object:timeProcess(v5, v[v6], false, true)
			object:auto_repl(false)
			return true
		end
	}
end

return Boost