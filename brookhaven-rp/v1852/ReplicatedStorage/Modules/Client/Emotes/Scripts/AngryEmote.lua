local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AngryEmote = {}
AngryEmote.__index = AngryEmote

function AngryEmote.new()
	local self = setmetatable({}, AngryEmote)
	self._janitor = Janitor.new()
	self._sounds = {}
	return self
end

local function setParticlesEnabled(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end
end

local function collectSounds(p, sound)
	if sound:IsA("Sound") then
		table.insert(p._sounds, sound)
	end

	for _, sound2 in sound:GetDescendants() do
		if sound2:IsA("Sound") then
			table.insert(p._sounds, sound2)
		end
	end
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
	collectSounds(p, v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cloneToParent(p, part, head)
	local v = p._janitor:Add(part:Clone())
	v.Parent = head
	setParticlesEnabled(v, true)
	collectSounds(p, v)
end

function AngryEmote:start(parent, object, p2)
	object.Looped = true
	local v = p2 ~= nil
	local v2 = not v or p2.isEnabled()
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local angry = emotes:FindFirstChild("Angry")

	if not angry then
		return
	end

	local head = parent:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		return
	end

	local parent2 = self._janitor:Add(Instance.new("Folder"))
	parent2.Name = "AngryAssets"
	parent2.Parent = parent
	local head2 = angry:FindFirstChild("Head")

	if head2 and head2:IsA("Folder") then
		for _, part in head2:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			else
				cloneToParent(self, part, head) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for _, part in angry:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			end
		end
	end

	if v2 == false then
		setParticlesEnabled(parent2, false)

		for _, _sound in self._sounds do
			if _sound.Parent ~= nil then
				_sound:Stop()
			end
		end
	end

	self._janitor:Add(object:GetMarkerReachedSignal("Sound"):Connect(function()
		if v2 == false then
			return
		end

		for _, _sound in self._sounds do
			if _sound.Parent ~= nil then
				_sound:Play()
			end
		end
	end))

	if v then
		self._janitor:Add(p2.onEnabledChanged:Connect(function(flag: boolean)
			v2 = flag

			if flag == false then
				setParticlesEnabled(parent2, false)

				for _, _sound in self._sounds do
					if _sound.Parent ~= nil then
						_sound:Stop()
					end
				end
			end
		end))
	end

	self._janitor:Add(object.DidLoop:Connect(function()
		if v2 == true then
			setParticlesEnabled(parent2, true)
		end
	end))
	self._janitor:Add(object.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return AngryEmote