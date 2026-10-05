local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local isServer = RunService:IsServer()
local parent = script.Parent
local Give = require(parent.Give)
local Mastery = require(parent.Mastery)
local Set = require(parent.Set)
local Utility = require(ReplicatedStorage.RemotePlus.Handlers.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility2 = require(ReplicatedStorage.CAM.Global.Utility)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local v

if isServer then
	local BanActions = require(ServerStorage.SAM.BanActions)
	v = BanActions or nil
else
	v = nil
end

local v2

if isServer then
	local Discord = require(ServerStorage.SAM.Services.Reporting.Discord)
	v2 = Discord or nil
else
	v2 = nil
end

local v3

if isServer then
	local TeleportServer = require(ServerStorage.CtS_modules.TeleportServer)
	v3 = TeleportServer or nil
else
	v3 = nil
end

local Penalties = isServer and require(ServerStorage.SAM.AntiCheat.Penalties) or nil
local Clan = isServer and require(parent.Set.Clan) or nil
local TeleportHandler = isServer and require(ServerScriptService.USC.TeleportHandler) or nil
local key = Give.Keys[3]
local key2 = Mastery.Keys[2]
local result = {}
local suggester = {
	"Ban",
	"Unban",
	"Appeal",
	"Kick",
	"Bring",
	"Goto",
	"Give",
	"Spectate",
	"Join"
}
local v5 = {
	"Level",
	"Item",
	"Wen",
	"Breathing",
	"Evil Art",
	"Mastery",
	"Clan"
}

for _, v6 in Set.Keys[3].Suggester({
	[2] = "clan"
}) do
	if v6 ~= "None" then
		table.insert(result, v6)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function named(items, p)
	local lower = tostring(p):lower()

	for _, item in items do
		if item:lower() == lower then
			return item
		end
	end

	return nil
end

local function target(p, p2, flag: boolean?)
	local player = Players:FindFirstChild((tostring(p2)))

	if player == nil or not player:IsA("Player") then
		error((`No player named "{p2}" in this server`))
	end

	if player == p then
		error("Staff cannot use this on themselves")
	end

	if not flag and v.IsStaff(player) then
		error("Staff cannot use this on other staff")
	end

	return player
end

local function optional(p: string)
	if p == nil or p == "" then
		return nil
	end

	return tonumber(p) or p
end

local v6 = {}
local watchedFocus = Utility.WatchedFocus or {}

-- equivalent calls inferred from this helper; original call sites unknown
local function unfocus(p)
	local v7 = watchedFocus[p]

	if v7 ~= nil then
		watchedFocus[p] = nil
		pcall(p.RemoveReplicationFocus, p, v7)
	end
end

local function unwatch(p)
	local v7 = v6[p]

	if v7 == nil then
		return
	end

	v6[p] = nil

	for _, connection in v7 do
		connection:Disconnect()
	end

	unfocus(p) -- equivalent call inferred; original call site unknown
	SignalEvent.ToClient(p, "StaffSpectate", nil)
end

local function watch(object, player)
	unwatch(object)
	local connections = {}

	local function aim()
		unfocus(object) -- equivalent call inferred; original call site unknown
		local character = player.Character
		local humanoidRootPart

		if character ~= nil then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart ~= nil then
			object:AddReplicationFocus(humanoidRootPart)
			watchedFocus[object] = humanoidRootPart
		end

		SignalEvent.ToClient(object, "StaffSpectate", player.UserId)
	end

	table.insert(connections, player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 10)

		if v6[object] == connections then
			aim()
		end
	end))
	table.insert(connections, object.CharacterAdded:Connect(function()
		unwatch(object)
	end))
	table.insert(connections, Players.PlayerRemoving:Connect(function(player2)
		if player2 == player or player2 == object then
			unwatch(object)
		end
	end))
	v6[object] = connections
	aim()
end

