local RunService = game:GetService("RunService")
local WCFinaleAdminAbuseAnimationIDs = require(script.Parent.WCFinaleAdminAbuseAnimationIDs)
local WCFinaleAdminAbuseConfig = require(script.Parent.WCFinaleAdminAbuseConfig)
local emoteIDs = WCFinaleAdminAbuseAnimationIDs.EmoteIDs
local v = {}
local v2 = nil
local total = 0
local v3 = 0
local thread = nil
local heartbeatConnection = nil
local count = 0
local BossAnimationClient = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function loadTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Looped = true
	return track
end

local function pickNextIndex(p: number?)
	local v4 = math.random(1, #v)

	if v4 ~= p or not (#v > 1) then
		return v4
	end

	if v4 == #v then
		return v4 - 1
	end

	return v4 + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playIndex(p: number)
	if v2 then
		local v4 = v[v2]

		if v4.IsPlaying then
			v4:Stop(0.25)
		end
	end

	v[p]:Play(0.25)
	v2 = p
end

function BossAnimationClient.start(p: string)
	BossAnimationClient.stop()
	count += 1
	local v4 = count
	thread = task.spawn(function()
		local humanoid = nil

		while count == v4 do
			local adminAbuse = workspace:FindFirstChild("AdminAbuse")
			local map = adminAbuse and adminAbuse:FindFirstChild("Map")
			local child = map and map:FindFirstChild(p .. "_Live")
			local scriptables = child and child:FindFirstChild("Scriptables")
			local bossRig = scriptables and scriptables:FindFirstChild("BossRig")
			humanoid = bossRig and bossRig:FindFirstChildOfClass("Humanoid")

			if humanoid then
				break
			else
				task.wait(0.5)
			end
		end

		if not humanoid or count ~= v4 then
			return
		end

		local v5 = humanoid:FindFirstChildOfClass("Animator")

		if not v5 then
			v5 = Instance.new("Animator")
			v5.Parent = humanoid
		end

		for _, emoteID in emoteIDs do
			table.insert(v, loadTrack(v5, emoteID))
		end

		if #v == 0 then
			warn("[BossAnimationClient] No emote tracks loaded for BossRig")
			thread = nil
		else
			v3 = math.random(
				WCFinaleAdminAbuseConfig.BOSS_EMOTE_SWITCH_MIN_SEC,
				WCFinaleAdminAbuseConfig.BOSS_EMOTE_SWITCH_MAX_SEC
			)
			playIndex(math.random(1, #v)) -- equivalent call inferred; original call site unknown
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				if count ~= v4 then
					return
				end

				total += dt

				if v3 <= total then
					total = 0
					v3 = math.random(
						WCFinaleAdminAbuseConfig.BOSS_EMOTE_SWITCH_MIN_SEC,
						WCFinaleAdminAbuseConfig.BOSS_EMOTE_SWITCH_MAX_SEC
					)
					local v7 = v2
					local v8 = math.random(1, #v)

					if v8 == v7 and #v > 1 then
						if v8 == #v then
							v8 -= 1
						else
							v8 += 1
						end
					end

					playIndex(v8) -- equivalent call inferred; original call site unknown
				end
			end)
			thread = nil
		end
	end)
end

function BossAnimationClient.stop()
	count += 1

	if thread then
		pcall(task.cancel, thread)
		thread = nil
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for _, v4 in v do
		if v4.IsPlaying then
			v4:Stop(0)
		end
	end

	table.clear(v)
	v2 = nil
	total = 0
end

return BossAnimationClient