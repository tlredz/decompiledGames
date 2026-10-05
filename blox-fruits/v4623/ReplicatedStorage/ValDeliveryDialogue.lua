local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local Anims = require(game.ReplicatedStorage.Util.Anims)
local valentinesModels = nil

local function getValentinesModels()
	if not valentinesModels then
		valentinesModels = FX:WaitForChild("ValentinesModels")
	end

	return valentinesModels
end

local responses = {
	SuizeiParlus = {
		NPCs = {
			Sender = "Suizei",
			Receiver = "Parlus (Cape NPC)"
		},
		Text = {
			{
				"Suizei",
				"To my long-forgotten half... I wonder how the Cape Business is going. Hope you're doing well.",
				1
			},
			{
				"Parlus",
				"LOLLL who is this bro. I got church in a lil but APPRECIATE IT... SUIZEI? Weird name bro but alr",
				2
			}
		}
	},
	robotarowe = {
		NPCs = {
			Sender = "rip_indra",
			Receiver = "arowe"
		},
		Text = {
			{
				"rip_indra",
				"My son, how are you faring in this world? I will come visit soon; however, my operations are starting to deviate from what I had originally planned.",
				1
			},
			{ "rip_indra", "Worry not, we’ll be together again soon.", 1 },
			{
				"arowe",
				":o my pops wrote me a letter! aw well i hope to see him soon :) thank you man. Time to League",
				2
			}
		}
	},
	suizeifelku = {
		NPCs = {
			Sender = "Suizei",
			Receiver = "Felku"
		},
		Text = {
			{
				"Suizei",
				"hey man i need that tiger fruit read- ahh jk just joshing you LOL. happy valentines day G.",
				1
			},
			{
				"Felku",
				"Tiger..? Silence Suizei. I am onto bigger and better things. I accept this letter.. accept it as fuel for the fireplace in my BAMP lair.",
				2
			}
		}
	},
	felkushafi = {
		NPCs = {
			Sender = "Felku",
			Receiver = "Shafi"
		},
		Text = {
			{
				"Felku",
				"Silly Shafi.. I am now the King of Fruits. Your reign has come to an end. The BAMP army will be attacking very soon.",
				1
			},
			{ "Felku", "I write this to you not as a Valentine's letter.. but as a threat.", 1 },
			{
				"Shafi",
				"xD hey thanks to Felku mane. maybe he delusional haha. Appreciate it. My next fruit is cooking better than anything he’s cooked xD.",
				2
			}
		}
	},
	doghouseindra = {
		NPCs = {
			Sender = "Doghouse",
			Receiver = "rip_indra"
		},
		Text = {
			{ "Frank", "OMGGGGFFF MASTAAA ITS VALENTINES ;o YOU KNOW What this means? I HAV A GIFT FOR U.", 1 },
			{ "Frank", "PLEASE RESPOND WITH new powahs so i can DESTROY THE CHEATERS AND MY ENEMEYS", 1 },
			{ "rip_indra", "Hmph. Doghouse Frank, haven’t heard from him in a while.", 2 },
			{
				"Frank",
				"You’re behaving, correct? Your time will come soon... continue to lurk from the shadows. aaasdzx🤔",
				1
			}
		}
	},
	onexlucky = {
		NPCs = {
			Sender = "1x1x1x1",
			Receiver = "RBLXLucky"
		},
		Text = {
			{ "1x1x1x1", "You have extraordinary skills for a Hacker like yourself. Do you want to team up?", 1 },
			{ "Luckymaxer", "from 1x1x1x1 himself.. Interesting. Maybe I’ll take him up on that.", 2 }
		}
	},
	uzothshafi = {
		NPCs = {
			Sender = "Uzoth",
			Receiver = "Shafi"
		},
		Text = {
			{
				"Uzoth",
				"SHAFI... UNDERSTAND THIS. Valentine’s is a time of spreading love. So that’s why i’m committed to tell you that...",
				1
			},
			{ "Uzoth", "your fighting style.. Is OKAY. It’s DECENT.", 1 },
			{
				"Shafi",
				"a letter from Uzoth? wow he likes Sanguine Art. i never expect that of him, it makes sense though, since it’s better, but okay haha",
				2
			}
		}
	},
	fudde = {
		NPCs = {
			Sender = "Uzi_London",
			Receiver = "Fudd"
		},
		Text = {
			{ "E", "Pouring one for you buddy. You were the greatest to ever do it. Come back soon, friend.", 1 },
			{ "Fudd", "...", 2 }
		}
	},
	yetigorilla = {
		NPCs = {
			Sender = "Yeti",
			Receiver = "The Gorilla King"
		},
		Text = {
			{ "Yeti", "HUUUUURRRRRAAAAAHHHH….. Huh… Huh… HRAAA! RRAKHH… ffffhhhh.", 1 },
			{
				"Yeti",
				"(I miss you man, hope all is going well over there. Come visit sometime! By the way, how did you ascend to a “Gorilla God”. What’s the deal with that?)",
				1
			},
			{ "The Gorilla King", "OOOH! OOH HOO UH. MMM-MMM... RAH-OOH AHH.", 2 },
			{
				"The Gorilla King",
				"Yeti! What a nice surprise. Well… it’s too cold over there, but I’ll see what I can do. I’ll tell you more about that in person!",
				2
			}
		}
	},
	marinepirate = {
		NPCs = {
			Sender = "Marine Recruiter",
			Receiver = "Pirate Recruiter"
		},
		Text = {
			{
				"Marine Recruiter",
				"We may stand on opposite sides of the sea… yet even rivals know when they face their equal.",
				1
			},
			{
				"Pirate Recruiter",
				"Heh. Wouldn’t have expected that. Guess the ocean’s big enough for the both of us factions.",
				2
			}
		}
	},
	enchanterblacksmith = {
		NPCs = {
			Sender = "Dragon Talon Sage",
			Receiver = "Blacksmith"
		},
		Text = {
			{ "Enchanter", "Hey Blacksmith, it’s been a pleasure working with you for all these years.", 1 },
			{
				"Enchanter",
				"Our business of forging some of the best weapons has not only made the world a stronger place, but has also been a great help to the Dragon Talon Academy.",
				1
			},
			{
				"Blacksmith",
				"Buddy! I’ve taken great pleasure in what we do together. After all, I was born to work with fine steel.",
				2
			}
		}
	},
	dethskeleton = {
		NPCs = {
			Sender = "Death King",
			Receiver = "Living Skeleton"
		},
		Text = {
			{
				"Death King",
				"Where are you, I’m not done with my research! If I have to find you on my own, you’ll regret me ever giving you consciousness.",
				1
			},
			{
				"Skeleton",
				"Yikes! That’s scary... but, to be honest, I am getting bored with this place. It’s nice to know Death King still thinks about me!",
				2
			},
			{ "Death King", "I don't btw, just get over here!!", 1 }
		}
	},
	boatdealers = {
		NPCs = {
			Sender = "Luxury Boat Dealer",
			Receiver = "Boat Dealer"
		},
		Text = {
			{
				"Luxury Boat Dealer",
				"I remember when you could barely sell a dinghy without sinking it.. Now look at you!",
				1
			},
			{ "Luxury Boat Dealer", "Proud of you, little bro! Soon, you’ll be selling vessels as grand as mine.", 1 },
			{ "Boat Dealer", "Thanks bro, I needed this.. It's hard out here, I'll keep doing my best!", 2 }
		}
	},
	donswan = {
		NPCs = {
			Sender = "Don Swan",
			Receiver = "Military Detective"
		},
		Text = {
			{
				"Don Swan",
				"The world has a funny way of crossing paths. So the next time you see me, I won’t be holding back. Stay vigilant, little Detective.",
				1
			},
			{
				"Military Detective",
				"I get a lot of letters, but this isn’t one I was expecting anytime soon. I wonder what he’s scheming...",
				2
			}
		}
	},
	mygameerin = {
		NPCs = {
			Sender = "mygame43",
			Receiver = "erin"
		},
		Text = {
			{
				"mygame43",
				"Through chaos, creation, and countless long nights, you’ve always been by my side. Happy Valentine's, Erin.",
				1
			},
			{ "Erin", "Tsk.. you never fail to surprise me, Red. Thanks for delivering this.", 2 }
		}
	},
	rosievalentine = {
		NPCs = {
			Sender = "Rosie",
			Receiver = "Valentine"
		},
		Text = {
			{ "Rosie", "Hiyaaa Valentineee… I’ve been wanting to say this for a while… but I LIKE YOU!!! >_<’’", 1 },
			{
				"Valentine",
				"From Rosie... Huh! I never knew she had feelings for me… which is great because I feel the same way! I wonder how I should respond...",
				2
			}
		}
	},
	wenlocktommy = {
		NPCs = {
			Sender = "undercovertommy",
			Receiver = "Wenlocktoad"
		},
		Text = {
			{
				"UndercoverTommy",
				"HI TOAD LOVE TOAD thank u be my brother and best friend. i like you more than Pig Like Mud 🐷",
				1
			},
			{
				"Wenlocktoad",
				"omg tommy thank you its been long time we grow old and together for so long. i rember when we went to roblox block con togeter 🐸",
				2
			}
		}
	},
	egotismcommander = {
		NPCs = {
			Sender = "Oni Boss 2",
			Receiver = "EGOTISMS"
		},
		Text = {
			{
				"Red Commander",
				"Dear Egotisms… I have faced war without fear, but addressing what I feel for you requires greater courage. Please accept these feelings.",
				1
			},
			{ "Egotisms", "Next time, choose your words more carefully. I might take them seriously... Hmph!", 2 }
		}
	},
	indrachan = {
		NPCs = {
			Sender = game.Players.LocalPlayer.Name,
			Receiver = "rip_indra-Chan"
		},
		Text = {
			{ game.Players.LocalPlayer.Name, [[
...
.......
...........]], 1 },
			{ "rip_indra chan", "Oh. Was that meant for me?", 2 },
			{ "rip_indra chan", "Thank you for your feelings. But I must decline. I don't go after... non-admins.", 2 }
		}
	}
}
local v2 = nil
require(game.ReplicatedStorage.Util.RayMap)

