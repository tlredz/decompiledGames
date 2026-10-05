local module = require("./background")
local module2 = require("../../util/component")
local module3 = require("../core/container")
require("../../../roblox_packages/language")
local module4 = require("../../state")
local module5 = require("../core/text")
local module6 = require("../../theme")
local module7 = require("../../../roblox_packages/vide")
local show = module7.show
local indexes = module7.indexes
local _ = module7.source
local _ = module7.effect
return module2(function(data, _)
	local show_suggestions_from = data.show_suggestions_from
	return module3({
		w = 300,
		auto = "y",
		anchor = function()
			if module4.alignment() == "top" then
				return { 0, 0 }
			end

			return { 0, 1 }
		end,
		z = 10000,
		thickness = 0,
		corner = 4,
		flex = {
			direction = "row",
			justify = "left",
			align = "bottom",
			pad = 4
		},
		show(function()
			return #data.result().suggestions > 0
		end, function()
			return module({
				w = 300,
				anchor = { 0, 1 },
				flex = {
					justify = "left",
					align = "bottom"
				},
				transparency = 0,
				auto = "y",
				indexes(function()
					local result = {}

					for i = show_suggestions_from(), show_suggestions_from() + 10 - 1 do
						result[i] = data.suggestions()[i]
					end

					return result
				end, function(callback, order: number)
					return module3({
						ws = 1,
						h = 20,
						order = order,
						color = module6.select_color("crust"),
						transparency = function()
							if order == data.selected() then
								return 0
							end

							return 1
						end,
						module5({
							ws = 1,
							h = 20,
							pad = {
								l = 4
							},
							size = 16,
							xalign = "left",
							color = function()
								if order == data.selected() then
									return (module6.select_color("text")())
								end

								return (module6.select_color("subtext1")())
							end,
							text = function()
								return callback().display
							end
						})
					})
				end)
			})
		end),
		show(function()
			local v = data.suggestions()[data.selected()]

			if v and v.metadata ~= nil then
				return v.metadata
			end

			return data.result().additional_info
		end, function()
			return module({
				w = 300,
				order = 10,
				auto = "y",
				flex = {
					align = "top",
					justify = "left"
				},
				anchor = { 0, 1 },
				transparency = 0,
				module3({
					w = 300,
					h = 24,
					flex = {
						direction = "row",
						justify = "between"
					},
					pad = {
						x = 4
					},
					module5({
						text = function()
							local v = data.suggestions()[data.selected()]
							local v2

							if v and v.metadata ~= nil then
								v2 = v.metadata
							else
								v2 = data.result().additional_info
							end

							return (v2 or {}).name or "not defined"
						end,
						size = 20,
						weight = 700
					}),
					module5({
						text = function()
							local v2 = data.suggestions()[data.selected()]
							local v3

							if v2 and v2.metadata ~= nil then
								v3 = v2.metadata
							else
								v3 = data.result().additional_info
							end

							return `{(v3 or {}).type}` or ""
						end,
						size = 18,
						weight = 400
					})
				}),
				module5({
					w = 300,
					pad = {
						p = 4
					},
					wraps = true,
					size = 16,
					xalign = "left",
					color = module6.text,
					text = function()
						local v = data.suggestions()[data.selected()]
						local v2

						if v and v.metadata ~= nil then
							v2 = v.metadata
						else
							v2 = data.result().additional_info
						end

						return (v2 or {}).description or "undefined"
					end
				})
			})
		end)
	})
end)