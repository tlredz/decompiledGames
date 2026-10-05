local CollisionUtility = {}
Random.new()
newproxy(true)
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local filterDescendantsInstances = { workspace.Particles, workspace.Map.Blockers, workspace.Map.Water }
raycastParams.FilterDescendantsInstances = filterDescendantsInstances
CollisionUtility.InteractionParams = raycastParams
local filterDescendantsInstances2 = {
	workspace.Items,
	workspace.Particles,
	workspace.Characters,
	workspace.Map.Blockers,
	workspace.Map.Water
}
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
raycastParams2.FilterDescendantsInstances = filterDescendantsInstances2
CollisionUtility.DefaultParams = raycastParams2
local filterDescendantsInstances3 = {
	workspace.Items,
	workspace.Particles,
	workspace.Map.Blockers,
	workspace.Map.Water
}
local raycastParams3 = RaycastParams.new()
raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
raycastParams3.FilterDescendantsInstances = filterDescendantsInstances3
CollisionUtility.ProjectileParams = raycastParams3
local filterDescendantsInstances4 = {
	workspace.Items,
	workspace.Particles,
	workspace.Map.Blockers,
	workspace.Map.Water
}
local raycastParams4 = RaycastParams.new()
raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
raycastParams4.FilterDescendantsInstances = filterDescendantsInstances4
CollisionUtility.EnemyProjectileParams = raycastParams4
CollisionUtility.OverlapParams = OverlapParams.new()
CollisionUtility.OverlapParams.FilterDescendantsInstances = { workspace.Particles, workspace.Map.Blockers }
CollisionUtility.AllCharacters = OverlapParams.new()
CollisionUtility.AllCharacters.FilterType = Enum.RaycastFilterType.Include
CollisionUtility.AllCharacters.FilterDescendantsInstances = { workspace.Characters }

function UpdateDefaultParams()
	local v5 = {
		workspace.Items,
		workspace.Characters,
		workspace.Particles,
		workspace.Map.Blockers,
		workspace.Map.Water
	}
	local characters = { workspace.Particles, workspace.Map.Blockers }
	local characters2 = { workspace.Characters }

	for _, child in pairs(game.Players:GetChildren()) do
		table.insert(v5, child.Character)
		table.insert(characters2, child.Character)
	end

	if RunService:IsClient() then
		table.insert(characters, game.Players.LocalPlayer.Character)
	end

	CollisionUtility.OverlapParams.FilterDescendantsInstances = characters
	CollisionUtility.AllCharacters.FilterDescendantsInstances = characters2
end

function CollisionUtility.GetSphereProjectileHit(p, p2, p3, p4)
	return (workspace:Spherecast(p, p3, p2 - p, p4 or raycastParams3))
end

function CollisionUtility.GetProjectileHit(p, p2, p3)
	return (workspace:Raycast(p, p2 - p, p3 or raycastParams3))
end

function CollisionUtility.GetGroundPosition(p, value)
	local vector = Vector3.new(0, -(value or 40), 0)
	local raycastResult = workspace:Raycast(p, vector, raycastParams2)

	if raycastResult and raycastResult.Material ~= Enum.Material.Water then
		return raycastResult.Position, raycastResult
	end
end

function CollisionUtility.HasLineOfSight(instance, position, _)
	local position2

	if instance and type(instance) == "userdata" then
		position2 = instance:GetPivot().Position
	else
		position2 = instance
		instance = nil
	end

	if position and type(position) == "userdata" then
		position = position:GetPivot().Position
	end

	if position == nil and RunService:IsClient() then
		local localPlayer = game.Players.LocalPlayer
		local position3 = localPlayer.Character and localPlayer.Character:GetPivot().Position
		position = position2
		position2 = position3
	end

	if not (position2 and position) then
		return
	end

	local raycastResult = workspace:Raycast(position2, position - position2, raycastParams2)

	if raycastResult == nil or raycastResult.Instance.Parent == instance or raycastResult.Instance.Parent.Parent == instance then
		return true
	end

	return false, raycastResult.Instance:GetFullName()
end

function TrackShootThroughBarriers() end

function AddCrossbowCultistIgnore(instance)
	if instance:GetAttribute("Tamed") then
		return
	end

	if not table.find(filterDescendantsInstances4, instance) then
		table.insert(filterDescendantsInstances4, instance)
		raycastParams4.FilterDescendantsInstances = filterDescendantsInstances4
	end
end

function RemoveCrossbowCultistIgnore(p)
	local index = table.find(filterDescendantsInstances4, p)

	if index then
		table.remove(filterDescendantsInstances4, index)
		raycastParams4.FilterDescendantsInstances = filterDescendantsInstances4
	end
end

function AddModel(p, p2)
	table.insert(filterDescendantsInstances, p)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	table.insert(filterDescendantsInstances2, p)
	raycastParams2.FilterDescendantsInstances = filterDescendantsInstances2
	table.insert(filterDescendantsInstances3, p)
	raycastParams3.FilterDescendantsInstances = filterDescendantsInstances3

	if p2 ~= "Character" then
		table.insert(filterDescendantsInstances4, p)
		raycastParams4.FilterDescendantsInstances = filterDescendantsInstances4
	end
end

function RemoveModel(p)
	local index = table.find(filterDescendantsInstances2, p)

	if index then
		table.remove(filterDescendantsInstances2, index)
		raycastParams2.FilterDescendantsInstances = filterDescendantsInstances2
	end

	local index2 = table.find(filterDescendantsInstances, p)

	if index2 then
		table.remove(filterDescendantsInstances, index2)
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	end

	local index3 = table.find(filterDescendantsInstances3, p)

	if index3 then
		table.remove(filterDescendantsInstances3, index3)
		raycastParams3.FilterDescendantsInstances = filterDescendantsInstances3
	end

	local index4 = table.find(filterDescendantsInstances4, p)

	if index4 then
		table.remove(filterDescendantsInstances4, index4)
		raycastParams4.FilterDescendantsInstances = filterDescendantsInstances4
	end
end

function PlayerAdded(player)
	player.CharacterAdded:Connect(function(character)
		wait(0.1)
		AddModel(character, "Character")
		UpdateDefaultParams()
	end)
	player.CharacterRemoving:Connect(function(character)
		RemoveModel(character)
	end)

	if player.Character then
		UpdateDefaultParams()
		AddModel(player.Character, "Character")
	end
end

task.spawn(function()
	game.Players.PlayerAdded:Connect(PlayerAdded)

	for _, child in pairs(game.Players:GetChildren()) do
		PlayerAdded(child)
	end

	task.spawn(function()
		CollectionService:GetInstanceAddedSignal("ShootThroughBarrier"):Connect(function(p)
			AddModel(p)
		end)

		for _, v5 in pairs(CollectionService:GetTagged("ShootThroughBarrier")) do
			AddModel(v5)
		end

		CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(p)
			AddCrossbowCultistIgnore(p)
		end)
		CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(p)
			RemoveCrossbowCultistIgnore(p)
		end)
		CollectionService:GetInstanceRemovedSignal("TamedAnimal"):Connect(function(p)
			RemoveCrossbowCultistIgnore(p)
		end)

		for _, v5 in pairs(CollectionService:GetTagged("NPC")) do
			AddCrossbowCultistIgnore(v5)
		end
	end)
end)
return CollisionUtility