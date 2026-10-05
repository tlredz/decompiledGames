local Maid = require(script.Maid)
local MaidTaskUtils = require(script.MaidTaskUtils)
return {
	isValidTask = MaidTaskUtils.isValidTask,
	doTask = MaidTaskUtils.doTask,
	delayed = MaidTaskUtils.delayed,
	new = Maid.new
}