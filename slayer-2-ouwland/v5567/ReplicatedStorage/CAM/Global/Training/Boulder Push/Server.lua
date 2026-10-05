local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local WorldEvents = require(ServerStorage.SAM.Utility.WorldEvents)
local firstlightWagasa = WorldEvents.Get("FirstlightWagasa")
local TrainingStorage = require(ServerStorage.SAM.Utility.TrainingStorage)
local TrainingQuestCredit = require(ServerStorage.SAM.Utility.TrainingQuestCredit)
local TrainingResult = require(ServerStorage.SAM.Utility.TrainingResult)

-- equivalent calls inferred from this helper; original call sites unknown
local function setPushing(state, pushing: boolean)
	if state.Pushing == pushing then
		return
	end

	state.Pushing = pushing
	local weldedBoulder = state.WeldedBoulder

	if weldedBoulder == nil then
		return
	end

	EffectsEvent.ToAllInRange(weldedBoulder, "BoulderPushEffect", weldedBoulder, pushing)
end

local BoulderPush = {}

function BoulderPush.Do(p, p2, state, instance, p3)
	state.Boulder = p3.Parent
	state.Pushing = false
	state.Boulder.Transparency = 1
	state.Boulder.CanCollide = false
	state.WeldedBoulder = script.Boulder:Clone()
	state.WeldedBoulder.Parent = workspace.Debree
	state.WeldedBoulder.Weld.Part0 = p2.HumanoidRootPart
	local clone = script.PS2trainingBOULDPUSHgrab:Clone()
	clone.Parent = state.WeldedBoulder
	clone:Play()
	local v

	if firstlightWagasa == nil then
		v = nil
	else
		v = firstlightWagasa.GoalFor(p, state.Boulder.Parent)
	end

	local v2 = v or state.Boulder.Parent:FindFirstChild("Goal")

	if v ~= nil then
		instance:SetAttribute("WagasaRoute", true)
	end

	local v3 = v2 == nil and 0 or (v2:GetPivot().Position - state.Boulder.Position).Magnitude
	instance:SetAttribute("LeashCenter", state.Boulder.Position)
	instance:SetAttribute("LeashRadius", v3 + 75)

	if v2 == nil then
		return true, true
	end

	local pivot = v2:GetPivot()
	instance:SetAttribute("GoalName", v2.Name)
	instance:SetAttribute("GoalPosition", pivot.Position)
	local flag = false
	state.WeldedBoulder.Touched:Connect(function(otherPart)
		if flag or otherPart ~= v2 and not otherPart:IsDescendantOf(v2) then
			return
		end

		flag = true
		EffectsEvent.ToAllInRange(pivot, "BoulderPlaced", pivot)
		TrainingQuestCredit(p, "Boulder Push")
		TrainingResult(p, "Boulder Push", true)

		if v ~= nil then
			firstlightWagasa.Reveal(p)
		end

		instance:Destroy()
		TrainingStorage.ClearStorage(p)
	end)
	return true, true
end

function BoulderPush.Destroying(_, _, state, _)
	state.Boulder.Transparency = 0
	state.Boulder.CanCollide = true
	state.Boulder = nil
	state.WeldedBoulder:Destroy()
	state.WeldedBoulder = nil
end

function BoulderPush.StateChanged(_, _, state, flag: boolean?)
	setPushing(state, flag == true) -- equivalent call inferred; original call site unknown
end

function BoulderPush.Stop(_, _, _, ...)
	return true
end

return BoulderPush