local _ = game.Players.LocalPlayer
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local dash = FX:WaitForChild("Dragon2").Hybrid.Dash
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

for _, child in pairs(dash:GetChildren()) do
	Util.ResizeModel(child, 0.85, child.Position)
end

return function(data)
	local root = data.Root
	local player = data.player
	local folder = Instance.new("Folder")
	Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DragonFruitVFXColor")
	Util.Debris:AddItem(folder, 2.5)
	local cframe = CFrame.new(data.Origin, data.Origin + data.Direction)
	task.spawn(function()
		task.wait(0.1)

		for i = 1, 2 do
			local v = 3.5
			local v2 = 0.25
			local startBeam = MovementAssets.cloneStartBeam(dash.StartBeam)
			startBeam.CFrame = cframe
			Util.SetParentOverrideWithColor(startBeam, folder, player, "DragonFruitVFXColor")

			if i == 2 then
				v2 = 0.35
				TweenService:Create(startBeam, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = startBeam.CFrame * CFrame.new(0, 0, 5)
				}):Play()
				v = 7
			else
				TweenService:Create(startBeam, TweenInfo.new(v2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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
					local v3 = descendant
					coroutine.wrap(function()
						TweenService:Create(v3, TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v3.CurveSize0 * v,
							CurveSize1 = v3.CurveSize1 * v,
							Width0 = v3.Width0 / 2,
							Width1 = v3.Width1 / 2
						}):Play()
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
	local clone = dash.StartImpact:Clone()
	clone.CFrame = cframe
	Util.SetParentOverrideWithColor(clone, folder, player, "DragonFruitVFXColor")
	Util.Sound:Play("Hybrid_Flame_Dash_02", root, nil, math.random(10, 12) / 10)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	local dash2 = MovementAssets.cloneDash(dash.Dash, cframe)
	Util.SetParentOverrideWithColor(dash2, folder, player, "DragonFruitVFXColor")

	for _, effect in pairs(dash2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	task.defer(function()
		local lastTime = tick()

		while tick() - lastTime < 0.25 do
			local velocity = root.Velocity

			if velocity.Magnitude < 0.1 then
				velocity = cframe.LookVector
			end

			dash2:PivotTo(CFrame.new(root.Position, root.Position + velocity))
			task.wait()
		end
	end)
	task.delay(0.225, function()
		for _, effect in pairs(dash2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end
	end)
end