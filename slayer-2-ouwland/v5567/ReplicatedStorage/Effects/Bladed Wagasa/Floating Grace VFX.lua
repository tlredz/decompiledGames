local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local assets = script:FindFirstChild("Assets")
local sounds = script:FindFirstChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills["Bladed Wagasa"]["Floating Grace"].Config)
local cframe = CFrame.fromMatrix(
	createVector(-0.6957, 2.0483, 5.531),
	createVector(0.5768, -0.8168, -0.0115),
	createVector(-0.012, 0.0056, -0.9999)
)
local cframe2 = CFrame.fromMatrix(
	createVector(-0.6957, 2.0483, -2.289),
	createVector(0.5768, -0.8168, -0.0115),
	createVector(-0.012, 0.0056, -0.9999)
)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-FloatingGraceVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-FloatingGraceVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, 8)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findFolder(instance)
	return workspace.Debree:FindFirstChild((`{instance.Name}-FloatingGraceVFX`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function anchorSpinVFX(folder)
	local umbrellaSpin = folder:FindFirstChild("UmbrellaSpin")
	local primaryPart = umbrellaSpin and (umbrellaSpin.PrimaryPart or umbrellaSpin:QueryDescendants("BasePart")[1])

	if primaryPart then
		primaryPart.Anchored = true
	end
end

return function(instance, p: string, _: CFrame?)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		local folder = findFolder(instance) -- equivalent call inferred; original call site unknown
		local floatUmbrella = folder and folder:FindFirstChild("FloatUmbrella")

		if floatUmbrella then
			local pS2bladedwagasaFLOATINGGRACEloop = floatUmbrella:FindFirstChild(
				"PS2bladedwagasaFLOATINGGRACEloop",
				true
			)

			if pS2bladedwagasaFLOATINGGRACEloop and folder then
				pS2bladedwagasaFLOATINGGRACEloop.Parent = folder
				TweenService:Create(pS2bladedwagasaFLOATINGGRACEloop, TweenInfo.new(0.3), {
					Volume = 0
				}):Play()
			end

			if folder then
				anchorSpinVFX(folder) -- equivalent call inferred; original call site unknown
			end

			floatUmbrella:Destroy()
		end

		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Start" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-FloatingGraceVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 8)
			vfxUtility.PlaySound(sounds, "PS2bladedwagasaFLOATINGGRACEreleaseLONG", humanoidRootPart, true)
			local v = instance:QueryDescendants("Model#Umbrella")[1]

			if v then
				local clone = v:Clone()
				clone.Name = "FloatUmbrella"
				local primaryPart = clone.PrimaryPart or clone:QueryDescendants("BasePart")[1]

				for _, part in clone:QueryDescendants("BasePart") do
					part.Anchored = false
					part.CanCollide = false
					part.CanQuery = false
					part.Massless = true

					if part:IsA("MeshPart") then
						part.Transparency = 0
					end
				end

				for _, v2 in clone:QueryDescendants("ParticleEmitter") do
					local setTransparency = v2:GetAttribute("SetTransparency")

					if setTransparency == nil then
						continue
					end

					v2.Enabled = setTransparency
					v2:SetAttribute("SetTransparency", nil)
				end

				local cframe3 = CFrame.fromMatrix(createVector(0, 0, 0), createVector(0, 0, 1), createVector(1, 0, 0))

				if primaryPart then
					local position = primaryPart.Position
					local part = Instance.new("Part")
					part.Name = "SpinBase"
					part.Anchored = false
					part.CanCollide = false
					part.CanQuery = false
					part.Massless = true
					part.Transparency = 1
					part.Size = createVector(1, 1, 1)
					part.CFrame = CFrame.new(position)
					part.Parent = clone
					local weld = Instance.new("Weld")
					weld.Name = "FloatWeld"
					weld.Part0 = humanoidRootPart
					weld.Part1 = part
					weld.C0 = humanoidRootPart.CFrame:ToObjectSpace(CFrame.new(position))
					weld.Parent = part
					local motor6D = Instance.new("Motor6D")
					motor6D.Part0 = part
					motor6D.Part1 = primaryPart
					motor6D.C1 = primaryPart.PivotOffset
					motor6D.Transform = cframe3
					motor6D.Parent = part
					vfxUtility.PlaySound(sounds, "PS2bladedwagasaFLOATINGGRACEloop", part, false)
					local umbrellaSpin = assets and assets:FindFirstChild("UmbrellaSpin")

					if umbrellaSpin then
						local clone2 = umbrellaSpin:Clone()
						local primaryPart2 = clone2.PrimaryPart or clone2:QueryDescendants("BasePart")[1]

						if primaryPart2 then
							local motor6D2 = Instance.new("Motor6D")
							primaryPart2.Massless = true
							motor6D2.Part0 = primaryPart
							motor6D2.Part1 = primaryPart2
							motor6D2.C0 = primaryPart.PivotOffset
							motor6D2.Parent = primaryPart
						end

						clone2.Parent = configuration
						Ouwmit.Enable(clone2, true, Ouwmit.Owned(instance))
					end

					clone.Parent = configuration
					TweenService:Create(
						weld,
						TweenInfo.new(Config.THROW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							C0 = CFrame.new(0, Config.UMBRELLA_HEIGHT, -Config.UMBRELLA_FORWARD)
						}
					):Play()
					task.spawn(function()
						local total = 0

						while motor6D.Parent and clone.Parent do
							total += RunService.Heartbeat:Wait() * 8
							motor6D.Transform = CFrame.Angles(0, total, 0) * cframe3
						end
					end)
				else
					clone.Parent = configuration
				end
			end

			if assets then
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position + createVector(0, 5, 0),
					createVector(-0, -15, -0),
					RaycastHelper.Crater
				)
				local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
				Ouwmit.Emit(
					vfxUtility.cloneAsset(assets, configuration, "Impact", humanoidRootPart.CFrame * cframe, 4),
					Ouwmit.Owned(instance, v2)
				)
				Ouwmit.Emit(
					vfxUtility.cloneAsset(assets, configuration, "UmbrellaEmit", humanoidRootPart.CFrame * cframe2, 8),
					Ouwmit.Owned(instance, v2)
				)
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.2,
				Amplitude = 0.5,
				SustainTime = 0.3,
				FadeOutTime = 1,
				RotationInfluence = createVector(0.25, 0.25, 0.25),
				PositionInfluence = createVector(1, 1, 1)
			})
		else
			local folder = findFolder(instance) -- equivalent call inferred; original call site unknown

			if folder == nil or assets == nil then
				return
			end

			if p == "Pull" then
				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.2,
					Amplitude = 0.75,
					SustainTime = 0.1,
					FadeOutTime = 0.2,
					RotationInfluence = createVector(0.25, 0.25, 0.25),
					PositionInfluence = createVector(1, 1, 1)
				})
				local floatUmbrella = folder:FindFirstChild("FloatUmbrella")
				local spinBase = floatUmbrella and floatUmbrella:FindFirstChild("SpinBase")
				local floatWeld = spinBase and spinBase:FindFirstChild("FloatWeld")
				local v = instance:QueryDescendants("Model#Umbrella")[1]
				local v2 = v and v:QueryDescendants("BasePart")[1]
				vfxUtility.PlaySound(sounds, "PS2bladedwagasaFLOATINGGRACEreturnLONG", humanoidRootPart, true)
				local pS2bladedwagasaFLOATINGGRACEloop = spinBase and spinBase:FindFirstChild("PS2bladedwagasaFLOATINGGRACEloop")

				if pS2bladedwagasaFLOATINGGRACEloop then
					TweenService:Create(pS2bladedwagasaFLOATINGGRACEloop, TweenInfo.new(Config.RETURN_TIME), {
						Volume = 0
					}):Play()
				end

				if floatWeld and spinBase and floatUmbrella and v and v2 then
					local objectSpace = humanoidRootPart.CFrame:ToObjectSpace(CFrame.new(v2.Position))
					local tween = TweenService:Create(
						floatWeld,
						TweenInfo.new(Config.RETURN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							C0 = objectSpace
						}
					)
					tween.Completed:Connect(function()
						anchorSpinVFX(folder) -- equivalent call inferred; original call site unknown
						floatUmbrella:Destroy()
						destroyFolder(instance) -- equivalent call inferred; original call site unknown
					end)
					tween:Play()
				else
					destroyFolder(instance) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end