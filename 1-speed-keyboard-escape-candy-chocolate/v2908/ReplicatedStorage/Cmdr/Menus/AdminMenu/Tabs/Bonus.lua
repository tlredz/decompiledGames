local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
local v = {
	["Galaxy 1"] = 1,
	["Galaxy 2"] = 2
}
local v2 = { true, true }
local v3 = { "XP", "Wins" }
local v4 = { "GlobalBonuses_Galaxy1", "GlobalBonuses_Galaxy2" }

local function stopLegacyGlobalBonuses()
	local count = 0
	local count2 = 0

	for k, v5 in v4 do
		local hashMap = MemoryStoreService:GetHashMap(v5)
		local v6 = "BonusSystem_Galaxy" .. k

		for _, v7 in v3 do
			local v8 = hashMap
			local v9 = v7

			if pcall(function()
				v8:RemoveAsync(v9 .. "___AdminAbuse")
			end) then
				count += 1
			else
				count2 += 1
			end

			local v10 = v6
			local bonusType = v7

			if pcall(function()
				MessagingService:PublishAsync(v10, HttpService:JSONEncode({
					bonusType = bonusType,
					boostKind = "AdminAbuse",
					mult = 0,
					endTime = 0,
					excludeEventWorlds = false
				}))
			end) then
				count += 1
			else
				count2 += 1
			end
		end
	end

	return count, count2
end

