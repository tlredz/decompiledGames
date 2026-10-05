local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
require(ReplicatedStorage.client.legacyControllers.WorldController)
local titles = require(ReplicatedStorage.shared.modules:WaitForChild("character"):WaitForChild("titles"))
local animatedgradient = require(ReplicatedStorage.shared.modules:WaitForChild("fx"):WaitForChild("animatedgradient"))
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local chatWindowConfiguration = TextChatService.ChatWindowConfiguration
local v = {}
local v2 = {
	["caught an exotic"] = animatedgradient._presets.Rainbow,
	["caught a secret"] = animatedgradient._presets.Secret,
	["caught a special"] = animatedgradient._presets.Special,
	["caught a cataclysmic"] = animatedgradient._presets.Cataclysmic,
	["caught a divine secret"] = animatedgradient._presets["Divine Secret"]
}

local function toHex(color: Color3)
	return "#" .. color:ToHex()
end

local function printDebug(...)
	if ReplicatedStorage:GetAttribute("DebugChat") then
		print(`[{script.Name}]`, ...)
	end
end

function TextChatService:OnChatWindowAdded()
	if not script.Parent then
		return
	end

	printDebug("received:", self.Text)
	local result = chatWindowConfiguration:DeriveNewMessageProperties()

	if self.TextSource then
		local playerByUserId = Players:GetPlayerByUserId(self.TextSource.UserId)
		local v3 = legacyLocalPlayerData.forPublicPlayer(playerByUserId, 1)
		printDebug("loaded data:", self.Text)

		if v3 then
			local title = v3:GetAttribute("title")
			local v4 = nil
			local v5 = title == "Custom"

			if v5 then
				local title_text = v3:GetAttribute("title_text")
				v4 = title_text and title_text ~= "" and {
					Text = title_text,
					TextColor = v3:GetAttribute("title_textColor") or Color3.new(1, 1, 1),
					StrokeColor = v3:GetAttribute("title_strokeColor") or Color3.new(0, 0, 0),
					Bold = true
				} or v4
			elseif title and titles[title] then
				v4 = titles[title]
			end

			if v4 and v4.Text ~= "" then
				if not v5 then
					local v6 = {
						name = playerByUserId.DisplayName
					}
					v4.Text = v4.Text:gsub("{(%a+)}", v6)
				end

				local text

				if v5 then
					text = `&lt;{v4.Text}&gt;`
				elseif v4.HideBrackets then
					text = v4.Text
				else
					text = `[{v4.Text}]`
				end

				if v4.CustomFont then
					local customFont = v4.CustomFont
					text = `<font family="{customFont.Family}" weight="{customFont.Weight.Value}">{text}</font>`
				end

				if v4.Bold then
					text = `<b>{text}</b>`
				end

				if v4.Italic then
					text = `<i>{text}</i>`
				end

				local prefixText = text .. " " .. self.PrefixText
				local v7 = false

				if typeof(v4.TextColor) == "Color3" then
					prefixText = `<font color="#{v4.TextColor:ToHex()}">{prefixText}</font>`
				else
					local uIGradient = Instance.new("UIGradient")
					uIGradient.Color = v4.TextColor

					if v4.GradientRotation then
						uIGradient.Rotation = v4.GradientRotation
					end

					result.PrefixTextProperties = chatWindowConfiguration:DeriveNewMessageProperties()
					v7 = true
					uIGradient.Parent = result.PrefixTextProperties
				end

				if v4.Shadow then
					local uIShadow = Instance.new("UIShadow")

					for k, v8 in v4.Shadow do
						uIShadow[k] = v8
					end

					if not v7 then
						result.PrefixTextProperties = chatWindowConfiguration:DeriveNewMessageProperties()
					end

					uIShadow.Parent = result
				end

				result.PrefixText = prefixText

				local function getFormattedStat(p, p2)
					local attribute = playerByUserId:GetAttribute((`lb_{p}`))

					if attribute then
						return "<font color ='" .. p2 .. "'>[#" .. attribute .. "]</font> "
					end

					return ""
				end

				local lb_coins = playerByUserId:GetAttribute("lb_coins")
				local v8 = not lb_coins and "" or "<font color ='" .. "#ffff8a" .. "'>[#" .. lb_coins .. "]</font> "
				local lb_tracker_fishcaught = playerByUserId:GetAttribute("lb_tracker_fishcaught")
				local v9 = not lb_tracker_fishcaught and "" or "<font color ='" .. "#79ffe4" .. "'>[#" .. lb_tracker_fishcaught .. "]</font> "
				local lb_tracker_timeplayed = playerByUserId:GetAttribute("lb_tracker_timeplayed")
				local v10 = not lb_tracker_timeplayed and "" or "<font color ='" .. "#5effa6" .. "'>[#" .. lb_tracker_timeplayed .. "]</font> "
				local lb_tracker_anglerquests = playerByUserId:GetAttribute("lb_tracker_anglerquests")
				result.PrefixText = v8 .. v9 .. v10 .. (not lb_tracker_anglerquests and "" or "<font color ='" .. "#ff6a6a" .. "'>[#" .. lb_tracker_anglerquests .. "]</font> ") .. result.PrefixText
				printDebug("applied prefixes:", self.Text)
				return result
			end
		end
	else
		local text = string.lower(self.Text)

		if string.find(text, "r15") then
			result.Text = ""
			self.Text = ""
		else
			for k, v4 in pairs(v2) do
				if not string.find(text, k, 1, true) then
					continue
				end

				local v5 = animatedgradient.new(v4, true)

				if script.Parent then
					v5.Parent = result
				end

				result.PrefixTextProperties = result
				result.PrefixText = self.Text
				result.Text = ""
				self.Text = "."
				break
			end
		end

		printDebug("displaying as system:", self.Text)
		return result
	end
end

RunService.RenderStepped:Connect(function(dt)
	for k, v3 in v do
		v3.Offset = Vector2.new(v3.Offset.X + 1 * dt, 0)

		if v3.Offset.X >= 1 then
			v3.Rotation = v3.Rotation == 180 and 0 or 180
			v3.Offset = Vector2.new(-1, 0)
		end

		if v3.Parent then
			continue
		end

		table.remove(v, k)
		v3:Destroy()
	end

	for _, v3 in CollectionService:GetTagged("AnimatedGradient") do
		local animationSpeed = v3:GetAttribute("AnimationSpeed") or 1
		v3.Offset = Vector2.new(v3.Offset.X + animationSpeed * dt, 0)

		if not (v3.Offset.X >= 1) then
			continue
		end

		v3.Rotation = v3.Rotation == 180 and 0 or 180
		v3.Offset = Vector2.new(-1, 0)
	end
end)