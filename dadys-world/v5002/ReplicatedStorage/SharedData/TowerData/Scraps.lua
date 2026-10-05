local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function canseetarget(folder, parent, p, part, magnitude)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")
	local folders = {}
	local filterDescendantsInstances = {}
	local position = p.Position
	local v2 = (part.Position - p.Position).Unit * magnitude
	local raycastParams = RaycastParams.new()

	if model then
		model:WaitForChild("Monsters")

		for _, folder2 in pairs(model.Monsters:GetChildren()) do
			if table.find(folders, folder2) then
				continue
			end

			for _, part2 in pairs(folder2:GetDescendants()) do
				if part2:IsA("BasePart") then
					table.insert(filterDescendantsInstances, part2)
				end
			end

			table.insert(folders, folder2)
		end
	end

	for _, folder2 in pairs(workspace.Elevators:GetChildren()) do
		if table.find(folders, folder2) then
			continue
		end

		for _, part2 in pairs(folder2:GetDescendants()) do
			if part2:IsA("BasePart") then
				table.insert(filterDescendantsInstances, part2)
			end
		end

		table.insert(folders, folder2)
	end

	for _, part2 in pairs(folder:GetDescendants()) do
		if part2:IsA("BasePart") then
			table.insert(filterDescendantsInstances, part2)
		end
	end

	for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
		if child ~= parent then
			table.insert(filterDescendantsInstances, child)
		end
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = game.Workspace:Raycast(position, v2, raycastParams)

	if raycastResult and raycastResult.Instance and raycastResult.Instance:IsDescendantOf(parent) then
		return true
	end

	return false
end

