local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local localPlayer = Players.LocalPlayer
local chatWindowConfiguration = TextChatService.ChatWindowConfiguration
local custom_Channels = TextChatService:WaitForChild("Custom_Channels", 15)
local textChatCommands = TextChatService:WaitForChild("TextChatCommands", 15)
local textChannels = TextChatService:WaitForChild("TextChannels", 15)
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
ReplicatedStorage:WaitForChild("ModuleScript")
local miscEvents = otherEvent:WaitForChild("MiscEvents")
otherEvent:WaitForChild("ItemEvents")
local secretEvents = otherEvent:WaitForChild("SecretEvents")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
localPlayer:WaitForChild("PlayerData", 60)
otherEvent.GuiEvents:WaitForChild("GuiEvent")
local clientAnnouncement = miscEvents:WaitForChild("ClientAnnouncement")
local notification = miscEvents:WaitForChild("Notification")
miscEvents:WaitForChild("Player_Commands")
local admin_Commands = secretEvents:WaitForChild("Admin_Commands")
local updateTabs = guiEvents:WaitForChild("UpdateTabs")
local v = {}
local _ = {
	"/hideui",
	"/showui",
	"/defaultsky",
	"/recd"
}

local function ConvertArrayToDictionary(list)
	local result = {}

	for _, v2 in ipairs(list) do
		if typeof(v2) == "string" then
			result[v2] = true
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Get_Commands()
	local v2 = admin_Commands:InvokeServer("Get_Commands")

	if v2 then
		v = ConvertArrayToDictionary(v2)
	end
end

local function Delete_TeamChannel()
	for _, textChatCommand in ipairs(textChatCommands:GetChildren()) do
		if not textChatCommand:IsA("TextChatCommand") or textChatCommand.Name ~= "RBXTeamCommand" or textChatCommand:GetAttribute("Disabled") then
			continue
		end

		textChatCommand:SetAttribute("Disabled", true)
		textChatCommand.AutocompleteVisible = false
		textChatCommand.PrimaryAlias = "/teamlnwza007"
		textChatCommand.SecondaryAlias = ""
	end

	for _, textChannel in ipairs(textChannels:GetChildren()) do
		if not (textChannel:IsA("TextChannel") and string.find(textChannel.Name, "RBXTeam")) then
			continue
		end

		textChannel:Destroy()
	end
end

local function Set_ChannelTabs()
	if #custom_Channels:GetChildren() > 0 then
		local flag = false

		for _, textChannel in ipairs(custom_Channels:GetChildren()) do
			if not (textChannel:IsA("TextChannel") and string.find(textChannel.Name, "Trading") and textChannel:FindFirstChild(localPlayer.Name)) then
				continue
			end

			flag = true
			break
		end

		if flag then
			if not TextChatService.ChannelTabsConfiguration.Enabled then
				TextChatService.ChannelTabsConfiguration.Enabled = true
			end
		elseif TextChatService.ChannelTabsConfiguration.Enabled then
			TextChatService.ChannelTabsConfiguration.Enabled = false
		end
	elseif TextChatService.ChannelTabsConfiguration.Enabled then
		TextChatService.ChannelTabsConfiguration.Enabled = false
	end
end

local function Converter(p)
	return (math.floor(p * 255))
end

local function UpdateTabs_Client(p: string)
	if p == "Update_Tabs" then
		Set_ChannelTabs()
	end
end

function TextChatService.OnChatWindowAdded(p)
	local textChannel = p.TextChannel

	if textChannel then
		local textSource = p.TextSource
		local playerByUserId = textSource and Players:GetPlayerByUserId(textSource.UserId)

		if playerByUserId then
			if playerByUserId.HasVerifiedBadge then
				utf8.char(57344)
			end

			local v2 = ""
			local v3 = ""
			local v4 = ""
			local displayName = playerByUserId.DisplayName

			if string.find(textChannel.Name, "Whisper") then
				local v5, v6 = string.match(textChannel.Name, "(%d+)_(%d+)")

				if v5 and v6 then
					local userId = playerByUserId.UserId
					local userId2 = localPlayer.UserId
					local playerByUserId2 = Players:GetPlayerByUserId(tonumber(v5) ~= userId2 and tonumber(v5) or tonumber(v6))

					if playerByUserId2 then
						v2 = `[{userId2 == userId and "To" or "From"} {playerByUserId2.DisplayName or playerByUserId2.Name}]`
					end
				end
			elseif string.find(textChannel.Name, "RBXTeam") then
				v3 = `<font color="rgb({playerByUserId.Team == Teams.Cheems and "175,221,255" or "255,89,89"})">[Team]</font>`
			elseif string.find(textChannel.Name, "Trading") then
				v4 = "<font color=\"rgb(255,255,255)\">[Trade]</font>"
			end

			local newMessageProperties = chatWindowConfiguration:DeriveNewMessageProperties()
			local v5 = playerByUserId.Team == Teams.Cheems and "175,221,255" or "255,89,89"

			if v2 ~= "" then
				newMessageProperties.PrefixText = `{v2} <font color="rgb({v5})">{displayName}:</font>`
				return newMessageProperties
			end

			if v3 ~= "" then
				newMessageProperties.PrefixText = `{v3} <font color="rgb({v5})">{displayName}:</font>`
				return newMessageProperties
			end

			if v4 == "" then
				newMessageProperties.PrefixText = `<font color="rgb({v5})">{displayName}:</font>`
				return newMessageProperties
			end

			newMessageProperties.PrefixText = `{v4} <font color="rgb({v5})">{displayName}:</font>`
			return newMessageProperties
		end
	end
end

clientAnnouncement.OnClientEvent:Connect(function(value, p: string)
	local rBXGeneral = value and textChannels:WaitForChild("RBXGeneral", 15)

	if rBXGeneral then
		if typeof(value) == "table" then
			local text = value.Text
			local color = value.Color

			if text and color then
				rBXGeneral:DisplaySystemMessage((`<font color="rgb({string.format("%d,%d,%d", color.R * 255, color.G * 255, color.B * 255)})">{text}</font>`))
			end
		elseif typeof(value) == "string" then
			rBXGeneral:DisplaySystemMessage(value)
		end
	end

	if p then
		notification:Fire(p)
	end
end)
Get_Commands() -- equivalent call inferred; original call site unknown
Delete_TeamChannel()
Set_ChannelTabs()
localPlayer:GetPropertyChangedSignal("Team"):Connect(Delete_TeamChannel)
custom_Channels.ChildAdded:Connect(Set_ChannelTabs)
custom_Channels.ChildRemoved:Connect(Set_ChannelTabs)
updateTabs.OnClientEvent:Connect(UpdateTabs_Client)