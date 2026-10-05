local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remo = require(ReplicatedStorage.Packages.remo)
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local SoundManager = {}
local gameSounds

if RunService:IsClient() then
	gameSounds = SoundService:FindFirstChild("GameSounds") or Instance.new("Folder")
	gameSounds.Name = "GameSounds"
	gameSounds.Parent = SoundService
else
	gameSounds = nil
end

local v = {}

function Preload()
	if RunService:IsServer() then
		return
	end

	local v2 = {}

	for k, v3 in pairs(Config.SOUNDS) do
		local sound = Instance.new("Sound")
		sound.Name = k
		sound.SoundId = v3.ID
		sound.Volume = v3.Volume or 0.5
		sound.Parent = gameSounds
		v[k] = sound
		table.insert(v2, sound)
	end

	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(v2)
		end)
	end)
end

Preload()

function SoundManager:Play(p: string)
	local v2 = v[p]

	if not v2 then
		warn("[SoundManager] Son inexistant : " .. tostring(p))
		return
	end

	local clone = v2:Clone()
	clone.Parent = gameSounds
	clone.PlaybackSpeed = v2.PlaybackSpeed * (math.random(95, 105) / 100)
	clone:Play()
	clone.Ended:Connect(function()
		clone:Destroy()
	end)
end

function SoundManager:PlayLevelUp()
	self:Play("LEVEL_UP")
end

function SoundManager:PlayRebirth()
	self:Play("REBIRTH")
end

function SoundManager:PlayCollect()
	self:Play("COLLECT")
end

function SoundManager:PlayWin()
	self:Play("WIN")
end

local flag = false
local remotes = remo.createRemotes({
	SoundManager_Play = remo.remote()
})

function SoundManager.SetupRemotes(_)
	if flag then
		return
	end

	flag = true

	if RunService:IsClient() then
		remotes.SoundManager_Play:connect(function(p: string)
			SoundManager:Play(p)
		end)
	end
end

function SoundManager.PlayForPlayer(_, p, p2: string)
	assert(RunService:IsServer(), "SoundManager:PlayForPlayer may not be called on the client")
	remotes.SoundManager_Play:fire(p, p2)
end

function SoundManager.PlayForEveryone(_, p: string)
	assert(RunService:IsServer(), "SoundManager:PlayForEveryone may not be called on the client")
	remotes.SoundManager_Play:fireAll(p)
end

return SoundManager