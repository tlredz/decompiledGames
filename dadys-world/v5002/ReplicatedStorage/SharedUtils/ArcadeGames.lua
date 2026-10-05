local ArcadeGames = {}
local CollectionService = game:GetService("CollectionService")
game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local fn
local arcadeGames = ReplicatedStorage:FindFirstChild("Parts") and ReplicatedStorage.Parts:FindFirstChild("ArcadeGames")
local arcadeGames2 = ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("ArcadeGames")
local Universe = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Universe"))
local Network = require(ReplicatedStorage.SharedUtils:WaitForChild("Network"))
local Maid = require(ReplicatedStorage.SharedUtils:WaitForChild("Maid"))

-- equivalent calls inferred from this helper; original call sites unknown
local function getArcadeContent(minigame: string)
	local child = arcadeGames and arcadeGames:FindFirstChild(minigame)
	local child2 = arcadeGames2:FindFirstChild(minigame)

	if child and child2 then
		return {
			Assets = child,
			Module = child2
		}
	end
end

local function getObjects(instance)
	local cam = instance:FindFirstChild("Cam")
	local screen = instance:FindFirstChild("Screen")
	local attachment = screen and screen:FindFirstChild("Attachment")
	local proximityPrompt = attachment and attachment:FindFirstChild("ProximityPrompt")

	if cam and screen and proximityPrompt then
		return {
			Camera = cam,
			Screen = screen,
			ProximityPrompt = proximityPrompt
		}
	end
end

local function waitForObjects(instance)
	local screen = instance:WaitForChild("Screen", 15)
	local cam = instance:WaitForChild("Cam", 15)
	local attachment = screen and screen:WaitForChild("Attachment", 15)
	local proximityPrompt = attachment and attachment:WaitForChild("ProximityPrompt", 15)

	if cam and screen and proximityPrompt then
		return {
			Camera = cam,
			Screen = screen,
			ProximityPrompt = proximityPrompt
		}
	end
end

local v = {}

local function getLeaderboard(p)
	local v2 = v[p]

	if v2 then
		return v2
	end

	local v3 = nil
	v[p] = v3
	return v3
end

