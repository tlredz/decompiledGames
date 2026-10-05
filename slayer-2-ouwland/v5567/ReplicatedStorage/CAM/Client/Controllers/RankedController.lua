local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local SeasonBoards = require(ReplicatedStorage.CAM.Global.SeasonBoards)
local SeasonRewards = require(ReplicatedStorage.CAM.Global.SeasonRewards)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local RankedController = {
	BoardReceived = simplesignal.new(),
	ResultReceived = simplesignal.new(),
	PageChanged = simplesignal.new()
}

function RankedController.handleBoard(data)
	if type(data) ~= "table" then
		return
	end

	if typeof(data.Key) == "string" and typeof(data.Top) == "table" then
		v2[data.Key] = nil
		v[data.Key] = {
			Top = data.Top,
			Distribution = data.Distribution,
			Season = Ranked.Season(),
			At = os.clock()
		}
		RankedController.PageChanged:Fire(data.Key)
	end

	RankedController.BoardReceived:Fire(data)
end

function RankedController.handleResult(p)
	if type(p) ~= "table" then
		return
	end

	RankedController.ResultReceived:Fire(p)
end

function RankedController.RequestBoard(p: string)
	SignalEvent.ToServer("RankedRequest", {
		action = "Board",
		key = p
	})
end

function RankedController.Page(p: string)
	local v3 = v[p]

	if v3 == nil or v3.Season ~= Ranked.Season() then
		return nil
	end

	return v3
end

function RankedController.Fetch(p: string)
	if not RunService:IsRunning() then
		return
	end

	local page = RankedController.Page(p)

	if page ~= nil and os.clock() - page.At < 300 or v2[p] then
		return
	end

	v2[p] = true
	local count = 0
	local ask

	ask = function()
		if not v2[p] or count >= 5 then
			v2[p] = nil
			return
		end

		count += 1
		RankedController.RequestBoard(p)
		task.delay(3, ask)
	end

	if v2[p] and not (count >= 5) then
		count += 1
		RankedController.RequestBoard(p)
		task.delay(3, ask)
	else
		v2[p] = nil
	end
end

function RankedController.Mine(p: string)
	local kind = SeasonBoards.KindOf(p)
	local _, v3 = Utility.GetData(localPlayer)
	local ranked

	if v3 ~= nil then
		ranked = v3:FindFirstChild("Ranked")
	end

	if kind == nil or ranked == nil then
		return nil
	end

	return kind.Mine(ranked, p)
end

function RankedController.Standing(p: string)
	local kind = SeasonBoards.KindOf(p)
	local mine = RankedController.Mine(p)

	if kind == nil or mine == nil then
		return 0, 0
	end

	local page = RankedController.Page(p)

	if page == nil then
		local _, v3 = Utility.GetData(localPlayer)
		local ranked

		if v3 ~= nil then
			ranked = v3:FindFirstChild("Ranked")
		end

		if ranked == nil then
			return 0, 0
		end

		return kind.Saved(ranked, p)
	else
		local v3 = 0

		for k, v5 in page.Top do
			if v5.UserId ~= localPlayer.UserId then
				continue
			end

			v3 = k
			break
		end

		if page.Distribution == nil then
			return v3, 0
		end

		return v3, Ranked.Rules.ShareAbove(kind.Knobs(), page.Distribution, mine) or 0
	end
end

function RankedController.Icon(p: string)
	local mine = RankedController.Mine(p)

	if mine == nil then
		return nil
	end

	return (Ranked.IconOf(mine))
end

function RankedController.Claim(p: string)
	SignalEvent.ToServer("RankedRequest", {
		action = "Claim",
		key = p
	})
end

function RankedController.KeyFor(p: string)
	if p ~= Ranked.TOURNEY then
		return p
	end

	local bucket = Ranked.BucketOf(Utility.GetData(localPlayer))

	if bucket == nil then
		return nil
	end

	return (Ranked.KeyFor(p, bucket))
end

function RankedController.Rewards()
	local result = {}
	local _, v3 = Utility.GetData(localPlayer)
	local ranked

	if v3 ~= nil then
		ranked = v3:FindFirstChild("Ranked")
	end

	local rewards

	if ranked ~= nil then
		rewards = ranked:FindFirstChild("Rewards")
	end

	for _, v4 in rewards == nil and {} or rewards:GetChildren() do
		local board = SeasonRewards.BoardOf(v4.Name)
		local decoded, award, v6 = SeasonRewards.Decode(v4.Value)

		if not (board ~= nil and decoded ~= nil and award ~= nil) then
			continue
		end

		local owed = SeasonRewards.Owed(SeasonRewards.Payout(board, decoded, award), v6)

		if owed ~= nil then
			table.insert(result, {
				Id = v4.Name,
				Board = board,
				Season = decoded,
				Award = award,
				Owed = owed
			})
		end
	end

	table.sort(result, function(a, b)
		if a.Season == b.Season then
			return a.Board < b.Board
		end

		return a.Season < b.Season
	end)
	return result
end

function RankedController.Pending(p: string)
	for _, v3 in RankedController.Rewards() do
		if SeasonRewards.GroupOf(v3.Board) == SeasonRewards.GroupOf(p) then
			return v3.Season, v3.Award
		end
	end

	return nil, nil
end

function RankedController.Line(childName: string)
	local _, v3 = Utility.GetData(localPlayer)
	local ranked

	if v3 ~= nil then
		ranked = v3:FindFirstChild("Ranked")
	end

	local modes

	if ranked ~= nil then
		modes = ranked:FindFirstChild("Modes")
	end

	local child

	if modes ~= nil then
		child = modes:FindFirstChild(childName)
	end

	if child == nil then
		return "Unranked"
	end

	local points = child:FindFirstChild("Points")
	local placements = child:FindFirstChild("Placements")
	local v4 = points == nil and 0 or points.Value
	local v5 = placements == nil and 0 or placements.Value

	if v5 < MinigameSettings.Settings.PvP.Ranked.PlacementCount then
		return (`Placement {v5}/{MinigameSettings.Settings.PvP.Ranked.PlacementCount}`)
	end

	local _, v6 = Ranked.TierOf(v4)
	local standing, v7 = RankedController.Standing(childName)
	local formatted = `{v6.Name} · {Utility.addCommasToNumber(v4)}`

	if standing > 0 then
		return (`{formatted} · #{standing}`)
	end

	if v7 > 0 then
		return (`{formatted} · Top {v7}%`)
	end

	return formatted
end

function RankedController.TowerLine(p: string)
	local mine = RankedController.Mine(p)

	if mine == nil then
		return "No ranked run yet"
	end

	local standing, v3 = RankedController.Standing(p)
	local formatted = `Best {Utility.addCommasToNumber(mine)}`

	if standing > 0 then
		return (`{formatted} · #{standing}`)
	end

	if v3 > 0 then
		return (`{formatted} · Top {v3}%`)
	end

	return formatted
end

return RankedController