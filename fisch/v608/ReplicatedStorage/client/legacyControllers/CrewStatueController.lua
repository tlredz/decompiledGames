local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local remoteFunction = Net:RemoteFunction("Crew/GetStatueBoards")
local remoteEvent = Net:RemoteEvent("Crew/StatueRefresh")
local color = Color3.fromRGB(255, 255, 255)
local v = {
	{ 1000, "K" },
	{ 1000000, "M" },
	{ 1000000000, "B" },
	{ 1000000000000, "T" }
}
local v2 = { Color3.fromRGB(255, 250, 106), Color3.fromRGB(148, 250, 255), Color3.fromRGB(241, 141, 87) }
local color2 = Color3.fromRGB(255, 255, 255)
local v3 = {
	Catches = "MOST CATCHES",
	RarestCatch = "RAREST CATCH",
	CrewRating = "CREW RATING",
	BiggestFish = "BIGGEST FISH"
}
local v4 = {}
local v5 = {}
local flag = false
local placement = script:FindFirstChild("placement")

local function comma(p: number)
	local v6 = tostring((math.floor(p)))
	local v7 = 1

	while v7 > 0 do
		v6, v7 = v6:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	end

	return v6
end

local function seasonEndsAt()
	local v6 = os.date("!*t")
	local year = v6.year
	local v7 = v6.month + 1

	if v7 > 12 then
		year += 1
		v7 = 1
	end

	return DateTime.fromUniversalTime(year, v7, 1).UnixTimestamp
end

local function formatCountdown(p: number)
	if p <= 0 then
		return "0m"
	end

	local v6 = math.floor(p / 86400)
	local v7 = math.floor(p % 86400 / 3600)
	local v8 = math.floor(p % 3600 / 60)

	if v6 > 0 then
		return (`{v6}d {v7}h`)
	end

	if v7 > 0 then
		return (`{v7}h {v8}m`)
	end

	return (`{v8}m {math.floor(p % 60)}s`)
end

local function isActive(p)
	return v4[p.Model] == p and p.Model:IsDescendantOf(game)
end

local function streamWait(p, instance, childName: string, flag2: boolean?)
	local child = instance:FindFirstChild(childName)
	local count = 0

	while not child and count < 6 do
		local v6

		if v4[p.Model] == p then
			v6 = p.Model:IsDescendantOf(game)
		else
			v6 = false
		end

		if not v6 then
			return nil
		end

		count += 1
		child = instance:WaitForChild(childName, 5)
	end

	if child or flag2 then
		return child
	end

	local v6

	if v4[p.Model] == p then
		v6 = p.Model:IsDescendantOf(game)
	else
		v6 = false
	end

	if v6 then
		warn((`[CrewStatueController] gave up waiting for "{childName}" under {instance:GetFullName()}`))
	end

	return child
end

local function streamWaitClass(p, instance, className: string)
	local firstChildOfClass = instance:FindFirstChildOfClass(className)
	local v6 = os.clock() + 30

	while not firstChildOfClass and os.clock() < v6 do
		local v7

		if v4[p.Model] == p then
			v7 = p.Model:IsDescendantOf(game)
		else
			v7 = false
		end

		if not v7 then
			return nil
		end

		task.wait(0.25)
		firstChildOfClass = instance:FindFirstChildOfClass(className)
	end

	if firstChildOfClass then
		return firstChildOfClass
	end

	local v7

	if v4[p.Model] == p then
		v7 = p.Model:IsDescendantOf(game)
	else
		v7 = false
	end

	if v7 then
		warn((`[CrewStatueController] gave up waiting for a {className} under {instance:GetFullName()}`))
	end

	return firstChildOfClass
end

local function formatOdds(chance: number)
	local v6 = 100 / chance

	if v6 < 1000 then
		return (`1/{math.floor(v6)}`)
	end

	for _, v7 in v do
		if v6 < v7[1] * 1000 then
			return (`1/{math.floor(v6 / v7[1] * 10) / 10}{v7[2]}`)
		end
	end

	return (`1/{math.floor(v6 / 1000000000000 * 10) / 10}T`)
end

local function statText(boardId: string, data)
	if boardId == "RarestCatch" then
		local rarity = rarities.Rarities[data.Rarity or ""]
		local color3 = rarity and rarity.Color or color

		if typeof(data.Chance) == "number" and data.Chance > 0 then
			return formatOdds(data.Chance), color3
		end

		if data.Fish and data.Fish ~= "" then
			return data.Fish, color3
		end

		return "-", color3
	elseif boardId == "BiggestFish" then
		local v6

		if typeof(data.Weight) == "number" then
			v6 = data.Weight
		else
			v6 = data.Score / 10
		end

		local v7 = tostring((math.floor(v6)))
		local v8 = 1

		while v8 > 0 do
			v7, v8 = v7:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		end

		return `{v7}kg`, color
	else
		local score = tostring((math.floor(data.Score or 0)))
		local v6 = 1

		while v6 > 0 do
			score, v6 = score:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		end

		return score, color
	end
end

local function clearRows(p)
	for i = #p.Rows, 1, -1 do
		p.Rows[i].Placement:Destroy()
		p.Rows[i] = nil
	end
end

