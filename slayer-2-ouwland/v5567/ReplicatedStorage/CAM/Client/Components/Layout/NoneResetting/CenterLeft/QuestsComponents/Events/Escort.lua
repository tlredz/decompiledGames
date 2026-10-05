local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Row = require(script.Row)
require(script.Types)
require(ReplicatedStorage.Packages.faye)
local v = RunService:IsStudio() and not RunService:IsRunning()
local localPlayer = Players.LocalPlayer

local function visibleToMe(instance)
	local visibleTo = instance:GetAttribute("VisibleTo")

	if visibleTo == nil then
		return true
	end

	if type(visibleTo) ~= "string" then
		return false
	end

	local v2 = tostring(localPlayer == nil and 0 or localPlayer.UserId)

	for _, v3 in string.split(visibleTo, ",") do
		if v3 == v2 then
			return true
		end
	end

	return false
end

local function buildTestRun()
	local folder = Instance.new("Folder")
	folder.Name = "TestEscortRun"
	folder:SetAttribute("Icon", "rbxassetid://94727915573736")
	local model = Instance.new("Model")
	model.Name = "Escort"
	local part = Instance.new("Part")
	part.Name = "HumanoidRootPart"
	part.Anchored = true
	part.Parent = model
	model.PrimaryPart = part
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 500
	humanoid.Health = 310
	humanoid.Parent = model
	model.Parent = folder
	local configuration = Instance.new("Configuration")
	configuration.Name = "EscortInfo"
	configuration:SetAttribute("Title", "Mira")
	configuration:SetAttribute("PathCount", 6)
	configuration:SetAttribute("AmbushAt", "2,3,5")
	configuration:SetAttribute("Reached", 3)
	configuration:SetAttribute("Progress", 3)
	configuration:SetAttribute("Phase", "Ambush")
	configuration.Parent = folder
	return configuration
end

