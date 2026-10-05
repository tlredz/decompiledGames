local Players = game:GetService("Players")
local Mounted = {
	Attribute = "OnHorse"
}

function Mounted.Is(character)
	if character == nil then
		character = Players.LocalPlayer.Character
	elseif character:IsA("Player") then
		character = character.Character
	end

	return character ~= nil and character:GetAttribute(Mounted.Attribute) == true
end

function Mounted.Watch(object, callback)
	return object:GetAttributeChangedSignal(Mounted.Attribute):Connect(function()
		callback(Mounted.Is(object))
	end)
end

return Mounted