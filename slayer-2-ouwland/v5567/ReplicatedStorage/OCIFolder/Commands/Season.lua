local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local isServer = RunService:IsServer()
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local SeasonBoards = require(ReplicatedStorage.CAM.Global.SeasonBoards)
local SeasonRewards = require(ReplicatedStorage.CAM.Global.SeasonRewards)
local Titles = require(ReplicatedStorage.CAM.Global.Titles)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local v

if isServer then
	local RankedRecord = require(ServerStorage.SAM.Utility.RankedRecord)
	v = RankedRecord or nil
else
	v = nil
end

local v2

if isServer then
	local SeasonRewardService = require(ServerStorage.SAM.Services.SeasonRewardService)
	v2 = SeasonRewardService or nil
else
	v2 = nil
end

local TitleService = isServer and require(ServerStorage.SAM.Services.TitleService) or nil
local suggester = {}
local v4 = {}
local suggester2 = {
	"Show",
	"Give",
	"Claim",
	"Clear"
}

for _, v6 in { Ranked.Keys(), MinigameSettings.Settings.Ouwigahara.Modes } do
	for k, v7 in v6 do
		if type(k) == "string" then
			v7 = k
		end

		if not SeasonRewards.Pays(v7) then
			continue
		end

		table.insert(suggester, v7)
		v4[v7:lower()] = v7
	end
end

table.sort(suggester)

-- equivalent calls inferred from this helper; original call sites unknown
local function named(items, p)
	local lower = tostring(p):lower()

	for _, item in items do
		if item:lower() == lower then
			return item
		end
	end

	return nil
end

local function word(p: string)
	if p == nil or p == "" then
		return nil
	end

	return p
end

local function madeUp(p: string, userId: number, p2: number?, p3: number?)
	local knobs = SeasonBoards.KindOf(p).Knobs()
	local v6 = knobs.HistogramBuckets - 1
	local top = {}

	for i = 1, 100 do
		local userId2

		if i == p2 then
			userId2 = userId
		else
			userId2 = -i
		end

		local v8 = {
			UserId = userId2,
			Score = p3 == nil and 0 or knobs.HistogramBuckets * knobs.HistogramBucket
		}
		table.insert(top, v8)
	end

	if p3 == nil then
		return {
			Top = top,
			Dist = {}
		}, 0
	end

	local dist = table.create(knobs.HistogramBuckets, 0)
	local v9 = math.ceil(100000 * p3 / 100)
	dist[1] = 100000 - v9
	dist[v6] = v9
	return {
		Top = top,
		Dist = dist
	}, (v6 - 1) * knobs.HistogramBucket
end

local function held(rewards, value: string?)
	local v6

	if value ~= nil then
		v6 = value:lower()
	end

	local v7

	if v6 ~= nil then
		v7 = v4[v6]
	end

	local children = {}

	for _, child in rewards:GetChildren() do
		if not (v6 == nil or child.Name:lower() == v6 or SeasonRewards.BoardOf(child.Name) == v7) then
			continue
		end

		table.insert(children, child)
	end

	return children
end

local function describe(p: string, value: string)
	local board = SeasonRewards.BoardOf(p)
	local decoded, v6, v7 = SeasonRewards.Decode(value)

	if board == nil or decoded == nil or v6 == nil then
		return (`{p}: unreadable "{value}"`)
	end

	local payout = SeasonRewards.Payout(board, decoded, v6)
	local v8 = {}
	local v9 = {}

	for _, v10 in SeasonRewards.PARTS do
		local v11 = payout[v10]

		if v11 == nil then
			continue
		end

		local v12

		if v10 == "Title" or v10 == "Zenith" then
			v12 = Titles.Get(v11)
		end

		local v13

		if v7[v10] then
			v13 = v8
		else
			v13 = v9
		end

		local v15

		if v12 == nil then
			v15 = tostring(v11)
		else
			v15 = `"{v12.displayName}"`
		end

		table.insert(v13, (`{v10} {v15}`))
	end

	return `{p}: {payout.Place} on {payout.Board}{SeasonRewards.Ready(decoded) and "" or " (season not Ready)"}` .. ` | owes {not (#v9 > 0) and "nothing" or table.concat(v9, ", ")}` .. ` | paid {not (#v8 > 0) and "nothing" or table.concat(v8, ", ")}`
end

