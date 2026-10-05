local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local enemyTemplate = ReplicatedStorage:WaitForChild("EnemyTemplate")
local animation_Folder = ReplicatedStorage:WaitForChild("Animation_Folder")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local skills = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skills")
animation_Folder:WaitForChild("Enemy")
local Quest_Settings = require(moduleScript:WaitForChild("Quest_Settings"))
local MonsterSettings = {
	DefaultCooldown = 10
}

for _, model in ipairs(enemyTemplate:GetChildren()) do
	if not model:IsA("Model") then
		continue
	end

	local levelNeed = 0
	local v = 0.9

	if MonsterSettings[model.Name] == nil then
		MonsterSettings[model.Name] = {}
	end

	for _, quest_Setting in pairs(Quest_Settings) do
		if quest_Setting.Target ~= model.Name then
			continue
		end

		levelNeed = quest_Setting.LevelNeed

		if quest_Setting.Need == 1 and not quest_Setting.Raid_Boss then
			MonsterSettings[model.Name].Boss = true
			v = 1.25
			local child = skills:FindFirstChild(model.Name)

			if child then
				if child:FindFirstChild("Z") then
					MonsterSettings[model.Name].Z = {
						Damage = levelNeed * v * 1.105
					}
				end

				if child:FindFirstChild("X") then
					MonsterSettings[model.Name].X = {
						Damage = levelNeed * v * 1.07
					}
				end
			end
		elseif quest_Setting.Raid_Boss then
			MonsterSettings[model.Name].Boss = true
			v = 1.75
			local child = skills:FindFirstChild(model.Name)

			if child then
				if child:FindFirstChild("Z") then
					MonsterSettings[model.Name].Z = {
						Damage = levelNeed * v * 1.574
					}
				end

				if child:FindFirstChild("X") then
					MonsterSettings[model.Name].X = {
						Damage = levelNeed * v * 1.513
					}
				end
			end
		elseif quest_Setting.Raid_Enemy then
			v = quest_Setting.TrueRaid_Boss and 1.65 or 1.15
			local child = skills:FindFirstChild(model.Name)

			if child then
				if child:FindFirstChild("Z") then
					MonsterSettings[model.Name].Z = {
						Damage = levelNeed * v * 1.447
					}
				end

				if child:FindFirstChild("X") then
					MonsterSettings[model.Name].X = {
						Damage = levelNeed * v * 1.414
					}
				end
			end
		end
	end

	MonsterSettings[model.Name].Level = levelNeed
	MonsterSettings[model.Name].Normal_Attack = levelNeed * v + 10
end

return MonsterSettings