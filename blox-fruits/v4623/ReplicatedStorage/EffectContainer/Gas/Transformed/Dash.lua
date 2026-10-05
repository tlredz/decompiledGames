local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.Dash.Assets
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)

for _, child in pairs(assets.Phase1:GetChildren()) do
	Util.ResizeModel(child, 1.25, child.Position)
end

return function(data)
	local root = data.Root
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 3)
	local cFrame = CFrame.new(data.Origin, data.Origin + data.Direction) + createVector(-0, -10, -0)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	Util.Sound:Play("BF_GASFRUIT_TSFM_SkyjumpsDodge_02", root)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.spawn(function()
		task.wait(0.05)

		for i = 1, 2 do
			local v2 = 3
			local v3 = 0.25
			local clone2 = assets.Phase1.StartBeam:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = folder

			if i == 2 then
				v3 = 0.35
				TweenService:Create(clone2, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
				}):Play()
				v2 = 7
			else
				TweenService:Create(clone2, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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
					local v4 = descendant
					coroutine.wrap(function()
						TweenService:Create(v4, TweenInfo.new(v3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v4.CurveSize0 * v2,
							CurveSize1 = v4.CurveSize1 * v2,
							Width0 = v4.Width0 / 2,
							Width1 = v4.Width1 / 2
						}):Play()
						task.wait(v3 / 2)
						local tween = TweenService:Create(
							v4,
							TweenInfo.new(v3 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v4:Destroy()
					end)()
				elseif descendant:IsA("Attachment") then
					local tweenInfo = TweenInfo.new(v3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					local v6 = descendant.Position.X * v2
					local v7 = descendant.Position.Y * v2
					TweenService:Create(descendant, tweenInfo, {
						Position = Vector3.new(v6, v7, descendant.Position.Z * v2)
					}):Play()
				end
			end
		end
	end)
	local clone2 = assets.Phase1.Dash:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = folder
	clone2.Anchored = false
	local effectsByEffect = {}

	for _, effect in pairs(clone2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = true
			effectsByEffect[effect] = effect
		elseif effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	local _ = root.Position
	task.defer(function()
		local lastTime = tick()
		local now = 0

		while tick() - lastTime < 0.15 do
			local velocity = root.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cFrame.LookVector
			end

			if tick() - now > 0.025 then
				for _, v2 in pairs(effectsByEffect) do
					v2:Emit(1)
				end

				now = tick()
			end

			clone2.CFrame = CFrame.new(root.Position, root.Position + velocity * createVector(1, 0, 1)) + createVector(
				-0,
				-10,
				-0
			)
			clone.CFrame = clone2.CFrame
			task.wait()
		end

		effectsByEffect = nil
	end)
	task.wait(0.15)
	clone2.Anchored = true

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end