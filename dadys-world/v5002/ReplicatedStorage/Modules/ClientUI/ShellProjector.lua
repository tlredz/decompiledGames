local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShellCore = require(ReplicatedStorage.Modules.ClientUI.ShellCore)
local v = {}
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function enabled()
	local info = workspace:FindFirstChild("Info")
	return not info or info:GetAttribute("ShellEnabled") ~= false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toVec(data)
	return {
		x = data.X,
		y = data.Y,
		z = data.Z
	}
end

local function setLocalTransparency(folder, localTransparencyModifier)
	local v2 = localTransparencyModifier == 0

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = localTransparencyModifier
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			local v3 = descendant
			pcall(function()
				v3.LocalTransparencyModifier = localTransparencyModifier
			end)
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") or descendant:IsA("BillboardGui") or descendant:IsA("Highlight") then
			if v2 then
				local _ShellPrevEnabled = descendant:GetAttribute("_ShellPrevEnabled")

				if _ShellPrevEnabled ~= nil then
					descendant.Enabled = _ShellPrevEnabled
					descendant:SetAttribute("_ShellPrevEnabled", nil)
				end
			else
				if descendant:GetAttribute("_ShellPrevEnabled") == nil then
					descendant:SetAttribute("_ShellPrevEnabled", descendant.Enabled)
				end

				descendant.Enabled = false
			end
		end
	end
end

local function buildShell(instance)
	local archivable = instance.Archivable
	instance.Archivable = true
	local clone = instance:Clone()
	instance.Archivable = archivable
	clone.Name = instance.Name .. "_Shell"

	for _, tag in ipairs(CollectionService:GetTags(clone)) do
		CollectionService:RemoveTag(clone, tag)
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		for _, tag in ipairs(CollectionService:GetTags(descendant)) do
			CollectionService:RemoveTag(descendant, tag)
		end

		if descendant:IsA("Humanoid") then
			descendant:Destroy()
		elseif descendant:IsA("LuaSourceContainer") or descendant:IsA("BodyMover") or descendant:IsA("Constraint") then
			descendant:Destroy()
		elseif descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") or descendant:IsA("Light") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Highlight") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true
			descendant.LocalTransparencyModifier = 0
			descendant.CollisionGroup = "Default"
		end
	end

	clone.PrimaryPart = clone:FindFirstChild("HumanoidRootPart") or clone.PrimaryPart

	if clone.PrimaryPart then
		clone.PrimaryPart.Anchored = true
	end

	if not clone:FindFirstChildOfClass("AnimationController") then
		local animationController = Instance.new("AnimationController")
		animationController.Parent = clone
		local animator = Instance.new("Animator")
		animator.Parent = animationController
	end

	clone:SetAttribute("Shell", nil)
	clone:SetAttribute("ShellAltitude", nil)
	clone:SetAttribute("ShellPhase", nil)
	clone:SetAttribute("ShellDiveAt", nil)
	clone.Parent = workspace.CurrentCamera
	return clone
end

local function buildShadow(shadowRadius)
	local part = Instance.new("Part")
	part.Name = "ShellShadow"
	part.Shape = Enum.PartType.Cylinder
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = Color3.new(0, 0, 0)
	part.Size = Vector3.new(0.05, shadowRadius * 2, shadowRadius * 2)
	part.Parent = workspace.CurrentCamera
	return part
end

local function detach(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil

	for _, conn in ipairs(v2.conns) do
		conn:Disconnect()
	end

	if v2.shell then
		v2.shell:Destroy()
	end

	if v2.shadow then
		v2.shadow:Destroy()
	end

	if p.Parent then
		setLocalTransparency(p, 0)
	end
end

local function attach(instance)
	if not v[instance] and enabled() then
		if workspace.CurrentCamera and instance:IsDescendantOf(workspace.CurrentCamera) or not workspace.CurrentCamera then
			return
		end

		local shell = instance:GetAttribute("Shell")

		if type(shell) ~= "string" then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local clone = table.clone(ShellCore.DEFAULTS)
		local shellAltitude = instance:GetAttribute("ShellAltitude")

		if type(shellAltitude) == "number" then
			clone.altitude = shellAltitude
		end

		local v2 = {
			body = instance,
			hrp = humanoidRootPart,
			mode = shell,
			knobs = clone,
			state = ShellCore.newState(toVec(humanoidRootPart.Position + Vector3.new(0, clone.altitude, 0)), 0),
			shell = buildShell(instance),
			shadow = buildShadow(clone.shadowRadius),
			params = RaycastParams.new(),
			conns = {}
		}
		v2.params.FilterType = Enum.RaycastFilterType.Exclude
		v2.params.RespectCanCollide = true
		v2.params.FilterDescendantsInstances = {
			instance,
			v2.shell,
			v2.shadow,
			workspace.CurrentCamera
		}
		setLocalTransparency(instance, 1)
		table.insert(v2.conns, instance.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				detach(instance)
			end
		end))
		table.insert(v2.conns, instance.Destroying:Connect(function()
			detach(instance)
		end))
		v[instance] = v2
		print(string.format("[ShellProjector] attached %s mode=%s altitude=%.1f", instance.Name, shell, clone.altitude))
	end
