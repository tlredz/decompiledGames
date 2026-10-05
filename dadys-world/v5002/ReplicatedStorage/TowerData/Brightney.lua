local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
local Brightney = {}
Brightney.Name = "Brightney"
Brightney.Cost = 100
Brightney.Icon = "rbxassetid://17261224750"
Brightney.VoteIcon = "rbxassetid://17268608217"
Brightney.Health = 3
Brightney.MainCharacter = false
Brightney.WalkSpeed = 15
Brightney.RunSpeed = 25
Brightney.DecodeSpeed = 1.2
Brightney.SkillCheckChance = 25
Brightney.SkillCheckValue = 2
Brightney.Stealth = 0
Brightney.Stamina = 175
Brightney.BoundarySize = 150
Brightney.LightToon = true
Brightney.DecodeRank = 4
Brightney.SpeedRank = 3
Brightney.StaminaRank = 4
Brightney.StealthRank = 1
Brightney.SkillCheckRank = 3
Brightney.Ability1Name = "Night Light"
Brightney.Ability1Type = "Active"
Brightney.Ability1Description = "This Toon can shine lights on Twisteds to make them visible during Blackouts for 8 seconds. Has a Cooldown of 45."
Brightney.ActiveAbility = true
Brightney.AbilityIcon = "rbxassetid://17701467532"
Brightney.AbilityCooldown = 45
Brightney.CustomAbilitySound = script.Sound

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

function Brightney.UseActiveAbility(_, instance, _)
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
		game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Shine")
		local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

		if model then
			local children = model:WaitForChild("Monsters"):GetChildren()
			local tweenInfo = TweenInfo.new(8, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			for _, parent in pairs(children) do
				if not parent:GetChildren()[1] or string.find(parent.Name, "Rodger") then
					continue
				end

				local pointLight = Instance.new("PointLight")
				pointLight.Parent = parent.PrimaryPart
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
				local highlight = Instance.new("Highlight")
				highlight.Parent = parent
				highlight.FillTransparency = 1
				highlight.FillColor = Color3.fromRGB(255, 255, 255)
				TweenService:Create(highlight, tweenInfo, {
					OutlineTransparency = 1
				}):Play()
				Debris:AddItem(highlight, 8)
				local model2 = parent

				local function CreatePopUp()
					local clone = ReplicatedStorage.GUI.WarningIcon:Clone()

					if model2:IsA("Model") then
						if model2.Name == "AstroMonster" then
							clone.ExtentsOffset = createVector(0, 0.5, 0)
						else
							clone.ExtentsOffset = createVector(0, 1.5, 0)
						end
					end

					clone.Size = UDim2.new(16, 0, 16, 0)
					clone.Frame.TextLabel.Text = "TWISTED"
					clone.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
					clone.Parent = model2
					TweenService:Create(clone.Frame.ImageLabel, tweenInfo, {
						ImageTransparency = 1
					}):Play()
					TweenService:Create(clone.Frame.TextLabel, tweenInfo, {
						TextTransparency = 1
					}):Play()
					TweenService:Create(clone.Frame.TextLabel.UIStroke, tweenInfo, {
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 8)
				end

				CreatePopUp()
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

return Brightney