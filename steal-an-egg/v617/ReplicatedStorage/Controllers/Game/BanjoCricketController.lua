local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Aim = require(script.Aim)
local BanjoCricket = require(ReplicatedStorage.Data.BanjoCricket)
local BanjoCricketFlags = require(ReplicatedStorage.Shared.Flags.BanjoCricketFlags)
local Mushrooms = require(script.Mushrooms)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Reveal = require(script.Reveal)
local Save = require(ReplicatedStorage.Shared.Save)
local Sounds = require(script.Sounds)
local Spores = require(script.Spores)
local Talk = require(script.Talk)
local Timer = require(ReplicatedStorage.Packages.Timer)
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local random = Random.new()
		local v = "Idle"
		local count = 0
		local v2 = 0
		local v3 = nil
		local now = 0
		local v4 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function sing(p: number)
			Mushrooms.Flash(p, BanjoCricket.Timing.Note)
			Mushrooms.Move(p, "Bounce")
			Sounds.Note(p)
			Spores.Puff(p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mute(p: number)
			Mushrooms.Move(p, "Squish")
			Sounds.Muted(p)
		end

		local function predict(mushroom: number)
			local now2 = os.clock()
			now = now2

			if v == "Busy" or v == "Showing" then
				mute(mushroom) -- equivalent call inferred; original call site unknown
				v3 = {
					Kind = "Muted",
					Mushroom = mushroom,
					At = now2
				}
			else
				sing(mushroom) -- equivalent call inferred; original call site unknown
				v3 = {
					Kind = "Note",
					Mushroom = mushroom,
					At = now2
				}
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function wasPredicted(p: string, mushroom: number)
			local v5 = v3

			if v5 == nil or v5.Kind ~= p or v5.Mushroom ~= mushroom or os.clock() - v5.At > 1.2 then
				return false
			end

			v3 = nil
			return true
		end

		local function playback(notes)
			count += 1
			local v5 = count
			v = "Showing"
			Mushrooms.SetProgress(v2, true)
			local timing = BanjoCricket.Timing
			local playbackSeconds = BanjoCricket.PlaybackSeconds(#notes)
			Sounds.Duck(playbackSeconds + 0.5)

			for k, v6 in notes do
				local v7 = (k - 1) * (timing.Note + timing.NoteGap)
				local v8 = v6
				task.delay(v7, function()
					if count == v5 then
						sing(v8) -- equivalent call inferred; original call site unknown
					end
				end)
			end

			task.delay(playbackSeconds, function()
				if count == v5 then
					v = "Listening"
					Mushrooms.Pulse()
				end
			end)
		end

		local function fail(mushroom: number)
			count += 1
			local v5 = count
			v = "Busy"
			v3 = nil
			v2 = 0
			Mushrooms.Darken()
			Mushrooms.MoveAll("Shake")
			Mushrooms.MoveAll("Droop")
			Sounds.Sour(mushroom)
			Spores.Wilt()
			Mushrooms.SetProgress(v2, true)
			task.delay(BanjoCricket.Timing.WrongPause, function()
				if count == v5 then
					v = "Idle"
					Mushrooms.SetProgress(v2, false)
				end
			end)
		end

		local function clearStage(cleared: number)
			count += 1
			v = "Busy"
			v2 = cleared
			Mushrooms.Celebrate()
			Mushrooms.SetProgress(v2, true)
			Sounds.Run()
			Spores.Spiral()
			Reveal.Strain(cleared / BanjoCricketFlags.Stages:Get())
		end

		local function onEffect(data)
			if data.Kind == "Note" then
				-- equivalent call inferred; original call site unknown
				if not wasPredicted("Note", data.Mushroom) then
					sing(data.Mushroom) -- equivalent call inferred; original call site unknown
				end

				if v == "Idle" then
					v = "Busy"
				end
			elseif data.Kind == "Muted" then
				-- equivalent call inferred; original call site unknown
				if not wasPredicted("Muted", data.Mushroom) then
					mute(data.Mushroom) -- equivalent call inferred; original call site unknown
				end
			elseif data.Kind == "Wrong" then
				fail(data.Mushroom)
			elseif data.Kind == "Playback" then
				playback(data.Notes)
			elseif data.Kind == "StageComplete" then
				clearStage(data.Cleared)
			elseif data.Kind == "Reset" then
				count += 1
				v = "Idle"
				v3 = nil
				v2 = 0
				Mushrooms.Darken()
				Mushrooms.SetProgress(v2, false)
			elseif data.Kind == "Solved" then
				count += 1
				v = "Solved"
				v2 = BanjoCricketFlags.Stages:Get()
				Mushrooms.SetProgress(v2, true)
				Reveal.Play()
			end
		end

		local function onBump(p: number)
			if v ~= "Idle" and v ~= "Solved" then
				return
			end

			now = os.clock()
			Mushrooms.Move(p, "Squish")
			Sounds.Soft(p)
		end

		local function invite()
			local now2 = os.clock()

			if v ~= "Idle" or now2 < v4 or now2 - now < 6 or not BanjoCricketFlags.Enabled:Get() then
				return
			end

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or Mushrooms.DistanceFrom(humanoidRootPart.Position) > 35 then
				return
			end

			local randomIndex = Mushrooms.RandomIndex(random)

			if randomIndex == nil then
				return
			end

			v4 = now2 + random:NextNumber(4, 7)
			Mushrooms.Move(randomIndex, "Hop")
			Sounds.Soft(randomIndex, -1)
		end

		local function applySaved()
			local v5 = Save.Peek()

			if v5 == nil then
				return
			end

			local banjoCricket = v5.BanjoCricket

			if banjoCricket.Solved and v ~= "Solved" then
				v = "Solved"
				v2 = BanjoCricketFlags.Stages:Get()
				Mushrooms.SetProgress(v2, true)
				Reveal.Open()
			elseif not banjoCricket.Solved and v == "Solved" then
				v = "Idle"
				v2 = 0
				Mushrooms.SetProgress(v2, false)
			end

			Talk.Sync(banjoCricket.Solved, banjoCricket.Claimed)
		end

		Mushrooms.Start(onBump)
		Reveal.Start()
		Talk.Start()
		Aim.Start(predict)
		Save.WatchFields({ "BanjoCricket" }, applySaved)

		if Save.IsLoaded() then
			applySaved()
		else
			Save.Loaded:Connect(applySaved)
		end

		Remotes.BanjoCricket.Effect.OnClientEvent:Connect(onEffect)
		Remotes.BanjoCricket.Squish.OnClientEvent:Connect(function(p: number)
			Mushrooms.Squish(p)
		end)
		Timer.Simple(0.5, invite)
	end
}