local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local _ = Util.LightningBolt3
local FX = require(game.ReplicatedStorage.FX)
local cyborgJump = FX:WaitForChild("RaceAwakenings").CyborgJump

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data)
	local ID = data.ID

	if ID and ID ~= 1 then
		if ID == 2 then
			local hitRoot = data.HitRoot

			if (hitRoot.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 800 then
				return
			end

			Util.Sound:Play("Hit1Electric", hitRoot, nil, math.random(9, 13) / 10, 0.3)
			local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
			equalizerSoundEffect.HighGain = 0
			equalizerSoundEffect.LowGain = 10
			local clone = cyborgJump.Orbs:Clone()
			debris:AddItem(clone, 1)
			clone.Parent = hitRoot
			local clone2 = cyborgJump.Spikes:Clone()
			debris:AddItem(clone2, 1)
			clone2.Parent = hitRoot
			clone:Emit(15)
			clone2:Emit(15)
		end
	else
		local cFrame = data.CFrame
		local rootPart = data.RootPart
		local strong = data.Strong
		local magnitude = (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

		if magnitude > 800 or not rootPart then
			return
		end

		if magnitude < 150 then
			Util.CameraShaker:ShakeOnce(10, 20, 0.2, strong and 0.5 or 0.2)
		end

		local clone = cyborgJump.Effect:Clone()
		debris:AddItem(clone, 3)
		local cframe = CFrame.Angles(0, math.rad((math.random(0, 360))), 0)
		local cframe2 = CFrame.new(cFrame.Position)
		local ray, v, _ = Util.Ray(
			cFrame.p,
			Vector3.new(0, -rootPart.Size.Y * 1.5 * 2 - 5),
			{ workspace.Characters, workspace.Enemies }
		)

		if ray then
			cframe2 = CFrame.new(v + createVector(0, 1, 0)) * cframe
		end

		local v2 = data.Replicated and 0.9 or 0.6

		if strong then
			local jumpOrigin = clone.JumpOrigin
			jumpOrigin.Rock.Speed = NumberRange.new(100, 120)
			jumpOrigin.Dust.Speed = NumberRange.new(50)
			jumpOrigin.RisingDrops.Speed = NumberRange.new(40, 80)
			local clones = {}

			for i = 1, 3 do
				local clone2 = cyborgJump.ShockTrail:Clone()
				debris:AddItem(clone2, 2)
				table.insert(clones, clone2)
				local v3 = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(0, math.rad(i * 120), 0)
				clone2.CFrame = rootPart.CFrame * v3 * CFrame.new(0, 0, -8)
				clone2.Parent = _WorldOrigin
				clone2.Trail.Enabled = true
			end

			local lastTime = os.clock()
			task.spawn(function()
				local v3 = 0

				while true do
					local v4

					if os.clock() - lastTime < v2 and rootPart ~= nil then
						v4 = rootPart.Parent ~= nil
					else
						v4 = false
					end

					if v4 then
						for k, v5 in pairs(clones) do
							local v6 = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								math.rad(k * 120 + v3),
								0
							)
							v5.CFrame = rootPart.CFrame * v6 * CFrame.new(0, 0, -8)
						end

						v3 -= 10
						RunService.RenderStepped:Wait()
					else
						if #clones > 0 then
							for _, v5 in pairs(clones) do
								v5.Trail.Enabled = false
								v5.Zaps.Enabled = false
								local v6 = v5
								task.delay(1, function()
									if v6 then
										v6:Destroy()
									end
								end)
							end
						end

						break
					end
				end
			end)
		end

		clone:SetPrimaryPartCFrame(cframe2 * cframe)
		clone.RibbonWind.Size = createVector(10, 15, 10)
		clone.RibbonWind.Position += createVector(0, 7, 0)
		clone.ShockEven.Size = createVector(5, 20, 5)
		clone.ShockEven.Position += createVector(0, 10, 0)
		local v3 = {
			RibbonWind = {
				Info = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0),
				Properties = {
					Size = strong and createVector(40, 0.1, 40) or createVector(30, 0.1, 30),
					Orientation = createVector(0, 360, 0),
					Transparency = 1,
					Position = clone.RibbonWind.Position - createVector(0, 7, 0)
				}
			},
			ShockEven = {
				Info = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0),
				Properties = {
					Size = strong and createVector(55, 1, 55) or createVector(45, 1, 45),
					Transparency = 1,
					Position = clone.ShockEven.Position - createVector(0, 10, 0)
				}
			},
			ShockUneven = {
				Info = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0),
				Properties = {
					Size = createVector(55, 0.5, 55),
					Transparency = 1
				}
			}
		}
		clone.Parent = _WorldOrigin

		for _, child in pairs(clone:GetChildren()) do
			if not v3[child.Name] then
				continue
			end

			local v4 = v3[child.Name]
			local tween = TweenService:Create(child, v4.Info, v4.Properties)
			local v5 = child
			tween.Completed:Connect(function()
				if v5 then
					v5:Destroy()
				end
			end)
			tween:Play()
		end

		for _, child in pairs(clone.JumpOrigin:GetChildren()) do
			if child.Name == "Light" then
				TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {
					Range = 0,
					Brightness = 0
				}):Play()
			else
				local emitCount = child:GetAttribute("EmitCount") or 5

				if child.Name == "Dust" or child.Name == "Rock" then
					if ray ~= nil then
						child:Emit(emitCount)
					end
				else
					child:Emit(emitCount)
				end
			end
		end

		Util.Sound:Play("ElectricStabThing", cFrame, nil, strong and 4 or 5, 1)
		Util.Sound:Play("ElectricImpactShort", rootPart, nil, strong and 0.9 or 1.2, 1)
		task.spawn(function()
			if strong then
				for _ = 1, 3 do
					if clone and clone.JumpOrigin.RisingDrops then
						clone.JumpOrigin.RisingDrops:Emit(5)
						task.wait(0.15)
					else
						break
					end
				end
			end
		end)

		for _ = 1, math.ceil(v2 / 0.1) do
			if rootPart and rootPart.Parent ~= nil and rootPart.Velocity.Magnitude > 10 then
				local clone2 = cyborgJump.MomentumRing:Clone()
				debris:AddItem(clone2, 1)

				if strong then
					clone2.Attachment.Ring.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 5, 1.14),
						NumberSequenceKeypoint.new(1, 15)
					})
				end

				clone2.CFrame = CFrame.new(rootPart.Position, rootPart.Position + rootPart.Velocity)
				clone2.Parent = _WorldOrigin
				clone2.Attachment.Ring:Emit(1)
				clone2.Flakes:Emit(10)
				clone2.Zaps:Emit(math.random(1, 2))

				if strong then
					clone2.Shards:Emit(5)
				end
			end

			task.wait(0.1)
		end
	end
end