local createVector = vector.create
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local v = {}
local v2 = 0
RunService.Heartbeat:Connect(function(dt: number)
	debug.profilebegin("Items:UpdateHUE")
	v2 += dt * 0.2

	if v2 > 1 then
		v2 -= 1
	end

	local color = Color3.fromHSV(v2, 1, 1)

	for _, v3 in v do
		if v3 and v3.Parent then
			v3.FillColor = color
		end
	end

	debug.profileend()
end)
local additionalItems, additionalScripts, additionalSounds, SoundService

if RunService:IsServer() then
	local toolsCode = ServerScriptService.ToolsCode
	additionalItems = toolsCode.AdditionalItems
	additionalScripts = toolsCode.AdditionalScripts
	additionalSounds = toolsCode.AdditionalSounds
	SoundService = require(ServerScriptService.Services.SoundService)
else
	SoundService = nil
	additionalSounds = nil
	additionalItems = nil
	additionalScripts = nil
end

local function attachEclipseOrbit(parent, humanoidRootPart, upperTorso)
	local mutationVFX = ReplicatedStorage.Shared.Animals:FindFirstChild("MutationVFX")
	local eclipse = mutationVFX and mutationVFX:FindFirstChild("Eclipse")
	local eclipseOrbit = eclipse and eclipse:FindFirstChild("EclipseOrbit")

	if not (eclipseOrbit and eclipseOrbit:IsA("Model")) then
		return nil
	end

	local clone = eclipseOrbit:Clone()
	local primaryPart = clone.PrimaryPart
	local sweptMin = clone:GetAttribute("SweptMin")
	local sweptMax = clone:GetAttribute("SweptMax")
	local center = clone:GetAttribute("Center")

	if not primaryPart or typeof(sweptMin) ~= "Vector3" or typeof(sweptMax) ~= "Vector3" or typeof(center) ~= "Vector3" then
		clone:Destroy()
		return nil
	end

	local v3 = humanoidRootPart.Size.Y * 2.5 * 1.3 / (sweptMax.Y - sweptMin.Y)
	clone:ScaleTo(v3)
	local v4 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local cframe

	if v4.Magnitude > 0.001 then
		cframe = CFrame.lookAlong(createVector(0, 0, 0), v4)
	else
		cframe = CFrame.identity
	end

	local position = upperTorso.Position
	clone:PivotTo(CFrame.new(position) * cframe * clone:GetPivot().Rotation * CFrame.new(-center * v3))
	clone:SetAttribute("FixedRotationOffset", CFrame.new(-position) * primaryPart.CFrame)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = upperTorso
	weldConstraint.Part1 = primaryPart
	weldConstraint.Parent = primaryPart
	clone.Parent = parent
	return clone
end

local v3 = {
	UpperTorso = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true
}

