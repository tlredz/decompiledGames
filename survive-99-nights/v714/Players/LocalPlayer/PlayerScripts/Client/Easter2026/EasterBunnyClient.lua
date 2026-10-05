local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("RunService")
local random = Random.new()
local v = {}
local v2 = {}
local v3 = {}
local v4 = true
local v5 = false
local easterMapHolder = Client.Interface.EasterMapHolder
Client.InteractionHandler.RegisterInteraction("EasterBunnyEgg", function(p)
	Client.Events.RequestStealEasterBunnyEgg:FireServer(p)
end)
easterMapHolder.CloseButton.MouseButton1Click:Connect(function()
	easterMapHolder.Visible = false
end)

function worldToScale(p, p2)
	return p / 2800 + 0.5, p2 / 2800 + 0.5
end

task.spawn(function()
	local function check()
		local easterBunnySafePos = workspace:GetAttribute("EasterBunnySafePos")

		if easterBunnySafePos then
			local v6, v7 = worldToScale(easterBunnySafePos.X, easterBunnySafePos.Z)
			easterMapHolder.Map.Icons.BunnyHouseIcon.Position = UDim2.new(v6, 0, v7, 0)
			easterMapHolder.Map.Icons.BunnyHouseIcon.Visible = true
		end
	end

	check()
	workspace:GetAttributeChangedSignal("EasterBunnySafePos"):Connect(check)
end)
Client.Events.RunEasterBunnyCheckMap:Connect(function(p)
	if p == localPlayer then
		Client.Events.CutsceneComplete:Connect(function(p2)
			if p2 == "MapFoundCutscene" then
				task.delay(1, function()
					easterMapHolder.Visible = true
				end)
			end
		end)
	end

	Client.Events.RunCutscene:Fire("MapFoundCutscene", {
		ForceCutscene = true,
		NoSkip = false
	})
end)
Client.Events.CutsceneComplete:Connect(function(p)
	if p == "EggStolenCutscene" then
		Client.Events.EggStolenCutsceneFinished:FireServer()
	end
end)
Client.Events.FlashEggWarning:Connect(function(player)
	local easterBunnyEgg = player.Character and player.Character:FindFirstChild("Easter Bunny Egg")

	if easterBunnyEgg then
		print("flash red", easterBunnyEgg:GetFullName())
		Client.EggEffectClient.FlashRed(easterBunnyEgg)
	end
end)

function BunnyHitGround(position)
	local volume

	if position then
		local magnitude = (workspace.CurrentCamera.Focus.Position - position).Magnitude

		if magnitude < 80 then
			volume = math.clamp(1 - magnitude / 80, 0, 1)
		else
			return
		end
	else
		volume = 1
	end

	local integer = random:NextInteger(1, 2)
	Client.Sound.Play("BunnyHop" .. integer, {
		Volume = volume,
		Position = position,
		VarySpeed = 0.1
	})
	task.delay(0.2, function()
		local v7 = math.clamp(volume, 0.1, 1)
		Client.CamShake.ShakeOnce(v7 * 4, 25, 0.07, 0.25)
	end)
end

local EasterBunnyClient = {
	BunnyHitGround = BunnyHitGround
}

function StartBunnyChaseVFX()
	v5 = true
	task.spawn(function()
		local egg = workspace.Map.Campground:WaitForChild("MainFire"):WaitForChild("Center"):WaitForChild("FarAway"):WaitForChild("ImageLabel"):WaitForChild("Egg")

		if not egg then
			return
		end

		egg.Visible = true

		while egg.Visible do
			local magnitude = math.round(((localPlayer.Character and localPlayer.Character:GetPivot().Position or workspace.CurrentCamera.CFrame.Position) * createVector(
				1,
				0,
				1
			)).Magnitude)
			egg.TextLabel.Text = magnitude .. "m"
			task.wait()
		end
	end)
	task.delay(1, function()
		for _ = 1, 3 do
			BunnyHitGround()
			task.wait(1.4)
		end
	end)
	task.delay(1.4, function()
		Client.PopUpUI.AddPopUp("get the egg back to safety", "easterbunny")
	end)
end

Client.Events.StartBunnyChaseVFX:Connect(StartBunnyChaseVFX)

function EndBunnyChaseVFX()
	v5 = false
	task.spawn(function()
		local egg = workspace.Map.Campground:WaitForChild("MainFire"):WaitForChild("Center"):WaitForChild("FarAway"):WaitForChild("ImageLabel"):WaitForChild("Egg")

		if not egg then
			return
		end

		egg.Visible = false
	end)
end

