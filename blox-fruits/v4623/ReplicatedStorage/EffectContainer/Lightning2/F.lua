local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").F.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, p)
	local v = not (p and p.Magnitude > 0 and p) and createVector(0, 1, 0) or p
	local p2 = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p2, unit2, v, unit3)
end

local LightningBoltShafi = require(game.ReplicatedStorage.Util.LightningBoltShafi)

local function ShafiBolt(p, ...)
	local v = LightningBoltShafi.new(...)
	v.MinRadius = 0
	v.MaxRadius = 3
	v.Frequency = 0.5
	v.AnimationSpeed = 6
	local maxThicknessMultiplier = math.random(1, 2)
	v.MinThicknessMultiplier = 0.2
	v.MaxThicknessMultiplier = maxThicknessMultiplier
	v.MinTransparency = 0
	v.MaxTransparency = 1
	v.PulseSpeed = math.random(5, 7)
	v.PulseLength = 10000
	v.FadeLength = 0.2
	v.ContractFrom = 0.5
	v.Color = Util.WrapColor3Constructor(Color3.new(0.380392, 1, 1), p, "LightningFruitVFXColor")
	v.ColorOffsetSpeed = 3
	return v
end

local function Tap(player, cFrame, folder, raycastParams2, dashDist)
	local clone = assets.Phase1.DashAura:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
	clone.Anchored = false

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = cFrame * CFrame.new(0, 0, -dashDist)
	}):Play()
	local v = tick() + 0.1
	local now = tick()
	local v2 = {}

	while true do
		if now - tick() <= 0 then
			now = tick() + 0.0075
			local position = clone.Position
			local raycastResult = workspace:Raycast(
				position + createVector(0, 1, 0),
				createVector(-0, -15, -0),
				raycastParams2
			)

			for _ = 1, math.random(1, 3) do
				if not raycastResult then
					continue
				end

				local v3 = raycastResult
				task.spawn(function()
					local worldPosition = v3.Position + Vector3.new(
						math.random(-25, 25) / 2,
						0,
						math.random(-25, 25) / 2
					)
					local clone2 = FX:WaitForChild("Lightning2").F.Part:Clone()
					clone2.CFrame = CFrame.new(clone.Position, worldPosition)
					Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
					clone2.Anchored = false
					clone2.Weld.Part1 = clone
					clone2.Massless = true
					clone2.Weld.C1 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-0, 0)) * CFrame.Angles(
						0,
						math.rad((math.random(-180, 180))),
						-1.5707963267948966
					)
					clone2.Attach1.WorldPosition = worldPosition
					clone2.Attach1:SetAttribute("Pos", worldPosition)
					clone2.Attach0.Orientation = Vector3.new(
						math.random(-180, 180),
						math.random(-180, 180),
						math.random(-180, 180)
					)
					local shafiBolt = ShafiBolt(
						player,
						clone2.Attach0,
						clone2.Attach1,
						math.random(15, 20) / 1.5,
						0.5 + math.random() * 0.25,
						folder
					)
					local curveSize = math.random(-15, 5) * 1.25
					local curveSize2 = math.random(-5, 15) * 1.25
					shafiBolt.CurveSize0 = curveSize
					shafiBolt.CurveSize1 = curveSize2
					v2[clone2.Attach1] = shafiBolt
					task.wait(0.115 * math.random() + 0.115)
					v2[clone2.Attach1] = nil
					shafiBolt:Destroy()
				end)
			end
		end

		for k, _ in pairs(v2) do
			local pos = k:GetAttribute("Pos")
			k.WorldPosition = CFrame.new(pos, clone.Position).Position
		end

		task.wait()

		if not (v - tick() <= 0) then
			continue
		end

		for k, _ in pairs(v2) do
			k.Parent.Weld.Enabled = false
			k.Parent.Anchored = true
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Weld.Enabled = false
		clone.Anchored = true
		break
	end
end

