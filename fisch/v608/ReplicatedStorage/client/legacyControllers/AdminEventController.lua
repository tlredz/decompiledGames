local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local sharedAdminEvent = ReplicatedStorage.shared.modules.SharedAdminEvent
local Loader = require(sharedAdminEvent.Loader)
local module = require("@self/ActionInstructions")
local AdminEventController = {
	Events = Loader(sharedAdminEvent.Events:GetChildren(), "Identity")
}

function AdminEventController.Start(_)
	task.wait(20)
	local _GetPreloadableContent = AdminEventController._GetPreloadableContent()
	AdminEventController._Preload(_GetPreloadableContent)
end

function AdminEventController._GetPreloadableContent()
	local tableUpvalue = {}

	for _, event in AdminEventController.Events do
		local _ = event.Actions
		module.Handle({
			Actions = event.Actions,
			Arguments = event.Arguments,
			TableUpvalue = tableUpvalue
		})
		task.wait(0)
	end

	return tableUpvalue
end

function AdminEventController._Preload(p)
	ContentProvider:PreloadAsync(p)
end

return AdminEventController