local function fn(folder, p)
	if folder:FindFirstChild("Humanoid") then
		folder.Humanoid.Name = "NPC"
	end

	local humanoid = folder:FindFirstChildWhichIsA("Humanoid")

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanQuery = false
		part.CastShadow = false
		part.CanCollide = false
		part.CanTouch = false

		if humanoid then
			if part.Parent:IsA("Accessory") then
				part.Anchored = false
			elseif part.Name == "HumanoidRootPart" then
				part.Anchored = true
			else
				if part.Name == "Head" and part.Parent:FindFirstChild("HumanoidRootPart") then
					local alignPosition = Instance.new("AlignPosition", part)
					local attachment = Instance.new("Attachment", part.Parent:FindFirstChild("HumanoidRootPart"))
					attachment.Position = part.Position - part.Parent:FindFirstChild("HumanoidRootPart").Position
					alignPosition.Attachment0 = Instance.new("Attachment", part)
					alignPosition.Attachment1 = attachment
				end

				part.Anchored = part.Name == "Anchor" or part.Parent.Name == "Anchor"
			end
		elseif folder:GetAttribute("CompositeTextureId") == nil then
			part.Anchored = true
		end
	end

	if folder:FindFirstChild("NPC") then
		folder.NPC.NameDisplayDistance = 40
		folder.NPC.DisplayDistanceType = "Subject"
		folder.NPC.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		folder.NPC.DisplayName = folder:GetAttribute("DisplayName") or folder.NPC.DisplayName
		folder.NPC.BreakJointsOnDeath = false
		folder.NPC.AutoRotate = false
		folder.NPC.RequiresNeck = false
		folder.NPC.EvaluateStateMachine = false
	end

	folder:SetAttribute("FloorPos", p or v2)
	folder:SetAttribute("FloorNormal", createVector(0, 1, 0))
