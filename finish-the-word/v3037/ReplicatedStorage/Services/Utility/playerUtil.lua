local Players = game:GetService("Players")
return {
	toPlayers = function(options, list)
		local v = options or {}
		local playerByUserIds = {}
		local v2 = {}

		if list then
			if list[1] == nil then
				v2 = list
			else
				for _, v3 in ipairs(list) do
					v2[v3] = true
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addIfPresent(p)
			if v2[p] then
				return
			end

			local playerByUserId = Players:GetPlayerByUserId(p)

			if playerByUserId then
				playerByUserIds[#playerByUserIds + 1] = playerByUserId
			end
		end

		if v[1] == nil then
			for k in pairs(v) do
				addIfPresent(k) -- equivalent call inferred; original call site unknown
			end
		else
			for _, v3 in ipairs(v) do
				addIfPresent(v3) -- equivalent call inferred; original call site unknown
			end
		end

		return playerByUserIds
	end
}