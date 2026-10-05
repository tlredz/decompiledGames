local RequirementBehaviors = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local behaviors = script:WaitForChild("Behaviors")
local isServer = RunService:IsServer()
local ReplicatedDataController

if isServer then
	ReplicatedDataController = nil
else
	ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
end

local ProfileService

if isServer then
	local ServerScriptService = game:GetService("ServerScriptService")
	ProfileService = require(ServerScriptService.Modules.PlayerData.ProfileService)
else
	ProfileService = nil
end

function RequirementBehaviors.PassesRequirementCheck(p, p2: string, ...)
	local requirementBehavior = RequirementBehaviors.GetRequirementBehavior(p2)
	assert(requirementBehavior, "RequirementBehavior " .. p2 .. " does not exist")

	if isServer then
		assert(
			requirementBehavior.PassesRequirementServer,
			"Attempt to call RequirementBehaviors.PassesRequirementCheck for behavior " .. p2 .. " which does not have a server-side check."
		)
		local v, v2 = ProfileService.GetProfilePromise(p):await()

		if v and v2 then
			return requirementBehavior.PassesRequirementServer(p, v2, ...)
		end
	else
		assert(
			requirementBehavior.PassesRequirementClient,
			"Attempt to call RequirementBehaviors.PassesRequirementCheck for behavior " .. p2 .. " which does not have a client-side check."
		)
		local v, v2 = ReplicatedDataController.GetReplicatedDataPromise():await()

		if v and v2 then
			return requirementBehavior.PassesRequirementClient(p, v2, ...)
		end
	end

	return false
end

function RequirementBehaviors.IsVisible(_, p: string, ...)
	local requirementBehavior = RequirementBehaviors.GetRequirementBehavior(p)
	assert(
		requirementBehavior.IsVisible,
		"Attempt to call RequirementBehaviors.IsVisible for behavior " .. p .. " which does not have a visibility setting."
	)

	if typeof(requirementBehavior.IsVisible) == "boolean" then
		return requirementBehavior.IsVisible
	end

	return requirementBehavior.IsVisible(...)
end

function RequirementBehaviors.GetDeniedMessage(p, p2: string, ...)
	local requirementBehavior = RequirementBehaviors.GetRequirementBehavior(p2)
	assert(
		requirementBehavior.DeniedMessage,
		"Attempt to call RequirementBehaviors.GetDeniedMessage for behavior " .. p2 .. " which does not have a denied message."
	)

	if typeof(requirementBehavior.DeniedMessage) == "string" then
		return requirementBehavior.DeniedMessage
	end

	return requirementBehavior.DeniedMessage(p, ...)
end

function RequirementBehaviors.GetRequirementBehavior(childName: string)
	if not childName:match("/") then
		return require(behaviors:FindFirstChild(childName, true))
	end

	local child = behaviors

	for _, childName2 in childName:split("/") do
		child = child:FindFirstChild(childName2)
	end

	return require(child)
end

return RequirementBehaviors