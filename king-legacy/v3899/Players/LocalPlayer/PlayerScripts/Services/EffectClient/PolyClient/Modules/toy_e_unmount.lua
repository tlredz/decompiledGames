local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)

local function tween_beam_transparency(items, p, p2, p3, time)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	TweenService:Create(numberValue, p3, {
		Value = p2
	}):Play()
	PeodizService.new({
		Time = time
	}, function()
		for _, item in pairs(items) do
			item.Transparency = NumberSequence.new(numberValue.Value)
		end
	end)

	if numberValue then
		numberValue:Destroy()
	end
end

function bloomBlur()
	local blurEffect = Instance.new("BlurEffect", game.Lighting)
	blurEffect.Size = 0
	local bloomEffect = Instance.new("BloomEffect", game.Lighting)
	_G.PU:Dust(blurEffect, 0.2)
	_G.PU:Dust(bloomEffect, 0.2)
	TweenService:Create(blurEffect, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Size = 4
	}):Play()
	TweenService:Create(bloomEffect, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true, 0), {
		Intensity = 3,
		Size = 35,
		Threshold = 1
	}):Play()
end

return function(data)
	local cf = data.cf
	local _ = data.root
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
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

	local _ = data.char
	local _ = data.dinocolor
	local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_unmount:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	_G.PU:Dust(clone, 2)
	local pointLight = Instance.new("PointLight")
	pointLight.Parent = clone
	pointLight.Range = 40
	pointLight.Brightness = 1
	pointLight.Color = Color3.fromRGB(100, 255, 83)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	localshake({
		4.5,
		5,
		0,
		0.75
	}) -- equivalent call inferred; original call site unknown
	wait()
	TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0
	}):Play()
end