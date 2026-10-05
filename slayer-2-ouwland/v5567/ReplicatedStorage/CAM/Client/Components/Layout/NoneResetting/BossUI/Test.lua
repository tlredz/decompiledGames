local Test = {
	Enabled = true,
	Config = {
		Title = "Test Boss",
		Name = "Training Dummy",
		Icon = nil,
		MaxHealth = 5000,
		Health = 0.6,
		Chest = "World Events Chest",
		ChestRarity = 3,
		Rewards = {
			Exp = 1000,
			Wen = 450,
			["Water Katana"] = {
				Chance = 0.03,
				Quantity = 1
			},
			["Water Haori"] = {
				Chance = 0.01,
				Quantity = 1
			},
			["Dead Calm"] = {
				Chance = 0.05,
				Quantity = 1
			}
		},
		Damage = {
			Giyen = 12480,
			Shinobu = 9310,
			Tanjiro = 4025
		},
		NpcCode = nil,
		Mode = 1,
		Timer = 60,
		OnlyAtNight = false
	}
}

function Test.Build()
	local config = Test.Config
	local folder = Instance.new("Folder")
	folder.Name = config.Name
	folder:SetAttribute("Icon", config.Icon)
	folder:SetAttribute("DespawnedAt", workspace:GetServerTimeNow() - config.Timer)
	local model = Instance.new("Model")
	model.Name = config.Name
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Parent = model
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = config.MaxHealth
	humanoid.Health = config.MaxHealth * math.clamp(config.Health, 0, 1)
	humanoid.Parent = model

	if config.Damage ~= nil then
		local folder2 = Instance.new("Folder")
		folder2.Name = "DMG"

		for k, v in config.Damage do
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = k
			numberValue.Value = v
			numberValue.Parent = folder2
		end

		folder2.Parent = model
	end

	model.PrimaryPart = part
	model.Parent = folder
	local folder2 = Instance.new("Folder")
	folder2.Name = "BossInfo"
	folder2:SetAttribute("NpcCode", config.NpcCode)
	folder2:SetAttribute("Chest", config.Chest)
	folder2:SetAttribute("ChestRarity", config.ChestRarity)
	folder2:SetAttribute("Title", config.Title)
	folder2:SetAttribute("OnlyAtNight", config.OnlyAtNight)
	folder2:SetAttribute("SpawnTime", config.Timer)
	folder2.Parent = folder
	folder.Parent = workspace.CurrentCamera
	return folder2
end

return Test