local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local _ = data.tocf
	local _ = game.Players.LocalPlayer
	local root = data.Root

	if data.side % 2 == 0 then
		local clone = ReplicatedStorage.Chest.Etc.Cyborg.prism_sword:Clone()
		clone.PrimaryPart.Anchored = false
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		local cFrame = root.CFrame
		task.spawn(function()
			wait()
			local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.prism_slash:Clone()
			_G.PU:Dust(clone2, 1.25)
			clone2.Parent = workspace.Effects
			clone2.CFrame = cFrame * CFrame.new(0, 0, -9) * CFrame.Angles(0, 3.141592653589793, 0)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11981979631",
				PlaybackSpeed = 1.1,
				Volume = 0.75
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			local Animate = require(clone2.Animate)
			Animate()
			TweenService:Create(
				clone2.PointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 0
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local clone3 = ReplicatedStorage.Chest.Etc.Cyborg.slashdust:Clone()
			clone3.Parent = workspace.Effects
			clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -9))
			_G.PU:Dust(clone3, 1)
			PeodizService.ForLoop({
				Step = 5,
				WaitTime = 0.15
			}, function(p)
				clone3["red" .. math.floor(p * 5)].shard:Emit(5)
			end)
		end)
		local weld = Instance.new("Weld")
		weld.Parent = root
		weld.Part0 = root
		weld.Part1 = clone.PrimaryPart
		weld.C0 = CFrame.new(0, 0, -6.5) * CFrame.Angles(0, 1.5707963267948966, 0)
		_G.PU:Dust(weld, 1)
		clone.AnimationController:LoadAnimation(clone.Animation):Play()
		clone.sword.Color = Color3.fromRGB(77, 117, 165)
		clone.sword.Transparency = 0
		TweenService:Create(clone.sword, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(184, 82, 191)
		}):Play()
		wait(0.25)
		clone.sword.Trail.Enabled = false
		TweenService:Create(clone.sword, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	else
		local clone = ReplicatedStorage.Chest.Etc.Cyborg.prism_sword:Clone()
		clone.PrimaryPart.Anchored = false
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		local cFrame = root.CFrame
		task.spawn(function()
			wait()
			local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.prism_slash:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = cFrame * CFrame.new(0, 0, -9) * CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.Angles(
				3.141592653589793,
				0,
				0
			)
			local Animate = require(clone2.Animate)
			Animate()
			TweenService:Create(
				clone2.PointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Range = 0
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone2, 1.25)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11981979631",
				PlaybackSpeed = 1.1,
				Volume = 0.75
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			local clone3 = ReplicatedStorage.Chest.Etc.Cyborg.slashdust:Clone()
			clone3.Parent = workspace.Effects
			clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -9))
			_G.PU:Dust(clone3, 1)

			for i = 5, 1, -1 do
				clone3["red" .. i].shard:Emit(5)
				task.wait(0.015)
			end
		end)
		local weld = Instance.new("Weld")
		weld.Parent = root
		weld.Part0 = root
		weld.Part1 = clone.PrimaryPart
		weld.C0 = CFrame.new(0, 0, -6.5) * CFrame.Angles(0, -1.5707963267948966, 0)
		_G.PU:Dust(weld, 1)
		clone.AnimationController:LoadAnimation(clone.Animation2):Play()
		clone.sword.Color = Color3.fromRGB(77, 117, 165)
		clone.sword.Transparency = 0
		TweenService:Create(clone.sword, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(184, 82, 191)
		}):Play()
		wait(0.25)
		clone.sword.Trail.Enabled = false
		TweenService:Create(clone.sword, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end
end