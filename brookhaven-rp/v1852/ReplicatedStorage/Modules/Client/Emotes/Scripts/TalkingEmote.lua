local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local TalkingEmote = {}
TalkingEmote.__index = TalkingEmote

function TalkingEmote.new()
	local self = setmetatable({}, TalkingEmote)
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
local function cloneToParent(p, part, head)
	local v = p._janitor:Add(part:Clone())
	v.Parent = head
	setParticlesEnabled(v, true)
end

function TalkingEmote:start(parent, p2, p3)
	local v = p3 ~= nil
	local v2 = not v or p3.isEnabled()
	local emotes = ReplicatedStorage:FindFirstChild("Emotes")

	if not emotes then
		return
	end

	local talking = emotes:FindFirstChild("Talking")

	if not talking then
		return
	end

	local head = parent:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) then
		return
	end

	local parent2 = self._janitor:Add(Instance.new("Folder"))
	parent2.Name = "TalkingAssets"
	parent2.Parent = parent
	local head2 = talking:FindFirstChild("Head")

	if head2 and head2:IsA("Folder") then
		for _, part in head2:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			else
				cloneToParent(self, part, head) -- equivalent call inferred; original call site unknown
			end
		end
	else
		for _, part in talking:GetChildren() do
			if part:IsA("BasePart") then
				attachPartToHead(self, part, head, parent2)
			end
		end
	end

	if v2 == false then
		setParticlesEnabled(parent2, false)
	end

	if v then
		self._janitor:Add(p3.onEnabledChanged:Connect(function(enabled: boolean)
			v2 = enabled
			setParticlesEnabled(parent2, enabled)
		end))
	end

	self._janitor:Add(p2.Stopped:Connect(function()
		self._janitor:Destroy()
	end))
end

return TalkingEmote