local function eclipseFloat(instance, instance2, p: string, p2: string, data)
	local humanoid = instance2:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
	local upperTorso = instance2:FindFirstChild("UpperTorso")
	local lowerTorso = instance2:FindFirstChild("LowerTorso")

	if not (humanoid and humanoidRootPart and upperTorso and lowerTorso) then
		return
	end

	SoundService:PlaySound(additionalSounds[p2], humanoidRootPart.Position)

	if instance:GetAttribute("GiantPotion") then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Color3.fromRGB(255, 219, 111)
	highlight.FillTransparency = 0.85
	highlight.OutlineColor = Color3.fromRGB(42, 37, 66)
	highlight.OutlineTransparency = 0
	highlight.Adornee = instance2
	highlight.Parent = instance2
	task.delay(1, function()
		if instance:GetAttribute("GiantPotion") then
			highlight:Destroy()
			return
		end

		local lastTime = os.clock()

		while os.clock() - lastTime < 5 do
			local ragdollEndTime = instance:GetAttribute("RagdollEndTime")
			local serverTimeNow = workspace:GetServerTimeNow()

			if typeof(ragdollEndTime) ~= "number" or ragdollEndTime - 0.1 < serverTimeNow then
				break
			end

			task.wait(0.1)
		end

		if instance:GetAttribute("GiantPotion") then
			highlight:Destroy()
			return
		end

		local instant = FFlags:GetInstant(`{p}/Delay`, data.Delay)
		local instant2 = FFlags:GetInstant(`{p}/ExtraRagdollTime`, data.ExtraRagdollTime)
		local instant3 = FFlags:GetInstant(`{p}/LiftTime`, data.LiftTime)
		instance:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow() + instant + instant2)
		local v4 = attachEclipseOrbit(instance2, humanoidRootPart, upperTorso)
		local clone = script.DivineSlap.HitEffect:Clone()

		for _, v5 in clone:QueryDescendants("ParticleEmitter"), nil, nil do
			v5.LockedToPart = true
		end

		VFX.emit(clone)
		local weld = Instance.new("Weld")
		weld.Part0 = clone
		weld.Part1 = upperTorso
		weld.Parent = clone
		clone.Parent = upperTorso
		local neckRigAttachment = upperTorso:FindFirstChild("NeckRigAttachment")
		local attachment = Instance.new("Attachment")
		attachment.Name = "FloatAttachment"
		local position

		if neckRigAttachment and neckRigAttachment:IsA("Attachment") then
			position = neckRigAttachment.Position
		else
			position = Vector3.new(0, upperTorso.Size.Y / 2, 0)
		end

		attachment.Position = position
		attachment.Parent = upperTorso
		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.Name = "FloatVelocity"
		linearVelocity.Attachment0 = attachment
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity.VectorVelocity = Vector3.new(0, FFlags:GetInstant(`{p}/UpwardsForce`, data.UpwardsForce), 0)
		linearVelocity.MaxForce = 1000000000
		linearVelocity.Parent = upperTorso
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "FloatHipAttachment"
		attachment2.Parent = lowerTorso
		local linearVelocity2 = Instance.new("LinearVelocity")
		linearVelocity2.Name = "FloatVelocity"
		linearVelocity2.Attachment0 = attachment2
		linearVelocity2.RelativeTo = Enum.ActuatorRelativeTo.World
		linearVelocity2.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
		linearVelocity2.PrimaryTangentAxis = createVector(1, 0, 0)
		linearVelocity2.SecondaryTangentAxis = createVector(0, 0, 1)
		linearVelocity2.PlaneVelocity = Vector2.zero
		linearVelocity2.MaxForce = 1000000000
		linearVelocity2.Parent = lowerTorso
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local v6 = attachment.WorldPosition - attachment2.WorldPosition
			linearVelocity2.PlaneVelocity = Vector2.new(v6.X, v6.Z) * 5
		end)
		local maxFrictionTorques = {}
		task.defer(function()
			for _, v6 in instance2:QueryDescendants("BallSocketConstraint.RagdollConstraint"), nil, nil do
				local parent = v6.Parent

				if not (parent and v3[parent.Name]) then
					continue
				end

				maxFrictionTorques[v6] = v6.MaxFrictionTorque
				v6.MaxFrictionTorque = 150
			end
		end)
		clone.Sfx:Play()
		SoundService:PlaySound(additionalSounds["Eclipse Float"], upperTorso.Position)
		task.delay(instant3, function()
			if linearVelocity.Parent then
				linearVelocity.VectorVelocity = createVector(0, 0, 0)
			end
		end)
		task.delay(instant, function()
			heartbeatConnection:Disconnect()
			linearVelocity2:Destroy()
			attachment2:Destroy()
			linearVelocity:Destroy()
			attachment:Destroy()

			for k, maxFrictionTorque in maxFrictionTorques do
				if k.Parent then
					k.MaxFrictionTorque = maxFrictionTorque
				end
			end

			if v4 then
				v4:Destroy()
			end

			task.wait(instant2)
			highlight:Destroy()
			task.wait(2)
			clone:Destroy()
		end)
	end)
end

