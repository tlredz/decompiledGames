local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
return Conch.register_type("Snap Music", Conch.args.enum_new({
	"Laser City",
	"Raining Burgers",
	"Concert",
	"Brazil",
	"Rap Concert",
	"Mexico",
	"Indonesia",
	"Spain",
	"Ay Mi Gatito",
	"Rip My Granny",
	"1 Year"
}))