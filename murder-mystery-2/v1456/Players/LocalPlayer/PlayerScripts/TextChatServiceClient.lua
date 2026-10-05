local TextChatService = game:GetService("TextChatService")

if TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService then
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local CurrentRoundClient = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("CurrentRoundClient"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage3:WaitForChild("Remotes")
local v = game.GameId == 119460199
local replicatedStorage = game.ReplicatedStorage
local TextChatService2 = game:GetService("TextChatService")
local TextChatService3 = game:GetService("TextChatService")
local localPlayer = game.Players.LocalPlayer
local players = game.Players
local rBXSystem = TextChatService3:WaitForChild("TextChannels"):WaitForChild("RBXSystem")
TextChatService3:WaitForChild("ChatInputBarConfiguration")
local systemMessage = script:WaitForChild("SystemMessage")
local TextChatService4 = game:GetService("TextChatService")
local chromaCommad = TextChatService4:WaitForChild("ChromaCommad")
local _ = Sync.Item
local rarity = Sync.Rarity

local function amInChannel(instance)
	return instance:FindFirstChild(localPlayer.Name)
end

local function isPlayerAlive(instance)
	if instance == nil or not instance:IsDescendantOf(players) or CurrentRoundClient.PlayerData[instance.Name] == nil then
		return false
	end

	return CurrentRoundClient.PlayerData[instance.Name].Dead ~= true
end

local function getDisguiseName(instance)
	if instance == nil or not instance:IsDescendantOf(players) or CurrentRoundClient.PlayerData[instance.Name] == nil then
		return nil
	end

	return CurrentRoundClient.PlayerData[instance.Name].CodeName
end

local function getDisguiseColor(instance)
	if instance == nil or not instance:IsDescendantOf(players) or CurrentRoundClient.PlayerData[instance.Name] == nil then
		return nil
	end

	local color = CurrentRoundClient.PlayerData[instance.Name].Color
	return not color and "ffffff" or color.Color:ToHex()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPlayerDead(instance)
	return instance == nil or not instance:IsDescendantOf(players) or CurrentRoundClient.PlayerData[instance.Name] == nil or CurrentRoundClient.PlayerData[instance.Name].Dead == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorText(p, p2)
	return "<font color='#" .. p2 .. "'>" .. p .. "</font>"
end

local function getChromaTag()
	return ("<font color='#" .. Color3.fromRGB(255, 0, 0):ToHex() .. "'>C</font>") .. ("<font color='#" .. Color3.fromRGB(
		255,
		100,
		0
	):ToHex() .. "'>h</font>") .. ("<font color='#" .. Color3.fromRGB(255, 225, 0):ToHex() .. "'>r</font>") .. ("<font color='#" .. Color3.fromRGB(
		0,
		255,
		0
	):ToHex() .. "'>o</font>") .. ("<font color='#" .. Color3.fromRGB(0, 255, 255):ToHex() .. "'>m</font>") .. ("<font color='#" .. Color3.fromRGB(
		0,
		125,
		255
	):ToHex() .. "'>a</font>") .. " "
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWhisper(p)
	return string.sub(p.Name, 1, 10) == "RBXWhisper"
end

TextChatService3.OnIncomingMessage = function(self)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")

	if not self.TextSource then
		return textChatMessageProperties
	end

	if self.TextSource.UserId == game.Players.LocalPlayer.UserId and isWhisper(self.TextChannel) then
		local v2 = string.split(string.sub(self.TextChannel.Name, 12), "_")
		local playerByUserId = game.Players:GetPlayerByUserId(v2[1])
		local playerByUserId2 = game.Players:GetPlayerByUserId(v2[2])
		local v3

		if playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil then
			v3 = false
		else
			v3 = CurrentRoundClient.PlayerData[playerByUserId.Name].Dead ~= true
		end

		local v4, v5

		if v3 then
			v4 = isPlayerDead(playerByUserId2)

			if not v4 then
				if playerByUserId2 == nil or not playerByUserId2:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId2.Name] == nil then
					v4 = false
				else
					v4 = CurrentRoundClient.PlayerData[playerByUserId2.Name].Dead ~= true
				end

				if v4 then
					if playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil then
						v5 = false
					else
						v5 = CurrentRoundClient.PlayerData[playerByUserId.Name].Dead ~= true
					end

					v4 = not v5
				end
			end
		else
			if playerByUserId2 == nil or not playerByUserId2:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId2.Name] == nil then
				v4 = false
			else
				v4 = CurrentRoundClient.PlayerData[playerByUserId2.Name].Dead ~= true
			end

			if v4 then
				if playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil then
					v5 = false
				else
					v5 = CurrentRoundClient.PlayerData[playerByUserId.Name].Dead ~= true
				end

				v4 = not v5
			end
		end

		if v4 then
			systemMessage:Fire({
				text = "You cannot whisper remaining players while eliminated."
			})
			self.Status = Enum.TextChatMessageStatus.InvalidTextChannelPermissions
			return textChatMessageProperties
		end
	end

	local playerByUserId = players:GetPlayerByUserId(self.TextSource.UserId)

	if not playerByUserId then
		return textChatMessageProperties
	end

	local v2

	if playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil then
		v2 = false
	else
		v2 = CurrentRoundClient.PlayerData[playerByUserId.Name].Dead ~= true
	end

	local elite = playerByUserId:GetAttribute("Elite")
	local name = playerByUserId.Name
	local codeName

	if not (playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil) then
		codeName = CurrentRoundClient.PlayerData[playerByUserId.Name].CodeName
	end

	if codeName then
		if v2 then
			name = codeName
		else
			name ..= " (" .. codeName .. ")"
		end
	end

	self.PrefixText = name .. ":"
	local v3 = "ffffff"
	local v4 = "a3a2a5"

	if codeName then
		if playerByUserId == nil or not playerByUserId:IsDescendantOf(players) or CurrentRoundClient.PlayerData[playerByUserId.Name] == nil then
			v3 = nil
		else
			local color = CurrentRoundClient.PlayerData[playerByUserId.Name].Color
			v3 = not color and "ffffff" or color.Color:ToHex()
		end
	elseif elite then
		self.PrefixText = "[ELITE] " .. self.PrefixText
		v3 = "e82a2a"
		v4 = "bf5f5f"
	end

	if v2 then
		self.PrefixText = colorText(self.PrefixText, v3)
		return textChatMessageProperties
	end

	self.PrefixText = colorText(self.PrefixText, v4)
	return textChatMessageProperties
