local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local HttpService = game:GetService("HttpService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local rankedQueue = localPlayer.PlayerGui:WaitForChild("RankedQueue")
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local guiInset = GuiService:GetGuiInset()
require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Packages.Signal)
local v5 = require3(ReplicatedStorage2.Shared.Time)
local v6 = require3(ReplicatedStorage2.Shared.RankedSeasonData)
local v7 = require3(ReplicatedStorage2.Shared.RankData)
local v8 = require3(ReplicatedStorage2.Controllers.Ranked.RankedSignalController)
local v9 = require3(ReplicatedStorage2.Common.Utils)
local v10 = v4.new()
local v11 = 0
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
v8:GetUpdateRankedMenuSignal():Connect(function(p)
	v16 = p
end)
local v17 = {
	["1v1"] = "rbxassetid://132856571912470",
	["2v2"] = "rbxassetid://79130894024192",
	["4v4"] = "rbxassetid://81899331641814"
}
local RankedQueueController = {}
local v18 = nil

function RankedQueueController:UpdatePlayersInQueue()
	local queuePartition = localPlayer:GetAttribute("QueuePartition")
	local v19 = queuePartition and v18:Get(queuePartition)
	local numPlayers = v19 and v19.NumPlayers
	local lastUpdate = v19 and v19.LastUpdate

	if lastUpdate ~= nil then
		local _ = workspace:GetServerTimeNow() - lastUpdate <= 420
	end

	local visible

	if numPlayers then
		if numPlayers > 1 then
			visible = v9.FFlag.GetFFlag("RankedQueueCountEnabled", true)
		else
			visible = false
		end
	else
		visible = numPlayers
	end

	local open = rankedQueue.Frame.Open
	local position

	if visible then
		position = UDim2.fromScale(0.6, 0.406)
	else
		position = UDim2.fromScale(0.6, 0.473)
	end

	open.Position = position
	local open2 = rankedQueue.Frame.Open
	local size

	if visible then
		size = UDim2.fromScale(0.6, 0.155)
	else
		size = UDim2.fromScale(0.6, 0.168)
	end

	open2.Size = size
	local title = rankedQueue.Frame.Title
	local position2

	if visible then
		position2 = UDim2.fromScale(0.606, 0.251)
	else
		position2 = UDim2.fromScale(0.606, 0.307)
	end

	title.Position = position2
	local open3 = rankedQueue.Frame.Open
	local size2

	if visible then
		size2 = UDim2.fromScale(0.605, 0.164)
	else
		size2 = UDim2.fromScale(0.605, 0.203)
	end

	open3.Size = size2

	if visible then
		rankedQueue.Frame.PlayersInQueue.Text = `{numPlayers}+ players in queue`
	end

	rankedQueue.Frame.PlayersInQueue.Visible = visible
end

function RankedQueueController.GetQueueStatusChanged(_)
	return v10
end

