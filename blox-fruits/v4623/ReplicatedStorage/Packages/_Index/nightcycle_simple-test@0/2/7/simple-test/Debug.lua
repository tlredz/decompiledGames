local ENV = require(script.Parent.ENV)
local Debug = {}

function Debug.log(p: string)
	if ENV.IS_VERBOSE then
		print(p)
	end
end

function Debug.warn(p: string)
	if ENV.IS_VERBOSE then
		warn(p)
	end
end

return Debug