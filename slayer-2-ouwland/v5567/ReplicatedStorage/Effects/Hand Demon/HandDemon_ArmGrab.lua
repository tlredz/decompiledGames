local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 3, 0),
		createVector(0, -20, 0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local function armName(value: string?)
	return (`HandDemonArmGrab-{value or ""}`)
end

local v = {
	FadeInTime = 0,
	Frequency = 0.2,
	Amplitude = 0.6,
	SustainTime = 0.1,
	FadeOutTime = 0.5,
	RotationInfluence = createVector(0.25, 0.25, 0.25),
	PositionInfluence = createVector(1, 1, 1)
}

local function burst(childName: string, cframe: CFrame, p, value: number?, p2)
	local child = script:FindFirstChild(childName)

	if child == nil then
		return nil
	end

	local clone = child:Clone()
	clone:PivotTo(cframe)
	clone.Parent = workspace.Debree
	Ouwmit.Emit(clone, Ouwmit.Owned(p2, p))
	DebrisModule:AddItem(clone, value or 4)
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function soundPart(clone)
	if clone == nil then
		return nil
	end

	if clone:IsA("BasePart") then
		return clone
	end

	if clone:IsA("Model") then
		return clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
	end

	return clone:FindFirstChildWhichIsA("BasePart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function burstSound(p: string, primaryPart)
	if primaryPart == nil then
		primaryPart = nil
	elseif not primaryPart:IsA("BasePart") then
		if primaryPart:IsA("Model") then
			primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart")
		else
			primaryPart = primaryPart:FindFirstChildWhichIsA("BasePart")
		end
	end

	if primaryPart ~= nil then
		vfxUtility.PlaySound(script.Sounds, p, primaryPart, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopArm(value: string?)
	local child = workspace.Debree:FindFirstChild((`HandDemonArmGrab-{value or ""}`))

	if child ~= nil then
		child.Name = "--"
		Ouwmit.Enable(child, false)
		DebrisModule:AddItem(child, 2)
	end
end

local v2 = {}
return function(instance, p: string?, value: string?, cframe, p2)
	if p == "Cancel" then
		v2[value or ""] = nil
		stopArm(value) -- equivalent call inferred; original call site unknown
	else
		if instance == nil then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Startup" then
			burst("Startup", humanoidRootPart.CFrame, groundDust(humanoidRootPart.Position), nil, instance)
			vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSarmgrabINIT", humanoidRootPart, true)
		elseif p == "Hit" or p == "Miss" then
			if typeof(cframe) ~= "CFrame" then
				return
			end

			local v3 = typeof(p2) == "table" and p2 or {}
			local squeeze = v3.Squeeze or 0.9666666666666667
			local throw = v3.Throw or 2.1666666666666665
			local armsUp = v3.ArmsUp or 3.033333333333333
			Cam_Shaker(cframe.Position, v)
			burstSound(
				"PS2handdemonSKILLSarmgrabSPAWN",
				burst("TentaclesUp", cframe, groundDust(cframe.Position), 6.5, instance)
			) -- equivalent call inferred; original call site unknown
			burst("FistGround", humanoidRootPart.CFrame, groundDust(humanoidRootPart.Position), nil, instance)
			local v6 = value or ""
			v2[v6] = true

			if p == "Hit" then
				task.delay(squeeze, function()
					if v2[v6] ~= true then
						return
					end

					burstSound(
						"PS2handdemonSKILLSarmgrabSQUEEZE",
						burst("Impact", cframe, groundDust(cframe.Position), nil, instance)
					) -- equivalent call inferred; original call site unknown
				end)
				task.delay(throw, function()
					if v2[v6] ~= true then
						return
					end

					local throw2 = script:FindFirstChild("Throw")

					if throw2 == nil then
						return
					end

					local clone = throw2:Clone()
					clone:PivotTo(cframe)
					clone.Parent = workspace.Debree
					DebrisModule:AddItem(clone, 4)
					local v7 = soundPart(clone) -- equivalent call inferred; original call site unknown

					if v7 ~= nil then
						vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSarmgrabTHROW", v7, true)
					end

					local v8 = groundDust(cframe.Position) -- equivalent call inferred; original call site unknown
					local slash = clone:FindFirstChild("Slash")

					if slash ~= nil then
						Ouwmit.Emit(slash, Ouwmit.Owned(instance, v8))
					end

					task.wait(0.1)

					if v2[v6] ~= true or clone.Parent == nil then
						return
					end

					local skillVFX = clone:FindFirstChild("SkillVFX")

					if skillVFX ~= nil then
						Ouwmit.Emit(skillVFX, Ouwmit.Owned(instance, v8))
					end
				end)
			end

			task.delay(armsUp, function()
				if v2[v6] ~= true then
					return
				end

				v2[v6] = nil

				if humanoidRootPart.Parent ~= nil then
					burst("FistGround", humanoidRootPart.CFrame, groundDust(humanoidRootPart.Position), nil, instance)
					vfxUtility.PlaySound(script.Sounds, "PS2handdemonSKILLSarmgrabARMRETURN", humanoidRootPart, true)
				end
			end)
			burst(p, cframe, groundDust(cframe.Position), nil, instance)
		end
	end
end