return {
	Slap = {
		Name = "Slap",
		Icon = "rbxassetid://111744314864127",
		Cooldown = 0.7,
		Force = 550,
		RagdollDuration = 3
	},
	["Iron Slap"] = {
		Name = "Iron Slap",
		Icon = "rbxassetid://126416331206871",
		Cooldown = 0.7,
		Force = 600,
		RagdollDuration = 3
	},
	["Gold Slap"] = {
		Name = "Gold Slap",
		Icon = "rbxassetid://73587459668895",
		Cooldown = 0.7,
		Force = 650,
		RagdollDuration = 3
	},
	["Diamond Slap"] = {
		Name = "Diamond Slap",
		Icon = "rbxassetid://103400414014905",
		Cooldown = 0.7,
		Force = 700,
		RagdollDuration = 3
	},
	["Emerald Slap"] = {
		Name = "Emerald Slap",
		Icon = "rbxassetid://125486072175077",
		Cooldown = 0.7,
		Force = 750,
		RagdollDuration = 3
	},
	["Ruby Slap"] = {
		Name = "Ruby Slap",
		Icon = "rbxassetid://135484448648993",
		Cooldown = 0.7,
		Force = 800,
		RagdollDuration = 3
	},
	["Blackhole Slap"] = {
		Name = "Blackhole Slap",
		Icon = "rbxassetid://78729379185611",
		Cooldown = 0.7,
		Force = 850,
		RagdollDuration = 3,
		HasHighlight = false,
		HighlightConfig = {
			FillColor = Color3.fromRGB(255, 0, 0),
			FillTransparency = 0.5
		}
	},
	["Flame Slap"] = {
		Name = "Flame Slap",
		Icon = "rbxassetid://107751993012682",
		Cooldown = 0.7,
		Force = 850,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			OutlineColor = Color3.fromRGB(),
			OutlineTransparency = 0
		}
	},
	["Dark Matter Slap"] = {
		Name = "Dark Matter Slap",
		Icon = "rbxassetid://116359699709899",
		Cooldown = 0.7,
		Force = 900,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 0.9,
			OutlineTransparency = 0
		}
	},
	["Nuclear Slap"] = {
		Name = "Nuclear Slap",
		Icon = "rbxassetid://94800671695541",
		Cooldown = 0.7,
		Force = 950,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			OutlineColor = Color3.fromRGB(234, 255, 0),
			OutilineTransparency = 0
		}
	},
	["Galaxy Slap"] = {
		Name = "Galaxy Slap",
		Icon = "rbxassetid://79582982176990",
		Cooldown = 0.7,
		Force = 1050,
		RagdollDuration = 3,
		HasHighlight = true
	},
	["Bloodmoon Slap"] = {
		Name = "Bloodmoon Slap",
		Icon = "rbxassetid://105241258528205",
		Cooldown = 0.7,
		Force = 1050,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 0.9,
			OutlineTransparency = 0
		}
	},
	["Glitched Slap"] = {
		Name = "Glitched Slap",
		Icon = "rbxassetid://87821905406599",
		Cooldown = 0.7,
		Force = 1150,
		RagdollDuration = 3,
		HasHighlight = true
	},
	["Rainbow Slap"] = {
		Name = "Rainbow Slap",
		Icon = "rbxassetid://76888105480836",
		Cooldown = 0.7,
		Force = 1150,
		RagdollDuration = 3,
		HasHighlight = true
	},
	["Candy Slap"] = {
		Name = "Candy Slap",
		Icon = "rbxassetid://116411677446062",
		Cooldown = 0.7,
		Force = 1200,
		RagdollDuration = 3,
		HasHighlight = true
	},
	["Lava Slap"] = {
		Name = "Lava Slap",
		Icon = "rbxassetid://80560167115825",
		Cooldown = 0.7,
		Force = 1200,
		RagdollDuration = 3,
		HasHighlight = true
	},
	["Splatter Slap"] = {
		Name = "Splatter Slap",
		Icon = "rbxassetid://88294870214352",
		Cooldown = 0.7,
		Force = 1200,
		RagdollDuration = 3,
		HasHighlight = true,
		OnHit = function(player)
			if RunService:IsServer() then
				Net:RemoteEvent("UseItem"):FireClient(player, "PaintballHitted", 9)
			end
		end
	},
	["Alien Slap"] = {
		Name = "Alien Slap",
		Icon = "rbxassetid://89070555394271",
		Cooldown = 0.7,
		Force = 1250,
		RagdollDuration = 5,
		HasHighlight = true,
		OnHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.05
			local alienSlap = script:FindFirstChild("AlienSlap")

			if not alienSlap then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
			local rootAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("RootAttachment")
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")

			if not (humanoidRootPart and humanoid and rootAttachment) then
				return
			end

			task.wait(1)

			local function GetGround(vector2: Vector3)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { instance2 }
				local vector3 = vector2 + createVector(0, 3, 0)
				local raycastResult = workspace:Raycast(vector3, createVector(0, -20, 0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return vector2 - createVector(0, 3, 0)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function IsOnGround()
				return math.abs(humanoidRootPart.AssemblyLinearVelocity.Y) < 1.5
			end

			local function IsStandingStill()
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				return Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < 1 and IsOnGround()
			end

			local lastTime = os.clock()
			local total = 0

			while os.clock() - lastTime < 5 do
				if IsOnGround() then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local v4

					if Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < 1 then
						v4 = IsOnGround()
					else
						v4 = false
					end

					if v4 then
						total += task.wait(WAIT_INTERVAL)

						if total >= 0.3 then
							break
						end
					else
						task.wait(WAIT_INTERVAL)
						total = 0
					end
				else
					task.wait(WAIT_INTERVAL)
					total = 0
				end
			end

			if total < 0.3 then
				return
			end

			local clones = {}

			for i = 1, 4 do
				local v4 = i / 4 * 3.141592653589793 * 2
				local vector2 = Vector3.new(math.cos(v4), 0, (math.sin(v4))) * 5
				local ground = GetGround(humanoidRootPart.Position + vector2)
				local florPart = alienSlap:FindFirstChild("florPart")

				if not florPart then
					continue
				end

				local clone = florPart:Clone()
				clone.Anchored = true
				clone.CFrame = CFrame.new(ground)
				clone.Parent = workspace
				table.insert(clones, clone)
			end

			GetGround(humanoidRootPart.Position)
			local part = alienSlap:FindFirstChild("Part")
			local clone

			if part then
				clone = part["002"]:Clone()
				clone.WorldCFrame = rootAttachment.WorldCFrame
				clone.CFrame = rootAttachment.CFrame
				clone.Parent = rootAttachment

				for _, v4 in clones do
					for _, beam in v4["001"]:GetChildren() do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Attachment0 = v4["001"]
						beam.Attachment1 = clone
					end
				end
			else
				clone = nil
			end

			local clone2 = additionalSounds["Alien slap"]:Clone()
			clone2.Parent = humanoidRootPart
			clone2:Play()
			instance:SetAttribute("Freeze", true)
			task.delay(3, function()
				if clone and clone.Parent then
					clone:Destroy()
				end

				for _, v4 in clones do
					if v4 and v4.Parent then
						v4:Destroy()
					end
				end

				instance:SetAttribute("Freeze", false)
			end)
		end
	},
	["Yin Yang Slap"] = {
		Name = "Yin Yang Slap",
		Icon = "rbxassetid://72523518394942",
		Cooldown = 0.7,
		Force = 1260,
		RagdollDuration = 6,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 0, 0)
		},
		OnHit = function(_, parent)
			local WAIT_INTERVAL = 0.05
			local yinYangSlap = script.YinYangSlap
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
			local rootAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("RootAttachment")
			local humanoid = parent:FindFirstChildOfClass("Humanoid")

			if not (humanoidRootPart and humanoid and rootAttachment) then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function isColorable(child)
				if child:IsA("Accessory") or child:IsA("Tool") then
					return false
				end

				if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
					return true
				end

				return false
			end

			local function GetGround(position: Vector3)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { parent }
				local vector2 = position + createVector(0, 3, 0)
				local raycastResult = workspace:Raycast(vector2, createVector(0, -20, 0), raycastParams)

				if raycastResult then
					return raycastResult.Position
				end

				return position - createVector(0, 3, 0)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function IsOnGround()
				return math.abs(humanoidRootPart.AssemblyLinearVelocity.Y) < 1.5
			end

			local function IsStandingStill()
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				return Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < 1 and IsOnGround()
			end

			task.wait(1)
			local shirt = parent:FindFirstChildOfClass("Shirt")

			if shirt then
				shirt.Parent = nil
			end

			local pants = parent:FindFirstChildOfClass("Pants")

			if pants then
				pants.Parent = nil
			end

			local children = {}
			local v4 = {}

			for _, child in parent:GetChildren() do
				-- equivalent call inferred; original call site unknown
				if not isColorable(child) then
					continue
				end

				table.insert(children, child)
				table.insert(v4, {
					part = child,
					color = child.Color
				})
			end

			for _, v5 in children do
				v5.Color = math.random(1, 2) == 1 and Color3.fromRGB() or Color3.fromRGB(255, 255, 255)
			end

			local head = parent:FindFirstChild("Head")

			if head then
				local clone = yinYangSlap.SleepVFX.SLEEPY_VFX_ATTACHMENT:Clone()
				clone.Parent = head
				Debris:AddItem(clone, 6)
			end

			local lastTime = os.clock()
			local total = 0

			while os.clock() - lastTime < 5 do
				if IsOnGround() then
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local v5

					if Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < 1 then
						v5 = IsOnGround()
					else
						v5 = false
					end

					if v5 then
						total += task.wait(WAIT_INTERVAL)

						if total >= 0.3 then
							break
						end
					else
						task.wait(WAIT_INTERVAL)
						total = 0
					end
				else
					task.wait(WAIT_INTERVAL)
					total = 0
				end
			end

			if total < 0.3 then
				return
			end

			local ground = GetGround(humanoidRootPart.Position)
			local yinyang = yinYangSlap:FindFirstChild("yinyang")

			if yinyang then
				local clone = yinyang:Clone()
				clone.CFrame = CFrame.new(ground)
				clone.Parent = workspace
				Debris:AddItem(clone, 4)
			end

			task.delay(4, function()
				for _, v6 in v4 do
					if v6.part and v6.part.Parent then
						v6.part.Color = v6.color
					end
				end

				if shirt then
					shirt.Parent = parent
				end

				if pants then
					pants.Parent = parent
				end
			end)
		end
	},
	["Radioactive Slap"] = {
		Name = "Radioactive Slap",
		Icon = "rbxassetid://134911999156077",
		Cooldown = 0.7,
		Force = 1200,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(0, 255, 0)
		},
		OnHit = function(p, instance, player)
			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoidRootPart) then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(0, 255, 0)
			highlight.FillTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(75, 155, 0)
			highlight.OutlineTransparency = 0
			highlight.Adornee = instance
			highlight.Parent = instance
			task.delay(5, function()
				if RunService:IsServer() then
					ServerScriptService.Services.CombatService.ApplyImpulse:Invoke(
						p,
						500,
						Vector3.new(),
						true,
						3,
						true,
						{
							Tag = "Radioactive Slap",
							Player = player
						}
					)
				end
			end)
			task.delay(8, function()
				highlight:Destroy()
			end)
		end
	},
	["Cursed Slap"] = {
		Name = "Cursed Slap",
		Icon = "rbxassetid://101392764194646",
		Cooldown = 0.7,
		Force = 1300,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 23, 23)
		},
		OnHit = function(instance, instance2, p)
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoidRootPart) then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(255, 23, 23)
			highlight.FillTransparency = 0.5
			highlight.OutlineColor = Color3.fromRGB(155, 0, 0)
			highlight.OutlineTransparency = 0
			highlight.Adornee = instance2
			highlight.Parent = instance2
			local Demon = require(ServerScriptService.Services.ItemService.Demon)
			task.delay(1, function()
				local lastTime = os.clock()

				while os.clock() - lastTime < 5 do
					local ragdollEndTime = instance:GetAttribute("RagdollEndTime")
					local serverTimeNow = workspace:GetServerTimeNow()

					if not ragdollEndTime or ragdollEndTime < serverTimeNow then
						break
					end

					task.wait(0.5)
				end

				task.wait(0.3)
				Demon.FreezePlayer(instance, humanoidRootPart, p, 4)
				highlight:Destroy()
			end)
		end
	},
	["Divine Slap"] = {
		Name = "Divine Slap",
		Icon = "rbxassetid://107787439485133",
		Cooldown = 0.7,
		Force = 1400,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 240, 23)
		},
		OnHit = function(instance, instance2, _, _)
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
			local upperTorso = instance2:FindFirstChild("UpperTorso")

			if not (humanoid and humanoidRootPart and upperTorso) or instance:GetAttribute("GiantPotion") then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(251, 255, 23)
			highlight.FillTransparency = 0.85
			highlight.OutlineColor = Color3.fromRGB(155, 150, 0)
			highlight.OutlineTransparency = 0
			highlight.Adornee = instance2
			highlight.Parent = instance2
			task.delay(1, function()
				if instance:GetAttribute("GiantPotion") then
					highlight:Destroy()
					return
				end

				local lastTime = os.clock()

				while os.clock() - lastTime < 5 do
					local ragdollEndTime = instance:GetAttribute("RagdollEndTime")
					local serverTimeNow = workspace:GetServerTimeNow()

					if not ragdollEndTime or ragdollEndTime - 0.1 < serverTimeNow then
						break
					end

					task.wait(0.1)
				end

				if instance:GetAttribute("GiantPotion") then
					return
				end

				local instant = FFlags:GetInstant("DivineSlap/Delay", 1.7)
				local instant2 = FFlags:GetInstant("DivineSlap/ExtraRagdollTime", 0.9)
				instance:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow() + instant + instant2)
				local clone = script.DivineSlap.TEMP_Halo:Clone()
				clone.Parent = instance2
				local clone2 = script.DivineSlap.HitEffect:Clone()
				VFX.emit(clone2)
				local weld = Instance.new("Weld")
				weld.Part0 = clone2
				weld.Part1 = upperTorso
				weld.Parent = clone2
				clone2.Parent = upperTorso
				local linearVelocity = Instance.new("LinearVelocity")
				linearVelocity.Name = "FloatVelocity"
				linearVelocity.Attachment0 = humanoidRootPart:FindFirstChildOfClass("Attachment")
				linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
				linearVelocity.VectorVelocity = Vector3.new(0, FFlags:GetInstant("DivineSlap/UpwardsForce", 20), 0)
				linearVelocity.MaxForce = 1000000000
				linearVelocity.Parent = humanoidRootPart
				clone2.Sfx:Play()
				task.delay(FFlags:GetInstant("DivineSlap/Delay", instant), function()
					linearVelocity:Destroy()
					task.wait(instant2)
					highlight:Destroy()
					clone:Destroy()
					task.wait(2)
					clone2:Destroy()
				end)
			end)
		end
	},
	["Cyber Slap"] = {
		Name = "Cyber Slap",
		Icon = "rbxassetid://130466812459508",
		Cooldown = 0.7,
		Force = 1500,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(67, 67, 255)
		},
		OnHit = function(instance, instance2, _, _)
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")
			local upperTorso = instance2:FindFirstChild("UpperTorso")

			if not (humanoid and humanoidRootPart and upperTorso) or instance:GetAttribute("GiantPotion") then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(121, 219, 255)
			highlight.FillTransparency = 0.85
			highlight.OutlineColor = Color3.fromRGB(82, 149, 173)
			highlight.OutlineTransparency = 0
			highlight.Adornee = instance2
			highlight.Parent = instance2
			task.delay(1, function()
				if instance:GetAttribute("GiantPotion") then
					highlight:Destroy()
					return
				end

				local lastTime = os.clock()

				while os.clock() - lastTime < 5 do
					local ragdollEndTime = instance:GetAttribute("RagdollEndTime")
					local serverTimeNow = workspace:GetServerTimeNow()

					if not ragdollEndTime or ragdollEndTime - 0.1 < serverTimeNow then
						break
					end

					task.wait(0.1)
				end

				local clone = script.CyberSlap.HitEffect:Clone()
				VFX.enable(clone)
				local weld = Instance.new("Weld")
				weld.Part0 = clone
				weld.Part1 = upperTorso
				weld.Parent = clone
				clone.Parent = upperTorso

				if clone:FindFirstChild("Sfx") then
					clone.Sfx:Play()
				end

				instance:SetAttribute("InverseControls", true)
				task.delay(5, function()
					highlight:Destroy()
					instance:SetAttribute("InverseControls", nil)
					VFX.disable(clone)
					task.wait(2)
					clone:Destroy()
				end)
			end)
		end
	},
	["Phantom Slap"] = {
		Name = "Phantom Slap",
		Icon = "rbxassetid://77885435762350",
		Cooldown = 0.7,
		Force = 1500,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 255, 255)
		},
		OnHit = function(_, instance, p, _)
			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			local upperTorso = instance:FindFirstChild("UpperTorso")

			if humanoid and humanoidRootPart and upperTorso then
				local PhantomSlapService = require(ServerScriptService.Services.PhantomSlapService)
				PhantomSlapService.TriggerWielderInvisibility(p)
			end
		end
	},
	["Crystal Slap"] = {
		Name = "Crystal Slap",
		Icon = "rbxassetid://103466550496346",
		Cooldown = 0.7,
		Force = 1500,
		RagdollDuration = 4,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(210, 222, 255)
		}
	},
	["Eclipse Slap"] = {
		Name = "Eclipse Slap",
		Icon = "rbxassetid://134321390440611",
		Cooldown = 0.7,
		Force = 1400,
		RagdollDuration = 3,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 174, 116)
		},
		OnHit = function(p, p2, _, _)
			eclipseFloat(p, p2, "EclipseSlap", "Eclipse Slap", {
				Delay = 2.7,
				ExtraRagdollTime = 0.9,
				UpwardsForce = 25,
				LiftTime = 0.45
			})
		end
	},
	["Eclipse Hammer"] = {
		Name = "Eclipse Hammer",
		Icon = "rbxassetid://133196448693805",
		Cooldown = 0.7,
		Force = 2000,
		RagdollDuration = 4,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(255, 174, 116)
		},
		OnHit = function(p, p2, _, _)
			eclipseFloat(p, p2, "EclipseHammer", "Eclipse Hammer", {
				Delay = 3.2,
				ExtraRagdollTime = 1.2,
				UpwardsForce = 28,
				LiftTime = 0.45
			})
		end
	},
	["Crystal Hammer"] = {
		Name = "Crystal Hammer",
		Icon = "rbxassetid://111256763764083",
		Cooldown = 0.7,
		Force = 2000,
		RagdollDuration = 7,
		HasHighlight = true,
		HighlightConfig = {
			FillTransparency = 1,
			OutlineTransparency = 0,
			OutlineColor = Color3.fromRGB(210, 222, 255)
		}
	},
	["Overseer Mace"] = {
		Icon = "rbxassetid://900731150",
		Range = createVector(12, 12, 12),
		Name = "Overseer Mace",
		RagdollDuration = 3,
		Cooldown = 0.8,
		Force = 1000,
		OnHit = function(instance, instance2, player)
			local humanoid = instance2:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoidRootPart) then
				return
			end

			task.wait(3)
			local v4 = 1

			for _ = 1, 10 do
				v4 -= 0.1
				instance:SetAttribute("DivideSpeedBy", v4)
				task.wait(0.6)
			end

			instance:SetAttribute("DivideSpeedBy", nil)

			if RunService:IsServer() then
				ServerScriptService.Services.CombatService.ApplyImpulse:Invoke(
					instance,
					500,
					Vector3.new(),
					true,
					3,
					true,
					{
						Tag = "Item.Overseer Mace",
						Player = player
					}
				)
				instance:SetAttribute("DivideSpeedBy", nil)
			end
		end
	},
	["Steampunk Glove"] = {
		Name = "Steampunk Glove",
		Icon = "rbxassetid://243184138",
		Cooldown = 0.7,
		Force = 1500,
		RagdollDuration = 3
	},
	["Ban Hammer"] = {
		Name = "Ban Hammer",
		Icon = "rbxassetid://102903994473061",
		Cooldown = 0.7,
		Force = 900,
		RagdollDuration = 3,
		HasParticles = function(part, p)
			local part2 = Instance.new("Part")
			part2.CanCollide = false
			part2.Size = createVector(1, 1, 1)
			part2.Anchored = false
			part2.Transparency = 1
			part2.CFrame = part.CFrame * CFrame.new(0, 0.4, -3)
			part2.Parent = workspace
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part2
			local clone = p.Handle.Attachment:Clone()
			clone.Parent = part2
			clone.ParticleEmitter:Emit(2)
			task.delay(1, function()
				if part2 then
					part2:Destroy()
				end

				if weldConstraint then
					weldConstraint:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end)
		end
	},
	["Bloodmoon Hammer"] = {
		Name = "Bloodmoon Hammer",
		Icon = "rbxassetid://96284196754755",
		Cooldown = 0.7,
		Force = 900,
		RagdollDuration = 6,
		HasParticles = function(part, p)
			local part2 = Instance.new("Part")
			part2.CanCollide = false
			part2.Size = createVector(1, 1, 1)
			part2.Anchored = false
			part2.Transparency = 1
			part2.CFrame = part.CFrame * CFrame.new(0, 0.4, -3)
			part2.Parent = workspace
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part2
			local clone = p.Handle.Attachment:Clone()
			clone.Parent = part2
			clone.ParticleEmitter:Emit(2)
			task.delay(1, function()
				if part2 then
					part2:Destroy()
				end

				if weldConstraint then
					weldConstraint:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end)
		end,
		OnHit = function(_, p)
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 1
			highlight.Adornee = p
			highlight.Parent = p
			task.delay(2.5, function()
				highlight:Destroy()
			end)
		end
	},
	["Rainbow Hammer"] = {
		Name = "Rainbow Hammer",
		Icon = "rbxassetid://139876541578910",
		Cooldown = 0.7,
		Force = 1000,
		RagdollDuration = 6,
		HasParticles = function(part, p)
			local part2 = Instance.new("Part")
			part2.CanCollide = false
			part2.Size = createVector(1, 1, 1)
			part2.Anchored = false
			part2.Transparency = 1
			part2.CFrame = part.CFrame * CFrame.new(0, 0.4, -3)
			part2.Parent = workspace
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part2
			local clone = p.Handle.Attachment:Clone()
			clone.Parent = part2
			clone.ParticleEmitter:Emit(2)
			task.delay(1, function()
				if part2 then
					part2:Destroy()
				end

				if weldConstraint then
					weldConstraint:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end)
		end,
		OnHit = function(_, p)
			local highlight = Instance.new("Highlight")
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineTransparency = 0
			highlight.FillTransparency = 0.5
			highlight.Adornee = p
			highlight.Parent = p
			table.insert(v, highlight)
			task.delay(2.5, function()
				table.remove(v, table.find(v, highlight))
				highlight:Destroy()
			end)
		end
	},
	["Delete Hammer"] = {
		Name = "Delete Hammer",
		Icon = "rbxassetid://102903994473061",
		Cooldown = 0,
		Force = 3000,
		RagdollDuration = 5,
		HasParticles = function(part, p)
			local part2 = Instance.new("Part")
			part2.CanCollide = false
			part2.Size = createVector(1, 1, 1)
			part2.Anchored = false
			part2.Transparency = 1
			part2.CFrame = part.CFrame * CFrame.new(0, 0.4, -3)
			part2.Parent = workspace
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part
			weldConstraint.Part1 = part2
			weldConstraint.Parent = part2
			local clone = p.Handle.Attachment:Clone()
			clone.Parent = part2
			clone.ParticleEmitter:Emit(2)
			task.delay(1, function()
				if part2 then
					part2:Destroy()
				end

				if weldConstraint then
					weldConstraint:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end)
		end
	},
	["Small Tree"] = {
		Name = "Small Tree",
		Icon = "rbxassetid://70956898840223",
		Cooldown = 0.7,
		Force = 1000,
		Range = createVector(12, 12, 12),
		RagdollDuration = 3
	},
	["Medium Tree"] = {
		Name = "Medium Tree",
		Icon = "rbxassetid://117374249944925",
		Cooldown = 0.7,
		Force = 1100,
		Range = createVector(14, 14, 14),
		RagdollDuration = 3
	},
	["Huge Tree"] = {
		Name = "Huge Tree",
		Icon = "rbxassetid://114915257709192",
		Cooldown = 0.7,
		Force = 1200,
		Range = createVector(16, 16, 16),
		RagdollDuration = 3
	},
	["Rainbow Small Tree"] = {
		Name = "Rainbow Small Tree",
		Icon = "rbxassetid://136011850681459",
		Cooldown = 0.7,
		Force = 1200,
		Range = createVector(12, 12, 12),
		RagdollDuration = 3
	},
	["Rainbow Medium Tree"] = {
		Name = "Rainbow Medium Tree",
		Icon = "rbxassetid://83546641619026",
		Cooldown = 0.7,
		Force = 1300,
		Range = createVector(14, 14, 14),
		RagdollDuration = 3
	},
	["Rainbow Huge Tree"] = {
		Name = "Rainbow Huge Tree",
		Icon = "rbxassetid://119257172353286",
		Cooldown = 0.7,
		Force = 1400,
		Range = createVector(16, 16, 16),
		RagdollDuration = 3
	},
	Bat = {
		Name = "Bat",
		Icon = "rbxassetid://86735158693802",
		Cooldown = 0.7,
		Force = 500,
		RagdollDuration = 3
	},
	Lollipop = {
		Name = "Lollipop",
		Icon = "rbxassetid://95336128645462",
		Cooldown = 0.7,
		Force = 800,
		RagdollDuration = 3,
		OnHit = function(instance, instance2)
			local function ApplyCandyEffect(instance3)
				for _, part in instance3:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end

					for _, child in script.Effect:GetChildren() do
						local clone = child:Clone()
						clone.Parent = part
						task.delay(5, function()
							clone:Destroy()
						end)
					end
				end
			end

			local humanoid = instance2:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not (humanoid and humanoidRootPart) then
				return
			end

			local clone = script.BillboardPart.BillboardGui:Clone()
			clone.Parent = humanoidRootPart
			ApplyCandyEffect(instance2)
			instance:SetAttribute("DivideSpeed", true)
			task.delay(5, function()
				instance:SetAttribute("DivideSpeed", nil)
				clone:Destroy()
			end)
			Net:RemoteEvent("UseItem"):FireClient(instance, "CandyEffect", 5)
		end
	},
	["Candy Cane"] = {
		Name = "Candy Cane",
		Icon = "rbxassetid://19250774",
		Cooldown = 0.4,
		Force = 500,
		RagdollDuration = 3
	},
	["Gummy Bear"] = {
		Name = "Gummy Bear",
		Icon = "rbxassetid://81350787786383",
		Cooldown = 0.7,
		Force = 750,
		RagdollDuration = 3,
		OnHit = function(instance, instance2)
			if Debounce(`TurnedToGummy/{instance.Name}/Server`, FFlags:GetInstant("GummyBearStickCooldown", 6.5)) then
				return
			end

			local gummyBear = additionalItems:FindFirstChild("GummyBear")

			if not gummyBear or not additionalScripts:FindFirstChild("GummyController") or instance:GetAttribute("Web") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance2:FindFirstChildWhichIsA("Humanoid")

			if not humanoid then
				return
			end

			instance2:PivotTo(CFrame.new(instance2:GetPivot().Position + createVector(0, 2, 0)))
			instance2:SetAttribute("SpeedAllowance", FFlags:GetInstant("GummyBearSpeedAllowance", 120))
			task.wait(FFlags:GetInstant("GummyBearHitWaitTime", 0.65))
			instance:SetAttribute("RagdollEndTime", 0)
			local clone = additionalSounds.GummyBear:Clone()
			clone.Parent = humanoidRootPart
			clone:Play()
			local tool = instance2:FindFirstChildOfClass("Tool")
			instance:SetAttribute("Web", true)
			instance:SetAttribute("BlockTools", true)
			ServerScriptService.Services.StealService.CancelSteal:Invoke(instance)
			humanoid.PlatformStand = true
			humanoid:UnequipTools()
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = humanoidRootPart
			local clone2 = gummyBear:Clone()
			clone2:PivotTo(instance2:GetPivot())
			clone2.Color = BrickColor.random().Color
			clone2.Parent = workspace

			for _, part in clone2:GetDescendants() do
				if part:IsA("BasePart") then
					ServerAuthority.SetNetworkOwner(part, instance)
				end
			end

			weldConstraint.Part1 = clone2
			weldConstraint.Parent = clone2
			instance2:SetAttribute("InGummy", true)
			instance:SetAttribute("NoMouseLockOffset", true)
			task.delay(FFlags:GetInstant("GummyBearDuration", 3), function()
				clone:Destroy()
				clone2:Destroy()
				humanoid.PlatformStand = false
				instance:SetAttribute("Web", nil)
				instance:SetAttribute("BlockTools", nil)
				instance2:SetAttribute("SpeedAllowance", nil)
				instance2:SetAttribute("InGummy", nil)
				instance:SetAttribute("NoMouseLockOffset", nil)

				if tool and tool.Parent == instance.Backpack and not ServerScriptService.Services.StealService.IsStealing:Invoke(instance) and humanoid.Health > 0 then
					humanoid:EquipTool(tool)
				end
			end)
		end
	},
	["Dev Slap"] = {
		Name = "Dev Slap",
		Icon = "",
		Cooldown = 0.7,
		Force = 5000,
		Range = createVector(25, 25, 25),
		RagdollDuration = 5,
		HasHighlight = true
	}
}