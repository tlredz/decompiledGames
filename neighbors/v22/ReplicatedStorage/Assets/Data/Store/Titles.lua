local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Modules.Title.Animations)
local v = {
	Points = {
		Order = 1,
		Items = {
			{
				Display = "Freshman",
				Color = Color3.fromRGB(90, 255, 137),
				Description = "Have at least 10,000 points."
			},
			{
				Display = "Sophomore",
				Color = Color3.fromRGB(253, 255, 131),
				Font = Enum.Font.Nunito,
				Description = "Have at least 25,000 points."
			},
			{
				Display = "Junior",
				Color = Color3.fromRGB(255, 204, 160),
				Font = Enum.Font.IndieFlower,
				Description = "Have at least 45,000 points.",
				Animation = ""
			},
			{
				Display = "Senior",
				Color = Color3.fromRGB(160, 177, 255),
				Font = Enum.Font.Code,
				Description = "Have at least 80,000 points."
			},
			{
				Display = "Master",
				Color = Color3.fromRGB(11, 255, 194),
				Font = Enum.Font.Merriweather,
				Description = "Have at least 150,000 points."
			},
			{
				Display = "Graduate",
				Color = Color3.fromRGB(148, 26, 255),
				Font = Enum.Font.Arial,
				Description = "Have at least 350,000 points."
			}
		}
	},
	Streak = {
		Order = 2,
		Items = {
			{
				Display = "Regular",
				Color = Color3.fromRGB(183, 248, 255),
				Description = "Have a streak of seven or more days."
			},
			{
				Display = "Loyal",
				Color = Color3.fromRGB(255, 220, 20),
				Font = Enum.Font.Oswald,
				Description = "Have a streak of fourteen or more days."
			},
			{
				Display = "OG",
				Color = Color3.fromRGB(255, 244, 158),
				Font = Enum.Font.Arcade,
				Description = "Have a streak of thirty or more days."
			},
			{
				Display = "No Life",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.PermanentMarker,
				Description = "Have a streak of fifty or more days."
			},
			{
				Display = "Elderly",
				Color = Color3.fromRGB(255, 146, 166),
				Font = Enum.Font.Antique,
				Description = "Have a streak of a hundred or more days."
			},
			{
				Display = "Ancient",
				Color = Color3.fromRGB(255, 237, 166),
				StrokeColor = Color3.fromRGB(162, 110, 65),
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 2,
				Description = "Have a streak of two hundred or more days."
			},
			{
				Display = "Everlasting",
				Color = Color3.fromRGB(255, 94, 94),
				StrokeColor = Color3.fromRGB(162, 32, 32),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Merriweather,
				Bold = true,
				Description = "Have a streak of a year or more days."
			}
		}
	},
	Invites = {
		Order = 3,
		Items = {
			{
				Display = "Popular",
				Color = Color3.fromRGB(255, 170, 127),
				Description = "Invite twenty or more people to the game."
			},
			{
				Display = "Celebrity",
				Color = Color3.fromRGB(107, 255, 233),
				Font = Enum.Font.Arcade,
				Description = "Invite fifty or more people to the game."
			}
		}
	},
	Other = {
		Order = 5,
		Items = {
			{
				Display = "VR User",
				Color = Color3.fromRGB(255, 143, 145),
				Font = Enum.Font.Code,
				Description = "You tried Neighbors in VR! I wonder how many other VR players there are out there..."
			}
		}
	},
	Group = {
		Order = 6,
		Items = {
			{
				Display = "Top CC",
				Color = Color3.fromRGB(255, 88, 88),
				StrokeColor = Color3.fromRGB(170, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187370928",
				Bold = true,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "Congratulations, you're a top Content Creator!",
				Animation = "Glow"
			},
			{
				Display = "Swiftie",
				Color = Color3.fromRGB(253, 185, 255),
				StrokeTransparency = 0.35,
				Font = "rbxasset://fonts/families/IndieFlower.json",
				Size = 6,
				Bold = true,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "My heart sings louder when yours does. It's kind of a magical bond, don't you think?",
				Animation = "Sparkle"
			},
			{
				Display = "Kirby",
				Color = Color3.fromRGB(236, 108, 143),
				StrokeColor = Color3.fromRGB(220, 127, 168),
				StrokeTransparency = 0.43,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				DontWrapInBrackets = true,
				Size = 7,
				HideIfNotOwned = true,
				Animation = "Dollface",
				Description = "Cute like Kirby - Ender"
			},
			{
				Display = "Moon Jellyfish",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187369802",
				Size = 6,
				Bold = true,
				DontWrapInBrackets = true,
				HideIfNotOwned = true,
				Description = "Moonish jellyfish",
				Animation = "Jellyfish"
			},
			{
				Display = "RIOT CONTROL",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187368843",
				Size = 6,
				Bold = false,
				HideIfNotOwned = true,
				Description = "Members of the Riot Control Unit.",
				Animation = "Riot"
			},
			{
				Display = "₍^. .^₎",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.35,
				Font = "rbxasset://fonts/families/IndieFlower.json",
				Bold = true,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "Meow.",
				Animation = "Sparkle"
			},
			{
				Display = "Blaugrana",
				Color = Color3.fromRGB(58, 134, 255),
				Font = "rbxassetid://12187369802",
				Size = 6,
				Italic = true,
				Bold = false,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "Blaugrana!",
				Animation = "Blaugrana"
			},
			{
				Display = "Mochi Donut",
				Color = Color3.fromRGB(255, 146, 213),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187369802",
				Bold = true,
				HideIfNotOwned = true,
				Description = "yummy",
				Animation = "Glow",
				DontWrapInBrackets = true
			},
			{
				Display = "Soda Pop",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187377325",
				Bold = true,
				HideIfNotOwned = true,
				Description = "SAJA BOYS!",
				Animation = "SodaPop"
			},
			{
				Display = "Universe",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187369802",
				Bold = true,
				Size = 6,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "Universe.",
				Animation = "Universe"
			},
			{
				Display = "Mr. 100",
				Other = "Mrs. 100",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187376739",
				Bold = true,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "100.",
				Animation = "Mr100"
			},
			{
				Display = "Dollface",
				Color = Color3.fromRGB(255, 60, 0),
				Font = "rbxassetid://12187369802",
				Size = 6,
				Italic = true,
				Bold = false,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Description = "CARAPHERNALIA!",
				Animation = "Dollface"
			},
			{
				Display = "Tester",
				Color = Color3.fromRGB(88, 255, 144),
				Bold = true,
				Size = 4,
				Description = "They help test things out before the update! We don't want broken updates now, do we?"
			},
			{
				Display = "Senior Tester",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				Size = 4,
				Description = "Most active in helping to test things out before the update! We don't want broken updates now, do we?",
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Animation = "Type"
			},
			{
				Display = "Content Creator",
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.67,
				Color = Color3.fromRGB(255, 46, 46),
				Bold = true,
				Italic = true,
				Size = 4,
				Description = "Exclusive to those with the Influencer role in the West Corner group.",
				Animation = "Scramble",
				DontWrapInBrackets = true,
				Gradient = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 33, 43))
				}),
				GradientRotation = 85
			},
			{
				Display = "Events Team",
				Color = Color3.fromRGB(170, 0, 0),
				Font = Enum.Font.IndieFlower,
				Bold = true,
				StrokeColor = Color3.fromRGB(96, 28, 244),
				StrokeTransparency = 0.35,
				Size = 10,
				Description = "Partake in creating fun activities for the community.",
				Animation = "EventsTeam"
			},
			{
				Display = "Helper",
				Color = Color3.fromRGB(19, 170, 137),
				Font = Enum.Font.Ubuntu,
				Bold = true,
				StrokeColor = Color3.fromRGB(185, 125, 244),
				StrokeTransparency = 0.35,
				Size = 3,
				Description = "Helpers of the game.",
				Animation = "GrimReaper"
			},
			{
				Display = "Moderator",
				Color = Color3.fromRGB(170, 0, 0),
				Font = Enum.Font.Montserrat,
				Bold = true,
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Size = 10,
				Description = "They help keep the game safe.",
				Animation = "Moderator"
			},
			{
				Display = "Senior Moderator",
				Color = Color3.fromRGB(11, 231, 255),
				Font = Enum.Font.Montserrat,
				Bold = true,
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Size = 10,
				Description = "They help keep the game safer.",
				Animation = "Moderator"
			},
			{
				Display = "Head Moderator",
				Color = Color3.fromRGB(89, 92, 255),
				Font = Enum.Font.Montserrat,
				Bold = false,
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Size = 6,
				Description = "Catchers of wrongdoers.",
				Animation = "Head Moderator"
			},
			{
				Display = "Community Manager",
				Color = Color3.fromRGB(255, 255, 255),
				Bold = true,
				Font = "rbxassetid://8836875837",
				Size = 4,
				Description = "Pretty much unobtainable. They are the head of moderation after all.",
				Animation = "Explosion",
				DontWrapInBrackets = true,
				Gradient = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				}),
				GradientRotation = 75
			},
			{
				Display = "Contractor",
				Color = Color3.fromRGB(131, 223, 102),
				Font = Enum.Font.Antique,
				Size = 4,
				Description = "Contractor!",
				Bold = true,
				Animation = "Type"
			},
			{
				Display = "Developer",
				Color = Color3.fromRGB(64, 204, 255),
				Font = "rbxassetid://12187370928",
				Animation = "Tornado",
				Size = 4,
				Description = "They developed the game. You wouldn't have Neighbors without them, would you?",
				DontWrapInBrackets = true
			},
			{
				Display = "Director",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				Font = "rbxassetid://12187370928",
				Animation = "BoldWave",
				Size = 4,
				Description = ""
			}
		}
	},
	["Random Titles"] = {
		Order = 20,
		Items = {
			{
				Display = "Gangster",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Fondamento,
				Description = "Where we dropping?"
			},
			{
				Display = "Scientist",
				Color = Color3.fromRGB(126, 255, 195),
				Font = Enum.Font.Nunito,
				Description = "For every action there is an equal and opposite reaction."
			},
			{
				Display = "Explorer",
				Color = Color3.fromRGB(170, 140, 98),
				Font = Enum.Font.GrenzeGotisch,
				Description = "I'll find it... It definitely exists! The ONE-"
			},
			{
				Display = "Sassy",
				Color = Color3.fromRGB(255, 170, 255),
				Description = "HUH?"
			},
			{
				Display = "Troll",
				Color = Color3.fromRGB(4, 255, 0),
				Font = Enum.Font.Bangers,
				Description = "lol gg ez"
			},
			{
				Display = "Lonely",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.PatrickHand,
				Description = "I feel empty... just numb."
			},
			{
				Display = "Superstar",
				Color = Color3.fromRGB(252, 255, 65),
				Font = Enum.Font.PermanentMarker,
				Description = "I'm BLAZING! I'm on top of the world!"
			},
			{
				Display = "Fugitive",
				Color = Color3.fromRGB(43, 43, 43),
				Font = Enum.Font.GrenzeGotisch,
				Description = "You saw nothing."
			},
			{
				Display = "Artist",
				Color = Color3.fromRGB(255, 181, 225),
				Font = Enum.Font.IndieFlower,
				Description = "Have you heard of color theory?"
			},
			{
				Display = "Introvert",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.PatrickHand,
				Description = "I need my alone time."
			},
			{
				Display = "Extrovert",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.LuckiestGuy,
				Description = "Let's go out!"
			},
			{
				Display = "Delicate",
				Color = Color3.fromRGB(201, 185, 255),
				Font = Enum.Font.Antique,
				Description = "I'm like a flower, beautiful but fragile."
			},
			{
				Display = "Wild Dog",
				Color = Color3.fromRGB(255, 93, 93),
				Font = Enum.Font.Creepster,
				Description = "BARK! BARK! BARK!"
			},
			{
				Display = "Untameable",
				Color = Color3.fromRGB(255, 170, 0),
				Font = Enum.Font.Creepster,
				Description = "I cannot be stopped. I cannot falter. I am UNTAMEABLE!"
			},
			{
				Display = "Toxic",
				Color = Color3.fromRGB(170, 85, 255),
				Font = Enum.Font.DenkOne,
				Description = "Yes. I do bring down the energy in every situation I go into."
			},
			{
				Display = "Killer",
				Color = Color3.fromRGB(170, 0, 0),
				Font = Enum.Font.Antique,
				Description = "I will show you death."
			},
			{
				Display = "Struggler",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.SpecialElite,
				Description = "I'll fall but always stand up."
			},
			{
				Display = "Empath",
				Color = Color3.fromRGB(85, 255, 255),
				Font = Enum.Font.Jura,
				Description = "I can literally feel your emotions as if they were my own. It's a pretty rare skill you know!"
			},
			{
				Display = "Gaslighter",
				Color = Color3.fromRGB(175, 84, 24),
				Font = Enum.Font.DenkOne,
				Description = "I would never, are you crazy?"
			},
			{
				Display = "Insomniac",
				Color = Color3.fromRGB(173, 173, 173),
				Font = Enum.Font.Fondamento,
				Description = "I just... can't sleep."
			},
			{
				Display = "Neko",
				Color = Color3.fromRGB(255, 85, 127),
				Description = "Purrrrrrr... meow! meow!"
			},
			{
				Display = "Sus",
				Color = Color3.fromRGB(0, 170, 255),
				Font = Enum.Font.LuckiestGuy,
				Description = "OMEGALUL SUS"
			},
			{
				Display = "Prince",
				Other = "Princess",
				Color = Color3.fromRGB(255, 255, 117),
				Font = Enum.Font.Bodoni,
				Description = "I belong to royalty. And you?"
			},
			{
				Display = "Professor",
				Color = Color3.fromRGB(0, 255, 255),
				Font = Enum.Font.Nunito,
				Description = "The next generation, the future of humanity.. It lies in my hands."
			},
			{
				Display = "Conqueror",
				Color = Color3.fromRGB(255, 84, 84),
				Font = Enum.Font.SpecialElite,
				Description = "What's yours isn't mine. I will take it."
			},
			{
				Display = "Demon",
				Color = Color3.fromRGB(255, 0, 0),
				Font = Enum.Font.SpecialElite,
				Description = "I am your worse enemy."
			},
			{
				Display = "Blessed",
				Color = Color3.fromRGB(255, 255, 127),
				Font = Enum.Font.PatrickHand,
				Description = "I bring holy energy. Let there be peace!"
			},
			{
				Display = "Protagonist",
				Color = Color3.fromRGB(85, 255, 127),
				Font = Enum.Font.PatrickHand,
				Description = "This story revolves around me, pal."
			},
			{
				Display = "Apex Predator",
				Color = Color3.fromRGB(85, 170, 127),
				Font = Enum.Font.SpecialElite,
				Description = "You thought you were at the top of the food chain? Look again! I am the food chain! RAGHHH!"
			},
			{
				Display = "Thinker",
				Color = Color3.fromRGB(170, 255, 238),
				Font = Enum.Font.SourceSansSemibold,
				Description = "How can we truly be sure of anything?"
			},
			{
				Display = "The Shadow",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.SpecialElite,
				Description = "I lurk in the shadows. I observe silently before I strike when you're weak."
			},
			{
				Display = "Mastermind",
				Color = Color3.fromRGB(170, 85, 255),
				Font = Enum.Font.SciFi,
				Description = "I view the world like a chessboard. I am not the King and I'm surely not a pawn. I am the one who plays."
			},
			{
				Display = "Devil",
				Color = Color3.fromRGB(200, 51, 40),
				Font = Enum.Font.Creepster,
				Description = "You fear a mere demon?"
			},
			{
				Display = "Alpha",
				Color = Color3.fromRGB(255, 48, 48),
				Font = Enum.Font.LuckiestGuy,
				Description = "Yep. WE UP NOW!"
			},
			{
				Display = "UwU",
				Color = Color3.fromRGB(255, 131, 238),
				Font = Enum.Font.Cartoon,
				Description = "UwU! UwU! uwu"
			},
			{
				Display = "Legend",
				Color = Color3.fromRGB(0, 255, 255),
				Font = Enum.Font.Code,
				Description = "My name is ingraved in history."
			},
			{
				Display = "Father",
				Other = "Mother",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.RobotoMono,
				Description = "I was there before you were."
			},
			{
				Display = "Sigma",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Garamond,
				Description = "*releases intense aura*"
			},
			{
				Display = "Atomic",
				Color = Color3.fromRGB(222, 105, 255),
				Font = Enum.Font.Highway,
				Description = "I am... atomic! *DZHDHHDZHZHH*"
			},
			{
				Display = "Evil",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Creepster,
				Description = "There's a reason for everything. Everything but true evil."
			},
			{
				Display = "King",
				Other = "Queen",
				Color = Color3.fromRGB(120, 93, 255),
				Font = Enum.Font.Antique,
				Description = "This is my Kingdom."
			},
			{
				Display = "Godfather",
				Other = "Godmother",
				Color = Color3.fromRGB(255, 255, 127),
				Font = Enum.Font.Antique,
				Description = "Yes. You have permission to go outside."
			},
			{
				Display = "The Almighty",
				Color = Color3.fromRGB(129, 255, 90),
				Font = Enum.Font.SourceSansBold,
				Description = "Those who do not understand true pain can never understand true peace."
			},
			{
				Display = "His Majesty",
				Color = Color3.fromRGB(141, 2, 255),
				Font = Enum.Font.Antique,
				Description = "I control. I conqueror. I win. Say my name properly.",
				Size = 4
			},
			{
				Display = "Chad",
				Color = Color3.fromRGB(255, 255, 0),
				Font = Enum.Font.Bangers,
				Description = "Yep! How you doing man? I've been doing great!"
			},
			{
				Display = "Chief",
				Color = Color3.fromRGB(65, 38, 34),
				Font = Enum.Font.Bodoni,
				Description = "I run this place, you hear?"
			},
			{
				Display = "Doctor",
				Color = Color3.fromRGB(189, 252, 255),
				Font = Enum.Font.JosefinSans,
				Description = "Seems like you've got a broken arm! That'll only be a couple grand to fix with insurance. Not bad!"
			},
			{
				Display = "Don",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Fondamento,
				Description = "Capiche?"
			},
			{
				Display = "Emperor",
				Other = "Empress",
				Color = Color3.fromRGB(255, 1, 1),
				Font = Enum.Font.Bodoni,
				Description = "I commend you!"
			},
			{
				Display = "Wizard",
				Color = Color3.fromRGB(234, 212, 101),
				Font = Enum.Font.Kalam,
				Description = "I always wondered what it'd be like to have magic."
			},
			{
				Display = "Priest",
				Color = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Antique,
				Description = "Seek salvation."
			},
			{
				Display = "President",
				Color = Color3.fromRGB(255, 236, 32),
				Font = Enum.Font.GrenzeGotisch,
				Description = "I, " .. (game.Players.LocalPlayer and game.Players.LocalPlayer.DisplayName or "??") .. " will make this country great!"
			},
			{
				Display = "Saint",
				Color = Color3.fromRGB(255, 249, 88),
				Font = Enum.Font.IndieFlower,
				Description = "I only wish for the best for you. Please follow the right path!"
			},
			{
				Display = "Brother",
				Other = "Sister",
				Color = Color3.fromRGB(157, 213, 255),
				Font = Enum.Font.Ubuntu,
				Description = "What on earth?"
			},
			{
				Display = "Sunshine",
				Color = Color3.fromRGB(255, 255, 0),
				Font = Enum.Font.Bangers,
				Description = "It's a beautiful day! Ohh~~ the sun is so bright!"
			},
			{
				Display = "Faceless",
				Color = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Oswald,
				Description = "What do you call a man with no face? Faceless."
			},
			{
				Display = "Hacker",
				Color = Color3.fromRGB(0, 255, 0),
				Font = Enum.Font.Arcade,
				Description = "No! Not Byfron! No! No!!"
			},
			{
				Display = "Chill",
				Color = Color3.fromRGB(255, 170, 0),
				Font = Enum.Font.LuckiestGuy,
				Description = "Yeahhhh man, I'm saying."
			},
			{
				Display = "404",
				Color = Color3.fromRGB(255, 0, 0),
				Font = Enum.Font.Arcade,
				Description = "Error."
			},
			{
				Display = "Gamer",
				Color = Color3.fromRGB(85, 255, 255),
				Font = Enum.Font.Arcade,
				Description = "I'm playing Neighbors mom! Go away!"
			},
			{
				Display = "Captain",
				Color = Color3.fromRGB(179, 150, 5),
				Font = Enum.Font.GrenzeGotisch,
				Description = "This is your captain speaking."
			},
			{
				Display = "Jester",
				Color = Color3.fromRGB(203, 114, 248),
				Font = Enum.Font.Fondamento,
				Description = "You fools! It was me all along!"
			},
			{
				Display = "Samurai",
				Color = Color3.fromRGB(163, 163, 163),
				Font = Enum.Font.Bodoni,
				Description = "A warrior is worthless unless he rises above others and stands strong in the midst of a storm."
			},
			{
				Display = "Knight",
				Color = Color3.fromRGB(163, 163, 163),
				Font = Enum.Font.Kalam,
				Description = "I'll serve until I physically can't anymore."
			},
			{
				Display = "Witch",
				Color = Color3.fromRGB(85, 54, 163),
				Font = Enum.Font.Garamond,
				Description = "A true apothcary is at hand..."
			},
			{
				Display = "Reaper",
				Color = Color3.fromRGB(80, 21, 21),
				Font = Enum.Font.SpecialElite,
				Description = "Your time has come."
			},
			{
				Display = "Pirate",
				Color = Color3.fromRGB(255, 183, 15),
				Font = Enum.Font.Cartoon,
				Description = "On the left boys! Theres the X!"
			},
			{
				Display = "Phantom",
				Color = Color3.fromRGB(255, 181, 235),
				Font = Enum.Font.SciFi,
				Description = "He's a phantom."
			},
			{
				Display = "Hero",
				Color = Color3.fromRGB(255, 243, 78),
				Font = Enum.Font.Fantasy,
				Description = "I need a hero!"
			},
			{
				Display = "Outlaw",
				Color = Color3.fromRGB(168, 51, 22),
				Font = Enum.Font.IndieFlower,
				Description = "I keep runnin' and they keep chasin'..."
			},
			{
				Display = "Cowboy",
				Color = Color3.fromRGB(168, 103, 56),
				Font = Enum.Font.IndieFlower,
				Description = "He's all hat and no cattle."
			},
			{
				Display = "Ninja",
				Color = Color3.fromRGB(36, 32, 23),
				Font = Enum.Font.IndieFlower,
				Description = "The first rule of being a ninja is ‘Do no harm.’ Unless you mean to do harm, then do lots of harm."
			}
		}
	},
	["Prestige Pack"] = {
		Order = 21,
		Items = {
			{
				Display = "Paragon",
				Color = Color3.fromRGB(176, 12, 14),
				StrokeColor = Color3.fromRGB(70, 13, 13),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Gotham,
				Bold = true,
				Description = "A perfect example of excellance."
			},
			{
				Display = "Enigma",
				Color = Color3.fromRGB(249, 82, 255),
				StrokeColor = Color3.fromRGB(249, 183, 255),
				StrokeTransparency = 0.75,
				Font = Enum.Font.JosefinSans,
				Bold = false,
				Size = -2,
				Description = "I can't get my mind around it."
			},
			{
				Display = "Catalyst",
				Color = Color3.fromRGB(162, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.75,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 4,
				Description = "Many don't know how it started... but they do."
			},
			{
				Display = "Valkyrie",
				Color = Color3.fromRGB(239, 215, 31),
				StrokeColor = Color3.fromRGB(168, 148, 0),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Antique,
				Bold = true,
				Description = "Chooser of the Slain"
			},
			{
				Display = "Celestial",
				Color = Color3.fromRGB(149, 195, 255),
				StrokeColor = Color3.fromRGB(130, 99, 255),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Description = "They belong to the stars."
			},
			{
				Display = "Seraph",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(144, 201, 255),
				StrokeTransparency = 0.2,
				Font = Enum.Font.Fantasy,
				Bold = false,
				Description = "Some of the highest and purist beings."
			},
			{
				Display = "Guardian",
				Color = Color3.fromRGB(1, 40, 124),
				StrokeColor = Color3.fromRGB(76, 122, 190),
				StrokeTransparency = 0.5,
				Font = Enum.Font.DenkOne,
				Bold = true,
				Description = "A protector of those above."
			},
			{
				Display = "Oracle",
				Color = Color3.fromRGB(85, 255, 96),
				StrokeColor = Color3.fromRGB(0, 126, 15),
				StrokeTransparency = 0.75,
				Font = Enum.Font.Michroma,
				Bold = true,
				Description = "They explain the deep meaning behind all of this."
			},
			{
				Display = "Rebel",
				Color = Color3.fromRGB(255, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 7,
				Description = "The ones who keep breaking all the rules."
			},
			{
				Display = "Savant",
				Color = Color3.fromRGB(255, 174, 93),
				StrokeColor = Color3.fromRGB(98, 79, 34),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = true,
				Description = "Most talented."
			},
			{
				Display = "Savant",
				Color = Color3.fromRGB(255, 174, 93),
				StrokeColor = Color3.fromRGB(98, 79, 34),
				StrokeTransparency = 0.35,
				Font = Enum.Font.DenkOne,
				Bold = true,
				Description = "Most talented."
			},
			{
				Display = "Vanguard",
				Color = Color3.fromRGB(73, 117, 75),
				StrokeColor = Color3.fromRGB(63, 117, 1),
				StrokeTransparency = 0.8,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 2,
				Description = "Leading us into a developmental future."
			},
			{
				Display = "Astral",
				Color = Color3.fromRGB(43, 56, 117),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.8,
				Font = Enum.Font.Sarpanch,
				Bold = true,
				Animation = "BoldWave",
				Description = "The mediums connecting us to the stars."
			},
			{
				Display = "Juggernaut",
				Color = Color3.fromRGB(255, 46, 46),
				StrokeColor = Color3.fromRGB(90, 15, 15),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Jura,
				Bold = true,
				Animation = "Type",
				Description = "Strong beings protecting our nation."
			},
			{
				Display = "Maverick",
				Color = Color3.fromRGB(38, 107, 255),
				StrokeColor = Color3.fromRGB(20, 47, 90),
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Animation = "Maverick",
				Size = 4,
				Description = "Out of the ordinary lone wolves."
			},
			{
				Display = "Voyager",
				Color = Color3.fromRGB(78, 84, 134),
				StrokeColor = Color3.fromRGB(92, 203, 255),
				StrokeTransparency = 0.35,
				Font = Enum.Font.SciFi,
				Bold = false,
				Size = -2,
				Description = "Across the systems."
			},
			{
				Display = "One Above All",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(81, 0, 255),
				StrokeTransparency = 0.35,
				Font = Enum.Font.SciFi,
				Bold = true,
				Animation = "RainbowWave",
				Description = "The True Leader"
			}
		}
	},
	["Luck Pack"] = {
		Order = 23,
		Items = {
			{
				Display = "Lucky",
				Color = Color3.fromRGB(0, 255, 0),
				Font = Enum.Font.LuckiestGuy,
				Description = "Lady Luck is on your side."
			},
			{
				Display = "Irish",
				Bold = true,
				Color = Color3.fromRGB(0, 155, 0),
				Font = Enum.Font.GrenzeGotisch,
				Size = 3,
				Description = "Straight from the Emerald Isle."
			},
			{
				Display = "Charmer",
				Color = Color3.fromRGB(255, 170, 255),
				Font = Enum.Font.IndieFlower,
				Description = "You have a way with words."
			},
			{
				Display = "Enchanter",
				Color = Color3.fromRGB(111, 8, 255),
				Font = Enum.Font.Kalam,
				Description = "Woven with lucky magic."
			},
			{
				Display = "Druid",
				Bold = true,
				Color = Color3.fromRGB(101, 186, 55),
				Size = 8,
				Font = "rbxassetid://12187369802",
				Description = "One with the nature around us."
			},
			{
				Display = "Enchanted",
				Color = Color3.fromRGB(156, 56, 255),
				Size = 1,
				Font = "rbxassetid://12187377325",
				Description = "Glowing with a lucky aura."
			},
			{
				Display = "Talisman",
				Color = Color3.fromRGB(218, 165, 32),
				Font = Enum.Font.SpecialElite,
				Description = "An object of great fortune."
			},
			{
				Display = "Relic",
				Color = Color3.fromRGB(169, 169, 169),
				Font = Enum.Font.Bodoni,
				Description = "A remnant of a lost era."
			},
			{
				Display = "Fernbound",
				Color = Color3.fromRGB(0, 157, 0),
				Font = Enum.Font.SciFi,
				Description = "Tied to the deep woods forever."
			},
			{
				Display = "Gold Keeper",
				Color = Color3.fromRGB(255, 215, 0),
				StrokeColor = Color3.fromRGB(120, 90, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Garamond,
				Bold = true,
				Animation = "Shine",
				Description = "Guardian of the pot at the end of the rainbow."
			},
			{
				Display = "Mr. Emerald",
				Other = "Mrs. Emerald",
				Color = Color3.fromRGB(0, 201, 87),
				StrokeColor = Color3.fromRGB(0, 50, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187376910",
				Bold = true,
				Animation = "BoldWave",
				Description = "The finest gem in the kingdom."
			},
			{
				Display = "Cloverlord",
				Color = Color3.fromRGB(50, 205, 50),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.2,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Size = 6,
				Animation = "RainbowWave",
				Description = "The true master of four leaves."
			}
		}
	},
	["Halloween Pack"] = {
		Order = 23,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Haunted",
				Color = Color3.fromRGB(85, 85, 127),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.AmaticSC,
				Bold = true,
				Size = 4,
				Description = "The walls whisper when I pass."
			},
			{
				Display = "Ghoul",
				Color = Color3.fromRGB(255, 217, 184),
				StrokeColor = Color3.fromRGB(255, 167, 167),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 4,
				Description = "Feed on the dead."
			},
			{
				Display = "Cursed",
				Color = Color3.fromRGB(255, 144, 146),
				StrokeColor = Color3.fromRGB(89, 7, 8),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 1,
				Description = "You'll fall soon enough."
			},
			{
				Display = "Boo",
				Color = Color3.fromRGB(197, 250, 255),
				StrokeColor = Color3.fromRGB(113, 167, 179),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Bangers,
				Bold = false,
				Description = "So scary!"
			},
			{
				Display = "Zombie",
				Color = Color3.fromRGB(161, 231, 161),
				StrokeColor = Color3.fromRGB(0, 135, 56),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 1,
				Description = "Braaaains..."
			},
			{
				Display = "Haunted",
				Color = Color3.fromRGB(77, 51, 144),
				StrokeColor = Color3.fromRGB(106, 80, 184),
				StrokeTransparency = 0.45,
				Font = Enum.Font.Creepster,
				Bold = false,
				Description = "Always the mansion."
			},
			{
				Display = "Wraith",
				Color = Color3.fromRGB(97, 54, 55),
				StrokeColor = Color3.fromRGB(115, 82, 87),
				StrokeTransparency = 0.57,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 4,
				Description = "The deads image."
			},
			{
				Display = "Sinister",
				Color = Color3.fromRGB(173, 57, 59),
				StrokeColor = Color3.fromRGB(74, 14, 15),
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 2,
				Animation = "BoldWave",
				Description = "Oh so freaky!"
			},
			{
				Display = "Ghastly",
				Color = Color3.fromRGB(0, 198, 155),
				StrokeColor = Color3.fromRGB(8, 86, 93),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 2,
				Description = "So scary!"
			},
			{
				Display = "Super Natural",
				Color = Color3.fromRGB(214, 225, 4),
				StrokeColor = Color3.fromRGB(107, 86, 10),
				StrokeTransparency = 0.35,
				Font = Enum.Font.DenkOne,
				Bold = true,
				Description = "Powers from below."
			},
			{
				Display = "Necromancer",
				Color = Color3.fromRGB(146, 152, 225),
				StrokeColor = Color3.fromRGB(54, 56, 83),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Creepster,
				Bold = true,
				Description = "What a creature!"
			},
			{
				Display = "Trick or Treat",
				Color = Color3.fromRGB(225, 120, 1),
				StrokeColor = Color3.fromRGB(107, 54, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Animation = "TrickOrTreat",
				Description = "I choose trick..."
			},
			{
				Display = "Pumpkin Man",
				Other = "Pumpkin Woman",
				Color = Color3.fromRGB(255, 150, 2),
				StrokeColor = Color3.fromRGB(125, 100, 36),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = true,
				Description = "Who wears these on heads?"
			},
			{
				Display = "Grim Reaper",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.SpecialElite,
				Bold = true,
				Animation = "GrimReaper",
				Description = "Fetch me their souls!"
			},
			{
				Display = "Skeleton",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.7,
				Font = Enum.Font.AmaticSC,
				Bold = true,
				Size = 4,
				Description = "How do they even move? I mean, they don't even have any muscles. They are just bones. How the hell does that even work? They have no blood flow, nothing. What makes them move around? I will never understand."
			},
			{
				Display = "Bewitched",
				Color = Color3.fromRGB(167, 50, 112),
				StrokeColor = Color3.fromRGB(255, 119, 167),
				StrokeTransparency = 0.7,
				Font = Enum.Font.AmaticSC,
				Bold = false,
				Size = 2,
				Description = "Beware!"
			},
			{
				Display = "Oni",
				Color = Color3.fromRGB(167, 0, 3),
				StrokeColor = Color3.fromRGB(85, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Highway,
				Bold = true,
				Size = 2,
				Description = "Monster!"
			},
			{
				Display = "Crow",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.GothamBlack,
				Bold = true,
				Size = 4,
				Description = "Fly during the night!"
			},
			{
				Display = "Fearless",
				Other = "Fearful",
				Color = Color3.fromRGB(167, 77, 77),
				StrokeColor = Color3.fromRGB(176, 200, 255),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Creepster,
				Bold = false,
				Size = 3,
				Description = "I seek no fear!"
			},
			{
				Display = "Banshee",
				Color = Color3.fromRGB(167, 160, 160),
				StrokeColor = Color3.fromRGB(253, 255, 254),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Bangers,
				Bold = false,
				Size = 2,
				Description = "Scary ghost, ooooo!"
			},
			{
				Display = "Sorcerer",
				Other = "Sorceress",
				Color = Color3.fromRGB(167, 159, 67),
				StrokeColor = Color3.fromRGB(139, 255, 255),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Ubuntu,
				Bold = false,
				Size = 2,
				Description = "Become the greatest Sorcerer!"
			},
			{
				Display = "Yokai",
				Color = Color3.fromRGB(66, 64, 62),
				StrokeColor = Color3.fromRGB(95, 255, 67),
				StrokeTransparency = 0.4,
				Font = Enum.Font.SciFi,
				Bold = false,
				Size = 2,
				Description = "What type of monster are you?"
			},
			{
				Display = "Corpse",
				Color = Color3.fromRGB(85, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.SpecialElite,
				Bold = false,
				Size = 3,
				Description = "Rotting, but not forgotten."
			},
			{
				Display = "Decaying",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187367066",
				Bold = false,
				Size = 3,
				Description = "Every breath is my last."
			},
			{
				Display = "Soulbound",
				Color = Color3.fromRGB(149, 117, 167),
				StrokeColor = Color3.fromRGB(246, 192, 255),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Creepster,
				Bold = false,
				Size = 3,
				Description = "Bound to a soul."
			},
			{
				Display = "Scarecrow",
				Color = Color3.fromRGB(221, 221, 113),
				StrokeColor = Color3.fromRGB(110, 255, 151),
				StrokeTransparency = 0.65,
				Font = Enum.Font.GothamMedium,
				Bold = false,
				Size = 2,
				Description = "Stand still in the field."
			},
			{
				Display = "Gargoyle",
				Color = Color3.fromRGB(167, 153, 141),
				StrokeColor = Color3.fromRGB(82, 93, 73),
				StrokeTransparency = 0.45,
				Font = Enum.Font.Jura,
				Bold = false,
				Size = 2,
				Description = "Protect the gates of Neighbors!"
			},
			{
				Display = "Specter",
				Color = Color3.fromRGB(74, 62, 52),
				StrokeColor = Color3.fromRGB(27, 25, 22),
				StrokeTransparency = 0.5,
				Font = Enum.Font.GrenzeGotisch,
				Italic = true,
				Bold = true,
				Size = 2,
				Animation = "Shine",
				Description = "You'll feel the chill before you see me."
			},
			{
				Display = "Fiend",
				Color = Color3.fromRGB(193, 37, 9),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 2,
				Description = "Your suffering is my delight.",
				Animation = "TypeWave"
			},
			{
				Display = "Soul Harvester",
				Color = Color3.fromRGB(167, 50, 112),
				StrokeColor = Color3.fromRGB(255, 119, 167),
				StrokeTransparency = 0.5,
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 2,
				Description = "Collect the souls of all!"
			},
			{
				Display = "Wandering Spirit",
				Color = Color3.fromRGB(182, 182, 182),
				StrokeColor = Color3.fromRGB(227, 255, 201),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 4,
				Description = "Just a roaming spirit!"
			},
			{
				Display = "Nightmare",
				Color = Color3.fromRGB(121, 27, 23),
				StrokeColor = Color3.fromRGB(21, 21, 31),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 4,
				Animation = "Wave",
				Description = "Sleep tight... if you can."
			},
			{
				Display = "Forsaken",
				Color = Color3.fromRGB(66, 42, 127),
				StrokeColor = Color3.fromRGB(27, 27, 40),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187368843",
				Bold = false,
				Size = 4,
				Animation = "Forsaken",
				Description = "Left behind by the living."
			},
			{
				Display = "Death",
				Color = Color3.fromRGB(195, 0, 3),
				StrokeColor = Color3.fromRGB(85, 0, 127),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Creepster,
				Bold = true,
				Size = 4,
				Animation = "Wave",
				Description = "Time is up."
			},
			{
				Display = "Black Cat",
				Color = Color3.fromRGB(255, 255, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Kalam,
				Bold = false,
				Size = 2,
				Animation = "BoldWave",
				Description = "Uh oh, unlucky!"
			},
			{
				Display = "Headless Horseman",
				Color = Color3.fromRGB(255, 85, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.45,
				Font = Enum.Font.Garamond,
				Bold = false,
				Size = 4,
				Animation = "GrimReaper",
				Description = "Become THE Headless Horseman!"
			},
			{
				Display = "Thing",
				Color = Color3.fromRGB(85, 85, 0),
				StrokeColor = Color3.fromRGB(85, 170, 127),
				StrokeTransparency = 0.5,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 4,
				Animation = "Thing",
				Description = "Just a helping hand..."
			},
			{
				Display = "Wednesday",
				Color = Color3.fromRGB(85, 0, 255),
				StrokeColor = Color3.fromRGB(19, 0, 57),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 4,
				Animation = "GrimReaper",
				Description = "I'm not perky."
			}
		}
	},
	["Thanksgiving Pack"] = {
		Order = 23,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Leafling",
				Color = Color3.fromRGB(223, 175, 43),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = "rbxasset://fonts/families/Fondamento.json",
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "TypeWave"
			},
			{
				Display = "Cornucopian",
				Color = Color3.fromRGB(199, 199, 199),
				StrokeColor = Color3.fromRGB(39, 14, 14),
				StrokeTransparency = 0.5,
				Font = "rbxasset://fonts/families/Guru.json",
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "Cornucopian"
			},
			{
				Display = "Hearthkeeper",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Merriweather,
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "Hearthkeeper"
			},
			{
				Display = "Corn King",
				Other = "Corn Queen",
				Color = Color3.fromRGB(255, 212, 71),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187366846",
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "TypeWave"
			},
			{
				Display = "Pilgrim",
				Color = Color3.fromRGB(200, 200, 100),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Code,
				Bold = false,
				Size = 2.5,
				Animation = "BoldWave",
				Description = "You is a Pilgrim!"
			},
			{
				Display = "Turkeyman",
				Other = "Turkeywoman",
				Color = Color3.fromRGB(85, 85, 127),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 2,
				Animation = "BrickGod",
				Description = "BAK BAK BAK TURKEYMAN!"
			},
			{
				Display = "Gobbler",
				Color = Color3.fromRGB(255, 136, 1),
				StrokeColor = Color3.fromRGB(255, 217, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Kalam,
				Bold = false,
				Size = 2,
				Description = "Gobble, gobble, gobble!"
			},
			{
				Display = "Grateful",
				Color = Color3.fromRGB(45, 26, 255),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.5,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Size = 2,
				Animation = "Maverick",
				Description = "Better be grateful for this!"
			},
			{
				Display = "Forager",
				Color = Color3.fromRGB(204, 102, 255),
				StrokeColor = Color3.fromRGB(65, 31, 7),
				StrokeTransparency = 0.5,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 2,
				Description = "Get foraging!"
			},
			{
				Display = "Gatherer",
				Color = Color3.fromRGB(0, 255, 127),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Jura,
				Bold = false,
				Size = 2,
				Description = "Gather all you can!"
			},
			{
				Display = "Baker",
				Color = Color3.fromRGB(170, 0, 127),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.5,
				Font = Enum.Font.LuckiestGuy,
				Bold = false,
				Size = 2,
				Description = "What should we bake?"
			},
			{
				Display = "Mender",
				Color = Color3.fromRGB(255, 119, 65),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Arial,
				Bold = false,
				Size = 2,
				Description = "Mendddddinggg..."
			},
			{
				Display = "Seedling",
				Color = Color3.fromRGB(113, 113, 15),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Highway,
				Bold = false,
				Size = 2,
				Description = "Just a seedling idk!"
			},
			{
				Display = "Carver",
				Color = Color3.fromRGB(0, 255, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 2,
				Description = "Carve it up!"
			},
			{
				Display = "Faster",
				Color = Color3.fromRGB(255, 138, 138),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Sarpanch,
				Bold = false,
				Size = 2,
				Description = "Gotta go quick!"
			}
		}
	},
	["4th of July Pack"] = {
		Order = 24,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Sparkles",
				Color = Color3.fromRGB(255, 215, 0),
				StrokeColor = Color3.fromRGB(255, 61, 61),
				StrokeTransparency = 0.4,
				Font = "rbxassetid://12187377325",
				Description = "Shine bright like a firework!",
				Animation = "BrickGod"
			},
			{
				Display = "Valor",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(10, 46, 122),
				Font = "rbxasset://fonts/families/Fondamento.json",
				Description = "Honor and true bravery.",
				Animation = "BoldWave"
			},
			{
				Display = "Pyrotechnic",
				Color = Color3.fromRGB(255, 69, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Sarpanch,
				Bold = true,
				Description = "Don't try this at home!"
			},
			{
				Display = "Cookout Master",
				Color = Color3.fromRGB(212, 91, 16),
				StrokeColor = Color3.fromRGB(39, 14, 14),
				Font = Enum.Font.DenkOne,
				Description = "Who ordered the extra-charred burgers?"
			},
			{
				Display = "Minuteman",
				Color = Color3.fromRGB(200, 180, 120),
				StrokeColor = Color3.fromRGB(40, 40, 40),
				Font = Enum.Font.Merriweather,
				Description = "Ready at a moment's notice!",
				Animation = "TypeWave"
			},
			{
				Display = "American",
				Color = Color3.fromRGB(10, 46, 122),
				StrokeColor = Color3.fromRGB(214, 40, 40),
				StrokeTransparency = 0.8,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Description = "Land of the free, home of the brave.",
				Animation = "BoldWave"
			},
			{
				Display = "Uncle Sam",
				Color = Color3.fromRGB(180, 0, 3),
				StrokeColor = Color3.fromRGB(32, 0, 214),
				StrokeTransparency = 0.8,
				Font = Enum.Font.Montserrat,
				Bold = true,
				Description = "Uncle Sam wants YOU!",
				Animation = "Universe"
			},
			{
				Display = "Bald Eagle",
				Color = Color3.fromRGB(161, 141, 116),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.8,
				Font = "rbxassetid://12187370928",
				Bold = true,
				Description = "The American way!"
			},
			{
				Display = "Liberator",
				Color = Color3.fromRGB(255, 234, 0),
				StrokeColor = Color3.fromRGB(0, 128, 214),
				StrokeTransparency = 0.8,
				Font = "rbxassetid://12187370928",
				Bold = true,
				Description = "The big blue sky, liberated.",
				Animation = "Maverick"
			},
			{
				Display = "Patriot",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(255, 0, 4),
				StrokeTransparency = 0.8,
				Font = "rbxassetid://12187375194",
				Bold = true,
				Description = "Patriotic, like an American."
			}
		}
	},
	["July Pack"] = {
		Order = 36,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Duke of July",
				Other = "Duchess of July",
				Color = Color3.fromRGB(255, 0, 4),
				StrokeColor = Color3.fromRGB(0, 174, 255),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Antique,
				Bold = false,
				Description = "Happy 4th.",
				Animation = "BoldWave"
			},
			{
				Display = "Mr. Firework",
				Other = "Mrs. Firework",
				Color = Color3.fromRGB(255, 0, 9),
				StrokeColor = Color3.fromRGB(244, 245, 255),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187377325",
				Italic = true,
				HideIfNotOwned = true,
				DontWrapInBrackets = true,
				Animation = "Shine",
				Description = "Just like a firework."
			}
		}
	},
	["Summer Banner"] = {
		Order = 37,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Surfer",
				Color = Color3.fromRGB(129, 217, 255),
				Font = Enum.Font.Bodoni,
				DontWrapInBrackets = true,
				Animation = "Cornucopian",
				Description = ""
			},
			{
				Display = "Golden Hour",
				Color = Color3.fromRGB(255, 235, 17),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				Font = Enum.Font.Garamond,
				Italic = true,
				Animation = "Mr100",
				Description = ""
			}
		}
	},
	["Donator Titles"] = {
		Order = 22,
		Items = {
			{
				Display = "Selfless",
				Color = Color3.fromRGB(126, 255, 147),
				StrokeColor = Color3.fromRGB(47, 122, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Kalam,
				Bold = false,
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 100 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Charitable",
				Color = Color3.fromRGB(33, 255, 188),
				StrokeColor = Color3.fromRGB(43, 58, 106),
				StrokeTransparency = 0.5,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 500 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Generous",
				Color = Color3.fromRGB(255, 148, 226),
				StrokeColor = Color3.fromRGB(106, 26, 71),
				StrokeTransparency = 0.5,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 1000 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Rich Donator",
				Color = Color3.fromRGB(179, 255, 0),
				StrokeColor = Color3.fromRGB(69, 106, 27),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Merriweather,
				Bold = true,
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 5000 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Outrageously Rich",
				Color = Color3.fromRGB(0, 255, 102),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 10000 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Money Man",
				Color = Color3.fromRGB(255, 217, 64),
				StrokeColor = Color3.fromRGB(107, 94, 31),
				StrokeTransparency = 0.5,
				Font = Enum.Font.FredokaOne,
				Bold = true,
				Animation = "BoldWave",
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 50000 Robux used to donate to others"
					end

					return "??"
				end
			},
			{
				Display = "Stinking Rich",
				Color = Color3.fromRGB(161, 255, 39),
				StrokeColor = Color3.fromRGB(0, 107, 34),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Creepster,
				Bold = true,
				Animation = "Wave",
				Description = function()
					local RunService2 = game:GetService("RunService")

					if RunService2:IsClient() then
						return tostring(Players.LocalPlayer:GetAttribute("TotalDonatedAmount") or "?") .. " / 100000 Robux used to donate to others"
					end

					return "??"
				end
			}
		}
	},
	["Santa's Pack"] = {
		Order = 24,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Reindeer",
				Color = Color3.fromRGB(255, 167, 66),
				StrokeColor = Color3.fromRGB(99, 65, 17),
				StrokeTransparency = 0.75,
				Font = Enum.Font.Kalam,
				Bold = false,
				Size = 0,
				Description = "Pull Santa's Sleigh"
			},
			{
				Display = "Holly",
				Color = Color3.fromRGB(255, 66, 69),
				StrokeColor = Color3.fromRGB(47, 255, 43),
				StrokeTransparency = 0.8,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = "Deck the halls"
			},
			{
				Display = "Jolly",
				Color = Color3.fromRGB(47, 255, 43),
				StrokeColor = Color3.fromRGB(255, 66, 69),
				StrokeTransparency = 0.8,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Gingerbread",
				Color = Color3.fromRGB(255, 137, 19),
				StrokeColor = Color3.fromRGB(255, 219, 17),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Bangers,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Frosty",
				Color = Color3.fromRGB(80, 208, 255),
				StrokeColor = Color3.fromRGB(0, 132, 255),
				StrokeTransparency = 0.6,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 0,
				Description = "Brrrrrr"
			},
			{
				Display = "Starlight",
				Color = Color3.fromRGB(255, 237, 135),
				StrokeColor = Color3.fromRGB(194, 182, 9),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Elf",
				Color = Color3.fromRGB(118, 255, 111),
				StrokeColor = Color3.fromRGB(23, 144, 10),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Merriweather,
				Bold = false,
				Size = 0,
				Description = "Okay people! Tomorrow morning, 10 AM!"
			},
			{
				Display = "Joyful",
				Color = Color3.fromRGB(251, 135, 255),
				StrokeColor = Color3.fromRGB(154, 63, 145),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Nutcracker",
				Color = Color3.fromRGB(255, 146, 148),
				StrokeColor = Color3.fromRGB(166, 31, 33),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Festive",
				Color = Color3.fromRGB(255, 52, 55),
				StrokeColor = Color3.fromRGB(102, 0, 2),
				StrokeTransparency = 0.6,
				Font = Enum.Font.Highway,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Merry",
				Color = Color3.fromRGB(255, 108, 110),
				StrokeColor = Color3.fromRGB(255, 0, 4),
				StrokeTransparency = 0.6,
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Mistletoe",
				Color = Color3.fromRGB(135, 255, 133),
				StrokeColor = Color3.fromRGB(31, 173, 24),
				StrokeTransparency = 0.6,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Santa",
				Color = Color3.fromRGB(255, 89, 89),
				StrokeColor = Color3.fromRGB(214, 214, 214),
				StrokeTransparency = 0.3,
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 2,
				Description = ""
			},
			{
				Display = "Jingle-Bells",
				Color = Color3.fromRGB(255, 234, 0),
				StrokeColor = Color3.fromRGB(214, 153, 0),
				StrokeTransparency = 0.3,
				Font = Enum.Font.Oswald,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "North-Pole",
				Color = Color3.fromRGB(166, 254, 255),
				StrokeColor = Color3.fromRGB(108, 182, 214),
				StrokeTransparency = 0.3,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Grinch",
				Color = Color3.fromRGB(122, 227, 115),
				StrokeColor = Color3.fromRGB(66, 136, 79),
				StrokeTransparency = 0.3,
				Font = Enum.Font.Bodoni,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Jack Frost",
				Color = Color3.fromRGB(80, 200, 255),
				StrokeColor = Color3.fromRGB(18, 57, 185),
				StrokeTransparency = 0.6,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Snowflake",
				Color = Color3.fromRGB(179, 225, 255),
				StrokeColor = Color3.fromRGB(102, 171, 255),
				StrokeTransparency = 0.6,
				Font = Enum.Font.DenkOne,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Candy Cane",
				Color = Color3.fromRGB(255, 94, 97),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0,
				Font = Enum.Font.LuckiestGuy,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Yeti",
				Color = Color3.fromRGB(183, 208, 255),
				StrokeColor = Color3.fromRGB(116, 124, 231),
				StrokeTransparency = 0.5,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Snow Angel",
				Color = Color3.fromRGB(198, 224, 255),
				StrokeColor = Color3.fromRGB(43, 134, 231),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = ""
			}
		}
	},
	["Valentines Pack"] = {
		Order = 25,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Cupid",
				Color = Color3.fromRGB(245, 120, 158),
				StrokeColor = Color3.fromRGB(93, 39, 64),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Sweetheart",
				Color = Color3.fromRGB(245, 172, 210),
				StrokeColor = Color3.fromRGB(93, 62, 90),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Love Bug",
				Color = Color3.fromRGB(245, 16, 127),
				StrokeColor = Color3.fromRGB(93, 0, 2),
				StrokeTransparency = 0,
				Font = Enum.Font.Bangers,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Toast of Love",
				Color = Color3.fromRGB(245, 103, 103),
				StrokeColor = Color3.fromRGB(89, 26, 26),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "King of Hearts",
				Other = "Queen of Hearts",
				Color = Color3.fromRGB(255, 90, 61),
				StrokeColor = Color3.fromRGB(206, 186, 107),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Rose",
				Color = Color3.fromRGB(255, 38, 42),
				StrokeColor = Color3.fromRGB(143, 39, 41),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Darling",
				Color = Color3.fromRGB(223, 143, 255),
				StrokeColor = Color3.fromRGB(118, 79, 143),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Twin Flame",
				Color = Color3.fromRGB(255, 85, 33),
				StrokeColor = Color3.fromRGB(143, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Garamond,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Mr. Valentine",
				Other = "Ms. Valentine",
				Color = Color3.fromRGB(242, 178, 255),
				StrokeColor = Color3.fromRGB(167, 93, 166),
				StrokeTransparency = 0,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Jewel",
				Color = Color3.fromRGB(113, 94, 255),
				StrokeColor = Color3.fromRGB(167, 58, 60),
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = false,
				Size = 2,
				Description = ""
			},
			{
				Display = "Dove",
				Color = Color3.fromRGB(249, 121, 123),
				StrokeColor = Color3.fromRGB(255, 231, 231),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 2,
				Description = ""
			},
			{
				Display = "HEARTBREAKER 💔",
				Color = Color3.fromRGB(255, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Cartoon,
				Bold = false,
				Size = 2,
				Description = "Breakin hearts",
				Animation = "Heartbreaker"
			}
		}
	},
	["Valentines Pack 2"] = {
		Order = 25,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Snuggs",
				Color = Color3.fromRGB(245, 120, 158),
				StrokeColor = Color3.fromRGB(93, 39, 64),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Stoneheart",
				Color = Color3.fromRGB(136, 136, 136),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187367066",
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "First Love",
				Color = Color3.fromRGB(245, 0, 4),
				StrokeColor = Color3.fromRGB(34, 0, 1),
				StrokeTransparency = 0,
				Font = Enum.Font.AmaticSC,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Old Flame",
				Color = Color3.fromRGB(255, 107, 33),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187377325",
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Lovethorn",
				Color = Color3.fromRGB(255, 38, 42),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Unstable 🥀",
				Color = Color3.fromRGB(223, 143, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Crush",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(197, 104, 185),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Overthinker",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0,
				Font = "rbxassetid://12187375194",
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "BoldWave"
			},
			{
				Display = "Ex.",
				Color = Color3.fromRGB(255, 0, 4),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 2,
				Description = "",
				Animation = "Heartbreaker"
			}
		}
	},
	["Saint Patrick's Day Pack"] = {
		Order = 26,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Shamrock",
				Color = Color3.fromRGB(0, 255, 17),
				StrokeColor = Color3.fromRGB(0, 116, 29),
				StrokeTransparency = 0.5,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Leprechaun",
				Color = Color3.fromRGB(153, 255, 0),
				StrokeColor = Color3.fromRGB(0, 182, 36),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Emerald",
				Color = Color3.fromRGB(97, 255, 123),
				StrokeColor = Color3.fromRGB(0, 116, 21),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Rainbow",
				Color = Color3.fromRGB(97, 255, 123),
				StrokeColor = Color3.fromRGB(0, 116, 21),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Size = 0,
				Description = "",
				Animation = "Rainbow"
			},
			{
				Display = "Pot'O Gold",
				Color = Color3.fromRGB(255, 234, 5),
				StrokeColor = Color3.fromRGB(198, 139, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Bangers,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Clover",
				Color = Color3.fromRGB(156, 255, 139),
				StrokeColor = Color3.fromRGB(0, 191, 32),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Celtic",
				Color = Color3.fromRGB(43, 213, 105),
				StrokeColor = Color3.fromRGB(128, 255, 121),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Piper",
				Color = Color3.fromRGB(162, 213, 20),
				StrokeColor = Color3.fromRGB(92, 158, 37),
				StrokeTransparency = 0.35,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 2,
				Description = ""
			}
		}
	},
	["Easter Egg Hunt '25"] = {
		Order = 28,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Egg Scavenger",
				Color = Color3.fromRGB(249, 221, 176),
				StrokeColor = Color3.fromRGB(186, 156, 7),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Egg Collector",
				Color = Color3.fromRGB(128, 249, 156),
				StrokeColor = Color3.fromRGB(50, 186, 35),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Egg Connoisseur",
				Color = Color3.fromRGB(249, 147, 239),
				StrokeColor = Color3.fromRGB(159, 50, 206),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Egg Enthusiast",
				Color = Color3.fromRGB(143, 212, 249),
				StrokeColor = Color3.fromRGB(58, 148, 186),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Description = ""
			}
		}
	},
	["Easter Pack"] = {
		Order = 27,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Bunny",
				Color = Color3.fromRGB(255, 228, 166),
				StrokeColor = Color3.fromRGB(172, 148, 53),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Animation = "Wave",
				Description = ""
			},
			{
				Display = "Spring",
				Color = Color3.fromRGB(129, 255, 90),
				StrokeColor = Color3.fromRGB(0, 172, 80),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 0,
				Description = "",
				Animation = "Shine"
			},
			{
				Display = "Chocolate Chaser",
				Color = Color3.fromRGB(198, 125, 0),
				StrokeColor = Color3.fromRGB(126, 63, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Hare",
				Color = Color3.fromRGB(249, 181, 183),
				StrokeColor = Color3.fromRGB(194, 125, 187),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Merriweather,
				Bold = false,
				Size = 0,
				Animation = "BoldWave",
				Description = ""
			},
			{
				Display = "Jellybean",
				Color = Color3.fromRGB(249, 94, 94),
				StrokeColor = Color3.fromRGB(175, 34, 34),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Highway,
				Bold = false,
				Size = 0,
				Animation = "BoldWave",
				Description = ""
			},
			{
				Display = "Florist",
				Color = Color3.fromRGB(249, 109, 249),
				StrokeColor = Color3.fromRGB(220, 20, 203),
				StrokeTransparency = 0.35,
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 0,
				Animation = "BoldWave",
				Description = ""
			},
			{
				Display = "Eggspert",
				Color = Color3.fromRGB(140, 249, 200),
				StrokeColor = Color3.fromRGB(66, 161, 176),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 0,
				Animation = "Shine",
				Description = ""
			},
			{
				Display = "Carrotman",
				Other = "Carrotwoman",
				Color = Color3.fromRGB(249, 151, 85),
				StrokeColor = Color3.fromRGB(159, 93, 46),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = true,
				Size = 0,
				Animation = "Wave",
				Description = ""
			},
			{
				Display = "Peep",
				Color = Color3.fromRGB(249, 244, 91),
				StrokeColor = Color3.fromRGB(166, 153, 16),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 0,
				Animation = "Shine",
				Description = ""
			}
		}
	},
	["Summer Titles"] = {
		Order = 30,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Dangerous",
				Color = Color3.fromRGB(180, 0, 3),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Creepster,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Chatty",
				Color = Color3.fromRGB(194, 255, 201),
				StrokeColor = Color3.fromRGB(59, 141, 116),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Stinky",
				Color = Color3.fromRGB(137, 255, 147),
				StrokeColor = Color3.fromRGB(35, 193, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Goddess",
				Color = Color3.fromRGB(255, 230, 230),
				StrokeColor = Color3.fromRGB(255, 194, 195),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Narcissist",
				Color = Color3.fromRGB(115, 169, 255),
				StrokeColor = Color3.fromRGB(99, 105, 143),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Angel",
				Color = Color3.fromRGB(148, 255, 246),
				StrokeColor = Color3.fromRGB(108, 181, 207),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PatrickHand,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Karen",
				Color = Color3.fromRGB(249, 255, 138),
				StrokeColor = Color3.fromRGB(188, 198, 84),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Treasure Hunter",
				Color = Color3.fromRGB(255, 226, 6),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.3,
				Font = Enum.Font.Merriweather,
				Bold = true,
				Animation = "Treasure",
				Size = 2,
				Description = ""
			}
		}
	},
	["Summer Titles 2"] = {
		Order = 35,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Lifeguard",
				Color = Color3.fromRGB(255, 0, 4),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.JosefinSans,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Boiled",
				Color = Color3.fromRGB(255, 158, 3),
				StrokeColor = Color3.fromRGB(141, 54, 3),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 0,
				Description = ""
			},
			{
				Display = "Puppetmaster",
				Color = Color3.fromRGB(186, 138, 42),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Sunsoaked",
				Color = Color3.fromRGB(255, 232, 179),
				StrokeColor = Color3.fromRGB(57, 57, 57),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Antique,
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Loudmouth",
				Color = Color3.fromRGB(98, 98, 98),
				StrokeColor = Color3.fromRGB(28, 143, 11),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = false,
				Size = 2,
				Description = ""
			},
			{
				Display = "Crybaby",
				Color = Color3.fromRGB(255, 144, 146),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PatrickHand,
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Hot Stuff",
				Color = Color3.fromRGB(255, 88, 46),
				StrokeColor = Color3.fromRGB(198, 198, 198),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 2,
				Description = ""
			},
			{
				Display = "Barb",
				Color = Color3.fromRGB(255, 128, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.45,
				Font = "rbxassetid://12187368317",
				Bold = true,
				Animation = "Wave",
				Size = 4,
				Description = ""
			},
			{
				Display = "Manipulator",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187375194",
				Bold = true,
				Animation = "BoldWave",
				Size = 2,
				Description = ""
			},
			{
				Display = "Honey",
				Color = Color3.fromRGB(229, 182, 14),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187377325",
				Bold = true,
				Animation = "Wave",
				Size = 2,
				Description = ""
			},
			{
				Display = "Skibidi Sigma",
				Color = Color3.fromRGB(255, 255, 249),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187370928",
				Bold = true,
				Animation = "BoldWave",
				Size = 2,
				Description = ""
			}
		}
	},
	["Summer Titles 3"] = {
		Order = 35,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Sanded",
				Color = Color3.fromRGB(255, 198, 26),
				StrokeColor = Color3.fromRGB(255, 228, 74),
				StrokeTransparency = 0.35,
				Font = Enum.Font.JosefinSans,
				Bold = false,
				Size = 0,
				Description = ""
			},
			{
				Display = "Splashy",
				Color = Color3.fromRGB(67, 123, 255),
				StrokeColor = Color3.fromRGB(160, 241, 248),
				StrokeTransparency = 0.45,
				Font = Enum.Font.Oswald,
				Bold = true,
				Animation = "Wave",
				Size = 4,
				Description = ""
			}
		}
	},
	["Weekly Spin"] = {
		Order = 30,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Drummer",
				Color = Color3.fromRGB(255, 176, 48),
				StrokeColor = Color3.fromRGB(156, 90, 32),
				StrokeTransparency = 0.35,
				Font = Enum.Font.DenkOne,
				Bold = true,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Singer",
				Color = Color3.fromRGB(69, 205, 255),
				StrokeColor = Color3.fromRGB(32, 81, 141),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Pianist",
				Color = Color3.fromRGB(241, 241, 241),
				StrokeColor = Color3.fromRGB(163, 163, 163),
				StrokeTransparency = 0.35,
				Font = Enum.Font.FredokaOne,
				Bold = false,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Dolphin",
				Color = Color3.fromRGB(149, 227, 255),
				StrokeColor = Color3.fromRGB(39, 105, 163),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = true,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Athlete",
				Color = Color3.fromRGB(255, 136, 51),
				StrokeColor = Color3.fromRGB(72, 43, 10),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PatrickHand,
				Bold = true,
				Size = 0,
				Animation = "Maverick",
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Fairy",
				Color = Color3.fromRGB(255, 170, 255),
				StrokeColor = Color3.fromRGB(255, 0, 255),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 0,
				Animation = "BoldWave",
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Robot",
				Color = Color3.fromRGB(33, 151, 255),
				StrokeColor = Color3.fromRGB(46, 69, 132),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Michroma,
				Bold = true,
				Size = 0,
				Animation = "GrimReaper",
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Poet",
				Color = Color3.fromRGB(255, 221, 87),
				StrokeColor = Color3.fromRGB(110, 111, 28),
				StrokeTransparency = 0.35,
				Font = Enum.Font.PermanentMarker,
				Bold = true,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Phoenix",
				Color = Color3.fromRGB(255, 150, 3),
				StrokeColor = Color3.fromRGB(131, 62, 13),
				StrokeTransparency = 0.35,
				Font = Enum.Font.TitilliumWeb,
				Bold = true,
				Size = 0,
				Animation = "BoldWave",
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Senator",
				Color = Color3.fromRGB(169, 255, 226),
				StrokeColor = Color3.fromRGB(72, 131, 72),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Sarpanch,
				Bold = true,
				Size = 0,
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Dreamer",
				Color = Color3.fromRGB(172, 124, 255),
				StrokeColor = Color3.fromRGB(66, 59, 86),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Animation = "BrickGod",
				Description = "Obtained from the Wheel."
			},
			{
				Display = "Engineer",
				Color = Color3.fromRGB(243, 255, 6),
				StrokeColor = Color3.fromRGB(134, 126, 17),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Size = 0,
				Animation = "Type",
				Description = "Obtained from the Wheel."
			}
		}
	},
	["Thanksgiving Banner"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Pilgrim's Omen",
				Color = Color3.fromRGB(192, 138, 43),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.1,
				Font = Enum.Font.Merriweather,
				Bold = false,
				Size = 2,
				Description = "A relic of the old frontier, carrying whispers of forgotten harvets.",
				Animation = "TypeWave"
			},
			{
				Display = "Cornfield King",
				Other = "Cornfield Queen",
				Color = Color3.fromRGB(240, 194, 48),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.1,
				Font = Enum.Font.LuckiestGuy,
				Bold = false,
				Size = 1,
				Description = "Crowned by the fields and favored by the autumn winds.",
				Animation = "BrickGod"
			}
		}
	},
	["Valentines Banner Pack"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Cuddle King",
				Color = Color3.fromRGB(255, 105, 180),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.1,
				Font = "rbxassetid://8764312106",
				Bold = true,
				Size = 3,
				Description = "Whoever owns this title is filled with warmth, comfort, friendliness, and affection.",
				Animation = "Shine",
				Other = "Cuddle Queen"
			},
			{
				Display = "Vow Keeper",
				Color = Color3.fromRGB(200, 16, 46),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.7,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 3,
				Description = "Those with this title have trust, honor, protection, and responsibility",
				Animation = "Shine"
			}
		}
	},
	["New Years Pack"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Time Keeper",
				Color = Color3.fromRGB(255, 215, 140),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.1,
				Font = "rbxassetid://12187370928",
				Bold = true,
				Size = 3,
				Description = "A title for those who set their goals and chase them without looking back.",
				Animation = "BoldWave"
			},
			{
				Display = "Reinvented",
				Color = Color3.fromRGB(90, 220, 210),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.7,
				Font = Enum.Font.FredokaOne,
				Bold = false,
				Size = 3,
				Description = "Proof that change is possible: rebuilt, refocused, and ready for what's next.",
				Animation = "BoldWave"
			}
		}
	},
	["Easter Banner"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Marshmallow",
				Color = Color3.fromRGB(255, 245, 255),
				StrokeColor = Color3.fromRGB(210, 180, 220),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Nunito,
				Bold = false,
				Size = 0,
				Description = "Squishy, sweet, and somehow survives everything. A little too soft for this world.",
				Animation = "Cute"
			},
			{
				Display = "Hollow",
				Color = Color3.fromRGB(80, 50, 30),
				StrokeColor = Color3.fromRGB(210, 140, 60),
				StrokeTransparency = 0.3,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 2,
				Description = "Chocolate on the outside. Nothing on the inside. But you already knew that.",
				Animation = "BoldWave"
			}
		}
	},
	["Superhero Pack"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Superhero",
				Color = Color3.fromRGB(161, 33, 40),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.1,
				Font = "rbxassetid://12187370928",
				Bold = true,
				Size = 3,
				Description = "Stand tall and shine bright — a title for those who bring justice to every battle.",
				Animation = "BoldWave"
			},
			{
				Display = "Villain",
				Color = Color3.fromRGB(0, 181, 21),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187375194",
				Bold = true,
				Size = 3,
				Description = "Embrace chaos and carve your name into infamy with this bold and wicked title.",
				Animation = "GrimReaper"
			},
			{
				Display = "Vigilante",
				Color = Color3.fromRGB(48, 55, 148),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.7,
				Font = Enum.Font.FredokaOne,
				Bold = false,
				Size = 3,
				Description = "Operate from the shadows, strike with purpose — for those who walk the gray line.",
				Animation = "BoldWave"
			}
		}
	},
	["Jolly Shop Pack"] = {
		Order = 31,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Cookie King",
				Color = Color3.fromRGB(255, 197, 82),
				StrokeColor = Color3.fromRGB(44, 29, 22),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 2,
				Description = "Rules the realm of sweets with unmatched delicious mastery.",
				Animation = "BoldWave"
			},
			{
				Display = "Sugar Dust",
				Color = Color3.fromRGB(255, 216, 247),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = Enum.Font.PermanentMarker,
				Bold = false,
				Size = 3,
				Description = "This title leaves a trail of sugary magic wherever it goes.."
			},
			{
				Display = "Jolly Baker",
				Color = Color3.fromRGB(222, 219, 187),
				StrokeColor = Color3.fromRGB(38, 38, 0),
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 4,
				Description = "A cheerful creator of holiday treats, spreading warmth with every batch.."
			}
		}
	},
	["Mean Green Pack"] = {
		Order = 32,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Holiday Menace",
				Color = Color3.fromRGB(139, 170, 2),
				StrokeColor = Color3.fromRGB(17, 30, 2),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 2,
				Description = "A holiday menace, ruining the holiday for everyone.",
				Animation = "TypeWave"
			},
			{
				Display = "Gift Snatcher",
				Color = Color3.fromRGB(85, 170, 0),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 3,
				Description = "Seriously? Snatching gifts is lame.",
				Animation = "BoldWave"
			},
			{
				Display = "Grouch",
				Color = Color3.fromRGB(59, 85, 11),
				StrokeColor = Color3.fromRGB(38, 38, 0),
				Font = Enum.Font.DenkOne,
				Bold = false,
				Size = 4,
				Description = "Don't be so grumpy."
			}
		}
	},
	["Hallows Pack"] = {
		Order = 32,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Eternally Cursed",
				Color = Color3.fromRGB(117, 102, 67),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 2,
				Description = "A fate sealed in shadows, never to be broken.",
				Animation = "TypeWave"
			},
			{
				Display = "Dreadful King",
				Other = "Dreadful Queen",
				Color = Color3.fromRGB(160, 52, 30),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				StrokeTransparency = 0.5,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 4,
				Description = "A sovereign crowned in terror and fear.",
				Animation = "BrickGod"
			},
			{
				Display = "Night Hallow",
				Color = Color3.fromRGB(66, 0, 131),
				StrokeColor = Color3.fromRGB(38, 38, 57),
				Font = Enum.Font.Antique,
				Bold = false,
				Size = 4,
				Description = "When the moon rises, the dark awakens."
			}
		}
	},
	["School Pack"] = {
		Order = 32,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Nerd",
				Color = Color3.fromRGB(0, 68, 0),
				StrokeColor = Color3.fromRGB(0, 68, 0),
				StrokeTransparency = 0.8,
				Font = Enum.Font.FredokaOne,
				Bold = false,
				Size = 3,
				Description = "Point and laugh everybody!",
				Animation = "BoldWave"
			},
			{
				Display = "Bully",
				Color = Color3.fromRGB(170, 0, 0),
				StrokeColor = Color3.fromRGB(170, 0, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Oswald,
				Bold = true,
				Size = 3,
				Description = "We don't like bullies.",
				Animation = "GrimReaper"
			}
		}
	},
	["Back to School"] = {
		Order = 40,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Transfer",
				Color = Color3.fromRGB(20, 160, 199),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187363887",
				Bold = true,
				Italic = true,
				Size = 5,
				Description = ""
			},
			{
				Display = "Newcomer",
				Color = Color3.fromRGB(86, 26, 49),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187375716",
				Bold = true,
				Italic = true,
				Size = 8,
				Description = ""
			},
			{
				Display = "Student",
				Color = Color3.fromRGB(0, 127, 162),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://8764312106",
				Bold = true,
				Size = 9,
				Animation = "SodaPop",
				Description = ""
			},
			{
				Display = "Dropout",
				Color = Color3.fromRGB(155, 71, 5),
				StrokeColor = Color3.fromRGB(2, 42, 225),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187376910",
				Bold = true,
				Size = 9,
				Animation = "Cornucopian",
				Description = ""
			},
			{
				Display = "Valedictorian",
				Color = Color3.fromRGB(5, 197, 51),
				StrokeColor = Color3.fromRGB(225, 87, 2),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187360881",
				Bold = false,
				Size = 5,
				Animation = "Riot",
				Description = "",
				DontWrapInBrackets = true
			},
			{
				Display = "Teacher",
				Color = Color3.fromRGB(5, 197, 134),
				StrokeColor = Color3.fromRGB(246, 12, 127),
				StrokeTransparency = 1,
				Font = "rbxassetid://8764312106",
				Bold = true,
				Size = 9,
				Animation = "Cute",
				Description = ""
			},
			{
				Display = "Principal",
				Color = Color3.fromRGB(193, 147, 243),
				StrokeColor = Color3.fromRGB(246, 12, 127),
				StrokeTransparency = 1,
				Font = "rbxassetid://8764312106",
				Bold = false,
				Italic = true,
				Size = 9,
				Animation = "Shine",
				Description = ""
			},
			{
				Display = "Vice Principal",
				Color = Color3.fromRGB(229, 243, 147),
				StrokeColor = Color3.fromRGB(246, 12, 127),
				StrokeTransparency = 1,
				Font = "rbxassetid://8764312106",
				Bold = false,
				Italic = true,
				Size = 9,
				Animation = "Shine",
				Description = ""
			},
			{
				Display = "Counselor",
				Color = Color3.fromRGB(229, 175, 217),
				StrokeColor = Color3.fromRGB(172, 16, 75),
				StrokeTransparency = 1,
				Font = Enum.Font.Code,
				Bold = false,
				Italic = true,
				Size = 9,
				Animation = "Dollface",
				Description = "",
				DontWrapInBrackets = true
			},
			{
				Display = "Therapist",
				Color = Color3.fromRGB(255, 249, 166),
				StrokeColor = Color3.fromRGB(172, 16, 16),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187367901",
				Bold = false,
				Italic = true,
				Size = 6,
				Animation = "Dollface",
				Description = ""
			},
			{
				Display = "Librarian",
				Color = Color3.fromRGB(14, 70, 0),
				StrokeColor = Color3.fromRGB(172, 16, 16),
				StrokeTransparency = 1,
				Font = Enum.Font.Arcade,
				Bold = false,
				Italic = true,
				Size = 7,
				Animation = "TypeWave",
				Description = "",
				DontWrapInBrackets = true
			},
			{
				Display = "Coach",
				Color = Color3.fromRGB(42, 0, 100),
				StrokeColor = Color3.fromRGB(255, 159, 159),
				StrokeTransparency = 0,
				Font = "rbxassetid://11702779517",
				Bold = true,
				Size = 7,
				Animation = "BoldWave",
				Description = ""
			},
			{
				Display = "Janitor",
				Color = Color3.fromRGB(2, 49, 21),
				StrokeColor = Color3.fromRGB(3, 97, 66),
				StrokeTransparency = 0,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Italic = true,
				Size = 8,
				Animation = "Grub",
				Description = ""
			},
			{
				Display = "Nurse",
				Color = Color3.fromRGB(135, 203, 255),
				StrokeColor = Color3.fromRGB(3, 77, 97),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187367901",
				Bold = false,
				Italic = true,
				Size = 10,
				Animation = "Maverick",
				Description = ""
			},
			{
				Display = "Substitute",
				Color = Color3.fromRGB(241, 153, 230),
				StrokeColor = Color3.fromRGB(3, 77, 97),
				StrokeTransparency = 1,
				Font = "rbxassetid://8764312106",
				Bold = false,
				Italic = true,
				Size = 10,
				Animation = "BoldWave",
				Description = ""
			},
			{
				Display = "Nerd",
				Color = Color3.fromRGB(153, 101, 22),
				StrokeColor = Color3.fromRGB(3, 77, 97),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187375716",
				Bold = false,
				Italic = true,
				Size = 10,
				Animation = "Thing",
				Description = ""
			},
			{
				Display = "Class Clown",
				Color = Color3.fromRGB(22, 153, 89),
				StrokeColor = Color3.fromRGB(3, 77, 97),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187368843",
				Bold = true,
				Size = 8,
				Animation = "Moderator",
				Description = ""
			},
			{
				Display = "Loner",
				Color = Color3.fromRGB(125, 23, 239),
				StrokeColor = Color3.fromRGB(54, 182, 218),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187376910",
				Bold = false,
				Italic = true,
				Size = 4,
				Animation = "Blaugrana",
				Description = ""
			},
			{
				Display = "Bully",
				Color = Color3.fromRGB(170, 0, 0),
				StrokeColor = Color3.fromRGB(170, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://8836875837",
				Bold = false,
				Size = 5,
				Description = "We don't like bullies.",
				Animation = "Tornado",
				DontWrapInBrackets = true,
				Gradient = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 42, 46)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				}),
				GradientRotation = 65
			},
			{
				Display = "Teacher's Pet",
				Color = Color3.fromRGB(191, 223, 6),
				StrokeColor = Color3.fromRGB(203, 218, 54),
				StrokeTransparency = 1,
				Font = "rbxassetid://12187364842",
				Bold = true,
				Italic = true,
				Size = 4,
				Animation = "EventsTeam",
				Description = "",
				DontWrapInBrackets = true
			}
		}
	},
	["Alien Pack"] = {
		Order = 32,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Alien",
				Color = Color3.fromRGB(0, 20, 0),
				StrokeColor = Color3.fromRGB(0, 20, 0),
				StrokeTransparency = 0.8,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "Visitor from the void — a title that marks you as something beautifully alien.",
				Animation = "BoldWave"
			},
			{
				Display = "Beep-Boop",
				Color = Color3.fromRGB(0, 185, 68),
				StrokeColor = Color3.fromRGB(183, 86, 190),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = true,
				Size = 3,
				Description = "That's not going to work on me anymore!",
				Animation = "GrimReaper"
			}
		}
	},
	["Toy Pack"] = {
		Order = 33,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Brickmaster",
				Color = Color3.fromRGB(255, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.15,
				Font = "rbxassetid://12187371840",
				Bold = true,
				Size = 3,
				Description = "Architect of imagination, builder of empires — wear this crown of creativity with pride.",
				Animation = "BoldWave"
			},
			{
				Display = "Chomper",
				Color = Color3.fromRGB(85, 225, 127),
				StrokeColor = Color3.fromRGB(85, 225, 127),
				StrokeTransparency = 0,
				Font = "rbxassetid://12187375716",
				Bold = false,
				Size = 3,
				Description = "With teeth like gears and a bite of steel — this title belongs to the relentless.",
				Animation = "GrimReaper"
			}
		}
	},
	["Steampunk Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Clockwork",
				Color = Color3.fromRGB(96, 85, 66),
				StrokeColor = Color3.fromRGB(33, 29, 23),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 3,
				Description = "Time is your weapon, precision your creed.",
				Animation = "BoldWave"
			},
			{
				Display = "Brasskeeper",
				Color = Color3.fromRGB(181, 166, 66),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = Enum.Font.Sarpanch,
				Bold = false,
				Size = 3,
				Description = "The gears turn, and you guard their secret.",
				Animation = "Type"
			}
		}
	},
	["Kitty Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Flufflord",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(251, 133, 255),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 3,
				Description = "Lord of the fluff.",
				Animation = "BoldWave"
			},
			{
				Display = "Pawmaster",
				Color = Color3.fromRGB(109, 58, 118),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = Enum.Font.Sarpanch,
				Bold = false,
				Size = 3,
				Description = "Master of scratch posts.",
				Animation = "Wave"
			}
		}
	},
	["Emo Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Bleeder",
				Color = Color3.fromRGB(255, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187375194",
				Bold = false,
				Size = 3,
				Description = "Lord of the fluff.",
				Animation = "BoldWave"
			},
			{
				Display = "Blood Sucker",
				Color = Color3.fromRGB(179, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "Master of scratch posts.",
				Animation = "BoldWave"
			}
		}
	},
	["Pharaoh Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Pharaoh",
				Color = Color3.fromRGB(239, 211, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187375194",
				Bold = false,
				Size = 3,
				Description = "Rule as the eternal sovereign of the sands",
				Animation = "BoldWave"
			},
			{
				Display = "Curse of Ra",
				Color = Color3.fromRGB(255, 0, 0),
				StrokeColor = Color3.fromRGB(74, 74, 74),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "Embody the wrath of the sun god himself.",
				Animation = "BoldWave"
			},
			{
				Display = "Cleopatra",
				Color = Color3.fromRGB(172, 152, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 3,
				Description = "Grace and power befitting the Queen.",
				Animation = "BoldWave"
			}
		}
	},
	["Guts & Bones Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Berserk",
				Color = Color3.fromRGB(141, 6, 8),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "Go berserk",
				Animation = "BoldWave"
			},
			{
				Display = "Bones",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(74, 74, 74),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 3,
				Description = "Got a bone to pick?.",
				Animation = "BoldWave"
			}
		}
	},
	["Heavenly Pack"] = {
		Order = 34,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Seraphim",
				Color = Color3.fromRGB(217, 194, 22),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "Be not afraid",
				Animation = "Shine"
			},
			{
				Display = "Fallen Angel",
				Color = Color3.fromRGB(255, 255, 255),
				StrokeColor = Color3.fromRGB(194, 188, 11),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187372382",
				Bold = false,
				Size = 3,
				Description = "One that has fallen from Grace.",
				Animation = "Forsaken"
			}
		}
	},
	["Anime Pack"] = {
		Order = 35,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Pirate King",
				Color = Color3.fromRGB(226, 226, 226),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187367066",
				Bold = false,
				Size = 3,
				Description = "I'm going to be king of the Pirates.",
				Animation = "Shine"
			},
			{
				Display = "Saiyan",
				Color = Color3.fromRGB(255, 137, 2),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187370928",
				Bold = false,
				Size = 3,
				Description = "I only want to fight the Strongest.",
				Animation = "BoldWave"
			}
		}
	},
	["Ramadan Pack"] = {
		Order = 36,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Devoted",
				Color = Color3.fromRGB(110, 135, 255),
				StrokeColor = Color3.fromRGB(40, 50, 120),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Antique,
				Bold = false,
				Description = "A soul finding peace in the silence of prayer.",
				Animation = "Wave"
			},
			{
				Display = "Radiant",
				Color = Color3.fromRGB(255, 255, 180),
				StrokeColor = Color3.fromRGB(255, 215, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Fondamento,
				Bold = true,
				Description = "A beacon of light in the darkest of nights.",
				Animation = "Shine"
			}
		}
	},
	["Autumn Pack"] = {
		Order = 36,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Cinnamon",
				Color = Color3.fromRGB(186, 68, 14),
				StrokeColor = Color3.fromRGB(86, 50, 4),
				StrokeTransparency = 0.2,
				Font = Enum.Font.SourceSans,
				Bold = false,
				Size = 3,
				Description = "Nice and spicy.",
				Animation = "Hearthkeeper"
			},
			{
				Display = "Harvest",
				Color = Color3.fromRGB(136, 73, 1),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = false,
				Size = 3,
				Description = "The harvest will be bountiful.",
				Animation = "Shine"
			}
		}
	},
	["Hacker Pack"] = {
		Order = 37,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Mr Robot",
				Color = Color3.fromRGB(172, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = Enum.Font.SourceSans,
				Bold = false,
				Size = 3,
				Description = "Just like in the TV Show.",
				Animation = "Shine"
			},
			{
				Display = "Glitched",
				Color = Color3.fromRGB(15, 136, 9),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = true,
				Size = 3,
				Description = "Escape the matrix.",
				Animation = "BoldWave"
			}
		}
	},
	["Brainrot Pack"] = {
		Order = 38,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Looksmaxxer",
				Color = Color3.fromRGB(133, 163, 177),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187370928",
				Bold = false,
				Size = 3,
				Description = "Get mogged dud.",
				Animation = "BrickGod"
			},
			{
				Display = "Cappuccino",
				Color = Color3.fromRGB(167, 124, 38),
				StrokeColor = Color3.fromRGB(54, 54, 54),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = true,
				Size = 3,
				Description = "ASSASSINO.",
				Animation = "Shine"
			}
		}
	},
	["Hello Pack"] = {
		Order = 38,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Princess Kitty",
				Color = Color3.fromRGB(167, 84, 166),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.2,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 3,
				Description = "Princess of all the kitty's.",
				Animation = "Shine"
			},
			{
				Display = "Meowster",
				Color = Color3.fromRGB(46, 59, 167),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187375194",
				Bold = true,
				Size = 3,
				Description = "MEOW.",
				Animation = "BoldWave"
			}
		}
	},
	["Apartments Exclusive"] = {
		Order = 29,
		Items = {
			{
				Display = "Gym Rat",
				Color = Color3.fromRGB(107, 136, 156),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Cartoon,
				Bold = false,
				Description = "100 Total Sets"
			},
			{
				Display = "Gym Goer",
				Color = Color3.fromRGB(171, 129, 60),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Bodoni,
				Bold = false,
				Description = "250 Total Sets"
			},
			{
				Display = "Gym Beast",
				Color = Color3.fromRGB(203, 97, 10),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Antique,
				Bold = true,
				Description = "500 Total Sets"
			},
			{
				Display = "Gym Demon",
				Color = Color3.fromRGB(165, 0, 0),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Kalam,
				Bold = true,
				Animation = "BoldWave",
				Description = "1000 Total Sets"
			},
			{
				Display = "Gym Reaper",
				Color = Color3.fromRGB(0, 0, 0),
				StrokeColor = Color3.fromRGB(165, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Kalam,
				Bold = true,
				Animation = "BoldWave",
				Description = "2000 Total Sets - Mega ripped!"
			},
			{
				Display = "Curler",
				Color = Color3.fromRGB(255, 198, 128),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Size = 2,
				Font = Enum.Font.TitilliumWeb,
				Bold = false,
				Description = "50 Sets"
			},
			{
				Display = "Flexer",
				Color = Color3.fromRGB(255, 135, 65),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Size = 2,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Description = "200 Sets"
			},
			{
				Display = "Arm Day Champ",
				Color = Color3.fromRGB(255, 44, 48),
				StrokeColor = Color3.fromRGB(65, 18, 19),
				StrokeTransparency = 0.65,
				Font = Enum.Font.FredokaOne,
				Bold = true,
				Description = "500 Sets"
			},
			{
				Display = "Lightweight",
				Color = Color3.fromRGB(84, 172, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Kalam,
				Size = 2,
				Bold = false,
				Description = "50 Sets"
			},
			{
				Display = "Built",
				Color = Color3.fromRGB(255, 96, 43),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Oswald,
				Bold = true,
				Description = "200 Sets"
			},
			{
				Display = "Heavyweight",
				Color = Color3.fromRGB(52, 0, 0),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.65,
				Font = Enum.Font.SpecialElite,
				Bold = true,
				Description = "500 Sets"
			},
			{
				Display = "Lifter",
				Color = Color3.fromRGB(143, 255, 180),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Fantasy,
				Bold = false,
				Description = "50 Sets"
			},
			{
				Display = "Great Form",
				Color = Color3.fromRGB(255, 255, 15),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Highway,
				Bold = true,
				Description = "200 Sets"
			},
			{
				Display = "Deadlift Champ",
				Color = Color3.fromRGB(127, 3, 26),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.65,
				Font = Enum.Font.Code,
				Bold = true,
				Description = "500 Sets"
			}
		}
	},
	["Easter Pack 2"] = {
		Order = 39,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Cottontail",
				Color = Color3.fromRGB(255, 220, 235),
				StrokeColor = Color3.fromRGB(200, 130, 160),
				StrokeTransparency = 0.4,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 4,
				Description = "Soft, fluffy, and hopping away the second things get awkward.",
				Animation = "Cute"
			},
			{
				Display = "Peeps",
				Color = Color3.fromRGB(255, 200, 80),
				StrokeColor = Color3.fromRGB(210, 110, 0),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Bangers,
				Bold = false,
				Size = 0,
				Description = "Stale after three days but somehow still here. Iconic.",
				Animation = "Wave"
			},
			{
				Display = "Egg Hunter",
				Color = Color3.fromRGB(140, 220, 130),
				StrokeColor = Color3.fromRGB(40, 110, 40),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Kalam,
				Bold = true,
				Size = 0,
				Description = "Gets up at 6 AM just to beat the little kids to the eggs. No shame.",
				Animation = "BoldWave"
			},
			{
				Display = "Spring Chick",
				Color = Color3.fromRGB(255, 240, 90),
				StrokeColor = Color3.fromRGB(190, 150, 0),
				StrokeTransparency = 0.45,
				Font = Enum.Font.FredokaOne,
				Bold = false,
				Size = 0,
				Description = "Just hatched. Brand new. Full of life and terrible decisions.",
				Animation = "Shine"
			},
			{
				Display = "Pastel Dream",
				Color = Color3.fromRGB(195, 170, 255),
				StrokeColor = Color3.fromRGB(120, 90, 200),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Fondamento,
				Bold = false,
				Size = 0,
				Description = "Everything is soft. Everything is nice. Do not bring drama in here.",
				Animation = "Shine"
			},
			{
				Display = "Basket Case",
				Color = Color3.fromRGB(255, 170, 100),
				StrokeColor = Color3.fromRGB(140, 70, 10),
				StrokeTransparency = 0.5,
				Font = Enum.Font.PatrickHand,
				Bold = false,
				Size = 5,
				Description = "The basket is overflowing. Your life is not.",
				Animation = "Wave"
			},
			{
				Display = "Scrambled",
				Color = Color3.fromRGB(255, 220, 120),
				StrokeColor = Color3.fromRGB(200, 100, 0),
				StrokeTransparency = 0.35,
				Font = Enum.Font.Cartoon,
				Bold = true,
				Size = 0,
				Description = "Dropped the egg. It's fine. Everything is fine.",
				Animation = "BoldWave"
			},
			{
				Display = "Daffodil",
				Color = Color3.fromRGB(255, 235, 60),
				StrokeColor = Color3.fromRGB(200, 160, 0),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Merriweather,
				Bold = false,
				Size = 0,
				Description = "First one out of the ground every spring. Pioneer. Legend. Flower.",
				Animation = "Shine"
			},
			{
				Display = "Hopscotch",
				Color = Color3.fromRGB(140, 230, 200),
				StrokeColor = Color3.fromRGB(30, 130, 110),
				StrokeTransparency = 0.5,
				Font = Enum.Font.LuckiestGuy,
				Bold = false,
				Size = 0,
				Description = "Hopping through life one square at a time. Don't step on the lines.",
				Animation = "Wave"
			},
			{
				Display = "Golden Egg",
				Color = Color3.fromRGB(171, 139, 34),
				StrokeColor = Color3.fromRGB(160, 100, 0),
				StrokeTransparency = 0.25,
				Font = Enum.Font.GrenzeGotisch,
				Bold = true,
				Size = 4,
				Description = "One in a million. You found it. Everyone else is still looking.",
				Animation = "Glow"
			}
		}
	},
	["Summer Pack"] = {
		Order = 40,
		HideIfNotOwned = true,
		Items = {
			{
				Display = "Diver",
				Color = Color3.fromRGB(0, 105, 148),
				StrokeColor = Color3.fromRGB(0, 40, 60),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Code,
				Bold = false,
				Description = "Down where the fish are."
			},
			{
				Display = "Swimmer",
				Color = Color3.fromRGB(80, 200, 255),
				StrokeColor = Color3.fromRGB(0, 60, 100),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Arial,
				Bold = false,
				Description = "Front crawl, back crawl, doesn't matter."
			},
			{
				Display = "Islander",
				Color = Color3.fromRGB(60, 200, 130),
				StrokeColor = Color3.fromRGB(20, 90, 60),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Cartoon,
				Bold = false,
				Description = "Sand between the toes, salt in the hair."
			},
			{
				Display = "Sailer",
				Color = Color3.fromRGB(20, 60, 140),
				StrokeColor = Color3.fromRGB(255, 255, 255),
				StrokeTransparency = 0.5,
				Font = Enum.Font.Highway,
				Bold = true,
				Description = "Wind in the sails, nowhere to be."
			},
			{
				Display = "Skipper",
				Color = Color3.fromRGB(240, 240, 245),
				StrokeColor = Color3.fromRGB(20, 60, 140),
				StrokeTransparency = 0.4,
				Font = Enum.Font.Oswald,
				Bold = true,
				Description = "Runs the ship. Or at least the boat."
			},
			{
				Display = "Sunseeker",
				Color = Color3.fromRGB(255, 176, 59),
				StrokeColor = Color3.fromRGB(150, 80, 0),
				StrokeTransparency = 0.4,
				Font = Enum.Font.FredokaOne,
				Bold = true,
				Description = "Chasing golden hour all season long."
			},
			{
				Display = "Wave Rider",
				Color = Color3.fromRGB(0, 190, 200),
				StrokeColor = Color3.fromRGB(0, 60, 70),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187367901",
				Bold = true,
				Size = 4,
				Description = "Doesn't fight the wave. Becomes it.",
				Animation = "Wave"
			},
			{
				Display = "Baddie",
				Color = Color3.fromRGB(255, 20, 120),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0.35,
				Font = "rbxassetid://12187375716",
				Bold = true,
				Size = 3,
				Description = "Poolside, poised, and posting.",
				Animation = "Shine"
			},
			{
				Display = "Diva",
				Color = Color3.fromRGB(255, 215, 0),
				StrokeColor = Color3.fromRGB(120, 90, 0),
				StrokeTransparency = 0.3,
				Font = "rbxassetid://12187367901",
				Bold = true,
				Size = 3,
				Description = "Center of attention, even in the shallow end.",
				Animation = "Glow"
			},
			{
				Display = "Doll",
				Color = Color3.fromRGB(255, 170, 210),
				StrokeColor = Color3.fromRGB(160, 60, 110),
				StrokeTransparency = 0.35,
				Font = Enum.Font.IndieFlower,
				Bold = false,
				Size = 4,
				Description = "Looks like plastic, acts like trouble.",
				Animation = "Cute"
			},
			{
				Display = "Model",
				Color = Color3.fromRGB(148, 169, 255),
				StrokeColor = Color3.fromRGB(0, 0, 0),
				StrokeTransparency = 0,
				Font = "rbxassetid://12187370928",
				Italic = false,
				Bold = false,
				Size = 4,
				Description = "Every angle is the good angle.",
				Animation = "Glow"
			},
			{
				Display = "Boss",
				Color = Color3.fromRGB(255, 85, 0),
				StrokeColor = Color3.fromRGB(130, 43, 0),
				StrokeTransparency = 0.25,
				Font = "rbxassetid://12187368843",
				Bold = true,
				Size = 4,
				Description = "Owns the beach whether it likes it or not.",
				Animation = "Glow"
			},
			{
				Display = "Delulu",
				Color = Color3.fromRGB(200, 130, 255),
				StrokeColor = Color3.fromRGB(90, 30, 140),
				StrokeTransparency = 0.3,
				Font = Enum.Font.FredokaOne,
				Bold = true,
				Size = 4,
				Description = "It's not delusion, it's just belief with no evidence.",
				Animation = "RainbowWave"
			},
			{
				Display = "Menace",
				Color = Color3.fromRGB(20, 0, 0),
				StrokeColor = Color3.fromRGB(200, 0, 0),
				StrokeTransparency = 0.2,
				Font = "rbxassetid://12187377325",
				Bold = true,
				Size = 5,
				Description = "To society.",
				Animation = "BoldWave"
			}
		}
	}
}
local Titles = require(game.ReplicatedStorage.Assets.Data.Crates.Titles)
require(game.ReplicatedStorage.Modules.Server)

