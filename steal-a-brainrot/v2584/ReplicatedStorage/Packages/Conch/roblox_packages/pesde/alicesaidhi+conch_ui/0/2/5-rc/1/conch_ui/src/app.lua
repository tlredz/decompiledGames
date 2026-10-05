local createVector = vector.create
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")
local module = require("./components/background")
local module2 = require("../roblox_packages/conch")
local module3 = require("./components/corner")
local module4 = require("./components/flex")
local module5 = require("./components/gap")
local module6 = require("./components/loading")
local module7 = require("./components/padding")
local module8 = require("./components/screen")
local module9 = require("./state")
local module10 = require("./components/suggestion")
local module11 = require("./components/text")
local module12 = require("./components/textbox")
local module13 = require("./theme")
local module14 = require("../roblox_packages/vide")
local source = module14.source
local derive = module14.derive
local show = module14.show
local changed = module14.changed
local effect = module14.effect
local cleanup = module14.cleanup
local indexes = module14.indexes
local v = 0
local v2 = {}
return function()
	local function output(p)
		local v3 = string.split(p.text, "\n")

		for _, text in v3 do
			local logs = module9.logs()
			table.insert(logs, 1, {
				kind = p.kind,
				text = text
			})
			table.remove(logs, 100)
			module9.logs(logs)
		end
	end

	module2.console.output = output

	for _, text in string.split([[
Conch 0.2.x
Copyright (c) alicesays_hallo - This project is licensed under MIT, you can view the included license with `license`]], "\n") do
		output({
			kind = "normal",
			text = text
		})
	end

	output({
		kind = "warn",
		text = "If you got here accidentally, run the `close-ui` command to close this UI."
	})
	module2.register("clear", {
		description = "Clears the console.",
		permissions = {},
		arguments = function() end,
		callback = function()
			module9.logs({})
		end
	})
	module2.register("close-ui", {
		description = "Close the CLI",
		permissions = {},
		arguments = function() end,
		callback = function()
			module9.opened(false)
			module9.focused(false)
		end
	})
	local text2 = source("")
	local v4 = source(false)
	local cursorPosition = source(0)
	local v6 = source(Vector2.zero)
	local v7 = source()
	local v8 = derive(function()
		debug.profilebegin("this")

		if v7() then
			debug.profileend()
			return v7().src .. text2()
		end

		debug.profileend()
		return text2()
	end)
	local v9 = derive(function()
		local parsed = module2.parse(v8())

		if parsed.status == "error" then
			return parsed.why
		end

		return nil
	end)
	local v10 = source(module2.analyze("", 0))
	local selected = source(1)
	effect(function()
		selected((math.clamp(selected(), 1, (math.max(1, #v10().suggestions)))))
	end)
	local flag = false
	effect(function()
		text2()
		cursorPosition()

		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false
			v10(module2.analyze(text2(), cursorPosition() - 1))
		end)
	end)
	local v12 = derive(function()
		return (string.sub(text2(), 1, cursorPosition() - 1))
	end)
	local v13 = source(createVector(0, 0, 0))
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = module13.font()
	getTextBoundsParams.RichText = false
	getTextBoundsParams.Size = 20
	getTextBoundsParams.Width = 100000
	effect(function()
		local text = v12()
		getTextBoundsParams.Text = text
		task.spawn(function()
			local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)

			if text ~= v12() then
				return
			end

			v13(textBoundsAsync)
		end)
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function autofill(value: string, replace: Vector3, with: string)
		local v14 = string.sub(value, 1, replace.x)
		local v15 = string.sub(value, replace.y + 1, -1)
		task.defer(cursorPosition, replace.x + #with + 2)
		return v14 .. with .. " " .. v15
	end

	cleanup(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Down then
			if #v10().suggestions ~= 0 then
				selected((math.min(selected() + 1, #v10().suggestions)))
				return
			end

			if v == 0 then
				v2[v] = text2()
			end

			v = math.clamp(v - 1, 0, #v2)
			text2(v2[v] or "")
			cursorPosition(#text2() + 1)
		elseif input.KeyCode == Enum.KeyCode.Up then
			if #v10().suggestions == 0 then
				if v == 0 then
					v2[v] = text2()
				end

				v = math.clamp(v + 1, 0, #v2)
				text2(v2[v] or "")
				cursorPosition(#text2() + 1)
			else
				selected((math.max(1, selected() - 1)))
			end
		end
	end))
	local v14 = false
	return module8({
		name = "Command Executor",
		display_order = 100000,
		enabled = module9.opened,
		module4():fill("horizontal"):vertical("bottom"),
		module7({
			padding = 12
		}),
		show(v10, function()
			return module14.create("Folder")({ module10({
					x = function()
						local v15 = string.split(v12(), "\n")
						return #v15[#v15] * 10 + 10
					end,
					y = function()
						return v13().Y + v6().Y - 20
					end,
					selected = selected,
					analyzing = function()
						return v10().analyzing
					end,
					suggestions = function()
						return v10().suggestions
					end
				}) })
		end),
		module({
			auto = "Y",
			module4(),
			module3(4),
			module7({
				y = 4
			}),
			indexes(function()
				local text = v9()
				local clone = table.clone(v10() and v10().logs or {})

				if text then
					table.insert(clone, {
						kind = "error",
						text = text
					})
				end

				return clone
			end, function(callback, p)
				return module11({
					order = 0 - p + 100,
					height = 20,
					text = function()
						return callback().text
					end,
					text_size = 16,
					text_style = function()
						return callback().kind
					end,
					xalignment = Enum.TextXAlignment.Left,
					module7({
						x = 8
					})
				})
			end),
			indexes(module9.logs, function(callback, p: number)
				return module11({
					height = 20,
					order = -p - 1,
					text = function()
						return callback().text
					end,
					text_size = 16,
					text_style = function()
						return callback().kind
					end,
					xalignment = Enum.TextXAlignment.Left,
					module7({
						x = 8
					})
				})
			end)
		}),
		module5({
			height = 4
		}),
		module({
			auto = Enum.AutomaticSize.Y,
			module3(4),
			show(v4, function()
				return module6({
					height = 18,
					speed = 6,
					text_size = 18,
					xalignment = Enum.TextXAlignment.Left
				})
			end, function()
				return module12({
					text = text2,
					update_text = function(value: string)
						local v15 = v14 or cursorPosition()
						local v16 = string.sub(value, v15 - 1, v15 - 1)
						local suggestions = v10().suggestions

						if v16 == "\t" and suggestions[1] then
							value = autofill(text2(), suggestions[selected()].replace, suggestions[selected()].with)
						end

						text2(value)
					end,
					placeholder = "Enter your command",
					text_size = 18,
					xalignment = Enum.TextXAlignment.Left,
					multiline = function()
						if v7() then
							return module2.parse(v7().src .. text2(), "yield").status == "pending"
						end

						return module2.parse(text2(), "yield").status == "pending"
					end,
					enter = function(p)
						v = 0
						table.insert(v2, 1, p)
						text2("")
						module9.focused(true)

						if v7() then
							v7(v7().append(p))
						else
							v7(module2.parse(p, true))
						end

						if v7().status ~= "pending" then
							v4(true)
							v7(nil)
							module2.execute(p)
							v4(false)
						end
					end,
					focused = module9.focused,
					update_focused = module9.focused,
					{
						CursorPosition = cursorPosition,
						changed("CursorPosition", function(p)
							if v14 then
								v14 = p
								return
							end

							v14 = p
							task.defer(function()
								cursorPosition(v14)
								v14 = false
							end)
						end)
					}
				})
			end),
			module7({
				x = 8,
				y = 8
			}),
			module4():fill():vertical("center"):horizontal("left"),
			changed("AbsolutePosition", v6)
		})
	})
end