local EntityAtlas = {}
local v = {}
local monster = workspace:WaitForChild("Monster")
local playerCharacters = workspace:WaitForChild("PlayerCharacters")
local seaMonster = workspace:FindFirstChild("SeaMonster")
local MOB = workspace:FindFirstChild("MOB")

function EntityAtlas.AddEntity(p)
	if table.find(v, p) then
		return
	end

	table.insert(v, p)
end

function EntityAtlas.RemoveEntity(p)
	local index = table.find(v, p)

	if not index then
		return
	end

	table.remove(v, index)
end

function EntityAtlas.GetEntities()
	return v
end

function LoadEntities(list)
	for _, v2 in ipairs(list) do
		for _, child in pairs(v2:GetChildren()) do
			EntityAtlas.AddEntity(child)
		end
	end
end

function EntityAtlas.Setup(_)
	monster.Mon.ChildAdded:Connect(EntityAtlas.AddEntity)
	monster.Boss.ChildAdded:Connect(EntityAtlas.AddEntity)
	playerCharacters.ChildAdded:Connect(EntityAtlas.AddEntity)
	monster.Mon.ChildRemoved:Connect(EntityAtlas.RemoveEntity)
	monster.Boss.ChildRemoved:Connect(EntityAtlas.RemoveEntity)
	playerCharacters.ChildRemoved:Connect(EntityAtlas.RemoveEntity)

	if seaMonster then
		seaMonster.ChildAdded:Connect(EntityAtlas.AddEntity)
		seaMonster.ChildRemoved:Connect(EntityAtlas.RemoveEntity)
	end

	if MOB then
		MOB.ChildAdded:Connect(EntityAtlas.AddEntity)
		MOB.ChildRemoved:Connect(EntityAtlas.RemoveEntity)
	end

	LoadEntities({
		monster.Mon,
		monster.Boss,
		playerCharacters,
		seaMonster,
		MOB
	})
end

return EntityAtlas