end

local ShellProjector = {
	shellFor = function(p)
		local v2 = v[p]
		return v2 and v2.shell or nil
	end
}
local fn

local function stepOne(instance, data, p)
	local hrp = data.hrp

	if not (hrp.Parent and instance.Parent) then
		detach(instance)
	elseif data.shell.Parent and data.shadow.Parent then
		local position = hrp.Position
		local raycastResult = workspace:Raycast(position, createVector(0, -60, 0), data.params)
		local raycastResult2 = workspace:Raycast(position, createVector(0, 60, 0), data.params)
		local Y = raycastResult and raycastResult.Position.Y or position.Y - 3
		local Y2 = raycastResult2 and raycastResult2.Position.Y or nil
		local lookVector = hrp.CFrame.LookVector
		local bodyYaw = math.atan2(-lookVector.X, -lookVector.Z)
		local shellDiveAt = instance:GetAttribute("ShellDiveAt")
		local v3 = ShellCore.step(data.state, {
			body = toVec(position),
			bodyYaw = bodyYaw,
			mode = data.mode,
			floorY = Y,
			ceilingY = Y2,
			phase = instance:GetAttribute("ShellPhase") or "Hover",
			diveAt = typeof(shellDiveAt) == "Vector3" and (toVec(shellDiveAt) or nil) or nil
		}, data.knobs, p)
		local v4 = CFrame.new(v3.pos.x, v3.pos.y, v3.pos.z) * CFrame.fromEulerAnglesYXZ(v3.pitch, v3.yaw, v3.roll)

		if v3.flipped then
			v4 *= CFrame.Angles(0, 0, 3.141592653589793)
		end

		data.shell:PivotTo(v4)
		local shadow = ShellCore.shadow(v3.pos, Y, data.knobs.altitude, data.knobs.shadowRadius)
		data.shadow.Size = Vector3.new(0.05, shadow.radius * 2, shadow.radius * 2)
		data.shadow.CFrame = CFrame.new(shadow.pos.x, shadow.pos.y + 0.05, shadow.pos.z) * CFrame.Angles(
			0,
			0,
			1.5707963267948966
		)
		data.shadow.Transparency = shadow.transparency
	else
		detach(instance)
		task.defer(fn, instance)
	end
end

local function stepAll(p)
	local info = workspace:FindFirstChild("Info")

	if info and info:GetAttribute("ShellEnabled") == false then
		for k in pairs(v) do
			detach(k)
		end
	else
		for k, v2 in pairs(v) do
			local success, result = pcall(stepOne, k, v2, p)

			if not success then
				warn(string.format("[ShellProjector] step failed for %s: %s", k.Name, (tostring(result))))
			end
		end
	end
end

local function steppedGuarded(p)
	local success, result = pcall(stepAll, p)

	if not success then
		warn(string.format("[ShellProjector] stepAll failed: %s", (tostring(result))))
	end
end

fn = function(model)
	task.spawn(function()
		for _ = 1, 20 do
			if v[model] or not model:IsDescendantOf(workspace) then
				break
			end

			if model:GetAttribute("Shell") then
				attach(model)
				break
			else
				task.wait(0.25)
			end
		end
	end)
end

local function discoverAndAttachAll()
	for _, model in ipairs(CollectionService:GetTagged("Twisted")) do
		if model:IsA("Model") then
			fn(model)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindShellEnabledWatch(object)
	local v2 = enabled() -- equivalent call inferred; original call site unknown
	object:GetAttributeChangedSignal("ShellEnabled"):Connect(function()
		local v3 = enabled() -- equivalent call inferred; original call site unknown

		if v3 and not v2 then
			discoverAndAttachAll()
		end

		v2 = v3
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armShellEnabledWatch()
	local info = workspace:FindFirstChild("Info")

	if info then
		bindShellEnabledWatch(info) -- equivalent call inferred; original call site unknown
	else
		local childAddedConnection = nil
		childAddedConnection = workspace.ChildAdded:Connect(function(child)
			if child.Name == "Info" then
				childAddedConnection:Disconnect()
				bindShellEnabledWatch(child) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

function ShellProjector.setupAll()
	if renderSteppedConnection then
		return
	end

	discoverAndAttachAll()
	CollectionService:GetInstanceAddedSignal("Twisted"):Connect(function(model)
		if model:IsA("Model") then
			fn(model)
		end
	end)
	CollectionService:GetInstanceRemovedSignal("Twisted"):Connect(detach)
	armShellEnabledWatch() -- equivalent call inferred; original call site unknown
	renderSteppedConnection = RunService.RenderStepped:Connect(steppedGuarded)
end

return ShellProjector