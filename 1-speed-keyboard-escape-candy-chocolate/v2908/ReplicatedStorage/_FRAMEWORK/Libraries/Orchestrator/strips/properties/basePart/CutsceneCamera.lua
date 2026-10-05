local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CameraManager = require(ReplicatedStorage._FRAMEWORK.Features.ClientOnly.CameraManager)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
require(script.Parent.Parent.Parent.Parent.types.Property)

-- equivalent calls inferred from this helper; original call sites unknown
local function isCurrentCutsceneCamera(p)
	return CameraManager.cutscene.getCurrentCutscenePart() == p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPluginCamera(p)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera ~= nil then
		local v = CameraManager.cutscene.getCurrentCutsceneCFrame() or p.CFrame
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = v
		currentCamera.Focus = v
		currentCamera.FieldOfView = CameraManager.cutscene.getCutsceneFOV()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releasePluginCamera()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera ~= nil then
		currentCamera.CameraType = Enum.CameraType.Fixed
		currentCamera.FieldOfView = 70
	end
end

local CutsceneCamera = {}
CutsceneCamera.stripType = "property"
CutsceneCamera.playbackMode = "continuous"
CutsceneCamera.propertyName = "CutsceneCamera"
CutsceneCamera.context = "client"
CutsceneCamera.catchUpPolicies = { "latest" }
CutsceneCamera.dataTemplate = {
	enabled = false
}
CutsceneCamera.supportsGlobal = false

function CutsceneCamera.buildEditor(p, p2, _)
	p.Components:AddCheckbox(function(object)
		object:SetText("Cutscene Camera"):SetValue(p2.enabled):SetOnChanged(function(enabled: boolean)
			p2.enabled = enabled
		end)
	end)
end

function CutsceneCamera.supports(part)
	return part:IsA("BasePart")
end

function CutsceneCamera.capture(p, _)
	return {
		enabled = isCurrentCutsceneCamera(p)
	}
end

function CutsceneCamera.interpolate(p, _, _: number)
	return p
end

function CutsceneCamera.apply(p, p2)
	if p2.enabled then
		if not Common.IsPlugin() then
			CameraManager.cutscene.startCutscene(p, 1)
			return
		end

		CameraManager.cutscene.startCutscene(p, nil)
		applyPluginCamera(p) -- equivalent call inferred; original call site unknown
	elseif isCurrentCutsceneCamera(p) then
		CameraManager.cutscene.stopCutscene()

		if Common.IsPlugin() then
			releasePluginCamera() -- equivalent call inferred; original call site unknown
		end
	end
end

function CutsceneCamera.isApplied(p, p2, _)
	local currentCutsceneCamera = isCurrentCutsceneCamera(p) -- equivalent call inferred; original call site unknown

	if p2.enabled then
		return currentCutsceneCamera
	end

	return not currentCutsceneCamera
end

return CutsceneCamera