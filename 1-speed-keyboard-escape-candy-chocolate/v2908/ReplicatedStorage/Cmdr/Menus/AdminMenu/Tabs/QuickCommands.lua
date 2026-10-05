local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
local WebhookLogger

if RunService:IsServer() then
	WebhookLogger = require(ServerScriptService.WebhookLogger)
else
	WebhookLogger = nil
end

local function getRootPart(player)
	local character = player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActionPermission(action: string)
	return (`cui.admin.quickCommands.{action}`)
end

local clientEvent = AdminRemote.RegisterClientEvent(
	"AdminMenu_QuickCommand",
	"cui.admin.quickCommands",
	true,
	function(player, p)
		if type(p) ~= "table" or p.Action ~= "bring" and p.Action ~= "teleport" and p.Action ~= "kick" or type(p.TargetUserId) ~= "number" or p.TargetUserId % 1 ~= 0 then
			return {
				Ok = false,
				Message = "Invalid quick command request"
			}
		end

		local actionPermission = getActionPermission(p.Action) -- equivalent call inferred; original call site unknown

		if not AdminPermissions.hasPermission(player.UserId, actionPermission) then
			return {
				Ok = false,
				Message = "You do not have permission to use this command"
			}
		end

		local playerByUserId = Players:GetPlayerByUserId(p.TargetUserId)

		if not playerByUserId then
			return {
				Ok = false,
				Message = "The selected player left the server"
			}
		end

		if p.Action == "kick" then
			local rank = AdminPermissions.getRank(playerByUserId.UserId)

			if rank > 0 and AdminPermissions.getRank(player.UserId) <= rank then
				return {
					Ok = false,
					Message = "You cannot kick an admin with an equal or higher role"
				}
			end

			local v = {
				Name = playerByUserId.Name,
				UserId = playerByUserId.UserId
			}
			playerByUserId:Kick("Kicked by an administrator")

			if WebhookLogger then
				WebhookLogger:LogKick(player, v, "Quick command")
			end

			return {
				Ok = true,
				Message = `{v.Name} was kicked`
			}
		else
			local character = player.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			local character2 = playerByUserId.Character
			local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
				humanoidRootPart2 = nil
			end

			if not (humanoidRootPart and humanoidRootPart2) then
				return {
					Ok = false,
					Message = "A character is not ready"
				}
			end

			if p.Action == "bring" then
				humanoidRootPart2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -5)

				if WebhookLogger then
					WebhookLogger:LogModBring(player, playerByUserId)
				end

				return {
					Ok = true,
					Message = `{playerByUserId.Name} was brought to you`
				}
			else
				humanoidRootPart.CFrame = humanoidRootPart2.CFrame * CFrame.new(0, 0, -5)

				if WebhookLogger then
					WebhookLogger:LogModTP(player, playerByUserId)
				end

				return {
					Ok = true,
					Message = `Teleported to {playerByUserId.Name}`
				}
			end
		end
	end
)
return {
	DisplayName = "Quick Commands",
	Permission = "cui.admin.quickCommands",
	Order = 1e999,
	Setup = function(object, _)
		if not (RunService:IsClient() and Players.LocalPlayer) then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = {}
		local v2 = nil
		local flag = false
		local v3 = false
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateButtons()
			local v8

			if clientEvent == nil or v2 == nil then
				v8 = false
			else
				v8 = not v3
			end

			v5:SetEnabled(v8)
			v6:SetEnabled(v8)
			v7:SetEnabled(v8)
		end

		local function refreshPlayers()
			if flag then
				return
			end

			table.clear(v)
			local values = {}

			for _, v8 in Players:GetPlayers() do
				local formatted = `{v8.Name}_{v8.UserId}`
				v[formatted] = v8
				table.insert(values, formatted)
			end

			table.sort(values, function(a, b)
				return string.lower(a) < string.lower(b)
			end)
			local value = v4:GetValue()
			local v8

			if v[value] then
				v8 = value
			else
				v8 = values[1] or "No players"
			end

			v2 = v[v8]
			v4:SetChoiceList(not (#values > 0) and { v8 } or values)

			if value ~= v8 then
				v4:SetSelected(v8)
			end

			updateButtons() -- equivalent call inferred; original call site unknown
		end

		local function runAction(action: string)
			local v8 = v2

			if not clientEvent or not v8 or v8.Parent ~= Players or v3 then
				refreshPlayers()
				return
			end

			v3 = true
			updateButtons() -- equivalent call inferred; original call site unknown
			clientEvent:Fire({
				Action = action,
				TargetUserId = v8.UserId
			}):andThen(function(p2)
				if flag then
					return
				end

				v3 = false
				updateButtons() -- equivalent call inferred; original call site unknown

				if not p2 then
					NotificationSystem:ShowGeneralNotification(
						"Quick command was rejected",
						Color3.fromRGB(255, 100, 100),
						4
					)
					return
				end

				local message = p2.Message
				local v10

				if p2.Ok then
					v10 = Color3.fromRGB(100, 255, 100)
				else
					v10 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v10, 4)
			end):catch(function(p2)
				if flag then
					return
				end

				v3 = false
				updateButtons() -- equivalent call inferred; original call site unknown
				NotificationSystem:ShowGeneralNotification(
					`Quick command failed: {tostring(p2)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		v4 = object:AddDropdown(function(object2)
			object2:SetText("Player"):SetChoiceList({ "No players" }):SetSelected("No players"):SetOnChanged(function(p)
				v2 = v[p]
				updateButtons() -- equivalent call inferred; original call site unknown
			end)
		end)
		object:AddSplit(function(p)
			v5 = p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Bring"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.admin.quickCommands.bring"):SetButtonCallback(function()
					runAction("bring")
				end)
			end)
			v6 = p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("TP"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.admin.quickCommands.teleport"):SetButtonCallback(function()
					runAction("teleport")
				end)
			end)
		end)
		v7 = object:AddButton(function(object2)
			object2:SetButtonText("Kick"):SetYSize(22):SetEnabled(false):SetEnabledPermission("cui.admin.quickCommands.kick"):SetButtonColor(Color3.fromRGB(
				190,
				45,
				45
			)):DoNeedConfirmation(true):SetButtonCallback(function()
				runAction("kick")
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(function()
			refreshPlayers()
		end)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function()
			task.defer(refreshPlayers)
		end)
		v4:GetUI().Destroying:Connect(function()
			flag = true
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end)
		refreshPlayers()
	end
}