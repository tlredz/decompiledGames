local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.ParticleTween)
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
	Amplitude = 0.15,
	SustainTime = 10,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.15, 0.15, 0.15),
	PositionInfluence = createVector(0.4, 0.4, 0.4)
}
game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Values"):WaitForChild(game.Players.LocalPlayer.Name)
return function(instance, p, _)
	if instance == nil or p == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 and p ~= "Cancel" and p ~= "End" then
		return
	end

	local name = string.format("%s RotatingBloodScythe", instance.Name)

	if p == "Windup" then
		local clone = assets:FindFirstChild("ChargeEffect"):Clone()
		clone.Parent = humanoidRootPart
		vfxUtility.EnableAll(clone, true, vfxUtility.Owned(instance))
		clone.CFrame = humanoidRootPart.CFrame
		vfxUtility.WeldConstraint(humanoidRootPart, clone)
		task.delay(0.45, function()
			vfxUtility.EnableAll(clone, false)
			DebrisModule:AddItem(clone, 2)
		end)
		vfxUtility.PlaySound(sounds, "Rotatingstart", clone, true)
	elseif p == "Start" then
		local folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
		DebrisModule:AddItem(folder, 7.5)
		local clone = assets.Cast:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = folder
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 3)
		vfxUtility.PlaySound(sounds, "Rotatingexplode", humanoidRootPart, true)
		task.wait(0.125)

		if folder.Parent == nil or folder.Name ~= name then
			return
		end

		local clone2 = assets["Rotating Blood Scythe"]:Clone()
		clone2.Name = "Blood"
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = folder
		vfxUtility.EnableAll(clone2, true, vfxUtility.Owned(instance))
		vfxUtility.WeldConstraint(humanoidRootPart, clone2.PrimaryPart)
		local v4 = vfxUtility.PlaySound(sounds, "Rotatingloop", clone2.PrimaryPart, false)
		local cam_Shaker = Cam_Shaker(humanoidRootPart.Position, v2)
		folder:SetAttribute("Active", true)
		local connections = {}

		local function fn()
			for _, connection in connections do
				connection:Disconnect()
			end

			cam_Shaker:Stop()
			cam_Shaker:Destroy()

			if v4 then
				TweenService:Create(v4, TweenInfo.new(0.4), {
					Volume = 0
				}):Play()
				DebrisModule:AddItem(v4, 0.4)
			end
		end

		table.insert(connections, folder.AttributeChanged:Connect(fn))
		table.insert(connections, folder.Destroying:Connect(fn))
	elseif p == "Cancel" then
		if parent:FindFirstChild(name) then
			local child = parent:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 3.5)
			vfxUtility.EnableAll(child, false)
			local blood = child:FindFirstChild("Blood")

			if blood ~= nil then
				vfxUtility.EnableAll(blood.Part, true, vfxUtility.Owned(instance))
				task.delay(0.5, function()
					vfxUtility.EnableAll(blood.Part, false)
					DebrisModule:AddItem(blood, 1.25)
				end)
			end
		end
	elseif p == "End" then
		if parent:FindFirstChild(name) then
			local child = parent:FindFirstChild(name)
			child.Name = "_"
			child:SetAttribute("Active", false)
			DebrisModule:AddItem(child, 3.5)
			vfxUtility.EnableAll(child, false)
			local blood = child:FindFirstChild("Blood")

			if blood ~= nil then
				vfxUtility.EnableAll(blood.Part, true, vfxUtility.Owned(instance))
				task.delay(0.5, function()
					vfxUtility.EnableAll(blood.Part, false)
					DebrisModule:AddItem(blood, 1.25)
				end)
			end
		end

		local clone = assets.Punch:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -3, -2) * CFrame.Angles(-1.5707963267948966, 0, 0))
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, "Medium_tiny_shake_preset")
		vfxUtility.PlaySound(sounds, "Rotatingpunch", clone.PrimaryPart, true)
	end
end