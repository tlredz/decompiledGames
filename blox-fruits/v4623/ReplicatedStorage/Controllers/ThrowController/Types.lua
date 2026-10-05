local RunService = game:GetService("RunService")
local Type = require(game.ReplicatedStorage.Packages.Type)
local Trajectory = require(game.ReplicatedStorage.Util.Trajectory)
local strictInterface = Type.strictInterface({
	ItemName = Type.string,
	HitRadius = Type.numberPositive,
	Influence = Type.NumberSequence,
	EffectName = function(childName)
		if typeof(childName) ~= "string" then
			return false, (`Expected string for EffectName, got {typeof(childName)}`)
		end

		if not RunService:IsServer() or game.ServerStorage.ServerAssets.ThrowingPotion.ThrowingPotionServer.Effects:FindFirstChild(childName) then
			return true
		end

		return
			false,
			(`Effect '{childName}' does not exist in ServerStorage/ServerAssets/ThrowingPotion/ThrowingPotionServer/Effects folder`)
	end,
	EffectDuration = Type.numberMin(0),
	InnerColor = Type.Color3,
	OuterColor = Type.Color3,
	MaxRange = Type.optional(Type.numberPositive),
	MaxSpeed = Type.optional(Type.numberPositive),
	SplashEnabled = Type.optional(Type.boolean),
	ThrowIgnoreTag = Type.optional(Type.string)
})
local literal = Type.literal("NO_ANIM")
local strictInterface2 = Type.strictInterface({
	Type = Type.literal("ThrowData"),
	UID = Type.string,
	Throwable = strictInterface,
	Thrower = Type.instanceOf("Player"),
	Aim = Trajectory.Types.AimData,
	Tags = Type.array(literal)
})
return {
	Tags = {
		NO_ANIM = "NO_ANIM"
	},
	Types = {
		ThrowData = strictInterface2,
		ThrowableConfig = strictInterface,
		ImpactData = Type.strictInterface({
			Type = Type.literal("ImpactData"),
			Position = Type.Vector3,
			Normal = Type.Vector3,
			InverseImpactNormal = Type.Vector3,
			Hit = Type.instanceOf("BasePart"),
			Throw = strictInterface2,
			Characters = Type.map(Type.instanceOf("Model"), Type.numberConstrained(0, 1))
		})
	}
}