return {
	Clearance = 6,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = true,
			Suggester = suggester2,
			Completer = function(p: string)
				local lower = tostring(p):lower()

				for _, v7 in suggester2 do
					if v7:lower() == lower then
						return v7
					end
				end

				return nil
			end
		},
		{
			Type = "Board",
			Name = "Board",
			Required = false,
			Suggester = suggester,
			Completer = function(value: string)
				if value == nil or value == "" then
					return nil
				end

				return v4[value:lower()] or value
			end
		},
		{
			Type = "Value",
			Name = "Place",
			Required = false,
			Completer = word
		},
		{
			Type = "Value",
			Name = "Season",
			Required = false,
			Completer = word
		}
	},
	Server = function(p, p2: string, p3: string?, p4: string?, p5: string?)
		local item = named(suggester2, p2) -- equivalent call inferred; original call site unknown

		if item == nil then
			error((`Season: unknown action "{tostring(p2)}" (Show, Give, Claim, Clear)`))
		end

		local _, v8 = Utility.GetData(p)
		local root = v.Root(v8)

		if root == nil then
			error("Season: your data is not loaded")
		end

		local rewards = root.Rewards
		local unlocked = v8.PlayerTitles.Unlocked
		local v9

		if not (p3 == nil or p3 == "") then
			v9 = tostring(p3)
		end

		local v10 = {}

		if item == "Show" then
			for _, child in rewards:GetChildren() do
				table.insert(v10, (describe(child.Name, child.Value)))
			end

			for _, child in unlocked:GetChildren() do
				local v11

				if Titles.Definitions[child.Name] == nil then
					v11 = Titles.Get(child.Name)
				end

				if v11 ~= nil then
					table.insert(v10, (`title "{v11.displayName}" ({v11.rarity})`))
				end
			end

			if #v10 == 0 then
				table.insert(v10, "No season rewards or titles.")
			end
		elseif item == "Give" then
			local v11

			if v9 ~= nil then
				v11 = v4[v9:lower()]
			end

			if v11 == nil then
				error((`Season: "{tostring(v9)}" is no board that pays (1v1, 2v2, 3v3, Tourney:<style>, Normal, Roguelike)`))
			end

			local kind = SeasonBoards.KindOf(v11)
			local lower = tostring(p4):lower()
			local v12 = tonumber(lower)
			local v13 = tonumber(string.match(lower, "^top(%d+%.?%d*)$"))

			if v12 ~= nil and (v12 ~= math.floor(v12) or v12 < 1 or v12 > 100) then
				error("Season: a place is 1-100 (past the first page, top<p>)")
			end

			if v12 == nil and (v13 == nil or v13 > 100 or math.ceil(v13 * 100000 / 100) <= 100) then
				error((`Season: "{tostring(p4)}" is no place: 1-100, or top<p> (top1, top3) for past the first page`))
			end

			local v14

			if p5 == nil or p5 == "" then
				v14 = kind.Number(kind.Season())
			else
				v14 = tonumber(p5)
			end

			if v14 == nil or v14 ~= math.floor(v14) or v14 < 1 then
				error((`Season: "{tostring(p5)}" is no season number (1 = September 2026)`))
			end

			local name = SeasonRewards.Id(v11, v14)

			if rewards:FindFirstChild(name) ~= nil then
				error((`Season: you already hold {name}; "season clear {name}" first`))
			end

			local v16, v17 = madeUp(v11, p.UserId, v12, v13)
			local judge = SeasonRewards.Judge(v11, p.UserId, v17, v16)

			if judge == nil then
				error((`Season: {lower} on {v11} earns nothing`))
			end

			local stringValue = Instance.new("StringValue")
			stringValue.Name = name
			stringValue.Value = SeasonRewards.Encode(v14, judge)
			stringValue.Parent = rewards
			table.insert(v10, "Given " .. describe(name, stringValue.Value))
		elseif item == "Claim" then
			for _, v11 in held(rewards, v9) do
				local claim, v12 = v2.Claim(p, v11.Name)
				local name = v11.Name

				if not claim then
					v12 = `not claimed, {v12}`
				end

				table.insert(v10, (`{name}: {v12}`))
			end

			if #v10 == 0 then
				table.insert(v10, (`No season reward to claim{v9 == nil and "" or ` for {v9}`}.`))
			end
		else
			local v11 = {}

			for _, v12 in held(rewards, v9) do
				local board = SeasonRewards.BoardOf(v12.Name)
				local decoded, v13 = SeasonRewards.Decode(v12.Value)
				local v14

				if not (board == nil or decoded == nil or v13 == nil) then
					v14 = SeasonRewards.Payout(board, decoded, v13)
				end

				if v14 ~= nil and v14.Title ~= nil then
					table.insert(v11, v14.Title)
				end

				if v14 ~= nil and v14.Zenith ~= nil then
					table.insert(v11, v14.Zenith)
				end

				table.insert(v10, (`Removed {v12.Name}`))
				v12:Destroy()
			end

			if v9 == nil then
				for _, child in unlocked:GetChildren() do
					if not (Titles.Definitions[child.Name] == nil and Titles.Get(child.Name) ~= nil) then
						continue
					end

					table.insert(v11, child.Name)
				end
			end

			for _, childName in v11 do
				if unlocked:FindFirstChild(childName) == nil then
					continue
				end

				local _, v12 = TitleService.Lock(p, childName)
				table.insert(v10, v12)
			end

			if #v10 == 0 then
				table.insert(v10, (`Nothing to remove{v9 == nil and "" or ` for {v9}`}.`))
			end
		end

		return {
			Content = table.concat(v10, "\n"),
			BgColor = Color3.fromRGB(32, 143, 70),
			FgColor = Color3.new(1, 1, 1)
		}
	end
}