local function ensureRows(data, p: number)
	local container = data.Container

	if not (container and placement) then
		return
	end

	for i = #data.Rows + 1, p do
		local clone = placement:Clone()
		local name = clone:FindFirstChild("name")
		local pos = clone:FindFirstChild("pos")
		local stat = clone:FindFirstChild("stat")

		if name and pos and stat then
			clone.Name = `placement{i}`
			clone.LayoutOrder = i
			clone.Visible = true
			clone.Parent = container
			data.Rows[i] = {
				Placement = clone,
				Name = name,
				Pos = pos,
				Stat = stat,
				BaseWeight = name.FontFace.Weight
			}
		else
			clone:Destroy()
			warn((`[CrewStatueController] {placement:GetFullName()} is missing name/pos/stat`))
			return
		end
	end

	for i = #data.Rows, p + 1, -1 do
		data.Rows[i].Placement:Destroy()
		data.Rows[i] = nil
	end
end

local function renderStatue(data)
	if not data.Ready then
		return
	end

	local v6 = v5[data.BoardId] or {}

	if data.Title then
		data.Title.Text = v3[data.BoardId] or data.BoardId
	end

	ensureRows(data, math.clamp(#v6, 3, 50))

	for i = 1, #data.Rows do
		local row = data.Rows[i]
		local v7 = v6[i]
		row.Pos.Text = `#{i}`
		row.Pos.TextColor3 = v2[i] or color2
		local fontFace = row.Name.FontFace
		local weight

		if i == 1 then
			weight = Enum.FontWeight.Bold
		else
			weight = row.BaseWeight
		end

		fontFace.Weight = weight
		row.Name.FontFace = fontFace
		row.Name.TextColor3 = row.Pos.TextColor3

		if v7 then
			row.Name.Text = v7.Name or "---"
			local text, textColor = statText(data.BoardId, v7)
			row.Stat.Text = text
			row.Stat.TextColor3 = textColor
		else
			row.Name.Text = "---"
			row.Stat.Text = "-"
			row.Stat.TextColor3 = color
		end
	end
end

local function buildCountdown(p)
	local v6 = streamWait(p, p.Model, "Timer", true)

	if not v6 then
		return
	end

	local v7 = streamWait(p, v6, "Header", true)

	if not v7 then
		return
	end

	local countdown = streamWait(p, v7, "Countdown", true)

	if countdown then
		local v9

		if v4[p.Model] == p then
			v9 = p.Model:IsDescendantOf(game)
		else
			v9 = false
		end

		if v9 then
			p.Countdown = countdown
		end
	end
end

local function buildStatue(p)
	local v6 = streamWait(p, p.Model, "Screen")

	if not v6 then
		return
	end

	local v7 = streamWaitClass(p, v6, "SurfaceGui")

	if not v7 then
		return
	end

	local v8 = streamWait(p, v7, "safezone")

	if not v8 then
		return
	end

	local container = streamWait(p, v8, "ScrollingFrame")

	if not container then
		return
	end

	local v10

	if v4[p.Model] == p then
		v10 = p.Model:IsDescendantOf(game)
	else
		v10 = false
	end

	if not v10 then
		return
	end

	p.Container = container
	p.Title = v8:FindFirstChild("title")
	p.Ready = true
	renderStatue(p)
	task.spawn(buildCountdown, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unregisterStatue(p)
	local v6 = v4[p]

	if not v6 then
		return
	end

	v4[p] = nil
	v6.Ready = false
	clearRows(v6)
	v6.Container = nil
	v6.Title = nil
	v6.Countdown = nil
	v6.Trove:Destroy()
end

local function registerStatue(instance)
	if v4[instance] then
		return
	end

	local boardType = instance:GetAttribute("BoardType")

	if typeof(boardType) ~= "string" or not v3[boardType] then
		warn((`[CrewStatueController] "{instance:GetFullName()}" has no valid BoardType attribute`))
		return
	end

	local v6 = {
		Model = instance,
		BoardId = boardType,
		Container = nil,
		Rows = {},
		Title = nil,
		Countdown = nil,
		Ready = false,
		Trove = Trove.new()
	}
	v4[instance] = v6
	v6.Trove:Connect(instance.Destroying, function()
		unregisterStatue(instance) -- equivalent call inferred; original call site unknown
	end)
	task.spawn(buildStatue, v6)
end

local function refresh()
	if flag then
		return true
	end

	flag = true
	local success, result = pcall(function()
		return remoteFunction:InvokeServer()
	end)
	flag = false

	if not success or typeof(result) ~= "table" then
		return false
	end

	v5 = result

	for _, v6 in v4 do
		renderStatue(v6)
	end

	return true
end

return {
	Start = function()
		if not placement then
			warn((`[CrewStatueController] missing the "placement" template under {script:GetFullName()}`))
			return
		end

		for _, v6 in CollectionService:GetTagged("CrewLeaderboardStatue") do
			registerStatue(v6)
		end

		CollectionService:GetInstanceAddedSignal("CrewLeaderboardStatue"):Connect(registerStatue)
		CollectionService:GetInstanceRemovedSignal("CrewLeaderboardStatue"):Connect(unregisterStatue)
		remoteEvent.OnClientEvent:Connect(function()
			task.spawn(refresh)
		end)
		task.spawn(function()
			while true do
				local v6 = refresh()
				task.wait(v6 and 60 or 10)
			end
		end)
		task.spawn(function()
			while true do
				local v6 = os.date("!*t")
				local year = v6.year
				local v7 = v6.month + 1

				if v7 > 12 then
					year += 1
					v7 = 1
				end

				local text = formatCountdown(DateTime.fromUniversalTime(year, v7, 1).UnixTimestamp - os.time())

				for _, v10 in v4 do
					if v10.Ready and v10.Countdown then
						v10.Countdown.Text = text
					end
				end

				task.wait(1)
			end
		end)
	end
}