local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data, _)
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

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local cf = data.cf
	local v = {
		Color3.fromRGB(356, 1020, 152),
		Color3.fromRGB(1020, 148, 148),
		Color3.fromRGB(148, 452, 1020),
		Color3.fromRGB(1020, 192, 1008),
		Color3.fromRGB(1020, 1020, 172)
	}
	local v2 = {
		CFrame.Angles(0, 0, 0.5235987755982988) * CFrame.Angles(3.141592653589793, 1.3962634015954636, 0),
		CFrame.Angles(0, 0, -0.5235987755982988) * CFrame.Angles(0, -1.9198621771937625, 0),
		CFrame.Angles(0, 0, -0.8726646259971648) * CFrame.Angles(3.141592653589793, -0.5235987755982988, 0),
		CFrame.Angles(0, 0, 0.17453292519943295) * CFrame.Angles(0, -2.792526803190927, 0),
		CFrame.Angles(0, 0, 0.5235987755982988) * CFrame.Angles(3.141592653589793, 1.3962634015954636, 0)
	}
	local clone = replicatedStorage.Chest.SwordEffect.Avalon.slash:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf * v2[data.attack]
	_G.PU:Dust(clone, 1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://14007880762",
		PlaybackSpeed = 0.95,
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local weld = Instance.new("Weld")
	weld.Part0 = data.root
	weld.Part1 = clone
	weld.C0 = v2[data.attack]
	weld.Parent = data.root
	_G.PU:Dust(weld, 1)
	local Animate = require(clone.Animate)
	Animate()
	clone.Neon.Color3 = v[data.attack]
	TweenService:Create(clone.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Scale = createVector(0.21059999, 0.17809999, 0.1924)
	}):Play()
	TweenService:Create(weld, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		C0 = CFrame.new(0, 0, -2) * v2[data.attack] * CFrame.Angles(0, 3.455751918948773, 0)
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Color = v[data.attack]
	pointLight.Range = 25
	pointLight.Brightness = 1.5
	pointLight.Parent = clone
	TweenService:Create(pointLight, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0.5
	}):Play()
end