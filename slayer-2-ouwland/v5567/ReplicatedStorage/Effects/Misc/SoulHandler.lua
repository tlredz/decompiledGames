local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function bodyParts(folder, parentRoot)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part ~= parentRoot and part.Name ~= "SoulGroundHost" then
			table.insert(parts, part)
		end
	end

	return parts
end

local function tierEffect(p, childName: string)
	local child = script:FindFirstChild(p.Name)
	return child ~= nil and child:FindFirstChild(childName) or nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundBelow(parentRoot)
	return workspace:Raycast(
		parentRoot.Position + createVector(0, 3, 0),
		createVector(-0, -50, -0),
		RaycastHelper.Crater
	)
end

local function groundHost(parent, position: Vector3)
	local part = Instance.new("Part")
	part.Name = "SoulGroundHost"
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(position)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Massless = true
	part.Transparency = 1
	part.Parent = parent
	return part
end

return function(parent, p: string)
	if parent == nil then
		return
	end

	local parentRoot = parent:FindFirstChild("Root") or parent.PrimaryPart or parent:WaitForChild("Root", 5)

	if parentRoot == nil or not parentRoot:IsA("BasePart") then
		return
	end

	if p == "Spawn" then
		local v = bodyParts(parent, parentRoot)

		if #v == 0 then
			task.wait()
			v = bodyParts(parent, parentRoot)
		end

		for _, v2 in v do
			local soulTransparency = v2:GetAttribute("SoulTransparency")
			v2.Transparency = 1
			TweenService:Create(v2, tweenInfo2, {
				Transparency = typeof(soulTransparency) ~= "number" and 0 or soulTransparency
			}):Play()
		end

		local child = script:FindFirstChild(parent.Name)
		local spawn

		if child ~= nil then
			spawn = child:FindFirstChild("Spawn") or nil
		end

		if spawn ~= nil then
			local clone = spawn:Clone()
			clone.Parent = parentRoot
			vfxUtility.PlaySound(script, "PS2soulSPAWN", clone)
			Ouwmit.Emit(clone)
		end
	elseif p == "Idle" then
		TweenService:Create(parentRoot, tweenInfo, {
			CFrame = parentRoot.CFrame * CFrame.new(0, 1, 0)
		}):Play()
		local child = script:FindFirstChild(parent.Name)
		local idle

		if child ~= nil then
			idle = child:FindFirstChild("Idle") or nil
		end

		if idle == nil then
			return
		end

		local clone = idle:Clone()
		clone.Parent = parentRoot
		vfxUtility.PlaySound(script, "PS2soulLOOP", clone)
		local ground = clone:FindFirstChild("Ground")
		local v = nil

		if ground ~= nil then
			local v2 = groundBelow(parentRoot) -- equivalent call inferred; original call site unknown

			if v2 == nil then
				ground = nil
			else
				v = vfxUtility.GetDustColorSettings(v2.Instance)
				local position = v2.Position
				local part = Instance.new("Part")
				part.Name = "SoulGroundHost"
				part.Size = createVector(1, 1, 1)
				part.CFrame = CFrame.new(position)
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.CastShadow = false
				part.Massless = true
				part.Transparency = 1
				part.Parent = parent
				ground.Parent = part

				if ground:IsA("Attachment") then
					ground.WorldPosition = v2.Position
				elseif ground:IsA("Model") or ground:IsA("BasePart") then
					ground:PivotTo(CFrame.new(v2.Position))
				end
			end
		end

		Ouwmit.Enable(clone, true, v)

		if ground ~= nil then
			Ouwmit.Enable(ground, true, v)
		end
	else
		if p ~= "Disappear" then
			return
		end

		local idle = parentRoot:FindFirstChild("Idle")

		if idle ~= nil then
			Ouwmit.Enable(idle, false)
			local pS2soulLOOP = idle:FindFirstChild("PS2soulLOOP")

			if pS2soulLOOP ~= nil and pS2soulLOOP:IsA("Sound") then
				pS2soulLOOP:Stop()
			end
		end

		local soulGroundHost = parent:FindFirstChild("SoulGroundHost")
		local ground

		if soulGroundHost ~= nil then
			ground = soulGroundHost:FindFirstChild("Ground") or nil
		end

		if ground ~= nil then
			Ouwmit.Enable(ground, false)
		end

		local child = script:FindFirstChild(parent.Name)
		local grab

		if child ~= nil then
			grab = child:FindFirstChild("Grab") or nil
		end

		if grab ~= nil then
			local clone = grab:Clone()

			if clone:IsA("Attachment") then
				local cFrame = clone.CFrame
				clone.Parent = workspace.Debree
				clone.WorldCFrame = parentRoot.CFrame * cFrame
			else
				clone.Parent = workspace.Debree

				if clone:IsA("Model") or clone:IsA("BasePart") then
					clone:PivotTo(parentRoot.CFrame)
				end
			end

			vfxUtility.PlaySound(script, "PS2soulGRAB", clone)
			Ouwmit.Emit(clone)
			DebrisModule:AddItem(clone, 4)
		end

		for _, v in bodyParts(parent, parentRoot) do
			TweenService:Create(v, tweenInfo2, {
				Transparency = 1
			}):Play()
		end
	end
end