local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)

local function holder()
	local sleepingEmote = workspace.Debree:FindFirstChild("SleepingEmote")

	if sleepingEmote ~= nil then
		return sleepingEmote
	end

	local folder = Instance.new("Folder")
	folder.Name = "SleepingEmote"
	folder.Parent = workspace.Debree
	return folder
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cut(p)
	local v = workspace.Debree:FindFirstChild("SleepingEmote")

	if v == nil then
		v = Instance.new("Folder")
		v.Name = "SleepingEmote"
		v.Parent = workspace.Debree
	end

	local child = v:FindFirstChild(p.Name)

	if child == nil then
		return
	end

	child.Name = `{p.Name}_ending`
	Ouwmit.Enable(child, false)
	DebrisModule:AddItem(child, 3)
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
		local parent = workspace.Debree:FindFirstChild("SleepingEmote")

		if parent == nil then
			parent = Instance.new("Folder")
			parent.Name = "SleepingEmote"
			parent.Parent = workspace.Debree
		end

		clone.Parent = parent
		clone:PivotTo(humanoidRootPart.CFrame)
		local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
			if not instance:IsDescendantOf(game) then
				cut(instance) -- equivalent call inferred; original call site unknown
			end
		end)
		clone.Destroying:Connect(function()
			ancestryChangedConnection:Disconnect()
		end)
		Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
	end
end