function RankedQueueController:Start()
	rankedQueue.Frame.Cancel.Activated:Connect(function()
		_G.LeaveRankedQueue(v14)
	end)
	rankedQueue.Frame.Hide.Activated:Connect(function()
		rankedQueue.Frame.Visible = false
		rankedQueue.Show.Visible = true

		if not v.TouchEnabled then
			rankedQueue.Show.Position = UDim2.new(0.5, 0, 0.1, -guiInset.Y - guiInset.Y / 1.5)
		end
	end)
	rankedQueue.Show.Activated:Connect(function()
		rankedQueue.Frame.Visible = true
		rankedQueue.Show.Visible = false
	end)
	v10:Connect(function()
		if v13 == "Dead" then
			v12 = nil
			RankedQueueController:_updateQueueStatus()
		else
			local GUID = HttpService:GenerateGUID(false)
			v12 = GUID

			while v12 == GUID do
				RankedQueueController:_updateQueueStatus()
				task.wait(0.5)
			end
		end
	end)
	localPlayer:GetAttributeChangedSignal("InRankedQueue"):Connect(function()
		if not localPlayer:GetAttribute("InRankedQueue") then
			RankedQueueController:LeaveQueue()
			return
		end

		local queueType = localPlayer:GetAttribute("QueueType")
		local queueGameMode = localPlayer:GetAttribute("QueueGameMode")
		local queueStatus = localPlayer:GetAttribute("QueueStatus")

		if queueType and queueGameMode and queueStatus then
			RankedQueueController:JoinQueue()
		end

		if not rankedQueue.Frame.Visible then
			rankedQueue.Frame.Visible = true
			rankedQueue.Show.Visible = false
		end
	end)
	localPlayer:GetAttributeChangedSignal("QueueStatus"):Connect(function()
		if not localPlayer:GetAttribute("InRankedQueue") then
			RankedQueueController:LeaveQueue()
			return
		end

		local queueStatus = localPlayer:GetAttribute("QueueStatus")

		if v11 and v14 and v15 and v13 ~= "Dead" then
			v13 = queueStatus
		end

		if v13 == "Dead" then
			self:LeaveQueue()
		end
	end)

	local function onQueueTypeChanged()
		local queueType = localPlayer:GetAttribute("QueueType") or "Ranked"
		local queueGameMode = localPlayer:GetAttribute("QueueGameMode") or queueType == "Duel" and "1v1" or "FFA"

		if queueType == "Ranked" then
			local rankedType = v6.GetRankedType()
			local currentSeason = v6.GetCurrentSeason(rankedType)
			local v19 = nil
			local v20 = v3.Client:WaitReplion("Data"):Get({ "Elo", rankedType, (`Season{currentSeason}`) })

			if v20 then
				local v21 = v20[queueGameMode] or v20.FFA

				if v21 then
					v19 = v7.GetRank(v21)
				end
			end

			local v21 = v19 or v7.Ranks.Rookie
			rankedQueue.Frame.Logo.Image = v21.Icon
		else
			rankedQueue.Frame.Logo.Image = v17[queueGameMode] or "rbxassetid://132856571912470"
		end

		self:UpdatePlayersInQueue()
		self:UpdateQueue()
		self:_updateQueueStatus()
	end

	localPlayer:GetAttributeChangedSignal("QueueType"):Connect(onQueueTypeChanged)
	localPlayer:GetAttributeChangedSignal("QueueGameMode"):Connect(onQueueTypeChanged)
	localPlayer:GetAttributeChangedSignal("QueuePartition"):Connect(onQueueTypeChanged)
	onQueueTypeChanged()
	v2.CurrentGuiChanged:Connect(function()
		RankedQueueController:_updateQueueStatus()
	end)
	v18 = v3.Client:WaitReplion("MatchmakingPlayerCounts")
	v18:OnDataChange(function()
		self:UpdatePlayersInQueue()
	end)
end

function RankedQueueController:LeaveQueue()
	RankedQueueController:_setQueue(nil, nil, "Dead", 0)
end

function RankedQueueController.IsInQueue(_)
	return v13 == "Searching" or v13 == "Confirming"
end

function RankedQueueController:UpdateQueue(p: number?)
	local queueType = localPlayer:GetAttribute("QueueType")

	if not queueType then
		return
	end

	local queueGameMode = localPlayer:GetAttribute("QueueGameMode")

	if not queueGameMode then
		return
	end

	local queueStatus = localPlayer:GetAttribute("QueueStatus")

	if not queueStatus then
		return
	end

	RankedQueueController:_setQueue(queueType, queueGameMode, queueStatus, p or v11 or v5:GetTime())
end

function RankedQueueController:JoinQueue()
	self:UpdateQueue((v5:GetTime()))
end

function RankedQueueController:_setQueue(p: string?, p2: string?, p3: string, p4: number)
	v11 = p4
	v14 = p
	v15 = p2
	v13 = p3
	v10:Fire()
end

function RankedQueueController:_updateQueueStatus()
	local color

	if v13 == "Searching" or v13 == "Confirming" then
		color = Color3.fromRGB(102, 252, 77)
	else
		color = Color3.fromRGB(252, 74, 77)
	end

	local text

	if v13 == "Searching" then
		text = "Searching"
	elseif v13 == "Confirming" then
		text = "Waiting for Server"
	elseif v13 == "Dead" then
		text = "Failed to start match"
	else
		text = "Something went wrong"
	end

	if v13 == "Searching" or v13 == "Confirming" then
		local v20 = v5:GetTime() - v11
		text ..= (" (%02d:%02d)"):format(math.floor(v20 % 3600 / 60), (math.floor(v20 % 60)))
	end

	local rankedType = v6.GetRankedType()

	if v16 then
		rankedType = v16
	end

	local text2 = ""

	if v14 == "Ranked" then
		local mode = v6.Modes[v15]
		local displayName = mode and mode.DisplayName or v15
		text2 = `{rankedType == "Normal" and "Ranked" or "No Ability"} {displayName} Queue`
	elseif v14 == "Duel" then
		text2 = `{v15} Duel`
	end

	rankedQueue.Frame.Title.Text = text2
	rankedQueue.Frame.Open.TextColor3 = color
	rankedQueue.Frame.Open.Text = text
	rankedQueue.Enabled = (v13 == "Searching" or v13 == "Confirming" or v13 == "Dead") and not v2._currentGui and localPlayer:GetAttribute("InRankedQueue")
end

return RankedQueueController