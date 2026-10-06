local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rankedPlayers = ReplicatedStorage:WaitForChild("RankedPlayers", 20) or Instance.new("Folder")
local TitleModule = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").TitleModule)
local TitleColorModule = require(ReplicatedStorage.Chest.Modules.TitleModule.TitleColorModule)
local _ = {
	Color3.fromRGB(231, 208, 42),
	Color3.fromRGB(176, 169, 151),
	Color3.fromRGB(183, 140, 61),
	Color3.fromRGB(243, 97, 142),
	Color3.fromRGB(229, 62, 73),
	Color3.fromRGB(231, 148, 33),
	Color3.fromRGB(123, 191, 62),
	Color3.fromRGB(39, 165, 127),
	Color3.fromRGB(131, 187, 226),
	Color3.fromRGB(120, 147, 196)
}

function GenerateTextSystem(data)
	return ("<font color='#" .. (data.Color and data.Color:ToHex() or Color3.fromRGB(255, 255, 255):ToHex()) .. "'>") .. ("<font face='" .. (data.Font or "Gotham") .. "'>") .. ("<font size='" .. (data.FontSize or "18") .. "'>") .. data.Text .. "</font></font></font>"
end

task.spawn(function()
	local TipsTable = require(ReplicatedStorage.Chest.Modules.TipsTable)
	local v = nil

	while wait(1200) do
		local v2 = TipsTable[math.random(1, #TipsTable)]

		if v2 == v then
			repeat
				v2 = TipsTable[math.random(1, #TipsTable)]
			until v2 ~= v
		end

		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(GenerateTextSystem({
			Text = "<font color='#00aa00'>[Tip]</font> " .. v2,
			Font = "SourceSansSemibold",
			Color = Color3.fromRGB(255, 255, 255),
			FontSize = 18
		}))
		v = v2
	end
end)

TextChatService.OnIncomingMessage = function(data)
	if not data.TextSource then
		return
	end

	local textChatMessageProperties = Instance.new("TextChatMessageProperties")
	local prefixText = data.PrefixText
	local playerByUserId = game.Players:GetPlayerByUserId(data.TextSource.UserId)

	if not playerByUserId then
		return
	end

	local race = nil
	local raceAppearance = nil
	local value = ""
	local value2 = ""

	if playerByUserId:FindFirstChild("PlayerStats") then
		local title = playerByUserId.PlayerStats:FindFirstChild("Title")
		local titleColor = playerByUserId.PlayerStats:FindFirstChild("TitleColor")

		if title then
			value = title.Value
		end

		if titleColor then
			value2 = titleColor.Value
		end
	end

	if playerByUserId.Character then
		race = playerByUserId.Character:GetAttribute("Race")
		raceAppearance = playerByUserId.Character:GetAttribute("RaceAppearance")
	end

	local v = "#" .. Color3.fromRGB(255, 255, 255):ToHex()

	if TitleColorModule[value2] and TitleColorModule[value2].Color then
		v = "#" .. tostring(TitleColorModule[value2].Color:ToHex())
	end

	if TitleModule[value] and TitleModule[value].Color then
		v = "#" .. tostring(TitleModule[value].Color:ToHex())
	end

	local v2 = "<font color='" .. v .. "'>[" .. value .. "]</font> "
	local child = rankedPlayers:FindFirstChild(playerByUserId.Name)
	textChatMessageProperties.PrefixText = (not child and "" or "<font color='" .. "#fff260" .. "'>#" .. child:GetAttribute("Rank") .. "</font> ") .. v2 .. "<font color='#01a2ff'>" .. prefixText .. "</font>"

	if _G.CheckSettingClient(playerByUserId, "Setting_HideRaceAppearance") then
		return textChatMessageProperties
	end

	if race == "Mink" then
		if raceAppearance == 1 then
			textChatMessageProperties.Text = data.Text .. " Bun!"
			return textChatMessageProperties
		elseif raceAppearance == 2 then
			textChatMessageProperties.Text = data.Text .. " Woof!"
			return textChatMessageProperties
		elseif raceAppearance == 3 then
			textChatMessageProperties.Text = data.Text .. " Moo!"
			return textChatMessageProperties
		elseif raceAppearance == 4 then
			textChatMessageProperties.Text = data.Text .. " Meow!"
			return textChatMessageProperties
		end
	elseif race == "Fish" then
		textChatMessageProperties.Text = data.Text .. " Fin."
	end

	return textChatMessageProperties
end