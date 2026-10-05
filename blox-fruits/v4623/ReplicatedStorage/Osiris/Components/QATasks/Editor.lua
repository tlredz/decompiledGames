local Osiris = require(game.ReplicatedStorage.Packages.Osiris)
local QATask = require(game.ReplicatedStorage.Definitions.QATask)
local Loader = require(game.ReplicatedStorage.Osiris.Components.QATasks.Loader)
local Present = require(game.ReplicatedStorage.Osiris.Components.QATasks.Present)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Store)
require(game.ReplicatedStorage.Osiris.Components.QATasks.Types)
local STEP_TYPES = QATask.Types.STEP_TYPES
local EXPECTATION_TYPES = QATask.Types.EXPECTATION_TYPES
local TAGS = QATask.Types.TAGS
local v = {
	SetLevel = "tells the tester which level to be at; the suggested command is only a hint they can copy",
	Item = "tells the tester which item (by id) they need; the suggested command is only a hint they can copy",
	GoTo = "tells the tester where to be; the suggested command is only a hint they can copy",
	RunCommand = "tells the tester to run this admin command themselves",
	Custom = "free-form instruction for the tester, with an optional command they can copy"
}
local v2 = {
	Always = "documents behavior the tester should see every time",
	Never = "documents behavior the tester should never see",
	Sometimes = "documents behavior the tester should only see under the condition"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function drawPreview(text: string, color: Color3?)
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.Text({
			Arguments = {
				Text = "→",
				Color = Present.MUTED
			}
		})
		Osiris.Widget.Text({
			Arguments = {
				Text = text,
				Color = color,
				Wrapped = true
			}
		})
	end)
end

local function drawStepRow(k: number, step)
	local v3 = false
	Osiris.PushId((`step-row-{step.Id}`))
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.Text({
			Arguments = {
				Text = `step {k}: {step.Type}`
			}
		})

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "remove"
			}
		}).clicked() then
			v3 = true
		end
	end)
	Osiris.Widget.Indent({}, function()
		Osiris.Widget.ComboArray({
			Arguments = {
				Text = "type"
			},
			States = {
				index = Osiris.TableState(step, "Type")
			},
			Extra = {
				selectionArray = STEP_TYPES
			}
		})
		local state = Osiris.State(step.Type)

		if state:get() ~= step.Type then
			state:set(step.Type)
			step.AutoCommand = Loader.defaultCommand(step) ~= nil
			Loader.syncStepCommand(step)
		end

		Present.note(v[step.Type] or "")

		if step.Type == "SetLevel" then
			Osiris.Widget.InputNum({
				Arguments = {
					Text = "level the tester needs",
					Min = 1,
					Increment = 1,
					Format = "%d"
				},
				States = {
					number = Osiris.TableState(step, "Level")
				}
			})
		elseif step.Type == "Item" then
			Osiris.Widget.InputNum({
				Arguments = {
					Text = "item id the tester needs",
					Min = 0,
					Increment = 1,
					Format = "%d",
					NoButtons = true
				},
				States = {
					number = Osiris.TableState(step, "ItemId")
				}
			})
		elseif step.Type == "GoTo" then
			Osiris.Widget.InputText({
				Arguments = {
					Text = "location",
					TextHint = "where the tester should go, e.g. Marine Fortress"
				},
				States = {
					text = Osiris.TableState(step, "Text")
				}
			})
		elseif step.Type == "RunCommand" then
			Osiris.Widget.InputText({
				Arguments = {
					Text = "instruction",
					TextHint = "what the tester should do, e.g. spawn the boss"
				},
				States = {
					text = Osiris.TableState(step, "Text")
				}
			})
		else
			Osiris.Widget.InputText({
				Arguments = {
					Text = "instruction",
					TextHint = "what the tester should do"
				},
				States = {
					text = Osiris.TableState(step, "Text")
				}
			})
		end

		if Loader.defaultCommand(step) ~= nil then
			Osiris.Widget.Checkbox({
				Arguments = {
					Text = "suggest a command from the values above"
				},
				States = {
					isChecked = Osiris.TableState(step, "AutoCommand")
				}
			})
		end

		Loader.syncStepCommand(step)

		if step.AutoCommand then
			Present.command(step.Command, "suggested command")
		else
			Osiris.Widget.InputText({
				Arguments = {
					Text = "command",
					TextHint = step.Type == "RunCommand" and "required, the command the tester should run, e.g. /spawn Blizzard-Blizzard" or "optional command shown to the tester as a shortcut"
				},
				States = {
					text = Osiris.TableState(step, "Command")
				}
			})
		end

		local rowToStep, v4 = Loader.rowToStep(step)

		if rowToStep then
			drawPreview(Present.stepLabel(rowToStep), nil) -- equivalent call inferred; original call site unknown
		else
			drawPreview(v4 or "invalid step", Present.BAD) -- equivalent call inferred; original call site unknown
		end
	end)
	Osiris.PopId()
	return v3
end

