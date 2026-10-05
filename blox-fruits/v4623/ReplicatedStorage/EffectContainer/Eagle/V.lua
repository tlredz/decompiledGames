local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleV = FX:WaitForChild("Eagle").EagleV
local _WorldOrigin = workspace._WorldOrigin
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

local function makeHighlight(player)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0.2
	highlight.OutlineColor = Util.WrapColor3Constructor(Color3.fromRGB(255, 183, 110), player, "EagleFruitVFXColor")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	return highlight
end

return function(player)
	local player2 = player.player
	local origin = player.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 800 then
		return
	end

	local stage = player.Stage
	local root = player.Root

	if stage == 0 then
		local holding = player.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "EagleFruitVFXColor")
		local random = Random.new()
		local clone = eagleV.Charge:Clone()
		clone.Weld.Part0 = root.Parent:FindFirstChild("UpperTorso") or root
		Util.SetParentOverrideWithColor(clone, folder, player2, "EagleFruitVFXColor")
		Util.Sound:Play("EagleFt_CV_Activate_01_V1", root)
		local v2 = Util.Sound:Play("EagleFt_M1_ShimmerOnly_01_V2", root)
		TweenService:Create(v2, TweenInfo.new(1), {
			Volume = 0.8
		}):Play()
		local highlight = makeHighlight(player2)
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
		Util.SetParentOverrideWithColor(highlight, player.Rig.Wings, player2, "EagleFruitVFXColor")
		local clone2 = eagleV.FloorWind:Clone()
		clone2.Position = root.Position
		Util.SetParentOverrideWithColor(clone2, folder, player2, "EagleFruitVFXColor")
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
					local clone3 = eagleV.FloorMesh:Clone()
					clone3.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						random:NextNumber(0, 6.283185307179586),
						0
					)
					Util.SetParentOverrideWithColor(clone3, _WorldOrigin, player2, "EagleFruitVFXColor")
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

		heartbeatConnection:Disconnect()

		if v4 then
			Util.Sound:FadeOut(v4, 0.1)
		end

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		heartbeatConnection:Disconnect()
		task.wait(5)
		folder:Destroy()
	elseif stage == 1 then
		local flightTime = player.FlightTime
		local random = Random.new(player.Seed)
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 10)
		local flag = false
		local clone = eagleV.ScreenEffect:Clone()
		local GUID = HttpService:GenerateGUID(false)
		local Players = game:GetService("Players")

		if Players.LocalPlayer == player.Player then
			clone.CFrame = currentCamera.CFrame
			Util.SetParentOverrideWithColor(clone, folder, player2, "EagleFruitVFXColor")
			TweenService:Create(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				FieldOfView = 110
			}):Play()
			RunService:BindToRenderStep("Speed Camera Effect" .. GUID, Enum.RenderPriority.Camera.Value, function()
				clone.CFrame = currentCamera.CFrame
			end)
		end

		local clone2 = eagleV.Flight:Clone()
		clone2.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone2, folder, player2, "EagleFruitVFXColor")
		ParticleState(clone2.Emit)
		Util.Sound:Play("EagleFt_V_SpearLaunch_02_V1", root)
		local v2 = Util.BodyMover.new(player.Character):Create("BodyVelocity", {
			Velocity = player.Direction.lookVector * 110 * 1.25 * 5
		})
		local random2 = Random.new()
		local connections = {}
		local clones = {}

		for i = 1, 3 do
			local clone3 = eagleV.FollowTrail:Clone()
			local v3 = (i - 1) * 120
			local number = random2:NextNumber(0, 360)
			local number2 = random2:NextNumber(300, 700)
			local number3 = random2:NextNumber(12, 22)
			local number4 = random2:NextNumber(12, 20)
			clone3.CFrame = root.CFrame * CFrame.new(
				math.sin((math.rad(v3))) * number4,
				math.cos((math.rad(v3))) * number4,
				math.sin((math.rad(number))) * number3
			)
			Util.SetParentOverrideWithColor(clone3, folder, player2, "EagleFruitVFXColor")
			table.insert(connections, (RunService.Heartbeat:Connect(function(dt)
				v3 += 800 * dt
				number += number2 * dt
				clone3.CFrame = root.CFrame * CFrame.new(
					math.sin((math.rad(v3))) * number4,
					math.cos((math.rad(v3))) * number4,
					math.sin((math.rad(number))) * number3
				)
			end)))
			table.insert(clones, clone3)
		end

		os.clock()
		local heartbeatConnection = nil

		local function clear()
			if flag then
				return
			end

			if v2 then
				flag = true
				task.spawn(function()
					v2:Set(player.Direction.LookVector * 110 * 1.25 * 5 * 0.05)
					wait()
					v2:Destroy()
				end)
			end

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end

			for _, connection in connections do
				connection:Disconnect()
			end

			for _, folder2 in clones do
				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end
			end

			local folder2 = clone2

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			local player3 = player.Player
			local Players2 = game:GetService("Players")

			if player3 == Players2.LocalPlayer then
				local folder3 = clone

				for _, effect in pairs(folder3:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				TweenService:Create(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
					FieldOfView = 70
				}):Play()
				task.delay(0.5, function()
					RunService:UnbindFromRenderStep("Speed Camera Effect" .. GUID)
				end)
			end
		end

		local lastTime = os.clock()
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			if workspace:Raycast(root.Position, root.Velocity * dt, raycastParams) then
				clear()
				heartbeatConnection:Disconnect()
			end

			if flightTime <= os.clock() - lastTime then
				heartbeatConnection:Disconnect()
			end
		end)
		task.spawn(function()
			local count = 0

			for _ = 1, 9 do
				for _ = 1, 3 do
					count += 1
					local v3 = player.FeathersCF[count]
					local clone3 = eagleV["Feather" .. math.random(1, 4)]:Clone()
					clone3.CFrame = v3 * CFrame.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					) * CFrame.Angles(
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586),
						random:NextNumber(0, 6.283185307179586)
					)
					Util.SetParentOverrideWithColor(clone3, folder, player2, "EagleFruitVFXColor")
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = Vector3.new(
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1),
						random:NextNumber(-1, 1)
					).Unit * random:NextNumber(70, 200)
					local number = random:NextNumber(0.4, 0.9)
					bodyVelocity.MaxForce = createVector(700000, 700000, 700000)
					Util.SetParentOverrideWithColor(bodyVelocity, clone3, player2, "EagleFruitVFXColor")
					TweenService:Create(bodyVelocity, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {
						Velocity = createVector(0, -30, 0)
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(1.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Orientation = Vector3.new(math.random(0, 360), math.random(0, 360), math.random(0, 360))
					}):Play()
					local raycastResult = nil
					local heartbeatConnection2 = nil
					heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
						raycastResult = workspace:Raycast(clone3.Position, clone3.Velocity * dt, raycastParams)

						if raycastResult then
							heartbeatConnection2:Disconnect()
							clone3.Anchored = true
							bodyVelocity:Destroy()
						end
					end)
					local v6 = clone3
					task.delay(number, function()
						heartbeatConnection2:Disconnect()
						local folder2 = v6

						for i, effect in pairs(folder2:GetDescendants()) do
							if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
								effect.Enabled = false
							end
						end

						local clone4 = eagleV.Explode:Clone()
						clone4.CFrame = v6.CFrame
						Util.SetParentOverrideWithColor(clone4, folder, player2, "EagleFruitVFXColor")
						ParticleState(clone4)
						Util.Sound:Play(
							"EagleFt_V_Spear_Feather_Explosions_0" .. tostring(math.random(1, 10)) .. "_V1",
							clone4.Position
						)
						TweenService:Create(clone4.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Brightness = 0,
							Range = 0
						}):Play()
					end)
				end

				task.wait(0.02)
			end
		end)
		task.wait(flightTime)
		clear()
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local root2 = player.Root
		local clone = eagleV.SlashesModel:Clone()
		local slashes = clone.Slashes

		for _, emitter in pairs(slashes:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Rate *= 1.4
			end
		end

		slashes.Weld.Part0 = root2
		Util.SetParentOverrideWithColor(clone, folder, player2, "EagleFruitVFXColor")
		task.spawn(function()
			for _ = 1, 6 do
				Util.Sound:Play("EagleFt_X_TargetHit_StabCut_0" .. tostring(math.random(1, 10)) .. "_V1", root2)
				task.wait(0.1)
			end
		end)

		for _, effect in pairs(slashes:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		task.delay(0.4, function()
			clone:ScaleTo(1.4)
			task.wait(0.3)
			local folder2 = slashes

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	elseif stage == 3 then
		local rayResult = player.RayResult
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player2, "EagleFruitVFXColor")
		Util.Debris:AddItem(folder, 5)
		local clone = eagleV.FloorHit:Clone()
		clone.CFrame = CFrame.lookAt(rayResult.Position, rayResult.Position + rayResult.Normal)
		Util.SetParentOverrideWithColor(clone, folder, player2, "EagleFruitVFXColor")
		ParticleState(clone)
	end
end