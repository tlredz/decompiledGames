local module = require("../../roblox_packages/conch")
local module2 = require("../../roblox_packages/vide")
local module3 = require("../state")
local module4 = require("../components/suggestion")
local source = module2.source
return function(p)
	module3.opened(true)
	module._.create_local_user()
	return module2.mount(function()
		return module4({
			highlighted_suggestion = source({
				name = "highlight",
				description = "this argument onmly takes like a vector or something and does this and that i honestly dont care.",
				type = "meow"
			}),
			suggestions = source({
				"test",
				"value",
				"grapes",
				"apples"
			})
		})
	end, p)
end