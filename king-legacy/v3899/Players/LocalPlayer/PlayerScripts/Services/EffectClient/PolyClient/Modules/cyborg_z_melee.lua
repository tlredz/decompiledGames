local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local tocf = data.tocf
	local localPlayer = game.Players.LocalPlayer

	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr and (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	PeodizService.ForLoop({
		Step = 12,
		WaitTime = 0.05
	}, function(p)
		local v = math.floor(p * 12)
		local v2 = v % 2 == 1 and "blue_slash" or "pink_slash"
		local clone = ReplicatedStorage.Chest.Etc.Cyborg[v2]:Clone()
		clone.CFrame = tocf * CFrame.new(math.random(-5, 5), 0, -v * 12) * CFrame.Angles(
			math.rad((math.random(-10, 10))),
			6.283185307179586 * math.random(),
			(math.rad((math.random(-10, 10))))
		)
		clone.Parent = workspace.Effects
		clone.Mesh.Scale = createVector(0.3395, 0.1687, 0.3395)
		clone.Size = createVector(19.293749, 1.5595999, 17.334799)
		clone.flare2:Emit(5)
		clone.Attachment.star:Emit(1)
		clone.Attachment.ImpactWind:Emit(3)
		clone.Attachment.WindSlash:Emit(3)
		_G.PU:Dust(clone, 1.5)

		if v % 2 == 1 then
			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 50,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://6313682232",
				Volume = 0.5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 2)
			sound.Parent = clone
			sound:Play()
		end

		local v3 = 40
		local p2 = clone.CFrame.p
		local v4 = "SmallerBump"
		task.spawn(function()
			v3 = v3 or 100

			if localPlayer == data.plr and (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v3 then
				_G.shake(v4)
			end
		end)
		TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Range = 0
			}
		):Play()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
		}):Play()
		TweenService:Create(clone.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = createVector(1.2125001, 0.60249996, 1.2125001)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(68.90625, 5.5699997, 61.91)
		}):Play()
		task.spawn(function()
			wait(0.1)
			clone.beam:Emit(2)
			wait(0.1)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
		end)
		local Animate = require(clone.Animate)
		Animate()
	end)
end