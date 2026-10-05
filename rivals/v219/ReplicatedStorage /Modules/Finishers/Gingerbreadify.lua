local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.CosmeticLibrary)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
require(ReplicatedStorage.Modules.Utility)
local v = {
	{ "RightUpperArm", "RightLowerArm", "RightHand" },
	{ "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	{ "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	{ "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	{ "UpperTorso", "LowerTorso", "Head" }
}
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2, ...)
	Ragdoll.PlayServer(object2, ...)
	wait(#v * 0.2 + 1)
	object2:_HideBody()
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") then
			if not (instance.Transparency >= 0.99) then
				instance.Color = Color3.fromRGB(106, 73, 50)
				instance.Material = Enum.Material.Slate

				if instance.Name == "Head" then
					local clone = script.Head:Clone()
					clone.Parent = instance
				elseif instance.Name == "UpperTorso" then
					local clone_2 = script.UpperTorso:Clone()
					clone_2.Parent = instance
				elseif instance.Name ~= "LowerTorso" then
					for _, child in pairs(script.Textures:GetChildren()) do
						local clone_3 = child:Clone()
						clone_3.Parent = instance
					end
				end
			end
		elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Decal") or instance:IsA("Clothing") or instance:IsA("Texture") then
			instance:Destroy()
		end
	end

	if not self._is_humanoid then
		return
	end

	local v2 = {}

	for k in pairs(v) do
		table.insert(v2, k)
	end

	wait(1)

	for _ = 1, #v2 do
		local v3 = table.remove(v2, math.random(#v2))

		for _, v4 in pairs(v[v3]) do
			self._subject.Parent[v4]:Destroy()
		end

		self:CreateSound("rbxassetid://18128896162", 1, 1 + 0.1 * math.random(), nil, true, 5)
		wait(0.2)
	end

	self:CreateSound("rbxassetid://18128949754", 1, 1 + 0.1 * math.random(), nil, true, 10)
end

function object:_Init() end

return object