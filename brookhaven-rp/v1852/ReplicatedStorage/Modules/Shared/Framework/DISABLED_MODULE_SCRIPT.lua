return (setmetatable({
	__loadOrder = 0,
	FrameworkInit = function() end,
	FrameworkStart = function() end
}, {
	__index = function(_, _)
		warn(
			`[DISABLED] Attempt to access disabled module script {script:GetFullName()}. This module script has been disabled and should not be used.`,
			debug.traceback()
		)
	end,
	__newindex = function(_, _, _)
		warn(
			`[DISABLED] Attempt to write to disabled module script {script:GetFullName()}. This module script has been disabled and should not be used.`,
			debug.traceback()
		)
	end,
	__metatable = false
}))