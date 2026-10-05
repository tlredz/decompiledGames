local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
game:GetService("RunService")
local ParticleTween = require(ReplicatedStorage.CAM.Global.ParticleTween)
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function QuadBezier(p, p2, p3, p4)
	local v2 = p2 + (p3 - p2) * p
	return v2 + (p3 + (p4 - p3) * p - v2) * p
end

local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local v2 = {
	FadeInTime = 0,
	Frequency = 0.125,
	Amplitude = 0.25,
	SustainTime = 10,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.15, 0.15, 0.15),
	PositionInfluence = createVector(1, 1, 1)
}
game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(game.Players.LocalPlayer.Name)
return function(instance, p, p2)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" and p ~= "End" then
		return
	end

	local name = string.format("%s RampantArcRampage", instance.Name)

	if p == "Windup" then
		vfxUtility.PlaySound(sounds, "PS2bloodsickRARstart", humanoidRootPart, true)
	elseif p == "Start" then
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
		DebrisModule:AddItem(folder, 15)
		local clone = assets.SlashEnable720:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		ParticleTween:ResizeParticles(clone, 5, 3, "Sine", "Out")
		local raycastResult = workspace:Raycast(
			clone.Position + createVector(0, 5, 0),
			-clone.CFrame.UpVector * 10,
			raycastParams
		)

		if raycastResult then
			local clone2 = assets.SlashEnableGroundMarks720:Clone()
			clone2.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone2.Parent = folder
			vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
			ParticleTween:ResizeParticles(clone2, 4.5, 3, "Sine", "Out")
			TweenService:Create(clone2, TweenInfo.new(5), {
				Size = clone2.Size * 4
			}):Play()
		end

		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, v2)
		local v5 = vfxUtility.PlaySound(sounds, "PS2bloodsickRARloop", clone, false)
		folder:SetAttribute("Active", true)
		local connections = {}

		local function fn()
			for _, connection in connections do
				connection:Disconnect()
			end

			cam_Shaker:Stop()
			cam_Shaker:Destroy()

			if v5 and v5.IsPlaying then
				v5:Stop()
			end
		end

		table.insert(connections, folder.AttributeChanged:Connect(fn))
		table.insert(connections, folder.Destroying:Connect(fn))
	elseif p == "Cancel" then
		if parent:FindFirstChild(name) then
			local child = parent:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)
			vfxUtility.EnableAll(child, false)
		end
	elseif p == "End" then
		if parent:FindFirstChild(name) then
			local child = parent:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 2.5)
			vfxUtility.EnableAll(child, false)
		end

		local clone = assets.EndEmit720Slash:Clone()
		ParticleTween:ResizeParticlesNoTween(clone, p2)
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 4)
		vfxUtility.PlaySound(sounds, "PS2bloodsickRARend", clone, true)
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position,
			-CFrame.new(humanoidRootPart.Position).UpVector * 10,
			raycastParams
		)

		if raycastResult then
			local lookVector = humanoidRootPart.CFrame.LookVector
			local clone2 = assets.GroundMarksEndEmit:Clone()
			ParticleTween:ResizeParticlesNoTween(clone2, p2)
			clone2.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + lookVector)
			clone2.Parent = parent
			vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
			DebrisModule:AddItem(clone2, 2.4)
		end

		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
	end
end