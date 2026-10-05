local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_SetupProp(script.PortalProp)
	object2:_PlayAnimation("rbxassetid://114622720984788", "rbxassetid://100757699753241", 1.15)
	object2:_InternalThread(task.spawn, function()
		wait(0.9)
		object2:CreateSound("rbxassetid://81610952487049", 0.375, 1 + 0.1 * math.random(), nil, true, 5)
		object2:CreateSound("rbxassetid://7127702569", 0.25, 1 + 0.25 * math.random(), nil, true, 5)
		wait(0.266)

		for i = 1, 1e999 do
			object2:CreateSound("rbxassetid://81610952487049", 0.25, 1 + 0.1 * math.random(), nil, true, 5)
			object2:CreateSound(
				"rbxassetid://7127702569",
				0.5 / ((i - 1) * 0.25 + 1),
				1 + 0.25 * math.random(),
				nil,
				true,
				5
			)
			wait(0.26666666666666666)
		end
	end)
end

function object:_Init() end

return object