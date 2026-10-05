local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
return {
	SchemaValidation = {
		ForestGuardHitRequest = t.interface({
			EggUid = t.string,
			GuardCFrame = t.CFrame
		}),
		ForestGuardDepositRequest = t.interface({
			EggUid = t.string,
			Kind = t.union(t.literal("Attached"), t.literal("Deposited"))
		})
	}
}