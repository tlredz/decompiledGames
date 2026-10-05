local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Clearance = 7,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = {
				"Start",
				"End",
				"Hearts",
				"Timer"
			}
		},
		{
			Type = "Value",
			Name = "Value",
			Required = false,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Server = function(p, p2: string, value: string?)
		if workspace:GetAttribute("MinigameKey") ~= "PvP" then
			error("Pvp: only works on a PvP minigame server")
		end

		local minigamesPlace = ReplicatedStorage:FindFirstChild("Minigames Place")
		local minigames

		if minigamesPlace ~= nil then
			minigames = minigamesPlace:FindFirstChild("Minigames") or nil
		end

		local pvP

		if minigames ~= nil then
			pvP = minigames:FindFirstChild("PvP") or nil
		end

		if pvP == nil then
			error("Pvp: no PvP minigame module in this place")
		end

		local module = require(pvP)
		local v = string.lower((tostring(p2)))

		if v == "start" then
			module.DebugStart()
		elseif v == "end" then
			local v2

			if value ~= nil then
				v2 = string.upper(value) or nil
			end

			if v2 ~= nil and v2 ~= "A" and v2 ~= "B" then
				error((`Pvp: side must be A or B, got "{value}"`))
			end

			module.DebugEnd(v2)
		elseif v == "hearts" then
			local v2 = tonumber(value)

			if v2 == nil then
				error("Pvp: hearts needs a number, e.g. pvp hearts 0")
			end

			module.DebugSetHearts({ p }, (math.floor(v2)))
		else
			if v ~= "timer" then
				error((`Pvp: unknown action "{v}" (Start, End, Hearts, Timer)`))
				return
			end

			local v2 = tonumber(value)

			if v2 == nil or v2 <= 0 then
				error("Pvp: timer needs a positive number of seconds")
			end

			module.DebugTimer(v2)
		end
	end
}