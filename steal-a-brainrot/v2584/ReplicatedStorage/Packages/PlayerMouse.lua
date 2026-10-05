local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

if not RunService:IsClient() then
	return table.freeze({
		Hit = CFrame.identity,
		Target = nil
	})
end

local function getFilter()
	local clone = table.clone(CollectionService:GetTagged("ExcludeFromRaycast") or {})
	local character = Players.LocalPlayer.Character

	if character then
		table.insert(clone, character)
	end

	return clone
end

local raycastParams = RaycastParams.new()
local clone = table.clone(CollectionService:GetTagged("ExcludeFromRaycast") or {})
local character = Players.LocalPlayer.Character

if character then
	table.insert(clone, character)
end

raycastParams.FilterDescendantsInstances = clone
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
Players.LocalPlayer.CharacterAdded:Connect(function(_)
	local v = raycastParams
	local clone2 = table.clone(CollectionService:GetTagged("ExcludeFromRaycast") or {})
	local character2 = Players.LocalPlayer.Character

	if character2 then
		table.insert(clone2, character2)
	end

	v.FilterDescendantsInstances = clone2
end)
local PlayerMouse = {
	Hit = CFrame.identity,
	Target = nil
}

local function performRaycast()
	debug.profilebegin("PlayerMouse:performRaycast")
	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local origin = viewportPointToRay.Origin
	local direction = viewportPointToRay.Direction
	local v = direction * 1000
	local raycastResult = workspace:Raycast(origin, v, raycastParams)
	local position

	if raycastResult then
		position = raycastResult.Position
	else
		position = origin + v
	end

	PlayerMouse.Hit = CFrame.lookAt(position, position + direction)
	local v2 = PlayerMouse
	local target

	if raycastResult then
		target = raycastResult.Instance
	end

	v2.Target = target
	debug.profileend()
end

RunService.PreRender:Connect(performRaycast)
task.spawn(performRaycast)
CollectionService:GetInstanceAddedSignal("ExcludeFromRaycast"):Connect(function()
	local v = raycastParams
	local clone2 = table.clone(CollectionService:GetTagged("ExcludeFromRaycast") or {})
	local character2 = Players.LocalPlayer.Character

	if character2 then
		table.insert(clone2, character2)
	end

	v.FilterDescendantsInstances = clone2
end)
CollectionService:GetInstanceRemovedSignal("ExcludeFromRaycast"):Connect(function()
	local v = raycastParams
	local clone2 = table.clone(CollectionService:GetTagged("ExcludeFromRaycast") or {})
	local character2 = Players.LocalPlayer.Character

	if character2 then
		table.insert(clone2, character2)
	end

	v.FilterDescendantsInstances = clone2
end)
return PlayerMouse