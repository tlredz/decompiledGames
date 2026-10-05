local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local WCFinaleScoreBarClient = require(script.WCFinaleScoreBarClient)
local WCFinaleAdminAbuseConfig = require(script.WCFinaleAdminAbuseConfig)
local WCFinaleAdminAbuseCutscenes = require(script.WCFinaleAdminAbuseCutscenes)
local BossAnimationClient = require(script.BossAnimationClient)
local ShootingPenalties = require(script.AttacksClient.ShootingPenalties)
local CommandPanel = require(script.CommandPanel)
local SoccerGoalsClient = require(script.SoccerGoalsClient)
local OrbsClient = require(script.OrbsClient)
local FakeAdminMessageUtil = require(ReplicatedStorage.Utilities.FakeAdminMessageUtil)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local v = nil
local flag = false
local flag2 = false
local maid = Janitor.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function isCutscenePayloadFresh(p)
	local firedAt = p.firedAt
	return type(firedAt) ~= "number" or os.time() - firedAt <= 20
end

local function handleFx(p: string, data)
	if p == "OpeningCutscene" then
		if not isCutscenePayloadFresh(data) then
			return
		end

		local thread = task.spawn(function()
			local child = workspace:FindFirstChild(data.mapName, true)

			if child then
				WCFinaleAdminAbuseCutscenes.init(child)
				WCFinaleAdminAbuseCutscenes.playOpening()
			end
		end)
		maid:Add(function()
			pcall(task.cancel, thread)
		end)
	elseif p == "EndingCutscene" then
		if not isCutscenePayloadFresh(data) then
			return
		end

		local thread = task.spawn(function()
			local child = workspace:FindFirstChild(data.mapName, true)

			if child then
				WCFinaleAdminAbuseCutscenes.init(child)
				WCFinaleAdminAbuseCutscenes.playEnding()
			end
		end)
		maid:Add(function()
			pcall(task.cancel, thread)
		end)
	elseif p == "ShowBossMessage" then
		local message = data.message

		if type(message) ~= "string" or message == "" then
			return
		end

		local senderId = data.senderId or WCFinaleAdminAbuseConfig.DefaultSenderId
		local duration = data.duration or 8

		if type(data.senderName) == "string" and type(data.senderIcon) == "string" then
			FakeAdminMessageUtil.show({
				message = message,
				senderName = data.senderName,
				senderUserId = senderId,
				preloadedThumb = data.senderIcon,
				duration = duration
			})
		else
			task.spawn(function()
				local success, result = pcall(function()
					return Players:GetNameFromUserIdAsync(senderId)
				end)
				FakeAdminMessageUtil.show({
					message = message,
					senderName = success and result or "User" .. tostring(senderId),
					senderUserId = senderId,
					preloadedThumb = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(senderId),
					duration = duration
				})
			end)
		end
	elseif p == "SpawnOrbs" then
		local v2 = type(data.count) == "number" and math.max(1, (math.floor(data.count))) or 1
		task.spawn(OrbsClient.spawnFromZone, v2)
	elseif p == "SPSpawn" then
		task.spawn(ShootingPenalties.spawn, data)
	elseif p == "SPImpact" then
		ShootingPenalties.impactFx(data)
	elseif p == "BossTeleport" then
		local rigModel = data.rigModel

		if not rigModel then
			warn("[WCFinaleAdminAbuse.client] - BossTeleport cmd missing rigModel arg")
			return
		end

		for _, part in ipairs(rigModel:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local clone = part:Clone()
			clone.Parent = data.debrisFolder or workspace
			clone.Anchored = true
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.Material = Enum.Material.ForceField

			if #clone:GetChildren() > 0 then
				for _, child in ipairs(clone:GetChildren()) do
					child:Destroy()
				end
			end

			local tween = TweenService:Create(clone, TweenInfo.new(3), {
				Transparency = 1
			})
			tween:Play()
			tween.Completed:Once(function(p2)
				tween:Destroy()
				clone:Destroy()
			end)
		end
	end
end

local WCFinaleAdminAbuse = {}
WCFinaleAdminAbuse.IsAdminAbuse = true
WCFinaleAdminAbuse.NeedsDuration = false

function WCFinaleAdminAbuse.Fire(_: number?)
	flag = false
	flag2 = false
	maid:Cleanup()

	if v then
		v:stop()
	end

	ShootingPenalties.cleanup()
	SoccerGoalsClient.stop()
	CommandPanel.Stop()
	v = WCFinaleScoreBarClient.new({
		sseChannelName = WCFinaleAdminAbuseConfig.sseChannelName,
		durationSec = WCFinaleAdminAbuseConfig.BossTheatreDurationSec,
		onFx = function(p: string, p2)
			if p == "OpeningCutscene" then
				if flag then
					return
				else
					flag = true
				end
			elseif p == "EndingCutscene" then
				if flag2 then
					return
				else
					flag2 = true
				end
			end

			handleFx(p, p2)
		end
	})
	v:fire()
	BossAnimationClient.start(WCFinaleAdminAbuseConfig.mapModelName)
	local _sse = v._sse

	if _sse then
		_sse:onChange("OpeningCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag and isCutscenePayloadFresh(p) then
				local thread = task.delay(2, function()
					if not flag then
						flag = true
						local v2 = p

						if not isCutscenePayloadFresh(v2) then
							return
						end

						local thread2 = task.spawn(function()
							local child = workspace:FindFirstChild(v2.mapName, true)

							if child then
								WCFinaleAdminAbuseCutscenes.init(child)
								WCFinaleAdminAbuseCutscenes.playOpening()
							end
						end)
						maid:Add(function()
							pcall(task.cancel, thread2)
						end)
					end
				end)
				maid:Add(function()
					pcall(task.cancel, thread)
				end)
			end
		end)
		_sse:onChange("EndingCutscene", function(p)
			if type(p) == "table" and p.mapName and not flag2 and isCutscenePayloadFresh(p) then
				local thread = task.delay(2, function()
					if not flag2 then
						flag2 = true
						local v2 = p

						if not isCutscenePayloadFresh(v2) then
							return
						end

						local thread2 = task.spawn(function()
							local child = workspace:FindFirstChild(v2.mapName, true)

							if child then
								WCFinaleAdminAbuseCutscenes.init(child)
								WCFinaleAdminAbuseCutscenes.playEnding()
							end
						end)
						maid:Add(function()
							pcall(task.cancel, thread2)
						end)
					end
				end)
				maid:Add(function()
					pcall(task.cancel, thread)
				end)
			end
		end)
	end

	local thread = task.spawn(function()
		print("[WCFinaleAdminAbuse][SoccerGoals] Fire(): waiting on AdminAbuse.Remotes...")
		local remotes = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes")
		local wCFinaleSoccerGoalScored = remotes:WaitForChild("WCFinaleSoccerGoalScored", 10)

		if not wCFinaleSoccerGoalScored then
			warn("[WCFinaleAdminAbuse] WCFinaleSoccerGoalScored remote not found — soccer goals disabled")
			return
		end

		print("[WCFinaleAdminAbuse][SoccerGoals] remote found:", wCFinaleSoccerGoalScored:GetFullName())
		SoccerGoalsClient.init(wCFinaleSoccerGoalScored)
		local wCFinaleGoalWinsSync = remotes:WaitForChild("WCFinaleGoalWinsSync", 10)

		if wCFinaleGoalWinsSync and v then
			v:bindWinsRemote(wCFinaleGoalWinsSync)
		else
			warn("[WCFinaleAdminAbuse] WCFinaleGoalWinsSync remote not found — wins bar will stay at 0")
		end

		local adminAbuse = workspace:WaitForChild("AdminAbuse", 10)

		if not adminAbuse then
			warn("[WCFinaleAdminAbuse][SoccerGoals] workspace.AdminAbuse not found after 10s")
			return
		end

		local map = adminAbuse:WaitForChild("Map", 10)

		if not map then
			warn("[WCFinaleAdminAbuse][SoccerGoals] workspace.AdminAbuse.Map not found after 10s")
			return
		end

		local v2 = WCFinaleAdminAbuseConfig.mapModelName .. "_Live"
		print(("[WCFinaleAdminAbuse][SoccerGoals] waiting on workspace.AdminAbuse.Map.%s..."):format(v2))
		local child = map:WaitForChild(v2, 10)

		if not child then
			warn(("[WCFinaleAdminAbuse][SoccerGoals] map clone '%s' not found under workspace.AdminAbuse.Map after 10s"):format(v2))
			return
		end

		print("[WCFinaleAdminAbuse][SoccerGoals] map clone found:", child:GetFullName())
		SoccerGoalsClient.scan(child)
		SoccerGoalsClient.spawnAll()
		OrbsClient.scan(child)
	end)
	maid:Add(function()
		pcall(task.cancel, thread)
	end)
	local thread2 = task.spawn(function()
		local child = ReplicatedStorage:WaitForChild("AdminAbuse"):WaitForChild("Remotes"):WaitForChild(
			WCFinaleAdminAbuseConfig.MessageCommandRemoteName,
			10
		)

		if child then
			CommandPanel.init(child)
		else
			warn("[WCFinaleAdminAbuse] MessageCommandRemote not found — trusted message panel disabled")
		end
	end)
	maid:Add(function()
		pcall(task.cancel, thread2)
	end)
end

function WCFinaleAdminAbuse.Stop()
	maid:Cleanup()
	WCFinaleAdminAbuseCutscenes.stopAll()
	BossAnimationClient.stop()
	ShootingPenalties.cleanup()
	SoccerGoalsClient.stop()
	OrbsClient.cleanup()
	CommandPanel.Stop()

	if v then
		v:stop()
		v = nil
	end
end

WCFinaleAdminAbuse.Hidden = true
return WCFinaleAdminAbuse