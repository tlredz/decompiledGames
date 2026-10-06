local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf2.p).Magnitude then
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

	localshake("SmallBump") -- equivalent call inferred; original call site unknown
	local cf = data.cf
	local clone = replicatedStorage.Chest.MeleeEffect.WaterStyle.V2.C.ball:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	_G.PU:Dust(clone, 1)
	task.spawn(function()
		clone.Size = createVector(50, 50, 50)
		clone.ParticleEmitter:Emit(2)
		clone.sw1:Emit(2)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") * 2)
			end
		end
	end)
end