end

local function getColoredItemText(item)
	local v2 = Sync.Item[item] or Sync.Pets[item]

	if not v2 then
		warn("ItemData not found for: " .. tostring(item))
		return item
	end

	local hex = rarity[v2.Rarity]:ToHex()
	local itemName = v2.ItemName or v2.Name
	return (v2.Chroma and getChromaTag() or "") .. colorText(itemName, hex)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function replicateMessage(p)
	local text = p.text

	if p.item then
		text ..= " " .. getColoredItemText(p.item)
	end

	rBXSystem:DisplaySystemMessage(text)
end

chromaCommad.Triggered:Connect(function()
	game.Players.LocalPlayer.PlayerScripts.WeaponVisuals.ChromaScript.ToggleChromas:Fire()
end)
systemMessage.Event:Connect(function(p)
	task.defer(function()
		replicateMessage(p) -- equivalent call inferred; original call site unknown
	end)
end)
replicatedStorage.ChatMessage.OnClientEvent:Connect(replicateMessage)
local v2 = remotes:WaitForChild("Extras"):WaitForChild("GetAvailableCommands"):InvokeServer()

for _, childName in v2 do
	local child = TextChatService2:WaitForChild(childName)

	if child:GetAttribute("TestingServerCommand") == true and not v then
		child.Enabled = false
		child.AutocompleteVisible = false
		continue
	end

	child.AutocompleteVisible = true
	child.Enabled = true
end