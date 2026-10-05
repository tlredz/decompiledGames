local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ServerNpcUtil

if RunService:IsServer() then
	ServerNpcUtil = require(ServerStorage.SAM.Services.ServerNpcUtil)
else
	ServerNpcUtil = nil
end

return {
	Clearance = 1,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Config",
			Name = "Config",
			Required = false,
			Suggester = { "Default" },
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Server = function(_, list, p: string?)
		local v = (p == nil or p == "") and "Default" or p

		if type(list) ~= "table" or #list == 0 then
			error("SpawnNpc: no valid players targeted")
		end

		local tempNpcs = ServerStorage.SAM:FindFirstChild("TempNpcs")

		if tempNpcs == nil or tempNpcs:FindFirstChild(v) == nil then
			error((`SpawnNpc: no temp NPC config named "{v}" in ServerStorage.SAM.TempNpcs`))
		end

		for _, target in ipairs(list) do
			local character = target.Character

			if character ~= nil then
				ServerNpcUtil.SpawnTempNpc(v, {
					Position = (character:GetPivot() * CFrame.new(0, 0, -8)).Position,
					Target = target,
					LockTarget = true
				})
			end
		end
	end
}