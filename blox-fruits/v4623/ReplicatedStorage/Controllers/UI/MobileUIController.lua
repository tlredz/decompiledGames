local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
game:GetService("Players")
local Inventory = require(ReplicatedStorage.Controllers.UI.Inventory)
local FruitSkillUtil = require(ReplicatedStorage.Modules.FruitSkillUtil)
local IsTransformed = require(ReplicatedStorage.Util.IsTransformed)
local LastInput = require(ReplicatedStorage.Modules.LastInput)
local Flags = require(ReplicatedStorage.Modules.Flags)
local Notification = require(ReplicatedStorage.Notification)
local MathUtil = require(ReplicatedStorage.Modules.Util.MathUtil)
local FruitSkills = require(ReplicatedStorage.FruitSkills)
local Signal = require(ReplicatedStorage.Modules.Util.Signal)
local MobileUIController = {}
local events = ReplicatedStorage.Events
local changeSetting = ReplicatedStorage.Remotes:WaitForChild("ChangeSetting")
local getSetting = ReplicatedStorage.Remotes:WaitForChild("GetSetting")
local localPlayer = game.Players.LocalPlayer
localPlayer:GetMouse()
local v = false
local flag = false
local now = 0
local v2 = false
local v3 = false
local zero = Vector2.zero
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = 1
local v8 = nil
local touchStartedConnection = nil
local v9 = Signal.new()
local v10 = {
	"ActivateRaceV4",
	"BoundActionBuso",
	"BoundActionKen",
	"BoundActionRaceAbility",
	"BoundActionSoru",
	"BoundActionDodge"
}
local v11 = {
	"Z",
	"X",
	"F",
	"V",
	"C",
	"TAP"
}
local v12 = {
	BoundActionRaceAbility = 1,
	ActivateRaceV4 = 2,
	BoundActionBuso = 3,
	BoundActionKen = 4,
	BoundActionSoru = 5
}
local v13 = {
	BoundActionRun = Vector2.new(428, 0),
	BoundActionKen = Vector2.new(0, 107),
	BoundActionSoru = Vector2.new(0, 0),
	BoundActionDodge = Vector2.new(107, 0),
	BoundActionBuso = Vector2.new(107, 107),
	BoundActionRaceAbility = Vector2.new(321, 0),
	ActivateRaceV4 = Vector2.new(214, 0)
}
local v14 = {
	BoundActionRun = {
		Old = UDim2.fromScale(0.85, -0.5),
		New = {
			Phone = UDim2.fromScale(-2.165, -0.757),
			Tablet = UDim2.fromScale(-2.179, -0.7)
		}
	},
	BoundActionKen = {
		Old = UDim2.fromScale(0.6, -0.75),
		New = {
			Phone = UDim2.fromScale(0.649, -0.742),
			Tablet = UDim2.fromScale(0.447, -0.843)
		}
	},
	BoundActionSoru = {
		Old = UDim2.fromScale(0.85, -0.25),
		New = {
			Phone = UDim2.fromScale(0.872, -0.43),
			Tablet = UDim2.fromScale(0.76, -0.525)
		}
	},
	BoundActionDodge = {
		Old = UDim2.fromScale(0.6, -0.25),
		New = {
			Phone = UDim2.fromScale(0.639, -0.424),
			Tablet = UDim2.fromScale(0.447, -0.525)
		}
	},
	BoundActionBuso = {
		Old = UDim2.fromScale(0.85, -0.75),
		New = {
			Phone = UDim2.fromScale(-2.158, -0.423),
			Tablet = UDim2.fromScale(-2.177, -0.398)
		}
	},
	BoundActionRaceAbility = {
		Old = UDim2.fromScale(0.6, -0.5),
		New = {
			Phone = UDim2.fromScale(0.875, -0.734),
			Tablet = UDim2.fromScale(0.76, -0.843)
		}
	},
	ActivateRaceV4 = {
		Old = UDim2.fromScale(),
		New = {
			Phone = UDim2.fromScale(-1.9, -0.423),
			Tablet = UDim2.fromScale(-1.88, -0.396)
		}
	},
	Skill_Z = {
		New = {
			Phone = UDim2.fromScale(0.608, -0.052),
			Tablet = UDim2.fromScale(0.391, 0.047)
		}
	},
	Skill_X = {
		New = {
			Phone = UDim2.fromScale(0.352, 0.147),
			Tablet = UDim2.fromScale(0.075, 0.181)
		}
	},
	Skill_F = {
		New = {
			Phone = UDim2.fromScale(0.577, 0.336),
			Tablet = UDim2.fromScale(0.374, 0.363)
		}
	},
	Skill_V = {
		New = {
			Phone = UDim2.fromScale(0.381, 0.782),
			Tablet = UDim2.fromScale(0.226, 0.757)
		}
	},
	Skill_C = {
		New = {
			Phone = UDim2.fromScale(0.298, 0.474),
			Tablet = UDim2.fromScale(0.045, 0.471)
		}
	},
	Skill_TAP = {
		New = {
			Phone = UDim2.fromScale(0.325, -0.175),
			Tablet = UDim2.fromScale(0.125, -0.1)
		}
	}
}
local v15 = {}

