local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local sound = Instance.new("Sound", humanoidRootPart)
	sound.SoundId = "rbxassetid://6605151904"
	sound.MaxDistance = 600
	sound.Volume = 2.5
	sound.TimePosition = 0.4
	sound.Looped = true
	sound:Play()
	_G.PU:Dust(sound, 5)
	local lastTime = tick()
	tick()
	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.05
	}, function()
		if not (char:IsDescendantOf(workspace) and char:FindFirstChild("RapidKick")) then
			return true
		end

		local humanoidRootPart2 = char:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart2 then
			return true
		end

		if tick() - lastTime > 0.2 then
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8748164748",
				Volume = 1.75
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = humanoidRootPart2
			sound2:Play()
			lastTime = tick()
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 20 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallerBump")
		end

		local cFrame = humanoidRootPart2.CFrame

		for i = 1, 2 do
			local cframe = CFrame.Angles(math.rad((math.random(-10, 10))), math.rad((math.random(-10, 10))), 0)
			local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.leg:Clone()
			clone.Parent = workspace.Effects
			clone.Size = createVector(0, 0, 13.5)
			clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * cframe
			clone.Anchored = false
			_G.PU:Dust(clone, 0.5)
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(2.1875, 2.1875, 31.25)
			}):Play()
			local v = i
			task.spawn(function()
				if v == 1 then
					local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Shockwave:Clone()
					clone2.Size = createVector(2, 5, 5)
					clone2.Parent = workspace.Effects

					if tick() * 10 % 2 < 1 then
						clone2.Color = Color3.fromRGB(172, 121, 108)
					end

					local weld = Instance.new("Weld")
					weld.Parent = humanoidRootPart2
					weld.Part0 = humanoidRootPart2
					weld.Part1 = clone2
					weld.C0 = CFrame.new(0, 0, -30) * cframe * CFrame.Angles(0, 1.5707963267948966, 0)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						weld,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							C0 = weld.C0 * CFrame.new(-30, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
						}
					):Play()
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(
						clone2,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(2, 22, 22)
						}
					):Play()
					wait()
					local TweenService4 = game:GetService("TweenService")
					TweenService4:Create(
						clone2,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					local TweenService5 = game:GetService("TweenService")
					TweenService5:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0, 22, 22)
					}):Play()
					_G.PU:Dust(clone2, 0.5)
				end
			end)
			local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.FlameSpiral:Clone()
			clone2.Parent = workspace.Effects
			clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -30) * cframe)
			clone2.PrimaryPart.Anchored = false
			clone2.PrimaryPart.diable:Emit(3)
			clone2.PrimaryPart.Blast:Emit(3)
			task.spawn(function()
				local ModuleScript = require(clone2.ModuleScript)
				ModuleScript()
				_G.PU:Dust(clone2, 0.75)
			end)

			for _, part in pairs(clone2:GetChildren()) do
				if not (part:IsA("BasePart") and part ~= clone2.PrimaryPart) then
					continue
				end

				part.Anchored = false
				local weld = Instance.new("Weld")
				weld.Parent = humanoidRootPart2
				weld.Part0 = humanoidRootPart2
				weld.Part1 = part
				weld.C0 = part.CFrame:Inverse() * clone2.PrimaryPart.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
				weld.C0 *= CFrame.new(10, 0, 0)
				_G.PU:Dust(weld, 0.75)
				TweenService:Create(weld, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					C0 = weld.C0 * CFrame.new(40, 0, 0)
				}):Play()
			end

			local weld = Instance.new("Weld")
			weld.Parent = humanoidRootPart2
			weld.Part0 = humanoidRootPart2
			weld.Part1 = clone2.PrimaryPart
			weld.C0 = CFrame.new(0, 0, -30) * cframe
			_G.PU:Dust(weld, 0.75)
			local weld2 = Instance.new("Weld")
			weld2.Parent = humanoidRootPart2
			weld2.Part0 = humanoidRootPart2
			weld2.Part1 = clone
			weld2.C0 = CFrame.Angles(0, 3.141592653589793, 0) * cframe
			_G.PU:Dust(weld2, 1)
			TweenService:Create(weld2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C0 = weld2.C0 * CFrame.new(0, 0, 40)
			}):Play()
			local pointLight = clone.PointLight
			TweenService:Create(
				pointLight,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0,
					Range = pointLight.Range / 2
				}
			):Play()
			task.spawn(function()
				wait(0.1)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end
	end)
	sound:Destroy()
end