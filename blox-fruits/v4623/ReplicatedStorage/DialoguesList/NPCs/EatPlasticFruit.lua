require(game.ReplicatedStorage.DialoguesList.Types)
return {
	Title = "Plastic Fruit",
	Get = function(_)
		local v = nil
		v = {
			Text = { "What do you wish to do with this Plastic Fruit?<AnimateYield=3>" },
			Option1 = {
				Label = "Eat",
				JumpTo = function()
					local eatRemote = game.Players.LocalPlayer.Character:FindFirstChild("EatRemote", true)

					if not eatRemote then
						return {
							Text = { "[You must be holding out the Plastic Fruit to eat it.]" }
						}
					end

					local function Eat()
						local v2 = eatRemote:InvokeServer()

						if typeof(v2) == "string" then
							return {
								Text = { v2 }
							}
						end

						if v2 == true then
							return {
								Text = { "[Eating Plastic Fruit.]" }
							}
						end

						return {
							Text = { "[An error has occurred. Please try again.]" }
						}
					end

					if game.Players.LocalPlayer.Data.DevilFruit.Value == "" then
						return (Eat())
					end

					return {
						Text = { "Are you sure?" },
						Option1 = {
							Label = "Confirm",
							JumpTo = function()
								return (Eat())
							end
						},
						Option2 = {
							Label = "Cancel",
							JumpTo = function()
								return v
							end
						}
					}
				end
			},
			Option2 = {
				Label = "Drop",
				JumpTo = function()
					local eatRemote = game.Players.LocalPlayer.Character:FindFirstChild("EatRemote", true)

					if not eatRemote then
						return {
							Text = { "[You must be holding out the Plastic Fruit to drop it.]" }
						}
					end

					if eatRemote:InvokeServer("Drop") == true then
						return {
							Text = { "[Plastic Fruit dropped.]" }
						}
					end

					return {
						Text = {
							"[Cannot drop Plastic Fruit.]",
							"[Plastic Fruits that were previously stored cannot be dropped.]"
						}
					}
				end
			},
			Option3 = {
				Label = "Store",
				JumpTo = function()
					local eatRemote = game.Players.LocalPlayer.Character:FindFirstChild("EatRemote", true)

					if not eatRemote then
						return {
							Text = { "[You must be holding out the Plastic Fruit to store it.]" }
						}
					end

					if game.ReplicatedStorage.Remotes.CommF_:InvokeServer(
						"StoreFruit",
						eatRemote.Parent:GetAttribute("OriginalName"),
						eatRemote.Parent
					) == true then
						return {
							Text = { "[Plastic Fruit stored.]" }
						}
					end

					return {
						Text = { "[Storage failed.]" }
					}
				end
			}
		}
		return v
	end
}