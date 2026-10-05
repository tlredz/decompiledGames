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
	object2:_SetupProp(script.ChairProp)
	object2:_PlayAnimation("rbxassetid://109007831000004", "rbxassetid://122853316942062", 3.6)
	object2:CreateSound("rbxassetid://136567309252911", 1, 1, nil, true)
	wait(30.6)
	local createSound = object2:CreateSound("rbxassetid://96651118435847", 1, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object