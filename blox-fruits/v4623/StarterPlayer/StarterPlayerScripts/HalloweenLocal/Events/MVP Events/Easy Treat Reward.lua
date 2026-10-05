local halloweenEvent = game.ReplicatedStorage.Remotes.HalloweenEvent
local DialogueController = require(game.ReplicatedStorage.DialogueController)
return {
	RunEarly = true,
	func = function(_, p, _, object)
		local v = p.WorldModel:GetChildren()[1]
		local folder = v.RandomNpc:GetChildren()[math.random(1, #v.RandomNpc:GetChildren())]
		folder:SetPrimaryPartCFrame(v.HumanoidRootPart.CFrame * CFrame.new(0, 1.44, -8))
		local humanoid = folder:FindFirstChildOfClass("Humanoid")

		if not humanoid:FindFirstChild("Animator") then
			Instance.new("Animator", humanoid)
		end

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
			end
		end

		local animation = Instance.new("Animation", folder)
		animation.AnimationId = "rbxassetid://507766388"
		humanoid:LoadAnimation(animation):Play()
		local animation2 = Instance.new("Animation", folder)
		animation2.AnimationId = "rbxassetid://121966805049108"
		local track = humanoid:LoadAnimation(animation2)
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

		local total = 0

		if not v2 then
			object:Wait()
		end

		local v3 = false
		DialogueController:Start({
			Title = folder.Name,
			Get = function(_)
				return {
					Text = { "Oh, hello there!" },
					Option1 = {
						Label = "Trick or Treat!",
						JumpTo = function()
							v3 = true
							halloweenEvent:FireServer("AcceptReward")
							task.spawn(function()
								while DialogueController.Active do
									total += task.wait()

									if not (total > 3) then
										continue
									end

									DialogueController:Close()
									break
								end
							end)

							if not track.IsPlaying then
								track:Play()
							end

							return {
								Text = { "Happy Halloween!" }
							}
						end
					}
				}
			end
		})

		if not v3 then
			halloweenEvent:FireServer("AcceptReward")
		end

		if not track.IsPlaying then
			track:Play()
		end

		while total < 3 do
			total += task.wait(0.1)
		end
	end
}