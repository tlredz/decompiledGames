local createVector = vector.create
local _ = game.Players.LocalPlayer
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Gas").Transformed.Jump.Assets
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)

for _, child in pairs(assets.Phase1:GetChildren()) do
	Util.ResizeModel(child, 1.5, child.Position)
end

return function(p)
	local _ = p.Root
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 3)
	local v = p.Origin - createVector(0, 17.5, 0)
	local cFrame = CFrame.new(v) * CFrame.Angles(1.5707963267948966, 0, 0)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = cFrame
	clone.Parent = folder
	Util.Sound:Play("BF_GASFRUIT_TSFM_Skyjumps_02")

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end

	task.spawn(function()
		task.wait(0.05)

		for i = 1, 2 do
			local v3 = 3
			local v4 = 0.25
			local clone2 = assets.Phase1.StartBeam:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = folder

			if i == 2 then
				v4 = 0.35
				TweenService:Create(clone2, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
				}):Play()
				v3 = 7
			else
				TweenService:Create(clone2, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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
					local v5 = descendant
					coroutine.wrap(function()
						TweenService:Create(v5, TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							CurveSize0 = v5.CurveSize0 * v3,
							CurveSize1 = v5.CurveSize1 * v3,
							Width0 = v5.Width0 / 2,
							Width1 = v5.Width1 / 2
						}):Play()
						task.wait(v4 / 2)
						local tween = TweenService:Create(
							v5,
							TweenInfo.new(v4 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween:Play()
						tween.Completed:Wait()
						v5:Destroy()
					end)()
				elseif descendant:IsA("Attachment") then
					local tweenInfo = TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					local v7 = descendant.Position.X * v3
					local v8 = descendant.Position.Y * v3
					TweenService:Create(descendant, tweenInfo, {
						Position = Vector3.new(v7, v8, descendant.Position.Z * v3)
					}):Play()
				end
			end
		end
	end)
end