local function bind(object, instance)
	local parent = instance.Parent
	local model

	if parent ~= nil then
		model = parent:FindFirstChildOfClass("Model")
	end

	local humanoid

	if model == nil then
		humanoid = nil
	else
		humanoid = model:FindFirstChildOfClass("Humanoid")
	end

	local title = instance:GetAttribute("Title") or model == nil and "Escort" or model.Name
	local pathCount = instance:GetAttribute("PathCount") or 0
	local legs = math.max(pathCount - 1, 0)
	local ambushes = {}
	local ambushAt = instance:GetAttribute("AmbushAt")

	if type(ambushAt) == "string" and ambushAt ~= "" then
		for _, v4 in string.split(ambushAt, ",") do
			local v5 = tonumber(v4)

			if v5 ~= nil then
				table.insert(ambushes, v5)
			end
		end
	end

	local phase = object:Value(instance:GetAttribute("Phase") or "Waiting")
	local reached = object:Value(instance:GetAttribute("Reached") or 1)

	local function watch(attributeName: string, object2, p)
		object:Connect(instance:GetAttributeChangedSignal(attributeName), function()
			object2:Set(instance:GetAttribute(attributeName) or p)
		end)
	end

	local v4 = "Phase"
	local v5 = "Waiting"
	object:Connect(instance:GetAttributeChangedSignal("Phase"), function()
		phase:Set(instance:GetAttribute(v4) or v5)
	end)
	local v6 = "Reached"
	local v7 = 1
	object:Connect(instance:GetAttributeChangedSignal("Reached"), function()
		reached:Set(instance:GetAttribute(v6) or v7)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function alpha(p)
		if legs < 1 then
			return 0
		end

		return (math.clamp(((tonumber(p) or 1) - 1) / legs, 0, 1))
	end

	local progress = object:Value(alpha(instance:GetAttribute("Progress")))
	object:Connect(instance:GetAttributeChangedSignal("Progress"), function()
		progress:Set(alpha(instance:GetAttribute("Progress")))
	end)
	local healthPercent = object:Value(1)
	local healthSize = object:Value(UDim2.fromScale(1, 1))
	local healthText = object:Value("")
	local strokeThickness = object:Value(1)
	local strokeTransparency = object:Value(0.85)

	if humanoid ~= nil then
		local v8 = nil

		local function upd()
			local v9 = not (humanoid.MaxHealth > 0) and 1 or humanoid.MaxHealth
			local v10 = math.clamp(humanoid.Health / v9, 0, 1)
			healthPercent:Set(v10)
			healthSize:Set(UDim2.fromScale(v10, 1))
			healthText:Set(math.floor(humanoid.Health * 100) / 100 .. " / " .. humanoid.MaxHealth)

			if v8 ~= nil and v10 < v8 then
				strokeThickness:Refresh()
				strokeTransparency:Refresh()
			end

			v8 = v10
		end

		upd()
		object:Connect(humanoid.HealthChanged, upd)
	end

	local v8 = {
		Info = instance,
		Folder = parent,
		Rig = model,
		Humanoid = humanoid,
		Icon = 0,
		Title = 0,
		PathCount = 0,
		Legs = 0,
		Ambushes = 0,
		Phase = 0,
		Reached = 0,
		Progress = 0,
		HealthPercent = 0,
		HealthSize = 0,
		HealthText = 0,
		StrokeThickness = 0,
		StrokeTransparency = 0,
		IsLive = 0,
		IsCleared = 0
	}
	local icon

	if parent ~= nil then
		icon = parent:GetAttribute("Icon")
	end

	v8.Icon = icon
	v8.Title = title
	v8.PathCount = pathCount
	v8.Legs = legs
	v8.Ambushes = ambushes
	v8.Phase = phase
	v8.Reached = reached
	v8.Progress = progress
	v8.HealthPercent = healthPercent
	v8.HealthSize = healthSize
	v8.HealthText = healthText
	v8.StrokeThickness = strokeThickness
	v8.StrokeTransparency = strokeTransparency

	function v8.IsLive(callback, p: number)
		return callback(reached) == p and callback(phase) == "Ambush"
	end

	function v8.IsCleared(callback, p: number)
		local v10 = callback(reached)

		if p < v10 then
			return true
		elseif v10 == p then
			return callback(phase) ~= "Ambush"
		else
			return false
		end
	end

	return v8
end

local function rowHeight(p: number)
	return (math.min(p * 0.345, 50))
end

return function(object, p, _, p2: number)
	local formatted = `Escort - {p.Name}`
	local value = object:Value(nil)

	local function claims(p3)
		local parent = p3.Parent

		if parent == nil or parent.Name ~= formatted then
			return false
		end

		return parent:FindFirstChildOfClass("Model") ~= nil and visibleToMe(p3)
	end

	local function rescan()
		for _, v2 in CollectionService:GetTagged("EscortTag") do
			local parent = v2.Parent
			local v3

			if parent == nil or parent.Name ~= formatted or parent:FindFirstChildOfClass("Model") == nil then
				v3 = false
			else
				v3 = visibleToMe(v2)
			end

			if not v3 then
				continue
			end

			value:Set(v2)
			return
		end

		value:Set(nil)
	end

	local function follow(instance)
		object:Connect(instance:GetAttributeChangedSignal("VisibleTo"), rescan)
		local v2 = nil

		local function hookFolder()
			local parent = instance.Parent

			if parent == nil or parent == v2 then
				return
			end

			v2 = parent
			object:Connect(parent.ChildAdded, rescan)
			rescan()
		end

		object:Connect(instance.AncestryChanged, hookFolder)
		local parent = instance.Parent

		if parent ~= nil and parent ~= v2 then
			v2 = parent
			object:Connect(parent.ChildAdded, rescan)
			rescan()
		end
	end

	for _, v2 in CollectionService:GetTagged("EscortTag") do
		follow(v2)
	end

	object:Connect(CollectionService:GetInstanceAddedSignal("EscortTag"), function(p3)
		follow(p3)
		rescan()
	end)
	object:Connect(CollectionService:GetInstanceRemovedSignal("EscortTag"), rescan)
	rescan()

	if v and value:Get() == nil then
		value:Set((buildTestRun()))
	end

	return object:Create("Frame")({
		Name = "AEvent",
		BackgroundTransparency = 1,
		Size = object:Do(function(callback, _, _)
			return UDim2.new(1, 0, 0, callback(value) == nil and 0 or math.min(p2 * 0.345, 50))
		end),
		object:State(function(callback, p3, _)
			local v2 = callback(value)

			if v2 == nil then
				return nil
			end

			return Row(p3, bind(p3, v2), p2)
		end)
	})
end