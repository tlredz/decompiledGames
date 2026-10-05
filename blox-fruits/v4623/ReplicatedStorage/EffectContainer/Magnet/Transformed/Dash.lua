local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local jump = FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Jump")
FX:WaitForChild("Magnet"):WaitForChild("Transformed"):WaitForChild("Dash")

local function hasCrimsonGoldSkin(player)
	if typeof(player) ~= "Instance" then
		return false
	end

	local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")

	if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
		return true
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
		return true
	end

	return false
end

local _WorldOrigin = workspace._WorldOrigin

local function makeProxyPartAtBone(attachment, parent, _, cframe: CFrame?)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. attachment.Name
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = cFrame
	attachment2.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	rigidConstraint.Parent = part
	part.Transparency = 1
	part.Parent = parent
	return part
end

return function(data)
	local WAIT_INTERVAL = 0.15
	assert(
		data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position,
		"Origin Vector3 missing in: ",
		script:GetFullName()
	)
	local player = data.Player
	local stage = data.Stage
	local magnetRig = player.Character:FindFirstChild("MagnetRig")
	local rootPart = magnetRig and magnetRig:FindFirstChild("RootPart", true)

	if not rootPart then
		return
	end

	if stage == 1 then
		local v = jump
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		Util.Debris:AddItem(model, 5)
		local root = data.Root
		local _ = root.CFrame
		local cFrame = data.Direction == createVector(0, 0, 0) and rootPart.CFrame or CFrame.new(
			rootPart.Position,
			rootPart.Position + data.Direction
		)
		Util.Sound:Play("Magnet_Transformed_Misc_Dash_04", root.Position)
		local cFrame2 = cFrame * CFrame.new(0, 30, 0)
		local clone = v.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone, model, player, "MagnetFruitVFXColor")
		Util.Debris:AddItem(clone, 3)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			task.wait(0.05)

			for i = 1, 2 do
				local v3 = 4
				local v4 = 0.25
				local clone2 = v.Phase1.StartBeam:Clone()
				clone2.CFrame = cFrame2
				Util.SetParentOverrideWithColor(clone2, model, player, "MagnetFruitVFXColor")

				if i == 2 then
					v4 = 0.35
					TweenService:Create(clone2, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
					}):Play()
					v3 = 7.75
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
							TweenService:Create(
								v5,
								TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v5.CurveSize0 * v3,
									CurveSize1 = v5.CurveSize1 * v3,
									Width0 = v5.Width0 / 2,
									Width1 = v5.Width1 / 2
								}
							):Play()
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
		local clone2 = v.Phase1.Dash:Clone()
		clone2.CFrame = cFrame2
		Util.SetParentOverrideWithColor(clone2, model, player, "MagnetFruitVFXColor")
		clone2.Anchored = true

		for i = 1, 2 do
			for i2 = 1, 3 do
				if i2 == 1 then
					continue
				end

				local v3 = i2
				local v4 = i
				task.spawn(function()
					local part = nil
					local cframe = CFrame.new(0, 10, 0)

					if v3 == 1 then
						cframe = CFrame.new(0, 10, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcAPipeR", true)
							else
								v7 = rootPart["APipe4.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcAPipeL", true)
							else
								v7 = rootPart["APipe4.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					elseif v3 == 2 then
						cframe = CFrame.new(0, 4.25, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcBPipeR", true)
							else
								v7 = rootPart["BPipe3.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcBPipeL", true)
							else
								v7 = rootPart["BPipe3.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					elseif v3 == 3 then
						cframe = CFrame.new(0, 3.5, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcCPipeR", true)
							else
								v7 = rootPart["CPipe3.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcCPipeL", true)
							else
								v7 = rootPart["CPipe3.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					end

					if hasCrimsonGoldSkin(player) then
						cframe = CFrame.new(0, 0, 0)
					end

					local clone3 = v.Phase1.PipeAura:Clone()
					clone3.CFrame = part.CFrame
					Util.SetParentOverrideWithColor(clone3, model, player, "MagnetFruitVFXColor")
					clone3.Anchored = false
					clone3.Massless = true
					clone3.Weld.Part0 = part
					clone3.Weld.C1 = cframe

					for i3, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						local v6 = emitter
						task.delay(0.15, function()
							v6.Enabled = false
						end)
					end
				end)
			end
		end

		task.wait(WAIT_INTERVAL)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	elseif stage == 3 then
		local v = jump
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		Util.Debris:AddItem(model, 5)
		local cFrame = rootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		local clone = v.Phase1.Dash:Clone()
		clone.CFrame = cFrame

		for _, child in pairs(clone:GetChildren()) do
			if child.Name ~= "Attachment2" and child.Name ~= "Particle_5" then
				child:Destroy()
			end
		end

		Util.SetParentOverrideWithColor(clone, model, player, "MagnetFruitVFXColor")
		clone.Anchored = true
		Util.Sound:Play("Magnet_Transformed_Misc_Air_Jump_01", rootPart.Position, 8, 1.5)

		for i = 1, 2 do
			for i2 = 1, 3 do
				if i2 == 1 then
					continue
				end

				local v3 = i2
				local v4 = i
				task.spawn(function()
					local part = nil
					local cframe = CFrame.new(0, 10, 0)

					if v3 == 1 then
						cframe = CFrame.new(0, 10, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcAPipeR", true)
							else
								v7 = rootPart["APipe4.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcAPipeL", true)
							else
								v7 = rootPart["APipe4.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					elseif v3 == 2 then
						cframe = CFrame.new(0, 4.25, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcBPipeR", true)
							else
								v7 = rootPart["BPipe3.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcBPipeL", true)
							else
								v7 = rootPart["BPipe3.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					elseif v3 == 3 then
						cframe = CFrame.new(0, 3.5, 0)

						if v4 == 1 then
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcCPipeR", true)
							else
								v7 = rootPart["CPipe3.R"]
							end

							part = makeProxyPartAtBone(v7, model)
						else
							local v7

							if hasCrimsonGoldSkin(player) then
								v7 = rootPart:FindFirstChild("ArcCPipeL", true)
							else
								v7 = rootPart["CPipe3.L"]
							end

							part = makeProxyPartAtBone(v7, model)
						end
					end

					if hasCrimsonGoldSkin(player) then
						cframe = CFrame.new(0, 0, 0)
					end

					local clone2 = v.Phase1.PipeAura:Clone()
					clone2.CFrame = part.CFrame
					Util.SetParentOverrideWithColor(clone2, model, player, "MagnetFruitVFXColor")
					clone2.Anchored = false
					clone2.Massless = true
					clone2.Weld.Part0 = part
					clone2.Weld.C1 = cframe

					for i3, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						local v6 = emitter
						task.delay(0.15, function()
							v6.Enabled = false
						end)
					end
				end)
			end
		end

		task.wait(WAIT_INTERVAL)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	else
		local v = jump
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		Util.Debris:AddItem(model, 5)
		local root = data.Root
		local _ = root.CFrame
		Util.Sound:Play("Magnet_Transformed_Misc_Air_Jump_01", root.Position)
		local cFrame = rootPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		local clone = v.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, model, player, "MagnetFruitVFXColor")
		Util.Debris:AddItem(clone, 3)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		task.spawn(function()
			task.wait(0.05)

			for i = 1, 2 do
				local v3 = 4
				local v4 = 0.25
				local clone2 = v.Phase1.StartBeam:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, model, player, "MagnetFruitVFXColor")

				if i == 2 then
					v4 = 0.35
					TweenService:Create(clone2, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = clone2.CFrame * CFrame.new(0, 0, 5)
					}):Play()
					v3 = 7.75
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
							TweenService:Create(
								v5,
								TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
								{
									CurveSize0 = v5.CurveSize0 * v3,
									CurveSize1 = v5.CurveSize1 * v3,
									Width0 = v5.Width0 / 2,
									Width1 = v5.Width1 / 2
								}
							):Play()
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
		local clone2 = v.Phase1.Dash:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, model, player, "MagnetFruitVFXColor")
		clone2.Anchored = true
		local v3 = {}

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
				v3[effect] = effect
			elseif effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		for i = 1, 2 do
			for i2 = 1, 3 do
				if i2 == 1 then
					continue
				end

				local v4 = i2
				local v5 = i
				task.spawn(function()
					local part = nil
					local cframe = CFrame.new(0, 10, 0)

					if v4 == 1 then
						cframe = CFrame.new(0, 10, 0)

						if v5 == 1 then
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcAPipeR", true)
							else
								v8 = rootPart["APipe4.R"]
							end

							part = makeProxyPartAtBone(v8, model)
						else
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcAPipeL", true)
							else
								v8 = rootPart["APipe4.L"]
							end

							part = makeProxyPartAtBone(v8, model)
						end
					elseif v4 == 2 then
						cframe = CFrame.new(0, 4.25, 0)

						if v5 == 1 then
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcBPipeR", true)
							else
								v8 = rootPart["BPipe3.R"]
							end

							part = makeProxyPartAtBone(v8, model)
						else
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcBPipeL", true)
							else
								v8 = rootPart["BPipe3.L"]
							end

							part = makeProxyPartAtBone(v8, model)
						end
					elseif v4 == 3 then
						cframe = CFrame.new(0, 3.5, 0)

						if v5 == 1 then
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcCPipeR", true)
							else
								v8 = rootPart["CPipe3.R"]
							end

							part = makeProxyPartAtBone(v8, model)
						else
							local v8

							if hasCrimsonGoldSkin(player) then
								v8 = rootPart:FindFirstChild("ArcCPipeL", true)
							else
								v8 = rootPart["CPipe3.L"]
							end

							part = makeProxyPartAtBone(v8, model)
						end
					end

					if hasCrimsonGoldSkin(player) then
						cframe = CFrame.new(0, 0, 0)
					end

					local clone3 = v.Phase1.PipeAura:Clone()
					clone3.CFrame = part.CFrame
					Util.SetParentOverrideWithColor(clone3, model, player, "MagnetFruitVFXColor")
					clone3.Anchored = false
					clone3.Massless = true
					clone3.Weld.Part0 = part
					clone3.Weld.C1 = cframe

					for i3, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						local v7 = emitter
						task.delay(0.15, function()
							v7.Enabled = false
						end)
					end
				end)
			end
		end

		task.wait(WAIT_INTERVAL)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end
end