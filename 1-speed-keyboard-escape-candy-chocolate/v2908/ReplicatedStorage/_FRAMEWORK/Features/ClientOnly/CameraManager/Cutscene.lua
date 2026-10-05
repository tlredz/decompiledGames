local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Signal = require(ReplicatedStorage.Utilities.Signal)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Cutscene = {}
local _ = Workspace.CurrentCamera
local v = nil
local v2 = nil
local v3 = nil
local v4 = 1
local v5 = 70
local v6 = false
Cutscene.onCutsceneStateChanged = Signal.new()

function Cutscene.isInCutscene()
	return v ~= nil and (v2 == nil or os.clock() < v2)
end

function Cutscene.getCurrentCutscenePart()
	if Cutscene.isInCutscene() then
		return v
	end

	return nil
end

function Cutscene.getCurrentCutsceneCFrame()
	local currentCutscenePart = Cutscene.getCurrentCutscenePart()

	if currentCutscenePart then
		return (v3 or currentCutscenePart.CFrame):Lerp(currentCutscenePart.CFrame, v4)
	end

	return nil
end

function Cutscene.stopCutscene()
	v = nil
	v2 = nil
	v3 = nil
	v4 = 1
	v5 = 70
end

function Cutscene.startCutscene(p, p2: number?)
	if v ~= p or not Cutscene.isInCutscene() then
		local currentCamera = Workspace.CurrentCamera
		local v7

		if currentCamera then
			v7 = currentCamera.CFrame
		else
			v7 = p.CFrame
		end

		v3 = v7
	end

	v = p
	local v7

	if p2 ~= nil then
		v7 = os.clock() + p2
	end

	v2 = v7
end

function Cutscene.setCutsceneAlpha(value: number)
	v4 = math.clamp(value, 0, 1)
end

function Cutscene.getCutsceneAlpha()
	return v4
end

function Cutscene.resetCutsceneFOV()
	Cutscene.setCutsceneFOV(70)
end

function Cutscene.setCutsceneFOV(p: number)
	v5 = p
end

function Cutscene.getCutsceneFOV()
	return v5
end

FeatureManager.RegisterFeature(script.Name, {
	OnRender = function()
		local inCutscene = Cutscene.isInCutscene()

		if v6 ~= inCutscene then
			v6 = inCutscene
			Cutscene.onCutsceneStateChanged:Fire(v6)
		end
	end
})
return Cutscene