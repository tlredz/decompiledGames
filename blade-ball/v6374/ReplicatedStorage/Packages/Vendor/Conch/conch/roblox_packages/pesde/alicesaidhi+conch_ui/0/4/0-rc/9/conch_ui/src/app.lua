local module = require("../roblox_packages/conch")
local module2 = require("./components/ui/console_output")
local module3 = require("./components/core/container")
local module4 = require("./components/ui/executor")
local module5 = require("../roblox_packages/language")
local module6 = require("./levenshtein_distance")
local module7 = require("./components/core/screen")
local module8 = require("./state")
local module9 = require("../roblox_packages/vide")
local source = module9.source
local derive = module9.derive
local effect = module9.effect
local formatted = `conch-ui 0.4.0-rc.9\tconch-language {module5.version}\tconch {module.version}`
local buf = buffer.create(1)
buffer.writeu8(buf, 0, 10)
return function()
	local function output(state)
		if module8.logs.at > 0 then
			module8.logs:write(buf)
		end

		if state.kind == "error" then
			state.text = ("\27[1;48;310mERR\27[0;38m %*\27[0m"):format(state.text)
		elseif state.kind == "warn" then
			state.text = ("\27[1;43;310mWRN\27[0;33m %*\27[0m"):format(state.text)
		elseif state.kind == "info" then
			state.text = ("\27[1;46;310mINF\27[0;36m %*\27[0m"):format(state.text)
		elseif state.kind == "success" then
			state.text = ("\27[1;42;310mSUC\27[0;32m %*\27[0m"):format(state.text)
		end

		module8.logs:write(buffer.fromstring((tostring(state.text))))
	end

	module.console.output = output

	for _, text in string.split(formatted, "\n") do
		output({
			kind = "normal",
			text = text
		})
	end

	output({
		kind = "warn",
		text = "If you got here accidentally, run the `close-ui` command to close this UI."
	})
	module.register("clear", {
		description = "Clears the console.",
		permissions = {},
		arguments = function() end,
		callback = function()
			module8.current_stream():clear()
		end
	})
	module.register("ansi", {
		description = "Displays all possible ANSI colors",
		permissions = {},
		arguments = function() end,
		callback = function()
			local v = {}

			for i = 0, 15 do
				table.insert(v, (("\27[4%*m%*\t"):format(i, i)))
			end

			output({
				kind = "normal",
				text = "Regular ansi colors"
			})
			output({
				kind = "normal",
				text = table.concat(v)
			})
		end
	})
	module.register("close-ui", {
		description = "Close the CLI",
		permissions = {},
		arguments = function() end,
		callback = function()
			module8.opened(false)
			module8.focused(false)
		end
	})
	local update_text = source("")
	local working = source(false)
	local update_cursor = source(0)
	local analysis = source(module.analyze("", 0))
	local flag = false
	effect(function()
		update_text()
		update_cursor()

		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false
			analysis(module.analyze(update_text(), update_cursor() - 1))
		end)
	end)
	local filtered_suggestions = derive(function()
		local v6 = analysis()
		local suggestions = v6 and v6.suggestions

		if not suggestions then
			return {}
		end

		local v7 = string.lower((string.sub(update_text(), v6.replace.x + 1, update_cursor() - 1)))
		local v8 = string.gsub(v7, "[\"'](.*)", "%1", 1)
		local v9 = {}

		for _, suggestion in suggestions do
			if not string.find(string.lower(suggestion.display), string.gsub(v8, "^%s", ""), 0, true) then
				continue
			end

			local score = module6(string.lower(suggestion.display), string.lower(v8))

			if score ~= -1e999 then
				table.insert(v9, {
					suggestion = suggestion,
					score = score
				})
			end
		end

		table.sort(v9, function(a, b)
			return a.score < b.score
		end)
		local suggestions2 = {}

		for _, v10 in v9 do
			table.insert(suggestions2, v10.suggestion)
		end

		return suggestions2
	end)
	return module7({
		name = "Command Executor",
		display_order = 100000,
		enabled = module8.opened,
		module3({
			ws = 1,
			hs = 1,
			flex = {
				justify = "fill",
				align = module8.alignment
			},
			pad = {
				p = 12
			},
			module2({
				ws = 1,
				auto = "y",
				order = function()
					if module8.alignment() == "bottom" then
						return 1
					end

					return -1
				end,
				errors = function()
					local result = {}

					for _, issue in analysis().issues do
						table.insert(result, (`{issue.why} at {issue.span.x}:{issue.span.y}:{issue.span.z}`))
					end

					return result
				end
			}),
			module3({
				h = 4,
				order = function()
					if module8.alignment() == "bottom" then
						return 2
					end

					return -2
				end
			}),
			module4({
				ws = 1,
				order = function()
					if module8.alignment() == "bottom" then
						return 3
					end

					return -3
				end,
				working = working,
				filtered_suggestions = filtered_suggestions,
				analysis = analysis,
				update_cursor = update_cursor,
				update_text = update_text,
				execute = function(p)
					working(true)
					local _, _ = pcall(module.execute, p)
					working(false)
				end
			})
		})
	})
end