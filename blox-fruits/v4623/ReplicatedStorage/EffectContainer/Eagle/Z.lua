local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleZRework = FX:WaitForChild("Eagle").EagleZRework
local _WorldOrigin = workspace._WorldOrigin
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
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
Util.ResizeModel(eagleZRework.Explosion, 0.5)

local function ParticleState(player, folder, enabled: boolean)
	if player ~= nil then
		player:IsA("Player")
	end

	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil and not effect:IsA("Trail") then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not (effect:IsA("Trail") or effect.Lifetime.Max <= max) then
			max = effect.Lifetime.Max
		end
	end

	return max
end

local function makeHighlight(player)
	if player ~= nil then
		player:IsA("Player")
	end

	local highlight = Instance.new("Highlight")
	local fillColor

	if player then
		fillColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	else
		fillColor = Color3.fromRGB(255, 183, 110)
	end

	highlight.FillColor = fillColor
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0.2
	local outlineColor

	if player then
		outlineColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	else
		outlineColor = Color3.fromRGB(255, 183, 110)
	end

	highlight.OutlineColor = outlineColor
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	return highlight
end

return function(data)
	local origin = data.Origin
	local player = data.player

	if player ~= nil then
		player:IsA("Player")
	end

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = data.Stage

	if stage == 0 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local root = data.Root
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		local random2 = Random.new()
		local clone = eagleZRework.Charge:Clone()
		clone.Weld.Part0 = root.Parent:FindFirstChild("UpperTorso") or root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_ZX_Activate_01_V1", data.Root)
		local v2 = Util.Sound:Play("EagleFt_Z_Hold_FireSparks_01_V1", root)
		TweenService:Create(v2, TweenInfo.new(1), {
			Volume = 0.8
		}):Play()
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
		local clone2 = eagleZRework.FloorWind:Clone()
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
					local clone3 = eagleZRework.FloorMesh:Clone()
					clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						random2:NextNumber(0, 6.283185307179586),
						0
					)
					Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
					local number = random2:NextNumber(9, 11)
					local number2 = random2:NextNumber(3, 6)
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
				ParticleState(player, clone2, true)
				v3 = true
			elseif v3 == true then
				ParticleState(player, clone2, false)

				if v4 then
					Util.Sound:FadeOut(v4, 0.1)
				end

				v3 = false
			end
		end)

		repeat
			task.wait()
		until not (holding:IsDescendantOf(workspace) and holding.Value)

		heartbeatConnection:Disconnect()

		if v4 then
			Util.Sound:FadeOut(v4, 0.1)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		ParticleState(player, clone2, false)
		ParticleState(player, clone, false)
		heartbeatConnection:Disconnect()
		task.wait(5)
		folder:Destroy()
	elseif stage == 1 then
		local duration = data.Duration
		local cFrame = data.Root.CFrame * CFrame.new(0, 15, 0)
		local hitbox = data.Hitbox
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local clone = eagleZRework.Hits:Clone()
		Util.Debris:AddItem(clone, duration + 3)
		clone.Size = hitbox
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local lastTime3 = os.clock()
		local lastTime4 = os.clock()
		Util.Sound:Play("EagleFt_Z_Release_03_V1", data.Root)
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if os.clock() - lastTime >= 0.15 then
				lastTime = os.clock()
				local clone2 = eagleZRework.BeamModel:Clone()
				clone2:ScaleTo(random:NextNumber(1, 2.3))
				local beams = clone2.Beams
				beams.CFrame = cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				) * CFrame.Angles(
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586)
				)
				Util.SetParentOverrideWithColor(beams, folder, player, "EagleFruitVFXColor")
				Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
				TweenService:Create(beams, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = beams.CFrame * CFrame.Angles(0, 0, 3.141592653589793 * random:NextNumber(0.8, 0.95))
				}):Play()
				task.delay(0.05, function()
					TweenService:Create(beams.MainSlash, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					task.wait(0.1)
					clone2:Destroy()
				end)
			end

			if os.clock() - lastTime2 >= 0.05 then
				lastTime2 = os.clock()
				local clone2 = eagleZRework.WindBeamModel:Clone()
				clone2:ScaleTo(random:NextNumber(0.6, 1.5))
				local beams = clone2.Beams
				beams.CFrame = cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				) * CFrame.Angles(
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586),
					random:NextNumber(0, 6.283185307179586)
				)
				Util.SetParentOverrideWithColor(beams, folder, player, "EagleFruitVFXColor")
				Util.Debris:AddItem(beams, 1)
				Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
				TweenService:Create(beams, TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = beams.CFrame * CFrame.Angles(0, 0, 3.141592653589793 * random:NextNumber(0.8, 0.95))
				}):Play()
				task.delay(0.05, function()
					TweenService:Create(beams.MainSlash, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
					task.wait(0.1)
					clone2:Destroy()
				end)
			end

			if os.clock() - lastTime4 >= 0.02 then
				local position = (cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				)).Position
				local position2 = (cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y * 1.5, hitbox.Y),
					random:NextNumber(-hitbox.Z / 1.5, hitbox.Z / 1.5)
				)).Position
				local raycastResult = workspace:Raycast(position, position2 - position, raycastParams)

				if raycastResult then
					lastTime4 = os.clock()
					local clone2 = eagleZRework.FloorSlash:Clone()
					clone2.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
					Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
					local particleState = ParticleState(player, clone2)
					task.delay(particleState, clone2.Destroy, clone2)
				end
			end

			if os.clock() - lastTime3 >= 0.1 then
				lastTime3 = os.clock()

				if data.Root.Parent == game.Players.LocalPlayer.Character then
					Util.CameraShaker:ShakeOnce(4, 8, 0.03333333333333333, 0.13333333333333333)
				end

				local clone2 = eagleZRework.MiniExplosion:Clone()
				clone2.Position = (cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				)).Position
				Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor")
				local particleState = ParticleState(player, clone2)
				Util.Sound:Play("EagleFt_Z_Small_Explosions_0" .. tostring(math.random(1, 9)) .. "_V1", clone2.Position)
				task.delay(particleState, clone2.Destroy, clone2)
				local position = (cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				)).Position
				local position2 = (cFrame * CFrame.new(
					random:NextNumber(-hitbox.X / 2, hitbox.X / 2),
					random:NextNumber(-hitbox.Y / 2, hitbox.Y / 2),
					random:NextNumber(-hitbox.Z / 2, hitbox.Z / 2)
				)).Position
				local clone3 = eagleZRework.ShotEffect:Clone()
				clone3.CFrame = CFrame.lookAt(position, position2)
				Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor")
				local particleState2 = ParticleState(player, clone3)
				task.delay(particleState2, clone3.Destroy, clone3)
				local clone4 = eagleZRework.BeamPart1:Clone()
				local beamPart2 = clone4.BeamPart2
				beamPart2.Position = position
				clone4.Position = position
				Util.SetParentOverrideWithColor(clone4, folder, player, "EagleFruitVFXColor")
				local number = random:NextNumber(350, 800)
				local v5 = (position - position2).Magnitude / number
				TweenService:Create(beamPart2, TweenInfo.new(v5, Enum.EasingStyle.Linear), {
					Position = position2
				}):Play()
				task.wait(v5 * 0.8)
				TweenService:Create(clone4.Beam, TweenInfo.new(v5 * 0.2, Enum.EasingStyle.Linear), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				task.wait(0.2 * v5)
				clone4:Destroy()
			end
		end)
		task.wait(duration)
		ParticleState(player, clone, false)
		heartbeatConnection:Disconnect()
	elseif stage == 2 then
		local enemyRoot = data.EnemyRoot
		local duration = data.Duration
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local folder2 = Instance.new("Folder")
		folder2.Name = "FeatherFolder"
		Util.SetParentOverrideWithColor(folder2, folder, player, "EagleFruitVFXColor")

		for _ = 1, 5 do
			local clone = eagleZRework["Feather" .. random:NextInteger(1, 3)]:Clone()
			clone.Weld.Part0 = enemyRoot
			clone.Weld.C0 = CFrame.new(random:NextNumber(-3, 3), random:NextNumber(-3, 3), random:NextNumber(-3, 3)) * CFrame.Angles(
				random:NextNumber(0, 6.283185307179586),
				random:NextNumber(0, 6.283185307179586),
				random:NextNumber(0, 6.283185307179586)
			)
			Util.SetParentOverrideWithColor(clone, folder2, player, "EagleFruitVFXColor")
		end

		task.wait(duration)
		folder2:Destroy()
		local clone = eagleZRework.Explosion:Clone()
		clone.CFrame = enemyRoot.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_Z_FinalNpcExplosion_0" .. tostring(math.random(1, 6)) .. "_V1", enemyRoot)
		TweenService:Create(clone.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Range = 0,
			Brightness = 0
		}):Play()
		local particleState = ParticleState(player, clone)
		task.delay(particleState, clone.Destroy, clone)
	elseif stage == 3 then
		local enemyRoot = data.EnemyRoot

		if not enemyRoot then
			return
		end

		local clone = eagleZRework.CharacterHit:Clone()
		clone.CFrame = enemyRoot.CFrame
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_Z_TargetHit_0" .. tostring(math.random(1, 5)) .. "_V2", clone.Position)
		Util.Debris:AddItem(clone, 1)
		task.wait(0.1)
		ParticleState(player, clone, false)
	end
end