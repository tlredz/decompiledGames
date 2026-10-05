local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local mouse = Players.LocalPlayer:GetMouse()

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

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { workspace.Characters }
local v = {
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
local v2 = {
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
local FX = require(game.ReplicatedStorage.FX)
local X_OLD = FX:WaitForChild("Bomb2").X_OLD
local v3 = {}
return function(player)
	local state = player.State
	local character = player.Character

	if state ~= "Start" and v3[character] ~= "Start" then
		return
	end

	v3[character] = state

	if state ~= "Start" then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local rightHand = character:WaitForChild("RightHand")
	local position = (humanoidRootPart.CFrame * CFrame.new(0, -3, 0)).Position
	local clone = X_OLD.Combine:Clone()
	clone.Position = position
	clone.Parent = workspace._WorldOrigin
	task.delay(ParticleState(clone), clone.Destroy, clone)
	local clone2 = X_OLD.Bomb:Clone()
	clone2.Anchored = true
	clone2.Position = position
	clone2.Parent = workspace._WorldOrigin
	local v4 = humanoidRootPart.Position + (mouse.Hit.Position - humanoidRootPart.Position) * 1.2
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, v4 - humanoidRootPart.Position, raycastParams)
	local v5 = raycastResult and raycastResult.Position + raycastResult.Normal * 3 or v4

	if (v5 - humanoidRootPart.Position).Magnitude >= 150 then
		v5 = (v5 - humanoidRootPart.Position).Unit * 150 + humanoidRootPart.Position
	end

	local clone3 = X_OLD.CharacterWind:Clone()
	clone3.Weld.Part0 = humanoidRootPart
	clone3.Parent = workspace._WorldOrigin
	clone2.Transparency = 1
	clone2.Anchored = true
	clone2.CanCollide = false
	local clone4 = X_OLD.FloorExplosion:Clone()
	clone4.Position = clone2.Position
	clone4.Parent = workspace._WorldOrigin
	task.delay(ParticleState(clone4), clone4.Destroy, clone4)
	local raycastResult2 = workspace:Raycast(clone2.Position, createVector(0, -10, 0), raycastParams)

	if raycastResult2 then
		local clone5 = X_OLD.FloorScorch:Clone()
		clone5.CFrame = CFrame.lookAt(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone5.Parent = workspace._WorldOrigin
		task.delay(ParticleState(clone5), clone5.Destroy, clone5)
	end

	TweenService:Create(clone2.Spark.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
		Brightness = 0,
		Range = 0
	}):Play()
	task.delay(ParticleState(clone2, false), clone2.Destroy, clone2)

	repeat
		task.wait()
	until character == nil or character.Parent == nil or v3[character] ~= "Start"

	local v6 = v3[character]
	v3[character] = nil

	if character == nil or character.Parent == nil then
		clone2:Destroy()
		return
	end

	local v7 = humanoidRootPart.Position + (mouse.Hit.Position - humanoidRootPart.Position) * 1.2
	local raycastResult3 = workspace:Raycast(humanoidRootPart.Position, v7 - humanoidRootPart.Position, raycastParams)

	if raycastResult3 then
		v7 = raycastResult3.Position + raycastResult3.Normal * 3 or v7
	end

	if (v7 - humanoidRootPart.Position).Magnitude > 150 then
		local _ = humanoidRootPart.Position + (v7 - humanoidRootPart.Position).Unit * 150
	end

	local _ = humanoidRootPart.Position
	local vector2 = Vector3.new(0, -workspace.Gravity, 0)
	local position2 = humanoidRootPart.Position
	local _ = (v5 - position2 - vector2 * 0.5) * 2.5
	os.clock()
	local v8 = nil
	local lastTime = os.clock()
	local v9

	if typeof(v6) == "Instance" then
		v9 = v6
	else
		v9 = nil
	end

	local _ = rightHand.Position
	local clone5 = X_OLD.Bomb:Clone()
	clone5.Weld.Part0 = rightHand
	clone5.Parent = workspace._WorldOrigin
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		task.delay(ParticleState(clone3, false), clone3.Destroy, clone3)
		heartbeatConnection:Disconnect()

		if v9 then
			local head = v9:WaitForChild("Head")
			humanoidRootPart.AssemblyLinearVelocity = humanoidRootPart.CFrame.LookVector * 150
			local clone6 = X_OLD.HeadInsert:Clone()
			clone6.CFrame = head.CFrame
			clone6.Parent = workspace._WorldOrigin
			task.delay(ParticleState(clone6), clone6.Destroy, clone6)
			clone5.Weld.Part0 = head
			ParticleState(clone2, true)
			task.wait(0.2)
			clone5.Transparency = 1
			local clone7 = X_OLD.Explosion:Clone()
			clone7.Position = head.Position
			clone7.Parent = workspace._WorldOrigin
			task.delay(ParticleState(clone5, false), clone5.Destroy, clone5)
			task.delay(ParticleState(clone7), clone7.Destroy, clone7)
			local clone8 = X_OLD.Cylinder:Clone()
			clone8.Position = clone2.Position
			clone8.Parent = workspace._WorldOrigin
			task.spawn(function()
				for _, texture in v2 do
					clone8.Decal.Texture = texture
					RunService.Heartbeat:Wait()
				end

				clone8:Destroy()
			end)

			for _ = 1, 7 do
				local clone9 = X_OLD.CloudMesh:Clone()
				clone9.Position = head.Position + Vector3.new(
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20),
					random:NextNumber(-20, 20)
				)
				clone9.Orientation = Vector3.new(
					random:NextNumber(0, 360),
					random:NextNumber(0, 360),
					random:NextNumber(0, 360)
				)
				clone9.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(4, 5)
				local lookVector = raycastResult3 and (CFrame.lookAt(
					raycastResult3.Position,
					raycastResult3.Position + raycastResult3.Normal
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
					clone9,
					TweenInfo.new(random:NextNumber(0.45, 0.65), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Position = clone9.Position + lookVector * random:NextNumber(10, 15),
						Orientation = clone9.Orientation + Vector3.new(
							random:NextNumber(-70, 70),
							random:NextNumber(-70, 70),
							random:NextNumber(-70, 70)
						)
					}
				):Play()
				TweenService:Create(clone9.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					Scale = clone9.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(8, 10)
				}):Play()
				task.delay(0.15, function()
					TweenService:Create(
						clone9.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Color3 = Color3.new(0, 0, 0)
						}
					):Play()
				end)
				clone9.Parent = workspace._WorldOrigin
				local v11 = clone9
				task.spawn(function()
					for k, texture in v do
						v11.Decal.Texture = texture
						RunService.Heartbeat:Wait()
					end

					v11:Destroy()
				end)
			end

			local raycastResult4 = workspace:Raycast(clone5.Position, createVector(0, -10, 0), raycastParams)

			if raycastResult4 then
				local clone9 = X_OLD.FloorScorch:Clone()
				clone9.CFrame = CFrame.lookAt(raycastResult4.Position, raycastResult4.Position + raycastResult4.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				clone9.Parent = workspace._WorldOrigin
				task.delay(ParticleState(clone9), clone9.Destroy, clone9)
			end
		else
			clone5:Destroy()
			local clone6 = X_OLD.ThrowBomb:Clone()
			clone6.Position = rightHand.Position
			clone6.Parent = workspace._WorldOrigin
			ParticleState(clone6, true)
			local position3 = nil
			local position4 = rightHand.Position
			v5 = v6.EndGoal + v6.Direction.Unit * 100
			position2 = rightHand.Position
			local v10 = (v5 - position2 - vector2 * 0.5) * 2.5
			local raycastResult4 = nil
			lastTime = os.clock()
			local heartbeatConnection2 = nil
			heartbeatConnection2 = RunService.Heartbeat:Connect(function(_)
				v8 = os.clock() - lastTime
				position3 = CFrame.new(vector2 * 0.5 * 6.25 * v8 ^ 2 + v10 * v8 + position2).Position
				raycastResult4 = workspace:Raycast(position4, position3 - position4, raycastParams)

				if raycastResult4 or v8 >= 0.5 then
					heartbeatConnection2:Disconnect()
					task.delay(ParticleState(clone6, false), clone6.Destroy, clone6)
					TweenService:Create(clone6.Spark.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						Range = 0,
						Brightness = 0
					}):Play()
					clone6.Transparency = 1
					local clone7 = X_OLD.Explosion:Clone()
					clone7.Position = raycastResult4 and raycastResult4.Position or clone6.Position
					clone7.Parent = workspace._WorldOrigin
					task.delay(ParticleState(clone7), clone7.Destroy, clone7)
					local clone8 = X_OLD.Cylinder:Clone()
					clone8.Position = clone6.Position
					clone8.Parent = workspace._WorldOrigin
					task.spawn(function()
						for _, texture in v2 do
							clone8.Decal.Texture = texture
							RunService.Heartbeat:Wait()
						end

						clone8:Destroy()
					end)

					for _ = 1, 7 do
						local clone9 = X_OLD.CloudMesh:Clone()
						clone9.Position = clone6.Position + Vector3.new(
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20),
							random:NextNumber(-20, 20)
						)
						clone9.Orientation = Vector3.new(
							random:NextNumber(0, 360),
							random:NextNumber(0, 360),
							random:NextNumber(0, 360)
						)
						clone9.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(2, 3.5)
						local lookVector = raycastResult3 and (CFrame.lookAt(
							raycastResult3.Position,
							raycastResult3.Position + raycastResult3.Normal
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
							clone9,
							TweenInfo.new(
								random:NextNumber(0.45, 0.65),
								Enum.EasingStyle.Cubic,
								Enum.EasingDirection.Out
							),
							{
								Position = clone9.Position + lookVector * random:NextNumber(10, 15),
								Orientation = clone9.Orientation + Vector3.new(
									random:NextNumber(-70, 70),
									random:NextNumber(-70, 70),
									random:NextNumber(-70, 70)
								)
							}
						):Play()
						TweenService:Create(
							clone9.Mesh,
							TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
							{
								Scale = clone9.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(8, 10)
							}
						):Play()
						task.delay(0.15, function()
							TweenService:Create(
								clone9.Decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Color3 = Color3.new(0, 0, 0)
								}
							):Play()
						end)
						clone9.Parent = workspace._WorldOrigin
						local v12 = clone9
						task.spawn(function()
							for k, texture in v do
								v12.Decal.Texture = texture
								RunService.Heartbeat:Wait()
							end

							v12:Destroy()
						end)
					end

					if raycastResult4 then
						local clone9 = X_OLD.FloorScorch:Clone()
						clone9.CFrame = CFrame.lookAt(
							raycastResult4.Position,
							raycastResult4.Position + raycastResult4.Normal
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						clone9.Parent = workspace._WorldOrigin
						task.delay(ParticleState(clone9), clone9.Destroy, clone9)
					end
				end

				clone6.CFrame = CFrame.lookAt(position3, position4) * CFrame.Angles(0, 3.141592653589793, 0)
				position4 = position3
			end)
		end
	end)
end