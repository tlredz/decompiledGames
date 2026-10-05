local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)

local function holder()
	local cryEmote = workspace.Debree:FindFirstChild("CryEmote")

	if cryEmote ~= nil then
		return cryEmote
	end

	local folder = Instance.new("Folder")
	folder.Name = "CryEmote"
	folder.Parent = workspace.Debree
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cut(instance)
	local v = workspace.Debree:FindFirstChild("CryEmote")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "CryEmote"
		v.Parent = workspace.Debree
	end

	local child = v:FindFirstChild(instance.Name)

	if child == nil then
		return
	end

	child.Name = `{instance.Name}_ending`
	Ouwmit.Enable(child, false)
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
		cut(instance) -- equivalent call inferred; original call site unknown
	else
		cut(instance) -- equivalent call inferred; original call site unknown
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
		local parent = workspace.Debree:FindFirstChild("CryEmote")

		if parent == nil then
			parent = Instance.new("Folder")
			parent.Name = "CryEmote"
			parent.Parent = workspace.Debree
		end

		clone.Parent = parent
		clone:PivotTo(humanoidRootPart.CFrame)
		DebrisModule:AddItem(clone, 5)
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
	end
end