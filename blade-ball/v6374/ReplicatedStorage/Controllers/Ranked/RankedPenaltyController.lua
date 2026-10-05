local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local playerGui = Players.LocalPlayer.PlayerGui
local rankedAbandonPenalty = playerGui:FindFirstChild("RankedAbandonPenalty")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.Packages.Freeze)
local v5 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.RankedPenaltyData)
local v6 = require3(ReplicatedStorage2.ServerInfo)
local v7 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v8 = require3(ReplicatedStorage2.Shared.Statable)
local maid = v5.Maid
local key = false
v6.isRankedLobbyServer()
v6.isNoAbilityRankedLobbyServer()
local rankType = v6:GetRankType() or "Normal"
local maid2 = maid.new()
local v9 = nil
local v10 = {
	Normal = nil,
	NoAbility = nil
}
local state = v8.State(false)
local v11 = v3.new()
local RankedPenaltyController = {}
RankedPenaltyController._promptQueue = {}
RankedPenaltyController._activeId = {}
RankedPenaltyController._currentHistory = {}

function RankedPenaltyController.IsRankedRestricted(p, p2: string?)
	local v12 = p2 or rankType
	local v13 = v10[v12]

	if v13 == nil then
		return true
	end

	if not (key and p._currentHistory[v12]) then
		return false
	end

	local filtered = v4.List.filter(p._currentHistory[v12], function(p3)
		return p3.Reason == "MatchInProgress" and not (p3.Timestamp - workspace:GetServerTimeNow() > 3600)
	end)
	return v13:Get() - workspace:GetServerTimeNow() > 0 or #filtered > 0
end

function RankedPenaltyController.GetPenaltyTimeStamp(_, p: string?)
	return v10[p or rankType]
end

function RankedPenaltyController:AddPenaltyToQueue(p)
	if p.Shown then
		return
	end

	self._activeId[p.Id] = true
	table.insert(self._promptQueue, p)

	if not state:Get() then
		task.spawn(function()
			self:ProcessQueue()
		end)
	end
end

function RankedPenaltyController:ProcessQueue()
	if state:Get() then
		return print("processing something")
	end

	if #self._promptQueue > 0 then
		state:Set(true)
		local v12 = self._promptQueue[1]
		table.remove(self._promptQueue, 1)
		self._activeId[v12.Id] = nil
		self:RenderPenalty(v12)
		v11:Wait()
		state:Set(false)
		task.spawn(function()
			self:ProcessQueue()
		end)
	end
end

function RankedPenaltyController:RenderPenalty(state2)
	maid2:DoCleaning()
	rankedAbandonPenalty.Enabled = true
	local mainFrame = rankedAbandonPenalty:WaitForChild("MainFrame")
	local closeButton = mainFrame:WaitForChild("CloseButton")
	local innerFrame = mainFrame:WaitForChild("InnerFrame")
	innerFrame:WaitForChild("Time")
	local title = innerFrame:WaitForChild("Title")

	if state2.Reason == "Adandoning" then
		state2.Reason = "Abandoning"
	end

	if title then
		title.Text = `{state2.Reason} Game Penalty`
	end

	maid2:GiveTask(closeButton.Button.Activated:Connect(function()
		closeButton.Button.Active = false
		rankedAbandonPenalty.Enabled = false

		if v9:InvokeServer(state2.Id, state2.RankType) ~= nil then
			maid2:DoCleaning()
			v11:Fire(true)
			closeButton.Button.Active = true
		end
	end))
	local time = rankedAbandonPenalty:WaitForChild("MainFrame"):WaitForChild("InnerFrame"):WaitForChild("Time")
	local v12 = v10[state2.RankType]
	maid2:GiveTask(RunService.RenderStepped:Connect(function()
		if not (rankedAbandonPenalty.Enabled and v12) then
			return
		end

		local v13 = v12:Get()
		print(v13)
		local v14 = v13 - workspace:GetServerTimeNow()
		local v15 = v14 < 0 and 0 or v14
		local v16 = math.floor(v15 / 3600)
		local v17 = math.floor(v15 % 3600 / 60)
		local v18 = v15 % 60

		if v16 > 0 then
			time.Text = string.format("%02d:%02d:%02d", v16, v17, v18)
		else
			time.Text = string.format("%02d:%02d", v17, v18)
		end
	end))
end

function RankedPenaltyController:Start()
	rankedAbandonPenalty = playerGui:WaitForChild("RankedAbandonPenalty")
	v9 = v:RemoteFunction("MarkPenaltyAsRead")
	local v12 = v2.Client:WaitReplion("Data")

	if not v12 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateIsEnabled()
		key = v7:GetKey("RankedPenaltyEnabled")
	end

	task.defer(function()
		v7:WaitForData()
		updateIsEnabled() -- equivalent call inferred; original call site unknown
	end)
	v7.DataUpdatedEvent:Connect(function()
		updateIsEnabled() -- equivalent call inferred; original call site unknown
	end)
	v10.Normal = v8.getReplionPathState(v12, { "RankedPenaltyHistory", "PenaltyTimestamps", "Normal" })
	v10.NoAbility = v8.getReplionPathState(v12, { "RankedPenaltyHistory", "PenaltyTimestamps", "NoAbility" })

	local function processRankedPenaltyHistory(rankType2: string, items)
		self._currentHistory[rankType2] = items

		for _, item in items do
			if not (self._activeId[item.Id] == nil and item.Shown == false and item.Reason ~= "MatchInProgress") then
				continue
			end

			item.RankType = rankType2
			self:AddPenaltyToQueue(item)
		end
	end

	task.wait(5)
	local replionPathState = v8.getReplionPathState(v12, { "RankedPenaltyHistory", "History" })
	replionPathState:Connect(function(items)
		for k, item in items do
			processRankedPenaltyHistory(k, item)
		end
	end)

	for k, v13 in replionPathState:Get() do
		processRankedPenaltyHistory(k, v13)
	end
end

return RankedPenaltyController