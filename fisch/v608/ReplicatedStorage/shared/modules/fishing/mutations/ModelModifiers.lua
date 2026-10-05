local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./util")
local module2 = require("@self/AddAccessory")
local module3 = require("@self/AddVfxTemplate")
local module4 = require("@self/BasicProperties")
local module5 = require("@self/AddClickSfx")
local module6 = require("@self/UpsideDown")
local module7 = require("@self/Pancake")
local module8 = require("@self/Supersonic")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("mutations"):WaitForChild("vfx")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("mutations"):WaitForChild("accessories")
local _ = {
	Verdant = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(242, 255, 240), Color3.fromRGB(222, 255, 217) },
				{ Color3.fromRGB(232, 255, 194), Color3.fromRGB(221, 255, 183) }
			},
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(160, 255, 134), Color3.fromRGB(157, 197, 104) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Verdant",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Noxious = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(208, 192, 231), Color3.fromRGB(171, 91, 202) },
				{ Color3.fromRGB(139, 93, 165), Color3.fromRGB(119, 44, 148) }
			},
			Materials = Enum.Material.CrackedLava,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(146, 56, 184), Color3.fromRGB(94, 52, 118) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Noxious",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	["New Years"] = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(120, 121, 101), Color3.fromRGB(153, 154, 128) },
				{ Color3.fromRGB(18, 18, 15), Color3.fromRGB(17, 17, 15) }
			},
			Materials = Enum.Material.Neon,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 242, 179), Color3.fromRGB(229, 184, 95) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "New Years",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Noctic = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(214, 214, 214) },
				{ Color3.fromRGB(0, 0, 0), Color3.fromRGB(17, 17, 17) }
			},
			Materials = Enum.Material.Glass,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(212, 212, 212) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Noctic",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Corvid = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(190, 102, 234), Color3.fromRGB(176, 94, 217) },
				{ Color3.fromRGB(128, 103, 153), Color3.fromRGB(130, 99, 153) }
			},
			Materials = { Enum.Material.Glass, Enum.Material.ForceField },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(197, 117, 255), Color3.fromRGB(185, 135, 255) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Corvid",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Nightmare = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(33, 53, 96), Color3.fromRGB(36, 57, 103) },
				{ Color3.fromRGB(26, 43, 76), Color3.fromRGB(25, 40, 72) }
			},
			Materials = Enum.Material.Glass,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 154, 107), Color3.fromRGB(229, 138, 96) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Nightmare",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}), module2.new({
			TemplateName = "Dusekkar",
			SizeMultiplier = 0.16666666666666666
		}) },
	["Upside-Down"] = { module6.new({
			Rotation = 180
		}) },
	Part = { module4.new({
			TransparencySets = { 1 },
			NameOverrides = {
				Hitbox = {
					TransparencySets = { 0 },
					ColorSets = { Color3.fromRGB(163, 162, 165) },
					Materials = Enum.Material.Plastic
				}
			}
		}) },
	Toxic = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(221, 211, 255), Color3.fromRGB(194, 119, 255) },
				{ Color3.fromRGB(195, 146, 255), Color3.fromRGB(169, 82, 255) }
			},
			Materials = Enum.Material.CrackedLava,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(173, 79, 255), Color3.fromRGB(138, 89, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Toxic",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	RainbowCluster = { module4.new({
			ColorSets = {
				{
					Color3.fromRGB(255, 112, 112),
					Color3.fromRGB(255, 184, 112),
					Color3.fromRGB(255, 231, 112),
					Color3.fromRGB(193, 255, 112),
					Color3.fromRGB(112, 255, 136),
					Color3.fromRGB(112, 255, 203),
					Color3.fromRGB(112, 138, 255),
					Color3.fromRGB(148, 112, 255)
				}
			},
			Materials = Enum.Material.Neon
		}) },
	Soulless = { module4.new({
			ColorSets = { Color3.fromRGB(172, 89, 255), Color3.fromRGB(103, 69, 141) },
			TransparencySets = {
				{ 0.35, 0.5 }
			},
			Materials = Enum.Material.Neon
		}), module3.new({
			TemplateName = "Soulless",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Wisp = { module4.new({
			ColorSets = { Color3.fromRGB(107, 255, 233), Color3.fromRGB(85, 141, 137) },
			TransparencySets = {
				{ 0.35, 0.5 }
			},
			Materials = Enum.Material.Neon
		}), module3.new({
			TemplateName = "Wisp",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Haunted = { module4.new({
			ColorSets = { Color3.fromRGB(85, 65, 35), Color3.fromRGB(109, 81, 57) },
			TransparencySets = {
				{ 0.35, 0.5 }
			},
			Materials = Enum.Material.Neon
		}), module3.new({
			TemplateName = "Haunted",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Spectral = { module4.new({
			ColorSets = { Color3.fromRGB(103, 82, 136), Color3.fromRGB(136, 115, 168) },
			TransparencySets = {
				{ 0.35, 0.5 }
			}
		}), module3.new({
			TemplateName = "Spectral",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Smurf = { module4.new({
			ColorSets = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(1, 153, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(186, 186, 186) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Puritas = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(244, 255, 255), Color3.fromRGB(220, 240, 255) },
				{ Color3.fromRGB(208, 233, 255), Color3.fromRGB(180, 210, 255) }
			},
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(139, 176, 255), Color3.fromRGB(113, 153, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Puritas",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Sacratus = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(138, 185, 255), Color3.fromRGB(133, 159, 255) },
				{ Color3.fromRGB(176, 194, 255), Color3.fromRGB(150, 165, 217) }
			},
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(74, 83, 255), Color3.fromRGB(113, 153, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Sacratus",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Levitas = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(208, 222, 255), Color3.fromRGB(201, 206, 255) },
				{ Color3.fromRGB(196, 205, 255), Color3.fromRGB(215, 221, 255) }
			},
			Materials = Enum.Material.Glass,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(159, 156, 255) },
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Levitas",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	LEGO = { module4.new({
			ColorSets = {
				Color3.fromRGB(255, 0, 0),
				Color3.fromRGB(13, 255, 0),
				Color3.fromRGB(255, 255, 0),
				Color3.fromRGB(0, 55, 255)
			},
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 255, 127) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Chaotic = { module4.new({
			ColorSets = { Color3.new(0, 0, 0), Color3.new(1, 1, 1) },
			Materials = Enum.Material.Neon,
			TransparencySets = {
				{ 0.05, 0.25 }
			}
		}), module3.new({
			TemplateName = "Chaotic",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Lost = { module4.new({
			ColorSets = { Color3.fromRGB(160, 255, 131), Color3.fromRGB(144, 255, 110), Color3.fromRGB(175, 255, 151) },
			Materials = Enum.Material.Neon
		}) },
	["Moon-Kissed"] = { module4.new({
			ColorSets = { Color3.fromRGB(148, 255, 255), Color3.fromRGB(73, 222, 255) },
			ColorRandomHSV = { 0, 0.1, 0.1 }
		}), module3.new({
			TemplateName = "Moon-Kissed",
			BoxSizeMultiplier = 2.4,
			ParticleSizeMultiplier = 0.5
		}) },
	Zora = { module4.new({
			ColorSets = { Color3.fromRGB(255, 170, 127), Color3.fromRGB(255, 255, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 85, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Duncan = { module4.new({
			ColorSets = { Color3.fromRGB(170, 255, 255), Color3.fromRGB(255, 255, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 85, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Henry = { module4.new({
			ColorSets = { Color3.fromRGB(255, 83, 83), Color3.fromRGB(255, 255, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 85, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	["Ashen Fortune"] = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 170, 0), module.ORIGINAL_COLOR }
			},
			Materials = Enum.Material.CrackedLava
		}) },
	Prismize = { module4.new({
			ColorSets = {
				Color3.fromRGB(92, 105, 134),
				Color3.fromRGB(129, 67, 231),
				Color3.fromRGB(126, 181, 231),
				Color3.fromRGB(231, 58, 137)
			},
			TransparencySets = { 0.2 },
			Reflectance = 0.2,
			Materials = Enum.Material.Glass
		}) },
	Blessed = { module4.new({
			ColorSets = { Color3.fromRGB(177, 178, 107) },
			ColorRandomHSV = { 0, -0.4, 0 },
			Materials = Enum.Material.Neon
		}), module3.new({
			TemplateName = "Blessed",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Lovely = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(253, 206, 255), Color3.fromRGB(255, 190, 241) },
				{ Color3.fromRGB(226, 185, 255), Color3.fromRGB(205, 170, 255) }
			},
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(175, 138, 175), Color3.fromRGB(155, 141, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Lovely",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Infernal = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 81, 38), Color3.fromRGB(135, 47, 25) },
				{ Color3.fromRGB(255, 109, 5), Color3.fromRGB(217, 69, 0) }
			},
			Materials = Enum.Material.CrackedLava,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 96, 23), Color3.fromRGB(197, 47, 27) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Lovely",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Snowy = { module4.new({
			ColorSets = { Color3.fromRGB(205, 232, 255) },
			Materials = Enum.Material.Snow,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 255, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Snowy",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222,
			CustomTransform = function(_, instance, p)
				if instance:FindFirstChild("Snow") then
					instance.Snow.Speed = NumberRange.new(-2 * p, -0.4 * p)
				end
			end
		}) },
	Permafrost = { module4.new({
			ColorSets = { Color3.fromRGB(170, 191, 214) },
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(226, 243, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Permafrost",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222,
			CustomTransform = function(_, instance, p)
				if instance:FindFirstChild("Snow") then
					instance.Snow.Speed = NumberRange.new(-2 * p, -0.4 * p)
				end
			end
		}) },
	Chilled = { module4.new({
			ColorSets = { Color3.fromRGB(210, 251, 255) },
			Materials = Enum.Material.Snow,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 255, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Chilled",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Glacial = { module4.new({
			ColorSets = { Color3.fromRGB(226, 255, 250) },
			Materials = Enum.Material.Glacier,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 255, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Glacial",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Summer = { module4.new({
			ColorSets = {
				Color3.fromRGB(221, 207, 149),
				Color3.fromRGB(199, 187, 141),
				Color3.fromRGB(185, 169, 130),
				Color3.fromRGB(252, 227, 169),
				Color3.fromRGB(227, 208, 158)
			},
			Materials = Enum.Material.Sand,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(83, 129, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Summer",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}), module2.new({
			TemplateName = "Umbrella",
			SizeMultiplier = createVector(0.5, 0.5, 0),
			OffsetExtents = createVector(0, -0.25, 0)
		}) },
	Patriotic = { module4.new({
			ColorSets = { Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0) },
			Materials = Enum.Material.Plastic,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0) }
					},
					TransparencySets = { 0.15 },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Patriotic",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Serene = { module4.new({
			ColorSets = { Color3.fromRGB(0, 1, 5) },
			PreserveColorHSV = { 0, 0.8, 0.65 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(93, 123, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Serene",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMode = "Nonuniform",
			AttachmentSizeMultiplier = 8
		}) },
	Quiet = { module4.new({
			ColorSets = { Color3.fromHSV(0.622, 0.35, 0.29) },
			PreserveColorHSV = { 0, 0.7, 0.325 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(64, 84, 99) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Astraeus = { module4.new({
			ColorSets = { Color3.fromRGB(5, 0, 10) },
			PreserveColorHSV = { 0, 0.8, 0.65 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 128, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Astraeus",
			SizeMode = "HitboxPart",
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMode = "Nonuniform",
			AttachmentSizeMultiplier = 8
		}) },
	Requies = { module4.new({
			ColorSets = { Color3.fromRGB(0, 10, 7) },
			PreserveColorHSV = { 0, 0.8, 0.65 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 128, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Requies",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMode = "Nonuniform",
			AttachmentSizeMultiplier = 8
		}) },
	Ascended = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(208, 223, 255), Color3.fromRGB(255, 239, 221) },
				{ Color3.fromRGB(131, 140, 148), Color3.fromRGB(97, 96, 96) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glass },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(179, 208, 255), Color3.fromRGB(161, 158, 148) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Ascended",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMode = "Nonuniform",
			AttachmentSizeMultiplier = 8
		}) },
	["Ocean's Ruin"] = { module4.new({
			ColorSets = { Color3.fromRGB(10, 4, 4) },
			PreserveColorHSV = { 0, 0.8, 0.65 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(118, 21, 21) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Ocean's Ruin",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMode = "Nonuniform",
			AttachmentSizeMultiplier = 8
		}) },
	Magical = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(212, 158, 234), Color3.fromRGB(181, 85, 200) },
				{ Color3.fromRGB(129, 81, 148), Color3.fromRGB(83, 61, 97) }
			},
			Materials = { Enum.Material.Rock, Enum.Material.RoofShingles },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(221, 180, 255), Color3.fromRGB(135, 122, 161) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Magical",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Vined = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(80, 52, 28), Color3.fromRGB(71, 52, 20) },
				{ Color3.fromRGB(51, 147, 17), Color3.fromRGB(50, 116, 60) },
				{ Color3.fromRGB(51, 147, 17), Color3.fromRGB(50, 116, 60) },
				{ Color3.fromRGB(51, 147, 17), Color3.fromRGB(50, 116, 60) }
			},
			Materials = {
				Enum.Material.Glacier,
				Enum.Material.Slate,
				Enum.Material.Slate,
				Enum.Material.Slate
			},
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(122, 255, 115) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Vined",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175,
			AttachmentSizeMultiplier = 8
		}) },
	Skrunkly = { module4.new({
			ColorSets = {
				Color3.fromRGB(226, 227, 202),
				Color3.fromRGB(146, 146, 127),
				Color3.fromRGB(94, 93, 80),
				Color3.fromRGB(61, 56, 44)
			},
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(103, 95, 86) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Skrunkly",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175
		}) },
	["Nico's Nyantics"] = { module4.new({
			ColorSets = {
				Color3.fromRGB(252, 140, 164),
				Color3.fromRGB(249, 202, 212),
				Color3.fromRGB(202, 233, 254),
				Color3.fromRGB(251, 226, 195)
			},
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(103, 95, 86) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Nico's Nyantics",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175
		}) },
	Nocturnal_Night = { module4.new({
			ColorSets = {
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(20, 20, 20),
				Color3.fromRGB(40, 40, 40),
				Color3.fromRGB(60, 60, 60)
			},
			Materials = Enum.Material.CrackedLava,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(39, 39, 39) },
					Materials = Enum.Material.Asphalt
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Nocturnal",
			SizeMode = "ExtentsSize",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Nocturnal_Day = { module4.new({
			ColorSets = {
				Color3.fromRGB(20, 20, 20),
				Color3.fromRGB(40, 40, 40),
				Color3.fromRGB(60, 60, 60),
				Color3.fromRGB(80, 80, 80)
			},
			Materials = Enum.Material.CrackedLava,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(63, 63, 63) },
					Materials = Enum.Material.Asphalt
				}
			},
			IgnoreNames = {}
		}) },
	Flora = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 164, 255), Color3.fromRGB(255, 107, 253) },
				{ Color3.fromRGB(192, 123, 235), Color3.fromRGB(141, 91, 217) }
			},
			Materials = Enum.Material.Glacier,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(207, 130, 255), Color3.fromRGB(192, 169, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Flora",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Gemstone = { module4.new({
			ColorSets = {
				Color3.fromRGB(0, 255, 255),
				Color3.fromRGB(0, 170, 255),
				Color3.fromRGB(85, 170, 255),
				Color3.fromRGB(0, 55, 255),
				Color3.fromRGB(106, 255, 6),
				Color3.fromRGB(120, 255, 124),
				Color3.fromRGB(159, 255, 130),
				Color3.fromRGB(60, 163, 15),
				Color3.fromRGB(255, 7, 94),
				Color3.fromRGB(255, 2, 48),
				Color3.fromRGB(255, 16, 112),
				Color3.fromRGB(163, 18, 52)
			},
			Materials = Enum.Material.Glass,
			TransparencySets = { 0.5 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 0, 255) },
					TransparencySets = { 0 },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Carrot = { module4.new({
			ColorSets = {
				Color3.fromRGB(255, 234, 0),
				Color3.fromRGB(255, 191, 0),
				Color3.fromRGB(255, 140, 0),
				Color3.fromRGB(255, 106, 0)
			},
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 255, 127) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Oscar = { module4.new({
			ColorSets = {
				Color3.fromRGB(167, 0, 0),
				Color3.fromRGB(148, 0, 2),
				Color3.fromRGB(182, 155, 0),
				Color3.fromRGB(193, 154, 0)
			},
			Materials = { Enum.Material.SmoothPlastic, Enum.Material.Metal },
			Reflectance = { 0, 0.8 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 200, 34) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Royal = { module4.new({
			ColorSets = {
				Color3.fromRGB(167, 48, 48),
				Color3.fromRGB(207, 41, 44),
				Color3.fromRGB(255, 204, 0),
				Color3.fromRGB(255, 213, 0)
			},
			Materials = { Enum.Material.Fabric, Enum.Material.Metal },
			Reflectance = { 0, 0.8 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 200, 34) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}) },
	Sanguine = { module4.new({
			ColorSets = {
				Color3.fromRGB(54, 0, 0),
				Color3.fromRGB(27, 0, 0),
				Color3.fromRGB(168, 0, 0),
				Color3.fromRGB(74, 0, 0),
				Color3.fromRGB(148, 0, 0)
			},
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 0, 0) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Sanguine",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Bloom = { module4.new({
			ColorSets = { Color3.fromRGB(118, 102, 153), Color3.fromRGB(255, 204, 153) },
			Materials = { Enum.Material.Neon, Enum.Material.Plastic },
			Reflectance = 0.2
		}) },
	["Tentacle Surge"] = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(29, 0, 43), Color3.fromRGB(148, 0, 222) }
			},
			Materials = Enum.Material.Pebble
		}) },
	["Mother Nature"] = { module4.new({
			ColorSets = { Color3.fromRGB(144, 113, 94), Color3.fromRGB(170, 255, 127) },
			Materials = { Enum.Material.Wood, Enum.Material.LeafyGrass },
			ColorRandomHSV = { 0, -0.1, -0.2 }
		}) },
	Cracked = { module4.new({
			ColorSets = { Color3.fromRGB(255, 170, 0), Color3.fromRGB(33, 33, 88) },
			Materials = { Enum.Material.Glass, Enum.Material.Marble }
		}) },
	Ember = { module4.new({
			ColorSets = { Color3.fromRGB(255, 144, 8), Color3.fromRGB(229, 50, 50) },
			Materials = { Enum.Material.Glass, Enum.Material.Glass }
		}) },
	Emberflame = { module4.new({
			ColorSets = { Color3.fromRGB(180, 90, 0), Color3.fromRGB(56, 0, 86), Color3.fromRGB(27, 27, 72) },
			Materials = { Enum.Material.Neon, Enum.Material.Glass, Enum.Material.Marble }
		}) },
	["Cursed Touch"] = { module4.new({
			ColorSets = { Color3.fromRGB(0, 255, 0), Color3.fromRGB(27, 0, 42) },
			Materials = { Enum.Material.Plastic, Enum.Material.Glass }
		}) },
	Charred = { module4.new({
			ColorSets = {
				Color3.fromRGB(40, 40, 40),
				Color3.fromRGB(114, 114, 114),
				Color3.fromRGB(25, 25, 25),
				Color3.fromRGB(0, 0, 0),
				Color3.fromRGB(79, 79, 79)
			},
			Materials = Enum.Material.Slate
		}) },
	["Brown Wood"] = { module4.new({
			ColorSets = {
				Color3.fromRGB(106, 82, 67),
				Color3.fromRGB(114, 89, 73),
				Color3.fromRGB(100, 77, 63),
				Color3.fromRGB(127, 99, 82),
				Color3.fromRGB(144, 113, 94)
			},
			Materials = Enum.Material.Wood
		}) },
	Oak = { module4.new({
			ColorSets = {
				Color3.fromRGB(93, 72, 59),
				Color3.fromRGB(108, 84, 69),
				Color3.fromRGB(100, 79, 61),
				Color3.fromRGB(127, 104, 76),
				Color3.fromRGB(134, 104, 78)
			},
			Materials = Enum.Material.Wood
		}) },
	Boreal = { module4.new({
			ColorSets = {
				Color3.fromRGB(39, 30, 25),
				Color3.fromRGB(26, 20, 17),
				Color3.fromRGB(49, 39, 30),
				Color3.fromRGB(47, 38, 28),
				Color3.fromRGB(29, 22, 17)
			},
			Materials = Enum.Material.Wood
		}) },
	Cement = { module4.new({
			ColorSets = {
				Color3.fromRGB(93, 93, 93),
				Color3.fromRGB(108, 108, 108),
				Color3.fromRGB(100, 100, 100),
				Color3.fromRGB(127, 127, 127),
				Color3.fromRGB(134, 134, 134)
			},
			Materials = Enum.Material.Concrete
		}) },
	Vitalic = { module4.new({
			ColorSets = { Color3.fromRGB(116, 215, 160), Color3.fromRGB(97, 188, 110) },
			Materials = Enum.Material.LeafyGrass
		}) },
	Tainted = { module4.new({
			ColorSets = { Color3.fromRGB(168, 92, 255), Color3.fromRGB(109, 61, 168) },
			Materials = Enum.Material.LeafyGrass
		}) },
	Dreaming = { module4.new({
			ColorSets = { Color3.fromRGB(222, 193, 255), Color3.fromRGB(168, 146, 193) },
			Materials = Enum.Material.LeafyGrass
		}) },
	Bliss = { module4.new({
			ColorSets = { Color3.fromRGB(216, 160, 249), Color3.fromRGB(151, 249, 249), Color3.fromRGB(141, 255, 135) },
			Materials = Enum.Material.LeafyGrass
		}) },
	Dirty = { module4.new({
			ColorSets = {
				Color3.fromRGB(135, 113, 102),
				Color3.fromRGB(144, 121, 109),
				Color3.fromRGB(118, 99, 89),
				Color3.fromRGB(102, 85, 77),
				Color3.fromRGB(173, 145, 131)
			},
			Materials = Enum.Material.Mud
		}) },
	Rotting = { module4.new({
			ColorSets = { Color3.fromRGB(86, 79, 55), Color3.fromRGB(86, 78, 60), Color3.fromRGB(74, 71, 48) },
			Materials = Enum.Material.Wood
		}) },
	Decayed = { module4.new({
			ColorSets = { Color3.fromRGB(55, 46, 51), Color3.fromRGB(49, 46, 55), Color3.fromRGB(43, 36, 40) },
			Materials = Enum.Material.Wood
		}) },
	Honey = { module4.new({
			ColorSets = {
				Color3.fromRGB(255, 192, 121),
				Color3.fromRGB(255, 167, 108),
				Color3.fromRGB(255, 213, 114),
				Color3.fromRGB(255, 201, 134),
				Color3.fromRGB(255, 183, 83)
			},
			Materials = Enum.Material.SmoothPlastic,
			Reflectance = 0.5
		}) },
	Plagued = { module4.new({
			ColorSets = {
				Color3.fromRGB(42, 38, 47),
				Color3.fromRGB(38, 38, 47),
				Color3.fromRGB(26, 23, 27),
				Color3.fromRGB(32, 28, 47),
				Color3.fromRGB(29, 18, 36)
			},
			Materials = Enum.Material.Rock
		}) },
	["Green Leaf"] = { module4.new({
			ColorSets = { Color3.fromRGB(170, 255, 127) },
			Materials = Enum.Material.LeafyGrass
		}) },
	Rose = { module4.new({
			ColorSets = { Color3.fromRGB(170, 255, 127), Color3.fromRGB(163, 0, 0) },
			Materials = { Enum.Material.LeafyGrass, Enum.Material.SmoothPlastic }
		}) },
	Gravy = { module4.new({
			ColorSets = {
				Color3.fromRGB(106, 68, 49),
				Color3.fromRGB(114, 67, 48),
				Color3.fromRGB(84, 55, 38),
				Color3.fromRGB(127, 78, 50),
				Color3.fromRGB(144, 101, 71)
			},
			Materials = Enum.Material.Mud
		}), module3.new({
			TemplateName = "Gravy",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Brined = { module4.new({
			ColorSets = { Color3.fromRGB(0, 255, 157), Color3.fromRGB(0, 255, 119), Color3.fromRGB(0, 255, 179) },
			Materials = Enum.Material.Neon
		}), module3.new({
			TemplateName = "Brined",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.4,
			ParticleSizeMultiplier = 0.175
		}) },
	["King’s Blessing"] = { module2.new({
			TemplateName = "Crown",
			RelativeTo = "HeadTop",
			OffsetExtents = createVector(0, 0.25, 0),
			SizeMultiplier = createVector(0.75, 0, 0),
			CustomTransform = function(_, p)
				module.colorPulse(p, 1, nil, { 1, p.Transparency })
			end
		}) },
	Nova = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(244, 255, 255), Color3.fromRGB(153, 153, 255) },
				{ Color3.fromRGB(215, 224, 255), Color3.fromRGB(161, 149, 255) }
			},
			Materials = Enum.Material.Ice,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(125, 125, 255), Color3.fromRGB(89, 85, 197) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Nova",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Galaxy = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(0, 0, 0), Color3.fromRGB(120, 120, 200) },
				{ Color3.fromRGB(0, 0, 0), Color3.fromRGB(93, 87, 149) }
			},
			Materials = Enum.Material.ForceField,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(89, 39, 255), Color3.fromRGB(79, 76, 176) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Galaxy",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Aether = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(137, 218, 255), Color3.fromRGB(255, 255, 255) },
				{ Color3.fromRGB(128, 194, 222), Color3.fromRGB(214, 214, 214) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Snow },
			TransparencySets = { 0.4 },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(112, 217, 255) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Aether",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Luminescent = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(163, 176, 234), Color3.fromRGB(90, 98, 200) },
				{ Color3.fromRGB(85, 95, 148), Color3.fromRGB(68, 65, 97) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(192, 219, 255), Color3.fromRGB(124, 132, 161) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Luminescent",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Lucid = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(172, 122, 234), Color3.fromRGB(184, 125, 200) },
				{ Color3.fromRGB(100, 74, 249), Color3.fromRGB(126, 79, 207) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(151, 116, 255), Color3.fromRGB(97, 67, 216) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Lucid",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Phantom = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(99, 99, 99), Color3.fromRGB(85, 85, 85) },
				{ Color3.fromRGB(40, 40, 40), Color3.fromRGB(34, 34, 34) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(216, 216, 216) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Phantom",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Distraught = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(40, 40, 40), Color3.fromRGB(33, 33, 33) },
				{ Color3.fromRGB(20, 20, 20), Color3.fromRGB(12, 12, 12) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(216, 216, 216) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Distraught",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Crimson = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 137, 137), Color3.fromRGB(186, 92, 92) },
				{ Color3.fromRGB(157, 0, 0), Color3.fromRGB(66, 0, 0) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 174, 174), Color3.fromRGB(176, 68, 68) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Crimson",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Mastered = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 101, 104), Color3.fromRGB(113, 143, 200) },
				{ Color3.fromRGB(65, 46, 46), Color3.fromRGB(56, 62, 99) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 128, 130), Color3.fromRGB(119, 157, 207) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Mastered",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Batty = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(61, 24, 25), Color3.fromRGB(40, 29, 29) },
				{ Color3.fromRGB(65, 46, 46), Color3.fromRGB(27, 5, 5) }
			},
			Materials = Enum.Material.Rock,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 128, 130), Color3.fromRGB(104, 58, 58) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Batty",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Unlucky = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(61, 61, 61), Color3.fromRGB(40, 40, 40) },
				{ Color3.fromRGB(65, 65, 65), Color3.fromRGB(27, 27, 27) }
			},
			Materials = Enum.Material.Rock,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 255, 255), Color3.fromRGB(104, 104, 104) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Unlucky",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Jackpot = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(79, 229, 97), Color3.fromRGB(151, 216, 151) },
				{ Color3.fromRGB(207, 180, 80), Color3.fromRGB(193, 159, 118) }
			},
			Materials = Enum.Material.Neon,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(165, 255, 188), Color3.fromRGB(212, 193, 119) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Jackpot",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Necrotic = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 58, 61), Color3.fromRGB(200, 117, 117) },
				{ Color3.fromRGB(65, 36, 36), Color3.fromRGB(27, 5, 5) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Glacier },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 97, 100), Color3.fromRGB(104, 45, 45) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Necrotic",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Wicked = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 184, 84), Color3.fromRGB(200, 148, 103) },
				{ Color3.fromRGB(93, 66, 38), Color3.fromRGB(116, 84, 67) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Granite },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(200, 148, 65), Color3.fromRGB(104, 91, 60) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Wicked",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	["Jack's Curse"] = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 155, 89), Color3.fromRGB(200, 140, 100) },
				{ Color3.fromRGB(65, 49, 38), Color3.fromRGB(27, 19, 15) }
			},
			Materials = { Enum.Material.ForceField, Enum.Material.Granite },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 145, 94), Color3.fromRGB(104, 69, 51) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Jack's Curse",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Frightful = { module4.new({
			ColorSets = { Color3.fromRGB(64, 53, 85), Color3.fromRGB(88, 74, 109) },
			Materials = Enum.Material.Neon,
			TransparencySets = {
				{ 0.35, 0.5 }
			}
		}), module3.new({
			TemplateName = "Frightful",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Spooky = { module4.new({
			ColorSets = { Color3.fromRGB(59, 52, 77), Color3.fromRGB(84, 74, 109) },
			Materials = Enum.Material.Wood,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 159, 42), Color3.fromRGB(177, 132, 80) }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Spooky",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Eerie = { module4.new({
			ColorSets = { Color3.fromRGB(40, 85, 47), Color3.fromRGB(67, 167, 99) },
			Materials = Enum.Material.ForceField,
			TransparencySets = {
				{ 0.35, 0.5 }
			},
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(41, 255, 148), Color3.fromRGB(85, 177, 127) }
					},
					Materials = Enum.Material.Neon,
					TransparencySets = {
						{ 0.05, 0.25 }
					}
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Eerie",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 0.75,
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Breezed = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(255, 255, 164), Color3.fromRGB(200, 197, 115) },
				{ Color3.fromRGB(167, 167, 118), Color3.fromRGB(163, 160, 114) }
			},
			Materials = Enum.Material.Salt,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 252, 212), Color3.fromRGB(207, 195, 134) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Breezed",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Mango = { module4.new({
			ColorSets = { Color3.fromRGB(255, 165, 0) },
			Materials = Enum.Material.Glacier,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(0, 171, 0) },
					Materials = Enum.Material.Grass
				}
			},
			IgnoreNames = {}
		}) },
	Oblivion = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(148, 0, 2), Color3.fromRGB(74, 42, 19) },
				{ Color3.fromRGB(38, 0, 0), Color3.fromRGB(39, 20, 0) }
			},
			Materials = Enum.Material.Rock,
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 102, 0), Color3.fromRGB(255, 42, 0) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Oblivion",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Tryhard = { module4.new({
			ColorSets = {
				{ Color3.fromRGB(238, 0, 4), Color3.fromRGB(147, 20, 20) },
				{ Color3.fromRGB(126, 12, 12), Color3.fromRGB(65, 18, 18) }
			},
			Materials = { Enum.Material.Rock, Enum.Material.ForceField },
			NameOverrides = {
				Eyes = {
					ColorSets = {
						{ Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 60, 60) }
					},
					TransparencySets = {
						{ 0.05, 0.25 }
					},
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Tryhard",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Mace = { module4.new({
			ColorSets = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(115, 0, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(115, 0, 255) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module2.new({
			TemplateName = "MajiBucket",
			RelativeTo = "HeadBottom",
			SizeMultiplier = createVector(0.25, 0.25, 0)
		}) },
	Honked = { module2.new({
			TemplateName = "Clown",
			RelativeTo = "HeadBottom",
			SizeMultiplier = createVector(1, 1, 0)
		}), module5.new({
			SoundId = "rbxassetid://18592230472",
			Volume = 1.5,
			Autoplay = true
		}) },
	Bunny = { module4.new({
			ColorSets = { Color3.fromRGB(255, 255, 255) },
			PreserveColorHSV = { 1, 0.25, 0.5 }
		}), module2.new({
			TemplateName = "BunnyEars",
			RelativeTo = "HeadTop",
			SizeMultiplier = createVector(1, 0, 0)
		}) },
	Birthday = { module4.new({
			ColorSets = { Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 222, 169), Color3.fromRGB(229, 185, 255) },
			Materials = Enum.Material.SmoothPlastic,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(255, 252, 216) },
					Materials = Enum.Material.Neon
				}
			}
		}), module3.new({
			TemplateName = "Birthday",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}), module2.new({
			TemplateName = "PartyHat",
			RelativeTo = "HeadTop",
			SizeMultiplier = createVector(0.5, 0, 0)
		}) },
	["Siren's Spite"] = { module4.new({
			ColorSets = { Color3.fromHSV(0, 0.8, 0.35) },
			PreserveColorHSV = { 0.05, 0.5, 0.5 },
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.fromRGB(178, 34, 34) },
					Materials = Enum.Material.Neon
				}
			},
			IgnoreNames = {}
		}), module2.new({
			TemplateName = "EvilCrown",
			RelativeTo = "HeadTop",
			OffsetExtents = createVector(0, 0.25, 0),
			SizeMultiplier = createVector(0.75, 0, 0),
			CustomTransform = function(_, p)
				module.colorPulse(p, 1, nil, { 1, p.Transparency })
			end
		}) },
	Albino = { module4.new({
			ColorSets = { Color3.new(1, 1, 1) },
			PreserveColorHSV = { 0, 0, 0.25 }
		}) },
	Clover = { module4.new({
			ColorSets = { Color3.fromRGB(13, 255, 0), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 238, 0) }
		}) },
	Blarney = { module4.new({
			ColorSets = { Color3.fromRGB(13, 255, 0), Color3.fromRGB(0, 242, 255), Color3.fromRGB(255, 238, 0) },
			Materials = Enum.Material.Neon
		}) },
	Midas = { module4.new({
			ColorSets = { Color3.fromRGB(250, 185, 73) },
			PreserveColorHSV = { 0, 0.25, 0.25 },
			Materials = Enum.Material.Metal
		}) },
	Rusty = { module4.new({
			Materials = Enum.Material.CorrodedMetal
		}) },
	Sinister = { module4.new({
			ColorSets = { Color3.fromRGB(122, 122, 114) },
			PreserveColorHSV = { 0, 0.25, 0.25 },
			Materials = Enum.Material.Granite
		}), module3.new({
			TemplateName = "Sinister",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Ghastly = { module4.new({
			ColorSets = { Color3.fromRGB(97, 255, 94) },
			PreserveColorHSV = { 0, 0.25, 0.25 },
			Materials = Enum.Material.Neon,
			TransparencySets = { 0.7 }
		}), module3.new({
			TemplateName = "Ghastly",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Husk = { module4.new({
			ColorSets = { Color3.fromRGB(103, 91, 69) },
			Materials = Enum.Material.Neon,
			TransparencySets = { 0.7 }
		}) },
	Forgotten = { module4.new({
			ColorSets = { Color3.fromRGB(13, 10, 10) },
			Materials = Enum.Material.Neon,
			TransparencySets = { 0.5 }
		}) },
	Shrouded = { module4.new({
			ColorSets = { Color3.fromRGB(200, 255, 200) },
			PreserveColorHSV = { 0.2, 0.3, 0.9 },
			TransparencySets = { 0.35 },
			Materials = Enum.Material.Neon,
			NameOverrides = {
				Eyes = {
					ColorSets = { Color3.new(1, 1, 1) },
					TransparencySets = { 0 }
				}
			},
			IgnoreNames = {}
		}), module3.new({
			TemplateName = "Shrouded",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Merry = { module4.new({
			ColorSets = {
				{
					Color3.fromRGB(255, 0, 0),
					Color3.fromRGB(0, 255, 0),
					Color3.fromRGB(255, 255, 0),
					Color3.fromRGB(0, 200, 255),
					Color3.fromRGB(255, 50, 200),
					Color3.fromRGB(255, 100, 0),
					Color3.fromRGB(180, 0, 255)
				},
				Color3.fromRGB(20, 90, 20),
				Color3.fromRGB(20, 90, 20)
			},
			Materials = { Enum.Material.Neon, Enum.Material.Grass, Enum.Material.Grass },
			FadeTime = { 1.4, 2.6 },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}) },
	Jolly = { module4.new({
			ColorSets = {
				{
					Color3.fromRGB(255, 46, 46),
					Color3.fromRGB(255, 221, 48),
					Color3.fromRGB(58, 255, 44),
					Color3.fromRGB(51, 167, 255)
				},
				Color3.fromRGB(21, 75, 18)
			},
			Materials = { Enum.Material.Neon, Enum.Material.Grass },
			FadeTime = { 1.4, 2.6 },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}) },
	Festive = { module4.new({
			ColorSets = { Color3.fromRGB(238, 0, 0), Color3.fromRGB(238, 227, 227) },
			Materials = Enum.Material.Ice,
			ColorRandomHSV = { 0, 0.2, -0.2 }
		}) },
	Minty = { module4.new({
			ColorSets = { Color3.fromRGB(147, 255, 192), Color3.fromRGB(80, 255, 159) },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}) },
	Frostnova = { module4.new({
			ColorSets = { Color3.fromRGB(137, 198, 255), Color3.fromRGB(101, 137, 255) },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}), module3.new({
			TemplateName = "Frostnova",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Floral = { module4.new({
			ColorSets = {
				Color3.fromRGB(255, 46, 46),
				Color3.fromRGB(255, 221, 48),
				Color3.fromRGB(58, 255, 44),
				Color3.fromRGB(51, 167, 255),
				Color3.fromRGB(81, 213, 107),
				Color3.fromRGB(81, 213, 107),
				Color3.fromRGB(81, 213, 107),
				Color3.fromRGB(81, 213, 107)
			},
			Materials = {
				Enum.Material.SmoothPlastic,
				Enum.Material.SmoothPlastic,
				Enum.Material.SmoothPlastic,
				Enum.Material.SmoothPlastic,
				Enum.Material.Grass,
				Enum.Material.Grass,
				Enum.Material.Grass,
				Enum.Material.Grass
			},
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}) },
	Blossomed = { module4.new({
			ColorSets = {
				Color3.fromRGB(164, 255, 172),
				Color3.fromRGB(86, 204, 78),
				Color3.fromRGB(62, 177, 62),
				Color3.fromRGB(157, 255, 115),
				Color3.fromRGB(86, 57, 21),
				Color3.fromRGB(86, 57, 21),
				Color3.fromRGB(86, 57, 21),
				Color3.fromRGB(86, 57, 21)
			},
			Materials = {
				Enum.Material.Grass,
				Enum.Material.Grass,
				Enum.Material.Grass,
				Enum.Material.Grass,
				Enum.Material.Wood,
				Enum.Material.Wood,
				Enum.Material.Wood,
				Enum.Material.Wood
			},
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}) },
	Embraced = { module4.new({
			ColorSets = { Color3.fromRGB(255, 248, 226), Color3.fromRGB(255, 133, 239) },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}), module3.new({
			TemplateName = "Embraced",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Lovestruck = { module4.new({
			ColorSets = { Color3.fromRGB(254, 248, 255), Color3.fromRGB(255, 167, 207) },
			ColorRandomHSV = { 0, 0.1, -0.1 }
		}), module3.new({
			TemplateName = "Lovestruck",
			SizeMode = "ExtentsSize",
			ParticleSizeMultiplier = 0.2222222222222222
		}) },
	Igneous = { module4.new({
			ColorSets = { Color3.fromRGB(255, 81, 0) },
			Materials = { Enum.Material.Neon, Enum.Material.ForceField },
			NameOverrides = {
				Eyes = {
					Materials = Enum.Material.Neon
				}
			}
		}), module3.new({
			TemplateName = "Lovestruck",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.7999999999999998,
			ParticleSizeMultiplier = 0.19999999999999998
		}) },
	Solar = { module4.new({
			ColorSets = { Color3.fromRGB(255, 243, 114) },
			Materials = { Enum.Material.Neon, Enum.Material.ForceField },
			NameOverrides = {
				Eyes = {
					Materials = Enum.Material.Neon
				}
			}
		}), module3.new({
			TemplateName = "Lovestruck",
			SizeMode = "HitboxPart",
			BoxSizeMultiplier = 1.7999999999999998,
			ParticleSizeMultiplier = 0.19999999999999998
		}) },
	Pancake = { module7.new({
			Scale = createVector(1, 0.1, 1)
		}) },
	Supersonic = { module4.new({
			ColorSets = { Color3.fromRGB(197, 62, 58), Color3.fromRGB(248, 248, 248) }
		}), module8.new({}) }
}