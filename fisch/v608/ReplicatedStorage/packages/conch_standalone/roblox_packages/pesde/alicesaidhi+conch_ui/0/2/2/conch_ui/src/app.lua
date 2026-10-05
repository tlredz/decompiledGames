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
return function()
	local function output(p)
		local v = string.split(p.text, "\n")

		for _, text in v do
			local logs = module9.logs()
			table.insert(logs, 1, {
				kind = p.kind,
				text = text
			})
			table.remove(logs, 1000)
			module9.logs(logs)
		end
	end

	module2.console.output = output

	for _, text in string.split([[
Conch 0.2.x
Copyright (c) alicesays_hallo - This project is licensed under MIT, you can view the included license with `license`
Press F2 to close this menu.]], "\n") do
		output({
			kind = "normal",
			text = text
		})
	end

	module2.register("clear", {
		description = "Clears the console.",
		permissions = {},
		arguments = function() end,
		callback = function()
			module9.logs({})
		end
	})
	local text2 = source("")
	local v2 = source(false)
	local cursorPosition = source(0)
	local v4 = source(Vector2.zero)
	local v5 = source()
	local v6 = {}
	local v7 = derive(function()
		if v5() then
			return v5().src .. text2()
		end

		return text2()
	end)
	local v8 = derive(function()
		local parsed = module2.parse(v7())

		if parsed.status == "error" then
			return parsed.why
		end

		return nil
	end)
	local v9 = source(module2.analyze("", 0))
	local selected = source(1)
	local v11 = source(1)
	effect(function()
		selected((math.clamp(selected(), 1, (math.max(1, #v9().suggestions)))))
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
			v9(module2.analyze(text2(), cursorPosition() - 1))
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
	local function autofill(value: string, replace: Vector3, with: string, not_final: boolean?)
		local v14 = string.sub(value, 1, replace.x)
		local v15 = string.sub(value, replace.y + 1, -1)
		task.defer(cursorPosition, replace.x + #with + 2)
		return v14 .. with .. (not_final and "" or " ") .. v15
	end

	cleanup(UserInputService.InputBegan:Connect(function(input)
		if not module9.opened() then
			return
		end

		local flag2 = false

		if input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.DPadDown then
			if v9().suggestions[1] then
				selected((math.min(selected() + 1, #v9().suggestions)))
			else
				v11((math.max(v11() - 1, 0)))
				flag2 = true
			end
		elseif input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.DPadUp then
			if v9().suggestions[1] then
				selected((math.max(1, selected() - 1)))
			else
				v11((math.min(v11() + 1, #v6)))
				flag2 = true
			end
		end

		if flag2 then
			local v14 = v6[v11()] or ""
			text2(v14)
			cursorPosition(#v14 + 1)
		end
	end))
	local v14 = source(Vector2.zero)
	local v15 = workspace.CurrentCamera.ViewportSize.Y - 150
	local v16 = false
	return module8({
		name = "Command Executor",
		display_order = 100000,
		enabled = module9.opened,
		module4():fill("horizontal"):vertical("bottom"),
		module7({
			padding = 12
		}),
		show(v9, function()
			return module14.create("Folder")({ module10({
					x = function()
						local v17 = string.split(v12(), "\n")
						return #v17[#v17] * 10 + 10
					end,
					y = function()
						return v13().Y + v4().Y - 20
					end,
					selected = selected,
					analyzing = function()
						return v9().analyzing
					end,
					suggestions = function()
						return v9().suggestions
					end
				}) })
		end),
		module({
			auto = "Y",
			scrolling = true,
			height = function()
				return (math.min(v14().Y, v15))
			end,
			module4(),
			module3(4),
			module7({
				y = 4
			}),
			indexes(function()
				local text = v8()
				local clone = table.clone(v9() and v9().logs or {})

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
					widthScaled = 1,
					order = -p - 1,
					text = function()
						return callback().text
					end,
					text_size = 16,
					text_style = function()
						return callback().kind
					end,
					xalignment = Enum.TextXAlignment.Left,
					wrapped = true,
					automaticSize = Enum.AutomaticSize.Y,
					module7({
						x = 8
					})
				})
			end),
			cpos = function(...)
				module9.logs()
				return Vector2.new(0, (math.max(v14().Y - v15, 0)))
			end,
			changed("AbsoluteCanvasSize", v14)
		}),
		module5({
			height = 4
		}),
		module({
			auto = Enum.AutomaticSize.Y,
			module3(4),
			show(v2, function()
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
						local v17 = v16 or cursorPosition()
						local v18 = string.sub(value, v17 - 1, v17 - 1)
						local suggestions = v9().suggestions

						if v18 == "\t" and suggestions[1] then
							value = autofill(
								text2(),
								suggestions[selected()].replace,
								suggestions[selected()].with,
								suggestions[selected()].not_final
							)
						end

						text2(value)
					end,
					placeholder = "Enter your command",
					text_size = 18,
					xalignment = Enum.TextXAlignment.Left,
					multiline = function()
						if v5() then
							return module2.parse(v5().src .. text2(), "yield").status == "pending"
						end

						return module2.parse(text2(), "yield").status == "pending"
					end,
					enter = function(p)
						if UserInputService.OnScreenKeyboardVisible or UserInputService.PreferredInput == Enum.PreferredInput.Touch then
							local suggestions = v9().suggestions

							if suggestions and suggestions[1] then
								text2(autofill(
									text2(),
									suggestions[selected()].replace,
									suggestions[selected()].with,
									suggestions[selected()].not_final
								))

								if p ~= text2() then
									task.defer(module9.focused, true)
									return
								end
							end
						end

						text2("")
						module9.focused(true)
						v11(0)

						if v6[1] ~= p then
							table.insert(v6, 1, p)

							if #v6 == 21 then
								v6[21] = nil
							end
						end

						if v5() then
							v5(v5().append(p))
						else
							v5(module2.parse(p, true))
						end

						if v5().status ~= "pending" then
							v2(true)
							v5(nil)
							module2.execute(p)
							v2(false)
						end
					end,
					focused = module9.focused,
					update_focused = module9.focused,
					{
						CursorPosition = cursorPosition,
						changed("CursorPosition", function(p)
							if v16 then
								v16 = p
								return
							end

							v16 = p
							task.defer(function()
								cursorPosition(v16)
								v16 = false
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
			changed("AbsolutePosition", v4)
		})
	})
end