Client.Events.EndBunnyChaseVFX:Connect(EndBunnyChaseVFX)
Client.InteractionHandler.RegisterInteraction("OpenEasterBunnyMap", function(_)
	if workspace:GetAttribute("EasterBunnyEggGenerated") then
		easterMapHolder.Visible = true
	else
		Client.Events.RequestGenerateBunnyEgg:FireServer()
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateEggIndices()
	v3 = {}

	for k, v6 in pairs(v2) do
		v3[v6] = k
	end
end

Client.Events.RescueEasterBunnyEgg:Connect(function(player)
	if player and player.Character and player.Character:FindFirstChild("Easter Bunny Egg") then
		local easterBunnyEgg = player.Character["Easter Bunny Egg"]
		AddFloatingEgg(easterBunnyEgg:Clone(), nil, player)
		easterBunnyEgg:Destroy()
	end
end)

function AddFloatingEgg(folder, instance, player)
	local cFrame = nil

	if instance then
		cFrame = instance:FindFirstChild("FloatPos").CFrame
	elseif player and player.Character then
		cFrame = CFrame.new(player.Character:GetPivot().Position) + createVector(0, 3, 0)
	end

	if not cFrame then
		return
	end

	local rareEgg = folder:GetAttribute("RareEgg")
	task.delay(1.5, function()
		local pivot = folder:GetPivot()

		if rareEgg then
			Client.Utility.SpawnParticles("BunnyVFXLarge", pivot)
		else
			Client.Utility.SpawnParticles("BunnyVFXSmall", pivot)
		end

		local index = table.find(v2, folder)

		if index then
			table.remove(v2, index)
			UpdateEggIndices() -- equivalent call inferred; original call site unknown
		end

		folder:Destroy()
	end)

	for k, _ in pairs(folder:GetAttributes()) do
		folder:SetAttribute(k, nil)
	end

	for _, tag in pairs(folder:GetTags()) do
		folder:RemoveTag(tag)
	end

	if folder:FindFirstChild("HoverLabel") then
		folder.HoverLabel:Destroy()
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Anchored = true
		elseif part.Name == "ToolWeld" then
			part:Destroy()
		end
	end

	folder:GetPivot()
	local total = 0
	folder.Parent = workspace.Particles
	Client.EggEffectClient.FlashGreenTick(folder)

	if player == nil then
		if v4 then
			table.insert(v2, folder)
		else
			table.insert(v2, 1, folder)
		end
	end

	UpdateEggIndices() -- equivalent call inferred; original call site unknown
	v4 = not v4
	local integer = random:NextInteger(160, 200)
	local total2 = 0
	task.spawn(function()
		while true do
			local v6 = task.wait()

			if not folder.Parent then
				break
			end

			total += integer * v6
			total2 += 1 * v6
			local v7

			if player then
				v7 = 0
			else
				v7 = (#v2 + 1) / 2
			end

			local v8 = (v3[folder] or 0) - v7
			local v9 = v8 * 4
			local v10 = math.abs(v8 / 6) ^ 2 * 4
			local v11 = cFrame * CFrame.new(v9, 0, v10) * CFrame.Angles(0, math.rad(total), 0) + Vector3.new(
				0,
				total2,
				0
			)
			folder:PivotTo((folder:GetPivot():Lerp(v11, 0.1)))
		end
	end)
end

function AnimateGiveEasterEgg(instance, p, _)
	local easterBunny = p.Parent:WaitForChild("EasterBunny")
	local v6 = v[easterBunny]
	task.spawn(function()
		AddFloatingEgg(instance:Clone(), p)
	end)
	local v7 = instance:GetAttribute("RareEgg") and "RareEggReceived" or "CommonEggReceived"
	local v8 = v6[v7]

	if v7 == "CommonEggReceived" and v6.RareEggReceived.IsPlaying or v8.IsPlaying then
		return
	end

	if v7 == "RareEggReceived" then
		v6.CommonEggReceived:Stop()
	end

	local pivot = easterBunny:GetPivot()

	if v7 == "CommonEggReceived" then
		Client.Utility.SpawnParticles("BunnyVFXSmall", pivot)
	elseif v7 == "RareEggReceived" then
		Client.Utility.SpawnParticles("BunnyVFXLarge", pivot)
	end

	v8:Play()
	Client.Sound.Play("BunnyGivenEgg", {
		Position = easterBunny:GetPivot().Position
	})
end

Client.Events.AnimateGiveEasterEgg:Connect(AnimateGiveEasterEgg)

function EasterBunnyAdded(instance)
	if not instance:IsDescendantOf(workspace) then
		return
	end

	local animator = instance:WaitForChild("AnimationController"):WaitForChild("Animator")
	local tracksByName = {}

	for _, animation in pairs(instance:WaitForChild("Animations"):GetChildren()) do
		tracksByName[animation.Name] = animator:LoadAnimation(animation)
	end

	tracksByName.Idle:Play()
	v[instance] = tracksByName
end

Client.Utility.ForAllTagged("EasterBunny", EasterBunnyAdded)
Client.InteractionHandler.RegisterInteraction("TakeEasterBasket", function(_)
	if localPlayer.Inventory:FindFirstChild("Egg Basket") then
		Client.PopUpUI.AddPopUp("You already have an egg basket", "easter")
		return
	end

	Client.Sound.Play("TakeBasket")
	Client.Events.RequestTakeEasterBasket:FireServer()
end)
local v6 = {}

function EasterEggZoneAdded(instance)
	local v7 = {}
	instance:WaitForChild("TouchPart").Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if not parent:GetAttribute("EasterEggId") or parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId or v7[parent] then
			return
		end

		v7[parent] = true

		if parent:GetAttribute("EggLocked") then
			task.delay(2, function()
				v7[parent] = nil
			end)

			if not v6[parent] then
				v6[parent] = true
				task.spawn(function()
					Client.EggEffectClient.FlashRedCross(parent)
					Client.PopUpUI.AddPopUp("this egg isn't ready yet", "easterwarning")
					wait(10)
					v6[parent] = false
				end)
			end
		else
			parent.Parent = game.ReplicatedStorage.TempStorage
			local v8 = {}
			task.spawn(function()
				AnimateGiveEasterEgg(parent, instance, v8)
			end)
			task.spawn(function()
				print("Fire", parent:GetFullName())
				local v9 = Client.Events.RequestGiveEasterEgg:InvokeServer(parent, instance)

				if v9 and v9.Success then
					v8.Success = true
				else
					task.wait(1)
					parent.Parent = workspace.Items
				end

				v7[parent] = nil
			end)
		end
	end)
end

Client.Utility.ForAllTagged("EasterEggDropZone", EasterEggZoneAdded)
return EasterBunnyClient