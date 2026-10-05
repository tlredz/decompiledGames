local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
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

		local v = type(data.Scope) ~= "string" and "" or string.lower(data.Scope)

		if v ~= "player" and v ~= "server" and v ~= "global" then
			return {
				Ok = false,
				Message = "Invalid bonus scope"
			}
		end

		if data.BonusType ~= "XP" and data.BonusType ~= "Wins" then
			return {
				Ok = false,
				Message = "Invalid bonus type"
			}
		end

		local multiplier = data.Multiplier
		local duration = data.Duration

		if type(multiplier) ~= "number" or multiplier ~= multiplier or multiplier < 1 or multiplier > 10000 then
			return {
				Ok = false,
				Message = `Multiplier must be between {1} and {10000}`
			}
		end

		if type(duration) ~= "number" or duration ~= duration or duration < 1 or duration > 1440 then
			return {
				Ok = false,
				Message = "Duration must be between 1 and 1440 minutes"
			}
		end

		local flag

		if data.BonusType == "Wins" and multiplier > 10 then
			multiplier = 10
			flag = true
		else
			flag = false
		end

		local playerByUserId

		if v == "player" then
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
		local v2 = Config.GetEventDataKey() ~= nil

		if v2 and v ~= "global" then
			return {
				Ok = false,
				Message = "XP/Wins bonuses are disabled on the event world"
			}
		end

		local BonusManager = require(ReplicatedStorage.BonusManager)
		local success, result = pcall(function()
			BonusManager:ActivateBonus(v, data.BonusType, multiplier, duration * 60, playerByUserId, "AdminAbuse", {
				excludeEventWorlds = true
			})
		end)

		if not success then
			return {
				Ok = false,
				Message = `Failed to activate bonus: {tostring(result)}`
			}
		end

		local v3

		if v == "player" then
			v3 = playerByUserId.Name
		else
			v3 = v == "server" and "this server" or "all servers"
		end

		local formatted = `Bonus {data.BonusType} x{multiplier} activated for {v3} ({duration} min)`

		if v2 and v == "global" then
			formatted = `Bonus {data.BonusType} x{multiplier} published globally ({duration} min)`
		elseif flag then
			formatted ..= ` — Wins mult capped x{10}`
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
			for _, v in { "XP", "Wins" } do
				BonusManager:StopBonus("server", v, nil, "AdminAbuse")
				BonusManager:StopBonus("global", v, nil, "AdminAbuse")
			end

			for _, v in Players:GetPlayers() do
				for _, v2 in { "XP", "Wins" } do
					BonusManager:StopBonus("player", v2, v, "AdminAbuse")
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
		local targetUserId = nil
		local userIds = {}
		local v6 = nil
		local flag = false
		local flag2 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Notify(message: string, ok: boolean)
			local v7

			if ok then
				v7 = Color3.fromRGB(100, 255, 100)
			else
				v7 = Color3.fromRGB(255, 100, 100)
			end

			NotificationSystem:ShowGeneralNotification(message, v7, 4)
		end

		local function RefreshPlayers()
			table.clear(userIds)
			local values = {}

			for _, v7 in Players:GetPlayers() do
				local formatted = `{v7.Name}_{v7.UserId}`
				table.insert(values, formatted)
				userIds[formatted] = v7.UserId
			end

			table.sort(values)
			local value = v6:GetValue()
			local v7

			if userIds[value] then
				v7 = value
			else
				v7 = values[1] or "No players"
			end

			targetUserId = userIds[v7]
			v6:SetChoiceList(not (#values > 0) and { v7 } or values)

			if value ~= v7 then
				v6:SetSelected(v7)
			end
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Scope"):SetChoiceList({ "Server", "Global", "Player" }):SetSelected("Server"):SetOnChanged(function(value)
					scope = string.lower(value)
					v6:SetVisible(scope == "player")
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
				object2:SetText("Multiplier"):SetNumberFilter(1, 10000):SetValue(2):SetOnChangedUnfocus(function(p2)
					multiplier = tonumber(p2) or 2
				end)
			end)
			p.RightComponents:AddNumberField(function(object2)
				object2:SetText("Duration (minutes)"):SetNumberFilter(1, 1440):SetValue(10):SetOnChangedUnfocus(function(p2)
					duration = tonumber(p2) or 10
				end)
			end)
		end)
		v6 = object:AddDropdown(function(object2)
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
							TargetUserId = targetUserId
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
		local playerAddedConnection = Players.PlayerAdded:Connect(RefreshPlayers)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function()
			task.defer(RefreshPlayers)
		end)
		v6:GetUI().Destroying:Connect(function()
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end)
		RefreshPlayers()
	end
}