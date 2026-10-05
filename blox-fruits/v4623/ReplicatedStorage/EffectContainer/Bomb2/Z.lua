local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mouse = require(ReplicatedStorage.Mouse)
local localPlayer = Players.LocalPlayer
local Util = require(ReplicatedStorage:WaitForChild("Util"))

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

local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Enemies }
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
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Z = FX:WaitForChild("BombRework").Z
return function(player)
	local state = player.State
	local character = player.Character
	local mouse = player.Mouse
	local player2 = player.Player

	if state == "End" and v3[character] ~= "Start" then
		return
	end

	local v4 = player.isMobile and Mouse or localPlayer:GetMouse()

	if typeof(mouse) == "Instance" or mouse:IsA("Vector3Value") then
		v4 = setmetatable({}, {
			__index = function(_, p)
				if p == "Hit" then
					return CFrame.new(mouse.Value)
				end
			end
		})
	end

	v3[character] = state

	if state == "End" then
		return
	end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local position = humanoidRootPart.Position

	if (workspace.CurrentCamera.CFrame.p - position).Magnitude > 800 then
		return
	end

	local v5 = humanoidRootPart.Position + (v4.Hit.Position - humanoidRootPart.Position) * 1.2
	local raycastResult = workspace:Raycast(
		v4.Hit.Position + createVector(0, 0.1, 0),
		createVector(0, -5, 0),
		raycastParams
	)
	local position3 = raycastResult and raycastResult.Position + raycastResult.Normal * 3 or v5

	if (position3 - humanoidRootPart.Position).Magnitude > 100 then
		position3 = humanoidRootPart.Position + (position3 - humanoidRootPart.Position).Unit * 100
	end

	local clone = Z.BombCentre:Clone()
	clone.Position = position3
	local v7 = Util.Sound:Play("BF_NewFruit_Z_Held_01", clone)
	Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		position3 = humanoidRootPart.Position + (v4.Hit.Position - humanoidRootPart.Position) * 1.2
		local raycastResult2 = workspace:Raycast(
			v4.Hit.Position + createVector(0, 0.1, 0),
			createVector(0, -5, 0),
			raycastParams
		)
		position3 = raycastResult2 and raycastResult2.Position + raycastResult2.Normal * 3 or position3

		if (position3 - humanoidRootPart.Position).Magnitude > 100 then
			position3 = humanoidRootPart.Position + (position3 - humanoidRootPart.Position).Unit * 100
		end

		clone.Position = position3
	end)
	local connectionsByClone = {}

	for _, child in Z.BombParts:GetChildren() do
		local clone2 = child:Clone()
		local number = random:NextNumber(10, 20)
		local lookVector = (CFrame.new(position3) * CFrame.Angles(
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			random:NextNumber(-3.141592653589793, 3.141592653589793)
		)).LookVector
		local raycastResult2 = workspace:Raycast(position3, lookVector * number, raycastParams)
		local position2 = raycastResult2 and raycastResult2.Position or position3 + lookVector * number
		clone2.Position = position2
		clone2.Orientation = Vector3.new(
			random:NextNumber(0, 360),
			random:NextNumber(0, 360),
			random:NextNumber(0, 360)
		)
		clone2.Color = Util.WrapColor3Constructor(Color3.new(0.329412, 0.419608, 1), player2, "BombFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		local total = 0
		connectionsByClone[clone2] = RunService.Heartbeat:Connect(function(dt)
			raycastResult2 = workspace:Raycast(position3, lookVector * number, raycastParams)
			total += 180 * dt
			position2 = raycastResult2 and raycastResult2.Position or position3 + lookVector * number
			clone2.Orientation += Vector3.new(0, 180 * dt, 0)
			clone2.Position = position2 + Vector3.new(0, math.sin((math.rad(total))) * 0.6, 0)
		end)
		local clone3 = Z.BombPartAppear:Clone()
		clone3.Position = position2
		clone3.Size = clone2.Size
		Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(clone3), clone3.Destroy, clone3)
	end

	repeat
		task.wait()
	until character == nil or character.Parent == nil or v3[character] == "End"

	if v7 then
		Util.Sound:FadeOut(v7, 0.2)
	end

	heartbeatConnection:Disconnect()
	v3[character] = nil

	if character == nil or character.Parent == nil then
		for k, connection in connectionsByClone do
			connection:Disconnect()
			k:Destroy()
		end
	else
		for k, connection in connectionsByClone do
			connection:Disconnect()
			TweenService:Create(k, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Position = position3
			}):Play()
			task.delay(0.1, k.Destroy, k)
		end

		task.delay(ParticleState(clone, false), clone.Destroy, clone)
		task.wait(0.1)
		local clone2 = Z.Combine:Clone()
		clone2.Position = position3
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		Util.Sound:Play("BF_NewFruit_Z_Activate_Fuse_01", position3)
		task.delay(ParticleState(clone2), clone2.Destroy, clone2)
		local clone3 = Z.Bomb:Clone()
		local bomb = clone3.Bomb
		bomb.Anchored = true
		bomb.Position = position3
		Util.SetParentOverrideWithColor(bomb, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		Util.Debris:AddItem(clone3, 5)
		task.wait(0.012)
		bomb.Anchored = false
		ParticleState(bomb.Spark, true)
		task.wait(0.108)
		TweenService:Create(bomb.Spark.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
			Brightness = 0,
			Range = 0
		}):Play()
		task.delay(ParticleState(bomb, false), bomb.Destroy, bomb)

		for _, part in pairs(clone3:GetChildren()) do
			if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
				continue
			end

			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
		end

		bomb.CanCollide = false
		Util.Sound:Play("BF_NewFruit_Z_Explosion_Generic_01", bomb.Position)
		local clone4 = Z.Explosion:Clone()
		clone4.Position = bomb.Position
		Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.delay(ParticleState(clone4), clone4.Destroy, clone4)
		local raycastResult2 = workspace:Raycast(bomb.Position, createVector(0, -10, 0), raycastParams)

		if raycastResult2 then
			local clone5 = Z.FloorScorch:Clone()
			clone5.CFrame = CFrame.lookAt(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
				-1.5707963267948966,
				0,
				0
			)
			Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			task.delay(ParticleState(clone5), clone5.Destroy, clone5)
		end

		local clone5 = Z.Cylinder:Clone()
		clone5.Position = bomb.Position
		Util.SetParentOverrideWithColor(clone5, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		task.spawn(function()
			for _, texture in v2 do
				clone5.Decal.Texture = texture
				RunService.Heartbeat:Wait()
			end

			clone5:Destroy()
		end)
		local workspace2 = workspace
		local raycastResult3 = workspace2:Raycast(
			v4.Hit.Position + createVector(0, 0.1, 0),
			createVector(0, -5, 0),
			raycastParams
		)

		for _ = 1, 7 do
			local clone6 = Z.CloudMesh:Clone()
			clone6.Position = bomb.Position + Vector3.new(
				random:NextNumber(-20, 20),
				random:NextNumber(-20, 20),
				random:NextNumber(-20, 20)
			)
			clone6.Orientation = Vector3.new(
				random:NextNumber(0, 360),
				random:NextNumber(0, 360),
				random:NextNumber(0, 360)
			)
			clone6.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(4, 5)
			local lookVector = raycastResult3 and (CFrame.lookAt(
				raycastResult3.Position,
				raycastResult3.Position + raycastResult3.Normal
			) * CFrame.Angles(
				math.rad((random:NextNumber(-90, 90))),
				math.rad((random:NextNumber(-90, 90))),
				(math.rad((random:NextNumber(-90, 90))))
			)).LookVector or Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
			TweenService:Create(
				clone6,
				TweenInfo.new(random:NextNumber(0.45, 0.65), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Position = clone6.Position + lookVector * random:NextNumber(10, 15),
					Orientation = clone6.Orientation + Vector3.new(
						random:NextNumber(-70, 70),
						random:NextNumber(-70, 70),
						random:NextNumber(-70, 70)
					)
				}
			):Play()
			TweenService:Create(clone6.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Scale = clone6.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(8, 10)
			}):Play()
			task.delay(0.15, function()
				TweenService:Create(
					clone6.Decal,
					TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
					{
						Color3 = Util.WrapColor3Constructor(Color3.new(0, 0, 0), player2, "BombFruitVFXColor")
					}
				):Play()
			end)
			Util.SetParentOverrideWithColor(clone6, workspace._WorldOrigin, player2, "BombFruitVFXColor")
			local v9 = clone6
			task.spawn(function()
				for k, texture in v do
					v9.Decal.Texture = texture
					RunService.Heartbeat:Wait()
				end

				v9:Destroy()
			end)
		end
	end
end