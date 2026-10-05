local TweenService = game:GetService("TweenService")
require(script.Parent.Parent.Parent.Parent.types.Property)
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local names = { "Constant" }
local v = {}
local names2 = {}
local v2 = {}

for _, v4 in Enum.EasingStyle:GetEnumItems() do
	table.insert(names, v4.Name)
	v[v4.Name] = v4
end

for _, v4 in Enum.EasingDirection:GetEnumItems() do
	table.insert(names2, v4.Name)
	v2[v4.Name] = v4
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

local function clampSize(vector2: Vector3)
	return (Vector3.new(math.max(vector2.X, 0.001), math.max(vector2.Y, 0.001), (math.max(vector2.Z, 0.001))))
end

local Size = {}
Size.stripType = "property"
Size.playbackMode = "continuous"
Size.propertyName = "Size"
Size.context = "both"
Size.catchUpPolicies = { "latest" }
Size.dataTemplate = {
	size = vector.create(1, 1, 1),
	easingStyle = quad,
	easingDirection = out
}
Size.supportsGlobal = false

function Size.buildEditor(p, state, _)
	p.Components:AddVector3Field(function(object)
		object:SetText("Size"):SetValue(state.size):SetOnChangedUnfocus(function(vector2: Vector3)
			state.size = Vector3.new(
				math.max(vector2.X, 0.001),
				math.max(vector2.Y, 0.001),
				(math.max(vector2.Z, 0.001))
			)
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Style"):SetChoiceList(names):SetSelected(getEasingStyleName(state.easingStyle)):SetOnChanged(function(p2: string)
			if p2 == "Constant" then
				state.easingStyle = "Constant"
			else
				state.easingStyle = v[p2] or quad
			end
		end)
	end)
	p.Components:AddDropdown(function(object)
		object:SetText("Easing Direction"):SetChoiceList(names2):SetSelected(state.easingDirection.Name):SetOnChanged(function(p2: string)
			state.easingDirection = v2[p2] or out
		end)
	end)
end

function Size.supports(part)
	return part:IsA("BasePart")
end

function Size.capture(p, _)
	return {
		size = p.Size,
		easingStyle = quad,
		easingDirection = out
	}
end

function Size.interpolate(data, p, p2: number)
	return {
		size = data.size:Lerp(p.size, getEasedAlpha(data, p2)),
		easingStyle = data.easingStyle,
		easingDirection = data.easingDirection
	}
end

function Size.apply(p, p2)
	local size = p2.size
	p.Size = Vector3.new(math.max(size.X, 0.001), math.max(size.Y, 0.001), (math.max(size.Z, 0.001)))
end

function Size.isApplied(p, p2, _)
	local size = p.Size
	local size2 = p2.size
	return size == Vector3.new(math.max(size2.X, 0.001), math.max(size2.Y, 0.001), (math.max(size2.Z, 0.001)))
end

return Size