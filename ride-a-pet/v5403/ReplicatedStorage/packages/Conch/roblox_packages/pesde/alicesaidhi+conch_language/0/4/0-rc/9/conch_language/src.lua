local module = require("@self/analysis")
local module2 = require("@self/ast")
local module3 = require("@self/ast/display")
local module4 = require("@self/treewalker")
local Src = {}
Src.version = "0.4.0-rc.9"

function Src.create_vm()
	return {
		global_metadata = {},
		vars_metadata = {},
		state = module4.create_state()
	}
end

function Src.set_command(p, p2: string, p3)
	p.state.globals[p2] = p3
end

function Src.set_variable(p, p2: string, p3)
	p.state.scope.vars[p2] = p3
end

function Src.attach_info(p, flag: boolean, p2: string, p3)
	if flag then
		p.vars_metadata[p2] = p3
		return {
			remove = function()
				p.vars_metadata[p2] = nil
			end
		}
	end

	p.global_metadata[p2] = p3
	return {
		remove = function()
			p.global_metadata[p2] = nil
		end
	}
end

function Src.run(p, str: string)
	local buffer2 = buffer.fromstring(str)
	local success, result = pcall(module2.parse, buffer2)

	if success and result.result then
		local v = module4.execute(p.state, result.result)

		if v.ok then
			return v
		end

		return {
			ok = false,
			why = { v.err }
		}
	else
		local why = {}

		for _, issue in result.issues do
			table.insert(why, (`{issue.why} at {issue.span.x}:{issue.span.y}:{issue.span.z}`))
		end

		return {
			ok = false,
			why = why
		}
	end
end

Src.analyze = module.analyze
Src.matches_type = module.matches_type
Src.display = module3
return Src