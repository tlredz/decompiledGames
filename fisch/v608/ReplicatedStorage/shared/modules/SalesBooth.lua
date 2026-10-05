local SalesBooth = {
	Items = {
		Default = {
			DisplayName = "Default",
			Icon = "rbxassetid://75403204209962",
			Order = 1,
			Untradeable = true
		},
		["Merlin White"] = {
			DisplayName = "Merlin White",
			Icon = "rbxassetid://107340476004041",
			Order = 2,
			Untradeable = true
		},
		["Merlin Black"] = {
			DisplayName = "Merlin Black",
			Icon = "rbxassetid://80911110854780",
			Order = 3,
			Untradeable = true
		},
		["Nessie Booth"] = {
			ProductId = 3303860343,
			EndTime = DateTime.fromUniversalTime(2025, 6, 21, 15).UnixTimestamp,
			DisplayName = "Nessie Booth",
			Icon = "rbxassetid://91220357256323",
			Order = 4
		},
		["Slime Trade Booth"] = {
			ProductId = 3311956349,
			EndTime = DateTime.fromUniversalTime(2025, 6, 28, 15).UnixTimestamp,
			DisplayName = "Slime Trade Booth",
			Icon = "rbxassetid://79706145445144",
			Order = 5
		},
		["Shelter Booth"] = {
			ProductId = 3408791667,
			EndTime = DateTime.fromUniversalTime(2025, 11, 28, 15).UnixTimestamp,
			DisplayName = "Shelter Booth",
			Icon = "rbxassetid://131304040653907",
			Order = 6
		},
		["Cathedral Booth"] = {
			ProductId = 3524481945,
			EndTime = DateTime.fromUniversalTime(2026, 2, 14, 17).UnixTimestamp,
			DisplayName = "Cathedral Booth",
			Icon = "rbxassetid://76028385570213",
			Order = 7
		},
		["Peep Princess Booth"] = {
			ProductId = 3569790586,
			EndTime = DateTime.fromUniversalTime(2026, 4, 11, 16).UnixTimestamp,
			DisplayName = "Peep Princess Booth",
			Icon = "rbxassetid://134023757841782",
			Order = 8
		},
		["Lyrical Loft"] = {
			ProductId = 3573977618,
			EndTime = DateTime.fromUniversalTime(2026, 4, 25, 16).UnixTimestamp,
			DisplayName = "Lyrical Loft",
			Icon = "rbxassetid://71471657201027",
			Order = 9
		},
		["Tropica Booth"] = {
			ProductId = 3608053066,
			EndTime = DateTime.fromUniversalTime(2026, 7, 25, 16).UnixTimestamp,
			DisplayName = "Tropica Booth",
			Icon = "rbxassetid://115910868639855",
			Order = 10
		},
		Racerbooth = {
			ProductId = 3711383042,
			EndTime = DateTime.fromUniversalTime(2026, 10, 3, 16).UnixTimestamp,
			DisplayName = "Racerbooth",
			Icon = "rbxassetid://139989367129320",
			Order = 11
		}
	},
	MaxItems = 12,
	MaxValue = 9999999999999
}
local RodSkins = require(script.Parent.RodSkins)
local types = {
	RodSkins = {
		DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite skins!</font>",
		DisplayLimit = 2,
		Data = RodSkins.Skins
	},
	Boat = 0,
	Bobber = 0,
	Halo = 0,
	Lantern = 0,
	BoothSkin = 0,
	Glider = 0,
	CompanionSkin = 0
}
local vessels = require(script.Parent.vessels)
types.Boat = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite boats!</font>",
	DisplayLimit = 1,
	Data = vessels.library
}
local bobbers = require(script.Parent.fishing.bobbers)
types.Bobber = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite bobbers!</font>",
	DisplayLimit = 1,
	Data = bobbers.Bobbers
}
types.Halo = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite halos!</font>",
	DisplayLimit = 1,
	Data = require(script.Parent.library.halos)
}
types.Lantern = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite lanterns!</font>",
	DisplayLimit = 1,
	Data = require(script.Parent.library.lanterns)
}
types.BoothSkin = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite booth skins!</font>",
	DisplayLimit = 1,
	Data = SalesBooth.Items
}
types.Glider = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite gliders!</font>",
	DisplayLimit = 1,
	Data = require(script.Parent.library.items.gliderdata)
}
local skins = require(script.Parent.library.companions.skins)
types.CompanionSkin = {
	DisplayLimitMessage = "<font color='#FF0000'>You've reached the limit of favorite companion skins!</font>",
	DisplayLimit = 1,
	Data = skins.Skins
}
SalesBooth.Types = types
return SalesBooth