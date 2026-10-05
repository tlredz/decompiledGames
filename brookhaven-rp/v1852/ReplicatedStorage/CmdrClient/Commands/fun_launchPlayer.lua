local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CannonLaunchEffect = require(ReplicatedStorage.Modules.Client.Util.CannonLaunchEffect)
return {
	Name = "fun_launchPlayer",
	Aliases = {},
	Description = "Send a player flying in a certain direction",
	Group = "Fun",
	Args = {
		{
			Type = "vector3",
			Name = "direction",
			Description = "The direction to launch the player in"
		},
		{
			Type = "number",
			Name = "power",
			Description = "The power to launch the player with(100 is a good value)",
			Default = 100,
			Optional = true
		},
		{
			Type = "number",
			Name = "spinDuration",
			Description = "The time to spin the player for",
			Default = 1,
			Optional = true
		}
	},
	ClientRun = function(_, vector: Vector3, p: number, p2: number)
		local character = Players.LocalPlayer.Character

		if not character then
			return "Player has no character"
		end

		CannonLaunchEffect(character, vector, p, p2)
	end
}