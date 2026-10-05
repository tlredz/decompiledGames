local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game.ReplicatedStorage:FindFirstChild("editData")
local Vee = {}
Vee.Name = "Vee"
Vee.Icon = "rbxassetid://17288109998"
Vee.VoteIcon = "rbxassetid://17288110108"
Vee.Health = 2
Vee.MainCharacter = true
Vee.WalkSpeed = 12.5
Vee.RunSpeed = 22.5
Vee.DecodeSpeed = 1.5
Vee.SkillCheckChance = 25
Vee.SkillCheckValue = 2.5
Vee.Stealth = 5
Vee.Stamina = 150
Vee.BoundarySize = 200
Vee.LightToon = true
Vee.DecodeRank = 5
Vee.SpeedRank = 2
Vee.StaminaRank = 3
Vee.StealthRank = 2
Vee.SkillCheckRank = 4
Vee.Ability1Name = "Mic Check"
Vee.Ability1Type = "Active"
Vee.Ability1Description = "This Toon can highlight all Twisteds and Machines on the Floor for 5 seconds. Has a Cooldown of 50."
Vee.Ability2Name = "Camera Hijack"
Vee.Ability2Type = "Passive"
Vee.Ability2Description = "This Toon will have the nearest 2 uncompleted Machines highlighted for them."
Vee.ActiveAbility = true
Vee.AbilityIcon = "rbxassetid://17701202860"
Vee.AbilityCooldown = 50
Vee.CustomAbilitySound = script.Sound

function Vee.HurtAnimation(instance)
	local config = instance:WaitForChild("Config")
	instance.Head.TextureID = config.HurtTexture.Texture

	if instance.Head:FindFirstChild("Head") then
		instance.Head.Head.TextureID = config.HurtTexture.Texture
	end

	task.wait(2)

	if instance.Parent ~= nil then
		instance.Head.TextureID = config.NormalTexture.Texture

		if instance.Head:FindFirstChild("Head") then
			instance.Head.Head.TextureID = config.NormalTexture.Texture
		end
	end
end

function Vee.ClientAbility(_, instance, p)
	if not (instance and instance.PrimaryPart) then
		return
	end

	local v = p and 5 or 1
	local tweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
	local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

	if model then
		local generators = model:FindFirstChild("Generators")

		if not generators then
			return
		end

		local children = generators:GetChildren()
		local v2 = {}
		local v3 = {}

		for _, v4 in pairs(children) do
			if not (v4:GetChildren()[1] and v4.PrimaryPart) then
				continue
			end

			local stats = v4:FindFirstChild("Stats")
			local completed = stats and stats:FindFirstChild("Completed")

			if not (completed and completed.Value ~= true) then
				continue
			end

			local magnitude = (instance.PrimaryPart.Position - v4.PrimaryPart.Position).Magnitude
			table.insert(v2, v4)
			table.insert(v3, magnitude)
		end

		for i = 1, #v3 do
			for i2 = i + 1, #v3 do
				if not (v3[i] > v3[i2]) then
					continue
				end

				local v4 = v3[i2]
				local v5 = v3[i]
				v3[i] = v4
				v3[i2] = v5
				local v6 = v2[i2]
				local v7 = v2[i]
				v2[i] = v6
				v2[i2] = v7
			end
		end

		for i = 1, math.min(p and 999 or 2, #v2) do
			local parent = v2[i]

			if not parent then
				continue
			end

			local stats = parent:FindFirstChild("Stats")

			if not stats then
				continue
			end

			local activePlayer = stats:FindFirstChild("ActivePlayer")
			local parent2 = parent

			local function CreatePopUp()
				local clone = ReplicatedStorage.GUI.WarningIcon:Clone()
				clone.Size = UDim2.new(16, 0, 16, 0)
				clone.Frame.TextLabel.Text = "MACHINE"

				if activePlayer.Value == nil then
					clone.Frame.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 97)
					clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(100, 255, 97)
				else
					clone.Frame.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end

				clone.Adornee = parent2:FindFirstChild("GuiAttachPoint") or parent2.PrimaryPart
				clone.Parent = parent2
				TweenService:Create(clone.Frame.ImageLabel, tweenInfo, {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.TextLabel, tweenInfo, {
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone.Frame.TextLabel.UIStroke, tweenInfo, {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, v)
			end

			CreatePopUp()
			local highlight = Instance.new("Highlight")
			highlight.Parent = parent
			highlight.FillTransparency = 1

			if activePlayer.Value == nil then
				highlight.OutlineColor = Color3.fromRGB(100, 255, 97)
			else
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			end

			TweenService:Create(highlight, tweenInfo, {
				OutlineTransparency = 1
			}):Play()
			Debris:AddItem(highlight, v)
			task.wait()
		end
	end
end

function Vee.UseActiveAbility(_, instance, _)
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

	if not (workspace.CurrentRoom:FindFirstChildOfClass("Model") and workspace.Info.FloorActive.Value == true) then
		return {
			Outcome = false,
			Reason = "Can't use that Ability in the Elevator!"
		}
	end

	currentCooldown.Value = cooldown.Value
	game.ReplicatedStorage.Events.AnimateTower:FireAllClients(instance, "Ability")
	task.spawn(function()
		game.ReplicatedStorage.Events.ClientAbilityEvent:FireAllClients(script, instance, true)
		local model = workspace.CurrentRoom:FindFirstChildOfClass("Model")

		if model then
			local children = model:WaitForChild("Monsters"):GetChildren()
			local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)

			for _, parent in pairs(children) do
				if not parent:GetChildren()[1] or string.find(parent.Name, "Rodger") then
					continue
				end

				local highlight = Instance.new("Highlight")
				highlight.Parent = parent
				highlight.FillTransparency = 1
				highlight.FillColor = Color3.fromRGB(100, 255, 97)
				highlight.OutlineColor = Color3.fromRGB(100, 255, 97)
				TweenService:Create(highlight, tweenInfo, {
					OutlineTransparency = 1
				}):Play()
				Debris:AddItem(highlight, 5)
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
					clone.Frame.TextLabel.TextColor3 = Color3.fromRGB(100, 255, 97)
					clone.Frame.ImageLabel.ImageColor3 = Color3.fromRGB(100, 255, 97)
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
					Debris:AddItem(clone, 5)
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

return Vee