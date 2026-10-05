local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleX = FX:WaitForChild("Eagle").EagleX
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local random = Random.new()

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {
	"rbxassetid://97218754302954",
	"rbxassetid://92512315439090",
	"rbxassetid://132257721027585",
	"rbxassetid://109043178609027",
	"rbxassetid://115658457608521",
	"rbxassetid://94038468481404",
	"rbxassetid://111899774172836",
	"rbxassetid://95331025420540",
	"rbxassetid://104310000298124",
	"rbxassetid://92106515101094",
	"rbxassetid://114921472789923",
	"rbxassetid://110904262719869",
	"rbxassetid://121352197431255"
}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
Util.ResizeModel(eagleX.Projectile, 1.5)
Util.ResizeModel(eagleX.FloorSlashes, 1.5)

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ScaleTween(clone, p: number, number, position)
	local total = 0
	local lastTime = os.clock()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		local value = game.TweenService:GetValue(
			math.min(total / number, 1),
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out
		)
		total += dt
		local scale = clone:GetScale()
		clone:ScaleTo((math.max(0.001, scale + (p - scale) * value)))
		local part = clone:FindFirstChildOfClass("Part")
		part.Position = position

		if clone:GetScale() == p then
			heartbeatConnection:Disconnect()
		elseif number <= os.clock() - lastTime then
			heartbeatConnection:Disconnect()
		end
	end)
end

local function makeHighlight(player)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0.2
	highlight.OutlineColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	return highlight
end

