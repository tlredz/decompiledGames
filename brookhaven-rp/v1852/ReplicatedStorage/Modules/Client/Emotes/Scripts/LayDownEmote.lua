local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = { "Lay Down", "LayDown" }
local LayDownEmote = {}
LayDownEmote.__index = LayDownEmote

function LayDownEmote.new()
	local self = setmetatable({}, LayDownEmote)
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
		local v2

		if item.Parent == nil then
			v2 = false
		else
			v2 = item.IsPlaying == true
		end

		list[item] = v2

		if v2 then
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
	local v2 = p._janitor:Add(part:Clone())
	v2.Anchored = false
	v2.CanCollide = false
	v2.CanTouch = false
	v2.Massless = true
	v2.CFrame = head.CFrame
	v2.Parent = parent
	local head2 = v2:FindFirstChild("Head", true)

	if head2 and head2:IsA("Motor6D") then
		head2.Part0 = head
		head2.Part1 = v2
		head2.Parent = head
	else
		local v3 = p._janitor:Add(Instance.new("WeldConstraint"))
		v3.Part0 = head
		v3.Part1 = v2
		v3.Parent = v2
	end

	setParticlesEnabled(v2, true)
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

local function findTemplate(instance)
	for _, childName in v do
		local child = instance:FindFirstChild(childName)

		if child then
			return child
		end
	end

	return nil
end

function LayDownEmote:start(parent, p2, p3)
	local v2 = p3 ~= nil
	local v3 = not v2 or p3.isEnabled()
	local v4 = {}
	local v5 = {}
	local v6 = false
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local flag = true
	local child

	for _, childName in v do
		child = emotes:FindFirstChild(childName)

		if not child then
			continue
		end

		flag = false
		break
	end

	if flag then
		child = nil
	end

	if not child then
		return
	end

	local head = parent:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		return
	end

	local parent2 = self._janitor:Add(Instance.new("Folder"))
	parent2.Name = "LayDownAssets"
	parent2.Parent = parent
	local head2 = child:FindFirstChild("Head")

	if head2 and head2:IsA("Folder") then
		for _, part in head2:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			else
				cloneToParent(self, part, head, v4) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for _, part in child:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			end
		end
	end

	if v3 == false then
		setParticlesEnabled(parent2, false)
		stopSoundsAndCaptureState(v4, v5)
	else
		playSounds(v4)
		v6 = true
	end

	if v2 then
		self._janitor:Add(p3.onEnabledChanged:Connect(function(flag2: boolean)
			v3 = flag2
			setParticlesEnabled(parent2, flag2)

			if flag2 == false then
				stopSoundsAndCaptureState(v4, v5)
				return
			end

			if v6 ~= false then
				resumeStoppedSounds(v4, v5)
				return
			end

			playSounds(v4)
			v6 = true
		end))
	end

	self._janitor:Add(p2.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return LayDownEmote