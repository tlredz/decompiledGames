local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local monster = workspace:WaitForChild("Monster")
local monsterSpawn = ReplicatedStorage:WaitForChild("MonsterSpawn")

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckIfAlive(instance)
	if instance and instance.Parent and instance:FindFirstChild("Humanoid") and instance:FindFirstChild("Humanoid").Parent and instance:FindFirstChild("Humanoid").Health > 0 then
		return true
	end

	return false
end

local function UpdateMonsterParent(p, parent)
	if p.Parent ~= parent then
		p.Parent = parent
	end
end

while task.wait(3) do
	local tagged = CollectionService:GetTagged("Enemy")

	for _, model in ipairs(tagged) do
		if not (model:IsA("Model") and model.PrimaryPart and model:GetAttribute("Loaded") and model.Name ~= "Meme Beast") then
			continue
		end

		if (model.PrimaryPart.Position - currentCamera.CFrame.Position).Magnitude <= 1500 then
			if CheckIfAlive(model) and model.Parent ~= monster then
				model.Parent = monster
			end
		elseif CheckIfAlive(model) and model.Parent ~= monsterSpawn then
			model.Parent = monsterSpawn
		end
	end
end