local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.RankedSeasonData)
local v5 = require3(ReplicatedStorage2:WaitForChild("ServerInfo"))
local localPlayer = Players.LocalPlayer
local remoteEvent = v2:RemoteEvent("RejoinRankedMatch")
local rankedMatchDisconnected = localPlayer.PlayerGui:WaitForChild("RankedMatchDisconnected")
local RankedDisconnectController = {}

function RankedDisconnectController:ShowRejoin(currentMatch)
	if self._currentMatch then
		return
	end

	self._currentMatch = currentMatch
	rankedMatchDisconnected.Enabled = true
end

function RankedDisconnectController:Close()
	self._currentMatch = nil
	rankedMatchDisconnected.Enabled = false
end

function RankedDisconnectController:Start()
	local v6 = v.Client:WaitReplion("Data")

	if v5.isRankedMatchServer() then
		return
	end

	rankedMatchDisconnected.Main.Abandon.Activated:Connect(function()
		self:Close()
	end)
	rankedMatchDisconnected.Main.CloseButton.Activated:Connect(function()
		self:Close()
	end)
	local v7 = 0
	rankedMatchDisconnected.Main.Rejoin.Activated:Connect(function()
		if not self._currentMatch then
			return
		end

		local now = os.clock()

		if now - v7 < 5 then
			return
		end

		v7 = now
		remoteEvent:FireServer(self._currentMatch.ID)
		self:Close()
	end)

	local function searchForMatch()
		if localPlayer:GetAttribute("InRankedQueue") or v3:IsOpen("MatchFound") or v3:IsOpen("ChooseMap") then
			return
		end

		for _, rankedType in v4.RankedTypes do
			local v9 = v6:Get({ "RankedMatchHistory", rankedType, (`Season{v4.GetCurrentSeason(rankedType)}`) })

			if not v9 then
				break
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v10 = nil
			local v11 = nil

			for k, v12 in v9 do
				for _, v13 in v12 do
					local inProgress = v13.InProgress
					local canceled = v13.Canceled

					if not inProgress or canceled or v13.EndTime ~= nil or serverTimeNow - v13.StartTime > 300 then
						continue
					end

					local v14 = string.split(v13.ID, "|")[2]

					if not (v14 and #v14 ~= 4 and (not v10 or v10.StartTime > v13.StartTime)) then
						continue
					end

					v11 = k
					v10 = v13
				end
			end

			if v11 == "Duel" then
				break
			end

			if v10 then
				self:ShowRejoin(v10)
			end
		end
	end

	v6:OnChange("RankedMatchHistory", searchForMatch)
	task.spawn(searchForMatch)
end

return RankedDisconnectController