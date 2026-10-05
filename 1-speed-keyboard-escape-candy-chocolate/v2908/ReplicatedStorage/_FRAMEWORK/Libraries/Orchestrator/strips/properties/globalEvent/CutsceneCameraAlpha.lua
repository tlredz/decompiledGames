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
local function applyPluginCamera()
	if Common.IsPlugin() and CameraManager.cutscene.isInCutscene() then
		local currentCamera = Workspace.CurrentCamera
		local currentCutsceneCFrame = CameraManager.cutscene.getCurrentCutsceneCFrame()

		if currentCamera ~= nil and currentCutsceneCFrame ~= nil then
			currentCamera.CFrame = currentCutsceneCFrame
			currentCamera.Focus = currentCutsceneCFrame
		end
	end
end

local CutsceneCameraAlpha = {}
CutsceneCameraAlpha.stripType = "property"
CutsceneCameraAlpha.playbackMode = "continuous"
CutsceneCameraAlpha.propertyName = "Cutscene Camera Alpha"
CutsceneCameraAlpha.context = "client"
CutsceneCameraAlpha.catchUpPolicies = { "latest" }
CutsceneCameraAlpha.dataTemplate = {
	alpha = 1,
	easingStyle = quad,
	easingDirection = out
}
CutsceneCameraAlpha.supportsGlobal = true

function CutsceneCameraAlpha.buildEditor(p, state, _)
	p.Components:AddNumberField(function(object)
		object:SetText("Camera Blend Alpha"):SetValue(state.alpha):SetNumberFilter(0, 1):SetOnChangedUnfocus(function(alpha: number)
			state.alpha = alpha
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

function CutsceneCameraAlpha.supports(_)
	return false
end

function CutsceneCameraAlpha.capture(_, _)
	return {
		alpha = CameraManager.cutscene.getCutsceneAlpha(),
		easingStyle = quad,
		easingDirection = out
	}
end

function CutsceneCameraAlpha.interpolate(data, p, p2: number)
	return {
		alpha = math.lerp(data.alpha, p.alpha, getEasedAlpha(data, p2)),
		easingStyle = data.easingStyle,
		easingDirection = data.easingDirection
	}
end

function CutsceneCameraAlpha.apply(_, p)
	CameraManager.cutscene.setCutsceneAlpha(p.alpha)
	applyPluginCamera() -- equivalent call inferred; original call site unknown
end

function CutsceneCameraAlpha.isApplied(_, p, _)
	return math.abs(CameraManager.cutscene.getCutsceneAlpha() - p.alpha) <= 1e-6
end

return CutsceneCameraAlpha