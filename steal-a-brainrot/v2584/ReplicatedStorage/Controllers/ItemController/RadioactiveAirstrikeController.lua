local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("Lighting")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shake = require(ReplicatedStorage.Packages.Shake)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local _ = localPlayer.PlayerScripts
local _ = workspace.CurrentCamera
playerGui:WaitForChild("ToolsScreen")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local CharacterController = require(ReplicatedStorage.Controllers.CharacterController)
local _ = CharacterController.Controls
local random = Random.new()

local function SpinPart(instance)
	task.spawn(function()
		while instance.Parent do
			local tween = TweenService:Create(instance, TweenInfo.new(0.6), {
				Orientation = instance.Orientation + Vector3.new(math.random(0, 180), 0, math.random(0, 180))
			})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

local TweenService2 = game:GetService("TweenService")

local function CreateJet(mousePosition, _)
	local v = mousePosition + createVector(0, 75, 0)
	local v2 = 6.283185307179586 * math.random()
	local cframe = CFrame.Angles(0, v2, 0)
	local v3 = cframe * createVector(0, 0, 300)
	local v4 = cframe * createVector(0, 0, -2500)
	local v5 = v + v3
	local v6 = v + v4
	local clone = script["F22 Bombing Jet"]:Clone()
	local torso = clone:WaitForChild("Torso")
	torso.CFrame = CFrame.new(v5, v)
	clone.Parent = workspace
	local tween = TweenService2:Create(torso, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(v, v6)
	})
	tween:Play()
	tween.Completed:Wait()
	task.wait(2.5)
	local tween2 = TweenService2:Create(torso, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = CFrame.new(v6, v6 + (v6 - v))
	})
	tween2:Play()
	tween2.Completed:Wait()
	Debris:AddItem(clone)
end

local function DropBombsAt(finalPositions, mousePosition, _)
	local v = mousePosition + createVector(0, 20, 0)

	for _, item in finalPositions do
		local v2 = item
		task.delay(item.TweenTime, function()
			local finalPos = v2.FinalPos
			local scale = v2.Scale
			local vector2 = Vector3.new(finalPos.X, v.Y + 40, finalPos.Z)
			local clone = script.Bomb:Clone()
			clone.Position = vector2
			local number = random:NextNumber(0.95, 1.05)
			local unit = (finalPos - vector2).Unit
			clone.CFrame = CFrame.new(vector2, vector2 + unit)
			clone.Parent = workspace
			clone.MissileFull.PlaybackSpeed *= number
			clone.MissileFull:Play()
			local position = finalPos + createVector(0, 0.5, 0)
			local tween = TweenService2:Create(
				clone,
				TweenInfo.new(0.7 / number, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					Position = position
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				local clone2 = script.greenExplosion:Clone()
				clone2:PivotTo(CFrame.new(position + createVector(0, 3, 0)))
				clone2:ScaleTo(scale * 1.1)
				clone2.Parent = workspace
				clone2:WaitForChild("greenExplosion")

				for i, emitter in clone2:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
					end
				end

				Debris:AddItem(clone2, 8)
				clone.Transparency = 1
				Debris:AddItem(clone, 5)
				task.spawn(function()
					local v4 = Shake.new()
					v4.Amplitude = 0.4
					v4.Frequency = 0.05
					v4.FadeInTime = 2
					v4.FadeOutTime = 2
					v4.PositionInfluence = createVector(0, 0.15, 0)
					v4.RotationInfluence = createVector(1.25, 0, 4)
					ShakePresets.BindShakeToCamera(v4, workspace.CurrentCamera)
					v4:Start()
				end)
			end)
		end)
	end
end

Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p: string, p2)
	if p ~= "CreateRadioctivatePuddles" then
		return
	end

	CreateJet(p2.MousePosition, p2.JetUUID)
end)
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p: string, data)
	if p ~= "DropBombsAt" then
		return
	end

	DropBombsAt(data.FinalPositions, data.MousePosition, data.JetUUID)
end)
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p: string, p2)
	if p ~= "LockCircle" then
		return
	end

	local pos = p2.Pos
	local part = Instance.new("Part")
	part.Size = createVector(37, 0.1, 37)
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Material = Enum.Material.Neon
	part.Position = pos
	part.Transparency = 0.3
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	local cylinderMesh = Instance.new("CylinderMesh")
	cylinderMesh.Parent = part
	Debris:AddItem(part, 7)
	part.Parent = workspace
end)
return {}