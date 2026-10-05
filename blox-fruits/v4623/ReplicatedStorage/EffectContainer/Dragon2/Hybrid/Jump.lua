local createVector = vector.create
local _ = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local jump = FX:WaitForChild("Dragon2").Hybrid.Jump
local Util = require(game.ReplicatedStorage.Util)
local MovementAssets = require(script.Parent.Parent.MovementAssets)
local _WorldOrigin = workspace._WorldOrigin

local function DeleteImpactAfterDuration(folder)
	local v = 0

	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local max = emitter.Lifetime.Max
		v = math.max(v, max)
	end

	task.spawn(function()
		task.wait(v)
		folder:Destroy()
	end)
end

for _, child in pairs(jump:GetChildren()) do
	Util.ResizeModel(child, 0.75, child.Position)
end

return function(data)
	local root = data.Root
	local player = data.player
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder, 3)
	local cFrame = CFrame.new(data.Origin, data.Origin + root.CFrame.LookVector * createVector(1, 0, 1)) * CFrame.Angles(
		1.5707963267948966,
		0,
		0
	)
	task.spawn(function()
		task.wait(0.1)

		for i = 1, 2 do
			local v2 = 3.5
			local v3 = 0.25
			local startBeam = MovementAssets.cloneStartBeam(jump.StartBeam)
			startBeam.CFrame = cFrame
			Util.SetParentOverrideWithColor(startBeam, folder, player, "DragonFruitVFXColor")

			if i == 2 then
				v3 = 0.35
				TweenService:Create(startBeam, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = startBeam.CFrame * CFrame.new(0, 0, 5)
				}):Play()
				v2 = 7
			else
				TweenService:Create(startBeam, TweenInfo.new(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = startBeam.CFrame * CFrame.new(0, 0, 8)
				}):Play()
			end

			if i == 2 then
				for _, descendant in pairs(startBeam:GetDescendants()) do
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

			for _, descendant in pairs(startBeam:GetDescendants()) do
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
	local clone = jump.StartImpact:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	Util.Sound:Play("Hybrid_Flame_Sky_Jump_01", root, nil, math.random(10, 12) / 10)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local dash = MovementAssets.cloneDash(jump.Dash, cFrame)
	Util.SetParentOverrideWithColor(dash, folder, player, "DragonFruitVFXColor")

	for _, effect in pairs(dash:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	task.defer(function()
		local lastTime = tick()

		while tick() - lastTime < 0.15 do
			local velocity = root.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cFrame.LookVector
			end

			dash:PivotTo(CFrame.new(root.Position, root.Position + velocity))
			task.wait()
		end
	end)
	task.delay(0.135, function()
		for _, effect in pairs(dash:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
end