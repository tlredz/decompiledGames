local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer.Character
require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("UseNewLobby"))
local ServerInfo = require(ReplicatedStorage:WaitForChild("ServerInfo"))
require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Time"))
local UniverseIds = require(ReplicatedStorage.Shared.UniverseIds)
local v = { "KillsLeaderboard", "WinsLeaderboard" }

if game.PlaceId == UniverseIds.Default.PlaceId or game.PlaceId == UniverseIds.MobileServers.PlaceId then
	table.insert(v, "StPatricksLeaderboard")
end

local v2

if ServerInfo.isDuelLobbyServer() then
	v2 = { "DuelWinsLeaderboard" }
elseif ServerInfo.isLTMServer() then
	v2 = { "KillsLeaderboard", "WinsLeaderboard", "LTMWinsLeaderboard" }
elseif ServerInfo.isMedalServer() then
	v2 = { "LTMWinsLeaderboard" }
elseif ServerInfo.isTradingPlazaServer() then
	v2 = { "EarnedTokensLeaderboard", "TotalRAPLeaderboard" }
elseif ServerInfo.isDungeonsLobbyServer() then
	v2 = {}
else
	v2 = v
end

local v3 = { "Emote12", "Emote24", "Emote26" }
local v4 = {
	Emote12 = true,
	Emote24 = true,
	Emote26 = true
}
local emotes = ReplicatedStorage:WaitForChild("Misc"):WaitForChild("Emotes")
ReplicatedStorage:WaitForChild("ReplicatedLobbies")
local threads = {}

local function prepareLeaderboards(instance)
	local leaderboards = instance:WaitForChild("Leaderboards")

	if leaderboards then
		for _, childName in ipairs(v2) do
			leaderboards:WaitForChild(childName):WaitForChild("FirstPlacePlayer"):Destroy()
		end
	end
end

local function animateLeaderboardModels(spawn)
	if ReplicatedStorage.FeaturesToggle.Leaderboards.Value or ServerInfo.isMedalServer() then
		task.spawn(function()
			if ServerInfo.isDuelLobbyServer() then
				return
			end

			local client = spawn:WaitForChild("Runtime"):WaitForChild("Client")

			for _, child in ipairs(client:GetChildren()) do
				child.Enabled = true
			end
		end)
		task.spawn(function()
			if ServerInfo.isDungeonsLobbyServer() then
				return
			end

			spawn:WaitForChild("Leaderboards")

			for _, childName in ipairs(v2) do
				local animator2 = workspace.Leaderboards:WaitForChild(childName):WaitForChild("FirstPlacePlayer"):WaitForChild("Rig"):WaitForChild("Humanoid"):WaitForChild("Animator")
				table.insert(threads, task.delay(1, function()
					while true do
						for k, v5 in animator2:GetPlayingAnimationTracks() do
							v5:Stop(0)
							v5:Destroy()
						end

						local v5 = v3[math.random(1, #v3)]
						local track = animator2:LoadAnimation(emotes[v5])
						track:Play()

						if v4[v5] then
							task.wait(10)
						else
							track.Ended:Wait()
						end

						track:Stop(0)
						track:Destroy()
					end
				end))
			end
		end)
	end
end

local function updateProServer(_)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function recolorPart(part)
		if part:IsA("BasePart") then
			part.Color = Color3.new(1, 0, 0)
		end
	end

	CollectionService:GetInstanceAddedSignal("SpawnNeon"):Connect(recolorPart)

	for _, v5 in ipairs(CollectionService:GetTagged("SpawnNeon")) do
		recolorPart(v5) -- equivalent call inferred; original call site unknown
	end
end

local Bootstrapper = {}

function Bootstrapper.BeforeKnitInit(_)
	local spawn = workspace:WaitForChild("Spawn")

	if spawn then
		animateLeaderboardModels(spawn)

		if ServerInfo.isProServer() then
			updateProServer(spawn)
		end

		workspace:SetAttribute("NewLobbyLoaded", true)
	end

	xpcall(function()
		require(ReplicatedStorage.Common.Utils)
		local ReplicatedInstances = require(ReplicatedStorage.Shared.ReplicatedInstances)
		ReplicatedInstances:Init()
		require(ReplicatedStorage.Common.MarketplaceService)
	end, warn)
end

function Bootstrapper.AfterKnitStarted(_) end

return Bootstrapper