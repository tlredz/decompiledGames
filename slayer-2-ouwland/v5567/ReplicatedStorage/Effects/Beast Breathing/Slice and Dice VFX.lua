local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local effects = script:WaitForChild("Effects")
local sounds = script:WaitForChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local BeastAura = require(script.Parent.BeastAura)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Config = require(ReplicatedStorage.Skills["Beast Breathing"]["Slice and Dice"].Config)
local v = {
	Jump = true,
	Slash = true,
	Dash = true,
	DashImpact = true
}
local v2 = {
	Jump = "activate_shake",
	Slash = {
		FadeInTime = 0,
		Frequency = 0.15,
		Amplitude = 0.8,
		SustainTime = 0.12,
		FadeOutTime = 0.5,
		RotationInfluence = createVector(0.25, 0.25, 0.25),
		PositionInfluence = createVector(3.5, 3.5, 3.5)
	},
	AuraImpact = "activate_shake",
	Dash = "Medium_tiny_shake_preset",
	DashImpact = "activate_shake"
}
local v3 = 0.5 - Config.HOLD_PAUSE
local RELEASE_WINDUP = Config.RELEASE_WINDUP
local DASH_IMPACT_AT = Config.DASH_IMPACT_AT

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p, p2: string)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-{p2}`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p, p2: string, p3: number)
	destroyFolder(p, p2) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-{p2}`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, p3)
	return configuration
end

local function findFolder(p, p2: string)
	return workspace.Debree:FindFirstChild((`{p.Name}-{p2}`))
end

local function alive(instance)
	return instance.Parent ~= nil and instance.Name ~= "--"
end

local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function stopDive(p)
	local v5 = v4[p]
	v4[p] = nil

	if v5 == nil then
		return
	end

	v5.turn:Disconnect()

	if v5.dive.Parent ~= nil then
		Ouwmit.Enable(v5.dive, false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

local v5 = {
	Jump = "PS2beastSLICEnDICEjump",
	Slash = "PS2beastSLICEnDICEslam",
	Dash = "PS2beastSLICEnDICEdash",
	DashImpact = "PS2beastSLICEnDICEfinalimpact"
}

local function emit(instance, p, p2: string, cframe: CFrame)
	local asset = vfxUtility.cloneAsset(effects, p, p2, cframe, 4)

	if asset == nil then
		return
	end

	local v6

	if v[p2] then
		v6 = groundDust(cframe.Position)
	end

	Ouwmit.Emit(asset, Ouwmit.Owned(instance, v6))
	local v7 = v2[p2]

	if v7 ~= nil then
		Cam_Shaker(cframe.Position, v7)
	end

	local v8 = v5[p2]
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if v8 ~= nil and humanoidRootPart ~= nil then
		vfxUtility.PlaySound(sounds, v8, humanoidRootPart, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitAt(duration: number, instance, p, p2: string, cframe: CFrame)
	task.delay(duration, function()
		local v6 = p
		local v7

		if v6.Parent == nil then
			v7 = false
		else
			v7 = v6.Name ~= "--"
		end

		if not v7 then
			return
		end

		emit(instance, p, p2, cframe)
	end)
end

return function(instance, p: string, p2, p3)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceVFX`))

		if child and child.Parent then
			Ouwmit.Enable(child, false)
			child.Name = "--"
			DebrisModule:AddItem(child, 1.3)
		end

		local child2 = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceToggleVFX`))

		if child2 and child2.Parent then
			Ouwmit.Enable(child2, false)
			child2.Name = "--"
			DebrisModule:AddItem(child2, 1.3)
		end
	elseif p == "Jump" then
		if typeof(p2) ~= "CFrame" or typeof(p3) ~= "Vector3" then
			return
		end

		local child = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceVFX`))

		if child and child.Parent then
			Ouwmit.Enable(child, false)
			child.Name = "--"
			DebrisModule:AddItem(child, 1.3)
		end

		local configuration = Instance.new("Configuration")
		configuration.Name = `{instance.Name}-SliceAndDiceVFX`
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 5.7)
		BeastAura(instance)
		emitAt(v3, instance, configuration, "Jump", p2) -- equivalent call inferred; original call site unknown
		task.delay(RELEASE_WINDUP, function()
			local parent = configuration
			local v9

			if parent.Parent == nil then
				v9 = false
			else
				v9 = parent.Name ~= "--"
			end

			if not v9 then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local dive = effects:FindFirstChild("Dive")

			if humanoidRootPart == nil or dive == nil then
				return
			end

			local clone = dive:Clone()
			local root = clone:FindFirstChild("Root")

			if root == nil then
				return
			end

			clone:PivotTo(humanoidRootPart.CFrame)
			local weld = Instance.new("Weld")
			weld.Part0 = humanoidRootPart
			weld.Part1 = root
			weld.Parent = clone
			clone.Parent = configuration
			DebrisModule:AddItem(clone, 4)
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				if clone.Parent == nil or humanoidRootPart.Parent == nil then
					stopDive(instance) -- equivalent call inferred; original call site unknown
				else
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity

					if assemblyLinearVelocity.Magnitude < 3 then
						return
					end

					local cframe = CFrame.lookAt(
						humanoidRootPart.Position,
						humanoidRootPart.Position + assemblyLinearVelocity
					)
					weld.C0 = humanoidRootPart.CFrame:ToObjectSpace(cframe).Rotation
				end
			end)
			stopDive(instance) -- equivalent call inferred; original call site unknown
			v4[instance] = {
				dive = clone,
				turn = renderSteppedConnection
			}
		end)
	elseif p == "Land" then
		stopDive(instance) -- equivalent call inferred; original call site unknown
		local child = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceVFX`))

		if child == nil or typeof(p2) ~= "CFrame" then
			return
		end

		emit(instance, child, "Slash", p2)
	else
		if p == "Mark" then
			return
		end

		if p == "Toggle" then
			if typeof(p2) ~= "CFrame" then
				return
			end

			local child = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceToggleVFX`))

			if child and child.Parent then
				Ouwmit.Enable(child, false)
				child.Name = "--"
				DebrisModule:AddItem(child, 1.3)
			end

			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-SliceAndDiceToggleVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 4.75)
			emit(instance, configuration, "AuraImpact", p2)
		elseif p == "Dash" then
			if typeof(p2) ~= "CFrame" or typeof(p3) ~= "CFrame" then
				return
			end

			local v6 = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceToggleVFX`))

			if not v6 then
				local child = workspace.Debree:FindFirstChild((`{instance.Name}-SliceAndDiceToggleVFX`))

				if child and child.Parent then
					Ouwmit.Enable(child, false)
					child.Name = "--"
					DebrisModule:AddItem(child, 1.3)
				end

				v6 = Instance.new("Configuration")
				v6.Name = `{instance.Name}-SliceAndDiceToggleVFX`
				v6.Parent = workspace.Debree
				DebrisModule:AddItem(v6, 4.75)
			end

			emit(instance, v6, "Dash", p2)
			emitAt(DASH_IMPACT_AT, instance, v6, "DashImpact", p2:Lerp(p3, 0.5)) -- equivalent call inferred; original call site unknown
		end
	end
end