local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local ScavengerHuntLibrary = {
	Info = {},
	InfoByWeapon = {}
}

local function add_scavenger_hunt(allowedInPrivateServers, name, color, objectsName, objectsNamePlural, objectsImage, objects, rewardOnCompletion, rewards)
	local v = {
		AllowedInPrivateServers = allowedInPrivateServers,
		Name = name,
		Color = color,
		ObjectsName = objectsName,
		ObjectsNamePlural = objectsNamePlural,
		ObjectsImage = objectsImage,
		Objects = objects,
		NumObjects = #objects,
		RewardOnCompletion = rewardOnCompletion,
		Rewards = rewards
	}
	ScavengerHuntLibrary.Info[name] = v

	for _, item in pairs(rewards) do
		if ItemLibrary.Items[item.Name] then
			ScavengerHuntLibrary.InfoByWeapon[item.Name] = v
		end
	end
end

add_scavenger_hunt(
	false,
	"JumpPad",
	Color3.fromRGB(49, 210, 255),
	"Jump Shard",
	"Jump Shards",
	"rbxassetid://110601089716497",
	{
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9"
	},
	true,
	{
		{
			Name = "Jump Pad"
		}
	}
)
return ScavengerHuntLibrary