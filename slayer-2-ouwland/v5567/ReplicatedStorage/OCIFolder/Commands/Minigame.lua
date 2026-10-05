local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local dataserializer = require(ReplicatedStorage.Packages["data-serializer"])
local HudGrid = require(ReplicatedStorage.CAM.HudGrid)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local v = {}

for k, setting in MinigameSettings.Settings do
	local v2 = {}

	for k2 in setting.Modes or {} do
		table.insert(v2, k2)
	end

	v[k] = v2
end

for k, v2 in HudGrid.Grid do
	local v3 = v[v2.Minigame]

	if v3 == nil then
		v3 = {}
		v[v2.Minigame] = v3
	end

	if table.find(v3, k) == nil then
		table.insert(v3, k)
	end
end

local suggester = {}

for k, list in v do
	table.sort(list)
	table.insert(suggester, k)
end

table.sort(suggester)
return {
	Clearance = 7,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Minigame",
			Name = "Minigame",
			Required = true,
			Suggester = suggester,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				for _, v3 in suggester do
					if v3:lower() == lower then
						return v3
					end
				end

				return nil
			end
		},
		{
			Type = "Gamemode",
			Name = "Gamemode",
			Required = false,
			Suggester = function(list)
				return v[list[2] or ""], true
			end,
			Completer = function(value: string, list)
				if value == nil or value == "" then
					return nil
				end

				local lower = value:lower()

				for _, v3 in v[list[2] or ""] or {} do
					if v3:lower() == lower then
						return v3
					end
				end

				return nil
			end
		}
	},
	Server = function(_, list, minigame: string, gamemode: string?)
		if RunService:IsStudio() then
			error("Minigame: Studio refuses teleports — run this in a published server")
		end

		if gameSettings.IsMinigame then
			error("Minigame: can't re-queue from inside a minigame (TeleportData rides the save, which a run may have disabled) — go home first")
		end

		if #list == 0 then
			error("Minigame: no players targeted (use `me`)")
		end

		local v3 = v[minigame]

		if v3 == nil then
			error((`Minigame: no minigame named "{minigame}" ({table.concat(suggester, ", ")})`))
		end

		if gamemode == "" then
			gamemode = nil
		end

		if gamemode == nil and #v3 > 0 then
			error((`Minigame: {minigame} needs a gamemode ({table.concat(v3, ", ")})`))
		elseif gamemode ~= nil and table.find(v3, gamemode) == nil then
			error((`Minigame: {minigame} has no gamemode "{gamemode}"`))
		end

		local GUID = HttpService:GenerateGUID(false)
		local v4 = HudGrid.ByName[gamemode]
		local players

		if v4 == nil then
			players = #list
		else
			players = v4.Players
		end

		local v5 = {}

		for _, v6 in list do
			local _, v7 = Utility.GetData(v6)

			if v7 == nil then
				continue
			end

			local teleportData = v7:FindFirstChild("TeleportData")

			if teleportData ~= nil then
				teleportData:Destroy()
			end

			local tofold = dataserializer.tofold
			local ticketId

			if #v5 < players then
				ticketId = GUID .. "-A"
			else
				ticketId = GUID .. "-B"
			end

			tofold({
				TeleportData = {
					Minigame = minigame,
					Gamemode = gamemode,
					TeleportId = GUID,
					TicketId = ticketId,
					PlaceId = game.PlaceId,
					JobId = game.JobId
				}
			}, v7)
			table.insert(v5, v6)
		end

		if #v5 == 0 then
			error("Minigame: no targeted player has loaded data to stamp")
		end

		local TeleportHandler = require(ServerScriptService.USC.TeleportHandler)

		if not TeleportHandler.GroupToPrivateServer(gameSettings.HUDQueuPlaceId, v5, {
			Title = "Minigame",
			SubTitle = gamemode or minigame
		}) then
			error("Minigame: the teleport failed — check the server log")
		end

		return {
			Content = `Sent {#v5} player(s) into {minigame}{gamemode == nil and "" or ` ({gamemode})`}`,
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}