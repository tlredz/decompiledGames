local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(player)
	local startCF = player.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	local v = (player.StartCF.Position - player.EndCF.Position).Magnitude / 4

	local function CloneCharacter()
		local model = Instance.new("Model")

		for _, part in pairs(player.Character:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local clone = part:Clone()

			for _, descendant in pairs(clone:GetDescendants()) do
				if not (descendant:IsA("Sound") or descendant:IsA("BillboardGui") or descendant:IsA("WeldConstraint") or descendant:IsA("Weld") or descendant:IsA("Motor6D") or descendant:IsA("Attachment") or descendant:IsA("Decal") or descendant:IsA("SurfaceAppearance") or descendant:IsA("BasePart")) then
					continue
				end

				descendant:Destroy()
			end

			clone.CastShadow = false
			clone.Material = "Neon"
			clone.BrickColor = BrickColor.new("Persimmon")
			clone.Transparency = 0.4
			clone.Anchored = true
			local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")

			if specialMesh then
				specialMesh.TextureId = ""
			end

			clone.Parent = model
		end

		if model:FindFirstChild("HumanoidRootPart") then
			model.PrimaryPart = model.HumanoidRootPart
		end

		return model
	end

	local model = Instance.new("Model")
	model.Name = "CharModel"
	model.Parent = workspace.Effects
	_G.PU:Dust(model, 4)
	PeodizService.ForLoop({
		Step = 3,
		WaitTime = player.Time / 3
	}, function(p)
		local v2 = math.floor(p * 3)
		local character = CloneCharacter()
		character.Parent = model
		character:SetPrimaryPartCFrame(player.StartCF * CFrame.new(0, 0, -v * v2))
		spawn(function()
			wait(0.5)

			for _, child in pairs(character:GetChildren()) do
				TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
					Transparency = 1
				}):Play()
			end
		end)
		_G.PU:Dust(character, 1.5)
		local v4 = v2 % 2 == 1 and 45 or -45
		local clone = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Particle1:Clone()
		_G.PU:Dust(clone, 1)
		clone.CFrame = player.StartCF * CFrame.new(0, 0, -v * v2)
		clone.Parent = workspace.Effects
		clone.Attachment.Bubble.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 5),
			NumberSequenceKeypoint.new(1, 20)
		})
		clone.Attachment.Bubble:Emit(1)
		clone.Attachment.Dust:Emit(math.random(20, 30))
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7498753440",
			Volume = 3,
			PlaybackSpeed = math.random(90, 110) / 100
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0),
			{
				Range = 15
			}
		):Play()
		local clone2 = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Slash:Clone()
		clone2.CFrame = player.StartCF * CFrame.new(0, 0, -v * v2) * CFrame.Angles(0, 0, -math.rad(v4)) * CFrame.Angles(
			0,
			math.rad(v4 * 3),
			0
		)
		clone2.Parent = workspace.Effects
		clone2.Attachment.Rays_Thick.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 5),
			NumberSequenceKeypoint.new(1, 25)
		})
		clone2.Attachment.Rays_Thick:Emit(math.random(2, 5))
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = player.StartCF * CFrame.new(0, 0, -v * v2) * CFrame.Angles(0, 0, -math.rad(v4)) * CFrame.Angles(
				0,
				-math.rad(v4 * 0.55),
				0
			)
		}):Play()
		TweenService:Create(clone2.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
			Scale = createVector(-10, 0.5, 10)
		}):Play()
		TweenService:Create(clone2.Back.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
			Scale = createVector(10, 0.5, 10)
		}):Play()
		_G.PU:Dust(clone2, 1)
		spawn(function()
			wait(0.25)

			if clone2:FindFirstChild("decal") then
				TweenService:Create(clone2.decal, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end

			if clone2:FindFirstChild("Back") and clone2.Back:FindFirstChild("decal") then
				TweenService:Create(clone2.Back.decal, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end
		end)
		spawn(function()
			wait(0.1)
			local clone3 = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Part:Clone()
			clone3.CFrame = player.StartCF * CFrame.new(0, 0, -v * v2 - 9) * CFrame.Angles(0, 0, (math.rad(v4)))
			clone3.Parent = workspace.Effects
			local v9 = math.random(20, 40)
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(0.75, v9, 0.75)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Color = Color3.fromRGB(255, 116, 111)
			}):Play()
			coroutine.wrap(function()
				wait(0.2)
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					Size = Vector3.new(0, v9 + 5, 0),
					Transparency = 1
				}):Play()
			end)()
			_G.PU:Dust(clone3, 2)
		end)
	end)
end