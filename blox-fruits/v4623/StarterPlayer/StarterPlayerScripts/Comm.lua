local Players = game:GetService("Players")
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local teleportVip = remotes:WaitForChild("TeleportVip")
local commE = remotes:WaitForChild("CommE")
local Notification = require(game.ReplicatedStorage:WaitForChild("Notification"))
local localPlayer = game.Players.LocalPlayer

local function syncSafeZone()
	local Global = require(game.ReplicatedStorage.Global)
	Global.InSafeZone = localPlayer:GetAttribute("InSafeZone") == true
	local safeZone = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("SafeZone")
	local inSafeZone = localPlayer:GetAttribute("InSafeZone") == true
	local inDangerZone = localPlayer:GetAttribute("InDangerZone") == true
	safeZone.Visible = inSafeZone or inDangerZone
	safeZone.Text = inDangerZone and "⚔️Danger - PvP Zone⚔️" or "🛡Safe Zone - PvP disabled🛡"
end

localPlayer:GetAttributeChangedSignal("InSafeZone"):Connect(syncSafeZone)
localPlayer:GetAttributeChangedSignal("InDangerZone"):Connect(syncSafeZone)
task.spawn(function()
	localPlayer:WaitForChild("PlayerGui").ChildAdded:Connect(function(child)
		if child.Name == "Main" then
			syncSafeZone()
		end
	end)
	syncSafeZone()
end)
local Global = require(game.ReplicatedStorage.Global)
Global.ServerData = {
	ExpBoost = 0,
	ExpBoostTick = tick()
}
require(game.ReplicatedStorage.Util)
commE.OnClientEvent:Connect(function(p, ...)
	if p == "Notify" then
		if ({ ... })[1]:find("Earned <Color=Green>$") then
			script.Money:Play()
		end

		local Notification2 = require(game.ReplicatedStorage.Notification)
		Notification2.new(...):Display()
	elseif p == "warnoutput" then
		warn(...)
	elseif p == "ExpBoost" then
		local expBoost = ...
		Players.LocalPlayer:SetAttribute("ExpBoost", expBoost)
		Players.LocalPlayer:SetAttribute("ExpBoostTick", tick())
		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.ServerData.ExpBoost = expBoost
		local Global3 = require(game.ReplicatedStorage.Global)
		Global3.ServerData.ExpBoostTick = tick()
	elseif p == "DestroyPart" then
		local v = ...
		local Global2 = require(game.ReplicatedStorage.Global)
		local encoded = Global2.Encode(v)
		pcall(function()
			wait()
			encoded:Destroy()
		end)
	elseif p == "DefeatedDoughKing" then
		workspace:WaitForChild("Map"):WaitForChild("CakeLoaf"):WaitForChild("RedDoor", 999999):Destroy()
	elseif p == "SafeZone" then
		syncSafeZone()
	elseif p == "PvpDisabled" then
		local visible = ...
		game.Players.LocalPlayer:SetAttribute("PvpDisabled", visible)
		local pvpDisabled = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("PvpDisabled")
		pvpDisabled.Visible = visible
		syncSafeZone()
	elseif p == "InCombat" then
		local v, v2 = ...
		local bottomHUDList = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("BottomHUDList")
		local inCombat = bottomHUDList:WaitForChild("InCombat")
		local inCombatBottom = bottomHUDList:WaitForChild("InCombatBottom")

		if v2 then
			inCombat.Text = string.format("⚔️In Combat⚔️")
		else
			inCombat.Text = string.format(
				"⚔️In Combat - %s at risk!⚔️",
				game.Players.LocalPlayer.Team == game.Teams.Pirates and "Bounty" or "Honor"
			)
		end

		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.InCombat = v
		inCombat.Visible = v
		syncSafeZone()
		inCombatBottom.Visible = v
	elseif p == "ChatNotification" then
		local v, v2 = ...
		local v3 = {
			Red = "#FF0000",
			Green = "#00FF00",
			Blue = "#0000FF",
			Yellow = "#FFFF00",
			White = "#FFFFFF"
		}

		local function ConvertFakeRichText(value: string)
			return (value:gsub("<Color=(%w+)>", function(p2)
				local v4 = v3[p2]

				if v4 then
					return string.format("<font color=\"%s\">", v4)
				end

				return ""
			end):gsub("<Color=/>", "</font>"))
		end

		local TextChatService = game:GetService("TextChatService")
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage((`<font color="#FF0000">{v:gsub("<Color=(%w+)>", function(p2)
			local v4 = v3[p2]

			if v4 then
				return string.format("<font color=\"%s\">", v4)
			end

			return ""
		end):gsub("<Color=/>", "</font>")}</font>`))

		if not (v2 or v:find("joined the server")) then
			Notification.new(v):Display()
		end
	elseif p == "FruitHide" then
		local v = ...
		local Global2 = require(game.ReplicatedStorage.Global)
		local encoded = Global2.Encode(v)

		if encoded and encoded.Parent then
			local Global3 = require(game.ReplicatedStorage.Global)
			Global3.TestGamePrint("fruithide")
			encoded:ClearAllChildren()
			encoded.ChildAdded:Connect(function(child)
				local Global4 = require(game.ReplicatedStorage.Global)
				Global4.TestGamePrint("destroy")
				task.defer(child.Destroy, child)
			end)
		else
			local fruit = workspace:WaitForChild("Fruit ", 3)

			if fruit then
				fruit:Destroy()
			end
		end
	end
end)

if game.ReplicatedStorage:FindFirstChild("ReservedServer") then
	game:GetService("Players")
	local TeleportService = game:GetService("TeleportService")
	local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

	if localPlayerTeleportData then
		teleportVip:FireServer(localPlayerTeleportData.Id, localPlayerTeleportData.VipOwner)
	end
end