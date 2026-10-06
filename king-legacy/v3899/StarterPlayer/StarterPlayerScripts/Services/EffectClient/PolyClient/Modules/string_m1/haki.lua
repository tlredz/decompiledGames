local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
game:GetService("TweenService")

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function quadraticBezier(p, p2, p3, p4)
	local lerped = lerp(p2, p3, p)
	local lerped2 = lerp(p3, p4, p)
	return (lerp(lerped, lerped2, p))
end

return function(data)
	local localPlayer = game.Players.LocalPlayer
	local _ = data.tocf
	local _ = data.fromcf

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

	local tocf = data.tocf
	local fromcf = data.fromcf
	localshake("SmallestBump") -- equivalent call inferred; original call site unknown
	local color = Color3.fromRGB(0, 0, 0)
	task.spawn(function()
		local fromcf2 = fromcf
		local cframe = CFrame.new(fromcf2.p, tocf.p)
		local magnitude = (fromcf2.p - tocf.p).magnitude
		local v2 = cframe * CFrame.Angles(0, 0, 6.283185307179586 * math.random()) * CFrame.new(
			0,
			math.random(15, 20),
			-magnitude / 2
		)
		local step = math.floor(magnitude / 8) + 1
		local v4 = {}

		for i = 1, step + 1 do
			v4[#v4 + 1] = quadraticBezier(i / step, fromcf2.p, v2.p, tocf.p)
		end

		local clone = replicatedStorage.Chest.FruitEffect.String.awake.m1haki.core:Clone()
		clone.Parent = workspace.Effects
		clone.Size = createVector(0, 2, 0)
		clone.CFrame = CFrame.new(cframe.p, quadraticBezier(1 / step, fromcf2.p, v2.p, tocf.p)) * CFrame.new(0, 0, -1.5) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		_G.PU:Dust(clone, 0.5)
		clone.Attachment.flare.Color = ColorSequence.new(color)
		clone.Attachment.ring.Color = ColorSequence.new(color)
		clone.Attachment.flare:Emit(1)
		clone.Attachment.ring:Emit(1)
		game.TweenService:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		game.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(18, 4, 18)
		}):Play()
		task.spawn(function()
			wait(0.25)
			game.TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
		end)
		PeodizService.ForLoop({
			Step = step
		}, function(p)
			local v5 = math.floor(p * step)
			local v6 = 12 - v5 * 10 / step
			local clone2 = replicatedStorage.Chest.FruitEffect.String.awake.m1haki.body:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = CFrame.new(v4[v5], v4[v5 + 1]) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			)
			clone2.Size = Vector3.new(4, (v4[v5] - v4[v5 + 1]).magnitude + 2, 4)
			_G.PU:Dust(clone2, 0.5)
			game.TweenService:Create(
				clone2,
				TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				}
			):Play()
			game.TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(v6, (v4[v5] - v4[v5 + 1]).magnitude + 2, v6)
			}):Play()
			task.spawn(function()
				wait(0.25)
				game.TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new(0, (v4[v5] - v4[v5 + 1]).magnitude + 2, 0),
					Transparency = 1
				}):Play()
			end)
		end)
		local clone2 = replicatedStorage.Chest.FruitEffect.String.awake.m1haki.exp:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = tocf
		_G.PU:Dust(clone2, 0.8)
		clone2.Attachment.spark2.Color = ColorSequence.new(color)
		clone2.Attachment.shards1.Color = ColorSequence.new(color)
		local v5 = 70
		local p = tocf.p
		local v6 = "SmallBump"
		task.spawn(function()
			v5 = v5 or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v5 then
				_G.shake(v6)
			end
		end)

		for _, emitter in pairs(clone2.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end)
end