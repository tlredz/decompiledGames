local createVector = vector.create
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local RunService = game:GetService("RunService")

local function renderlerp(instance, p, instance2, p2, p3, p4, p5, p6, instance3)
	local renderSteppedConnection = nil
	local total = 0
	local v = false
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		if instance and p and instance2 then
			if p6 == true and instance3 then
				if instance3.Parent == nil then
					v = true
					renderSteppedConnection:Disconnect()
				else
					local _, v2, _ = CFrame.lookAt(instance3.PrimaryPart.Position, instance2.CFrame.Position):ToOrientation()
					local X = instance2.CFrame.Position.X
					local Y = instance2.CFrame.Position.Y
					local Z = instance2.CFrame.Position.Z
					local cFrame = instance3.PrimaryPart.CFrame
					local v3 = CFrame.new(X, Y, Z) * CFrame.fromOrientation(0, v2, 0)
					total += dt
					local v4 = total / 0.5
					local value = TweenService:GetValue(math.min(total / 0.5, 1), p3, p4)
					local lerped = cFrame.Position:Lerp(v3.Position, value)
					local lerped2 = cFrame.Rotation:Lerp(v3.Rotation, value)
					instance:PivotTo(CFrame.new(lerped) * lerped2)

					if v4 >= 1 then
						v = true
						renderSteppedConnection:Disconnect()
					end
				end
			else
				total += dt
				local v2 = total / p2
				local value = TweenService:GetValue(math.min(total / p2, 1), p3, p4)
				local lerped = p.Position:Lerp(instance2.Position, value)
				local lerped2 = p.Rotation:Lerp(instance2.Rotation, value)
				instance:PivotTo(CFrame.new(lerped) * lerped2)

				if v2 >= 1 then
					v = true
					renderSteppedConnection:Disconnect()
				end
			end
		else
			v = true
			renderSteppedConnection:Disconnect()
		end
	end)

	if p5 then
		while not v do
			task.wait()
		end
	end
end

return {
	RenderObject = function(list)
		local v = list[1]
		local humanoid = v:WaitForChild("Humanoid")
		local humanoidRootPart = v:WaitForChild("HumanoidRootPart")
		local Players = game:GetService("Players")

		if v ~= Players.LocalPlayer.Character then
			local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
			local tower = TowerLUT:GetTower("Tisha")

			if tower then
				local module = require(tower)
				tower = module.CustomAbilitySound
			end

			if tower then
				Audio:Play(tower.SoundId or tower, {
					PlaybackSpeed = tower.PlaybackSpeed or 1,
					Volume = tower.Volume or 1,
					Parent = humanoidRootPart
				})
			end
		end

		local skin = v:WaitForChild("Stats"):WaitForChild("Skin")
		local v2 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
		local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
		local skinModuleFolder = TowerLUT:GetSkinModuleFolder()

		if skin.Value == "Default" then
			local clone = ReplicatedStorage.Parts.TishaPoof:Clone()
			TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false)
			clone.Parent = workspace
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CastShadow = false
			clone.CanTouch = false
			clone.Size = createVector(0, 0.25, 0)
			clone.Position = v.PrimaryPart.Position + Vector3.new(0, -v2, 0)
			task.spawn(function()
				local featherStick = v:FindFirstChild("FeatherStick")
				local particleEmitter = featherStick and featherStick:FindFirstChild("ParticleEmitter")

				if particleEmitter then
					local clone2 = particleEmitter:Clone()
					clone2.Parent = clone
					clone2.Enabled = true
					task.delay(1.5, function()
						if clone2 and clone2.Parent then
							clone2.Enabled = false
						end
					end)
				end
			end)
			Debris:AddItem(clone, 5)
			TweenService:Create(clone, tweenInfo, {
				Size = createVector(60, 0.25, 60),
				Transparency = 1,
				Rotation = createVector(0, 2.740167, 0)
			}):Play()
		else
			local module = require(skinModuleFolder.Tisha[skin.Value])
			module.UseAbility(v)
		end
	end
}