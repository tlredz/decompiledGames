local createVector = vector.create
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local parent = workspace.Debree:FindFirstChild(game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd")

if parent == nil then
	parent = Instance.new("Folder", workspace.Debree)
	parent.Name = game.Players.LocalPlayer.Name .. "'s effects debree thing213asdasdasdasd"
end

local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
return function(instance, p)
	local humanoidRootPart

	if instance ~= nil then
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or nil
	end

	if humanoidRootPart == nil or (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude >= 250 then
		return
	end

	if p == "Barrage" then
		local clone = script.HitFX:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Parent = parent
		vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone, 5)

		for _ = 1, 5 do
			task.wait(0.1)
			local clone2 = script:FindFirstChild("DXbanditbrrgslash" .. tostring(math.random(1, 3))):Clone()
			clone2.Parent = clone
			DebrisModule:AddItem(clone2, clone2.TimeLength)
			clone2:Play()
		end
	elseif p == "Slice" then
		local clone = script.Strike1:Clone()
		clone:PivotTo(humanoidRootPart.CFrame)
		clone.Parent = parent
		local raycastResult = workspace:Raycast(
			humanoidRootPart.Position + createVector(0, 5, 0),
			createVector(-0, -20, -0),
			RaycastHelper.Crater
		)
		local emit = Ouwmit.Emit
		local owned = Ouwmit.Owned
		local getDustColorSettings = vfxUtility.GetDustColorSettings
		local v2

		if raycastResult ~= nil then
			v2 = raycastResult.Instance or nil
		end

		emit(clone, owned(instance, getDustColorSettings(v2)))
		DebrisModule:AddItem(clone, 2)
		local clone2 = script.SlashEmithorizontal:Clone()
		clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.0758056640625, -0.2365574836730957, -6.6212158203125) * CFrame.fromEulerAnglesYXZ(
			-0,
			0,
			1.5626753568649292
		)
		clone2.Parent = parent
		vfxUtility.EmitAll(clone2, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone2, 5)
		local clone3 = script.SlashHorizontal:Clone()
		clone3.CFrame = humanoidRootPart.CFrame * CFrame.new(0.3232421875, -0.46233105659484863, -4.83160400390625) * CFrame.fromEulerAnglesYXZ(
			-0,
			3.141592653589793,
			-1.5966670513153076
		)
		clone3.Parent = parent
		vfxUtility.EnableAll(clone3, true, vfxUtility.Owned(instance))
		DebrisModule:AddItem(clone3, 4)
		TweenService:Create(clone3, TweenInfo.new(0.6), {
			CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -15) * CFrame.fromEulerAnglesYXZ(
				-0,
				3.141592653589793,
				-1.5966670513153076
			)
		}):Play()
		local clone4 = script.DXbanditBASICSLASH:Clone()
		clone4.Parent = humanoidRootPart
		DebrisModule:AddItem(clone4, clone4.TimeLength)
		clone4:Play()
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		task.wait(0.4)
		vfxUtility.EnableAll(clone3, false)
	end
end