local function getCaseScaledPrice(rarity: string, items, price: number)
	if (not items[rarity] and 0 or #items[rarity] or 0) == 0 then
		return 0
	end

	if table.find({
		"Unique",
		"???",
		"Collectible",
		"Royalty"
	}, rarity) then
		return 1e999
	end

	local v4 = ({
		Common = 52,
		Uncommon = 32,
		Rare = 9.6,
		Royalty = 5,
		Unique = 1,
		["???"] = 0.4,
		Collectible = 0
	})[rarity]

	if not v4 or v4 == 0 then
		return 1e999
	end

	local v5 = v4 / 100
	local v6 = ({
		Common = 2,
		Uncommon = 3,
		Rare = 4,
		Royalty = 5
	})[rarity] or 1
	return math.ceil(price * (1 / v5) * v6 / 100) * 100
end

local function getCaseFromName(display: string)
	for k, title in Titles do
		for _, list in title.Items do
			if table.find(list, display) then
				return k, title
			end
		end
	end

	return nil, nil
end

local v2 = {}
local v3 = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Royalty = 4,
	Unique = 5,
	["???"] = 6,
	Collectible = 7,
	None = 8
}
local Titles2 = {}

for _, title in Titles do
	for k, item in title.Items do
		for _, v4 in item do
			v2[v4] = k
		end
	end
