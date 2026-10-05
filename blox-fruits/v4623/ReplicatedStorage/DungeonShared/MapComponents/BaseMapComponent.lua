require(game.ReplicatedStorage.Modules.Component)
local DungeonShared = require(game.ReplicatedStorage.DungeonShared)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
local v = BuildInfo.IS_PUBLISHED == false

local function getFloorFromComponent(state)
	if state.Floor then
		return state.Floor
	end

	local instance = state.Instance

	while instance do
		local parent = instance.Parent

		if parent and parent.Parent == workspace.Map then
			state.Floor = instance
			return instance
		else
			instance = parent
		end
	end

	return nil
end

local BaseMapComponent = {}

function BaseMapComponent.Started(p)
	assert(p.Instance)
	local floorFromComponent = getFloorFromComponent(p)

	if floorFromComponent then
		table.insert(DungeonShared.getComponentsOnFloor(floorFromComponent.Name), p)
	elseif v then
		warn((`MapComponentExtension.Started: Could not find floor for component {p.Instance:GetFullName()}`))
	end
end

function BaseMapComponent.Stopped(p)
	local floorFromComponent = getFloorFromComponent(p)

	if floorFromComponent then
		local componentsOnFloor = DungeonShared.getComponentsOnFloor(floorFromComponent.Name)
		local index = table.find(componentsOnFloor, p)

		if index then
			table.remove(componentsOnFloor, index)
		end
	end
end

return BaseMapComponent