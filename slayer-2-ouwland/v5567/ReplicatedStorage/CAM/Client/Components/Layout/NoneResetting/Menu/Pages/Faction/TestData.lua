local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Client.Modules.FactionState)
return function(userId: number, displayName: string)
	local members = {
		{
			DisplayName = displayName,
			UserId = userId,
			IsAdmin = true,
			Reputation = 120
		},
		{
			DisplayName = "builderman",
			UserId = 156,
			IsAdmin = true,
			Reputation = -45
		},
		{
			DisplayName = "Roblox",
			UserId = 1,
			IsAdmin = false,
			Reputation = 0
		},
		{
			DisplayName = "Shedletsky",
			UserId = 261,
			IsAdmin = false,
			Reputation = 310
		},
		{
			DisplayName = "Stickmasterluke",
			UserId = 80254,
			IsAdmin = false,
			Reputation = -200
		}
	}

	for i = 1, 45 do
		table.insert(members, {
			DisplayName = `Tester {i}`,
			UserId = i + 1000000,
			IsAdmin = false,
			Reputation = i * 37 % 400 - 200
		})
	end

	return {
		FactionName = "Test Faction",
		FactionBanner = "",
		FactionId = "TEST-FACTION",
		Version = 7,
		CreatedAt = os.time() - 259200,
		Members = members
	}
end