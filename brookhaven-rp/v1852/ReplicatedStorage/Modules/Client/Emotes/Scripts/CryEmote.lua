local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local CryEmote = {}
CryEmote.__index = CryEmote

function CryEmote.new()
	local self = setmetatable({}, CryEmote)
	self._janitor = Janitor.new()
	return self
end

local function setParticlesEnabled(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end
end

local function playSounds(items)
	for _, item in items do
		if item.Parent ~= nil and item.IsPlaying == false then
			item:Play()
		end
	end
end

local function stopSoundsAndCaptureState(items, list)
	table.clear(list)

	for _, item in items do
		local v

		if item.Parent == nil then
			v = false
		else
			v = item.IsPlaying == true
		end

		list[item] = v

		if v then
			item:Stop()
		end
	end
end

local function resumeStoppedSounds(items, list)
	for _, item in items do
		if list[item] == true and item.Parent ~= nil and item.IsPlaying == false then
			item:Play()
		end
	end

	table.clear(list)
end

local function attachPartToHead(p, part, head, parent)
	local v = p._janitor:Add(part:Clone())
	v.Anchored = false
	v.CanCollide = false
	v.CanTouch = false
	v.Massless = true
	v.CFrame = head.CFrame
	v.Parent = parent
	local head2 = v:FindFirstChild("Head", true)

	if head2 and head2:IsA("Motor6D") then
		head2.Part0 = head
		head2.Part1 = v
		head2.Parent = head
	else
		local v2 = p._janitor:Add(Instance.new("WeldConstraint"))
		v2.Part0 = head
		v2.Part1 = v
		v2.Parent = v
	end

	setParticlesEnabled(v, true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cloneToParent(p, part, head, sounds)
	local sound = p._janitor:Add(part:Clone())
	sound.Parent = head
	setParticlesEnabled(sound, true)

	if sound:IsA("Sound") then
		table.insert(sounds, sound)
	end
end

function CryEmote:start(parent, p2, p3)
	local v = p3 ~= nil
	local v2 = not v or p3.isEnabled()
	local v3 = {}
	local v4 = {}
	local v5 = false
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local cry = emotes:FindFirstChild("Cry")

	if not cry then
		return
	end

	local head = parent:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		return
	end

	local parent2 = self._janitor:Add(Instance.new("Folder"))
	parent2.Name = "CryAssets"
	parent2.Parent = parent
	local head2 = cry:FindFirstChild("Head")

	if head2 and head2:IsA("Folder") then
		for _, part in head2:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			else
				cloneToParent(self, part, head, v3) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for _, part in cry:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			end
		end
	end

	if v2 == false then
		setParticlesEnabled(parent2, false)
		stopSoundsAndCaptureState(v3, v4)
	else
		playSounds(v3)
		v5 = true
	end

	if v then
		self._janitor:Add(p3.onEnabledChanged:Connect(function(enabled: boolean)
			v2 = enabled
			setParticlesEnabled(parent2, enabled)

			if enabled == false then
				stopSoundsAndCaptureState(v3, v4)
				return
			end

			if v5 ~= false then
				resumeStoppedSounds(v3, v4)
				return
			end

			playSounds(v3)
			v5 = true
		end))
	end

	self._janitor:Add(p2.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return CryEmote