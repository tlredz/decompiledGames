local AlienCommandShipClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
Client.Events.OpenAlienAirlock:Connect(function(instance, p)
	if not instance then
		return
	end

	local v = p - workspace:GetServerTimeNow()

	if v > 0 then
		task.wait(v)
	end

	Client.Events.OpenAlienDoor:Fire(instance, 0.1)
	local pivot = instance:GetPivot()

	local function fly(instance2)
		local clone = instance2:Clone()
		instance2:Destroy()
		task.delay(0.5, function()
			clone:Destroy()
		end)
		clone:RemoveTag("AirlockAlien")
		clone.Parent = workspace.Particles
		local unit = (pivot.Position - clone.PrimaryPart.Position).Unit
		local primaryPart = clone.PrimaryPart
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.MaxForce = 1e999
		linearVelocity.VectorVelocity = unit * 70
		linearVelocity.Attachment0 = primaryPart.RootAttachment
		linearVelocity.Parent = primaryPart
	end

	task.spawn(function()
		local total = 0

		while total < 5 do
			local tagged = CollectionService:GetTagged("AirlockAlien")

			if #tagged <= 0 then
				break
			end

			for _, v2 in pairs(tagged) do
				if v2:GetAttribute("Dead") then
					fly(v2)
				end
			end

			total += task.wait()
		end
	end)
end)
Client.InteractionHandler.RegisterInteraction("AirlockLever", function(p)
	Client.Events.RequestPullAlienAirlockLever:FireServer(p)
end)
Client.InteractionHandler.RegisterInteraction("PrisonLever", function(p)
	Client.Events.RequestPullAlienPrisonLever:FireServer(p)
	print("pull lever")
end)
Client.Events.AnimateCellOpening:Connect(function(instance)
	if not instance then
		return
	end

	local children = { instance:FindFirstChild("ForceField") }

	for _, child in pairs(instance.Bars:GetChildren()) do
		table.insert(children, child)
	end

	for _, v in pairs(children) do
		TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 1
		}):Play()
	end
end)

function AlienCommandShipClient.Init() end

return AlienCommandShipClient