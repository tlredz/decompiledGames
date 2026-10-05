local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ViewportSize = require(ReplicatedStorage.Client.ViewportSize)
local v = {
	LeftControls = true,
	RightButtons = true
}
local v2 = {
	Chat = true,
	TouchGui = true
}
local v3 = {
	ImageButton = {
		Property = "SliceScale",
		Baseline = "AuthoredSliceScale",
		Applies = function(p)
			return p.ScaleType == Enum.ScaleType.Slice
		end
	},
	ImageLabel = {
		Property = "SliceScale",
		Baseline = "AuthoredSliceScale",
		Applies = function(p)
			return p.ScaleType == Enum.ScaleType.Slice
		end
	},
	UIStroke = {
		Property = "Thickness",
		Baseline = "AuthoredThickness",
		Applies = function(p)
			return p.StrokeSizingMode == Enum.StrokeSizingMode.FixedSize
		end
	}
}
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local v4 = 1

local function isScaledScreen(layerCollector)
	local isA = layerCollector:IsA("LayerCollector")

	if isA then
		if v2[layerCollector.Name] == true then
			isA = false
		else
			isA = layerCollector:GetAttribute("ScaledDecoration") ~= false
		end
	end

	return isA
end

local function screenOf(parent)
	while parent ~= nil and parent.Parent ~= playerGui do
		parent = parent.Parent
	end

	return parent
end

local function pinned(instance, attributeName: string, p: number)
	local attribute = instance:GetAttribute(attributeName)

	if type(attribute) == "number" then
		return attribute
	end

	instance:SetAttribute(attributeName, p)
	return p
end

local function scaleDecoration(instance)
	local v5 = v3[instance.ClassName]

	if v5 == nil or not v5.Applies(instance) then
		return
	end

	local property = v5.Property
	local baseline = v5.Baseline
	local v6 = instance[v5.Property]
	local attribute = instance:GetAttribute(baseline)

	if type(attribute) == "number" then
		v6 = attribute
	else
		instance:SetAttribute(baseline, v6)
	end

	instance[property] = v6 * v4
end

local function refit(p: number)
	v4 = math.lerp(1, p, 0.45)

	for _, layerCollector in playerGui:GetChildren() do
		local isA = layerCollector:IsA("LayerCollector")

		if isA then
			if v2[layerCollector.Name] == true then
				isA = false
			else
				isA = layerCollector:GetAttribute("ScaledDecoration") ~= false
			end
		end

		if not isA then
			continue
		end

		for _, descendant in layerCollector:GetDescendants() do
			local v5 = v3[descendant.ClassName]

			if not (v5 ~= nil and v5.Applies(descendant)) then
				continue
			end

			local property = v5.Property
			local baseline = v5.Baseline
			local v6 = descendant[v5.Property]
			local attribute = descendant:GetAttribute(baseline)

			if type(attribute) == "number" then
				v6 = attribute
			else
				descendant:SetAttribute(baseline, v6)
			end

			descendant[property] = v6 * v4
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function adoptLater(descendant)
	task.defer(function()
		local parent = descendant

		while parent ~= nil and parent.Parent ~= playerGui do
			parent = parent.Parent
		end

		if parent ~= nil then
			local isA = parent:IsA("LayerCollector")

			if isA then
				if v2[parent.Name] == true then
					isA = false
				else
					isA = parent:GetAttribute("ScaledDecoration") ~= false
				end
			end

			if isA then
				local v5 = descendant
				local v6 = v3[v5.ClassName]

				if v6 ~= nil then
					if not v6.Applies(v5) then
						return
					end

					local property = v6.Property
					local baseline = v6.Baseline
					local v7 = v5[v6.Property]
					local attribute = v5:GetAttribute(baseline)

					if type(attribute) == "number" then
						v7 = attribute
					else
						v5:SetAttribute(baseline, v7)
					end

					v5[property] = v7 * v4
				end
			end
		end
	end)
end

playerGui.DescendantAdded:Connect(function(descendant)
	if v3[descendant.ClassName] ~= nil then
		adoptLater(descendant) -- equivalent call inferred; original call site unknown
	end
end)
ViewportSize.Observe(function(_, p)
	refit(p)
end)
task.spawn(function()
	local Hud = require(ReplicatedStorage.Client.Hud)
	local v5 = {}

	for _, v6 in { "Game", "Treadmill" } do
		for _, frame in Hud.Frame(v6):GetChildren() do
			if not (frame:IsA("Frame") and v[frame.Name] == true) then
				continue
			end

			local uIScale = Instance.new("UIScale")
			uIScale.Name = "HudFitScale"
			uIScale.Parent = frame
			table.insert(v5, uIScale)
		end
	end

	ViewportSize.Observe(function(_, p)
		local scale = (1 + 0.1 / p) / 1.1

		for _, v7 in v5 do
			v7.Scale = scale
		end
	end)
end)
return table.freeze({})