return {
	Clearance = 0.75,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = suggester,
			Completer = function(p: string)
				local lower = tostring(p):lower()

				for _, v8 in suggester do
					if v8:lower() == lower then
						return v8
					end
				end

				return nil
			end
		},
		{
			Type = "Username",
			Name = "Username",
			Required = true,
			Suggester = function(list)
				local item = named(suggester, list[1] or "") -- equivalent call inferred; original call site unknown
				local names = item == "Spectate" and { "none" } or {}

				for _, v9 in Players:GetPlayers() do
					table.insert(names, v9.Name)
				end

				return names
			end
		},
		{
			Type = "Value",
			Name = "Hours / reason / give type",
			Required = false,
			Suggester = function(list)
				local item = named(suggester, list[1] or "") -- equivalent call inferred; original call site unknown
				local v9

				if item == "Give" then
					v9 = v5
				end

				return v9, true
			end,
			Completer = optional
		},
		{
			Type = "Value",
			Name = "Reason / give value",
			Required = false,
			Suggester = function(list)
				local item = named(suggester, list[1] or "") -- equivalent call inferred; original call site unknown

				if item ~= "Give" then
					return nil, true
				end

				local item2 = named(v5, list[3] or "") -- equivalent call inferred; original call site unknown

				if item2 == "Mastery" then
					return key2.Suggester, true
				elseif item2 == "Clan" then
					return result, true
				end

				return key.Suggester({
					[2] = item2
				})
			end,
			Completer = function(p: string, list)
				local v7

				if not (p == nil or p == "") then
					local item = named(suggester, list[1] or "") -- equivalent call inferred; original call site unknown

					if item == "Give" then
						local lower = tostring(list[3] or ""):lower()

						for _, v12 in v5 do
							if v12:lower() ~= lower then
								continue
							end

							v7 = v12
							break
						end
					end
				end

				local v8

				if v7 == "Mastery" then
					v8 = key2.Completer(p)
				elseif v7 == "Clan" then
					local lower = tostring(p):lower()

					for _, v11 in result do
						if v11:lower() ~= lower then
							continue
						end

						v8 = v11
						break
					end
				elseif v7 == "Item" or v7 == "Breathing" or v7 == "Evil Art" then
					v8 = key.Completer(p, {
						[2] = v7
					})
				end

				if v8 then
					return v8
				end

				if p == nil or p == "" then
					return nil
				end

				return tonumber(p) or p
			end
		},
		{
			Type = "Amount",
			Name = "Amount / level",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(player, p2: string, p3, value, value2, p4)
		local item = named(suggester, p2) -- equivalent call inferred; original call site unknown

		if item == nil then
			error((`Invalid staff action: {p2}`))
		end

		if item == "Unban" then
			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, (tostring(p3)))

			if not success then
				error((`No Roblox account named "{p3}"`))
			end

			v.Lift({
				id = userIdFromNameAsync,
				name = tostring(p3)
			}, player)
			return {
				Content = `Unbanned {p3} ({userIdFromNameAsync})`,
				ContentColor = Color3.new(1, 1, 1),
				BgColor = Color3.fromRGB(30, 110, 60)
			}
		elseif item == "Appeal" then
			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, (tostring(p3)))

			if not success then
				error((`No Roblox account named "{p3}"`))
			end

			local lift, content = Penalties.Lift({
				id = userIdFromNameAsync,
				name = tostring(p3)
			}, player)

			if not lift then
				error(content)
			end

			return {
				Content = content,
				ContentColor = Color3.new(1, 1, 1),
				BgColor = Color3.fromRGB(30, 110, 60)
			}
		elseif item == "Join" then
			if RunService:IsStudio() then
				error("Studio refuses teleports; run this in a published server")
			end

			local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, (tostring(p3)))

			if not success then
				error((`No Roblox account named "{p3}"`))
			end

			local success2, playerPlaceInstanceAsync, _, v9 = pcall(
				TeleportService.GetPlayerPlaceInstanceAsync,
				TeleportService,
				userIdFromNameAsync
			)

			if success2 and playerPlaceInstanceAsync ~= true and v9 == gameSettings.HUDQueuPlaceId then
				local minigameCode = TeleportHandler.MinigameCode(userIdFromNameAsync)

				if minigameCode == nil then
					error((`{p3}'s minigame server can't be reached`))
				end

				if not TeleportHandler.GroupToReservedServer(v9, minigameCode, { player }) then
					error("Teleport failed")
				end
			else
				local v10, v11 = v3(player, {
					followName = tostring(p3),
					allowFallback = false
				})

				if not v10 then
					error(v11 or "Teleport failed")
				end
			end

			v2.Send("moderation", "Join", {
				player = player,
				target = {
					id = userIdFromNameAsync,
					name = tostring(p3)
				}
			})
			return {
				Content = `Joining {p3}'s server`,
				ContentColor = Color3.new(1, 1, 1),
				BgColor = Color3.fromRGB(40, 70, 120)
			}
		else
			local lower = tostring(p3):lower()

			if item == "Spectate" and (lower == "none" or lower == player.Name:lower()) then
				unwatch(player)
				return {
					Content = "Spectate ended",
					ContentColor = Color3.new(1, 1, 1),
					BgColor = Color3.fromRGB(40, 70, 120)
				}
			end

			local target2 = target(player, p3, item == "Spectate")

			if item == "Ban" then
				local v10 = tonumber(value)

				if v10 == nil or v10 < 0 then
					error((`Hours must be a number (0 = permanent), not "{value}"`))
				end

				if typeof(value2) ~= "string" or string.match(value2, "^%s*$") ~= nil then
					error("A reason is required")
				end

				v.Manual(v2.Player(target2), not (v10 > 0) and -1 or v10 * 3600, value2, player)
				return {
					Content = `Banned {target2.Name} {not (v10 > 0) and "permanently" or `for {v10}h`}: {value2}`,
					ContentColor = Color3.new(1, 1, 1),
					BgColor = Color3.fromRGB(150, 30, 30)
				}
			elseif item == "Kick" then
				local reason = (typeof(value) ~= "string" or value == "") and "You were removed by a moderator." or value
				v2.Send("moderation", "Kick", {
					player = player,
					target = target2,
					data = {
						reason = reason
					}
				})
				target2:Kick(reason)
				return nil
			elseif item == "Bring" or item == "Goto" then
				local v10

				if item == "Bring" then
					v10 = target2
				else
					v10 = player
				end

				local v11

				if item == "Bring" then
					v11 = player
				else
					v11 = target2
				end

				local humanoidRootPart

				if v11.Character ~= nil then
					humanoidRootPart = v11.Character:FindFirstChild("HumanoidRootPart")
				end

				if humanoidRootPart == nil then
					error((`{v11.Name} has no character`))
				end

				if v10.Character ~= nil then
					local position = humanoidRootPart.Position
					local position2 = (humanoidRootPart.CFrame * CFrame.new(0, 0, -4)).Position
					v10.Character:PivotTo(CFrame.lookAt(position2, position))
					v10.Character:MoveTo(position2)
				end

				v2.Send("moderation", item, {
					player = player,
					target = target2
				})
				return nil
			elseif item == "Give" then
				local item2 = named(v5, value or "") -- equivalent call inferred; original call site unknown

				if item2 == nil then
					error((`Staff can give {table.concat(v5, ", ")}, not "{value}"`))
				end

				if value2 == nil then
					error((`Give {item2} needs a value`))
				end

				if item2 == "Mastery" then
					local item3 = named(key2.Suggester, value2) -- equivalent call inferred; original call site unknown

					if item3 == nil then
						error((`No mastery track named "{value2}"`))
					end

					if tonumber(p4) == nil then
						error("Give Mastery needs a level")
					end

					return Mastery.Server(player, { target2 }, item3, p4)
				else
					if item2 ~= "Clan" then
						return Give.Server(player, { target2 }, item2, value2, p4)
					end

					local clan2 = named(result, value2) -- equivalent call inferred; original call site unknown

					if clan2 == nil then
						error((`No clan named "{value2}"`))
					end

					local data = Utility2.GetData(target2)
					local clan

					if data ~= nil then
						clan = data:FindFirstChild("Clan")
					end

					if clan == nil then
						error((`{target2.Name}'s data is not loaded`))
					end

					local previous = clan.Value
					Clan({ target2 }, clan2)
					v2.Send("moderation", "ClanRestore", {
						player = player,
						target = target2,
						data = {
							clan = clan2,
							previous = previous
						}
					})
					return {
						Content = `Gave {target2.Name} the {clan2} clan (was {previous})`,
						ContentColor = Color3.new(1, 1, 1),
						BgColor = Color3.fromRGB(30, 110, 60)
					}
				end
			else
				if item ~= "Spectate" then
					return nil
				end

				watch(player, target2)
				v2.Send("moderation", "Spectate", {
					player = player,
					target = target2
				})
				return {
					Content = `Spectating {target2.Name}; Staff Spectate none to stop`,
					ContentColor = Color3.new(1, 1, 1),
					BgColor = Color3.fromRGB(40, 70, 120)
				}
			end
		end
	end
}