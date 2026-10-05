local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mutations = require(ReplicatedStorage.Datas.Mutations)
require(ReplicatedStorage.Shared.Updates)
return {
	Gold = {
		DisplayText = Mutations.Gold.DisplayText,
		DisplayWithRichText = Mutations.Gold.DisplayWithRichText,
		MainColor = Mutations.Gold.MainColor,
		Palettes = Mutations.Gold.Palettes,
		Order = 2,
		ColorOrder = 2,
		IsMutation = true,
		CompletitionPercent = 0.75,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(179, 107, 13),
			[createVector(69, 71, 80)] = Color3.fromRGB(163, 98, 12),
			[createVector(27, 42, 53)] = Color3.fromRGB(200, 150, 0),
			[createVector(91, 93, 105)] = Color3.fromRGB(179, 107, 13)
		}
	},
	Diamond = {
		DisplayText = Mutations.Diamond.DisplayText,
		DisplayWithRichText = Mutations.Diamond.DisplayWithRichText,
		MainColor = Mutations.Diamond.MainColor,
		Palettes = Mutations.Diamond.Palettes,
		Order = 3,
		ColorOrder = 3,
		IsMutation = true,
		CompletitionPercent = 0.75,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(25, 138, 175),
			[createVector(69, 71, 80)] = Color3.fromRGB(13, 105, 172),
			[createVector(27, 42, 53)] = Color3.fromRGB(28, 150, 194),
			[createVector(91, 93, 105)] = Color3.fromRGB(25, 138, 175)
		}
	},
	Bloodrot = {
		DisplayText = Mutations.Bloodrot.DisplayText,
		DisplayWithRichText = Mutations.Bloodrot.DisplayWithRichText,
		MainColor = Mutations.Bloodrot.MainColor,
		Palettes = Mutations.Bloodrot.Palettes,
		LimitedMutation = 1750885200,
		ShowInSettings = false,
		Index = require(script.Index.Bloodrot),
		DisableIndex = true,
		IsMutation = true,
		CompletitionPercent = 1
	},
	Rainbow = {
		DisplayText = Mutations.Rainbow.DisplayText,
		DisplayWithRichText = Mutations.Rainbow.DisplayWithRichText,
		MainColor = Mutations.Rainbow.MainColor,
		Palettes = Mutations.Rainbow.Palettes,
		Order = 4,
		ColorOrder = 5,
		IsMutation = true,
		CompletitionPercent = 0.75,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(99, 95, 98),
			[createVector(69, 71, 80)] = Color3.fromRGB(69, 71, 80),
			[createVector(27, 42, 53)] = Color3.fromRGB(27, 42, 53),
			[createVector(91, 93, 105)] = Color3.fromRGB(91, 93, 105)
		}
	},
	Candy = {
		DisplayText = Mutations.Candy.DisplayText,
		DisplayWithRichText = Mutations.Candy.DisplayWithRichText,
		MainColor = Mutations.Candy.MainColor,
		Palettes = Mutations.Candy.Palettes,
		Order = 5,
		ColorOrder = 4,
		LimitedMutation = 1753477200,
		ShowInSettings = false,
		Index = require(script.Index.Candy),
		IsMutation = true,
		CompletitionPercent = 1,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(255, 105, 180),
			[createVector(69, 71, 80)] = Color3.fromRGB(177, 73, 125),
			[createVector(27, 42, 53)] = Color3.fromRGB(99, 41, 70),
			[createVector(91, 93, 105)] = Color3.fromRGB(255, 105, 180)
		}
	},
	Lava = {
		DisplayText = Mutations.Lava.DisplayText,
		DisplayWithRichText = Mutations.Lava.DisplayWithRichText,
		MainColor = Mutations.Lava.MainColor,
		Palettes = Mutations.Lava.Palettes,
		Order = 5,
		ColorOrder = 4,
		LimitedMutation = 1755957600,
		ShowInSettings = false,
		Index = require(script.Index.Lava),
		IsMutation = true,
		CompletitionPercent = 1,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(62, 31, 15),
			[createVector(69, 71, 80)] = Color3.fromRGB(230, 106, 17),
			[createVector(27, 42, 53)] = Color3.fromRGB(120, 17, 8),
			[createVector(91, 93, 105)] = Color3.fromRGB(255, 160, 0)
		}
	},
	Galaxy = {
		DisplayText = Mutations.Galaxy.DisplayText,
		DisplayWithRichText = Mutations.Galaxy.DisplayWithRichText,
		MainColor = Mutations.Galaxy.MainColor,
		Palettes = Mutations.Galaxy.Palettes,
		Order = 6,
		ColorOrder = 4,
		LimitedMutation = 1758999600,
		ShowInSettings = false,
		Index = require(script.Index.Galaxy),
		IsMutation = true,
		CompletitionPercent = 1,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(167, 79, 255),
			[createVector(69, 71, 80)] = Color3.fromRGB(87, 0, 186),
			[createVector(27, 42, 53)] = Color3.fromRGB(32, 12, 48),
			[createVector(91, 93, 105)] = Color3.fromRGB(113, 0, 243)
		}
	},
	YinYang = {
		DisplayText = Mutations.YinYang.DisplayText,
		UseRichText = Mutations.YinYang.UseRichText,
		DisplayWithRichText = Mutations.YinYang.DisplayWithRichText,
		MainColor = Mutations.YinYang.MainColor,
		Palettes = Mutations.YinYang.Palettes,
		Order = 7,
		ColorOrder = 5,
		LimitedMutation = 1763236800,
		ShowInSettings = false,
		Index = require(script.Index.YinYang),
		IsMutation = true,
		CompletitionPercent = 0.75,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(204, 204, 204),
			[createVector(69, 71, 80)] = Color3.fromRGB(204, 204, 204),
			[createVector(27, 42, 53)] = Color3.fromRGB(0, 0, 0),
			[createVector(91, 93, 105)] = Color3.fromRGB(0, 0, 0),
			[createVector(196, 40, 28)] = Color3.fromRGB(159, 161, 172),
			Ground = Color3.fromRGB(159, 161, 172)
		}
	},
	Halloween = {
		DisplayText = "Halloween",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ef7625\">Halloween</font>",
		MainColor = Color3.fromRGB(239, 118, 37),
		Order = 8,
		ShowInSettings = false,
		Index = require(script.Index.Halloween),
		LimitedMutation = 1762012800,
		CountAllMutations = true,
		CompletitionPercent = 0.75,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(220, 107, 21),
			[createVector(69, 71, 80)] = Color3.fromRGB(199, 94, 20),
			[createVector(27, 42, 53)] = Color3.fromRGB(161, 78, 16),
			[createVector(91, 93, 105)] = Color3.fromRGB(220, 107, 21),
			[createVector(202, 203, 209)] = Color3.fromRGB(198, 164, 61),
			[createVector(65, 67, 75)] = Color3.fromRGB(161, 78, 16),
			[createVector(108, 88, 75)] = Color3.fromRGB(198, 164, 61),
			Ground = Color3.fromRGB(220, 107, 21)
		}
	},
	Radioactive = {
		DisplayText = Mutations.Radioactive.DisplayText,
		UseRichText = Mutations.Radioactive.UseRichText,
		DisplayWithRichText = Mutations.Radioactive.DisplayWithRichText,
		MainColor = Mutations.Radioactive.MainColor,
		Palettes = Mutations.Radioactive.Palettes,
		Order = 9,
		ColorOrder = 6,
		ShowInSettings = false,
		LimitedMutation = 1767470400,
		IsMutation = true,
		CompletitionPercent = 0.75,
		Index = require(script.Index.Radioactive),
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(114, 156, 0),
			[createVector(69, 71, 80)] = Color3.fromRGB(156, 227, 50),
			[createVector(27, 42, 53)] = Color3.fromRGB(31, 59, 19),
			[createVector(91, 93, 105)] = Color3.fromRGB(156, 156, 156),
			[createVector(202, 203, 209)] = Color3.fromRGB(255, 255, 255),
			Ground = Color3.fromRGB(114, 156, 0)
		}
	},
	Cursed = {
		DisplayText = Mutations.Cursed.DisplayText,
		UseRichText = Mutations.Cursed.UseRichText,
		DisplayWithRichText = Mutations.Cursed.DisplayWithRichText,
		MainColor = Mutations.Cursed.MainColor,
		Palettes = Mutations.Cursed.Palettes,
		Order = 9,
		ColorOrder = 6,
		LimitedMutation = 1771704000,
		ShowInSettings = false,
		IsMutation = true,
		CompletitionPercent = 0.6,
		Index = require(script.Index.Cursed),
		BaseColors = {}
	},
	Divine = {
		DisplayText = Mutations.Divine.DisplayText,
		UseRichText = Mutations.Divine.UseRichText,
		DisplayWithRichText = Mutations.Divine.DisplayWithRichText,
		MainColor = Mutations.Divine.MainColor,
		Palettes = Mutations.Divine.Palettes,
		Order = 10,
		ColorOrder = 7,
		LimitedMutation = 1776542400,
		ShowInSettings = false,
		IsMutation = true,
		CompletitionPercent = 0.6,
		Index = require(script.Index.Divine),
		BaseColors = {}
	},
	Cyber = {
		DisplayText = Mutations.Cyber.DisplayText,
		UseRichText = Mutations.Cyber.UseRichText,
		DisplayWithRichText = Mutations.Cyber.DisplayWithRichText,
		MainColor = Mutations.Cyber.MainColor,
		Palettes = Mutations.Cyber.Palettes,
		Order = 10,
		ColorOrder = 7,
		LimitedMutation = 1781377200,
		IsMutation = true,
		CompletitionPercent = 0.6,
		ShowInSettings = false,
		Index = require(script.Index.Cyber),
		BaseColors = {}
	},
	Phantom = {
		DisplayText = Mutations.Phantom.DisplayText,
		UseRichText = Mutations.Phantom.UseRichText,
		DisplayWithRichText = Mutations.Phantom.DisplayWithRichText,
		MainColor = Mutations.Phantom.MainColor,
		Palettes = Mutations.Phantom.Palettes,
		Order = 10,
		ColorOrder = 7,
		LimitedMutation = 1785006000,
		IsMutation = true,
		CompletitionPercent = 0.5,
		ShowInSettings = false,
		Index = require(script.Index.Phantom),
		BaseColors = {}
	},
	Crystal = {
		DisplayText = Mutations.Crystal.DisplayText,
		UseRichText = Mutations.Crystal.UseRichText,
		DisplayWithRichText = Mutations.Crystal.DisplayWithRichText,
		MainColor = Mutations.Crystal.MainColor,
		Palettes = Mutations.Crystal.Palettes,
		Order = 11,
		ColorOrder = 8,
		LimitedMutation = 1791054000,
		IsMutation = true,
		CompletitionPercent = 0.5,
		ShowInSettings = false,
		Index = require(script.Index.Crystal),
		BaseColors = {}
	},
	Eclipse = {
		DisplayText = Mutations.Eclipse.DisplayText,
		UseRichText = Mutations.Eclipse.UseRichText,
		DisplayWithRichText = Mutations.Eclipse.DisplayWithRichText,
		MainColor = Mutations.Eclipse.MainColor,
		Palettes = Mutations.Eclipse.Palettes,
		Order = 12,
		ColorOrder = 9,
		LimitedMutation = 1795287600,
		IsMutation = true,
		CompletitionPercent = 0.5,
		ShowInSettings = false,
		Update = "Update-10/03/2026",
		BaseColors = {}
	},
	Aquatic = {
		DisplayText = "Aquatic",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#0096ff\">Aquatic</font>",
		MainColor = Color3.fromRGB(0, 150, 255),
		Order = 11,
		ShowInSettings = false,
		Index = require(script.Index.Aquatic),
		LimitedMutation = 1764446400,
		CustomIndex = {
			Name = "Aquatic"
		},
		CountAllMutations = true,
		CompletitionPercent = 0.9,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(59, 121, 163),
			[createVector(69, 71, 80)] = Color3.fromRGB(38, 77, 104),
			[createVector(27, 42, 53)] = Color3.fromRGB(21, 35, 65),
			[createVector(91, 93, 105)] = Color3.fromRGB(153, 106, 53),
			[createVector(202, 203, 209)] = Color3.fromRGB(99, 159, 211),
			Ground = Color3.fromRGB(176, 124, 61)
		}
	},
	Christmas = {
		DisplayText = "Christmas",
		UseRichText = false,
		DisplayWithRichText = "<font color=\"#ff4343\">Christmas</font>",
		MainColor = Color3.fromRGB(255, 67, 67),
		Order = 12,
		ShowInSettings = false,
		Index = require(script.Index.Christmas),
		LimitedMutation = 1767286800,
		CountAllMutations = true,
		CompletitionPercent = 0.9,
		CompletitionForcedAmount = 36,
		BaseColors = {}
	},
	Taco = {
		DisplayText = "Taco",
		UseRichText = false,
		DisplayWithRichText = "<font color=\"#FFDE59\">Taco</font>",
		MainColor = Color3.fromRGB(255, 222, 89),
		Order = 13,
		ShowInSettings = false,
		Index = require(script.Index.Taco),
		DisableAutomaticSkin = true,
		CustomIndex = {
			Name = "Taco",
			Filter = function(_: string, _: string)
				return ReplicatedStorage:GetAttribute("TacoBaseEvent") == true
			end
		},
		HideButton = true,
		CountAllMutations = true,
		CompletitionPercent = 0.9,
		BaseColors = {}
	},
	Valentines = {
		DisplayText = "Valentine's",
		UseRichText = false,
		DisplayWithRichText = "<font color=\"#e364bb\">Valentine's</font>",
		MainColor = Color3.fromRGB(227, 100, 187),
		Order = 12,
		ShowInSettings = false,
		Index = require(script.Index.Valentines),
		DisableAutomaticSkin = true,
		LimitedMutation = 1771704000,
		CustomIndex = {
			Name = "Valentines"
		},
		CountAllMutations = true,
		CompletitionPercent = 0.9,
		CompletitionForcedAmount = 8,
		BaseColors = {}
	},
	Gingerbread = {
		DisplayText = "Gingerbread",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ff7327\">Gingerbread</font>",
		MainColor = Color3.fromRGB(255, 115, 39),
		Order = 13,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Rose = {
		DisplayText = "Rose",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#f42020\">Rose</font>",
		MainColor = Color3.fromRGB(244, 32, 32),
		Order = 14,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Lucky = {
		DisplayText = "Lucky",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#4ee321\">Lucky</font>",
		MainColor = Color3.fromRGB(78, 227, 3),
		Order = 15,
		ShowInSettings = false,
		Index = require(script.Index.Lucky),
		DisableAutomaticSkin = true,
		CustomIndex = {
			Name = "Lucky",
			Filter = function(_: string, _: string)
				return ReplicatedStorage:GetAttribute("LuckyBaseEvent") == true
			end
		},
		HideButton = true,
		CountAllMutations = true,
		CompletitionPercent = 0.8,
		BaseColors = {}
	},
	Easter = {
		DisplayText = "Easter",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#a8e06c\">Easter</font>",
		MainColor = Color3.fromRGB(168, 224, 108),
		Order = 16,
		ShowInSettings = false,
		Index = require(script.Index.Easter),
		DisableAutomaticSkin = true,
		CustomIndex = {
			Name = "Easter"
		},
		HideButton = true,
		CountAllMutations = true,
		CompletitionPercent = 0.8,
		CompletitionForcedAmount = 10,
		BaseColors = {}
	},
	["Pot of Gold"] = {
		DisplayText = "Pot of Gold",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ffd015\">Pot of Gold</font>",
		MainColor = Color3.fromRGB(255, 208, 21),
		Order = 16,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	["Bunny Basket"] = {
		DisplayText = "Bunny Basket",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#a8e06c\">Bunny Basket</font>",
		MainColor = Color3.fromRGB(168, 224, 108),
		Order = 16,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Summer = {
		DisplayText = "Summer",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ffbb33\">Summer</font>",
		MainColor = Color3.fromRGB(255, 187, 51),
		Order = 16,
		ShowInSettings = false,
		Index = require(script.Index.Summer),
		DisableAutomaticSkin = true,
		CustomIndex = {
			Name = "Summer",
			Filter = function(_: string, _: string)
				return false
			end
		},
		HideButton = true,
		CountAllMutations = true,
		CompletitionPercent = 0.8,
		CompletitionForcedAmount = 21,
		BaseColors = {}
	},
	["Honey Bee"] = {
		DisplayText = "Honey Bee",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ffb300\">Honey Bee</font>",
		MainColor = Color3.fromRGB(255, 179, 0),
		Order = 16,
		ShowInSettings = false,
		Index = require(script.Index["Honey Bee"]),
		DisableAutomaticSkin = true,
		CustomIndex = {
			Name = "Honey Bee",
			Filter = function(_: string, _: string)
				return ReplicatedStorage:GetAttribute("HoneyBeeBaseEvent") == true
			end
		},
		HideButton = true,
		CountAllMutations = true,
		CompletitionPercent = 0.8,
		BaseColors = {}
	},
	Octo = {
		DisplayText = "Octo",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#f42020\">Octo</font>",
		MainColor = Color3.fromRGB(244, 32, 32),
		Order = 16,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	["Bee Emperor"] = {
		DisplayText = "Bee Emperor",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ffcc00\">Bee Emperor</font>",
		MainColor = Color3.fromRGB(255, 204, 0),
		Order = 16,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Tralalero = {
		DisplayText = "Tralalero",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#0096ff\">Tralalero</font>",
		MainColor = Color3.fromRGB(0, 150, 255),
		Order = 16,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Skibidi = {
		DisplayText = "Skibidi",
		UseRichText = false,
		UseRichTextInSettings = true,
		DisplayWithRichText = "<stroke thickness=\"2\" transparency=\"0.5\"><font color=\"#ffffff\">Skibidi</font></stroke>",
		MainColor = Color3.fromRGB(255, 255, 255),
		Order = 17,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Meowl = {
		DisplayText = "Meowl",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ffff14\">Meowl</font>",
		MainColor = Color3.fromRGB(255, 255, 20),
		Order = 18,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Strawberry = {
		DisplayText = "Strawberry",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#cf3b3f\">Strawberry</font>",
		MainColor = Color3.fromRGB(207, 59, 63),
		Order = 19,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {
			[createVector(99, 95, 98)] = Color3.fromRGB(235, 235, 235),
			[createVector(69, 71, 80)] = Color3.fromRGB(180, 180, 180),
			[createVector(27, 42, 53)] = Color3.fromRGB(139, 139, 139),
			[createVector(91, 93, 105)] = Color3.fromRGB(235, 235, 235),
			[createVector(202, 203, 209)] = Color3.fromRGB(253, 213, 110),
			Ground = Color3.fromRGB(196, 40, 28)
		}
	},
	Headless = {
		DisplayText = "Headless",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#7e44e3\">Headless</font>",
		MainColor = Color3.fromRGB(126, 68, 227),
		Order = 21,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	["John Pork"] = {
		DisplayText = "John Pork",
		UseRichText = true,
		DisplayWithRichText = "<font color=\"#ff8fb3\">John Pork</font>",
		MainColor = Color3.fromRGB(255, 143, 179),
		Order = 20,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	Spyder = {
		DisplayText = "Spyder",
		UseRichText = true,
		UseRichTextInSettings = true,
		DisplayWithRichText = "<stroke thickness=\"2\" transparency=\"0.5\"><font color=\"#ffffff\">Spyder</font></stroke>",
		MainColor = Color3.fromRGB(255, 255, 255),
		Order = 22,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	},
	["1 OF 1"] = {
		DisplayText = "1 OF 1",
		UseRichText = true,
		UseRichTextInSettings = true,
		DisplayWithRichText = "<stroke thickness=\"2\" transparency=\"0.5\"><font color=\"#ffffff\">1 OF 1</font></stroke>",
		MainColor = Color3.fromRGB(255, 255, 255),
		Order = 23,
		ShowInSettings = false,
		Index = {},
		DisableIndex = true,
		CountAllMutations = false,
		CompletitionPercent = 1,
		BaseColors = {}
	}
}