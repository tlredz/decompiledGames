local useTagInstance = require(game.ReplicatedStorage.React.Hooks.UID.useTagInstance)
return function(p: string)
	local guiObject, v = useTagInstance(p)

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject, v
	end

	return nil, v
end