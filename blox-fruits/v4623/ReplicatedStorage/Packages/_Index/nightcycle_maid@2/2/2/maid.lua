local Maid = require(script:WaitForChild("Maid"))
local MaidTaskUtils = require(script:WaitForChild("MaidTaskUtils"))
return {
	isValidTask = MaidTaskUtils.isValidTask,
	doTask = MaidTaskUtils.doTask,
	delayed = MaidTaskUtils.delayed,
	new = Maid.new
}