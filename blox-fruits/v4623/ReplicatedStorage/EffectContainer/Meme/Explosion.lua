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

			effect:Emit(effect:GetAttribute("EmitCount") or 0)
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

local function ParentEffect(p, p2)
	if p2 then
		Util.SetParentOverrideWithColor(p, workspace._WorldOrigin, p2, "BombFruitVFXColor")
		return p
	end

	p.Parent = workspace._WorldOrigin
	return p
end

local function ResolveExplosionPosition(part)
	if typeof(part) == "Instance" and part:IsA("BasePart") then
		return part.Position
	end

	if typeof(part) == "Vector3" then
		return part
	end

	if typeof(part) == "CFrame" then
		return part.Position
	end

	return nil
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

local function PlayExplosionAtPosition(position: Vector3, player)
	local raycastResult = workspace:Raycast(position + createVector(0, 0.1, 0), createVector(0, -5, 0), raycastParams)
	local clone = Z.Combine:Clone()
	clone.Position = position

	if player then
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player, "BombFruitVFXColor")
	else
		clone.Parent = workspace._WorldOrigin
	end

	Util.Sound:Play("BF_NewFruit_Z_Activate_Fuse_01", position)
	task.delay(ParticleState(clone), clone.Destroy, clone)
	task.wait(0.012)
	task.wait(0.108)
	Util.Sound:Play("BF_NewFruit_Z_Explosion_Generic_01", clone.Position)
	local clone2 = Z.Explosion:Clone()
	clone2.Position = clone.Position

	if player then
		Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player, "BombFruitVFXColor")
	else
		clone2.Parent = workspace._WorldOrigin
	end

	task.delay(ParticleState(clone2), clone2.Destroy, clone2)
	local raycastResult2 = workspace:Raycast(clone.Position, createVector(0, -10, 0), raycastParams)

	if raycastResult2 then
		local clone3 = Z.FloorScorch:Clone()
		clone3.CFrame = CFrame.lookAt(raycastResult2.Position, raycastResult2.Position + raycastResult2.Normal) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)

		if player then
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player, "BombFruitVFXColor")
		else
			clone3.Parent = workspace._WorldOrigin
		end

		task.delay(ParticleState(clone3), clone3.Destroy, clone3)
	end

	local clone3 = Z.Cylinder:Clone()
	clone3.Position = clone.Position

	if player then
		Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player, "BombFruitVFXColor")
	else
		clone3.Parent = workspace._WorldOrigin
	end

	task.spawn(function()
		for _, texture in v2 do
			if clone3 and clone3.Parent then
				if clone3:FindFirstChild("Decal") then
					clone3.Decal.Texture = texture
				end

				RunService.Heartbeat:Wait()
			else
				break
			end
		end

		if clone3 then
			clone3:Destroy()
		end
	end)

	for _ = 1, 7 do
		local clone4 = Z.CloudMesh:Clone()
		clone4.Position = clone.Position + Vector3.new(
			random:NextNumber(-20, 20),
			random:NextNumber(-20, 20),
			random:NextNumber(-20, 20)
		)
		clone4.Orientation = Vector3.new(
			random:NextNumber(0, 360),
			random:NextNumber(0, 360),
			random:NextNumber(0, 360)
		)
		clone4.Mesh.Scale = createVector(1, 1, 1) * random:NextNumber(4, 5)
		local lookVector = raycastResult and (CFrame.lookAt(
			raycastResult.Position,
			raycastResult.Position + raycastResult.Normal
		) * CFrame.Angles(
			math.rad((random:NextNumber(-90, 90))),
			math.rad((random:NextNumber(-90, 90))),
			(math.rad((random:NextNumber(-90, 90))))
		)).LookVector or Vector3.new(random:NextNumber(-1, 1), random:NextNumber(-1, 1), random:NextNumber(-1, 1))
		TweenService:Create(
			clone4,
			TweenInfo.new(random:NextNumber(0.45, 0.65), Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{
				Position = clone4.Position + lookVector * random:NextNumber(10, 15),
				Orientation = clone4.Orientation + Vector3.new(
					random:NextNumber(-70, 70),
					random:NextNumber(-70, 70),
					random:NextNumber(-70, 70)
				)
			}
		):Play()
		TweenService:Create(clone4.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Scale = clone4.Mesh.Scale + createVector(1, 1, 1) * random:NextNumber(8, 10)
		}):Play()

		if player then
			local v4 = clone4
			task.delay(0.15, function()
				if v4 and v4.Parent and v4:FindFirstChild("Decal") then
					TweenService:Create(
						v4.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{
							Color3 = Util.WrapColor3Constructor(Color3.new(0, 0, 0), player, "BombFruitVFXColor")
						}
					):Play()
				end
			end)
		end

		if player then
			Util.SetParentOverrideWithColor(clone4, workspace._WorldOrigin, player, "BombFruitVFXColor")
		else
			clone4.Parent = workspace._WorldOrigin
		end

		task.spawn(function()
			for k, texture in v do
				if clone4 and clone4.Parent then
					if clone4:FindFirstChild("Decal") then
						clone4.Decal.Texture = texture
					end

					RunService.Heartbeat:Wait()
				else
					break
				end
			end

			if clone4 then
				clone4:Destroy()
			end
		end)
	end