function ArcadeGames._Server()
	local v2 = RunService:IsStudio() and 10 or 100
	local IchorTransactions = require(ServerStorage:WaitForChild("SharedModules"):WaitForChild("IchorTransactions"))
	local AchievementGiver = require(ServerStorage:WaitForChild("SharedModules"):WaitForChild("AchievementGiver"))
	local modules = ReplicatedStorage:WaitForChild("Modules")
	local BetterAnalyticsService = Universe:IsGame() and require(modules:WaitForChild("Services"):WaitForChild("BetterAnalyticsService")) or require(modules:WaitForChild("BetterAnalyticsService"))
	local editData = ReplicatedStorage:WaitForChild("editData")
	local ReplicaCache = require(ServerScriptService.Modules.ReplicaCache)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getReplica(p)
		return p and ReplicaCache[p.UserId]
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SetReplicaValue(p, p2, p3)
		local replica = getReplica(p) -- equivalent call inferred; original call site unknown

		if replica then
			replica:SetValue(p2, p3)
		end
	end

	local FriendsLeaderboard = require(ReplicatedStorage.SharedUtils:WaitForChild("FriendsLeaderboard"))
	local v3 = {}

	local function getFriendsBoard(minigame)
		local v4 = v3[minigame]

		if v4 then
			return v4
		end

		local v5 = FriendsLeaderboard.new(minigame, {
			getOnlineScore = function(p)
				local v6 = ReplicaCache[p]
				local data = v6 and v6.Data
				local statistics = data and data.Statistics
				return statistics and statistics.Highscore_SwimmyBarnaby
			end
		})
		v3[minigame] = v5
		return v5
	end

	local v4 = {}
	local instances = {}

	fn = function(instance)
		local minigame = instance:GetAttribute("Minigame")

		if not minigame then
			return
		end

		local child = arcadeGames and arcadeGames:FindFirstChild(minigame)
		local child2 = arcadeGames2:FindFirstChild(minigame)

		if not (child and child2) then
			return
		end

		local objects = getObjects(instance)

		if not objects then
			return
		end

		local v5 = minigame .. "_" .. tostring(math.random())
		instance:SetAttribute("ID", v5)
		instance:GetAttributeChangedSignal("PromptHidden"):Connect(function()
			if instance and instance.Parent and objects.ProximityPrompt and objects.ProximityPrompt.Parent then
				local promptHidden = instance:GetAttribute("PromptHidden") == true
				objects.ProximityPrompt.Enabled = not promptHidden
			end
		end)
		objects.ProximityPrompt.Triggered:Connect(function(player)
			local character = player.Character

			if not character or player:GetAttribute("InMinigame") then
				return
			end

			local userId = player.UserId

			if v4[userId] then
				v4[userId]:Destroy()
			end

			player:SetAttribute("InMinigame", v5)
			local maid = Maid.new()
			maid:GiveTask(function()
				if v4[userId] then
					v4[userId] = nil
				end

				if player and player.Parent and player:GetAttribute("InMinigame") == v5 then
					player:SetAttribute("InMinigame", nil)
				end
			end)
			maid:GiveTask(character.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					maid:Destroy()
				end
			end))
			maid:GiveTask(instance.AncestryChanged:Connect(function()
				if instance.Parent == nil then
					maid:Destroy()
				end
			end))
			v4[userId] = maid
		end)
		instances[v5] = instance
		getFriendsBoard(minigame)
		print("SERVER ADDED MACHINE: ", instance, minigame)
	end

	Network:AddAction("ExitMinigame", function(p)
		local v5 = v4[p.UserId]

		if v5 then
			v5:Destroy()
		end
	end)
	local v5 = {}
	Players.PlayerRemoving:Connect(function(player)
		if v5[player] then
			v5[player] = nil
		end
	end)
	Network:AddAction("PurchaseArcadeEntry", function(p, p2)
		local machine = instances[p2]

		if not machine then
			print("Could not find machine!")
			return false, "No machine found with given ID"
		end

		local flag = false
		local v7 = "N/A"
		editData:Invoke(p, function(p3)
			if p3 then
				local v8, v9 = IchorTransactions:TakeIchor(p, p3, 25)

				if v8 then
					SetReplicaValue(p, "Coin", p3.Data.Coin) -- equivalent call inferred; original call site unknown
					BetterAnalyticsService:LogEconomyEvent(
						p,
						"Sink",
						"Coins",
						25,
						p3.Data.Coin,
						"Shop",
						"SwimmyBarnaby"
					)
					flag = true
				else
					flag = false
					v7 = v9
				end
			else
				v7 = "Profile does not exist"
				flag = false
			end
		end)

		if flag then
			v5[p] = {
				TS = workspace.DistributedGameTime,
				Machine = machine
			}
		end

		return flag, v7
	end)
	Network:AddAction("SubmitArcadeScore", function(p, p2, p3)
		local v6 = instances[p2]

		if not v6 then
			print("Could not find machine!")
			return false, "No machine found with given ID"
		end

		local v7 = v5[p]

		if not v7 then
			print("No record of machine found that was started!")
			return false, "You haven't started a game with this machine!"
		end

		if not (p3 and tonumber(p3) and tonumber(p3) > 0) then
			print("Score must be positive integer")
			return false, "Score must be positive integer"
		end

		local friendsBoard = getFriendsBoard(v6:GetAttribute("Minigame"))
		local highscore_SwimmyBarnaby = math.ceil((tonumber(p3)))
		local v9 = (workspace.DistributedGameTime - v7.TS - 7) * 1.15
		local v10 = v9 * 0.19999999999999996

		if highscore_SwimmyBarnaby > 200 and v10 < highscore_SwimmyBarnaby - v9 then
			print("Score alignment from the server does not match:")
			print(highscore_SwimmyBarnaby, v9, v10)
			return false, "Score does not match expected score"
		else
			v5[p] = nil
			editData:Invoke(p, function(p4)
				if not (p4 and p4.Data) then
					return
				end

				if (p4.Data.Statistics.Highscore_SwimmyBarnaby or 0) < highscore_SwimmyBarnaby then
					p4.Data.Statistics.Highscore_SwimmyBarnaby = highscore_SwimmyBarnaby
					SetReplicaValue(p, "Statistics.Highscore_SwimmyBarnaby", highscore_SwimmyBarnaby) -- equivalent call inferred; original call site unknown
					friendsBoard:Set(p.UserId, highscore_SwimmyBarnaby)
				end
			end)
		end
	end)
	Network:AddAction("GetFriendsLeaderboard", function(p, p2)
		local v6 = instances[p2]

		if not v6 then
			return false, "No machine found with given ID"
		end

		return getFriendsBoard(v6:GetAttribute("Minigame")):Get(p, p2)
	end)
	Network:AddAction("ReportArcadeMilestone", function(p, p2)
		local v6 = instances[p2]

		if not (v6 and v6:GetAttribute("Minigame") == "SwimmyBarnaby") then
			return
		end

		local v7 = v5[p]

		if not v7 or (workspace.DistributedGameTime - v7.TS - 3) * 1.15 < v2 * 0.8 then
			return
		end

		task.spawn(function()
			AchievementGiver:CompleteAchievementOneOff(p, "ID_58_SwimmyBarnaby")
		end)
	end)

	if Universe:IsGame() then
		local panic = workspace:WaitForChild("Info"):WaitForChild("Panic")

		local function refundEntry(p)
			if not v5[p] then
				return
			end

			v5[p] = nil
			editData:Invoke(p, function(p2)
				if not (p2 and p2.Data) then
					return
				end

				IchorTransactions:GiveIchor(p, p2, 25, false)
				SetReplicaValue(p, "Coin", p2.Data.Coin) -- equivalent call inferred; original call site unknown
				BetterAnalyticsService:LogEconomyEvent(
					p,
					"Source",
					"Coins",
					25,
					p2.Data.Coin,
					"Gameplay",
					"SwimmyBarnaby"
				)
			end)
		end

		panic:GetPropertyChangedSignal("Value"):Connect(function()
			if panic.Value ~= true then
				return
			end

			for _, v6 in pairs(instances) do
				if v6:IsDescendantOf(workspace) then
					v6:SetAttribute("PromptHidden", true)
				end
			end

			for _, v6 in ipairs(Players:GetPlayers()) do
				if not v6:GetAttribute("InMinigame") then
					continue
				end

				local v7 = v4[v6.UserId]

				if v7 then
					v7:Destroy()
				end

				task.spawn(refundEntry, v6)
			end
		end)
	end
