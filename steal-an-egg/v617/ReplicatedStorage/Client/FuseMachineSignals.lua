local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	FuseStarted = require(ReplicatedStorage.Packages.Signal).new()
}