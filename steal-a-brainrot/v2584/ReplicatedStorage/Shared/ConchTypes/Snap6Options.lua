local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
return Conch.register_type("Snap6 Music", Conch.args.enum_new({
	"None",
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