local function getElapsed(p)
	return os.clock() - p
end

local function fromScale(p)
	return UDim2.fromScale(p.X, p.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function computeGrabOffsetPx(data, p)
	return p - (data.AbsolutePosition + data.AnchorPoint * data.AbsoluteSize)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function absoluteAnchorToScaleOnParent(contextButtonFrame, p)
	local absoluteSize = contextButtonFrame.AbsoluteSize

	if absoluteSize.X == 0 or absoluteSize.Y == 0 then
		return UDim2.new()
	end

	local v16 = p - contextButtonFrame.AbsolutePosition
	return UDim2.fromScale(v16.X / absoluteSize.X, v16.Y / absoluteSize.Y)
end

function MobileUIController:GetDeviceLayout()
	local main = localPlayer.PlayerGui:WaitForChild("Main")
	local v16 = math.min(main.AbsoluteSize.X, main.AbsoluteSize.Y)
	local v17 = v16 <= 500
	local v18 = v16 > 500

	if v17 then
		return "Phone"
	end

	return v18 and "Tablet"
end

function MobileUIController.GetDeviceLayoutChangedSignal(_)
	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyButtonCustomization(state)
	if not state then
		return
	end

	local deviceLayout = MobileUIController:GetDeviceLayout()
	local old = v14[state.Name].Old

	if v then
		old = v14[state.Name].New[deviceLayout]
	end

	state.Position = old
	local scale = deviceLayout == "Tablet" and 1.5 or 1
	state.UIScale.Scale = scale
end

function MobileUIController:GetMobileSkillMode()
	return v7
end

function MobileUIController:SetMobileSkillMode(p)
	v7 = p
	changeSetting:FireServer("MobileSkillMode", p)

	for _, v16 in v11 do
		local contextButton = MobileUIController:GetContextButton("Skill_" .. v16)
		local button = contextButton and contextButton:FindFirstChild("Button")

		if button then
			button.Active = p == 2
		end
	end
end

function MobileUIController:PlayCooldownAnimation(instance, p, p2, totalTime, p4)
	if not v15[p] then
		v15[p] = {}
	end

	if not p4 then
		v15[p][p2] = {
			StartTime = os.clock(),
			TotalTime = totalTime
		}
	end

	local v16 = v15[p][p2]
	local cooldown = instance:FindFirstChild("Cooldown", true)
	local v17 = v16.StartTime + v16.TotalTime

	if v17 - os.clock() <= 0 then
		return
	end

	if not instance:GetAttribute("NonToolButton") then
		local tool = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Tool")

		if not tool or tool.Name ~= p then
			return
		end
	end

	local itemName = instance:GetAttribute("ItemName")
	local cooldownLabel = instance:FindFirstChild("CooldownLabel", true)

	while true do
		local v18 = v17 - os.clock()

		if cooldownLabel then
			cooldownLabel.Visible = true
			cooldownLabel.Text = string.match(tostring(v18), "%d+%.%d")
		end

		cooldown:SetAttribute("Percentage", v18 / v16.TotalTime)
		cooldown.Visible = true
		task.wait()
		local v19 = not cooldown.Parent or itemName ~= instance:GetAttribute("ItemName")
		local v20 = v18 <= 0

		if not (v19 or v20) then
			continue
		end

		if v19 and not v20 then
			cooldown:SetAttribute("Percentage", 0)
		end

		if cooldownLabel then
			cooldownLabel.Visible = false
			cooldown.Visible = false
		end

		if v17 - os.clock() <= 0 then
			v15[p][p2] = nil
		end

		break
	end
end

local function reflectLayoutSetting()
	if not LastInput:IsMobile() then
		return
	end

	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local main = playerGui:WaitForChild("Main")
	local touchControlsEnabled = v and GuiService.TouchControlsEnabled
	local touchControlsEnabled2 = not v and GuiService.TouchControlsEnabled
	local mobileContextButtons = playerGui:WaitForChild("MobileContextButtons")
	local _ = localPlayer.Team == game.Teams.Pirates

	if v then
		mobileContextButtons.Enabled = touchControlsEnabled
	else
		mobileContextButtons.Enabled = touchControlsEnabled2
	end

	for _, v16 in {
		MobileUIController:GetContextButton("BoundActionRun"),
		MobileUIController:GetContextButton("BoundActionDodge"),
		MobileUIController:GetContextButton("BoundActionSoru"),
		MobileUIController:GetContextButton("BoundActionBuso"),
		MobileUIController:GetContextButton("BoundActionKen"),
		MobileUIController:GetContextButton("BoundActionRaceAbility"),
		(MobileUIController:GetContextButton("ActivateRaceV4"))
	} do
		if not v16 then
			continue
		end

		applyButtonCustomization(v16) -- equivalent call inferred; original call site unknown
	end

	main.CustomizeMobileButtons.Visible = false
	main.ResetCustomization.Visible = false
	main.HUDButtonBar.Visible = touchControlsEnabled2 and not Inventory.IsOpen
end

function MobileUIController.UnbindContextButton(_, childName)
	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if playerGui then
		local universalContextButtons = playerGui:WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("UniversalContextButtons")
		local v16 = playerGui:WaitForChild("MobileContextButtons").ContextButtonFrame:FindFirstChild(childName) or universalContextButtons:FindFirstChild(childName)

		if v16 then
			v16:Destroy()
		end
	end

	ContextActionService:UnbindAction("Proxy_" .. childName)
end

function MobileUIController.CreateContextButton(_, name, callback, ...)
	local playerGui = localPlayer.PlayerGui

	if MobileUIController:GetContextButton(name) then
		return
	end

	local isMobile = LastInput:IsMobile()

	if isMobile or table.find(v10, name) then
		local v16 = { ... }
		local clone = (isMobile and script.ContextButtonTemplate or script.UniversalContextButtonTemplate):Clone()
		local button = clone.Button
		clone.Name = name

		-- equivalent calls inferred from this helper; original call sites unknown
		local function callBoundFunction(p, p2, input)
			local userInputType = input.UserInputType

			if userInputType == Enum.UserInputType.Touch or userInputType == Enum.UserInputType.MouseButton1 then
				callback(p, p2, input)
			end
		end

		button.InputBegan:Connect(function(input)
			if v2 and input.UserInputType == Enum.UserInputType.Touch then
				if input.UserInputState ~= Enum.UserInputState.Change then
					return
				end
			else
				callBoundFunction(name, Enum.UserInputState.Begin, input) -- equivalent call inferred; original call site unknown
				flag = true
			end
		end)
		button.InputChanged:Connect(function(input)
			if v2 and input.UserInputType == Enum.UserInputType.Touch then
				return
			end

			callBoundFunction(name, Enum.UserInputState.Change, input) -- equivalent call inferred; original call site unknown
		end)
		button.InputEnded:Connect(function(input)
			callBoundFunction(name, Enum.UserInputState.End, input) -- equivalent call inferred; original call site unknown
		end)
		clone.CaptureInput.TouchLongPress:Connect(function(_, p)
			if p == Enum.UserInputState.Begin then
				zero = computeGrabOffsetPx(button, UserInputService:GetMouseLocation() - GuiService:GetGuiInset())
				v4 = clone
				script.CustomizationPressHaptic:Play()
			end
		end)
		local uIScale = clone:FindFirstChildWhichIsA("UIScale")

		if v6[clone.Name] then
			uIScale.Scale = v6[clone.Name]
		end

		local scale = uIScale.Scale

		local function onTouchPinch(_, p, _, p2)
			if not v2 then
				return
			end

			if p2 == Enum.UserInputState.Begin and not v3 then
				v3 = true
				scale = uIScale.Scale
			elseif p2 == Enum.UserInputState.Change then
				uIScale.Scale = scale * p
			elseif p2 == Enum.UserInputState.End and v3 then
				v3 = false
				local name2 = clone.Name
				local v17 = {
					ButtonName = name2,
					Prop = "Scale",
					Value = uIScale.Scale
				}
				v6[name2] = v17.Value
				changeSetting:FireServer("MobileButtonCustomization", v17)
			end
		end

		clone.CaptureInput.TouchPinch:Connect(onTouchPinch)
		local cooldown = clone:FindFirstChild("Cooldown", true)
		cooldown:SetAttribute("BackgroundFrameTransparency", 1)
		cooldown:SetAttribute("FillTransparency", 0)
		cooldown:SetAttribute("FillColor", Color3.fromRGB(0, 0, 0))
		cooldown:SetAttribute("DoFlip", true)

		if isMobile then
			clone.GroupTransparency = 0.8
			button.Active = true

			for _, button2 in button:GetDescendants() do
				if button2:IsA("GuiButton") then
					button2.Active = true
				end
			end
		else
			if #v16 > 0 then
				ContextActionService:BindAction(name, callback, false, unpack(v16))
			end

			local layoutOrder = v12[name]

			if layoutOrder then
				clone.LayoutOrder = layoutOrder
			end

			local innerGlow = clone.InnerGlow
			button.MouseEnter:Connect(function()
				innerGlow.ImageTransparency = 0
			end)
			button.MouseLeave:Connect(function()
				innerGlow.ImageTransparency = 1
			end)
		end

		local v17 = string.match(name, "Skill_")

		if v17 then
			button.Active = MobileUIController:GetMobileSkillMode() == 2
		else
			button.Active = true
		end

		clone.Active = false
		clone.CaptureInput.ZIndex = v17 and 0 or 99
		local selectedGlow = clone:FindFirstChild("SelectedGlow", true)

		if selectedGlow then
			local function reflectSelected()
				selectedGlow.ImageTransparency = clone:GetAttribute("Selected") and 0 or 1
			end

			selectedGlow.ImageTransparency = clone:GetAttribute("Selected") and 0 or 1
			clone:GetAttributeChangedSignal("Selected"):Connect(reflectSelected)
		end

		local imageRectOffset = v13[name]

		if imageRectOffset then
			local icon = clone:FindFirstChild("Icon", true)
			icon.Image = "rbxassetid://16930268184"
			icon.ImageRectSize = Vector2.new(107, 107)
			icon.ImageRectOffset = imageRectOffset
			icon.Size = UDim2.fromScale(0.65, 0.6)
			local label = clone:FindFirstChild("Label", true)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.fromScale(0.5, 1)
		end

		local universalContextButtons = playerGui:WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("UniversalContextButtons")
		local mobileContextButtons = playerGui:WaitForChild("MobileContextButtons")

		if isMobile then
			universalContextButtons = mobileContextButtons.ContextButtonFrame or universalContextButtons
		end

		clone.Parent = universalContextButtons
		now = tick()

		if isMobile then
			reflectLayoutSetting()
		end

		return clone
	else
		ContextActionService:BindAction("Proxy_" .. name, callback, false, ...)
		RunService:IsStudio()
	end
end

function MobileUIController:GetContextButton(childName)
	local playerGui = localPlayer.PlayerGui
	local mobileContextButtons = playerGui:WaitForChild("MobileContextButtons")
	local universalContextButtons = playerGui:WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("UniversalContextButtons")
	return mobileContextButtons.ContextButtonFrame:FindFirstChild(childName) or universalContextButtons:FindFirstChild(childName)
end

function MobileUIController.CreateSkillContextButtons(_, instance)
	MobileUIController:UnbindSkillContextButtons()

	local function activateSkill(mobileSelection)
		return function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v16 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v16)

					if v16 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end
	end

	local function activateM1(_, p, inputObject)
		local contextButton = MobileUIController:GetContextButton("Skill_TAP")

		if p == Enum.UserInputState.Begin then
			if MobileUIController:GetMobileSkillMode() == 1 then
				inputObject.KeyCode = Enum.KeyCode.G
				local Global = require(game.ReplicatedStorage.Global)
				Global.mobileSelection = "G"
				FruitSkillUtil.MobileM1ButtonActivated({
					HeldTool = instance,
					InputObject = inputObject
				})
			else
				local v16 = not contextButton:GetAttribute("Selected")
				contextButton:SetAttribute("Selected", v16)

				if v16 then
					if v8 then
						v8:SetAttribute("Selected", false)
					end

					v8 = contextButton
				else
					v8 = nil
				end

				touchStartedConnection = UserInputService.TouchStarted:Connect(function(inputObject2, p4)
					if p4 or not instance.Parent or v8 ~= contextButton then
						return
					end

					if touchStartedConnection then
						touchStartedConnection:Disconnect()
						touchStartedConnection = nil
						FruitSkillUtil.MobileM1ButtonActivated({
							HeldTool = instance,
							InputObject = inputObject2
						})
					end
				end)
			end
		elseif p == Enum.UserInputState.End then
			local Global = require(game.ReplicatedStorage.Global)
			Global.mobileSelection = "G"
		end
	end

	local v16 = FruitSkills[instance.Name][instance:FindFirstChild("AwakenedMoves") ~= nil and 2 or 1]

	-- equivalent calls inferred from this helper; original call sites unknown
	local function has(p)
		for _, v17 in v16 do
			if v17[1] == p then
				return true
			end
		end

		return false
	end

	-- equivalent call inferred; original call site unknown
	if has("Z") then
		local mobileSelection = "Z"
		local createContextButton = MobileUIController:CreateContextButton("Skill_Z", function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v18 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v18)

					if v18 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end)
		createContextButton.Button.Label.Text = "Z"
	end

	-- equivalent call inferred; original call site unknown
	if has("X") then
		local mobileSelection = "X"
		local createContextButton_2 = MobileUIController:CreateContextButton("Skill_X", function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v18 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v18)

					if v18 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end)
		createContextButton_2.Button.Label.Text = "X"
	end

	-- equivalent call inferred; original call site unknown
	if has("F") then
		local mobileSelection = "F"
		local createContextButton_3 = MobileUIController:CreateContextButton("Skill_F", function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v18 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v18)

					if v18 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end)
		createContextButton_3.Button.Label.Text = "F"
	end

	-- equivalent call inferred; original call site unknown
	if has("V") then
		local mobileSelection = "V"
		local createContextButton_4 = MobileUIController:CreateContextButton("Skill_V", function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v18 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v18)

					if v18 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end)
		createContextButton_4.Button.Label.Text = "V"
	end

	-- equivalent call inferred; original call site unknown
	if has("C") then
		local mobileSelection = "C"
		local createContextButton_5 = MobileUIController:CreateContextButton("Skill_C", function(_, p, p2)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. mobileSelection)
			local mobileSkillMode = MobileUIController:GetMobileSkillMode()
			local lockedFrame = contextButton.Button:FindFirstChild("LockedFrame")
			local visible = lockedFrame and lockedFrame.Visible

			if p == Enum.UserInputState.Begin then
				local fortBuilderActive = instance:FindFirstChild("FortBuilderActive")
				local value = fortBuilderActive and fortBuilderActive.Value

				if mobileSkillMode == 1 and not value then
					local keyCode = Enum.KeyCode[string.upper(mobileSelection)]
					p2.KeyCode = keyCode
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
					local Global2 = require(game.ReplicatedStorage.Global)
					Global2.casFunc("DevilFruit", Enum.UserInputState.Begin, p2, keyCode)
				elseif not visible then
					local v18 = not contextButton:GetAttribute("Selected")
					contextButton:SetAttribute("Selected", v18)

					if v18 then
						if v8 then
							v8:SetAttribute("Selected", false)
						end

						v8 = contextButton
					else
						v8 = nil
						local Global = require(game.ReplicatedStorage.Global)
						Global.mobileSelection = nil
					end
				end
			elseif p == Enum.UserInputState.End and not visible then
				if mobileSkillMode == 1 then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				elseif mobileSkillMode == 2 and contextButton:GetAttribute("Selected") then
					local Global = require(game.ReplicatedStorage.Global)
					Global.mobileSelection = mobileSelection
				end
			end
		end)
		createContextButton_5.Button.Label.Text = "C"
	end

	if instance:GetAttribute("MobileM1Button") and (instance.Name ~= "Dragon-Dragon" or IsTransformed(localPlayer)) then
		local createContextButton_6 = MobileUIController:CreateContextButton("Skill_TAP", activateM1)
		createContextButton_6.Button.Label.Text = "M1"
	end

	for _, v17 in v11 do
		local v18 = v15[instance.Name]
		local v19 = v18 and v18[v17]
		local contextButton = MobileUIController:GetContextButton("Skill_" .. v17)

		if not contextButton then
			continue
		end

		applyButtonCustomization(contextButton) -- equivalent call inferred; original call site unknown

		if not v19 then
			continue
		end

		local v20 = v18
		local v21 = v17
		local v22 = contextButton
		task.spawn(function()
			if v20[v21] then
				MobileUIController:PlayCooldownAnimation(v22, instance.Name, v21, nil, true)
			end
		end)
	end
