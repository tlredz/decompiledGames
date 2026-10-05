local ChristmasPresentClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()

function PresentAdded(instance)
	if instance.Parent ~= workspace.Items then
		return
	end

	local proximityInteraction = instance:WaitForChild("Main"):WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
	local chestLid = instance:WaitForChild("ChestLid")
	local origCF = instance:GetAttribute("OrigCF") or instance:GetPivot()
	instance:SetAttribute("OrigCF", origCF)
	local objectSpace = origCF:ToObjectSpace(chestLid:GetPivot())
	local origCF2 = chestLid:GetAttribute("OrigCF") or objectSpace
	chestLid:SetAttribute("OrigCF", origCF2)
	local v = 0
	local v2 = 0
	local v3 = 0
	local v4 = 0
	local v5 = 0
	proximityInteraction.PromptButtonHoldBegan:Connect(function()
		local v6 = v + 1
		v = v6
		local holdDuration = proximityInteraction.HoldDuration
		local v7 = random:NextNumber() * 100
		local v8 = random:NextNumber() * 100
		local v9 = random:NextNumber() * 100
		local v10 = random:NextNumber() * 100
		local v11 = math.noise(v7, 0)
		local v12 = math.noise(v8, 0)
		local v13 = math.noise(v9, 0)
		local v14 = math.noise(v10, 0)
		local total = 0
		local total2 = 0

		while v == v6 do
			local v15 = task.wait()
			total += v15
			local v16 = total / holdDuration
			total2 += v15 * (math.clamp(v16, 0.3, 0.55) * 15)
			local v17 = (math.noise(v7, total2) - v11) * v16
			local v18 = (math.noise(v8, total2) - v12) * v16
			local v19 = (math.noise(v9, total2) - v13) * v16
			local v20 = (math.noise(v10, total2) - v14) * v16
			v2 = math.rad(v17 * 8)
			v3 = math.rad(v18 * 8)
			v4 = math.rad(v19 * 7)
			v5 = math.rad(v20 * 7)
			local v21 = instance:GetAttribute("OrigCF") * CFrame.Angles(v2, 0, v3)
			instance:PivotTo(v21)
			chestLid:PivotTo(v21 * origCF2 * CFrame.Angles(v4, 0, v5))
		end

		Client.TweenModule.new(function(p)
			local v15 = v2 * (1 - p)
			local v16 = v3 * (1 - p)
			local v17 = v4 * (1 - p)
			local v18 = v5 * (1 - p)
			local v19 = instance:GetAttribute("OrigCF") * CFrame.Angles(v15, 0, v16)
			instance:PivotTo(v19)
			chestLid:PivotTo(v19 * origCF2 * CFrame.Angles(v17, 0, v18))
		end, 0.25):Play()
	end)
	proximityInteraction.PromptButtonHoldEnded:Connect(function()
		v += 1
	end)
end

function Rand(p, p2)
	return p + random:NextNumber() * (p2 - p)
end

function SpawnCandyCanes(instance)
	local v = instance:GetPivot() * CFrame.Angles(1.5707963267948966, 0, 0)
	local candyCane = game.ReplicatedStorage.Assets.Christmas["Candy Cane"]

	for _ = 1, localPlayer:GetAttribute("Class") == "Santa's Helper" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 3 and 6 or 5 do
		local v2 = v * CFrame.Angles(0, 0, random:NextNumber() * 3.141592653589793 * 2) * CFrame.Angles(
			0.5235987755982988,
			0,
			0
		)
		local v3 = v2.LookVector * 40 * candyCane.PrimaryPart.AssemblyMass
		Client.CandyCaneClient.SpawnCandyCane(v2, "Present", v3)
	end
end

Client.Events.VisualOpenPresent:Connect(function(p)
	ChristmasPresentClient.OpenChest(p, false, true)
end)

function ChristmasPresentClient.OpenChest(instance, p, p2)
	local onFactoryLine = instance:GetAttribute("OnFactoryLine")

	if p then
		instance:Destroy()
		return
	end

	instance:RemoveTag("GeneratorPresent")

	if not p2 then
		Client.Events.RequestOpenItemChest:FireServer(instance)
	end

	Client.Sound.Play("PresentOpen")

	if p2 then
		if instance.PrimaryPart:FindFirstChild("ProximityAttachment") then
			instance.PrimaryPart.ProximityAttachment:Destroy()
		end

		instance:RemoveTag("Interaction")
	end

	instance:PivotTo((instance:GetAttribute("OrigCF")))
	local clone = instance:Clone()
	clone.Parent = workspace.Particles
	instance:Destroy()

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CollisionGroup = "Presents"

		if part.Name ~= "Main" and part.Name ~= "Base" then
			part.Anchored = false
		end
	end

	if clone:GetAttribute("LootTable") == "ChristmasChest2" and not clone:GetAttribute("SingleUse") then
		SpawnCandyCanes(clone)
	end

	local primaryPart = clone.PrimaryPart
	Client.Utility.SpawnParticles("PresentVFX", primaryPart.CFrame)
	local chestLid = clone:WaitForChild("ChestLid")
	local v = CFrame.Angles(0, random:NextNumber() * 3.141592653589793 * 2, 0) * CFrame.Angles(0.2617993877991494, 0, 0)
	local v2 = v.UpVector * (chestLid.PrimaryPart.AssemblyMass * 70)
	chestLid.PrimaryPart:ApplyImpulse(v2)
	chestLid.PrimaryPart:ApplyAngularImpulse(v.LookVector * 120)

	for _, child in pairs(clone.Base:GetChildren()) do
		if child.Name == "Side" then
			child:ApplyImpulse((child.Position - primaryPart.Position).Unit * 10)
		end
	end

	task.delay(10, function()
		chestLid:Destroy()
	end)
	task.delay((onFactoryLine and 0.1 or 1) * 20, function()
		clone:Destroy()
	end)
end

function ChristmasPresentClient.Init()
	Client.Utility.ForAllTagged("ChristmasPresent", PresentAdded)
end

return ChristmasPresentClient