local Scraps = {
	Name = "Scraps",
	Icon = "rbxassetid://17552138553",
	VoteIcon = "rbxassetid://17552098307",
	Render = "rbxassetid://115014938712178",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 12.5,
	RunSpeed = 22.5,
	DecodeSpeed = 1,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 200,
	BoundarySize = 100,
	DecodeRank = 3,
	SpeedRank = 2,
	StaminaRank = 5,
	StealthRank = 3,
	SkillCheckRank = 2,
	Ability1Name = "Crafty Grapple",
	Ability1Type = "Active",
	Ability1Description = "This Toon can pull herself towards another Toon or Machine’s targeted position. Needs direct line of sight. 25 second cooldown.",
	Cost = 1500,
	Requirement1 = { "Coin", 1500 },
	Requirement2 = { "Research", 50, "GoobMonster" },
	MasterySkin = "VintageScraps",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 100
		},
		{
			Name = "TravelDistance",
			Requirement = 85000
		},
		{
			Name = "PickUpItem",
			Requirement = 60
		},
		{
			Name = "UseItem",
			Requirement = 60
		},
		{
			Name = "EncounterMonster",
			Requirement = 25
		},
		{
			Name = "BuyDandyStoreItem",
			Requirement = 12
		}
	},
	RightHandBone = "R_hand_jnt",
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		instance.Head.TextureID = config.HurtTexture.Texture
		task.wait(2)

		if instance.Parent ~= nil then
			instance.Head.TextureID = config.NormalTexture.Texture
		end
	end,
	ActiveAbility = true,
	PlayerAbility = true,
	GeneratorAbility = true,
	CanTargetStash = true,
	TargetVisual = {
		text = "TARGET"
	},
	PlayerRadius = 80,
	AbilityIcon = "rbxassetid://17701466969",
	AbilityCooldown = 25,
	CustomAbilitySound = {
		SoundId = "rbxassetid://9120660757",
		PlaybackSpeed = 0.76,
		Volume = 0.35
	},
	SpecialSetupClient = function(_) end,
	SpecialSetup = function(parent)
		local v = parent:FindFirstChild("Grabbing")

		if not v then
			v = Instance.new("BoolValue")
			v.Name = "Grabbing"
			v.Value = false
			v.Parent = parent
		end

		v.Changed:Connect(function()
			if v.Value == true then
				for _, folder in pairs(parent:GetChildren()) do
					if not string.find(folder.Name, "Tail") then
						continue
					end

					for _, part in pairs(folder:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 1
						end
					end

					folder.Transparency = 1
				end
			else
				for _, folder in pairs(parent:GetChildren()) do
					if not string.find(folder.Name, "Tail") then
						continue
					end

					local flag = true

					for _, part in pairs(folder:GetDescendants()) do
						if not part:IsA("BasePart") or part:FindFirstChild("NoHide") then
							continue
						end

						part.Transparency = 0
						flag = false
					end

					if flag then
						folder.Transparency = 0
					else
						folder.Transparency = 1
					end
				end
			end
		end)

		while parent.Parent do
			local torso_jnt = parent.RootPart:FindFirstChild("torso_jnt", true)

			if not torso_jnt then
				continue
			end

			local attachment = Instance.new("Attachment")
			attachment.Name = "AttachmentL0"
			attachment.CFrame = CFrame.new(0.4, 0.45, 0)
			attachment.Parent = torso_jnt
			break
		end
	end,
	UseActiveAbility = function(player, instance, p, parent)
		instance:WaitForChild("Config")
		local decoding = instance:WaitForChild("Decoding")
		local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
		local cooldown = ability1:WaitForChild("Cooldown")
		local currentCooldown = ability1:WaitForChild("CurrentCooldown")
		local stats = instance:WaitForChild("Stats")
		stats:WaitForChild("WalkSpeed")
		stats:WaitForChild("RunSpeed")
		local humanoid = instance:WaitForChild("Humanoid")

		if currentCooldown.Value > 0 then
			return {
				Outcome = false,
				Reason = "That Ability is on Cooldown!"
			}
		end

		if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
			return {
				Outcome = false,
				Reason = "Can't use that Ability in the Elevator!"
			}
		end

		if decoding.Value ~= nil then
			return {
				Outcome = false,
				Reason = "Can't use that Ability while extracting!"
			}
		end

		if not parent or parent.Parent == nil then
			return {
				Outcome = false,
				Reason = "No valid targets in range!"
			}
		end

		local v = CollectionService:HasTag(parent, "Generator") or CollectionService:HasTag(parent, "GigiStash")

		if v then
			if not parent.PrimaryPart then
				return {
					Outcome = false,
					Reason = "Invalid generator target!"
				}
			end
		else
			local humanoid2 = parent:FindFirstChildOfClass("Humanoid")

			if not humanoid2 or humanoid.Health <= 0 or humanoid2.Health <= 0 then
				return {
					Outcome = false,
					Reason = "No valid targets in range!"
				}
			end

			local grabbing = parent:FindFirstChild("Grabbing")

			if grabbing and grabbing.Value == true then
				return {
					Outcome = false,
					Reason = "You can't target Toons who are grabbing!"
				}
			end
		end

		local primaryPart = parent.PrimaryPart
		local primaryPart2 = instance.PrimaryPart
		local position

		if v then
			local scrapsAttachPoint = parent:FindFirstChild("ScrapsAttachPoint")

			if scrapsAttachPoint then
				position = scrapsAttachPoint.Position
			else
				position = primaryPart.Position
			end
		else
			position = primaryPart.Position
		end

		local magnitude = (p.Position - position).Magnitude
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Position = position
		part.Parent = parent
		local v2 = canseetarget(instance, parent, p, part, magnitude)
		part:Destroy()

		if not v2 then
			return {
				Outcome = false,
				Reason = v and "You need line of sight with that Machine!" or "You need line of sight with that Toon!"
			}
		end

		local v3 = {
			Outcome = true,
			Reason = parent.Name
		}
		currentCooldown.Value = cooldown.Value
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local bindables = game.ServerStorage:FindFirstChild("Bindables")
		local removeCharacterAntiExploitModule = bindables and bindables:FindFirstChild("RemoveCharacterAntiExploitModule")

		if not removeCharacterAntiExploitModule then
			warn("[Scraps] anti-cheat bindable missing; grapple will run unexempted")
		end

		if removeCharacterAntiExploitModule then
			if not v then
				removeCharacterAntiExploitModule:Fire(parent, true)
			end

			removeCharacterAntiExploitModule:Fire(player, true)
		end

		local _, v4, _ = CFrame.lookAt(p.Position, position):ToOrientation()
		local cFrame = CFrame.new(p.Position.X, p.Position.Y, p.Position.Z) * CFrame.fromOrientation(0, v4, 0)
		TweenService:Create(instance.PrimaryPart, tweenInfo, {
			CFrame = cFrame
		}):Play()
		task.spawn(function()
			primaryPart2.Anchored = true
			local boolValue = Instance.new("BoolValue")
			boolValue.Name = "Invincible"
			boolValue.Parent = primaryPart2.Parent
			boolValue.Value = true
			Debris:AddItem(boolValue, 1)

			if not v then
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "Grabbed"
				boolValue2.Parent = primaryPart2.Parent
				boolValue2.Value = true
				Debris:AddItem(boolValue2, 1.05)
			end

			local boolValue2 = Instance.new("BoolValue")
			boolValue2.Name = "NoDecode"
			boolValue2.Parent = primaryPart2.Parent
			boolValue2.Value = true
			Debris:AddItem(boolValue2, 1.2)
			task.delay(1, function()
				if primaryPart2 and primaryPart2.Parent ~= nil and decoding.Value == nil then
					primaryPart2.Anchored = false
				end
			end)
			local _ = primaryPart.CFrame
			task.spawn(function()
				if instance and instance.Parent ~= nil then
					instance.Grabbing.Value = true
					task.delay(1, function()
						instance.Grabbing.Value = false
					end)
					local scrapsToonGrab = ReplicatedStorage.Parts.RenderModules.ScrapsToonGrab
					ReplicatedStorage.Events.RenderObject:FireAllClients(scrapsToonGrab, { instance, parent })
				end
			end)
			task.wait(0.25)
			local magnitude2 = (p.Position - position).Magnitude
			local part2 = Instance.new("Part")
			part2.Transparency = 1
			part2.Anchored = true
			part2.CanCollide = false
			part2.Position = position
			part2.Parent = parent
			local v6 = canseetarget(instance, parent, p, part2, magnitude2)
			part2:Destroy()

			if not v6 then
				return {
					Outcome = false,
					Reason = v and "Line of sight with that Generator was lost!" or "Line of sight with that Toon was lost!"
				}
			end

			if not primaryPart2 or primaryPart2.Parent == nil then
				return
			end

			primaryPart2.Anchored = true
			local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if primaryPart2 and primaryPart2.Parent ~= nil then
				local _, v7, _ = CFrame.lookAt(p.Position, position):ToOrientation()
				local cFrame2 = CFrame.new(position.X, position.Y, position.Z) * CFrame.fromOrientation(0, v7, 0)

				if decoding and decoding.Parent ~= nil and decoding.Value ~= nil and player then
					decoding.Value:WaitForChild("Stats"):WaitForChild("ForceStop"):Fire(player)
					ReplicatedStorage.Events.StopInteracting:FireClient(player)
				end

				local tween = TweenService:Create(primaryPart2, tweenInfo2, {
					CFrame = cFrame2
				})
				tween:Play()
				tween.Completed:Wait()

				if primaryPart2 and primaryPart2.Parent ~= nil then
					primaryPart2.Anchored = false
				end
			end

			if not v then
				local removeCharacterAntiExploitModule2 = game.ServerStorage:WaitForChild("Bindables"):WaitForChild("RemoveCharacterAntiExploitModule")
				removeCharacterAntiExploitModule2:Fire(parent, false)
				removeCharacterAntiExploitModule2:Fire(player, false)
			end
		end)
		task.spawn(function()
			local lastTime = os.clock()

			while instance do
				currentCooldown.Value -= 0.1

				if currentCooldown.Value <= 0 then
					currentCooldown.Value = 0
					break
				else
					local v7 = 0.1 - (os.clock() - lastTime) % 0.1
					task.wait(v7)
				end
			end
		end)
		return v3
	end
}
local nows = {}
Scraps.PlayFunctions = {
	RPAbility = {
		Cooldown = 10,
		DisplayName = Scraps.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local track = humanoid:LoadAnimation((animations:WaitForChild("Ability")))

			local function dothing()
				for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
					if v.Name ~= "Ability" then
						continue
					end

					v:Stop()
					v:Destroy()
				end

				track:Play()
			end

			if nows[p] then
				if p2 < tick() - nows[p] then
					nows[p] = tick()
					dothing()
				end
			else
				nows[p] = tick()
				dothing()
			end
		end
	}
}
return Scraps