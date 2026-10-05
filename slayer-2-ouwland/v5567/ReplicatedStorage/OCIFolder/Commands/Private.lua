local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local suggester = {}

for k, v2 in Worlds.Grid do
	if v2.Ignore ~= true then
		table.insert(suggester, k)
	end
end

table.sort(suggester)
return {
	Clearance = 7,
	Keys = {
		{
			Type = "Players",
			Required = true,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				if lower == "all" then
					return Players:GetPlayers()
				end

				if lower == "all except me" then
					local result = {}

					for _, v2 in Players:GetPlayers() do
						if v2 ~= Players.LocalPlayer then
							table.insert(result, v2)
						end
					end

					return result
				else
					local localPlayers = {}

					for k in value:gmatch("[^,]+") do
						local match = k:match("^%s*(.-)%s*$")
						local localPlayer

						if match:lower() == "me" then
							localPlayer = Players.LocalPlayer
						else
							localPlayer = Players:FindFirstChild(match)
						end

						if localPlayer == nil or not localPlayer:IsA("Player") or table.find(localPlayers, localPlayer) ~= nil then
							return nil
						else
							table.insert(localPlayers, localPlayer)
						end
					end

					if #localPlayers > 0 then
						return localPlayers
					end

					return nil
				end
			end
		},
		{
			Type = "World",
			Name = "World",
			Required = false,
			Suggester = suggester,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				for _, v2 in suggester do
					if v2:lower() == lower then
						return v2
					end
				end

				return nil
			end
		}
	},
	Server = function(_, list, p: string?)
		if RunService:IsStudio() then
			error("Private: Studio refuses teleports — run this in a published server")
		end

		if #list == 0 then
			error("Private: no players targeted (use `me`)")
		end

		local placeId = game.PlaceId

		if p ~= nil then
			local v2 = Worlds.ByName[p]

			if v2 == nil or v2.Ignore == true then
				error((`Private: no world named "{p}" ({table.concat(suggester, ", ")})`))
			end

			placeId = v2.Id
		end

		local TeleportHandler = require(ServerScriptService.USC.TeleportHandler)

		if not TeleportHandler.GroupToPrivateServer(placeId, list, {
			SubTitle = "Private Server"
		}) then
			error("Private: the teleport failed — check the server log")
		end

		return {
			Content = `Sent {#list} player(s) into a fresh private server`,
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}