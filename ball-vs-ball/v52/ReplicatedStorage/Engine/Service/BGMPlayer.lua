local BGMPlayer = {}
local sounds = {}
local v = 0
local v2 = nil
local endedConnection = nil
local flag = false
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectEnded()
	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end
end

local function shufflePlaylist()
	for i = #sounds, 2, -1 do
		local integer = random:NextInteger(1, i)
		local v3 = sounds
		local v4 = sounds
		local v5 = sounds[integer]
		local v6 = sounds[i]
		v3[i] = v5
		v4[integer] = v6
	end
end

local playNext

playNext = function()
	if flag or #sounds == 0 then
		return
	end

	local v3 = v2
	disconnectEnded() -- equivalent call inferred; original call site unknown
	v += 1

	if v > #sounds then
		v = 1
		shufflePlaylist()

		if #sounds > 1 and sounds[1] == v3 then
			local v4 = sounds
			local v5 = sounds
			local v6 = sounds[2]
			local v7 = sounds[1]
			v4[1] = v6
			v5[2] = v7
		end
	end

	local v4 = sounds[v]
	v2 = v4
	v4.Looped = false
	v4.TimePosition = 0
	endedConnection = v4.Ended:Connect(function()
		if v2 == v4 then
			playNext()
		end
	end)
	v4:Play()
end

function BGMPlayer.Start(folder)
	assert(folder:IsA("Folder"), "BGMPlayer.Start 需要传入 Folder")
	disconnectEnded() -- equivalent call inferred; original call site unknown

	if v2 then
		v2:Stop()
		v2 = nil
	end

	table.clear(sounds)
	v = 0
	flag = false

	for _, sound in ipairs(folder:GetChildren()) do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	if #sounds == 0 then
		warn((`[BGMPlayer] 文件夹中没有直接子级 Sound: {folder:GetFullName()}`))
		return
	end

	shufflePlaylist()
	playNext()
end

function BGMPlayer.Pause()
	if flag then
		return
	end

	flag = true

	if v2 then
		v2:Pause()
	end
end

function BGMPlayer.Resume()
	if not flag then
		return
	end

	flag = false

	if v2 then
		v2:Resume()
	else
		playNext()
	end
end

return BGMPlayer