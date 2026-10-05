local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local dialog = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("dialog")
local debris = require(ReplicatedStorage2.shared.modules:WaitForChild("fx"):WaitForChild("debris"))
local fx = require(ReplicatedStorage2.shared.modules:WaitForChild("fx"))
local voices = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("voices")
local ui = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui")
local character = require(ReplicatedStorage2.shared.modules:WaitForChild("character"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local GamepadService = game:GetService("GamepadService")
local packages = ReplicatedStorage2:WaitForChild("packages")
local input = packages:WaitForChild("Input")
local Trove = require(packages.Trove)
local module = require(input)
local preferredInput = module.PreferredInput
local Debounce = require(packages.Debounce)
local Net = require(ReplicatedStorage.packages.Net)
local SettingsController = require(ReplicatedStorage2.client.legacyControllers.SettingsController)
local WindowController = require(ReplicatedStorage2.client.legacyControllers.WindowController)
local DynamicString = require(ReplicatedStorage.shared.modules.DynamicString)
local ProximityPromptService = game:GetService("ProximityPromptService")
local remoteFunction = Net:RemoteFunction("DialogInteract", -1)
local modulesByName = {}

for _, moduleScript in script:GetChildren() do
	local name = moduleScript.Name
	local module2 = require(moduleScript)
	modulesByName[name] = module2
end

local v = nil
local v2 = nil
local v3 = nil
local v4 = false
local v5 = false
local v6 = false
local maid = Trove.new()
local v7 = { "Moosewood", "Moosewood Village" }

local function isZoneAllowed(p, _)
	local v8 = tostring(p)

	for _, v9 in ipairs(v7) do
		if v9 == v8 then
			return true
		end
	end

	return false
end

local v8 = false
game.UserInputService.InputBegan:Connect(function(input2, gameProcessed)
	if (input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.KeyCode == Enum.KeyCode.ButtonX or input2.UserInputType == Enum.UserInputType.Touch) and not gameProcessed and v5 == true then
		v6 = true
	end
end)

local function recvDialogEvent(p, parent, state, startline: number?, flag: boolean)
	if parent == nil then
		return
	end

	if not state.locked or state.locked == nil then
		state.locked = false
	end

	if v4 == true and state.locked == true or character:Can(localPlayer) == false and not flag and localPlayer:GetAttribute("hasGhost") ~= true then
		return
	end

	local v9 = {}

	for _, v10 in state.dialog do
		if v10.cs_await then
			v9[v10.cs_await] = v10
		end
	end

	local runBehaviourFunction = state.runBehaviourFunction
	local initial_data = state.initial_data

	if state.locked == true then
		ProximityPromptService.Enabled = false
		v = parent
		v2 = state
		local character2 = localPlayer.Character

		if character2:FindFirstChild("dialoglink") then
			character2:FindFirstChild("dialoglink"):Destroy()
		end

		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "dialoglink"
		objectValue.Value = p.npc
		objectValue.Parent = character2
		v3 = objectValue

		if p.npc:FindFirstChild("dialogprompt") then
			local dialogprompt = p.npc:FindFirstChild("dialogprompt")
			dialogprompt.Enabled = false
		end

		local _ = character2.zone.Value
		local v10 = character.PS(localPlayer)

		if not v10 then
			repeat
				task.wait()
				v10 = character.PS(localPlayer)
			until v10 or not (localPlayer or localPlayer.Parent)
		end

		local _ = v10:FindFirstChild("Stats"):FindFirstChild("tracker_timesjoined").Value
		local useNewDialogueUI = localPlayer:GetAttribute("UseNewDialogueUI") or false
		v8 = useNewDialogueUI

		function EndDialog(p2)
			ProximityPromptService.Enabled = true
			maid:Clean()

			if p2 ~= "New Dialog" then
				objectValue:Destroy()
				v = nil
				v2 = nil
				v4 = false
				v3 = nil

				if localPlayer.PlayerGui:FindFirstChild("options") then
					localPlayer.PlayerGui:FindFirstChild("options"):Destroy()
				end

				if localPlayer.PlayerGui.hud.safezone:FindFirstChild("options") then
					localPlayer.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
				end
			end

			if p.npc:FindFirstChild("dialogprompt") then
				local dialogprompt = p.npc:FindFirstChild("dialogprompt")
				dialogprompt.Enabled = true
			end

			if p2 == "No More Dialog Responses" then
				if parent:FindFirstChild("dialogline") then
					debris:AddItem(parent:FindFirstChild("dialogline"), 10)
					local TweenService = game:GetService("TweenService")
					TweenService:Create(
						parent:FindFirstChild("dialogline").title,
						TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 5),
						{
							TextTransparency = 1,
							TextStrokeTransparency = 1
						}
					):Play()
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						parent:FindFirstChild("dialogline").bg,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 8),
						{
							ImageTransparency = 1
						}
					):Play()
				end

				if localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline") then
					task.wait(1)
					localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline"):Destroy()
				end
			elseif p2 == "Walked Away" or p2 == "New Dialog" then
				if parent:FindFirstChild("dialogline") then
					parent:FindFirstChild("dialogline"):Destroy()
				end

				if localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline") then
					localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline"):Destroy()
				end

				local leavemessage = state.leavemessages[math.random(1, #state.leavemessages)]
				local clone = useNewDialogueUI and dialog.linenew:Clone() or dialog.line:Clone()
				clone.Name = "dialogline"
				clone.title.Text = leavemessage
				clone.title.MaxVisibleGraphemes = 0
				clone.Parent = parent

				if state.disableBillboard then
					state.disableBillboard.Enabled = false
				end

				if p.npc:FindFirstChild("dialogprompt") then
					local dialogprompt_2 = p.npc:FindFirstChild("dialogprompt")
					dialogprompt_2.Enabled = true
				end

				if not useNewDialogueUI then
					local TweenService = game:GetService("TweenService")
					TweenService:Create(
						clone.title,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
						{
							MaxVisibleGraphemes = #leavemessage
						}
					):Play()
					debris:AddItem(clone, 10)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						clone.title,
						TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 5),
						{
							TextTransparency = 1,
							TextStrokeTransparency = 1
						}
					):Play()
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(
						clone.bg,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 8),
						{
							ImageTransparency = 1
						}
					):Play()
				end

				local v11 = false
				local value = p.npc and p.npc:FindFirstChild("description") and p.npc.description:FindFirstChild("voice") and p.npc.description.voice.Value or p.voice
				clone.title:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
					if v11 == false and clone.title.MaxVisibleGraphemes <= #leavemessage then
						v11 = true
						local children = voices:FindFirstChild(value):GetChildren()
						fx:PlaySound(children[math.random(1, #children)], parent, true)
						task.wait(0.04)
						v11 = false
					end
				end)
			end

			v4 = false

			if not WindowController.CurrentWindow then
				local TweenService = game:GetService("TweenService")
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
					{
						FieldOfView = 70
					}
				):Play()

				if tostring(preferredInput.Current) == "Gamepad" then
					GamepadService:DisableGamepadCursor()
				end
			end
		end

		local track = nil
		local CreateDialogLine

		CreateDialogLine = function(state2)
			maid:Clean()

			if parent:FindFirstChild("dialogline") then
				parent:FindFirstChild("dialogline"):Destroy()
			end

			if localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline") then
				localPlayer.PlayerGui.hud.safezone:FindFirstChild("dialogline"):Destroy()
			end

			if localPlayer.PlayerGui:FindFirstChild("options") then
				localPlayer.PlayerGui:FindFirstChild("options"):Destroy()
			end

			if localPlayer.PlayerGui.hud.safezone:FindFirstChild("options") then
				localPlayer.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
			end

			v4 = true
			v5 = false
			v6 = false

			if not state2 then
				return
			end

			if track then
				track:Stop()
				track = nil
			end

			if state2.animation and p.npc:FindFirstChild("Humanoid") and p.npc:FindFirstChild("dialogAnimations") and p.npc:FindFirstChild("dialogAnimations"):FindFirstChild(state2.animation) then
				track = p.npc.Humanoid:LoadAnimation(p.npc:FindFirstChild("dialogAnimations"):FindFirstChild(state2.animation))
				track:Play()
			end

			if state2.sound then
				local child = ui:FindFirstChild(state2.sound)

				if child then
					fx:PlaySound(child, parent, false)
				else
					warn((`Unknown sound "{state2.sound}"`))
				end
			end

			if state2.choices == nil then
				state2.choices = {}
			end

			local clone = useNewDialogueUI and dialog.linenew:Clone() or dialog.line:Clone()

			if useNewDialogueUI then
				clone.NPCName.Text = tostring(p.npc)
			end

			clone.Name = "dialogline"

			if state2.hasPassdown then
				local v11 = string.split(state2.text, "@")
				local text = ""

				for _, v13 in v11 do
					if v13 == "passdown" then
						if localPlayer:FindFirstChild("Passdown") then
							text ..= tostring(localPlayer:FindFirstChild("Passdown").Value)
							localPlayer:FindFirstChild("Passdown"):Destroy()

							for _ = 1, 5 do
								if localPlayer:FindFirstChild("Passdown") then
									localPlayer:FindFirstChild("Passdown"):Destroy()
								end
							end
						else
							text ..= ""
						end
					else
						text ..= v13
					end
				end

				clone.title.Text = text
			elseif state2.is_dynamic and typeof(initial_data) == "table" then
				clone.title.Text = DynamicString:Format(state2.text, initial_data)
			else
				clone.title.Text = state2.text
			end

			clone.title.MaxVisibleGraphemes = 0
			clone.Parent = useNewDialogueUI and localPlayer.PlayerGui.hud.safezone or parent

			if state2.customPosition then
				clone.title.Position = state2.customPosition
			end

			if state2.customSize then
				clone.title.Size = state2.customSize
			end

			if state2.enableBillboard then
				state2.enableBillboard.Enabled = true
			end

			if state2.disableBillboard then
				state2.disableBillboard.Enabled = false
			end

			if state2.t == nil then
				state2.t = #clone.title.ContentText * 0.025
			end

			local TweenService = game:GetService("TweenService")
			local tween = TweenService:Create(
				clone.title,
				TweenInfo.new(state2.t, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{
					MaxVisibleGraphemes = #clone.title.ContentText
				}
			)
			tween:Play()
			local v11 = false
			v5 = true
			local value = p.npc and p.npc:FindFirstChild("description") and p.npc.description:FindFirstChild("voice") and p.npc.description.voice.Value or p.voice
			local children = voices:FindFirstChild(value):GetChildren()
			clone.title:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
				if not (clone and clone:FindFirstChild("title")) then
					return
				end

				if v6 == true then
					tween:Cancel()
					clone.title.MaxVisibleGraphemes = -1
				elseif v11 == false and clone.title.MaxVisibleGraphemes <= #clone.title.Text then
					v11 = true
					fx:PlaySound(children[math.random(1, #children)], parent, true)
					task.wait(0.04)
					v11 = false
				end
			end)
			local lastTime = os.clock()

			repeat
				task.wait()
			until v6 == true or os.clock() - lastTime >= state2.t * 0.9

			v5 = false

			if v6 == true then
				tween:Cancel()

				if clone and clone.Parent then
					clone.title.MaxVisibleGraphemes = -1
				end

				fx:PlaySound(
					ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("dialogSkip"),
					parent,
					true
				)
				v6 = false
				fx:PlaySound(children[math.random(1, #children)], parent, true)

				if not (state2 and (state2.nodelay or state2.choices and state2.choices[1])) then
					task.wait(0.5)
				end
			end

			if v3 ~= objectValue or v2 ~= state then
				EndDialog("New Dialog")
			end

			if not (character2:FindFirstChild("dialoglink") and character2:FindFirstChild("dialoglink") == objectValue) then
				return
			end

			if v == parent and v2 == state then
				if v == parent and v2 == state and character2:FindFirstChild("dialoglink") and v4 == true then
					if state2.skipto or state2.cs_trigger or state2.continue then
						v5 = true
						v6 = false
						local v12 = state2.t * 0.9

						if state2.dialogdelay or state2.continue then
							v12 = state2.t * 0.9 + (state2.dialogdelay or 1)
						end

						local lastTime2 = os.clock()

						repeat
							task.wait()
						until v6 == true or state2.nodelay or v12 <= os.clock() - lastTime2

						if v6 == true then
							fx:PlaySound(
								ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("dialogSkip"),
								parent,
								true
							)
						end

						if state2.continue then
							CreateDialogLine(state.dialog[table.find(state.dialog, state2) + 1])
						else
							CreateDialogLine(v9[state2.cs_trigger] or state.dialog[state2.skipto])
						end
					else
						if #state2.choices == 0 then
							EndDialog("No More Dialog Responses")
							return
						end

						local clone2 = useNewDialogueUI and dialog.optionsnew:Clone() or dialog.options:Clone()

						if useNewDialogueUI then
							for k, choice in pairs(state2.choices) do
								local text = choice.text

								if choice.is_dynamic and typeof(initial_data) == "table" then
									text = DynamicString:Format(choice.text, initial_data)
								end

								local clone3 = clone2.responses.template:Clone()
								clone3.Name = k .. "option"
								clone3.Text = "[\"" .. text .. "\"]"
								clone3.Parent = clone2.responses
								clone3.Visible = true
								clone3.MouseEnter:Connect(function()
									fx:PlaySound(
										ReplicatedStorage2.resources.sounds.sfx.ui.select,
										localPlayer.PlayerGui,
										true
									)
								end)
								local v12 = k

								local function OptionPress()
									if character2:FindFirstChild("dialogline", true) then
										character2:FindFirstChild("dialogline", true):Destroy()
									end

									if character2.Head:FindFirstChild("responseline") then
										character2.Head:FindFirstChild("responseline"):Destroy()
									end

									clone2:Destroy()
									local clone4 = dialog.playerline:Clone()
									clone4.Name = "responseline"
									clone4.title.Text = text
									clone4.title.MaxVisibleGraphemes = 0
									clone4.Parent = character2.Head
									local TweenService2 = game:GetService("TweenService")
									TweenService2:Create(
										clone4.title,
										TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
										{
											MaxVisibleGraphemes = #clone4.title.ContentText
										}
									):Play()
									debris:AddItem(clone4, 8)
									local TweenService3 = game:GetService("TweenService")
									TweenService3:Create(
										clone4.title,
										TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 4),
										{
											TextTransparency = 1,
											TextStrokeTransparency = 1
										}
									):Play()
									local TweenService4 = game:GetService("TweenService")
									TweenService4:Create(
										clone4.bg,
										TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 6),
										{
											ImageTransparency = 1
										}
									):Play()
									fx:PlaySound(
										ReplicatedStorage2.resources.sounds.sfx.ui.select,
										localPlayer.PlayerGui,
										true
									)
									clone4.title:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
										if v11 == false and clone4.title.MaxVisibleGraphemes <= #state2.text then
											v11 = true
											local children2 = voices:FindFirstChild("3"):GetChildren()
											fx:PlaySound(children2[math.random(1, #children2)], character2.Head, true)
											task.wait(0.04)
											v11 = false
										end
									end)
									task.wait(0.6)

									if v == parent and v2 == state and character2:FindFirstChild("dialoglink") and v4 == true then
										if state2.choices[v12].run then
											local v13 = state2.choices[v12].run:InvokeServer(p)

											if v13 == true then
												if state2.choices[v12].nextlinetrue then
													CreateDialogLine(state.dialog[state2.choices[v12].nextlinetrue])
												else
													EndDialog("No More Dialog Responses")
												end
											elseif v13 == false then
												if state2.choices[v12].nextlinefalse then
													CreateDialogLine(state.dialog[state2.choices[v12].nextlinefalse])
												else
													EndDialog("No More Dialog Responses")
												end
											elseif type(v13) == "string" then
												if v9[v13] then
													CreateDialogLine(v9[v13])
													return
												end

												warn((`Unregistered CustomString "{v13}"`))
												EndDialog("No More Dialog Responses")
											end
										elseif state2.choices[v12].nextline then
											CreateDialogLine(state.dialog[state2.choices[v12].nextline])
										elseif state2.choices[v12].cs_trigger then
											CreateDialogLine(v9[state2.choices[v12].cs_trigger])
										else
											EndDialog("No More Dialog Responses")
										end
									end
								end

								clone3.MouseButton1Click:Connect(OptionPress)
								task.wait(0.1)
							end

							clone2.Name = "options"
							clone2.Parent = localPlayer.PlayerGui.hud.safezone
						else
							local v12 = 1
							local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
							local gamepad = require(ReplicatedStorage3.client.legacyControllers.InputController):Get("Gamepad")
							maid:Add(gamepad.ButtonDown:Connect(function(p2, flag2: boolean)
								if flag2 == true then
									return
								end

								if p2 == Enum.KeyCode.DPadUp or p2 == Enum.KeyCode.DPadDown then
									v12 += p2 == Enum.KeyCode.DPadUp and -1 or 1

									if v12 > #state2.choices then
										v12 = 1
									elseif v12 <= 0 then
										v12 = #state2.choices
									end

									for k, _ in state2.choices do
										local child = clone2.safezone:FindFirstChild((`{k}option`))

										if child then
											child.GamepadIcon.Visible = k == v12
										end
									end
								elseif p2 == Enum.KeyCode.ButtonB then
									EndDialog("...")
								end
							end))

							for k, choice in pairs(state2.choices) do
								local clone3 = clone2.safezone.template:Clone()
								clone3.Name = k .. "option"
								clone3.choicenum.Text = tostring(k .. ". ")
								local text = choice.text

								if choice.is_dynamic and typeof(initial_data) == "table" then
									text = DynamicString:Format(choice.text, initial_data)
								end

								clone3.text.Text = `["{text}"]`
								clone3.Parent = clone2.safezone
								clone3.GamepadIcon.Visible = k == v12
								clone3.shine.ImageTransparency = 1
								clone3.text.TextTransparency = 1
								clone3.text.Position = UDim2.new(0.06, 0, 0, 0)
								clone3.text.stroke.Transparency = 1
								clone3.choicenum.TextTransparency = 1
								clone3.choicenum.stroke.Transparency = 1
								local TweenService2 = game:GetService("TweenService")
								TweenService2:Create(
									clone3.text,
									TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										Position = UDim2.new(0, 0, 0, 0),
										TextTransparency = 0
									}
								):Play()
								local TweenService3 = game:GetService("TweenService")
								TweenService3:Create(
									clone3.text.stroke,
									TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										Transparency = 0.54
									}
								):Play()
								local TweenService4 = game:GetService("TweenService")
								TweenService4:Create(
									clone3.choicenum,
									TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										TextTransparency = 0
									}
								):Play()
								local TweenService5 = game:GetService("TweenService")
								TweenService5:Create(
									clone3.choicenum.stroke,
									TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
									{
										Transparency = 0.54
									}
								):Play()
								local TweenService6 = game:GetService("TweenService")
								TweenService6:Create(
									clone3.shine,
									TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										ImageTransparency = 0.35
									}
								):Play()
								clone3.Visible = true
								local v13 = nil
								local v14 = nil
								clone3.button.MouseEnter:Connect(function()
									if v13 ~= nil then
										v13:Cancel()
									end

									if v14 ~= nil then
										v14:Cancel()
									end

									local TweenService7 = game:GetService("TweenService")
									v13 = TweenService7:Create(
										clone3.text,
										TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
										{
											Position = UDim2.new(0.04, 0, 0, 0)
										}
									):Play()
									local TweenService8 = game:GetService("TweenService")
									v14 = TweenService8:Create(
										clone3.shine,
										TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
										{
											ImageTransparency = 0.16
										}
									):Play()
									fx:PlaySound(
										ReplicatedStorage2.resources.sounds.sfx.ui.select,
										workspace.CurrentCamera,
										true
									)
								end)
								local v16 = clone3
								clone3.button.MouseLeave:Connect(function()
									if v13 ~= nil then
										v13:Cancel()
									end

									if v14 ~= nil then
										v14:Cancel()
									end

									local TweenService7 = game:GetService("TweenService")
									v13 = TweenService7:Create(
										v16.text,
										TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
										{
											Position = UDim2.new(0, 0, 0, 0)
										}
									):Play()
									local TweenService8 = game:GetService("TweenService")
									v14 = TweenService8:Create(
										v16.shine,
										TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
										{
											ImageTransparency = 0.35
										}
									):Play()
								end)
								local flag2 = false
								local v17 = choice
								local v18 = k

								local function OptionPress()
									if flag2 then
										return
									end

									flag2 = true

									if character2:FindFirstChild("dialogline", true) then
										character2:FindFirstChild("dialogline", true):Destroy()
									end

									if character2.Head:FindFirstChild("responseline") then
										character2.Head:FindFirstChild("responseline"):Destroy()
									end

									clone2:Destroy()
									local clone4 = dialog.playerline:Clone()
									clone4.Name = "responseline"
									clone4.title.Text = v17.displaytext or text
									clone4.title.MaxVisibleGraphemes = 0
									clone4.Parent = character2.Head
									local TweenService7 = game:GetService("TweenService")
									TweenService7:Create(
										clone4.title,
										TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
										{
											MaxVisibleGraphemes = #(v17.displaytext or text)
										}
									):Play()
									debris:AddItem(clone4, 8)
									local TweenService8 = game:GetService("TweenService")
									TweenService8:Create(
										clone4.title,
										TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 4),
										{
											TextTransparency = 1,
											TextStrokeTransparency = 1
										}
									):Play()
									local TweenService9 = game:GetService("TweenService")
									TweenService9:Create(
										clone4.bg,
										TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 6),
										{
											ImageTransparency = 1
										}
									):Play()
									fx:PlaySound(
										ReplicatedStorage2.resources.sounds.sfx.ui.select,
										localPlayer.PlayerGui,
										true
									)
									clone4.title:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
										if v11 == false and clone4.title.MaxVisibleGraphemes <= #state2.text then
											v11 = true
											local children2 = voices:FindFirstChild("3"):GetChildren()
											fx:PlaySound(children2[math.random(1, #children2)], character2.Head, true)
											task.wait(0.04)
											v11 = false
										end
									end)
									task.wait(0.6)

									if v == parent and v2 == state and character2:FindFirstChild("dialoglink") and v4 == true then
										if state2.choices[v18].run then
											local v19 = state2.choices[v18].run:InvokeServer(p)

											if v19 == true then
												if state2.choices[v18].nextlinetrue then
													CreateDialogLine(state.dialog[state2.choices[v18].nextlinetrue])
												else
													EndDialog("No More Dialog Responses")
												end
											elseif v19 == false then
												if state2.choices[v18].nextlinefalse then
													CreateDialogLine(state.dialog[state2.choices[v18].nextlinefalse])
												else
													EndDialog("No More Dialog Responses")
												end
											else
												if type(v19) ~= "string" then
													EndDialog("No More Dialog Responses")
													return
												end

												if v9[v19] then
													CreateDialogLine(v9[v19])
													return
												end

												warn((`Unregistered CustomString "{v19}"`))
												EndDialog("No More Dialog Responses")
											end
										elseif state2.choices[v18].callback then
											local v19, v20 = remoteFunction:InvokeServer(state2.nodeIndex, v18)
											initial_data = v20

											if v19 == true then
												if state2.choices[v18].nextlinetrue then
													CreateDialogLine(state.dialog[state2.choices[v18].nextlinetrue])
												else
													EndDialog("No More Dialog Responses")
												end
											elseif v19 == false then
												if state2.choices[v18].nextlinefalse then
													CreateDialogLine(state.dialog[state2.choices[v18].nextlinefalse])
												else
													EndDialog("No More Dialog Responses")
												end
											else
												if type(v19) ~= "string" then
													EndDialog("No More Dialog Responses")
													return
												end

												if v9[v19] then
													CreateDialogLine(v9[v19])
													return
												end

												warn((`Unregistered CustomString "{v19}"`))
												EndDialog("No More Dialog Responses")
											end
										elseif state2.choices[v18].nextline then
											CreateDialogLine(state.dialog[state2.choices[v18].nextline])
										elseif state2.choices[v18].cs_trigger then
											CreateDialogLine(v9[state2.choices[v18].cs_trigger])
										else
											EndDialog("No More Dialog Responses")
										end
									end
								end

								clone3.button.MouseButton1Click:Connect(OptionPress)
								local v19 = k
								local OptionPress2 = OptionPress
								maid:Add(gamepad.ButtonDown:Connect(function(p2, flag3: boolean)
									if v12 ~= v19 or flag3 == true or p2 ~= Enum.KeyCode.ButtonX or Debounce(
										"ButtonX",
										0.5
									) then
										return
									end

									OptionPress2()
								end))
								task.wait(0.1)
							end

							clone2.Parent = localPlayer.PlayerGui
							clone2.Adornee = character2.Torso
						end

						local _ = tostring(preferredInput.Current) == "Gamepad"
					end
				end
			else
				if localPlayer.PlayerGui:FindFirstChild("options") then
					localPlayer.PlayerGui:FindFirstChild("options"):Destroy()
				end

				if localPlayer.PlayerGui.hud.safezone:FindFirstChild("options") then
					localPlayer.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
				end
			end
		end

		if state.locked == true then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
				{
					FieldOfView = 65
				}
			):Play()
		end

		if state.cs_start then
			CreateDialogLine(v9[state.cs_start])
		else
			if startline == nil or not startline then
				startline = state.startline or 1
			end

			CreateDialogLine(state.dialog[startline])
		end
	else
		if runBehaviourFunction then
			modulesByName[runBehaviourFunction](p.npc)
		end

		local CreateNonLockedDialogLine

		CreateNonLockedDialogLine = function(data)
			if parent:FindFirstChild("dialogline") then
				parent:FindFirstChild("dialogline"):Destroy()
			end

			if p and p.npc and p.npc:FindFirstChild("dialogprompt") then
				local dialogprompt = p.npc:FindFirstChild("dialogprompt")
				dialogprompt.Enabled = false
			end

			local clone = dialog.line:Clone()
			clone.Name = "dialogline"
			clone.title.Text = data.text
			clone.title.MaxVisibleGraphemes = 0
			clone.Parent = parent
			local TweenService = game:GetService("TweenService")
			TweenService:Create(clone.title, TweenInfo.new(data.t, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				MaxVisibleGraphemes = #data.text
			}):Play()
			local v10 = false
			clone.title:GetPropertyChangedSignal("MaxVisibleGraphemes"):Connect(function()
				if v10 == false and clone.title.MaxVisibleGraphemes <= #data.text then
					v10 = true

					if p.voice then
						local children = voices:FindFirstChild(p.voice):GetChildren()
						fx:PlaySound(children[math.random(1, #children)], parent, true)
						task.wait(0.04)
					end

					v10 = false
				end
			end)
			task.wait(data.t)

			if data.skipto or data.cs_trigger or data.continue then
				if not data.nodelay then
					task.wait(data.t * 1.1)
				end

				if data.continue then
					CreateNonLockedDialogLine(state.dialog[table.find(state.dialog, data) + 1])
				else
					CreateNonLockedDialogLine(v9[data.cs_trigger] or state.dialog[data.skipto])
				end
			else
				if p and p.npc and p.npc:FindFirstChild("dialogprompt") then
					local dialogprompt_2 = p.npc:FindFirstChild("dialogprompt")
					dialogprompt_2.Enabled = true
				end

				if parent:FindFirstChild("dialogline") then
					debris:AddItem(parent:FindFirstChild("dialogline"), 8)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						parent:FindFirstChild("dialogline").title,
						TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 3),
						{
							TextTransparency = 1,
							TextStrokeTransparency = 1
						}
					):Play()
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(
						parent:FindFirstChild("dialogline").bg,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 6),
						{
							ImageTransparency = 1
						}
					):Play()
				end
			end
		end

		CreateNonLockedDialogLine(state.dialog[state.startline or 1])
	end
end

ReplicatedStorage2:WaitForChild("events"):WaitForChild("dialogstart").OnClientEvent:Connect(recvDialogEvent)
ReplicatedStorage2.events.clientdialog.Event:Connect(recvDialogEvent)
local Players2 = game:GetService("Players")
local localPlayer2 = Players2.LocalPlayer
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	if not localPlayer2.Character then
		return
	end

	local humanoidRootPart = localPlayer2.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = localPlayer2.Character:FindFirstChildOfClass("Humanoid")
	local user = humanoidRootPart and humanoidRootPart:FindFirstChild("user")

	if v4 == true and v ~= nil and v2 ~= nil then
		if user then
			user.Enabled = false
		end

		if humanoidRootPart and not ((humanoidRootPart.Position - v.Position).Magnitude > v2.maxdistance) and humanoid and not (humanoid.Health <= 0) or not localPlayer2.Character:FindFirstChild("dialoglink") then
			if (not humanoidRootPart or (humanoidRootPart.Position - v.Position).Magnitude > v2.maxdistance or not humanoid or humanoid.Health <= 0) and localPlayer2.PlayerGui:FindFirstChild("options") then
				localPlayer2.PlayerGui:FindFirstChild("options"):Destroy()
				localPlayer2.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
			end
		elseif localPlayer2.Character:FindFirstChild("dialoglink").Value ~= nil then
			if localPlayer2.PlayerGui:FindFirstChild("options") then
				localPlayer2.PlayerGui:FindFirstChild("options"):Destroy()
			end

			if localPlayer2.PlayerGui.hud.safezone:FindFirstChild("options") then
				localPlayer2.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
			end

			EndDialog("Walked Away")
		end
	else
		if user then
			user.Enabled = SettingsController:GetSettingValue("seeOwnName") and not localPlayer2.Character:GetAttribute("CharacterInvisible")
		end

		if localPlayer2.PlayerGui:FindFirstChild("options") then
			localPlayer2.PlayerGui:FindFirstChild("options"):Destroy()

			if localPlayer2.PlayerGui.hud.safezone:FindFirstChild("options") then
				localPlayer2.PlayerGui.hud.safezone:FindFirstChild("options"):Destroy()
			end
		end
	end
end)