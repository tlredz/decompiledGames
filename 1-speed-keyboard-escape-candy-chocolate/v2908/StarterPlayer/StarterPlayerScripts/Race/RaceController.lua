local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceService = require(ReplicatedStorage.Services.RaceService)
local Chrono = require(ReplicatedStorage.Services.Chrono)
local RaceFormat = require(ReplicatedStorage.Services.RaceFormat)
local RaceRemotes = require(ReplicatedStorage.Services.RaceRemotes)
local localPlayer = Players.LocalPlayer
local formatTime = RaceFormat.FormatTime
local formatDelta = RaceFormat.FormatDelta
local v = Chrono.new()
local v2 = Chrono.new()
local v3 = false
local v4 = 0
local elapseds = {}
local elapseds2 = {}
local result = {}
local v5 = nil
local v6 = false
local v7 = nil
local v8 = {
	running = false,
	segIndex = 0,
	segElapsed = 0,
	segDelta = nil,
	segIsGold = false,
	segLive = false,
	cumElapsed = 0,
	cumDelta = nil,
	cumLive = false
}

local function getBestPaceUpTo(p: number)
	local total = 0

	for i = 1, p do
		if not result[i] then
			return nil
		end

		total += result[i]
	end

	return total
end

local function getSumOfBestSegments()
	local total = 0

	for i = 1, RaceService.GetStageCount() - 1 do
		if not result[i] then
			return nil
		end

		total += result[i]
	end

	return total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearFrozenDeltas()
	v5 = nil
	v6 = false
	v7 = nil
end

local function getLiveState()
	if v:IsRunning() then
		local segIndex = v4
		local elapsed = v2:GetElapsed()
		local elapsed2 = v:GetElapsed()
		local v10 = result[segIndex]
		local segDelta, segIsGold, segLive

		if v10 and v10 < elapsed then
			segDelta = elapsed - v10
			segIsGold = false
			segLive = true
		else
			segDelta = v5
			segIsGold = v6
			segLive = false
		end

		local v14 = 0

		for i = 1, segIndex - 1 do
			if result[i] then
				v14 += result[i]
			else
				v14 = nil
				break
			end
		end

		local v15 = v14 and v10 and v14 + v10 or nil
		local cumDelta, cumLive

		if v15 and v15 < elapsed2 then
			cumDelta = elapsed2 - v15
			cumLive = true
		else
			cumDelta = v7
			cumLive = false
		end

		v8.running = true
		v8.segIndex = segIndex
		v8.segElapsed = elapsed
		v8.segDelta = segDelta
		v8.segIsGold = segIsGold
		v8.segLive = segLive
		v8.cumElapsed = elapsed2
		v8.cumDelta = cumDelta
		v8.cumLive = cumLive
		return v8
	else
		v8.running = false
		v8.segIndex = 0
		v8.segElapsed = 0
		v8.segDelta = nil
		v8.segIsGold = false
		v8.segLive = false
		v8.cumElapsed = 0
		v8.cumDelta = nil
		v8.cumLive = false
		return v8
	end
end

local function resetRaceState()
	v:Reset()
	v2:Reset()
	v4 = 0
	elapseds = {}
	elapseds2 = {}
	clearFrozenDeltas() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function abortRace()
	if not v:IsRunning() then
		return
	end

	resetRaceState()
	RaceRemotes.RaceAbort:fire()
	print("[Race] Aborted")
end

RaceRemotes.RaceVoided:connect(function(p: string)
	if not v:IsRunning() then
		return
	end

	resetRaceState()
	print("[Race] Voided by server:", p)
end)

local function setEnabled(flag: boolean)
	v3 = flag
	RaceRemotes.RaceSetEnabled:fire(flag)

	if not flag then
		abortRace() -- equivalent call inferred; original call site unknown
	end
end

RaceService.PlayerEnteredStage:Connect(function(_, p: number)
	if not v3 then
		return
	end

	if v:IsRunning() then
		if p == v4 then
			return
		end

		if p == v4 + 1 then
			v4 = p
			local v9 = p - 1
			local elapsed = v:GetElapsed()
			elapseds[v9] = elapsed
			local elapsed2 = v2:Stop().elapsed
			v2:Reset()
			v2:Start()
			elapseds2[v9] = elapsed2
			local v10 = result[v9]
			local v11

			if v10 then
				v11 = elapsed2 - v10 or nil
			end

			local v12

			if v10 == nil then
				v12 = false
			else
				v12 = elapsed2 < v10
			end

			local v13 = 0

			for i = 1, v9 do
				if result[i] then
					v13 += result[i]
				else
					v13 = nil
					break
				end
			end

			local v14

			if v13 then
				v14 = elapsed - v13 or nil
			end

			v5 = v11
			v6 = v12
			v7 = v14

			if v10 == nil or elapsed2 < v10 then
				result[v9] = elapsed2
			end

			local stageCount = RaceService.GetStageCount()

			if p == stageCount then
				local v15 = v:Stop()
				local v16 = v15.isPersonalBest and " ★ NEW BEST" or ""
				print(string.format("[Race] Finished — %s%s", formatTime(v15.elapsed), v16))
				local v17 = 0

				for i = 1, RaceService.GetStageCount() - 1 do
					if result[i] then
						v17 += result[i]
					else
						v17 = nil
						break
					end
				end

				if v17 then
					print(string.format("[Race] Theoretical best: %s", formatTime(v17)))
				end

				print("[Race] Splits & Segments:")

				for i = 1, stageCount - 1 do
					local v18 = elapseds[i]
					local v19 = elapseds2[i]

					if v18 and v19 then
						print(string.format("  Stage %d: %s  (seg %s)", i, formatTime(v18), formatTime(v19)))
					end
				end
			else
				local v15 = v14 and string.format("%s (%s)", formatTime(elapsed), formatDelta(v14)) or formatTime(elapsed)
				local v16 = v11 and string.format(
					"seg: %s (%s)%s",
					formatTime(elapsed2),
					formatDelta(v11),
					v12 and " ★GOLD" or ""
				) or string.format("seg: %s", formatTime(elapsed2))
				print(string.format("[Race] Stage %d — %s  |  %s", v9, v15, v16))
			end
		else
			print(string.format("[Race] Stage out of order (%d, current %d) → abort", p, v4))
			abortRace() -- equivalent call inferred; original call site unknown
		end
	else
		if p ~= 1 then
			return
		end

		v4 = 1
		elapseds = {}
		elapseds2 = {}
		clearFrozenDeltas() -- equivalent call inferred; original call site unknown
		v:Reset()
		v:Start()
		v2:Reset()
		v2:Start()
		print("[Race] Started (Stage 1)")
	end
end)
localPlayer.CharacterAdded:Connect(abortRace)
v.NewBestTime:Connect(function(p: number)
	print(string.format("[Race] ★ Personal best: %s", formatTime(p)))
end)
RaceRemotes.RacePersonalBest:connect(function(p)
	if p.global > 0 then
		v:SetBestTime(p.global)
		print(string.format("[Race] PB global loaded: %s", formatTime(p.global)))
	end

	for k, segment in p.segments do
		result[k] = segment
	end

	if next(p.segments) then
		print("[Race] Segments received from server")
	end
end)
print("[Race] Init — state:", RaceService.GetPlayerState())
local RaceController = {}
RaceController.SetEnabled = setEnabled

function RaceController.GetRaceChrono()
	return v
end

function RaceController.GetBestSegments()
	return result
end

RaceController.GetSumOfBestSegments = getSumOfBestSegments
RaceController.GetLiveState = getLiveState
return RaceController