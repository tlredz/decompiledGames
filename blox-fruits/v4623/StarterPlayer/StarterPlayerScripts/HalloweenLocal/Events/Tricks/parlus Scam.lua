local halloweenEvent = game.ReplicatedStorage.Remotes.HalloweenEvent
local DialogueController = require(game.ReplicatedStorage.DialogueController)
return {
	RunEarly = true,
	func = function(p, p2, _, object)
		local v = p2.WorldModel:GetChildren()[1]
		local parlus = v.NPCs.Parlus
		local death = v.NPCs.Death
		parlus:PivotTo(p.Part.CFrame * CFrame.Angles(0, 0.5235987755982988, 0) * CFrame.new(0, -5, 15))
		death:PivotTo(p.Part.CFrame * CFrame.Angles(0, -0.5235987755982988, 0) * CFrame.new(0, -5, 15))
		local animation = Instance.new("Animation", parlus)
		animation.AnimationId = "rbxassetid://507766388"
		parlus.Humanoid:LoadAnimation(animation):Play()
		death.Humanoid:LoadAnimation(animation):Play()
		local animation2 = Instance.new("Animation", parlus)
		animation2.AnimationId = "rbxassetid://138170251812965"
		local animation3 = Instance.new("Animation", parlus)
		animation3.AnimationId = "rbxassetid://18884847573"
		local v2 = false
		object:Once(function()
			v2 = true
		end)

		if DialogueController.Active then
			DialogueController:Close()
		end

		while DialogueController.Active do
			task.wait()
		end

		if not v2 then
			object:Wait()
		end

		local v3 = false

		local function GiveCandy(p3)
			DialogueController:UpdateTitle(p3 == "Parlus" and "Suizei" or p3)
			local v4 = {
				["Death King"] = "Double",
				Parlus = "Triple"
			}
			v3 = true
			halloweenEvent:FireServer("AcceptReward", p3)
			local v5

			if p3 == "Death King" then
				v5 = death
			else
				v5 = parlus
			end

			v5.Humanoid:LoadAnimation(animation2):Play()
			local Sound = require(game.ReplicatedStorage.Util.Sound)
			Sound:Play("Halloween_Event_Scam_ParlusLaughing_01", p.Part.CFrame, nil, nil, 2)
			return {
				Text = { (`Haha scammed! {v4[p3]}? More like {v4[p3]:lower()} enemies!`) }
			}
		end

		task.spawn(function()
			while not v3 and task.wait() do
				if not ((p.Part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 17) then
					continue
				end

				if not DialogueController.Active then
					break
				end

				DialogueController:Close()
				break
			end
		end)
		DialogueController:Start({
			Title = "Death King",
			Get = function(_)
				task.spawn(function()
					local total = 0

					while DialogueController.Active do
						total += task.wait()

						if not (total > 12) then
							continue
						end

						DialogueController:Close()
						break
					end
				end)
				local track = death.Humanoid:LoadAnimation(animation3)
				track:Play()
				return {
					Text = { "Give me your candy kid, I'll double it!", function()
							parlus.Humanoid:LoadAnimation(animation3):Play()
							track:Stop(0.2)
							DialogueController:UpdateTitle("Suizei")
							return "Double it? I'll TRIPLE it if you give it to me!"
						end },
					Option1 = {
						Label = "Give to Death",
						JumpTo = function()
							return (GiveCandy("Death King"))
						end
					},
					Option2 = {
						Label = "Give to Suizei",
						JumpTo = function()
							return (GiveCandy("Parlus"))
						end
					}
				}
			end
		})

		if not v3 then
			if DialogueController.Active then
				DialogueController:Close()
			end

			while DialogueController.Active do
				task.wait()
			end

			DialogueController:Start({
				Title = "Scammers",
				Get = function(_)
					task.spawn(function()
						local total = 0

						while DialogueController.Active do
							total += task.wait()

							if not (total > 5) then
								continue
							end

							DialogueController:Close()
							break
						end
					end)
					return {
						Text = { "Oh... nevermind I guess." }
					}
				end
			})
			v3 = true
			halloweenEvent:FireServer("AcceptReward", "None")
		end
	end
}