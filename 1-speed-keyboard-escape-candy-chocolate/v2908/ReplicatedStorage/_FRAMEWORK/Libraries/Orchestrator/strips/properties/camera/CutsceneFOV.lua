local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CameraManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.CameraManager)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPluginFieldOfView(fieldOfView: number)
	if Common.IsPlugin() and CameraManager.cutscene.isInCutscene() then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera ~= nil then
			currentCamera.FieldOfView = fieldOfView
		end
	end
end

local CutsceneFOV = {}
CutsceneFOV.stripType = "property"
CutsceneFOV.playbackMode = "continuous"
CutsceneFOV.propertyName = "CutsceneFOV"
CutsceneFOV.context = "client"
CutsceneFOV.catchUpPolicies = { "latest" }
CutsceneFOV.dataTemplate = {
	fieldOfView = 70,
	easingStyle = quad,
	easingDirection = out
}
CutsceneFOV.supportsGlobal = true

function CutsceneFOV.buildEditor(p, state, _)
	p.Components:AddNumberField(function(object)
		object:SetText("Field of View"):SetValue(state.fieldOfView):SetNumberFilter(1, 120):SetOnChangedUnfocus(function(fieldOfView: number)
			state.fieldOfView = fieldOfView
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

function CutsceneFOV.supports(_)
	return false
end

function CutsceneFOV.capture(_, _)
	return {
		fieldOfView = CameraManager.cutscene.getCutsceneFOV(),
		easingStyle = quad,
		easingDirection = out
	}
end

function CutsceneFOV.interpolate(data, p, p2: number)
	return {
		fieldOfView = math.lerp(data.fieldOfView, p.fieldOfView, getEasedAlpha(data, p2)),
		easingStyle = data.easingStyle,
		easingDirection = data.easingDirection
	}
end

function CutsceneFOV.apply(_, p)
	CameraManager.cutscene.setCutsceneFOV(p.fieldOfView)
	applyPluginFieldOfView(p.fieldOfView) -- equivalent call inferred; original call site unknown
end

function CutsceneFOV.isApplied(_, p, _)
	return CameraManager.cutscene.getCutsceneFOV() == p.fieldOfView
end

return CutsceneFOV