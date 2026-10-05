local createVector = vector.create
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Blade").X.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
local TweenService = game:GetService("TweenService")

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

local function SpinSlash(folder, root, data, player)
	local slashCFrameOffset = data.SlashCFrameOffset
	local _ = data.StartMultiplier
	local multiplier = data.Multiplier
	local _ = data.MultiplierSpeed
	local _ = data.MultiplierDelay
	local slashType = data.SlashType
	local slashIterations = data.SlashIterations
	local slashSpinAngle = data.SlashSpinAngle
	local slashFinalSpinAngle = data.SlashFinalSpinAngle
	local slashEndSpeed = data.SlashEndSpeed
	local clone = slashType:Clone()
	local slash = clone.Slash
	slash.CFrame = root.CFrame
	slash.Anchored = false
	slash.Weld.Part0 = root
	slash.Weld.C0 = slash.Weld.Part0.CFrame:ToObjectSpace(slash.Weld.Part1.CFrame) * slashCFrameOffset
	Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")

	for _, descendant in pairs(slash:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local startDelay = descendant:GetAttribute("StartDelay")
			local v = descendant
			local v2 = descendant:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0 * 1.5,
						Width1 = v.Width1 * 1.5
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = Vector3.new(
					descendant.Position.X * 1.5,
					descendant.Position.Y * 1.5,
					descendant.Position.Z * 1.5
				)
			})
		end
	end

	clone:ScaleTo(multiplier / math.random(90, 140))

	for _ = 1, slashIterations do
		local tween = TweenService:Create(
			slash.Weld,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = slash.Weld.Part0.CFrame:ToObjectSpace(slash.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					math.rad(slashSpinAngle),
					0
				) * CFrame.new(0, 0, 0)
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	slash.Weld.Enabled = false
	slash.Anchored = true
	TweenService:Create(slash, TweenInfo.new(slashEndSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = slash.CFrame * CFrame.Angles(0, math.rad(slashFinalSpinAngle), 0)
	}):Play()
	task.wait(slashEndSpeed / 2)

	for _, effect in pairs(slash:GetDescendants()) do
		if effect:IsA("Beam") then
			local v = effect
			task.spawn(function()
				local endDelay = v:GetAttribute("EndDelay")
				local tween = TweenService:Create(
					v,
					TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end
end

require(script.Parent.Modules.CreateBlade)
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
return function(data)
	local root = data.Root
	local player = data.player

	if (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 15)
	local cFrame = root.CFrame
	local v = 2.1 + tick()
	local clone = assets.Phase1.Spin:Clone()
	clone.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone, folder, player, "BladeFruitVFXColor")

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	local function AlignCFrame(data2, normal)
		local v2 = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
		local p = data2.p
		local unit = data2.LookVector:Cross(v2).Unit
		local unit2 = (unit.Magnitude > 0.001 and unit or data2.RightVector).Unit
		local unit3 = unit2:Cross(v2).Unit
		return CFrame.fromMatrix(p, unit2, v2, unit3)
	end

	local clone2 = assets.Phase1.GroundSpark:Clone()
	clone2.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "BladeFruitVFXColor")
	local _ = clone2.Size
	local clone3 = assets.Phase1.Dust:Clone()
	clone3.CFrame = root.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
	Util.SetParentOverrideWithColor(clone3, folder, player, "BladeFruitVFXColor")
	local v2 = Util.Sound:Play("Slice.BladeDance", root)
	local lastTime = tick()

	while data.Holding.Value ~= false and data.Holding:IsDescendantOf(workspace) or not (tick() - lastTime > 0.5) do
		local raycastResult = workspace:Raycast(root.Position, createVector(-0, -7, -0), raycastParams)

		if raycastResult and raycastResult.Position then
			clone3.Attachment.ParticleEmitter.Color = ColorSequence.new(raycastResult.Instance.Color)
			clone3.Attachment.ParticleEmitter2.Color = ColorSequence.new(raycastResult.Instance.Color)
			clone3.Orientation = root.Orientation - createVector(0, 180, 0)
			clone3.CFrame = root.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			clone3.Attachment.ParticleEmitter.Enabled = true
			clone3.Attachment.ParticleEmitter2.Enabled = true
		else
			clone3.Attachment.ParticleEmitter.Enabled = false
			clone3.Attachment.ParticleEmitter2.Enabled = false
		end

		clone.CFrame = root.CFrame
		local slashCFrameOffset = CFrame.Angles(
			math.rad(math.random(-25, 25) / 1.5),
			math.rad((math.random(-180, 180))),
			(math.rad(math.random(-25, 25) / 1.5))
		)
		task.spawn(function()
			SpinSlash(folder, root, {
				StartMultiplier = 100 + math.random(25, 70),
				Multiplier = 350 + math.random(-50, 70) * 2,
				MultiplierSpeed = 60 + math.random(0, 60),
				MultiplierDelay = 0.01,
				SlashCFrameOffset = slashCFrameOffset,
				SlashType = assets.Phase1.SlashModel,
				SlashIterations = 2,
				SlashSpinAngle = 179,
				SlashFinalSpinAngle = 179,
				SlashEndSpeed = 0.07
			}, player)
		end)

		for _ = 1, 2 do
			task.spawn(function()
				local raycastResult2 = workspace:Raycast(
					CFrame.new(root.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * Vector3.new(
						0,
						0,
						math.random(15, 25)
					),
					createVector(-0, -7, -0),
					raycastParams
				)
				task.wait(math.random(5, 15) / 100)

				if raycastResult2 then
					clone2.CFrame = AlignCFrame(
						CFrame.new(raycastResult2.Position, root.Position),
						raycastResult2.Normal
					) * CFrame.Angles(0, 1.5707963267948966, 0) + raycastResult2.Normal * 0.05

					for _, emitter in pairs(clone2:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end
				end
			end)
		end

		task.wait(0.05)

		if v - tick() <= 0 then
			break
		end
	end

	if v2 then
		Util.Sound:FadeOut(v2, 0.6)
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown

	if clone3 then
		clone3.Attachment.ParticleEmitter.Enabled = false
		clone3.Attachment.ParticleEmitter2.Enabled = false
	end
end