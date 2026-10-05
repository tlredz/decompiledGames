local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)

local function holder()
	local godlikeEmote = workspace.Debree:FindFirstChild("GodlikeEmote")

	if godlikeEmote ~= nil then
		return godlikeEmote
	end

	local folder = Instance.new("Folder")
	folder.Name = "GodlikeEmote"
	folder.Parent = workspace.Debree
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function light(instance)
	return instance:FindFirstChildWhichIsA("PointLight", true)
end

local function cut(instance)
	local v = workspace.Debree:FindFirstChild("GodlikeEmote")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "GodlikeEmote"
		v.Parent = workspace.Debree
	end

	local child = v:FindFirstChild(instance.Name)

	if child == nil then
		return
	end

	child.Name = `{instance.Name}_ending`
	Ouwmit.Enable(child, false)
	local v2 = light(child) -- equivalent call inferred; original call site unknown

	if v2 ~= nil then
		TweenService:Create(v2, TweenInfo.new(0.5), {
			Brightness = 0
		}):Play()
	end

	DebrisModule:AddItem(child, 4)
end

return function(instance, p: string?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		cut(instance)
		return
	end

	cut(instance)
	local pVInstance = script:FindFirstChildWhichIsA("PVInstance")

	if pVInstance == nil then
		warn((`{script.Name}: no effect (a Model or a part) is parented under the module, nothing to emit`))
		return
	end

	local clone = pVInstance:Clone()

	if clone:IsA("Model") and clone.PrimaryPart == nil then
		local root = clone:FindFirstChild("Root")

		if root ~= nil and root:IsA("BasePart") then
			clone.PrimaryPart = root
		end
	end

	clone.Name = instance.Name
	local parent = workspace.Debree:FindFirstChild("GodlikeEmote")

	if parent == nil then
		parent = Instance.new("Folder")
		parent.Name = "GodlikeEmote"
		parent.Parent = workspace.Debree
	end

	clone.Parent = parent
	clone:PivotTo(humanoidRootPart.CFrame)
	local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
		if not instance:IsDescendantOf(game) then
			cut(instance)
		end
	end)
	clone.Destroying:Connect(function()
		ancestryChangedConnection:Disconnect()
	end)
	local v2 = light(clone) -- equivalent call inferred; original call site unknown

	if v2 ~= nil then
		v2.Enabled = true
	end

	Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
end