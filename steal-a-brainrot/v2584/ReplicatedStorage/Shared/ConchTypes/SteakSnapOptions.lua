local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
return Conch.register_type("Snap Music", Conch.args.enum_new({
	"Concert",
	"Brazil",
	"Rap Concert",
	"Mexico",
	"Indonesia",
	"Spain",
	"Ay Mi Gatito"
}))