local createVector = vector.create
local Players = game:GetService("Players")
return {
	Name = "fun_skateConfig",
	Aliases = {},
	Description = "Change configuration of the ice skating system",
	Group = "Fun",
	Args = {
		{
			Type = "number",
			Name = "\"Spider Mode\"",
			Description = "Whether to enable \"spider mode\" for the skating system, setting this to 1 on will allow you to skate on any surface and setting it to 2 will change gravity to adhere to the surface angle (default is 0)",
			Default = 0,
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Perma-Skate",
			Description = "Whether to enable \"perma-skate\" for the skating system, turning this on will allow you to skate on (nearly) anything...expect lots of weirdness and bugs!",
			Default = false,
			Optional = true
		},
		{
			Type = "boolean",
			Name = "Infini-Jump",
			Description = "Whether to enable \"infini-jump\" for the skating system, turning this on will allow you to jump infinitely while skating, even if not on the ground",
			Default = false,
			Optional = true
		},
		{
			Type = "vector3",
			Name = "Up Vector",
			Description = "The global direction of 'up' for the skating system, default is 0,1,0 - changing this effectively 'changes gravity'!",
			Default = createVector(0, 1, 0)
		},
		{
			Type = "number",
			Name = "Speed Multiplier",
			Description = "The speed that the character attempts to maintain at maximum while skating (multiplier * 32 = target studs/s)",
			Default = 1,
			Optional = true
		},
		{
			Type = "vector3",
			Name = "Gravity",
			Description = "The global direction of gravity for the skating system, default is 0,-9.81,0",
			Default = createVector(0, -9.81, 0),
			Optional = true
		}
	},
	ClientRun = function(_, p: number, flag: boolean, flag2: boolean, vector2: Vector3, p2: number, vector3: Vector3)
		local character = Players.LocalPlayer.Character

		if not character then
			return "Player has no character"
		end

		if not character:HasTag("IceSkating") then
			return "Player is not currently skating"
		end

		if p ~= 0 and p ~= 1 and p ~= 2 then
			return "Spider mode must be 0, 1, or 2"
		end

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local IceSkating = require(ReplicatedStorage.Modules.Client.Components.LiveOps.Christmas2025.IceSkating)
		local v = IceSkating:FromInstance(character)

		if not v then
			return "Couldn't find IceSkating component, did it error during construction?"
		end

		v:UpdateConfigs(
			p,
			flag,
			flag2,
			vector2 or createVector(0, 1, 0),
			not p2 and 32 or p2 * 32,
			vector3 or createVector(0, -9.81, 0)
		)
		return "Configs changed successfully 🫡"
	end
}