end

local ValDeliveryDialogue = {
	CurrentNpc = nil,
	Responses = responses,
	SpawnNpc = function(p, cframe)
		if not valentinesModels then
			valentinesModels = FX:WaitForChild("ValentinesModels")
		end

		local clone = valentinesModels[p.CurrentNpc.NPCs.Receiver]:Clone()
		clone.Name = "Valentines Delivery"
		clone:SetPrimaryPartCFrame(cframe)
		clone:SetAttribute("Optimized", true)
		fn(clone, cframe.Position - createVector(0, 2.385, 0))
		clone:SetPrimaryPartCFrame(cframe)
		clone.Parent = workspace.NPCs
		return clone
	end
}

local function GetRandomNpc()
	local v3 = {}

	for k, _ in pairs(responses) do
		table.insert(v3, k)
	end

	local v4 = responses[v3[math.random(1, #v3)]]

	if not valentinesModels then
		valentinesModels = FX:WaitForChild("ValentinesModels")
	end

	return valentinesModels:WaitForChild(v4.NPCs.Sender), v4
end

local valentinesDelivery = nil
local total = 0

while not valentinesDelivery and total < 30 do
	total += task.wait(0.1)
	valentinesDelivery = workspace.NPCs:FindFirstChild("Valentines Delivery") or game.ReplicatedStorage.NPCs:FindFirstChild("Valentines Delivery")
end

if not valentinesDelivery then
	return ValDeliveryDialogue
end

if not valentinesModels then
	valentinesModels = FX:WaitForChild("ValentinesModels")
end

ValDeliveryDialogue.OriginalNpc = valentinesModels["Valentines Delivery"]
ValDeliveryDialogue.OriginalNpc:AddTag("ValentinesEvent_Delivery")
local cFrame = valentinesDelivery.PrimaryPart.CFrame
v2 = cFrame.Position - createVector(0, 2.385, 0)
game.Debris:AddItem(valentinesDelivery, 0.1)
task.spawn(function()
	repeat
		task.wait()
	until game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Parent == workspace.Characters

	game.ReplicatedStorage.Remotes.CommF_:InvokeServer("requestHeartDelivery", "Get")
end)
local clone = nil
local thread = nil
local thread2 = nil

function MakeNewNpc()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	if clone then
		clone:PivotTo(CFrame.new(0, -3000, 0))
		clone:Destroy()
		clone = nil
	end

	local v3, currentNpc = GetRandomNpc()
	ValDeliveryDialogue.CurrentNpc = currentNpc
	clone = v3:Clone()
	clone.Name = "Valentines Delivery"
	clone:AddTag("ValentinesEvent_Delivery")
	clone:SetPrimaryPartCFrame(cFrame)
	clone:SetAttribute("Optimized", true)
	fn(clone)
	local folder = Instance.new("Folder", clone)
	folder.Name = "NPCConfig"
	folder:SetAttribute("IgnoreIdleAnimation", true)
	clone.Parent = workspace.NPCs
	local track = clone:FindFirstChildOfClass("Humanoid"):LoadAnimation(Anims:GetRaw("CutesyIdle"))
	local track2 = clone:FindFirstChildOfClass("Humanoid"):LoadAnimation(Anims:GetRaw("ShyPointingIdle"))
	track2.Priority = Enum.AnimationPriority.Movement
	thread = task.spawn(function()
		track:Play(0.3)
		local v5 = math.random(20, 26)

		while true do
			v5 -= task.wait(0.1)

			if v5 < 0 then
				if track2.IsPlaying then
					track2:Stop(1)
					v5 = math.random(20, 26)
				else
					track2:Play(1)
					v5 = math.random(3, 5)
				end
			end

			if not track.IsPlaying then
				track:Play(0.3)
			end
		end
	end)
end

local ValentinesDay2026 = require(game.ReplicatedStorage.EventConfig.ValentinesDay2026)
local Scheduler = require(game.ReplicatedStorage.Util.Scheduler)
Scheduler.between(ValentinesDay2026.START_AT, ValentinesDay2026.NO_MORE_GAMEPLAY_AT):ConnectUpdateLoop(function(flag: boolean)
	if flag then
		if not thread2 then
			thread2 = task.spawn(function()
				while true do
					MakeNewNpc()
					task.wait(os.clock() % 3600)
				end
			end)
		end
	else
		if thread2 then
			task.cancel(thread2)
		end

		if thread then
			task.cancel(thread)
			thread = nil
		end

		if clone then
			clone:PivotTo(CFrame.new(0, -3000, 0))
			clone:Destroy()
			clone = nil
		end
	end
end)
ValDeliveryDialogue.MakeNewNpc = MakeNewNpc
return ValDeliveryDialogue