return function(data)
	local player = data.Player or data.player

	if (currentCamera.CFrame.p - data.Root.Position).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		local holding = data.Holding

		if not (holding:IsDescendantOf(workspace) and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		local root = data.Root
		local clone = assets.Phase0.HoldAura:Clone()
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		clone.Anchored = true
		local v = Util.Sound:Play("BF_Thunder_F_Held_01", root)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		repeat
			task.wait()
			clone.CFrame = root.CFrame
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if clone then
			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		Util.Debris:AddItem(folder, 2)
	elseif stage == 2 then
		local root = data.Root

		if not root then
			return
		end

		if data.newCF and root:GetAttribute("Tapped") then
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				root:SetAttribute("Tapped", nil)
				return
			end
		elseif data.newCF and not root:GetAttribute("Tapped") then
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				root.CFrame = data.newCF
			end
		end

		local startCFrame = data.StartCFrame
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 2)
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_F_DashLightning_Dash_04", root)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local highlight = Instance.new("Highlight")
		highlight.FillColor = Util.WrapColor3Constructor(
			Color3.fromRGB(107, 253, 255),
			player,
			"LightningFruitVFXColor"
		)
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		Util.SetParentOverrideWithColor(highlight, root.Parent, player, "LightningFruitVFXColor")
		task.delay(0.1, function()
			pcall(function()
				TweenService:Create(highlight, TweenInfo.new(0.05), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
			end)
		end)
		Util.Debris:AddItem(highlight, 0.15)
		local dashDist = data.DashDist
		task.spawn(function()
			task.wait(0.05)

			for i = 1, 6 do
				local v = i * 25

				if dashDist < v then
					break
				end

				local v2 = startCFrame * CFrame.new(0, 0, -(v - 25))
				local clone2 = assets.Phase1.StartBeam:Clone()
				clone2.CFrame = v2 * CFrame.new(0, 0, -10)
				Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
				}):Play()

				for _, descendant in pairs(clone2:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v3 = descendant
						task.spawn(function()
							TweenService:Create(
								v3,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v3.CurveSize0 * 1.5,
									CurveSize1 = v3.CurveSize1 * 1.5,
									Width0 = v3.Width0 / 2,
									Width1 = v3.Width1 / 2
								}
							):Play()
							task.wait(0.08333333333333333)
							local tween = TweenService:Create(
								v3,
								TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v3:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(
									descendant.Position.X * 1.5,
									descendant.Position.Y * 1.5,
									descendant.Position.Z * 1.5
								)
							}
						):Play()
					end
				end

				task.wait(0.025)
			end
		end)
		Tap(player, startCFrame, folder, raycastParams, dashDist)
	elseif stage == 3 then
		local root = data.Root
		local startCFrame = data.StartCFrame
		local startCFrame2 = data.StartCFrame2
		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local clone = assets.Phase2.HitImpact:Clone()
		clone.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_F_DashLightning_NPCStrike_V2_0" .. tostring(math.random(1, 2)), clone.Position)
		local clone2 = assets.Phase1.DashAura:Clone()
		clone2.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		clone2.Anchored = false
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local clone3 = assets.Phase1.StartImpact:Clone()
		clone3.CFrame = startCFrame2
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone3) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local highlight = Instance.new("Highlight")
		highlight.FillColor = Util.WrapColor3Constructor(
			Color3.fromRGB(107, 253, 255),
			player,
			"LightningFruitVFXColor"
		)
		highlight.FillTransparency = 0
		highlight.OutlineTransparency = 1
		Util.SetParentOverrideWithColor(highlight, root.Parent, player, "LightningFruitVFXColor")
		task.delay(0.1, function()
			pcall(function()
				TweenService:Create(highlight, TweenInfo.new(0.05), {
					FillTransparency = 1,
					OutlineTransparency = 1
				}):Play()
			end)
		end)
		Util.Debris:AddItem(highlight, 0.15)
		local dashDist = data.DashDist
		task.spawn(function()
			task.wait(0.05)

			for i = 1, 6 do
				local v = i * 25

				if dashDist < v then
					break
				end

				local v2 = startCFrame2 * CFrame.new(0, 0, -(v - 25))
				local clone4 = assets.Phase1.StartBeam:Clone()
				clone4.CFrame = v2 * CFrame.new(0, 0, -10)
				Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone4.CFrame * CFrame.new(0, 0, 5)
				}):Play()

				for _, descendant in pairs(clone4:GetDescendants()) do
					if descendant:IsA("Beam") then
						local v3 = descendant
						task.spawn(function()
							TweenService:Create(
								v3,
								TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v3.CurveSize0 * 1.5,
									CurveSize1 = v3.CurveSize1 * 1.5,
									Width0 = v3.Width0 / 2,
									Width1 = v3.Width1 / 2
								}
							):Play()
							task.wait(0.08333333333333333)
							local tween = TweenService:Create(
								v3,
								TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Width0 = 0,
									Width1 = 0
								}
							)
							tween:Play()
							tween.Completed:Wait()
							v3:Destroy()
						end)
					elseif descendant:IsA("Attachment") then
						TweenService:Create(
							descendant,
							TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Position = Vector3.new(
									descendant.Position.X * 1.5,
									descendant.Position.Y * 1.5,
									descendant.Position.Z * 1.5
								)
							}
						):Play()
					end
				end

				task.wait(0.025)
			end
		end)
		task.spawn(function()
			Tap(player, startCFrame2, folder, raycastParams, dashDist)
		end)
		clone2.CFrame = root.CFrame

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local v = {}

		if data.CaughtRoots[2] then
			local v2 = true
			task.spawn(function()
				local now = tick()

				repeat
					if now - tick() <= 0 then
						now = tick() + 0.0075
						local position = clone2.Position
						local raycastResult = workspace:Raycast(
							position + createVector(0, 1, 0),
							createVector(-0, -15, -0),
							raycastParams
						)

						for _ = 1, math.random(1, 3) do
							if not raycastResult then
								continue
							end

							local v3 = raycastResult
							task.spawn(function()
								local worldPosition = v3.Position + Vector3.new(
									math.random(-25, 25) / 2,
									0,
									math.random(-25, 25) / 2
								)
								local clone4 = FX:WaitForChild("Lightning2").F.Part:Clone()
								clone4.CFrame = CFrame.new(clone2.Position, worldPosition)
								Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
								clone4.Anchored = false
								clone4.Weld.Part1 = clone2
								clone4.Massless = true
								clone4.Weld.C1 = CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-0, 0)) * CFrame.Angles(
									0,
									math.rad((math.random(-180, 180))),
									-1.5707963267948966
								)
								clone4.Attach1.WorldPosition = worldPosition
								clone4.Attach1:SetAttribute("Pos", worldPosition)
								clone4.Attach0.Orientation = Vector3.new(
									math.random(-180, 180),
									math.random(-180, 180),
									math.random(-180, 180)
								)
								local shafiBolt = ShafiBolt(
									player,
									clone4.Attach0,
									clone4.Attach1,
									math.random(15, 20) / 1.5,
									0.5 + math.random() * 0.25,
									folder
								)
								local curveSize = math.random(-15, 5) * 1.25
								local curveSize2 = math.random(-5, 15) * 1.25
								shafiBolt.CurveSize0 = curveSize
								shafiBolt.CurveSize1 = curveSize2
								v[clone4.Attach1] = shafiBolt
								task.wait(0.115 * math.random() + 0.115)
								v[clone4.Attach1] = nil
								shafiBolt:Destroy()
							end)
						end
					end

					for k, _ in pairs(v) do
						local pos = k:GetAttribute("Pos")
						k.WorldPosition = CFrame.new(pos, clone2.Position).Position
					end

					task.wait()
				until not v2
			end)

			for i = 2, #data.CaughtRoots do
				local cFrame = data.CaughtRoots[i].CFrame
				local magnitude = (cFrame.Position - root.Position).Magnitude
				local v3 = CFrame.new(cFrame.Position, root.Position) * CFrame.Angles(0, 3.141592653589793, 0)
				local v4 = v3 + v3.LookVector * 10
				local v5 = v4.p + Vector3.new(0, root.Size.Y * 1.5, 0)
				local position = root.Position
				local v6 = v5 - position

				if v6.Magnitude > 250 then
					v5 = position + v6.Unit * 250
				end

				local cFrame2 = CFrame.new(v5) * (v4 - v4.p)
				root.Anchored = true
				local v9 = CFrame.lookAt(root.Position, cFrame.Position)
				task.spawn(function()
					task.wait(0.05)

					for i2 = 1, 6 do
						local v10 = i2 * 25

						if magnitude < v10 then
							break
						end

						local v11 = v9 * CFrame.new(0, 0, -(v10 - 25))
						local clone4 = assets.Phase1.StartBeam:Clone()
						clone4.CFrame = v11 * CFrame.new(0, 0, -10)
						Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
						TweenService:Create(
							clone4,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								CFrame = clone4.CFrame * CFrame.new(0, 0, 5)
							}
						):Play()

						for i3, descendant in pairs(clone4:GetDescendants()) do
							if descendant:IsA("Beam") then
								local v12 = descendant
								task.spawn(function()
									TweenService:Create(
										v12,
										TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
										{
											CurveSize0 = v12.CurveSize0 * 1.5,
											CurveSize1 = v12.CurveSize1 * 1.5,
											Width0 = v12.Width0 / 2,
											Width1 = v12.Width1 / 2
										}
									):Play()
									task.wait(0.08333333333333333)
									local tween = TweenService:Create(
										v12,
										TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Width0 = 0,
											Width1 = 0
										}
									)
									tween:Play()
									tween.Completed:Wait()
									v12:Destroy()
								end)
							elseif descendant:IsA("Attachment") then
								TweenService:Create(
									descendant,
									TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
									{
										Position = Vector3.new(
											descendant.Position.X * 1.5,
											descendant.Position.Y * 1.5,
											descendant.Position.Z * 1.5
										)
									}
								):Play()
							end
						end

						task.wait(0.025)
					end
				end)
				Util.Sound:Play("BF_Thunder_F_DashLightning_Dash_04", root)
				local lastTime = os.clock()

				while os.clock() - lastTime < 0.1 do
					local v10 = (os.clock() - lastTime) / 0.1
					root.CFrame = cFrame2 * CFrame.new(0, 0, magnitude * (1 - v10 ^ 0.5))
					clone2.CFrame = root.CFrame
					RunService.PreSimulation:Wait()
				end

				root.CFrame = cFrame2
				clone2.CFrame = root.CFrame
				root.Anchored = false
				local clone4 = assets.Phase2.HitImpact:Clone()
				clone4.CFrame = startCFrame
				Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
				clone4.CFrame = root.CFrame
				Util.Sound:Play(
					"BF_Thunder_F_DashLightning_NPCStrike_V2_0" .. tostring(math.random(1, 2)),
					clone4.Position
				)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end

			v2 = false

			for k, _ in pairs(v) do
				k.Parent.Weld.Enabled = false
				k.Parent.Anchored = true
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			clone2.Weld.Enabled = false
			clone2.Anchored = true
		end
	end
end