end

return function(player)
	local state = player.State
	local character = player.Character
	local mouse = player.Mouse
	local player2 = player.Player
	local position = player.Position

	if typeof(position) == "Instance" and position:IsA("BasePart") then
		position = position.Position
	elseif typeof(position) ~= "Vector3" then
		if typeof(position) == "CFrame" then
			position = position.Position
		else
			position = nil
		end
	end

	if state == "End" and position then
		PlayExplosionAtPosition(position, player2)
		return
	end

	if state == "End" and v3[character] ~= "Start" then
		return
	end

	local v4 = player.isMobile and Mouse or localPlayer:GetMouse()

	if typeof(mouse) == "Instance" and mouse:IsA("Vector3Value") then
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
	local position2 = humanoidRootPart.Position

	if (workspace.CurrentCamera.CFrame.Position - position2).Magnitude > 800 then
		return
	end

	local v5 = humanoidRootPart.Position + (v4.Hit.Position - humanoidRootPart.Position) * 1.2
	local raycastResult = workspace:Raycast(
		v4.Hit.Position + createVector(0, 0.1, 0),
		createVector(0, -5, 0),
		raycastParams
	)
	local position4 = raycastResult and raycastResult.Position + raycastResult.Normal * 3 or v5

	if (position4 - humanoidRootPart.Position).Magnitude > 100 then
		position4 = humanoidRootPart.Position + (position4 - humanoidRootPart.Position).Unit * 100
	end

	local clone = Z.BombCentre:Clone()
	clone.Position = position4
	local v7 = Util.Sound:Play("BF_NewFruit_Z_Held_01", clone)

	if player2 then
		Util.SetParentOverrideWithColor(clone, workspace._WorldOrigin, player2, "BombFruitVFXColor")
	else
		clone.Parent = workspace._WorldOrigin
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		position4 = humanoidRootPart.Position + (v4.Hit.Position - humanoidRootPart.Position) * 1.2
		local raycastResult2 = workspace:Raycast(
			v4.Hit.Position + createVector(0, 0.1, 0),
			createVector(0, -5, 0),
			raycastParams
		)
		position4 = raycastResult2 and raycastResult2.Position + raycastResult2.Normal * 3 or position4

		if (position4 - humanoidRootPart.Position).Magnitude > 100 then
			position4 = humanoidRootPart.Position + (position4 - humanoidRootPart.Position).Unit * 100
		end

		clone.Position = position4
	end)
	local connectionsByClone = {}

	for _, child in Z.BombParts:GetChildren() do
		local clone2 = child:Clone()
		local number = random:NextNumber(10, 20)
		local lookVector = (CFrame.new(position4) * CFrame.Angles(
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			random:NextNumber(-3.141592653589793, 3.141592653589793),
			random:NextNumber(-3.141592653589793, 3.141592653589793)
		)).LookVector
		local raycastResult2 = workspace:Raycast(position4, lookVector * number, raycastParams)
		local position3 = raycastResult2 and raycastResult2.Position or position4 + lookVector * number
		clone2.Position = position3
		clone2.Orientation = Vector3.new(
			random:NextNumber(0, 360),
			random:NextNumber(0, 360),
			random:NextNumber(0, 360)
		)
		clone2.Color = Util.WrapColor3Constructor(Color3.new(0.329412, 0.419608, 1), player2, "BombFruitVFXColor")

		if player2 then
			Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		else
			clone2.Parent = workspace._WorldOrigin
		end

		local total = 0
		connectionsByClone[clone2] = RunService.Heartbeat:Connect(function(dt)
			raycastResult2 = workspace:Raycast(position4, lookVector * number, raycastParams)
			total += 180 * dt
			position3 = raycastResult2 and raycastResult2.Position or position4 + lookVector * number
			clone2.Orientation += Vector3.new(0, 180 * dt, 0)
			clone2.Position = position3 + Vector3.new(0, math.sin((math.rad(total))) * 0.6, 0)
		end)
		local clone3 = Z.BombPartAppear:Clone()
		clone3.Position = position3
		clone3.Size = clone2.Size

		if player2 then
			Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player2, "BombFruitVFXColor")
		else
			clone3.Parent = workspace._WorldOrigin
		end

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
				Position = position4
			}):Play()
			task.delay(0.1, k.Destroy, k)
		end

		task.delay(ParticleState(clone, false), clone.Destroy, clone)
		task.wait(0.1)
		PlayExplosionAtPosition(position4, player2)
	end
end