local function drawExpectationRow(k: number, expectation)
	local v3 = false
	Osiris.PushId((`expectation-row-{expectation.Id}`))
	Osiris.Widget.SameLine({}, function()
		Osiris.Widget.Text({
			Arguments = {
				Text = `expectation {k}: {expectation.Type}`
			}
		})

		if Osiris.Widget.SmallButton({
			Arguments = {
				Text = "remove"
			}
		}).clicked() then
			v3 = true
		end
	end)
	Osiris.Widget.Indent({}, function()
		Osiris.Widget.ComboArray({
			Arguments = {
				Text = "type"
			},
			States = {
				index = Osiris.TableState(expectation, "Type")
			},
			Extra = {
				selectionArray = EXPECTATION_TYPES
			}
		})
		Present.note(v2[expectation.Type] or "")

		if expectation.Type == "Sometimes" then
			Osiris.Widget.InputText({
				Arguments = {
					Text = "condition",
					TextHint = "when does this apply, e.g. the player is in water"
				},
				States = {
					text = Osiris.TableState(expectation, "Condition")
				}
			})
		end

		Osiris.Widget.InputText({
			Arguments = {
				Text = "behavior",
				TextHint = expectation.Type == "Never" and "what must never happen, e.g. the fruit deals damage to allies" or expectation.Type == "Sometimes" and "what happens under the condition" or "what should always happen, e.g. the move goes on cooldown"
			},
			States = {
				text = Osiris.TableState(expectation, "Behavior")
			}
		})
		local rowToExpectation, v4 = Loader.rowToExpectation(expectation)

		if rowToExpectation then
			drawPreview(Present.expectationLabel(rowToExpectation), Present.expectationColor(rowToExpectation)) -- equivalent call inferred; original call site unknown
		else
			drawPreview(v4 or "invalid expectation", Present.BAD) -- equivalent call inferred; original call site unknown
		end
	end)
	Osiris.PopId()
	return v3
end

local function drawTags(p)
	Osiris.Widget.Tree({
		Arguments = {
			Text = "Tags"
		}
	}, function()
		for _, text in TAGS do
			Osiris.PushId((`tag-{text}`))
			local state = Osiris.State(p.Tags[text] == true)
			local checkbox = Osiris.Widget.Checkbox({
				Arguments = {
					Text = text
				},
				States = {
					isChecked = state
				}
			})

			if checkbox.checked() then
				p.Tags[text] = true
			elseif checkbox.unchecked() then
				p.Tags[text] = nil
			elseif state:get() ~= (p.Tags[text] == true) then
				state:set(p.Tags[text] == true)
			end

			Osiris.PopId()
		end
	end)
end

return function(p)
	local store = p.Store
	local driver = p.Driver
	local v3 = store.editor:get()

	if v3 == nil or v3.Mode == "None" then
		return
	end

	Osiris.PushId((`editor-{v3.Session}`))
	Present.stat("parent", v3.Parent or "(top level)")

	if v3.Mode == "Edit" then
		Present.stat("path", v3.Path or "")
		Osiris.Widget.InputText({
			Arguments = {
				Text = "key",
				ReadOnly = true
			},
			States = {
				text = Osiris.TableState(v3, "Key")
			}
		})
	else
		Osiris.Widget.InputText({
			Arguments = {
				Text = "key",
				TextHint = "optional, made from the title if empty"
			},
			States = {
				text = Osiris.TableState(v3, "Key")
			}
		})
	end

	Osiris.Widget.InputText({
		Arguments = {
			Text = "title"
		},
		States = {
			text = Osiris.TableState(v3, "Title")
		}
	})
	Osiris.Widget.InputText({
		Arguments = {
			Text = "description",
			MultiLine = true,
			TextHint = "what to check"
		},
		States = {
			text = Osiris.TableState(v3, "Description")
		}
	})
	Osiris.Widget.Checkbox({
		Arguments = {
			Text = "share across branches (global)"
		},
		States = {
			isChecked = Osiris.TableState(v3, "IsGlobal")
		}
	})
	Present.note(v3.IsGlobal and "the task definition is saved once and shows up on every branch" or "the task definition is saved for this branch only")
	drawTags(v3)
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Steps"
		}
	})
	local v4 = nil

	for k, step in v3.Steps do
		if drawStepRow(k, step) then
			v4 = k
		end
	end

	if v4 then
		table.remove(v3.Steps, v4)
	end

	if #v3.Steps == 0 then
		Present.note("no steps yet, add one below")
	end

	Osiris.Widget.Text({
		Arguments = {
			Text = "add step:",
			Color = Present.MUTED
		}
	})
	Osiris.Widget.SameLine({}, function()
		for _, v5 in STEP_TYPES do
			Osiris.PushId((`add-step-{v5}`))

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = `+ {v5}`
				}
			}).clicked() then
				Loader.addStepRow(v3, v5)
			end

			Osiris.PopId()
		end
	end)
	Osiris.Widget.SeparatorText({
		Arguments = {
			Text = "Expectations"
		}
	})
	local v5 = nil

	for k, expectation in v3.Expectations do
		if drawExpectationRow(k, expectation) then
			v5 = k
		end
	end

	if v5 then
		table.remove(v3.Expectations, v5)
	end

	if #v3.Expectations == 0 then
		Present.note("no expectations yet, add one below")
	end

	Osiris.Widget.Text({
		Arguments = {
			Text = "add expectation:",
			Color = Present.MUTED
		}
	})
	Osiris.Widget.SameLine({}, function()
		for _, v6 in EXPECTATION_TYPES do
			Osiris.PushId((`add-expectation-{v6}`))

			if Osiris.Widget.SmallButton({
				Arguments = {
					Text = `+ {v6}`
				}
			}).clicked() then
				Loader.addExpectationRow(v3, v6)
			end

			Osiris.PopId()
		end
	end)
	Osiris.Widget.Separator({})
	local error = v3.Error

	if error ~= nil then
		Present.error(error)
	end

	Osiris.Widget.SameLine({}, function()
		local text = v3.IsSubmitting and "saving..." or v3.Mode == "Edit" and "save" or "create"

		if Osiris.Widget.Button({
			Arguments = {
				Text = text
			}
		}).clicked() and not v3.IsSubmitting then
			Loader.submitEditor(store, driver)
		end

		if Osiris.Widget.Button({
			Arguments = {
				Text = "cancel"
			}
		}).clicked() then
			Loader.closeEditor(store)
		end
	end)
	Osiris.PopId()
end