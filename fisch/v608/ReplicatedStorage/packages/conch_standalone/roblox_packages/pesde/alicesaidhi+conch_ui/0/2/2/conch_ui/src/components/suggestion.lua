local module = require("./background")
local module2 = require("./container")
local module3 = require("./flex")
local module4 = require("./padding")
local module5 = require("./text")
local module6 = require("../../roblox_packages/vide")
local show = module6.show
local indexes = module6.indexes
local source = module6.source
local effect = module6.effect
return function(data)
	local v = source(data.selected())
	effect(function()
		local selected = data.selected()
		local v2 = v()
		local v3 = v() + 10 - 1

		if v3 < selected then
			local v4 = selected - v3
			v(v() + v4)
		elseif selected < v2 then
			local v4 = selected - v2
			v(v() + v4)
		end
	end)
	return module2({
		x = data.x,
		y = data.y,
		width = 300,
		auto = "Y",
		anchor = { 0, 1 },
		zindex = 10000,
		module3():column():gap(4):vertical("bottom"),
		show(data.analyzing, function()
			return module({
				width = 300,
				layout = 10,
				auto = Enum.AutomaticSize.Y,
				{
					BackgroundTransparency = 0
				},
				module3(),
				module({
					height = 24,
					width = 300,
					module3():column():between("horizontal"):vertical("center"),
					module4({
						x = 4
					}),
					module5({
						text = function()
							if (data.analyzing() or {
								kind = "",
								name = "",
								description = ""
							}).kind == "variadic" then
								return "..."
							end

							return (data.analyzing() or {
								kind = "",
								name = "",
								description = ""
							}).name or ""
						end,
						text_size = 20,
						weight = Enum.FontWeight.Bold
					}),
					module5({
						text = function()
							return (data.analyzing() or {
								kind = "",
								name = "",
								description = ""
							}).type or ""
						end,
						text_size = 18,
						weight = Enum.FontWeight.Light
					})
				}),
				module5({
					module4({
						padding = 4
					}),
					width = 300,
					wrapped = true,
					text_size = 16,
					xalignment = Enum.TextXAlignment.Left,
					text = function()
						return (data.analyzing() or {
							kind = "",
							name = "",
							description = ""
						}).description or ""
					end
				})
			})
		end),
		show(function()
			return data.suggestions()[1] ~= nil
		end, function()
			return module({
				ys = 1,
				width = 200,
				height = 0,
				anchor = { 0, 1 },
				auto = Enum.AutomaticSize.Y,
				{
					BackgroundTransparency = 0
				},
				module3():vertical("bottom"),
				indexes(function()
					local suggestions = data.suggestions()
					table.sort(suggestions, function(a, b)
						return a.name < b.name
					end)
					local result = {}

					for i = v(), v() + 10 - 1 do
						result[i - v() + 1] = suggestions[i]
					end

					return result
				end, function(callback, order)
					return module5({
						width = 200,
						height = 20,
						order = order,
						text_size = 16,
						xalignment = Enum.TextXAlignment.Left,
						text = function()
							return callback().name
						end,
						text_style = function()
							if order == data.selected() - v() + 1 then
								return "info"
							end

							return "normal"
						end,
						module4({
							left = 4
						})
					})
				end)
			})
		end)
	})
end