local createVector = vector.create
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local TweenService = game:GetService("TweenService")
local Sprout = {
	Health = 2,
	MainCharacter = true,
	WalkSpeed = 17.5,
	RunSpeed = 27.5,
	DecodeSpeed = 0.85,
	SkillCheckChance = 25,
	SkillCheckValue = 1.5,
	Stealth = 10,
	Stamina = 200,
	BoundarySize = 100,
	Name = "Sprout",
	Icon = "rbxassetid://99825183109033",
	VoteIcon = "rbxassetid://18551033828",
	Render = "rbxassetid://122458547118880",
	DecodeRank = 2,
	SpeedRank = 4,
	StaminaRank = 5,
	StealthRank = 3,
	SkillCheckRank = 2,
	Ability1Name = "Baked Sweets",
	Ability1Type = "Active",
	Ability1Description = "This Toon can heal a targeted Toon by 1 Heart at the cost of 100 Tapes. Has a cooldown of 100. Tape cost scales with the number of Sprouts in the round.",
	Ability2Name = "Overprotective",
	Ability2Type = "Passive",
	Ability2Description = "This Toon can see where all other alive Toons are, along with their current Health status.",
	ActiveAbility = true,
	PlayerAbility = true,
	PlayerRadius = 60,
	AbilityIcon = "rbxassetid://18555366888",
	AbilityCooldown = 100,
	AbilityCost = 100,
	AbilityDuration = 15,
	HealCooldown = true,
	CustomAbilitySound = {
		SoundId = "rbxassetid://18553104869",
		PlaybackSpeed = 1,
		Volume = 0.2
	},
	Cost = 4500,
	Requirement1 = { "Coin", 4500 },
	Requirement2 = { "Research", 100, "SproutMonster" },
	Requirement3 = { "Mastery", 100, "Cosmo" },
	MasterySkin = "VintageSprout",
	MasteryRequirements = {
		{
			Name = "ActiveAbilityActivate",
			Requirement = 50
		},
		{
			Name = "TravelDistance",
			Requirement = 150000
		},
		{
			Name = "PickUpItem",
			Requirement = 85
		},
		{
			Name = "SurviveFloorWithParty",
			Requirement = 15,
			Number = 5
		},
		{
			Name = "SurviveFloorWithToon",
			Requirement = 30,
			Tower = "Cosmo"
		},
		{
			Name = "SurviveFloor",
			Requirement = 75
		}
	},
	CreateTargetVisualExperimental = function(parent)
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.85
		highlight.FillColor = Color3.fromRGB(255, 255, 255)
		highlight.Enabled = true
		highlight.Parent = parent
		local clone = ReplicatedStorage.GUI.SproutTargetObject:Clone()
		clone.Parent = parent
		clone.Adornee = parent.PrimaryPart or parent:FindFirstChild("HumanoidRootPart") or parent
		clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(0, 255, 0)
		return highlight, clone
	end,
	CreateTargetVisual = function(instance, p)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local v

		if humanoidRootPart then
			v = humanoidRootPart:FindFirstChild("StickerOverride") or nil
		end

		local adornee = v or instance.PrimaryPart or humanoidRootPart or instance
		local v3, v4 = HighlightController:PlayHighlight(instance, "Target", {
			FillColor = Color3.fromRGB(255, 255, 255),
			FillTransparency = 0.85,
			OutlineColor = Color3.fromRGB(255, 255, 255),
			OutlineTransparency = 0,
			Billboard = {
				Label = p and "MACHINE" or "TARGET",
				Size = p and UDim2.new(16, 0, 16, 0) or UDim2.new(6, 0, 6, 0),
				Adornee = adornee
			},
			Priority = HighlightController.Priority.LOCAL_ABILITY
		})

		if not v4 then
			return v3, v4
		end

		v4.DistanceStep = 1
		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)

		local function onChange()
			v4:SetAttribute("Height", v4.CurrentDistance <= 30 and createVector(0, 3.2, 0) or createVector(0, 1, 0))
		end

		v4:GetAttributeChangedSignal("Height"):Connect(function()
			local height = v4:GetAttribute("Height") or createVector(0, 1, 0)
			TweenService:Create(v4, tweenInfo, {
				StudsOffset = height
			}):Play()
		end)
		v4:GetPropertyChangedSignal("CurrentDistance"):Connect(onChange)
		v4:SetAttribute("Height", v4.CurrentDistance <= 30 and createVector(0, 3.2, 0) or createVector(0, 1, 0))
		return v3, v4
	end,
	RightHandBone = "Sprout_rig_v002:R_hand",
	HurtAnimation = function(instance)
		local config = instance:WaitForChild("Config")
		local blinkingParts = instance:FindFirstChild("BlinkingParts")
		local v = {}

		if blinkingParts and #blinkingParts:GetChildren() > 0 then
			for _, objectValue in ipairs(blinkingParts:GetChildren()) do
				if not objectValue:IsA("ObjectValue") then
					continue
				end

				local value = objectValue.Value

				if not value then
					continue
				end

				table.insert(v, value)

				if objectValue.Value:FindFirstChildWhichIsA("MeshPart") then
					table.insert(v, objectValue.Value:FindFirstChildWhichIsA("MeshPart"))
				end

				for _, part in ipairs(v) do
					if part:IsA("BasePart") then
						part.TextureID = config.HurtTexture.Texture
					end
				end
			end
		else
			local v2 = {
				instance:FindFirstChild("Head"),
				instance:FindFirstChild("UpperTorso"),
				instance:FindFirstChild("EyeL"),
				instance:FindFirstChild("EyeR")
			}

			for _, part in pairs(v2) do
				if not (part and part:IsA("MeshPart")) then
					continue
				end

				table.insert(v, part)
				part.TextureID = config.HurtTexture.Texture
			end
		end

		task.wait(2)

		if instance.Parent ~= nil then
			for _, v2 in pairs(v) do
				v2.TextureID = config.NormalTexture.Texture
			end
		end
	end,
	ClientAbility = function(_, instance)
		local parts = ReplicatedStorage:WaitForChild("Parts")
		local inGamePlayers = workspace.InGamePlayers

		if inGamePlayers then
			local children = inGamePlayers:GetChildren()
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			for _, v in pairs(children) do
				if not v:GetChildren()[1] or v == instance or v:GetAttribute("GigiHoardProp") then
					continue
				end

				local v2 = v

				local function CreatePopUp()
					local humanoid = v2:FindFirstChild("Humanoid")

					if not humanoid then
						return
					end

					local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
					local humanoidRootPart2 = v2:FindFirstChild("HumanoidRootPart")

					if not (humanoidRootPart and humanoidRootPart2) then
						return
					end

					local clone = parts.HeartIconBillboards.SproutHeartIcon:Clone()
					clone.Name = "HeartIcon"
					local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
					clone.Size = UDim2.new(math.clamp(magnitude / 10, 2, 15), 0, math.clamp(magnitude / 10, 2, 15), 0)
					local maxHealth = humanoid.MaxHealth
					local health = humanoid.Health
					Color3.fromRGB(255, 0, 4)
					Color3.fromRGB(255, 126, 128)
					Color3.fromRGB(255, 255, 255)
					local heart3 = clone.Frame.Heart3
					local heart2 = clone.Frame.Heart2
					local heart1 = clone.Frame.Heart1

					if humanoid.MaxHealth == 2 then
						heart3 = humanoid.Health == 1 and heart1 or heart3
					elseif humanoid.MaxHealth >= 3 then
						if humanoid.Health == 1 and heart1 then
							heart3 = heart1
						elseif humanoid.Health < humanoid.MaxHealth then
							heart3 = heart2 or heart3
						end
					end

					heart3.Visible = true
					clone.Parent = humanoidRootPart2
					TweenService:Create(heart3, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					Debris:AddItem(clone, 1.5)
				end

				CreatePopUp()
				task.wait()
			end
		end
	end
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

function Sprout.UseActiveAbility(p, instance, p2, instance2)
	local ActionEvent = require(ReplicatedStorage2.SharedUtils.ActionEvent)
	instance:WaitForChild("Config")
	instance:WaitForChild("Decoding")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	local humanoid = instance:WaitForChild("Humanoid")
	local survivalPoints = workspace.Info.PlayerStats:FindFirstChild(instance.Name):WaitForChild("SurvivalPoints")
	local abilityCost = ability1:WaitForChild("AbilityCost")

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

	if workspace.Info.GameStats.HealCooldown.Value == true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability right now!"
		}
	end

	if survivalPoints.Value < abilityCost.Value then
		return {
			Outcome = false,
			Reason = "You don't have enough Tapes!"
		}
	end

	if not instance2 or instance2.Parent == nil then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	local humanoid2 = instance2:WaitForChild("Humanoid")

	if humanoid.Health <= 0 or humanoid2.Health <= 0 then
		return {
			Outcome = false,
			Reason = "No valid targets in range!"
		}
	end

	if humanoid2.Health >= humanoid2.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use Ability on Toons with full Health!"
		}
	end

	local primaryPart = instance2.PrimaryPart
	local _ = instance.PrimaryPart
	local _ = (p2.Position - primaryPart.Position).Magnitude
	local v = {
		Outcome = true,
		Reason = instance2.Name
	}
	currentCooldown.Value = cooldown.Value
	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")

	if instance and instance.Parent ~= nil then
		local sproutCupcake = ReplicatedStorage2.Parts.RenderModules.SproutCupcake
		ReplicatedStorage2.Events.RenderObject:FireAllClients(sproutCupcake, { instance, instance2 })
	end

	local success, result = pcall(function()
		if instance2 and humanoid2 then
			humanoid2.Health += 1

			if humanoid2.Health >= humanoid2.MaxHealth then
				humanoid2.Health = humanoid2.MaxHealth
			end

			ActionEvent:Record(instance2, "ReceiveActiveAbility", "Sprout", p and p.UserId)

			if survivalPoints.Value >= abilityCost.Value then
				survivalPoints.Value -= abilityCost.Value

				if survivalPoints.Value <= 0 then
					survivalPoints.Value = 0
				end
			end
		end
	end)

	if success then
		local function adjustcost()
			local children = workspace.InGamePlayers:GetChildren()
			local count = 0

			for _, v2 in pairs(children) do
				v2:WaitForChild("Config"):WaitForChild("ModuleName")
				local abilities = v2:WaitForChild("Abilities")

				if not (abilities:FindFirstChild("Ability1") and abilities:WaitForChild("Ability1"):FindFirstChild("HealCooldown")) then
					continue
				end

				count += 1
			end

			return (math.max(count, 1) - 1) * 10 + 15
		end

		local v2 = adjustcost()
		print(v2)

		if workspace.Info.GameStats.HealCooldown.Value ~= true then
			workspace.Info.GameStats.HealCooldown.Value = true
			task.delay(v2, function()
				workspace.Info.GameStats.HealCooldown.Value = false
			end)
		end
	else
		warn(result)
	end

	task.spawn(function()
		local lastTime = os.clock()

		while instance do
			currentCooldown.Value -= 0.1

			if currentCooldown.Value <= 0 then
				currentCooldown.Value = 0
				break
			else
				local v3 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v3)
			end
		end
	end)
	return v
end

local nows = {}
Sprout.PlayFunctions = {
	RPAbility = {
		Cooldown = 15,
		DisplayName = Sprout.Ability1Name .. " (%d sec)",
		Action = function(p, instance, p2)
			if not (p and instance) then
				return
			end

			local animations = instance:WaitForChild("Animations")
			local humanoid = instance:WaitForChild("Humanoid")
			local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
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
				local part = Instance.new("Part")
				part.Name = "HumanoidRootPart"
				part.Size = createVector(1, 1, 1)
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.Transparency = 1
				local model = Instance.new("Model")
				model.Parent = workspace
				part.Parent = model
				model.PrimaryPart = part
				model:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -12))
				local Debris2 = game:GetService("Debris")
				Debris2:AddItem(model, 5)

				if instance and instance.Parent ~= nil then
					local sproutCupcake = ReplicatedStorage2.Parts.RenderModules.SproutCupcake
					ReplicatedStorage2.Events.RenderObject:FireAllClients(sproutCupcake, { instance, model })
				end
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
return Sprout