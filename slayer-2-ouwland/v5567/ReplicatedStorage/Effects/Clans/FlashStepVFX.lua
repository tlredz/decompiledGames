local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Clan["Flash Step"].Config)
local sounds = script:WaitForChild("Sounds")
local cframe = CFrame.new(0, -1.5, 0)
local ENDLAG = Config.ENDLAG

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function burst(instance, p, instance2)
	local children = {}

	for _, child in instance:GetChildren() do
		if child.Name ~= "DustRaycast" then
			table.insert(children, child)
		end
	end

	Ouwmit.Emit(children, Ouwmit.Owned(instance2, p))
end

local function findLive(instance)
	for _, child in workspace.Debree:GetChildren() do
		if child:GetAttribute("_FlashStepLive") == instance.Name then
			return child
		end
	end

	return nil
end

return function(instance, p: string?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v = groundDust(humanoidRootPart.Position) -- equivalent call inferred; original call site unknown

	if p == "Vanish" then
		local flashStep = script:FindFirstChild("FlashStep")

		if flashStep == nil then
			warn((`[FlashStepVFX] no "FlashStep" template under {script:GetFullName()}`))
			return
		end

		local live = findLive(instance)

		if live ~= nil then
			live:Destroy()
		end

		local clone = flashStep:Clone()
		clone:SetAttribute("_FlashStepLive", instance.Name)
		clone.Parent = workspace.Debree
		clone:PivotTo(humanoidRootPart.CFrame * cframe)

		if clone:IsA("BasePart") then
			clone.Anchored = false
			clone.CanCollide = false
			clone.Massless = true
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.Part1 = clone
			weld.C0 = cframe
			weld.Parent = clone
		end

		DebrisModule:AddItem(clone, 8)
		burst(clone, v, instance)
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance, v))
		vfxUtility.PlaySound(sounds, "PS2flashstepLEAVE", humanoidRootPart, true)
		vfxUtility.PlaySound(sounds, "PS2flashstepLOOP", clone, false)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	else
		local live = findLive(instance)

		if live ~= nil then
			live:SetAttribute("_FlashStepLive", nil)
			local pS2flashstepLOOP = live:FindFirstChild("PS2flashstepLOOP")

			if pS2flashstepLOOP ~= nil then
				pS2flashstepLOOP:Destroy()
			end

			burst(live, v, instance)
			Ouwmit.Enable(live, true, Ouwmit.Owned(instance, v))
			DebrisModule:AddItem(live, ENDLAG + 3)
			task.delay(ENDLAG, function()
				if live.Parent ~= nil then
					Ouwmit.Enable(live, false)
				end
			end)
		end

		vfxUtility.PlaySound(sounds, "PS2flashstepRETURN", humanoidRootPart, true)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
	end
end