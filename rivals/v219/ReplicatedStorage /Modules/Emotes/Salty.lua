local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.6, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	self:_PlayAnimation("rbxassetid://72081093559633")
	local clones = {}

	for _, child in pairs(script.Particles:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = self._humanoid.Parent and self._humanoid.Parent:FindFirstChild("LeftHand")
		table.insert(clones, clone)
		table.insert(self._destroy_these, clone)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function enable(enabled)
		for _, v in pairs(clones) do
			v.Enabled = enabled
		end
	end

	enable(false) -- equivalent call inferred; original call site unknown
	wait(0.5)
	self:CreateSound("rbxassetid://82749828642126", 1, 1, nil, true, 5)
	wait(0.2)
	enable(true) -- equivalent call inferred; original call site unknown
	wait(0.6)
	enable(false) -- equivalent call inferred; original call site unknown
end

function object:_Init() end

return object