end

function ArcadeGames._Client()
	local localPlayer = Players.LocalPlayer
	local screenGui, MyDataController

	if Universe:IsGame() then
		screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
		MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClientUI"):WaitForChild(
			"MyDataController",
			60
		))
	else
		screenGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")
		MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController", 60))
	end

	local MenuManager = require(ReplicatedStorage.SharedUtils:WaitForChild("MenuManager"))
	local CameraModeController = require(ReplicatedStorage.SharedUtils:WaitForChild("CameraModeController"))
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local function sequence(items)
		for _, item in pairs(items) do
			local v2 = item()

			if not v2 then
				continue
			end

			v2:Play()
			v2.Completed:Wait()
		end
	end

	local v2 = {}
	Network:AddAction("FriendsLeaderboardUpdate", function(p, p2)
		local v3 = v2[p]

		if v3 and v3.GameInstance then
			v3.GameInstance:UpdateLeaderboard(p2)
		end
	end)

	fn = function(instance)
		while not instance:GetAttribute("Minigame") do
			instance.AttributeChanged:Wait()
		end

		local minigame = instance:GetAttribute("Minigame")
		local arcadeContent = getArcadeContent(minigame) -- equivalent call inferred; original call site unknown

		if not arcadeContent then
			warn("[ArcadeGames] no content bundle for arcade '" .. tostring(minigame) .. "' — skipping " .. instance:GetFullName())
			return
		end

		local objects = waitForObjects(instance)

		if not objects then
			warn("[ArcadeGames] cabinet parts (Cam/Screen/ProximityPrompt) never replicated — skipping " .. instance:GetFullName())
			return
		end

		while not instance:GetAttribute("ID") do
			instance.AttributeChanged:Wait()
		end

		objects.Screen.Color = Color3.new(0, 0, 0)
		local ID = instance:GetAttribute("ID")
		local Module = require(arcadeContent.Module)
		local gameInstance = Module.new(ID, {
			Model = instance,
			Content = arcadeContent,
			Objects = objects
		})

		if not gameInstance then
			warn("[ArcadeGames] " .. tostring(minigame) .. " .new() returned nil (arcade bundle incomplete) — skipping machine " .. tostring(ID))
			return
		end

		v2[ID] = {
			Model = instance,
			ArcadeName = minigame,
			Content = arcadeContent,
			Objects = objects,
			GameInstance = gameInstance
		}
		print("CLIENT ADDED MACHINE: ", instance, minigame)
	end

	MyDataController:onReplicaReady(function(p)
		local function setFocus(data)
			task.spawn(sequence, { function()
					return TweenService:Create(data.Objects.Screen, tweenInfo, {
						Color = Color3.new(0.3, 0.3, 0.3)
					})
				end, function()
					return TweenService:Create(data.Objects.Screen, tweenInfo, {
						Color = Color3.new(0.1, 0.1, 0.1)
					})
				end, function()
					return TweenService:Create(data.Objects.Screen, tweenInfo3, {
						Color = Color3.new(0.8, 0.8, 0.8)
					})
				end })
			data.Objects.ProximityPrompt.Enabled = false
			MenuManager:CloseAll()
			CameraModeController.Exit()
			screenGui.Enabled = false
			local bootup = data.GameInstance:Bootup(p)
			screenGui.Enabled = true

			if bootup then
				Network:Post("ExitMinigame")
			end

			task.delay(3, function()
				if data.Model and data.Model.Parent and data.Model:GetAttribute("PromptHidden") then
					return
				end

				if data.Objects.ProximityPrompt and data.Objects.ProximityPrompt.Parent then
					data.Objects.ProximityPrompt.Enabled = true
				end
			end)
			TweenService:Create(data.Objects.Screen, tweenInfo2, {
				Color = Color3.new(0, 0, 0)
			}):Play()
		end

		local v3 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateInMinigame()
			local inMinigame = localPlayer:GetAttribute("InMinigame")
			local v4 = inMinigame and v2[inMinigame]

			if v4 then
				v3 = v4
				setFocus(v4)
			elseif v3 then
				v3.GameInstance:SendShutdownSignal(-1)
				v3 = nil
			end
		end

		localPlayer:GetAttributeChangedSignal("InMinigame"):Connect(function()
			local inMinigame = localPlayer:GetAttribute("InMinigame")
			local v4 = inMinigame and v2[inMinigame]

			if v4 then
				v3 = v4
				setFocus(v4)
			elseif v3 then
				v3.GameInstance:SendShutdownSignal(-1)
				v3 = nil
			end
		end)
		updateInMinigame() -- equivalent call inferred; original call site unknown
	end)
end

function ArcadeGames._init()
	if RunService:IsServer() then
		ArcadeGames._Server()
	else
		ArcadeGames._Client()
	end

	CollectionService:GetInstanceAddedSignal("ArcadeGame"):Connect(fn)

	for _, v2 in pairs(CollectionService:GetTagged("ArcadeGame")) do
		task.spawn(fn, v2)
	end
end

local v2 = RunService:IsServer() and "Server_" or "Client_"

if not script:GetAttribute(v2 .. "Initialized") then
	script:SetAttribute(v2 .. "Initialized", true)
	ArcadeGames._init()
end

return ArcadeGames