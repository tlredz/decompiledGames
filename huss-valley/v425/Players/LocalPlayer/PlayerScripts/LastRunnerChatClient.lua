local TextChatService = game:GetService("TextChatService")
local lastRunnerChatEvent = game.ReplicatedStorage.ChickenOrHero.Game:WaitForChild("LastRunnerChatEvent")
local rBXGeneral = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
local v = {
	Color3.fromRGB(253, 41, 67),
	Color3.fromRGB(1, 162, 255),
	Color3.fromRGB(2, 184, 87),
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color
}

local function nameColor(username)
	local total = 0

	for i = 1, #username do
		local v2 = string.byte(username, i)
		local v3 = #username - i + 1

		if #username % 2 == 1 then
			v3 -= 1
		end

		if v3 % 4 >= 2 then
			v2 = -v2
		end

		total += v2
	end

	return v[total % #v + 1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function escape(value)
	return value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;")
end

local v2 = {}
lastRunnerChatEvent.OnClientEvent:Connect(function(data)
	if game.Players.LocalPlayer:GetAttribute("ChatNotificationsEnabled") == false then
		return
	end

	if type(data) ~= "table" or type(data.id) ~= "string" or v2[data.id] or type(data.displayName) ~= "string" or type(data.username) ~= "string" or type(data.chasers) ~= "number" or data.chasers < 1 or data.chasers > 100 or data.chasers % 1 ~= 0 then
		return
	end

	v2[data.id] = os.clock()

	for k, v3 in v2 do
		if os.clock() - v3 > 300 then
			v2[k] = nil
		end
	end

	local v3 = nameColor(data.username)
	local color = Color3.new(v3.R * 0.7, v3.G * 0.7, v3.B * 0.7)
	local v4 = escape(data.displayName) -- equivalent call inferred; original call site unknown
	local v5 = escape(data.username) -- equivalent call inferred; original call site unknown
	local chasers = math.floor(data.chasers)
	rBXGeneral:DisplaySystemMessage(
		string.format(
			"<font color=\"#%s\">%s</font> <font color=\"#%s\">(%s)</font> <font color=\"#FFFF00\">was the last runner standing and crossed against %d %s!</font>",
			v3:ToHex(),
			v4,
			color:ToHex(),
			v5,
			chasers,
			chasers == 1 and "chaser" or "chasers"
		),
		"LastRunnerCrossing"
	)
end)