local UserInputService = game:GetService("UserInputService")
local Environment = {
	EnvGlobalInjectionKey = "__hotreload_env_global_injection__"
}

function SearchInEnv(p: string, p2)
	local envGlobalInjection = Environment.GetEnvGlobalInjection()

	if envGlobalInjection then
		p2 = envGlobalInjection[p] or p2
	end

	return p2
end

function Environment.GetEnvGlobalInjection()
	return getfenv()[Environment.EnvGlobalInjectionKey]
end

function Environment.IsStory()
	return Environment.GetEnvGlobalInjection() ~= nil
end

function UserInputFallback(p)
	if not p then
		return
	end

	if p == UserInputService then
		return
	else
		return (setmetatable(table.clone(p), {
			__index = UserInputService
		}))
	end
end

Environment.Unmount = SearchInEnv("Unmount", function() end)
Environment.Reload = SearchInEnv("Reload", function() end)
Environment.CreateSnapshot = SearchInEnv("CreateSnapshot", function() end)
Environment.SetStoryHolder = SearchInEnv("SetStoryHolder", function() end)

function Environment.GetJanitor()
	return (SearchInEnv("StoryJanitor"))
end

Environment.InputListener = SearchInEnv("InputListener", nil)
Environment.UserInput = UserInputFallback(SearchInEnv("InputListener", UserInputService))
Environment.EnvironmentUID = SearchInEnv("EnvironmentUID", "")
Environment.PreviewUID = SearchInEnv("PreviewUID", "")
Environment.OriginalG = SearchInEnv("OriginalG", _G)
Environment.PluginWidget = SearchInEnv("PluginWidget", nil)
return Environment