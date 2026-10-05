local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "debug_lazyLoadOverlay",
	Aliases = { "lazyload_debug" },
	Description = "Shows or hides the on-screen list of lazy models currently loaded for you.",
	Group = "Debug",
	Args = {
		{
			Type = "boolean",
			Name = "enable",
			Description = "Whether to show the lazy load overlay.",
			Default = true,
			Optional = true
		}
	},
	ClientRun = function(_, flag: boolean)
		local v = flag == nil or flag
		local LazyLoadModelController = require(ReplicatedStorage.Modules.Client.LazyLoad.LazyLoadModelController)
		LazyLoadModelController.SetDebugEnabled(v)
		return (`Lazy load overlay is now {v and "enabled" or "disabled"}`)
	end
}