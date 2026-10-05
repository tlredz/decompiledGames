local parent = script.Parent
local CrunchTable = require(parent.CrunchTable)
local RunContext = require(parent.RunContext)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local Signal = require(parent.Signal)
require(parent.Trove)
local v = CrunchTable.new()
local patchFeed = Signal.new()
v:Begin(false):Add("Owner", CrunchTable.Enum.UINT53):Add("SongId", CrunchTable.Enum.STRING32):Add(
	"Volume",
	CrunchTable.Enum.FLOAT16
):Add(
	"Playing",
	CrunchTable.Enum.BOOLEAN
):Add(
	"TimePosition",
	CrunchTable.Enum.FLOAT32
)
v:End()
local event = Network.Event("RELICSxyz_AudioPatch", function(p)
	assert(type(p._b) == "buffer")
	return p
end)

local function sendAudioPatch(p, p2)
	local compressed = v:Compress(p)

	if RunContext.IsClient then
		event:Client():Fire(compressed)
	elseif p2 then
		event:Server():Fire(p2, compressed)
		p.Owner = p2.UserId
		patchFeed:Fire(p)
	end
end

local function findServerAudio(p: number)
	local folder = script:FindFirstChild((`ServerAudio{p}`))
	local audioPlayer = folder and folder:FindFirstChild("AudioPlayer")

	if folder and folder:IsA("Folder") and audioPlayer and audioPlayer:IsA("AudioPlayer") then
		return {
			Audio = audioPlayer,
			Bin = folder
		}
	end

	return nil
end

local function waitForServerAudioImpl(p: number, duration: number?)
	local v3 = Promise.new(function(callback, _, callback2)
		local thread = task.spawn(function()
			local v4

			while true do
				v4 = findServerAudio(p)

				if v4 then
					break
				end

				script.ChildAdded:Wait()
			end

			callback(v4)
		end)
		callback2(function()
			if thread then
				task.cancel(thread)
			end

			callback(nil)
		end)
	end)

	if duration then
		task.delay(duration, function()
			v3:cancel()
		end)
	else
		task.delay(5, function()
			if v3:getStatus() == "Started" then
				warn((`[RelicsXYZ] Infinite yield possible on Boombox.WaitForServerAudio({p})`))
				print(debug.traceback())
			end
		end)
	end

	return v3:expect()
end

if RunContext.IsServer then
	event:Server():On(function(p, p2)
		local decompressed = v:Decompress(p2)

		if decompressed then
			decompressed.Owner = p.UserId
			patchFeed:Fire(decompressed)
		end
	end)
else
	event:Client():On(function(p)
		local decompressed = v:Decompress(p)

		if decompressed then
			patchFeed:Fire(decompressed)
		end
	end)
end

return table.freeze({
	Bin = script,
	PatchFeed = patchFeed,
	Find = findServerAudio,
	Await = waitForServerAudioImpl,
	SendAudioPatch = sendAudioPatch
})