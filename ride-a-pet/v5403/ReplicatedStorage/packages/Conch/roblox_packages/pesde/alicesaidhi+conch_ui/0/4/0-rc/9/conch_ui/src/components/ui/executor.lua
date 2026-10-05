local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local module = require("./background")
local module2 = require("../../util/component")
local module3 = require("../../../roblox_packages/conch")
local module4 = require("../../util/interval")
require("../../../roblox_packages/language")
local module5 = require("../../util/loading")
local module6 = require("../../runtime_plugin_api")
local module7 = require("../core/screen")
local module8 = require("../../state")
local module9 = require("./suggestion")
local module10 = require("../core/text")
local module11 = require("../core/textbox")
local module12 = require("../../theme")
local module13 = require("../../../roblox_packages/vide")
local changed = module13.changed
local derive = module13.derive
local source = module13.source
local show = module13.show
local effect = module13.effect
local cleanup = module13.cleanup
local v = 0
return module2(function(data)
	local show_suggestions_from = source(0)
	local v3 = source(Vector2.zero)
	local text2 = source("")
	local selected = source(1)
	effect(function()
		data.update_text(text2())
	end)
	local cursorPosition = source(0)
	local v7 = false
	effect(function()
		selected((math.clamp(selected(), 1, (math.max(1, #data.filtered_suggestions())))))
	end)
	local v8 = derive(function()
		return (string.sub(text2(), 1, cursorPosition() - 1))
	end)
	local v9 = source(Vector2.zero)
	effect(function()
		data.update_cursor(cursorPosition())
	end)
	effect(function()
		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Font = module12.font()
		getTextBoundsParams.RichText = false
		getTextBoundsParams.Size = 19
		getTextBoundsParams.Width = 100000
		local v10 = v8()
		local count = 0
		local v11 = 1

		for k in string.gmatch(v10, "\n()") do
			count += 1
			v11 = k
		end

		getTextBoundsParams.Text = string.rep("\n", count) .. string.sub(v10, v11)
		task.spawn(function()
			local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)

			if v10 ~= v8() then
				return
			end

			v9(textBoundsAsync)
		end)
	end)
	effect(function()
		local v10 = selected()
		local v11 = show_suggestions_from()
		local v12 = show_suggestions_from() + 10 - 1

		if v12 < v10 then
			local v13 = v10 - v12
			show_suggestions_from(show_suggestions_from() + v13)
		elseif v10 < v11 then
			local v13 = v10 - v11
			show_suggestions_from(show_suggestions_from() + v13)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function autofill(value: string, replace: Vector3, text: string)
		local v10 = string.sub(value, 1, replace.x)
		local v11 = string.sub(value, replace.y + 1, -1)
		task.defer(cursorPosition, replace.x + #text + 2)
		return v10 .. text .. " " .. v11
	end

	local function move_down()
		local history = module8.history

		if #data.analysis().suggestions ~= 0 or text2():find("\n") ~= nil then
			selected((math.min(selected() + 1, #data.filtered_suggestions())))
			return
		end

		if v == 0 then
			history[v] = text2()
		end

		v = math.clamp(v - 1, 0, #history)
		text2(history[v] or "")
		cursorPosition(#text2() + 1)
	end

	local function move_up()
		local history = module8.history

		if #data.analysis().suggestions ~= 0 or text2():find("\n") ~= nil then
			selected((math.max(1, selected() - 1)))
			return
		end

		if v == 0 then
			history[v] = text2()
		end

		v = math.clamp(v + 1, 0, #history)
		text2(history[v] or "")
		cursorPosition(#text2() + 1)
	end

	local v10 = {
		up = false,
		down = false
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function start_auto_scroll(p: string)
		task.spawn(function()
			local v11 = os.clock() + 0.4

			while v10[p] do
				local now = os.clock()

				if now < v11 then
					task.wait()
				else
					if p == "up" then
						move_up()
					else
						move_down()
					end

					v11 = now + 0.05
				end
			end
		end)
	end

	cleanup(UserInputService.InputBegan:Connect(function(input)
		if not module8.opened() then
			return
		end

		if input.KeyCode == Enum.KeyCode.Down then
			move_down()
			v10.down = true
			start_auto_scroll("down") -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.Up then
			move_up()
			v10.up = true
			start_auto_scroll("up") -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.C and input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
			module3.cancel()
		elseif input.KeyCode == Enum.KeyCode.Return then
			module8.focused(true)
		end
	end))
	cleanup(UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Down then
			v10.down = false
		elseif input.KeyCode == Enum.KeyCode.Up then
			v10.up = false
		end
	end))
	cleanup(UserInputService.InputChanged:Connect(function(input)
		if not module8.opened() then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if input.Position.Z > 0 then
				move_up()
			else
				move_down()
			end
		end
	end))
	local v11 = source(nil)
	return module({
		name = "Executor",
		ws = 1,
		h = 20,
		auto = "y",
		corner = 4,
		pad = {
			p = 8
		},
		flex = {
			justify = "left"
		},
		changed("AbsolutePosition", v3),
		module13.action(v11),
		show(data.analysis, function()
			return module7({
				name = "Suggestion",
				display_order = 1000000000,
				module9({
					x = function()
						local v12 = string.split(v8(), "\n")
						return #v12[#v12] * 9 + 32
					end,
					y = function()
						local v12 = v11()

						if v12 == nil then
							return 0
						end

						return v9().Y + v12.AbsolutePosition.Y
					end,
					selected = selected,
					show_suggestions_from = show_suggestions_from,
					suggestions = data.filtered_suggestions,
					result = data.analysis
				})
			})
		end),
		show(data.working, function()
			local total = 0
			local v12 = module4(0, function(p: number)
				total += p
				return total
			end)
			return module10({
				h = 20,
				size = 18,
				text = function()
					return (`{module5()} - {string.format("%0.3f", v12())}s - Ctrl-C to cancel`)
				end
			})
		end, function()
			return module11({
				ws = 1,
				auto = "y",
				h = 20,
				text = text2,
				update_text = function(value: string)
					local v12 = v7 or cursorPosition()
					local v13 = string.sub(value, v12 - 1, v12 - 1)
					local v14 = data.filtered_suggestions()[selected()]

					if v13 == "\t" and v14 then
						value = autofill(text2(), data.analysis().replace, v14.text)
					end

					text2(value)
				end,
				placeholder = "Enter your command",
				size = 18,
				xalign = "left",
				multiline = module4(0, function()
					return #data.analysis().issues > 0 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				end),
				enter = function(p)
					v = 0
					module6.add(p)
					data.execute(p)
					module8.focused(true)
					text2("")
					task.delay(0, text2, "")
				end,
				focused = module8.focused,
				update_focused = module8.focused,
				changed("Text", data.update_text),
				{
					CursorPosition = cursorPosition,
					changed("CursorPosition", function(p)
						if v7 then
							v7 = p
							return
						end

						v7 = p
						task.defer(function()
							if v7 == false then
								return
							end

							cursorPosition(v7)
							v7 = false
						end)
					end)
				}
			})
		end)
	})
end)