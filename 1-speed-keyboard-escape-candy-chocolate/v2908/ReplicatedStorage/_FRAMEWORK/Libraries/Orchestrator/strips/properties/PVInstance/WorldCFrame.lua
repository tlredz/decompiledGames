local TweenService = game:GetService("TweenService")
require(script.Parent.Parent.Parent.Parent.types.Property)
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local dataTemplate = {
	worldCFrame = CFrame.new(),
	easingStyle = quad,
	easingDirection = out
}
local names = { "Constant" }
local v2 = {}
local names2 = {}
local v3 = {}

for _, v4 in Enum.EasingStyle:GetEnumItems() do
	table.insert(names, v4.Name)
	v2[v4.Name] = v4
end

for _, v4 in Enum.EasingDirection:GetEnumItems() do
	table.insert(names2, v4.Name)
	v3[v4.Name] = v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEasingStyleName(p)
	if p == "Constant" then
		return "Constant"
	end

	return p.Name
end

local function getEasedAlpha(data, p: number)
	if data.easingStyle == "Constant" then
		return 0
	end

	return TweenService:GetValue(p, data.easingStyle, data.easingDirection)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRootCFrame(pVInstance)
	if pVInstance:IsA("PVInstance") then
		return (pVInstance:GetPivot())
	end

	return (CFrame.new())
end

local WorldCFrame = {}
WorldCFrame.stripType = "property"
WorldCFrame.playbackMode = "continuous"
WorldCFrame.propertyName = "WorldCFrame"
WorldCFrame.context = "both"
WorldCFrame.catchUpPolicies = { "latest" }
WorldCFrame.dataTemplate = dataTemplate
WorldCFrame.supportsGlobal = false

function WorldCFrame.buildEditor(p, state, _)
	p.Components:AddCFrameField(function(object)
		object:SetText("Root-Relative CFrame"):SetValue(state.worldCFrame):SetOnChangedUnfocus(function(worldCFrame: CFrame)
			state.worldCFrame = worldCFrame
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Style"):SetChoiceList(names):SetSelected(getEasingStyleName(state.easingStyle)):SetOnChanged(function(p2: string)
			if p2 == "Constant" then
				state.easingStyle = "Constant"
			else
				state.easingStyle = v2[p2] or quad
			end
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Direction"):SetChoiceList(names2):SetSelected(state.easingDirection.Name):SetOnChanged(function(p2: string)
			state.easingDirection = v3[p2] or out
		end)
	end)
end

function WorldCFrame.supports(pVInstance)
	return pVInstance:IsA("PVInstance")
end

function WorldCFrame.capture(instance, pVInstance)
	local rootCFrame = getRootCFrame(pVInstance) -- equivalent call inferred; original call site unknown
	return {
		worldCFrame = rootCFrame:ToObjectSpace(instance:GetPivot()),
		easingStyle = quad,
		easingDirection = out
	}
end

function WorldCFrame.interpolate(data, p, p2: number)
	return {
		worldCFrame = data.worldCFrame:Lerp(p.worldCFrame, getEasedAlpha(data, p2)),
		easingStyle = data.easingStyle,
		easingDirection = data.easingDirection
	}
end

function WorldCFrame.apply(instance, p, p2)
	local rootCFrame = getRootCFrame(p2.root) -- equivalent call inferred; original call site unknown
	instance:PivotTo(rootCFrame * p.worldCFrame)
end

function WorldCFrame.isApplied(instance, p, p2)
	local pivot = instance:GetPivot()
	local rootCFrame = getRootCFrame(p2.root) -- equivalent call inferred; original call site unknown
	return pivot == rootCFrame * p.worldCFrame
end

return WorldCFrame