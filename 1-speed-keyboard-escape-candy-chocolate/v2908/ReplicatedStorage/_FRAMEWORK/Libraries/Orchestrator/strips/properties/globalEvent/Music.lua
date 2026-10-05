local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
require(script.Parent.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.Parent.types.Save)
require(script.Parent.Parent.Parent.Parent.types.Strip)
local MusicPreviewManager

if Common.IsPlugin() then
	MusicPreviewManager = require(ServerStorage.DevPlugin.Pages.Orchestrator.MusicPreviewManager)
else
	MusicPreviewManager = nil
end

local MusicManager

if Common.IsPlugin() then
	MusicManager = nil
else
	MusicManager = require(ReplicatedStorage._FRAMEWORK.Features.MusicManager)
end

local v = { "PLAY", "STOP" }
local dataTemplate = {
	mode = "PLAY",
	assetId = "",
	name = "OrchestratorMusic",
	priority = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function applyGameMusicEvent(data)
	local v3 = MusicManager

	if data.mode == "PLAY" then
		v3.play(data.assetId, data.name, data.priority)
	else
		v3.stop(data.name)
	end
end

local function previewMusicEvent(data)
	local success, result = pcall(function()
		if MusicPreviewManager == nil then
			applyGameMusicEvent(data) -- equivalent call inferred; original call site unknown
		elseif data.mode == "PLAY" then
			MusicPreviewManager.play(data.assetId, data.name, data.priority)
		else
			MusicPreviewManager.stop(data.name)
		end
	end)

	if not success then
		warn(string.format("Could not preview Music event: %s", (tostring(result))))
	end
end

local function getDesiredTimePosition(p: number, p2: number)
	if p > 0 then
		return p2 % p
	end

	return p2
end

local function reconcileTimePosition(data, p, p2: number)
	local timeLength = data.getTimeLength(p.music)
	local timePosition = data.getTimePosition(p.music)

	if timeLength == nil or timePosition == nil then
		return false
	end

	local v3 = math.max(p2 - p.startTimeSeconds, 0)

	if timeLength > 0 then
		v3 %= timeLength
	end

	local v4 = math.abs(timePosition - v3)

	if timeLength > 0 then
		v4 = math.min(v4, (math.max(timeLength - v4, 0)))
	end

	if v4 >= 1 then
		data.setTimePosition(p.music, v3)
	end

	return true
end

local function createGameRuntime(p, callback)
	local v3 = false

	local function reconcileAtTime(timeSeconds: number)
		for _, keyframe in p.keyframes do
			if timeSeconds < keyframe.timeSeconds then
				break
			end

			applyGameMusicEvent(keyframe.data) -- equivalent call inferred; original call site unknown
		end
	end

	return {
		attach = function(_, _, p2)
			if not p2.isGlobal then
				callback("Music only supports the Global actor.")
				return false
			end

			v3 = true
			reconcileAtTime(p2.timeSeconds)
			return true
		end,
		update = function(_, data)
			if v3 and not data.isCatchUp and not data.isSeeking and data.timeSeconds > data.previousTimeSeconds then
				for _, keyframe in p.keyframes do
					if not (keyframe.timeSeconds > data.previousTimeSeconds and keyframe.timeSeconds <= data.timeSeconds) then
						continue
					end

					applyGameMusicEvent(keyframe.data) -- equivalent call inferred; original call site unknown
				end
			end
		end,
		detach = function(_, _: string, _: boolean)
			v3 = false
		end,
		destroy = function(_, _: string, _: boolean)
			v3 = false
		end
	}
end

local function createPreviewRuntime(p, callback, MusicPreviewManager2)
	local v3 = {}
	local flag = false
	local flag2 = false

	local function applyKeyframe(keyframe)
		local data = keyframe.data

		if data.mode == "PLAY" then
			local music = MusicPreviewManager2.play(data.assetId, data.name, data.priority)
			v3[data.name] = {
				music = music,
				resumeOnPlayback = false,
				startTimeSeconds = keyframe.timeSeconds
			}
		else
			MusicPreviewManager2.stop(data.name)
			v3[data.name] = nil
		end
	end

	local function reconcileTracks(p2: number)
		for k, v4 in v3 do
			if not reconcileTimePosition(MusicPreviewManager2, v4, p2) then
				v3[k] = nil
			end
		end
	end

	local function rebuildTracks(timeSeconds: number)
		local v4 = {}
		local v5 = {}

		for _, keyframe in p.keyframes do
			if timeSeconds < keyframe.timeSeconds then
				break
			end

			local data = keyframe.data

			if data.mode == "PLAY" then
				local v6 = v4[data.name]

				if v6 ~= nil then
					v5[v6.data.priority] = nil
				end

				local v7 = v5[data.priority]

				if v7 ~= nil then
					v4[v7] = nil
				end

				v4[data.name] = {
					data = data,
					timeSeconds = keyframe.timeSeconds
				}
				v5[data.priority] = data.name
			else
				local v6 = v4[data.name]

				if v6 ~= nil then
					v5[v6.data.priority] = nil
				end

				v4[data.name] = nil
			end
		end

		for k, v6 in v3 do
			local v7 = v4[k]
			local v8

			if v7 == nil or tostring(v6.music.assetId) ~= tostring(v7.data.assetId) or v6.music.priority ~= v7.data.priority then
				v8 = false
			else
				v8 = MusicPreviewManager2.getTimePosition(v6.music) ~= nil
			end

			if v8 then
				v6.startTimeSeconds = v7.timeSeconds
				v4[k] = nil
			else
				MusicPreviewManager2.stopTrack(v6.music)
				v3[k] = nil
			end
		end

		local v6 = {}

		for _, v7 in v4 do
			table.insert(v6, v7)
		end

		table.sort(v6, function(a, b)
			return a.timeSeconds < b.timeSeconds
		end)

		for _, v7 in v6 do
			local music = MusicPreviewManager2.play(v7.data.assetId, v7.data.name, v7.data.priority)
			v3[v7.data.name] = {
				music = music,
				resumeOnPlayback = false,
				startTimeSeconds = v7.timeSeconds
			}
		end

		reconcileTracks(timeSeconds)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pauseTracks()
		for _, v4 in v3 do
			if MusicPreviewManager2.pause(v4.music) then
				v4.resumeOnPlayback = true
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resumeTracks()
		for _, v4 in v3 do
			if not v4.resumeOnPlayback then
				continue
			end

			MusicPreviewManager2.resume(v4.music)
			v4.resumeOnPlayback = false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearTracks()
		for _, v4 in v3 do
			MusicPreviewManager2.stopTrack(v4.music)
		end

		table.clear(v3)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function release()
		clearTracks() -- equivalent call inferred; original call site unknown
		flag = false
	end

	return {
		attach = function(_, _, p2)
			if not p2.isGlobal then
				callback("Music only supports the Global actor.")
				return false
			end

			flag = true
			rebuildTracks(p2.timeSeconds)

			if flag2 then
				pauseTracks() -- equivalent call inferred; original call site unknown
			end

			return true
		end,
		update = function(_, data)
			if flag then
				if data.isSeeking then
					rebuildTracks(data.timeSeconds)

					if flag2 then
						pauseTracks() -- equivalent call inferred; original call site unknown
					end
				elseif not data.isCatchUp and data.timeSeconds > data.previousTimeSeconds then
					for _, keyframe in p.keyframes do
						if keyframe.timeSeconds > data.previousTimeSeconds and keyframe.timeSeconds <= data.timeSeconds then
							applyKeyframe(keyframe)
						end
					end
				end

				reconcileTracks(data.timeSeconds)
			end
		end,
		pause = function(_)
			flag2 = true
			pauseTracks() -- equivalent call inferred; original call site unknown
		end,
		resume = function(_)
			flag2 = false
			resumeTracks() -- equivalent call inferred; original call site unknown
		end,
		detach = function(_, _: string, _: boolean)
			release() -- equivalent call inferred; original call site unknown
		end,
		destroy = function(_, _: string, _: boolean)
			release() -- equivalent call inferred; original call site unknown
			flag2 = false
		end
	}
end

local Music = {}
Music.stripType = "property"
Music.playbackMode = "custom"
Music.propertyName = "Music"
Music.context = "server"
Music.catchUpPolicies = { "latest", "skip" }
Music.dataTemplate = dataTemplate
Music.supportsGlobal = true

function Music.buildEditor(p, state, _)
	p.Components:AddDropdown(function(object)
		object:SetText("Mode"):SetChoiceList(v):SetSelected(state.mode):SetOnChanged(function(p2: string)
			state.mode = p2 == "STOP" and "STOP" or "PLAY"
		end)
	end)
	p.Components:AddField(function(object)
		object:SetText("Asset ID"):SetValue(state.assetId):SetOnChangedUnfocus(function(assetId: string)
			state.assetId = assetId
		end)
	end)
	p.Components:AddField(function(object)
		object:SetText("Track Name"):SetValue(state.name):SetOnChangedUnfocus(function(name: string)
			state.name = name
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Priority"):SetValue(state.priority):SetOnChangedUnfocus(function(priority: number)
			state.priority = priority
		end)
	end)
	p.Components:AddButton(function(object)
		object:SetButtonText("Preview Event"):SetButtonCallback(function()
			previewMusicEvent(state)
		end)
	end)
	p.Components:AddButton(function(object)
		object:SetButtonText("Stop All Music"):SetButtonCallback(function()
			if MusicPreviewManager == nil then
				MusicManager.stopAll()
			else
				MusicPreviewManager.stopAll()
			end
		end)
	end)
end

function Music.supports(_)
	return false
end

function Music.capture(_, _)
	return table.clone(dataTemplate)
end

function Music.createRuntime(p, p2)
	if MusicPreviewManager == nil then
		return (createGameRuntime(p, p2))
	end

	return (createPreviewRuntime(p, p2, MusicPreviewManager))
end

return Music