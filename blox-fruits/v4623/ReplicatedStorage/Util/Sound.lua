local createVector = vector.create
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local Groups = require(script.Groups)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local isRunning = RunService:IsRunning()
local isUnitTest = GlobalUtil.FFlags.IsUnitTest
local v = {
	Boost = 1.05,
	Max = 1.5
}
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
local parent2 = workspace._WorldOrigin:FindFirstChild("Sounds")

if isRunning and isUnitTest == false and not parent2 then
	parent2 = Instance.new("Folder", workspace._WorldOrigin)
	assert(parent2, "bad sounds")
	parent2.Name = "Sounds"
end

local sound = game.ReplicatedStorage.Storage:WaitForChild("Sound", 1) or Instance.new("Folder")
local v3 = {}

local function getLocation(value: string)
	local child = nil

	for childName in string.gmatch(value, "([^.]+)") do
		child = (child or sound):FindFirstChild(childName)
	end

	return child
end

local function materialize(template)
	local function get(attributeName: string)
		return template:GetAttribute(attributeName)
	end

	local sound2 = Instance.new("Sound")
	sound2.PlaybackSpeed = template:GetAttribute("PlaybackSpeed")
	sound2.RollOffMinDistance = template:GetAttribute("RollOffMinDistance")
	sound2.RollOffMaxDistance = template:GetAttribute("RollOffMaxDistance")
	sound2.RollOffMode = template:GetAttribute("RollOffMode")
	sound2.TimePosition = template:GetAttribute("TimePosition")
	sound2.SoundId = template:GetAttribute("SoundId")
	sound2.PlayOnRemove = template:GetAttribute("PlayOnRemove")
	sound2.Playing = template:GetAttribute("Playing")
	sound2.Looped = template:GetAttribute("Looped")
	sound2.Name = template.Name
	sound2.Volume = template:GetAttribute("Volume")
	return sound2
end

local function resolveEntry(childName: string)
	local v4 = v3[childName]

	if v4 and v4.Template.Parent ~= nil then
		return v4
	end

	v3[childName] = nil
	local child

	if childName:find("%.") then
		child = getLocation(childName)
	else
		child = sound:FindFirstChild(childName, true)
	end

	if not child then
		return nil
	end

	local v5 = {
		Template = child,
		Materialized = nil,
		GroupName = Groups.resolveTemplateGroup(child, sound)
	}
	v3[childName] = v5
	return v5
end

local function scaledVolume(p, p2: number)
	return math.clamp(p2 * 1.05, 0, 1.5) * p.__GlobalVolume
end

