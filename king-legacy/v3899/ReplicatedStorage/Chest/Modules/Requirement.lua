local RunService = game:GetService("RunService")

function GetStatistic()
	if RunService:IsClient() then
		return _G.GetStatisticClient
	end

	if RunService:IsServer() then
		return _G.GetStatistic
	end
end

return {
	Lnwza007 = {
		X = function(p)
			local v = GetStatistic()

			if not v then
				return
			end

			if v(p, "FirstSeaDungeon") < 1 then
				return
			else
				return true
			end
		end,
		C = function(p)
			local v = GetStatistic()

			if not v then
				return
			end

			if v(p, "FirstSeaDungeon") < 1 then
				return
			else
				return true
			end
		end,
		V = function(p)
			local v = GetStatistic()

			if not v then
				return
			end

			if v(p, "FirstSeaDungeon") < 1 then
				return
			else
				return true
			end
		end,
		E = function(p)
			local v = GetStatistic()

			if not v then
				return
			end

			if v(p, "FirstSeaDungeon") < 1 then
				return
			else
				return true
			end
		end
	}
}