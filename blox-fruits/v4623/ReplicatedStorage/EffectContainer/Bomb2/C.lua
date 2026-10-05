local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
local localPlayer = Players.LocalPlayer
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage2:WaitForChild("Util"))

local function ParticleState(folder, enabled: boolean)
	local max = 0

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if enabled == nil then
			if not effect:IsA("ParticleEmitter") then
				continue
			end

			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end

		if not effect:IsA("ParticleEmitter") or effect.Lifetime.Max <= max then
			continue
		end

		max = effect.Lifetime.Max
	end

	return max
end

local FX = require(ReplicatedStorage2:WaitForChild("FX"))
local C = FX:WaitForChild("BombRework").C
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
local v = {
	"rbxassetid://73647294349229",
	"rbxassetid://85313759525368",
	"rbxassetid://124182135729886",
	"rbxassetid://126810897297121",
	"rbxassetid://91509806271907",
	"rbxassetid://90479186456505",
	"rbxassetid://111478021960545",
	"rbxassetid://72394462518441",
	"rbxassetid://124616265933473",
	"rbxassetid://117230838251776",
	""
}
local v2 = {
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://100647424634065",
	"rbxassetid://135530889139185",
	"rbxassetid://138511637855738",
	"rbxassetid://138511637855738",
	"rbxassetid://120749649345523",
	"rbxassetid://120749649345523",
	"rbxassetid://102310243857129",
	"rbxassetid://102310243857129",
	"rbxassetid://108474977001459",
	"rbxassetid://108474977001459",
	"rbxassetid://92213695816660",
	"rbxassetid://92213695816660",
	"rbxassetid://118643736609722",
	"rbxassetid://118643736609722",
	"rbxassetid://93828106193342",
	"rbxassetid://93828106193342",
	"rbxassetid://130925880037995",
	"rbxassetid://130925880037995",
	"rbxassetid://132445268949222",
	"rbxassetid://132445268949222",
	"rbxassetid://131755796674054",
	"rbxassetid://131755796674054",
	"rbxassetid://101329734542701",
	"rbxassetid://101329734542701",
	"rbxassetid://73441550360544",
	"rbxassetid://73441550360544"
}
local v3 = {
	"rbxassetid://116393957503079",
	"rbxassetid://80909680394785",
	"rbxassetid://95630632044819",
	"rbxassetid://108191552775354",
	"rbxassetid://89074170362017",
	"rbxassetid://71571417999265",
	"rbxassetid://80535182901890",
	"rbxassetid://77405538044765",
	"rbxassetid://103677931814244",
	"rbxassetid://106052936885775",
	"rbxassetid://120903577796175",
	"rbxassetid://131294518763834"
}
local random = Random.new()
local v4 = {
	Tap = function(player)
		local player2 = player.Player
		local character = player.Character
		local seed = player.Seed
		local started = player.Started
		local speed = player.Speed or 1.4
		local bombCount = player.BombCount or 18
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local position = humanoidRootPart.Position

		if (workspace.CurrentCamera.CFrame.p - position).Magnitude > 1200 then
			return
		end

		local tap = C.Tap
		local clone = tap.PreExplode:Clone()
		clone.Position = humanoidRootPart.Position
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(clone), clone.Destroy, clone)
		Util.Sound:Play("BF_NewFruit_C_Release_TapLaunch_01", humanoidRootPart.Position)
		task.wait(0.1)
		local clone2 = tap.PreExplode2:Clone()
		clone2.Position = humanoidRootPart.Position
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(clone2), clone2.Destroy, clone2)
		task.spawn(function()
			task.wait(0.05)
			local clone3 = tap.Shockwave:Clone()
			clone3.Position = humanoidRootPart.Position
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")

			for _, texture in v do
				clone3.Decal.Texture = texture
				task.wait()
			end

			clone3:Destroy()
		end)
		local random2 = Random.new(seed)
		local v5 = workspace:GetServerTimeNow() - started

		for i = 1, bombCount do
			local clone3 = tap.Bomb:Clone()
			local bomb = clone3.Bomb
			clone3:PivotTo(humanoidRootPart.CFrame)
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			Util.Debris:AddItem(clone3, 3)
			ParticleState(bomb, true)
			local now = os.clock()
			local raycastResult = nil
			local position2 = humanoidRootPart.Position
			local vector2 = Vector3.new(0, -workspace.Gravity * random2:NextNumber(0.4, 1), 0)
			local position3 = humanoidRootPart.Position
			local number = random2:NextNumber(0, 360)
			local number2 = random2:NextNumber(40, 60)
			local total = 0
			local heartbeatConnection = nil
			local v9 = (humanoidRootPart.Position + Vector3.new(
				math.sin((math.rad(number))) * number2,
				0,
				math.cos((math.rad(number))) * number2
			) - position3 - vector2 * 0.5) * speed
			local v13 = CFrame.Angles(0, 0, 1.5707963267948966)
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += 12.566370614359172 * dt
				local v14 = os.clock() - now
				local position4 = CFrame.new(vector2 * 0.5 * speed ^ 2 * v14 ^ 2 + v9 * v14 + position3).Position
				raycastResult = workspace:Raycast(position2, (position4 - position2) * 2.3, raycastParams)

				if raycastResult or v14 >= 1.5 then
					heartbeatConnection:Disconnect()
					task.delay(ParticleState(bomb, false), bomb.Destroy, bomb)

					for i2, part in pairs(clone3:GetChildren()) do
						if part:IsA("BasePart") or part:IsA("MeshPart") then
							part.Transparency = 1
						end
					end

					local position5 = raycastResult and raycastResult.Position or clone3:GetPivot().Position
					local clone4 = tap.Explosion:Clone()
					clone4.Position = raycastResult and raycastResult.Position or bomb.Position
					Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					Util.Sound:Play("BF_NewFruit_Z_Explosion_Generic_0" .. tostring(math.random(2, 5)), clone4.Position)

					if raycastResult then
						local clone5 = tap.FloorScorch:Clone()
						clone5.CFrame = CFrame.lookAt(
							raycastResult.Position,
							raycastResult.Position + raycastResult.Normal
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
						task.delay(ParticleState(clone5), clone5.Destroy, clone5)
					end

					local clone5 = tap.Cylinder:Clone()
					clone5.Position = bomb.Position
					Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					task.spawn(function()
						for k, texture in v3 do
							clone5.Decal.Texture = texture
							RunService.Heartbeat:Wait()
						end

						clone5:Destroy()
					end)

					for i2 = 1, 7 do
						local clone6 = tap.CloudMesh:Clone()
						clone6.Position = position5 + Vector3.new(
							random2:NextNumber(-10, 10),
							random2:NextNumber(-10, 10),
							random2:NextNumber(-10, 10)
						)
						clone6.Orientation = Vector3.new(
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360),
							random2:NextNumber(0, 360)
						)
						clone6.Mesh.Scale = createVector(1, 1, 1) * random2:NextNumber(2, 4)
						local lookVector = raycastResult and (CFrame.lookAt(
							raycastResult.Position,
							raycastResult.Position + raycastResult.Normal
						) * CFrame.Angles(
							math.rad((random2:NextNumber(-90, 90))),
							math.rad((random2:NextNumber(-90, 90))),
							(math.rad((random2:NextNumber(-90, 90))))
						)).LookVector or Vector3.new(
							random2:NextNumber(-1, 1),
							random2:NextNumber(-1, 1),
							random2:NextNumber(-1, 1)
						)
						TweenService:Create(
							clone6,
							TweenInfo.new(
								random2:NextNumber(0.45, 0.65),
								Enum.EasingStyle.Cubic,
								Enum.EasingDirection.Out
							),
							{
								Position = clone6.Position + lookVector * random2:NextNumber(10, 15),
								Orientation = clone6.Orientation + Vector3.new(
									random2:NextNumber(-70, 70),
									random2:NextNumber(-70, 70),
									random2:NextNumber(-70, 70)
								)
							}
						):Play()
						TweenService:Create(
							clone6.Mesh,
							TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Scale = clone6.Mesh.Scale + createVector(1, 1, 1) * random2:NextNumber(4, 7)
							}
						):Play()
						task.delay(0.15, function()
							TweenService:Create(
								clone6.Decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Color3 = Util.WrapColor3Constructor(
										Color3.new(0, 0, 0),
										player2,
										"BombFruitVFXColor"
									)
								}
							):Play()
						end)
						Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player2, "BombFruitVFXColor")
						local v16 = clone6
						task.spawn(function()
							for k, texture in v2 do
								v16.Decal.Texture = texture
								RunService.Heartbeat:Wait()
							end

							v16:Destroy()
						end)
					end
				else
					clone3:PivotTo(CFrame.new(position4) * CFrame.Angles(0, total, 0) * v13)
				end

				position2 = position4
			end)

			if v5 < i * 0.04 then
				task.wait(i * 0.04 - v5)
			end

			v5 = workspace:GetServerTimeNow() - started
		end
	end,
	Hold = function(player)
		local player2 = player.Player
		local _ = player.State
		local _ = player.Mode
		local character = player.Character
		local floorRay = player.FloorRay
		local bombs = player.Bombs
		character:WaitForChild("HumanoidRootPart")
		local hold = C.Hold
		local clone = hold.FloorAreaModel:Clone()
		clone:ScaleTo(60)
		local floorArea = clone.FloorArea
		floorArea.CFrame = CFrame.lookAt(floorRay.Position, floorRay.Position + floorRay.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(floorArea), clone.Destroy, clone)

		for _, bomb in pairs(bombs) do
			random:NextNumber(0, 360)
			random:NextNumber(0, 60)
			local ray = bomb.Ray
			local clone2 = hold.Warning:Clone()
			clone2.Position = ray.Position + ray.Normal * 8
			Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			local clone3 = hold.FloorBeam:Clone()
			clone3.Position = ray.Position
			clone3.Top.Position = ray.Position + ray.Normal * 30
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			TweenService:Create(clone3.Top, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = clone3.Position
			}):Play()
			TweenService:Create(clone3.Beam, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			Util.Sound:Play("BF_NewFruit_C_Plant_Mine_0" .. tostring(math.random(1, 3)), ray.Position)
			local v7 = bomb
			task.delay(0.2, function()
				local clone4 = hold.WarningBreak:Clone()
				clone4.Position = clone2.Position
				Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player2, "BombFruitVFXColor")
				task.delay(ParticleState(clone4), clone4.Destroy, clone4)
				clone2:Destroy()
				local clone5 = hold.SmallFloorArea:Clone()
				clone5.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
				task.wait((ParticleState(clone5)))
				clone5:Destroy()
				local position, clone6, v8, clone7, clone8

				if character == localPlayer.Character then
					position = clone2.Position
					clone6 = hold.BombHologram:Clone()
					clone6.Position = clone2.Position
					clone6.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(clone6, 30)
					Util.Sound:Play("BF_NewFruit_C_Idle_MineActive_Loop_01", clone6)
					Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					v8 = random:NextNumber(0, 360)
					clone7 = hold.BeamHologram:Clone()
					clone7.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal)
					Util.SetParentOverrideWithColor(clone7, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					TweenService:Create(clone7, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						CFrame = CFrame.lookAt(ray.Position + ray.Normal * 5, ray.Position + ray.Normal * 11)
					}):Play()

					for i, beam in clone7:GetDescendants() do
						if not beam:IsA("Beam") then
							continue
						end

						TweenService:Create(
							beam,
							TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Width0 = 10,
								Width1 = 10
							}
						):Play()
						local v9 = beam
						task.delay(0.3, function()
							TweenService:Create(
								v9,
								TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Brightness = 0,
									LightEmission = 1
								}
							):Play()
						end)
					end

					clone8 = hold.FloorHologram:Clone()
					clone8.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
					Util.SetParentOverrideWithColor(clone8, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					task.delay(ParticleState(clone8), clone8.Destroy, clone8)
				else
					v8 = nil
					clone6 = nil
					position = nil
					clone7 = nil
					clone8 = nil
				end

				local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					if character == localPlayer.Character or character == localPlayer.CharacterAdded:Wait() then
						v8 += 180 * dt
						clone6.Position = position + Vector3.new(0, math.sin((math.rad(v8))), 0)
						clone6.Orientation += Vector3.new(0, 250 * dt, 0)
					end
				end)
				local changedConnection = nil
				changedConnection = v7.Part.Changed:Connect(function(p)
					if p == "Name" then
						changedConnection:Disconnect()
						heartbeatConnection:Disconnect()

						if character == localPlayer.Character then
							clone6:Destroy()
							clone7:Destroy()
							clone8:Destroy()
						end

						local clone9 = hold.Bomb:Clone()
						local bomb2 = clone9.Bomb
						clone9:PivotTo(CFrame.new(ray.Position))
						clone9.Parent = workspace._WorldOrigin
						Util.Debris:AddItem(clone9, 5)
						task.spawn(function()
							local pivot = clone9:GetPivot()

							for i = 1, math.floor(0.1 / RunService.Heartbeat:Wait()) do
								pivot += createVector(0, 100, 0) * RunService.Heartbeat:Wait()
								clone9:PivotTo(pivot)
							end
						end)
						Util.Sound:Play("BF_NewFruit_C_MineExplode_0" .. tostring(math.random(1, 4)), ray.Position)
						task.wait(0.1)

						for i, part in pairs(clone9:GetChildren()) do
							if part:IsA("BasePart") or part:IsA("MeshPart") then
								part.Transparency = 1
							end
						end

						task.delay(ParticleState(bomb2, false), bomb2.Destroy, bomb2)
						local clone10 = hold.Explosion:Clone()
						clone10.Position = bomb2.Position
						Util.SetParentOverrideWithColor(clone10, workspace._WorldOrigin, player2, "BombFruitVFXColor")
						local clone11 = hold.Cylinder:Clone()
						clone11.Position = bomb2.Position
						Util.SetParentOverrideWithColor(clone11, workspace._WorldOrigin, player2, "BombFruitVFXColor")
						task.spawn(function()
							for k, texture in v3 do
								clone11.Decal.Texture = texture
								RunService.Heartbeat:Wait()
							end

							clone11:Destroy()
						end)

						for i = 1, 7 do
							local clone12 = hold.CloudMesh:Clone()
							clone12.Position = bomb2.Position + Vector3.new(
								random:NextNumber(-10, 10),
								random:NextNumber(-10, 10),
								random:NextNumber(-10, 10)
							)
							clone12.Orientation = Vector3.new(
								random:NextNumber(0, 360),
								random:NextNumber(0, 360),
								random:NextNumber(0, 360)
							)
							clone12.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(2, 4)
							local raycastResult = workspace:Raycast(
								bomb2.Position + createVector(0, 1, 0),
								createVector(-0, -5, -0),
								raycastParams
							)
							local lookVector = raycastResult and (CFrame.lookAt(
								raycastResult.Position,
								raycastResult.Position + raycastResult.Normal
							) * CFrame.Angles(
								math.rad((random:NextNumber(-90, 90))),
								math.rad((random:NextNumber(-90, 90))),
								(math.rad((random:NextNumber(-90, 90))))
							)).LookVector or Vector3.new(
								random:NextNumber(-1, 1),
								random:NextNumber(-1, 1),
								random:NextNumber(-1, 1)
							)
							TweenService:Create(
								clone12,
								TweenInfo.new(
									random:NextNumber(0.45, 0.65),
									Enum.EasingStyle.Cubic,
									Enum.EasingDirection.Out
								),
								{
									Position = clone12.Position + lookVector * random:NextNumber(10, 15),
									Orientation = clone12.Orientation + Vector3.new(
										random:NextNumber(-70, 70),
										random:NextNumber(-70, 70),
										random:NextNumber(-70, 70)
									)
								}
							):Play()
							TweenService:Create(
								clone12.Mesh,
								TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Scale = clone12.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(4, 7)
								}
							):Play()
							task.delay(0.15, function()
								TweenService:Create(
									clone12.Decal,
									TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
									{
										Color3 = Util.WrapColor3Constructor(
											Color3.new(0, 0, 0),
											player2,
											"BombFruitVFXColor"
										)
									}
								):Play()
							end)
							Util.SetParentOverrideWithColor(
								clone12,
								workspace._WorldOrigin,
								player2,
								"BombFruitVFXColor"
							)
							local v10 = clone12
							task.spawn(function()
								for k, texture in v2 do
									v10.Decal.Texture = texture
									RunService.Heartbeat:Wait()
								end

								v10:Destroy()
							end)
						end

						task.delay(ParticleState(clone10), clone10.Destroy, clone10)
						local clone12 = hold.FloorScorch:Clone()
						clone12.CFrame = CFrame.lookAt(ray.Position, ray.Position + ray.Normal) * CFrame.Angles(
							-1.5707963267948966,
							0,
							0
						)
						Util.SetParentOverrideWithColor(clone12, workspace._WorldOrigin, player2, "BombFruitVFXColor")
						task.delay(ParticleState(clone12), clone12.Destroy, clone12)
					elseif p == "Parent" then
						changedConnection:Disconnect()
						heartbeatConnection:Disconnect()

						if character == localPlayer.Character or character == localPlayer.CharacterAdded:Wait() then
							clone6:Destroy()
							clone7:Destroy()
							clone8:Destroy()
						end
					end
				end)
			end)
		end
	end
}
return function(player)
	local player2 = player.Player
	local state = player.State
	local mode = player.Mode
	local character = player.Character

	if state == "End" then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	character:WaitForChild("Humanoid")

	if mode ~= "Start" then
		v4[mode](player)
		return
	end

	local clone = C.WindUp:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	task.delay(ParticleState(clone), clone.Destroy, clone)
	task.wait(0.15)
	local clone2 = C.SmileFace:Clone()
	clone2.Position = humanoidRootPart.Position + createVector(0, 24, 0)
	Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	task.delay(ParticleState(clone2.Attachment) - 0.5, function()
		task.wait((ParticleState(clone2.Disappear)))
		clone2:Destroy()
	end)
end