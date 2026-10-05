local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)

local function setEnabled(folder, enabled)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
			continue
		end

		descendant.Enabled = enabled

		if not (descendant:IsA("PointLight") and enabled == false) then
			continue
		end

		descendant.Enabled = true
		TweenService:Create(descendant, TweenInfo.new(0.3), {
			Brightness = 0
		}):Play()
	end
end

return function(instance, value: number?, value2: number?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	local v = (value or 80) * 0.85
	local cFrame = humanoidRootPart.CFrame
	local folder = Instance.new("Folder")
	folder.Name = "BearDash"
	folder.Parent = workspace.Debree
	task.delay(6, folder.Destroy, folder)
	local raycastResult = workspace:Raycast(
		cFrame.Position + createVector(0, 5, 0),
		createVector(-0, -20, -0),
		RaycastHelper.Crater
	)
	local v2 = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
	local clone = script.Dash:Clone()
	clone.Parent = folder
	clone:PivotTo(cFrame)
	local p0 = clone.Dirt.p0
	local p1 = clone.Dirt.p1
	p0:FindFirstChild("CFrame"):SetAttribute(
		"_END_VALUE",
		CFrame.new(p0.Position + cFrame.LookVector * v - createVector(0, 2.5, 0))
	)
	p1:FindFirstChild("CFrame"):SetAttribute(
		"_END_VALUE",
		CFrame.new(p1.Position + cFrame.LookVector * v - createVector(0, 2.5, 0))
	)
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, v2))
	task.delay(5, clone.Destroy, clone)
	local clone2 = script.Trail:Clone()
	clone2.Parent = folder
	clone2.CFrame = cFrame * CFrame.new(0, -2, 0)
	clone2.PS2bearDASH:Play()
	Ouwmit.Emit(clone2, Ouwmit.Owned(instance, v2))
	task.delay(0.65, function()
		setEnabled(clone2, false)
		clone2.Anchored = true
		task.delay(3, clone2.Destroy, clone2)
	end)
	local v3 = cFrame.Position + cFrame.LookVector * v
	TweenService:Create(clone2, TweenInfo.new(value2 or 0.85, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Position = v3 - createVector(0, 2, 0)
	}):Play()
end