local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_ActivateBonus",
	"cui.admin.bonus.activate",
	true,
	function(_, data)
		if type(data) ~= "table" then
			return {
				Ok = false,
				Message = "Invalid bonus request"
			}
		end

		local v5 = type(data.Scope) ~= "string" and "" or string.lower(data.Scope)

		if v5 ~= "player" and v5 ~= "server" and v5 ~= "global" then
			return {
				Ok = false,
				Message = "Invalid bonus scope"
			}
		end

		local v6 = v5 == "global"

		if data.BonusType ~= "XP" and data.BonusType ~= "Wins" then
			return {
				Ok = false,
				Message = "Invalid bonus type"
			}
		end

		local galaxyIndex = data.GalaxyIndex

		if galaxyIndex ~= nil and (type(galaxyIndex) ~= "number" or v2[galaxyIndex] ~= true) then
			return {
				Ok = false,
				Message = "Select a valid galaxy"
			}
		end

		if not v6 then
			galaxyIndex = nil
		end

		local multiplier = data.Multiplier
		local duration = data.Duration

		if type(multiplier) ~= "number" or multiplier ~= multiplier or multiplier < 1 or multiplier > 50000 then
			return {
				Ok = false,
				Message = `Multiplier must be between {1} and {50000}`
			}
		end

		if type(duration) ~= "number" or duration ~= duration or duration < 1 or duration > 1440 then
			return {
				Ok = false,
				Message = "Duration must be between 1 and 1440 minutes"
			}
		end

		local flag

		if data.BonusType == "Wins" and multiplier > 20 then
			multiplier = 20
			flag = true
		else
			flag = false
		end

		local playerByUserId

		if v5 == "player" then
			if type(data.TargetUserId) ~= "number" or data.TargetUserId <= 0 or data.TargetUserId % 1 ~= 0 then
				return {
					Ok = false,
					Message = "Select a valid player"
				}
			end

			playerByUserId = Players:GetPlayerByUserId(data.TargetUserId)

			if not playerByUserId then
				return {
					Ok = false,
					Message = "The selected player left the server"
				}
			end
		else
			playerByUserId = nil
		end

		local Config = require(ReplicatedStorage.Config)
		local v7 = Config.GetEventDataKey() ~= nil

		if v7 and not v6 then
			return {
				Ok = false,
				Message = "XP/Wins bonuses are disabled on this world"
			}
		end

		local BonusManager = require(ReplicatedStorage.BonusManager)
		local success, result = pcall(function()
			BonusManager:ActivateBonus(v5, data.BonusType, multiplier, duration * 60, playerByUserId, "AdminAbuse", {
				excludeEventWorlds = true,
				galaxyIndex = galaxyIndex
			})
		end)

		if not success then
			return {
				Ok = false,
				Message = `Failed to activate bonus: {tostring(result)}`
			}
		end

		local v8 = not galaxyIndex and "all galaxies" or `Galaxy {galaxyIndex}`
		local v9

		if playerByUserId then
			v9 = playerByUserId.Name
		else
			v9 = not v6 and "this server" or v8
		end

		local formatted = `Bonus {data.BonusType} x{multiplier} activated for {v9} ({duration} min)`

		if v7 and v6 then
			formatted = `Bonus {data.BonusType} x{multiplier} published for {v8} ({duration} min)`
		elseif flag then
			formatted ..= ` — Wins mult capped x{20}`
		end

		return {
			Ok = true,
			Message = formatted
		}
	end
)
local clientEvent2 = AdminRemote.RegisterClientEvent(
	"AdminMenu_StopBonuses",
	"cui.admin.bonus.stop",
	true,
	function(_, _)
		local BonusManager = require(ReplicatedStorage.BonusManager)
		local success, result = pcall(function()
			for _, v5 in { "XP", "Wins" } do
				BonusManager:StopBonus("server", v5, nil, "AdminAbuse")
				BonusManager:StopBonus("global", v5, nil, "AdminAbuse")
			end

			for _, v5 in Players:GetPlayers() do
				for _, v6 in { "XP", "Wins" } do
					BonusManager:StopBonus("player", v6, v5, "AdminAbuse")
				end
			end

			BonusManager:BroadcastToClients()
		end)

		if success then
			return {
				Ok = true,
				Message = "All admin bonuses stopped"
			}
		end

		return {
			Ok = false,
			Message = `Failed to stop bonuses: {tostring(result)}`
		}
	end
)
local clientEvent3 = AdminRemote.RegisterClientEvent(
	"AdminMenu_StopLegacyBonuses",
	"cui.admin.bonus.stop",
	true,
	function(_, _)
		local v5, v6 = stopLegacyGlobalBonuses()

		if v6 > 0 then
			return {
				Ok = false,
				Message = `Legacy stop partially failed ({v5} succeeded, {v6} failed)`
			}
		end

		return {
			Ok = true,
			Message = "Legacy global admin bonuses stopped"
		}
	end
)
return {
	DisplayName = "Bonus",
	Permission = "cui.admin.bonus",
	Order = 10,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local scope = "server"
		local bonusType = "XP"
		local multiplier = 2
		local duration = 10
		local galaxyIndex = nil
		local targetUserId = nil
		local userIds = {}
		local v11 = nil
		local v12 = nil
		local flag = false
		local flag2 = false
		local flag3 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Notify(message: string, ok: boolean)
			local v13

			if ok then
				v13 = Color3.fromRGB(100, 255, 100)
			else
				v13 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v13, 4)
		end

		local function RefreshPlayers()
			table.clear(userIds)
			local values = {}

			for _, v13 in Players:GetPlayers() do
				local formatted = `{v13.Name}_{v13.UserId}`
				table.insert(values, formatted)
				userIds[formatted] = v13.UserId
			end

			table.sort(values)
			local value = v11:GetValue()
			local v13

			if userIds[value] then
				v13 = value
			else
				v13 = values[1] or "No players"
			end

			targetUserId = userIds[v13]
			v11:SetChoiceList(not (#values > 0) and { v13 } or values)

			if value ~= v13 then
				v11:SetSelected(v13)
			end
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Scope"):SetChoiceList({ "Server", "Global", "Player" }):SetSelected("Server"):SetOnChanged(function(value)
					scope = string.lower(value)
					v11:SetVisible(scope == "player")
					v12:SetVisible(scope == "global")
				end)
			end)
			p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Type"):SetChoiceList({ "XP", "Wins" }):SetSelected("XP"):SetOnChanged(function(p2)
					bonusType = p2
				end)
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddNumberField(function(object2)
				object2:SetText("Multiplier"):SetNumberFilter(1, 50000):SetValue(2):SetOnChangedUnfocus(function(p2)
					multiplier = tonumber(p2) or 2
				end)
			end)
			p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Duration (minutes)"):SetNumberFilter(1, 1440):SetValue(10):SetOnChangedUnfocus(function(p2)
					duration = tonumber(p2) or 10
				end)
			end)
		end)
		v12 = object:AddDropdown(function(object2)
			object2:SetText("Galaxies"):SetChoiceList({ "All galaxies", "Galaxy 1", "Galaxy 2" }):SetSelected("All galaxies"):SetOnChanged(function(p)
				galaxyIndex = v[p]
			end)
			object2:SetVisible(false)
		end)
		v11 = object:AddDropdown(function(object2)
			object2:SetText("Player"):SetChoiceList({ "No players" }):SetSelected("No players"):SetVisible(false):SetOnChanged(function(p)
				targetUserId = userIds[p]
			end)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Activate bonus"):SetYSize(22):SetEnabledPermission("cui.admin.bonus.activate"):SetButtonCallback(function()
					if flag then
						return
					end

					if scope == "player" and not targetUserId then
						NotificationSystem:ShowGeneralNotification("Select a player", Color3.fromRGB(255, 100, 100), 4)
					elseif clientEvent then
						flag = true
						clientEvent:Fire({
							Scope = scope,
							BonusType = bonusType,
							Multiplier = multiplier,
							Duration = duration,
							TargetUserId = targetUserId,
							GalaxyIndex = galaxyIndex
						}):andThen(function(p2)
							flag = false

							if p2 then
								Notify(p2.Message, p2.Ok) -- equivalent call inferred; original call site unknown
							else
								NotificationSystem:ShowGeneralNotification(
									"Bonus request was rejected",
									Color3.fromRGB(255, 100, 100),
									4
								)
							end
						end):catch(function(p2)
							flag = false
							NotificationSystem:ShowGeneralNotification(
								`Bonus activation failed: {tostring(p2)}`,
								Color3.fromRGB(255, 100, 100),
								4
							)
						end)
					else
						NotificationSystem:ShowGeneralNotification(
							"Bonus API is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
					end
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Stop all bonuses"):SetYSize(22):SetEnabledPermission("cui.admin.bonus.stop"):DoNeedConfirmation(true):SetButtonCallback(function()
					if flag2 then
						return
					end

					if clientEvent2 then
						flag2 = true
						clientEvent2:Fire({}):andThen(function(p2)
							flag2 = false

							if p2 then
								Notify(p2.Message, p2.Ok) -- equivalent call inferred; original call site unknown
							else
								NotificationSystem:ShowGeneralNotification(
									"Stop bonus request was rejected",
									Color3.fromRGB(255, 100, 100),
									4
								)
							end
						end):catch(function(p2)
							flag2 = false
							NotificationSystem:ShowGeneralNotification(
								`Stopping bonuses failed: {tostring(p2)}`,
								Color3.fromRGB(255, 100, 100),
								4
							)
						end)
					else
						NotificationSystem:ShowGeneralNotification(
							"Bonus API is unavailable",
							Color3.fromRGB(255, 100, 100),
							4
						)
					end
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Legacy stop all bonuses"):SetYSize(22):SetEnabledPermission("cui.admin.bonus.stop"):DoNeedConfirmation(true):SetButtonCallback(function()
				if flag3 then
					return
				end

				if clientEvent3 then
					flag3 = true
					clientEvent3:Fire({}):andThen(function(p)
						flag3 = false

						if p then
							Notify(p.Message, p.Ok) -- equivalent call inferred; original call site unknown
						else
							NotificationSystem:ShowGeneralNotification(
								"Legacy stop request was rejected",
								Color3.fromRGB(255, 100, 100),
								4
							)
						end
					end):catch(function(p)
						flag3 = false
						NotificationSystem:ShowGeneralNotification(
							`Stopping legacy bonuses failed: {tostring(p)}`,
							Color3.fromRGB(255, 100, 100),
							4
						)
					end)
				else
					NotificationSystem:ShowGeneralNotification(
						"Legacy bonus API is unavailable",
						Color3.fromRGB(255, 100, 100),
						4
					)
				end
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(RefreshPlayers)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function()
			task.defer(RefreshPlayers)
		end)
		v11:GetUI().Destroying:Connect(function()
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end)
		RefreshPlayers()
	end
}