local UserInputService = game:GetService("UserInputService")
local module = require("./background")
local module2 = require("../../util/component")
local module3 = require("../core/container")
local module4 = require("../../util/interval")
local module5 = require("../../state")
local module6 = require("../core/text")
local module7 = require("../core/textbox")
local module8 = require("../../theme")
local module9 = require("../../../roblox_packages/vide")
local source = module9.source
local effect = module9.effect
local indexes = module9.indexes
local changed = module9.changed
return module2(function(p)
	local v = source(0)
	local v2 = source(0)
	local v3 = source(0)
	local text = source("")
	local v5 = source(0)
	local v6 = source(0)
	effect(function()
		local current_stream = module5.current_stream()
		v((math.clamp(
			v(),
			current_stream.visible_lines,
			(math.max(current_stream.visible_lines + 1, #current_stream.richtext_lines))
		)))
	end)
	module4(0, function(_)
		if not module5.opened() then
			return nil
		end

		local current_stream = module5.current_stream()
		current_stream.max_line_length = workspace.CurrentCamera.ViewportSize.X // 9
		current_stream.visible_lines = (workspace.CurrentCamera.ViewportSize.Y * 0.8 / 16 - 2) // 1
		v3(current_stream.visible_lines)
		v5(current_stream.visible_lines)
		v6((math.max(current_stream.visible_lines + 1, #current_stream.richtext_lines)))

		if v() >= v2() then
			v(#current_stream.richtext_lines)
		end

		v2(#current_stream.richtext_lines)
		text(current_stream:getformatted(v()))
		return nil
	end)

	local function fn()
		return math.map(v(), v5(), v6(), 0, 1)
	end

	local v7 = source(false)
	local v8 = source(Vector2.zero)
	local v9 = source(Vector2.zero)
	local mouseLocation = nil
	module4(0, function()
		if not v7() then
			return nil
		end

		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			v7(false)
			return nil
		end

		local mouseLocation2 = UserInputService:GetMouseLocation()

		if mouseLocation == nil then
			local v10 = (mouseLocation2.Y - v8().Y) / v9().Y
			v(math.map(v10, 0, 1, v5(), v6()) // 1)
			mouseLocation = mouseLocation2
		else
			local v10 = (1 - v2() / v3()) / v2()
			local v11 = (mouseLocation - mouseLocation2).Y / v9().Y
			local v12 = math.sign(v11)
			local v13 = math.ceil(math.abs(v11) / v10)
			v(v() + v13 * v12)

			if v13 ~= 0 then
				mouseLocation = mouseLocation2
			end
		end

		return nil
	end)
	return module({
		name = "Output",
		ws = 1,
		auto = "y",
		pad = {
			p = 4
		},
		corner = 4,
		flex = {
			justify = "left"
		},
		module3({
			name = "Output",
			ws = 1,
			auto = "y",
			flex = {
				direction = "row",
				align = "bottom"
			},
			sink = true,
			enabled = true,
			wheel = function(p2: number)
				v(v() + p2 * 3)
			end,
			module7({
				name = "OutputText",
				grow = 1,
				shrink = 1,
				auto = "y",
				xalign = "left",
				size = 16,
				weight = 500,
				transparency = module8.background_transparency,
				color = module8.background,
				text = function()
					return (text():gsub("<(.-)>", ""):gsub("&gt;", ">"):gsub("&lt;", "<"):gsub("&quot;", "\""):gsub(
						"&apos;",
						"'"
					):gsub(
						"&amp;",
						"&"
					))
				end,
				editable = false,
				module6({
					name = "OutputText",
					ws = 1,
					auto = "y",
					xalign = "left",
					size = 16,
					weight = 500,
					rich = true,
					text = text
				})
			}),
			module3({
				name = "Scrollbar",
				w = 8,
				h = function()
					return v3() * 16
				end,
				visible = function()
					return v2() > v3()
				end,
				hold = function(p2)
					if p2 then
						v7(true)
					end
				end,
				changed("AbsolutePosition", v8),
				changed("AbsoluteSize", v9),
				module3({
					name = "Scrollbar",
					w = 8,
					ys = fn,
					anchor = function()
						return { 0, fn() }
					end,
					hs = function()
						return v3() / v2()
					end,
					color = module8.background,
					hold = function(p2)
						if p2 then
							v7(true)
							mouseLocation = UserInputService:GetMouseLocation()
						end
					end,
					module9.create("UISizeConstraint")({
						MinSize = Vector2.new(0, 16)
					})
				})
			})
		}),
		module3({
			name = "Problems",
			ws = 1,
			auto = "y",
			flex = {
				justify = "left"
			},
			indexes(p.errors, function(text2)
				return module6({
					ws = 1,
					auto = "y",
					xalign = "left",
					wraps = true,
					text = text2,
					size = 16,
					color = module8.text_error
				})
			end)
		})
	})
end)