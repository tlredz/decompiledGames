require(game.ReplicatedStorage.DialoguesList.Types)
local Util = require(game.ReplicatedStorage.DialoguesList.Util)
return {
	Title = "robloxmecha",
	Get = function(_)
		return {
			Text = { "say it and say it well" },
			Option1 = {
				Label = "i say",
				JumpTo = function()
					return ((function()
						local v = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RobotTalk")

						if v == 0 then
							return {
								Text = { "idk of u" },
								Option1 = {
									Label = "k",
									JumpTo = function()
										return {
											Text = { "k" }
										}
									end
								}
							}
						elseif v == 1 then
							Util.playAction("Negative")
							return {
								Text = { "i cant respect you yet..." },
								Option1 = {
									Label = "respect me",
									Text = { "OMG I SAID I CANT RESPECT U YET BRO! U NEED TO EARN MY RESPECT NOT ASK FOR IT!!! " },
									Option1 = {
										Label = ":( k",
										Text = { "K" }
									}
								}
							}
						elseif v == 2 then
							return {
								Text = { "what do u need bro" },
								Option1 = {
									Label = "respect me well",
									Text = {
										"x",
										"xx",
										"XXXXXX",
										"XXXXXXXXXXXXOMGGMGOMGMGGMG I SURE RESPECT U WELL BRO",
										"u have earned all my respect for reaching lvl 350! yo bro can u help me with a quest plz?"
									},
									Option1 = {
										Label = "fast",
										Text = {
											"K",
											"yo bro have u seen my son indra? he escaped yesterday when i caught him cheating with my homie mygame43 plz help me capture him bro 😭"
										},
										Option1 = {
											Label = "for sure g",
											Text = { "omg ur a real homie thx" }
										}
									}
								}
							}
						end

						if v == 3 or v == 4 then
							Util.playAction("Negative")
							return {
								Text = { "im busy playing nsuns in this moment go find my son indra" },
								Option1 = {
									Label = "k",
									Text = { "omg talk to me later bro" }
								}
							}
						end

						if v == 5 then
							Util.playAction("Positive")
							return {
								Text = { "cri cri cri my son still loves me 😭😭😭 THX BRO UR A REAL G U HAVE 100% MY RESPECT NOW! AND I HAVE HACKED UR <Dark Blade> GO SEE!!!" },
								Option1 = {
									Label = "xomg",
									Text = { "YEYE IF U NEED ANYTHING JUST TELL ME NO SHAME U KNOW WELL THATS WHAT HOMIES ARE FOR" }
								}
							}
						elseif v == 6 then
							return {
								Text = { "hm" },
								Option1 = {
									Label = "mission",
									Text = { "go PM ffudd10 in roblox and tell him the $avage is after him 🤡" }
								}
							}
						end

						return {
							Text = { "..." }
						}
					end)())
				end
			}
		}
	end
}