local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(255, 127, 0),
	Color3.fromRGB(255, 215, 0),
	Color3.fromRGB(100, 255, 50),
	Color3.fromRGB(0, 190, 255),
	Color3.fromRGB(122, 56, 255)
}
local v2 = { "rbxassetid://14796313307", "rbxassetid://14796313578" }
local v3 = { "rbxassetid://14796313153", "rbxassetid://14796313025" }
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local HSV = v[math.random(#v)]:ToHSV()

	for _, part in pairs(self:_GetObjects(true)) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Color = Color3.fromHSV((HSV + 0.1 * (math.random() - 0.5)) % 1, 1, 1)
		local clones = {}

		for _, child in pairs(script.Particles:GetChildren()) do
			local clone = child:Clone()
			clone.Color = ColorSequence.new(part.Color)
			clone.Parent = part
			table.insert(self._destroy_these, clone)
			table.insert(clones, clone)
		end

		Utility:PlayParticles(clones)
		self:CreateSound(v2[math.random(#v2)], 1, 1 + 0.2 * math.random(), nil, true, 5)
		self:CreateSound(v3[math.random(#v3)], 1, 1 + 0.2 * math.random(), nil, true, 5)
		wait(0.025 + 0.05 * math.random())
	end
end

function object:_Init() end

return object