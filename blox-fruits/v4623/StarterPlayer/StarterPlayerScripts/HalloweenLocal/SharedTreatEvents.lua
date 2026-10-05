local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalUtil = require(ReplicatedStorage.GlobalUtil)
local SharedTreatEvents = {}

local function addEvent(p: string, childName: string, baseCandy: number, flag: boolean, value: string?, value2)
	if SharedTreatEvents[p] then
		error((`bad -> {p}`))
	end

	local halloweenEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HalloweenEvent")
	SharedTreatEvents[p] = {
		Server = {
			Name = "EasyTreat",
			Type = "Treat",
			Scene = value2 or "Mansion",
			BaseCandy = baseCandy,
			Server = function(p3, _, object, maid, _, callback)
				maid:GiveTask(task.spawn(function()
					repeat
						local v, v2 = halloweenEvent.OnServerEvent:Wait()
					until v == p3 and v2 == "AcceptReward"

					warn("player accepted a reward")
					callback(p3, baseCandy)
					task.wait(3)
					object:Fire()
				end))
			end
		},
		Client = {
			RunEarly = true,
			func = function(_, p3, _, object)
				local DialogueController = require(game.ReplicatedStorage.DialogueController)
				local v = p3.WorldModel:GetChildren()[1]

				if not v then
					return
				end

				local randomNpc = v:FindFirstChild("RandomNpc")

				if not randomNpc or #randomNpc:GetChildren() == 0 then
					return
				end

				local folder = randomNpc:FindFirstChild(childName) or randomNpc:GetChildren()[math.random(
					1,
					#randomNpc:GetChildren()
				)]
				local humanoidRootPart = v:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart and folder.PrimaryPart then
					folder:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(0, 1.44, -8))
				elseif humanoidRootPart and folder:FindFirstChildWhichIsA("BasePart") then
					folder:MoveTo(humanoidRootPart.Position + createVector(0, 1.44, -8))
				end

				local pants = childName == "Experienced Captain" and math.random() < 0.25 and folder:FindFirstChildOfClass("Pants")

				if pants then
					pants.PantsTemplate = ""
				end

				local humanoid = folder:FindFirstChildOfClass("Humanoid")
				local v2 = humanoid ~= nil

				if humanoid and not humanoid:FindFirstChild("Animator") then
					Instance.new("Animator", humanoid)
				end

				for _, part in ipairs(folder:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = false
					end
				end

				local track = nil

				if v2 then
					local animation = Instance.new("Animation")
					animation.AnimationId = "rbxassetid://507766388"
					humanoid:LoadAnimation(animation):Play()

					if flag then
						local animation2 = Instance.new("Animation")
						animation2.AnimationId = "rbxassetid://121966805049108"
						track = humanoid:LoadAnimation(animation2)
					end
				end

				local v3 = false
				object:Once(function()
					v3 = true
				end)

				if DialogueController.Active then
					DialogueController:Close()
				end

				while DialogueController.Active do
					task.wait()
				end

				local total = 0

				if not v3 then
					object:Wait()
				end

				local v4 = false
				DialogueController:Start({
					Title = childName,
					Get = function(_)
						return {
							Text = { value or "Oh, hello there!" },
							Option1 = {
								Label = "Trick or Treat!",
								JumpTo = function()
									v4 = true
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

									if flag and track and not track.IsPlaying then
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

				if not v4 then
					halloweenEvent:FireServer("AcceptReward")
				end

				if flag and track and not track.IsPlaying then
					track:Play()
				end

				while total < 3 do
					total += task.wait(0.1)
				end
			end
		}
	}
end

if GlobalUtil.FFlags.IsUnitTest == true then
	return SharedTreatEvents
end

addEvent("rip_indra", "rip_indra", 400, true, "Only the powerful are worthy of such delicacies. Take it.")
addEvent("Stone Mygame", "Stone Mygame", 200, false, "I'm still sealed.. maybe this will persuade you to free me.")
addEvent("Shafi", "Shafi", 100, true, "im actually cooking that one fruit rn. uk the one. want some candy man?")
addEvent("Uzoth", "Uzoth", 50, true, "Yo! Here's some candy. Wait, what Fighting Style are you using again..?")
addEvent("Mysterious Scientist", "Mysterious Scientist", 40, true)
addEvent("Luxury Boat Dealer", "Luxury Boat Dealer", 30, true)
addEvent("Dog House", "Dog House", 25, false, "WOOF WOOF")
addEvent("Dragon Hunter", "Dragon Hunter", 15, true)
addEvent("Ancient Monk", "Ancient Monk", 13, true, "A gift for the worthy. Accept this candy, mortal.")
addEvent("Experienced Captain", "Experienced Captain", 12, true, "What the, ahoy!!")
addEvent("Boat Dealer", "Boat Dealer", 11, true)
addEvent("Barista Cousin", "Barista Cousin", 10, true)
addEvent("Awakenings Expert", "Awakenings Expert", 7, true)
addEvent("Bandit Quest Giver", "Bandit Quest Giver", 5, true, "Long time no see! Here you go.")
return SharedTreatEvents