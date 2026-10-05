local parent = script.Parent
local MapLocator = {
	current = function()
		local activeMap = parent:FindFirstChild("ActiveMap")
		local value = activeMap and activeMap.Value

		if not (value and value:IsDescendantOf(workspace) and value) then
			value = nil
		end

		return value
	end
}

function MapLocator.lobby()
	local current = MapLocator.current()
	return current and current:FindFirstChild("Lobby") or nil
end

return MapLocator