return function(data)
	local player = data.player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	if data.Stage == 0 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		local root = data.Root
		Util.Sound:Play("EagleFt_ZX_Activate_01_V1", data.Root)
		local v2 = Util.Sound:Play("EagleFt_X_Hold_01_V1", root)
		TweenService:Create(v2, TweenInfo.new(1), {
			Volume = 0.8
		}):Play()
		local clone = eagleX.Charge:Clone()
		clone.Weld.Part0 = root.Parent:FindFirstChild("UpperTorso") or root
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "EagleFruitVFXColor")
		local highlight = makeHighlight(player)
		local fillTransparency = highlight.FillTransparency
		local outlineTransparency = highlight.OutlineTransparency
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		task.spawn(function()
			repeat
				TweenService:Create(
					highlight,
					TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true),
					{
						FillTransparency = fillTransparency,
						OutlineTransparency = outlineTransparency
					}
				):Play()
				task.wait(0.8)
			until not (holding:IsDescendantOf(workspace) and holding.Value)

			highlight:Destroy()
		end)
		Util.SetParentOverrideWithColor(highlight, data.Rig.Wings, player, "EagleFruitVFXColor")
		local clone2 = eagleX.FloorWind:Clone()
		clone2.Position = root.Position
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
		local lastTime = os.clock()
		local v3 = false
		os.clock()
		local raycastResult = nil
		local v4 = nil
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			raycastResult = workspace:Raycast(root.Position, createVector(0, -10, 0), raycastParams)

			if raycastResult then
				clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)

				if os.clock() - lastTime >= 0.04 then
					lastTime = os.clock()
					local clone3 = eagleX.FloorMesh:Clone()
					clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						random:NextNumber(0, 6.283185307179586),
						0
					)
					Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
					local number = random:NextNumber(9, 11)
					local number2 = random:NextNumber(3, 6)
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(#v * 0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Scale = Vector3.new(number, number2, number),
							Offset = Vector3.new(0, number2 / 3, 0)
						}
					):Play()
					task.spawn(function()
						for _, texture in v do
							clone3.Decal.Texture = texture
							task.wait(0.02)
						end

						clone3:Destroy()
					end)
				end

				if v3 == true then
					return
				end

				v4 = Util.Sound:Play("EagleFt_WindRushingLoop_03_V1", root)
				local folder2 = clone2

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = true
					end
				end

				v3 = true
			elseif v3 == true then
				local folder2 = clone2

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				if v4 then
					Util.Sound:FadeOut(v4, 0.1)
				end

				v3 = false
			end
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		if v4 then
			Util.Sound:FadeOut(v4, 0.1)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		heartbeatConnection:Disconnect()

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.delay(nil, clone2.Destroy, clone2)
		task.delay(ParticleState(clone), clone.Destroy, clone)
		task.wait(5)
		folder:Destroy()
	elseif data.Stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local lifetime = data.Lifetime
		local speed = data.Speed
		local _ = data.HitRadius
		local HRP = data.HRP
		local v2 = speed * lifetime
		local v3 = v2 / speed
		local cFrame = HRP.CFrame
		local clone = eagleX.ShootEffect:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		ParticleState(clone)

		if data.Player then
			local player2 = data.Player
			local Players = game:GetService("Players")

			if player2 == Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(8, 12, 0.1, 0.25)
			end
		end

		Util.Sound:Play("EagleFt_X_ReleaseWhoosh_03_V1", clone.Position)
		local clone2 = eagleX.Projectile:Clone()
		clone2.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
		TweenService:Create(clone2, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
			CFrame = cFrame * CFrame.new(0, 0, -v2)
		}):Play()
		local raycastResult = nil
		local v4 = false
		local clone3 = eagleX.FloorSlashes:Clone()
		clone3.CFrame = HRP.CFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(_)
			if os.clock() - lastTime <= 0.01 then
				return
			end

			lastTime = os.clock()
			local clone4 = eagleX.BeamModel:Clone()
			local beams = clone4.Beams
			beams.CFrame = clone2.CFrame * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586))
			Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
			local position = clone2.Position
			raycastResult = workspace:Raycast(clone2.Position, createVector(0, -7, 0), raycastParams)

			if raycastResult then
				clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

				if v4 == false then
					local folder2 = clone3

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = true
						end
					end
				end

				v4 = true
			elseif v4 == true and not raycastResult then
				local folder2 = clone3

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				v4 = false
			end

			local number = random:NextNumber(0.15, 0.25)
			TweenService:Create(
				beams.MainSlash,
				TweenInfo.new(number * random:NextNumber(0.7, 0.9), Enum.EasingStyle.Linear),
				{
					Brightness = 0,
					LightEmission = 1
				}
			):Play()
			TweenService:Create(beams, TweenInfo.new(number, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Orientation = beams.Orientation + Vector3.new(0, 0, random:NextNumber(180, 600))
			}):Play()
			ScaleTween(clone4, 0.1 + (1 - (os.clock() - lastTime2) / v3), number, position) -- equivalent call inferred; original call site unknown
		end)

		for i = -1, 1, 2 do
			local clone4 = eagleX.FloorTrail:Clone()
			clone4.CFrame = clone2.CFrame * CFrame.new(i * 10, 0, 0)
			Util.SetParentOverrideWithColor(clone4, clone2, player, "EagleFruitVFXColor")
			local v5 = false
			local heartbeatConnection2 = nil
			local v7 = i
			heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				if heartbeatConnection.Connected == false then
					local folder2 = clone4

					for i2, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end

					heartbeatConnection2:Disconnect()
				else
					local raycastResult2 = workspace:Raycast(
						(clone2.CFrame * CFrame.new(v7 * 10, 5, 0)).Position,
						createVector(0, -10, 0),
						raycastParams
					)
					clone4.Position = raycastResult2 and raycastResult2.Position or clone4.Position

					if raycastResult2 then
						local folder2 = clone4

						for i2, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = true
							end
						end

						clone4.Trail.Enabled = true

						if not v5 then
							v5 = true
							Util.Sound:Play("EagleFt_X_Release_GroundSlice_02_V1", clone4.Position)
						end
					end
				end
			end)
		end

		task.wait(v3)

		for _, effect in pairs(clone3:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		heartbeatConnection:Disconnect()

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local clone4 = eagleX.Glow:Clone()
		clone4.CFrame = clone2.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
		ParticleState(clone4)
		task.wait()
		local clone5 = eagleX.Explosion:Clone()
		clone5.CFrame = clone2.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "EagleFruitVFXColor")
		ParticleState(clone5)
		Util.Sound:Play("EagleFt_X_ReleaseExplosionAdditional_06_V2", clone5.Position)
		TweenService:Create(clone5.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Brightness = 0,
			Range = 0
		}):Play()
	elseif data.Stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local root = data.Root
		local clone = eagleX.Hit:Clone()
		clone.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_X_TargetHit_StabCut_0" .. tostring(math.random(1, 10)) .. "_V1", root)
		task.delay(0.1, function()
			local folder2 = clone

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(1)
			clone:Destroy()
		end)
	end
end