end

function MobileUIController:UnbindSkillContextButtons()
	local contextButtonFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MobileContextButtons").ContextButtonFrame

	for _, v16 in v11 do
		local child = contextButtonFrame:FindFirstChild("Skill_" .. v16)

		if child then
			child:Destroy()
		end
	end
end

function MobileUIController.GetNewCooldownFrame(_)
	return script.UniversalContextButtonTemplate.Cooldown:Clone()
end

function MobileUIController:IsNewUIEnabled()
	return LastInput:IsMobile() and v and Flags.NEW_MOBILE_CONTROLS_OPTION_ENABLED
end

function MobileUIController.SetNewUIEnabled(_, p)
	if p == MobileUIController:IsNewUIEnabled() then
		return
	end

	v = p
	reflectLayoutSetting()
	events.MobileUIModeUpdated:Fire(v)
end

function MobileUIController.OnStart(_)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local main = playerGui:WaitForChild("Main")

	repeat
		task.wait()
	until localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Characters)

	while not Inventory:GetIfInitialized() do
		task.wait()
	end

	local PlayerModule = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	local controls = PlayerModule:GetControls()
	local clone = main:WaitForChild("BottomHUDList"):WaitForChild("ShipHealthBar"):Clone()
	clone.Name = "MobileShipHealthBar"
	clone.AnchorPoint = Vector2.new(0, 1)
	clone.Size = UDim2.fromScale(0.19, 0.05)
	clone.Position = UDim2.fromScale(0, 0.975)
	clone.Parent = main
	local mobileContextButtons = playerGui:WaitForChild("MobileContextButtons")
	task.defer(function()
		local v16 = 0
		local flag2 = true

		local function setProperties(child, p, p2)
			local groupTransparency = p and 0 or 0.8

			if p2 then
				TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
					GroupTransparency = groupTransparency
				}):Play()
			else
				child.GroupTransparency = groupTransparency
			end
		end

		local function reflectAllButtonsVisibility(p)
			for _, child in mobileContextButtons.ContextButtonFrame:GetChildren() do
				setProperties(child, p, true)
			end
		end

		mobileContextButtons:WaitForChild("ContextButtonFrame").ChildAdded:Connect(function(child)
			child.GroupTransparency = flag2 and 0 or 0.8
		end)

		while task.wait() do
			local now2 = tick()
			local character = localPlayer.Character
			local v17 = controls:GetMoveVector() ~= createVector(0, 0, 0)
			local busy = character and character:FindFirstChild("Busy")
			local value = busy and busy.Value
			local v18 = v17 or flag or value or now2 - now < 1 or v2

			if v18 then
				if flag2 then
					v16 = now2
				else
					flag2 = true
					v16 = now2

					for _, child in mobileContextButtons.ContextButtonFrame:GetChildren() do
						TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
							GroupTransparency = 0
						}):Play()
					end
				end
			elseif not v18 and now2 - v16 >= 1.5 and flag2 then
				flag2 = false

				for _, child in mobileContextButtons.ContextButtonFrame:GetChildren() do
					TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
						GroupTransparency = 0.8
					}):Play()
				end
			end

			if flag then
				flag = false
			end
		end
	end)
	events.PlaySkillCooldownAnimation.Event:Connect(function(p, p2, p3)
		local contextButton = MobileUIController:GetContextButton("Skill_" .. p2) or MobileUIController:GetContextButton(p)

		if contextButton and contextButton.Parent then
			MobileUIController:PlayCooldownAnimation(contextButton, p, p2, p3)
		end
	end)
	events.UsedRaceSkill.OnClientEvent:Connect(function()
		events.PlaySkillCooldownAnimation:Fire("BoundActionRaceAbility", "n/a", 30)
	end)
	reflectLayoutSetting()
	localPlayer:GetPropertyChangedSignal("Team"):Connect(reflectLayoutSetting)
	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(reflectLayoutSetting)
	Inventory.OnInventoryOpen:Connect(reflectLayoutSetting)
	Inventory.OnInventoryClose:Connect(reflectLayoutSetting)

	if not Flags.NEW_MOBILE_CONTROLS_OPTION_ENABLED then
		return
	end

	playerGui:WaitForChild("Main"):WaitForChild("BottomHUDList"):WaitForChild("UniversalContextButtons")

	if LastInput:IsMobile() then
		mobileContextButtons.Enabled = true
		reflectLayoutSetting()
		localPlayer:GetPropertyChangedSignal("Team"):Connect(reflectLayoutSetting)
		events.ActivatedSkill.Event:Connect(function(_, p)
			local contextButton = MobileUIController:GetContextButton("Skill_" .. p)

			if not contextButton then
				return
			end

			contextButton.GroupColor3 = Color3.fromRGB(0, 255, 255)
		end)

		local function setButtonCustomizationMode(visible)
			if v2 == visible then
				return
			end

			v2 = visible
			Notification.new((`Mobile Customization Mode {visible and "Enabled" or "Disabled"}`)):Display()

			for _, v16 in CollectionService:GetTagged("MobileContextButton") do
				v16.CaptureInput.Visible = visible
			end
		end

		local customizeMobileButtons = playerGui.Main:WaitForChild("CustomizeMobileButtons")
		customizeMobileButtons.Visible = false
		customizeMobileButtons.TouchTap:Connect(function()
			setButtonCustomizationMode(not v2)
		end)
		local resetCustomization = playerGui.Main:WaitForChild("ResetCustomization")
		resetCustomization.Visible = false
		resetCustomization.TouchLongPress:Connect(function(_, p)
			if p == Enum.UserInputState.Begin then
				script.CustomizationPressHaptic:Play()
				v5 = {}
				v6 = {}
				changeSetting:FireServer("MobileButtonCustomization", {
					Prop = "Reset"
				})
				Notification.new("Customization Reset"):Display()

				for _, child in mobileContextButtons.ContextButtonFrame:GetChildren() do
					child.UIScale.Scale = 1
					child.Position = v14[child.Name].New
				end
			end
		end)
	else
		local customizeMobileButtons_2 = playerGui.Main:WaitForChild("CustomizeMobileButtons")
		customizeMobileButtons_2.Visible = false
		local resetCustomization_2 = playerGui.Main:WaitForChild("ResetCustomization")
		resetCustomization_2.Visible = false
	end

	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(function()
		reflectLayoutSetting()
	end)
	UserInputService.InputChanged:Connect(function(_)
		if v4 and not v3 then
			local v16 = UserInputService:GetMouseLocation() - GuiService:GetGuiInset() - zero
			local v17 = v4
			local position = absoluteAnchorToScaleOnParent(mobileContextButtons.ContextButtonFrame, v16) -- equivalent call inferred; original call site unknown
			v17.Position = position
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if v2 and v4 and input.UserInputType == Enum.UserInputType.Touch then
			local name = v4.Name
			local v16 = {
				ButtonName = name,
				Prop = "Position",
				Value = {
					X = MathUtil.round(v4.Position.X.Scale, 3),
					Y = MathUtil.round(v4.Position.Y.Scale, 3)
				}
			}
			v5[name] = v16.Value
			changeSetting:FireServer("MobileButtonCustomization", v16)
			v4 = nil
		end
	end)
	ContextActionService.LocalToolUnequipped:Connect(function()
		v8 = nil

		if touchStartedConnection then
			touchStartedConnection:Disconnect()
			touchStartedConnection = nil
		end

		MobileUIController:UnbindSkillContextButtons()
	end)
	events.DeactivatedSkill.Event:Connect(function()
		if v8 then
			v8:SetAttribute("Selected", false)
			v8 = nil
		end

		if touchStartedConnection then
			touchStartedConnection:Disconnect()
			touchStartedConnection = nil
		end
	end)
	v5 = getSetting:InvokeServer("MobileButtonCustomization", "Position")
	v6 = getSetting:InvokeServer("MobileButtonCustomization", "Scale")
	MobileUIController:SetMobileSkillMode(getSetting:InvokeServer("MobileSkillMode"))
end

return MobileUIController