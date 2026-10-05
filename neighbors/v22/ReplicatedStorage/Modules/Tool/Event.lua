local Event = {}
local Players = game:GetService("Players")

function Event.new(character, tool)
	local self = setmetatable({}, {
		__index = Event
	})
	self.Character = character
	self.Tool = tool
	self.Player = Players:GetPlayerFromCharacter(character)
	self.Handle = tool:FindFirstChild("Handle")
	return self
end

return Event