local DateTime = require(script:WaitForChild("DateTime"))
local Net = require(script:WaitForChild("Net"))
local Task = require(script:WaitForChild("Task"))
local Secrets = require(script:WaitForChild("Secrets"))
local CONFIG = require(script:WaitForChild("CONFIG"))
return table.freeze({
	IS_LUNE_ENV = CONFIG.IS_LUNE_ENV,
	IS_RBX_ENV = CONFIG.IS_RBX_ENV,
	Task = Task,
	Net = Net,
	DateTime = DateTime,
	Secrets = Secrets,
	Env = require(script:WaitForChild("Env"))
})