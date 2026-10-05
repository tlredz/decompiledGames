local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local Brightney = {
	Name = "Brightney",
	Icon = "rbxassetid://17261224750",
	VoteIcon = "rbxassetid://17268608217",
	Render = "rbxassetid://112344915894918",
	Health = 3,
	MainCharacter = false,
	WalkSpeed = 15,
	RunSpeed = 25,
	DecodeSpeed = 1.2,
	SkillCheckChance = 25,
	SkillCheckValue = 2,
	Stealth = 0,
	Stamina = 175,
	BoundarySize = 150,
	LightToon = true,
	DecodeRank = 4,
	SpeedRank = 3,
	StaminaRank = 4,
	StealthRank = 1,
	SkillCheckRank = 3,
	Ability1Name = "Night Light",
	Ability1Type = "Active",
	Ability1Description = "This Toon can shine lights on Twisteds to make them visible during Blackouts for 8 seconds. Has a Cooldown of 45.",
	ActiveAbility = true,
	AbilityIcon = "rbxassetid://17701467532",
	AbilityCooldown = 45,
	CustomAbilitySound = {
		SoundId = "rbxassetid://6691605753",
		PlaybackSpeed = 1,
		Volume = 0.4
	},
	MasterySkin = "VintageBrightney",
	Cost = 1250
}
Brightney.Requirement1 = { "Coin", Brightney.Cost }
Brightney.Requirement2 = { "BlackOut", 5 }
Brightney.MasteryRequirements = {
	{
		Name = "BlackOut",
		Requirement = 15
	},
	{
		Name = "ActiveAbilityActivate",
		Requirement = 50
	},
	{
		Name = "TravelDistance",
		Requirement = 80000
	},
	{
		Name = "CompleteGenerator",
		Requirement = 50
	},
	{
		Name = "PickUpItem",
		Requirement = 60
	},
	{
		Name = "UseItem",
		Requirement = 60
	}
}
Brightney.RightHandBone = "R_hand"

function Brightney.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.Head.TextureID = config.HurtTexture.Texture
	task.wait(2)

	if instance.Parent ~= nil then
		instance.Head.TextureID = config.NormalTexture.Texture
	end
end

function Brightney.ClientAbility(_, instance)
	if not (instance and instance.PrimaryPart) then
		return
	end

	if workspace.CurrentRoom:FindFirstChildOfClass("Model") then
		local part = Instance.new("Part")
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
		part.Parent = workspace
		part.Name = "SniffRadius"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Color = Color3.fromRGB(255, 255, 255)
		part.CastShadow = false
		part.CanTouch = false
		part.Material = Enum.Material.ForceField
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(0, 0, 0)
		part.CFrame = instance.PrimaryPart.CFrame
		Debris:AddItem(part, 5)
		TweenService:Create(part, tweenInfo, {
			Size = createVector(250, 250, 250),
			Transparency = 1
		}):Play()
	end
end

function Brightney.UseActiveAbility(origin, instance, _)
	instance:WaitForChild("Config")
	local ability1 = instance:WaitForChild("Abilities"):WaitForChild("Ability1")
	local cooldown = ability1:WaitForChild("Cooldown")
	local currentCooldown = ability1:WaitForChild("CurrentCooldown")
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("WalkSpeed")
	stats:WaitForChild("RunSpeed")
	instance:WaitForChild("Humanoid")

	if currentCooldown.Value > 0 then
		return {
			Outcome = false,
			Reason = "That Ability is on Cooldown!"
		}
	end

	if workspace.Info.BlackOut.Value ~= true then
		return {
			Outcome = false,
			Reason = "You can only use that Ability during blackouts!"
		}
	end

	if workspace.Info.FloorActive.Value ~= true then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	task.spawn(function()
		game.ReplicatedStorage.Events.ClientAbilityEvent:FireAllClients(script, instance)
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
		local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

		if model then
			local children = model:WaitForChild("Monsters"):GetChildren()
			local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			for _, v in pairs(children) do
				if not v:GetChildren()[1] or (string.find(v.Name, "Rodger") or v:GetAttribute("GigiHoardProp")) then
					continue
				end

				local pointLight = Instance.new("PointLight")
				pointLight.Parent = v.PrimaryPart
				pointLight.Range = 0
				pointLight.Enabled = true
				pointLight.Color = Color3.fromRGB(255, 255, 255)
				TweenService:Create(pointLight, tweenInfo2, {
					Range = 25
				}):Play()
				task.delay(0.26, function()
					TweenService:Create(pointLight, tweenInfo, {
						Color = Color3.fromRGB(0, 0, 0)
					}):Play()
					Debris:AddItem(pointLight, 8)
					task.wait()
				end)
				HighlightController:BroadcastHighlight(v, "Threat", {
					FillColor = Color3.fromRGB(255, 255, 255),
					FillTransparency = 1,
					OutlineColor = Color3.fromRGB(255, 255, 255),
					OutlineTransparency = 0,
					Decay = 8,
					Origin = origin,
					Billboard = {
						Label = "TWISTED",
						Size = UDim2.new(16, 0, 16, 0),
						ExtentsOffset = v.Name == "AstroMonster" and createVector(0, 0.5, 0) or createVector(0, 1.5, 0)
					}
				})
				task.wait()
			end
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
				local v2 = 0.1 - (os.clock() - lastTime) % 0.1
				task.wait(v2)
			end
		end
	end)
	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

local now = 0
Brightney.PlayFunctions = {
	RPAbility = {
		DisplayName = Brightney.Ability1Name,
		Action = function(p, instance, _)
			if not (p and instance) or tick() - now < 1 then
				return
			end

			now = tick()
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

			dothing()
		end
	}
}
return Brightney