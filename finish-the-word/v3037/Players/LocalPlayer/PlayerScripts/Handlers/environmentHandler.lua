local import = _G.import("event")
local import2 = _G.import("modelUtil")
local import3 = _G.import("mathUtil")
local import4 = _G.import("modeData")
local import5 = _G.import("environmentCollection")

local function playSounds(sounds, shuffle)
	if #sounds == 0 then
		return
	end

	local sound = Instance.new("Sound")
	sound.Parent = workspace
	local v = shuffle == false and sounds or import3.randomShuffle(sounds)
	task.spawn(function()
		while true do
			for _, v2 in ipairs(v) do
				sound.SoundId = v2.id
				sound.Volume = v2.volume
				sound:Play()
				sound.Ended:Wait()
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadEnvironment(startEnvironment)
	local v = import5:get(startEnvironment)
	import.fire("setLighting", startEnvironment)
	playSounds(v.sounds, v.shuffle)
end

local function gameLoaded()
	loadEnvironment(import4[import2.getAttribute(workspace, "Mode"):await()].StartEnvironment) -- equivalent call inferred; original call site unknown
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", gameLoaded)
		import.connect("loadEnvironment", loadEnvironment)
	end
}