local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TowerBoard = require(ReplicatedStorage.CAM.Global.TowerBoard)
local RankedBoard

if RunService:IsServer() then
	RankedBoard = require(ServerStorage.SAM.Utility.RankedBoard)
else
	RankedBoard = nil
end

return {
	Clearance = 7,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = { "End", "Rebuild" }
		},
		{
			Type = "Value",
			Name = "Mode",
			Required = false,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		},
		{
			Type = "Value",
			Name = "Season",
			Required = false,
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Server = function(p, p2: string, p3: string?, p4: string?)
		if workspace:GetAttribute("MinigameKey") ~= "Ouwigahara" then
			error("Ouwigahara: only works on an Ouwigahara minigame server")
		end

		local minigamesPlace = ReplicatedStorage:FindFirstChild("Minigames Place")
		local minigames

		if minigamesPlace ~= nil then
			minigames = minigamesPlace:FindFirstChild("Minigames") or nil
		end

		local ouwigahara

		if minigames ~= nil then
			ouwigahara = minigames:FindFirstChild("Ouwigahara") or nil
		end

		if ouwigahara == nil then
			error("Ouwigahara: no Ouwigahara minigame module in this place")
		end

		local v = string.lower((tostring(p2)))

		if v == "end" then
			local Run = require(ouwigahara.Run)

			if not Run.End((`The run was ended by {p.Name}`)) then
				error("Ouwigahara: no run is live")
			end
		elseif v == "rebuild" then
			if p3 == nil or table.find(TowerBoard.Modes(), p3) == nil then
				error((`Ouwigahara: rebuild needs a mode ({table.concat(TowerBoard.Modes(), ", ")})`))
			end

			local v2

			if p4 == nil or p4 == "" then
				v2 = TowerBoard.Season()
			else
				v2 = tonumber(p4)
			end

			if v2 == nil then
				error("Ouwigahara: the season is a number")
			end

			task.spawn(function()
				local rebuild = RankedBoard.Rebuild(p3, v2)
				local v3

				if rebuild == nil then
					v3 = `[Ouwigahara] {p3} season {v2}: rebuild failed, see the warnings`
				else
					v3 = `[Ouwigahara] {p3} season {v2}: histogram rebuilt, population {rebuild}`
				end

				print(v3)
			end)
			return {
				Content = `{p3} season {v2}: rebuilding from the board, the result prints to the server output`,
				BgColor = Color3.fromRGB(32, 143, 70),
				FgColor = Color3.new(1, 1, 1)
			}
		else
			error((`Ouwigahara: unknown action "{v}" (End, Rebuild)`))
		end

		return nil
	end
}