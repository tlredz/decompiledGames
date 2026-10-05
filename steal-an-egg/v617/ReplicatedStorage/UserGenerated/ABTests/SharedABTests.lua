local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("UserGenerated.ABTestDefaults", Asserts.Map(Asserts.String, Asserts.Any), {})
return table.freeze({
	UpdateRemote = script:WaitForChild("Update"),
	ABTestDefaults = replicated
})