local v4 = {
	__GlobalVolume = 1,
	__Disabled = {},
	Storage = sound,
	Kill = function(self, instance)
		pcall(function()
			instance:Stop()
		end)
		local parent = instance.Parent

		if parent and parent2 and instance:IsDescendantOf(parent2) and parent:IsA("BasePart") then
			parent:Destroy()
		elseif parent then
			instance:Destroy()
		end
	end,
	Play = function(self, p, cFrame, p2, p3, p4, p5)
		local playOptions = Groups.parsePlayOptions(p2, p3, p4, p5)
		local entry = resolveEntry(p)

		if not entry then
			return Instance.new("Sound")
		end

		if cFrame then
			if typeof(cFrame) == "table" then
				cFrame = cFrame.CFrame
			end

			if typeof(cFrame) == "CFrame" then
				cFrame = cFrame.Position
			end

			if typeof(cFrame) == "Vector3" then
				local part = Instance.new("Part")
				part.Name = "ProxySound"
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.Transparency = 1
				part.Size = createVector(0.05, 0.05, 0.05)
				part.CFrame = CFrame.new(cFrame)
				part.Parent = parent2
				part.ChildRemoved:Connect(function()
					part:Destroy()
				end)
				cFrame = part
			end
		else
			cFrame = nil
		end

		local template = entry.Template
		local clone

		if template:IsA("Sound") then
			clone = template:Clone()

			if playOptions.volume then
				clone.Volume = math.clamp(playOptions.volume * v.Boost, 0, v.Max) * self.__GlobalVolume
			end
		else
			local materialized = entry.Materialized or materialize(template)
			entry.Materialized = materialized
			clone = materialized:Clone()
			clone.Volume = math.clamp((playOptions.volume or template:GetAttribute("Volume")) * v.Boost, 0, v.Max) * self.__GlobalVolume
		end

		if playOptions.speed then
			clone.PlaybackSpeed = playOptions.speed
		end

		if playOptions.radius then
			clone.RollOffMinDistance = playOptions.radius * 4
			clone.RollOffMaxDistance = playOptions.radius * 40
		end

		Groups.assign(clone, playOptions.group or entry.GroupName)

		if not self.__Disabled[p] then
			clone.Ended:Connect(function()
				self:Kill(clone)
			end)

			if playOptions.fadeIn then
				local volume = clone.Volume
				clone.Volume = 0

				if isClient then
					TweenService:Create(
						clone,
						TweenInfo.new(playOptions.fadeIn, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{
							Volume = volume
						}
					):Play()
				elseif isServer then
					task.delay(playOptions.fadeIn, function()
						clone.Volume = volume
					end)
				end
			end

			clone:Play()
		end

		clone.Parent = cFrame or parent2
		return clone
	end,
	PlayUI = function(p, p2, p3)
		local v5 = resolveEntry(`UI.{p2}`) or resolveEntry(p2)

		if not v5 then
			return Instance.new("Sound")
		end

		local template = v5.Template
		local clone

		if template:IsA("Sound") then
			clone = template:Clone()

			if p3 then
				clone.Volume = math.clamp(p3 * v.Boost, 0, v.Max) * p.__GlobalVolume
			end
		else
			local materialized = v5.Materialized or materialize(template)
			v5.Materialized = materialized
			clone = materialized:Clone()

			if p3 then
				clone.Volume = math.clamp(p3 * v.Boost, 0, v.Max) * p.__GlobalVolume
			end
		end

		Groups.assign(clone, "HighPriority")
		clone.Ended:Connect(function()
			clone:Destroy()
		end)
		clone.Parent = SoundService
		clone:Play()
		return clone
	end,
	FadeOut = function(self, p, duration, p2)
		if not (p and p.Parent) then
			return
		end

		if isClient then
			if p2 and typeof(p2) ~= "TweenInfo" then
				warn("not of type tweenInfo", p)
				p2 = nil
			end

			local tween = TweenService:Create(
				p,
				p2 or TweenInfo.new(duration or 1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
				{
					Volume = 0
				}
			)
			tween.Completed:Connect(function()
				self:Kill(p)
			end)
			tween:Play()
		elseif isServer then
			local sound2 = game.ReplicatedStorage.Remotes.Sound
			local Global = require(game.ReplicatedStorage.Global)
			sound2:FireAllClients("FadeOut", Global.Encode(p), duration)
			task.delay(duration, function()
				self:Kill(p)
			end)
		end
	end,
	Preload = function(self, p)
		task.spawn(function()
			local location = getLocation(p)

			if not location then
				return
			end

			local soundId = location:GetAttribute("SoundId") or location:IsA("Sound") and location.SoundId

			if soundId then
				local ContentProvider = game:GetService("ContentProvider")
				ContentProvider:PreloadAsync({ soundId })
			end
		end)
	end,
	Get = function(_, p)
		return (getLocation(p))
	end,
	SetGlobalVolume = function(p, globalVolume)
		p.__GlobalVolume = globalVolume
	end,
	SetDisabled = function(p, options)
		p.__Disabled = options or {}
	end
}

if isClient and isRunning and isUnitTest == false then
	if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Dressrosa") then
		v4:Preload("AnimatedBattle.FXWithMusic")
	end

	Groups.initCompressors()
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sound").OnClientEvent:Connect(function(p: string, p2, ...)
		local Global = require(game.ReplicatedStorage.Global)
		local encoded = Global.Encode(p2)
		v4[p](v4, encoded, ...)
	end)
	return v4
elseif isServer and isRunning and isUnitTest == false then
	return (setmetatable({}, {
		__index = function(_, p)
			return v4[p]
		end
	}))
else
	return {
		Kill = function(...) end,
		Play = function(...) end,
		FadeOut = function(...) end,
		Preload = function(...) end,
		Get = function(...) end,
		SetGlobalVolume = function(...) end,
		SetDisabled = function(...) end
	}
end