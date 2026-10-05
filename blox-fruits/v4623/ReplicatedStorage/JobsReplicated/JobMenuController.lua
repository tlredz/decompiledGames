local JobMenuController = {
	context = nil,
	currentScreenGui = nil
}
local jobsUI = script.JobsUI
jobsUI.Parent = nil
local Maid = require(game.ReplicatedStorage.Util.Maid)
local maid = Maid.new()
local v = {
	SkillFrame = function(_) end
}
local unpackHandlers

unpackHandlers = function(p, items, instance)
	for childName, item in items do
		if typeof(item) == "table" and instance:FindFirstChild(childName) then
			unpackHandlers(p, item, instance:FindFirstChild(childName))
		elseif typeof(item) == "function" then
			if childName == "OnCreated" then
				item(instance, p)
			elseif childName == "OnUpdate" then
				local v2 = item
				table.insert(p.OnUpdate, function(p2)
					v2(instance, p2)
				end)
			else
				local v2 = childName
				local v3 = item
				pcall(function()
					instance[v2]:Connect(function(...)
						v3(instance, p, ...)
					end)
				end)
			end
		else
			local v2 = childName
			local v3 = item
			pcall(function()
				instance[v2] = v3
			end)
		end
	end
end

JobMenuController.unpackHandlers = unpackHandlers

function JobMenuController.OpenJob(jobName: string)
	JobMenuController.currentScreenGui = jobsUI:Clone()
	maid.ScreenGui = JobMenuController.currentScreenGui
	local module = require(script.Jobs[jobName])
	local v2 = module(JobMenuController)
	local clone = table.clone(v2.ComponentHandlers or v)

	for k, v3 in v do
		if not clone[k] then
			clone[k] = v3
		end
	end

	local context = {
		JobName = jobName,
		OnUpdate = {},
		JobData = 0,
		JobsReplicated = 0,
		maid = 0
	}
	local parentModule = require(script.Parent)
	context.JobData = parentModule.GetJobData(jobName, true)
	context.JobsReplicated = require(script.Parent)
	context.maid = maid
	JobMenuController.context = context
	local descendants = JobMenuController.currentScreenGui:GetDescendants()
	table.sort(descendants, function(guiObject, guiObject2)
		if not guiObject:IsA("GuiObject") then
			return false
		end

		return not guiObject2:IsA("GuiObject") or guiObject.AbsolutePosition.Y < guiObject2.AbsolutePosition.Y
	end)

	for _, descendant in ipairs(descendants) do
		local v4 = clone[descendant:GetAttribute("Component")]

		if not v4 then
			continue
		end

		if typeof(v4) == "function" then
			v4(descendant, context)
		elseif typeof(v4) == "table" then
			unpackHandlers(context, v4, descendant)
		end
	end

	maid:GiveTask(function()
		JobMenuController.context = nil
		JobMenuController.currentScreenGui = nil
	end)
	local thread = task.defer(function()
		context.first = true
		JobMenuController.Update()
		context.first = false
		JobMenuController.currentScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
		JobMenuController.Update()
	end)
	maid:GiveTask(thread)

	while coroutine.status(thread) ~= "dead" do
		task.wait()
	end
end

function JobMenuController.Destroy()
	maid:DoCleaning()
end

function JobMenuController.Update(p, jobData)
	if not (JobMenuController.currentScreenGui and JobMenuController.context) or p and JobMenuController.context.JobName ~= p then
		return
	end

	if jobData then
		JobMenuController.context.JobData = jobData
	end

	for _, v2 in JobMenuController.context.OnUpdate do
		v2(JobMenuController.context)
	end
end

return JobMenuController