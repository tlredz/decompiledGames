local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local _ = Util.Sound
local _ = workspace.CurrentCamera
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").Dash.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(data)
	local player = data.Player
	local root = data.Root
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "PainFruitVFXColor")
	Util.Debris:AddItem(folder, 5)
	local stage = data.Stage

	if stage == 1 then
		local cframe = CFrame.lookAt(root.Position, root.Position + createVector(0, 5, 0))
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cframe
		Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		Util.Sound:Play("Awakened_Jump_0" .. tostring(math.random(1, 3)) .. "_V1", cframe.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			task.wait(0.05)

			for i = 1, 2 do
				local v = 3
				local v2 = 0.25
				local clone2 = assets.Phase1.StartBeam:Clone()
				clone2.CFrame = cframe
				Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor")

				if i == 2 then
					v2 = 0.35
					TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
					}):Play()
					v = 7
				else
					TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 8)
					}):Play()
				end

				if i == 2 then
					for _, descendant in pairs(clone2:GetDescendants()) do
						if descendant:IsA("Beam") then
							descendant.CurveSize0 /= 3
							descendant.CurveSize1 /= 3
							descendant.Width0 = 7
							descendant.Width1 = 7
						elseif descendant:IsA("Attachment") then
							descendant.Position = Vector3.new(
								descendant.Position.X / 3,
								descendant.Position.Y / 3,
								descendant.Position.Z / 3
							)
						end
					end
				end

				for _, descendant in pairs(clone2:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v3 = descendant
						coroutine.wrap(function()
							TweenService:Create(
								v3,
								TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v3.CurveSize0 * v,
									CurveSize1 = v3.CurveSize1 * v,
									Width0 = v3.Width0 / 2,
									Width1 = v3.Width1 / 2
								}
							):Play()
							task.wait(v2 / 2)
							local tween = TweenService:Create(
								v3,
								TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v3:Destroy()
						end)()
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v5 = descendant.Position.X * v
						local v6 = descendant.Position.Y * v
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v5, v6, descendant.Position.Z * v)
						}):Play()
					end
				end
			end
		end)
		local clone2 = assets.Phase1.Dash:Clone()
		clone2.CFrame = cframe
		Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor")
		clone2.Anchored = false
		clone2.Weld.Part1 = root
		local effectsByEffect = {}

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				effectsByEffect[effect] = effect
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		task.spawn(function()
			local lastTime = tick()

			repeat
				for _, v in pairs(effectsByEffect) do
					v:Emit(1)
				end

				task.wait(0.045)
			until tick() - lastTime >= 0.07500000000000001
		end)
		task.wait(0.1)
		clone2.Weld.Enabled = false
		clone2.Anchored = true

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	elseif stage == 2 then
		local cFrame = data.Direction == createVector(0, 0, 0) and root.CFrame or CFrame.new(
			root.Position,
			root.Position + data.Direction
		)
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "PainFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		Util.Sound:Play("Awakened_Dash_0" .. tostring(math.random(1, 3)) .. "_V1", cFrame.Position)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			task.wait(0.05)

			for i = 1, 2 do
				local v = 3
				local v2 = 0.25
				local clone2 = assets.Phase1.StartBeam:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor")

				if i == 2 then
					v2 = 0.35
					TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
					}):Play()
					v = 7
				else
					TweenService:Create(clone2, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 8)
					}):Play()
				end

				if i == 2 then
					for _, descendant in pairs(clone2:GetDescendants()) do
						if descendant:IsA("Beam") then
							descendant.CurveSize0 /= 3
							descendant.CurveSize1 /= 3
							descendant.Width0 = 7
							descendant.Width1 = 7
						elseif descendant:IsA("Attachment") then
							descendant.Position = Vector3.new(
								descendant.Position.X / 3,
								descendant.Position.Y / 3,
								descendant.Position.Z / 3
							)
						end
					end
				end

				for _, descendant in pairs(clone2:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v3 = descendant
						coroutine.wrap(function()
							TweenService:Create(
								v3,
								TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v3.CurveSize0 * v,
									CurveSize1 = v3.CurveSize1 * v,
									Width0 = v3.Width0 / 2,
									Width1 = v3.Width1 / 2
								}
							):Play()
							task.wait(v2 / 2)
							local tween = TweenService:Create(
								v3,
								TweenInfo.new(v2 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v3:Destroy()
						end)()
					elseif descendant:IsA("Attachment") then
						local tweenInfo = TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
						local v5 = descendant.Position.X * v
						local v6 = descendant.Position.Y * v
						TweenService:Create(descendant, tweenInfo, {
							Position = Vector3.new(v5, v6, descendant.Position.Z * v)
						}):Play()
					end
				end
			end
		end)
		local clone2 = assets.Phase1.Dash:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "PainFruitVFXColor")
		clone2.Anchored = false
		clone2.Weld.Part1 = root
		local effectsByEffect = {}

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				effectsByEffect[effect] = effect
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		task.spawn(function()
			local lastTime = tick()

			repeat
				for _, v in pairs(effectsByEffect) do
					v:Emit(1)
				end

				task.wait(0.045)
			until tick() - lastTime >= 0.1275
		end)
		task.wait(0.17)
		pcall(function()
			clone2.Weld.Enabled = false
			clone2.Anchored = true

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
	end
end