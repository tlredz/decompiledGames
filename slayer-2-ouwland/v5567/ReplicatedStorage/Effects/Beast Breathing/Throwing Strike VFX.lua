local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CAM = ReplicatedStorage.CAM
local script2 = script
local sounds = script:WaitForChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Config = require(ReplicatedStorage.Skills["Beast Breathing"]["Throwing Strike"].Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-ThrowingStrikeVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-ThrowingStrikeVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 6.6)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-ThrowingStrikeVFX`))
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

-- equivalent calls inferred from this helper; original call sites unknown
local function burst(p, p2, p3: string, instance)
	local asset = vfxUtility.cloneAsset(script2, p2, p3, instance.CFrame, 5)

	if asset == nil then
		return
	end

	Ouwmit.Emit(asset, Ouwmit.Owned(p, groundDust(instance.Position)))
end

local function shoot(instance, folder, p: string, cframe: CFrame, p2: number, RETURN_TIME: number, durationScalar: number?)
	local asset = vfxUtility.cloneAsset(script2, folder, p, cframe, 5)

	if asset == nil then
		return
	end

	local primaryPart = asset.PrimaryPart

	if primaryPart then
		for _, v in asset:QueryDescendants("BasePart") do
			v.Anchored = false
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
		end

		local attachment = Instance.new("Attachment")
		attachment.Parent = primaryPart
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Attachment0 = attachment
		linearVelocity.MaxForce = 10000000
		linearVelocity.VectorVelocity = cframe.LookVector * p2
		linearVelocity.Parent = primaryPart
		task.delay(RETURN_TIME, function()
			if primaryPart.Parent == nil then
				return
			end

			linearVelocity:Destroy()
			primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			local root = asset:FindFirstChild("Root")

			if root ~= nil and root:IsA("BasePart") then
				root.Anchored = true
			end
		end)
	end

	local v = groundDust(cframe.Position) or {}
	v.DurationScalar = durationScalar
	Ouwmit.Emit(asset, Ouwmit.Owned(instance, v))
end

local function sweep(instance, folder, humanoidRootPart, fn)
	local spin = script2:FindFirstChild("Spin")

	if spin == nil then
		return
	end

	local clone = spin:Clone()

	for _, v in clone:QueryDescendants("BasePart") do
		v.Anchored = true
		v.CanCollide = false
		v.CanQuery = false
		v.CanTouch = false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function placed(p: number)
		return CFrame.new(humanoidRootPart.Position) * humanoidRootPart.CFrame.Rotation * CFrame.new(0, 0, -p)
	end

	clone:PivotTo(CFrame.new(humanoidRootPart.Position) * humanoidRootPart.CFrame.Rotation * CFrame.new(0, 0, -0))
	clone.Parent = folder
	DebrisModule:AddItem(clone, 5)
	local v = groundDust(humanoidRootPart.Position) or {}
	v.DurationScalar = 0.6
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v))
	local lastTime = os.clock()
	local renderSteppedConnection = nil
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if clone.Parent == nil or folder.Name == "--" or humanoidRootPart.Parent == nil then
			renderSteppedConnection:Disconnect()
			return
		end

		local v2 = math.min((os.clock() - lastTime) / Config.THROW_TIME, 1)
		local v4 = placed(Config.TRAVEL_DISTANCE * v2) -- equivalent call inferred; original call site unknown
		clone:PivotTo(v4)

		if v2 >= 1 then
			renderSteppedConnection:Disconnect()
			fn(v4)
		end
	end)
end

return function(instance, p: string, _: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Release" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-ThrowingStrikeVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 6.6)
			task.delay(0.05, function()
				if configuration.Parent == nil or configuration.Name == "--" then
					return
				end

				burst(instance, configuration, "Throw", humanoidRootPart) -- equivalent call inferred; original call site unknown
				vfxUtility.PlaySound(sounds, "PS2beastTHROWINGSTRIKEthrow", humanoidRootPart, true)
				Cam_Shaker(humanoidRootPart.Position, "activate_shake")
			end)
		else
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil then
				return
			end

			if p == "Throw" then
				sweep(instance, folder, humanoidRootPart, function(cframe: CFrame)
					task.delay(Config.RETURN_DELAY, function()
						if folder.Parent == nil or folder.Name == "--" then
							return
						end

						shoot(
							instance,
							folder,
							"SpinReturn",
							cframe * CFrame.Angles(0, 3.141592653589793, 0),
							Config.TRAVEL_DISTANCE / Config.RETURN_TIME,
							Config.RETURN_TIME
						)
						vfxUtility.PlaySound(sounds, "PS2beastTHROWINGSTRIKEreturn", humanoidRootPart, true)
					end)
				end)
			elseif p == "Grab" then
				burst(instance, folder, "SwordGrab", humanoidRootPart) -- equivalent call inferred; original call site unknown
				vfxUtility.PlaySound(sounds, "PS2beastTHROWINGSTRIKEgrab", humanoidRootPart, true)
				Cam_Shaker(humanoidRootPart.Position, "activate_shake")
			end
		end
	end
end