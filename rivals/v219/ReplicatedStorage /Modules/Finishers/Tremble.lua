local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_AnchorModel(0)
end

function object:PlayClient(...)
	local cFramesByPart = {}

	for _, part in pairs(self:_GetObjects(true)) do
		if part:IsA("BasePart") then
			cFramesByPart[part] = part.CFrame
		end
	end

	table.insert(self._connections, RunService.RenderStepped:Connect(function(_)
		for k, v in pairs(cFramesByPart) do
			k.CFrame = v + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.2
		end
	end))
	self:CreateSound("rbxassetid://82637145735352", 1, 1 + 0.1 * math.random(), nil, true)
end

function object:_Init() end

return object