end

for k, v4 in v do
	local v5 = v4.Order * 200

	if v2[select(2, next(v4.Items)).Display] then
		table.sort(v4.Items, function(a, b)
			local v6 = v2[a.Display] or "None"
			local v7 = v2[b.Display] or "None"

			if v6 == v7 then
				return a.Display < b.Display
			end

			return v3[v6] < v3[v7]
		end)
	end

	for k2, item in v4.Items do
		item.HideIfNotOwned = v4.HideIfNotOwned or item.HideIfNotOwned or false
		item.Category = k
		item.Order = v5 + k2
		item.Rarity = v2[item.Display]
		local caseFromName, v6 = getCaseFromName(item.Display)

		if caseFromName and v6 then
			if v6.Offsale then
				item.Price = 1e999
			else
				item.Price = getCaseScaledPrice(item.Rarity, v6.Items, v6.Price)
			end
		end

		Titles2[item.Display] = item
	end
end

if RunService:IsClient() then
	pcall(function()
		local Animations = require(Players.LocalPlayer.PlayerScripts.Scripts.UI.DisplayNameHandler.DisplayNameAnimation.Animations)

		for _, v4 in next, v, nil do
			for _, item in next, v4.Items, nil do
				if not item.Animation or Animations[item.Animation] then
					continue
				end

				warn((`[Title] {item.Display} has an invalid animation: {item.Animation}`))
			end
		end
	end)
end

return Titles2