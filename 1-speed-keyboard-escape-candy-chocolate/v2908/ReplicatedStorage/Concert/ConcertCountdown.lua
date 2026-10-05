local CollectionService = game:GetService("CollectionService")
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
require(ReplicatedStorage.SoundManager)
local v = { "rbxassetid://131538182531189", "rbxassetid://99709285619088" }
local flag = false
local v2 = false
local v3 = false
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function SetSurfaceGuiEnabled(surfaceGui, enabled: boolean)
	if surfaceGui:IsA("SurfaceGui") then
		surfaceGui.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetCountdownText(instance, text: string)
	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		instance.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetAllSurfaceGuisEnabled(enabled: boolean)
	for _, v5 in CollectionService:GetTagged("SceneCountdownSurfaceGui") do
		SetSurfaceGuiEnabled(v5, enabled) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetAllCountdownText(text: string)
	for _, v5 in CollectionService:GetTagged("SceneCountdownText") do
		SetCountdownText(v5, text) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatCountdown(p: number)
	local v5 = math.max(0, (math.ceil(p)))
	local v6 = math.floor(v5 / 3600)
	local v7 = math.floor(v5 % 3600 / 60)
	local v8 = v5 % 60
	return string.format("%02d:%02d:%02d", v6, v7, v8)
end

local ConcertCountdown = {
	Start = function()
		if flag then
			return
		end

		flag = true

		if RunService:IsServer() then
			SetAllSurfaceGuisEnabled(false) -- equivalent call inferred; original call site unknown
			CollectionService:GetInstanceAddedSignal("SceneCountdownSurfaceGui"):Connect(function(surfaceGui)
				SetSurfaceGuiEnabled(surfaceGui, false) -- equivalent call inferred; original call site unknown
			end)
		else
			SetAllSurfaceGuisEnabled(false) -- equivalent call inferred; original call site unknown
			CollectionService:GetInstanceAddedSignal("SceneCountdownSurfaceGui"):Connect(function(surfaceGui)
				SetSurfaceGuiEnabled(surfaceGui, v2 and not v3) -- equivalent call inferred; original call site unknown
			end)
			CollectionService:GetInstanceAddedSignal("SceneCountdownText"):Connect(function(instance)
				if v4 then
					SetCountdownText(instance, v4) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end,
	SetSuppressed = function(flag2: boolean)
		if not RunService:IsClient() or v3 == flag2 then
			return
		end

		v3 = flag2

		if flag2 then
			v2 = false
			SetAllSurfaceGuisEnabled(false) -- equivalent call inferred; original call site unknown
		end
	end,
	SetNextLaunchTimestamp = function(nextLaunchTimestamp: number)
		if not RunService:IsServer() then
			return
		end

		local v5

		if nextLaunchTimestamp == nextLaunchTimestamp then
			v5 = math.abs(nextLaunchTimestamp) < 1e999
		else
			v5 = false
		end

		assert(v5, "Concert countdown launch timestamp must be finite.")
		script:SetAttribute("NextLaunchTimestamp", nextLaunchTimestamp)
	end
}

function PremakeSounds()
	if not RunService:IsClient() then
		return
	end

	for _, soundId in v do
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
		sound.RollOffMinDistance = 425
		sound.RollOffMaxDistance = 800
		sound.Parent = script
	end
end

function PlayTickSound()
	if v3 then
		return
	end

	local v5 = CollectionService:GetTagged("SceneCountdownSurfaceGui")[1]
	local parent = v5 and v5.Parent

	if not (parent and parent:IsA("BasePart")) then
		return
	end

	local children = script:GetChildren()
	local clone = children[math.random(1, #children)]:Clone()
	clone.PlaybackSpeed = math.random(95, 110) / 100
	clone.Parent = parent
	clone:Play()
end

function ConcertCountdown.Update(flag2: boolean)
	if not RunService:IsClient() then
		return
	end

	local nextLaunchTimestamp = script:GetAttribute("NextLaunchTimestamp")
	local v5 = type(nextLaunchTimestamp) == "number"
	local v6 = not v5 and 0 or nextLaunchTimestamp - Workspace:GetServerTimeNow()

	if v5 then
		if v6 > 0 then
			v5 = not (flag2 or v3)
		else
			v5 = false
		end
	end

	if v2 ~= v5 then
		v2 = v5
		SetAllSurfaceGuisEnabled(v5) -- equivalent call inferred; original call site unknown
	end

	if not v5 then
		return
	end

	local text = FormatCountdown(v6) -- equivalent call inferred; original call site unknown

	if v4 ~= text then
		v4 = text
		SetAllCountdownText(text) -- equivalent call inferred; original call site unknown
		PlayTickSound()
	end
end

return ConcertCountdown