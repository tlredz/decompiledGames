local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
Players.LocalPlayer:GetMouse()
local Mouse = require(ReplicatedStorage.Mouse)
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
local M1 = FX:WaitForChild("BombRework").M1
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace._WorldOrigin, workspace.Enemies }
local random = Random.new()
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
local v3 = {}
return function(player)
	local state = player.State
	local character = player.Character
	local player2 = player.Player
	local mouse = player.Mouse or Mouse

	if player.Mouse then
		mouse = setmetatable({}, {
			__index = function(_, p)
				if p ~= "Hit" then
					return
				end

				print("ye")
				return CFrame.new(player.Mouse.Value)
			end
		})
	end

	if state == "End" and v3[character] ~= "Start" then
		return
	end

	v3[character] = state

	if state == "End" then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local position = humanoidRootPart.Position

	if (workspace.CurrentCamera.CFrame.p - position).Magnitude > 700 then
		return
	end

	local rightHand = character:WaitForChild("RightHand")
	local clone = M1.BombModel:Clone()
	local bomb = clone.Bomb
	bomb.Anchored = true
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	local v4 = false
	task.spawn(function()
		while rightHand and rightHand:IsDescendantOf(workspace) and clone and clone:IsDescendantOf(workspace) and not v4 do
			clone:PivotTo(rightHand.CFrame)
			task.wait()
		end
	end)
	local clone2 = M1.BombAppear:Clone()
	clone2.Position = bomb.Position
	Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	Util.Sound:Play("BF_NewFruit_M1_Activate_01", bomb.Position)
	task.delay(ParticleState(clone2), clone2.Destroy, clone2)
	local lastTime = os.clock()
	local v5 = true
	local v6 = nil
	task.delay(0.2, function()
		if v5 == false then
			return
		end

		v6 = Util.Sound:Play("BF_NewFruit_M1_HeldFuse_01", bomb)
		TweenService:Create(v6, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()

		for _, child in M1.BombParts:GetChildren() do
			local clone3 = child:Clone()
			local number = random:NextNumber(20, 30)
			local lookVector = (CFrame.new(bomb.Position) * CFrame.Angles(
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793),
				random:NextNumber(-3.141592653589793, 3.141592653589793)
			)).LookVector
			local raycastResult = workspace:Raycast(bomb.Position, lookVector * number, raycastParams)
			local position2 = raycastResult and raycastResult.Position or bomb.Position + lookVector * number
			clone3.Position = position2
			clone3.Orientation = Vector3.new(
				random:NextNumber(0, 360),
				random:NextNumber(0, 360),
				random:NextNumber(0, 360)
			)
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Position = bomb.Position
			}):Play()
			local clone4 = M1.BombPartAppear:Clone()
			clone4.Position = position2
			clone4.Size = clone3.Size
			Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			task.delay(ParticleState(clone4), clone4.Destroy, clone4)
			task.delay(0.2, clone3.Destroy, clone3)
		end

		task.wait(0.2)
		clone:ScaleTo(1.4)
		local clone3 = M1.Combine:Clone()
		clone3.Position = bomb.Position
		Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(clone3), clone3.Destroy, clone3)
	end)

	repeat
		task.wait()
	until character.Parent == nil or character == nil or v3[character] == "End" or v3[character] == nil

	Util.Debris:AddItem(clone, 5)

	if v6 then
		Util.Sound:FadeOut(v6, 0.2)
	end

	if not v3[character] then
		clone:Destroy()
		return
	end

	ParticleState(bomb.Smoke, true)
	v5 = false
	v4 = true
	v3[character] = nil

	if character.Parent == nil or character == nil then
		task.wait(ParticleState(bomb, false), clone.Destroy, clone)
		return
	end

	local v7 = os.clock() - lastTime >= 0.2 and "Red" or "Normal"

	if v7 == "Normal" then
		ParticleState(bomb.Smoke, true)
	else
		ParticleState(bomb, true)
	end

	local cFrame = CFrame.lookAt(
		humanoidRootPart.Position,
		mouse.Hit.Position + Vector3.new(0, (mouse.Hit.Position - humanoidRootPart.Position).Magnitude / 5, 0)
	) * CFrame.new(0, 0, -4)
	local clone3 = M1.Throw:Clone()
	clone3.CFrame = cFrame
	Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	Util.Sound:Play("BF_NewFruit_M1_Launch_Release_0" .. tostring(math.random(1, 2)), clone3.Position)
	local v9 = Util.Sound:Play("BF_NewFruit_M1_CannonballFlying_01", bomb)
	task.delay(ParticleState(clone3), clone3.Destroy, clone3)
	local position2 = mouse.Hit.Position

	if (position2 - cFrame.Position).Magnitude >= 120 then
		position2 = (position2 - cFrame.Position).Unit * 120 + cFrame.Position
	end

	local position3 = bomb.Position
	local raycastResult = workspace:Raycast(bomb.Position, bomb.CFrame.LookVector * 10, raycastParams)
	local vector2 = Vector3.new(0, -workspace.Gravity, 0)
	local position4 = cFrame.Position
	local v10 = (position2 - position4 - vector2 * 0.5) * 1.7
	local v11 = nil
	local lastTime2 = os.clock()
	bomb.Weld:Destroy()
	bomb.Anchored = true
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		local v12 = os.clock() - lastTime2
		local v13 = position4 + v10 * v12 + vector2 * 0.5 * v12 * v12 * 1.7 * 1.7
		v11 = os.clock() - lastTime2
		raycastResult = workspace:Raycast(bomb.Position, v13 - position3, raycastParams)

		if raycastResult or v11 >= 0.8 then
			heartbeatConnection:Disconnect()
			task.delay(ParticleState(bomb, false), clone.Destroy, clone)
			TweenService:Create(bomb.Spark.PointLight, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				Range = 0,
				Brightness = 0
			}):Play()

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") or part:IsA("MeshPart") then
					part.Transparency = 1
				end
			end

			if v9 then
				Util.Sound:FadeOut(v9, 0.01)
			end

			local clone4 = M1[v7 .. "Explosion"]:Clone()
			clone4.Position = raycastResult and raycastResult.Position or bomb.Position
			Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			Util.Sound:Play("BF_NewFruit_Z_Explosion_Generic_01", clone4.Position)
			local v14 = v7 == "Normal" and 1 or 1.5
			local clone5 = M1.Cylinder:Clone()
			clone5.Position = bomb.Position
			clone5.Mesh.Scale = clone5.Mesh.Scale * v14
			Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			task.spawn(function()
				for _, texture in v2 do
					clone5.Decal.Texture = texture
					RunService.Heartbeat:Wait()
				end

				clone5:Destroy()
			end)
			pcall(function()
				for _ = 1, 7 do
					local clone6 = M1.CloudMesh:Clone()
					clone6.Position = bomb.Position + Vector3.new(
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10),
						random:NextNumber(-10, 10)
					) * v14
					clone6.Orientation = Vector3.new(
						random:NextNumber(0, 360),
						random:NextNumber(0, 360),
						random:NextNumber(0, 360)
					)
					clone6.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(1, 2) * v14
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
						clone6,
						TweenInfo.new(random:NextNumber(0.45, 0.65), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Position = clone6.Position + lookVector * random:NextNumber(4, 8) * v14,
							Orientation = clone6.Orientation + Vector3.new(
								random:NextNumber(-70, 70),
								random:NextNumber(-70, 70),
								random:NextNumber(-70, 70)
							)
						}
					):Play()
					TweenService:Create(
						clone6.Mesh,
						TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Scale = clone6.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(4.5, 7) * v14
						}
					):Play()

					if not player.boss then
						local v15 = clone6
						task.delay(0.15, function()
							TweenService:Create(
								v15.Decal,
								TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
								{
									Color3 = v7 == "Normal" and Util.WrapColor3Constructor(
										Color3.new(0, 0, 0),
										player2,
										"BombFruitVFXColor"
									) or Util.WrapColor3Constructor(
										Color3.new(0.172549, 0.0470588, 0.0470588),
										player2,
										"BombFruitVFXColor"
									)
								}
							):Play()
						end)
					end

					Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player2, "BombFruitVFXColor")
					task.spawn(function()
						if not player.boss then
							for k, texture in v do
								clone6.Decal.Texture = texture
								RunService.Heartbeat:Wait()
							end
						end

						clone6:Destroy()
					end)
				end
			end)
			task.delay(ParticleState(clone4), clone4.Destroy, clone4)

			if raycastResult then
				local clone6 = M1.FloorScorch:Clone()
				clone6.CFrame = CFrame.lookAt(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player2, "BombFruitVFXColor")
				task.delay(ParticleState(clone6), clone6.Destroy, clone6)
			end
		end

		local position5 = CFrame.new(vector2 * 0.5 * 2.8899999999999997 * v11 ^ 2 + v10 * v11 + position4).Position
		bomb.CFrame = CFrame.lookAt(position5, position3) * CFrame.Angles(0, 3.141592653589793, 0)
		position3 = position5
	end)
end