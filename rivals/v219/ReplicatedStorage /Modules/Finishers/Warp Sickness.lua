local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
	wait(1)
	object2:_AnchorModel(0, false)
	object2:_Ragdoll()
	object2:_AnchorModel()
end

function object:PlayClient(...)
	local cFramesByInstance = {}

	for _, instance in pairs(self:_GetObjects(true)) do
		if instance:IsA("BasePart") and instance.Transparency < 0.99 then
			cFramesByInstance[instance] = instance.CFrame

			if instance.Name == "Head" then
				instance.Transparency = 1
			else
				instance:SetAttribute("WrapGroup", 1)
				instance:SetAttribute("IgnoreObject", true)
				instance:AddTag("Wrappable")
			end
		elseif instance:IsA("Texture") or instance:IsA("Decal") then
			instance:Destroy()
		end
	end

	local parent = self._is_humanoid and self._subject.Parent or self._subject
	parent:SetAttribute("WrapName", "Encroached")
	parent:AddTag("WrapThis")
	local lastTime = tick()
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		local v = 5 * (1 - (tick() - lastTime) / 1) ^ 4

		for k, v2 in pairs(cFramesByInstance) do
			k.CFrame = v2 + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * v
		end
	end)
	table.insert(self._connections, renderSteppedConnection)
	self:CreateSound("rbxassetid://118282338053058", 1.75, 1 + 0.1 * math.random(), nil, true, 5)
	wait(1)
	renderSteppedConnection:Disconnect()

	for k, cFrame in pairs(cFramesByInstance) do
		k.CFrame = cFrame
	end

	self:_AnchorModel(0, false)
end

function object:_Init() end

return object