local modules = {
	CutsceneEnvironment = require(script.Parent),
	EmptyOcean = require(script.EmptyOcean)
}
require(script.Parent.Parent.Types)
return table.freeze({
	create = function(p)
		if p == "Default" or p == "EmptyOcean" then
			return modules.CutsceneEnvironment.new(modules.EmptyOcean.create())
		end

		error(`Unknown cutscene environment preset "{p}"`, 2)
	end
})