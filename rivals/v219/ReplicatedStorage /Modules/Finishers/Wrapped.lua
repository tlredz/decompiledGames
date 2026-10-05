local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Ragdoll.PlayClient(object2, ...)

	for _, instance in pairs(object2:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			if instance.Name ~= "Head" and not (instance.Transparency >= 0.99) then
				local v = math.random() < 0.5
				instance.Color = v and Color3.fromRGB(247, 42, 55) or Color3.fromRGB(14, 150, 57)
				instance.Material = Enum.Material.SmoothPlastic
				instance.MaterialVariant = v and "WrappingPearlescent" or "WrappingPaper"

				for _, child in pairs(script.Textures:GetChildren()) do
					local clone = child:Clone()
					clone.Parent = instance
				end
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			instance:Destroy()
		end
	end

	object2:CreateSound("rbxassetid://74885181688460", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object