local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local BossEventFlags = require(ReplicatedStorage.Shared.Flags.BossEventFlags)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local GUI = require(ReplicatedStorage.Client.GUI)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Signal = require(ReplicatedStorage.Packages.Signal)
local uDim = UDim2.fromScale(0.5, 0.5)
local numberRange = NumberRange.new(24, 160)
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local v = {
	BossMastery = true,
	BossShop = true
}
local v2 = {
	Activated = Signal.new(),
	Deactivated = Signal.new()
}
local v3 = nil
local v4 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function animate(p, p2, items, flag: boolean)
	if flag then
		for k, item in items do
			p[k] = item
		end

		return nil
	else
		local tween = TweenService:Create(p, p2, items)
		tween:Play()
		return tween
	end
end

local parent2 = assert(Workspace.CurrentCamera, "Tabs requires Workspace.CurrentCamera")
local blurEffect = Instance.new("BlurEffect")
blurEffect.Enabled = false
blurEffect.Name = "MenuBackdropBlur"
blurEffect.Size = 0
blurEffect.Parent = parent2
local v6 = nil
local flag = false
local count = 0
local v7 = {}

local function drive(p: string, p2, p3, items, flag2: boolean)
	local v8 = v7[p]

	if v8 ~= nil then
		v7[p] = nil
		v8:Cancel()
	end

	local tween = animate(p2, p3, items, flag2) -- equivalent call inferred; original call site unknown

	if tween ~= nil then
		v7[p] = tween
	end

	return tween
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tabletLayout()
	return PlatformController.IsMobile() and parent2.ViewportSize.Y >= 600
end

local function parkPlayerList()
	if flag or not tabletLayout() then
		return
	end

	if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		flag = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unparkPlayerList()
	if flag then
		flag = false
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function blurIn(flag2: boolean)
	blurEffect.Enabled = true
	local blur = v7.blur

	if blur ~= nil then
		v7.blur = nil
		blur:Cancel()
	end

	local blur2 = animate(blurEffect, tweenInfo2, {
		Size = 14
	}, flag2) -- equivalent call inferred; original call site unknown

	if blur2 ~= nil then
		v7.blur = blur2
	end
end

local function blurOut(flag2: boolean)
	local blur = v7.blur

	if blur ~= nil then
		v7.blur = nil
		blur:Cancel()
	end

	local blur2 = animate(blurEffect, tweenInfo2, {
		Size = 0
	}, flag2) -- equivalent call inferred; original call site unknown

	if blur2 ~= nil then
		v7.blur = blur2
	end

	return blur2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pushFieldOfView(flag2: boolean)
	local v8 = v6 or parent2.FieldOfView
	v6 = v8
	local v9 = parent2
	local v11 = {
		FieldOfView = v8 + 5
	}
	local fieldOfView = v7.fieldOfView

	if fieldOfView ~= nil then
		v7.fieldOfView = nil
		fieldOfView:Cancel()
	end

	local fieldOfView2 = animate(v9, tweenInfo2, v11, flag2) -- equivalent call inferred; original call site unknown

	if fieldOfView2 ~= nil then
		v7.fieldOfView = fieldOfView2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreFieldOfView(flag2: boolean)
	local fieldOfView2 = v6

	if fieldOfView2 ~= nil then
		local v9 = parent2
		local fieldOfView = v7.fieldOfView

		if fieldOfView ~= nil then
			v7.fieldOfView = nil
			fieldOfView:Cancel()
		end

		local fieldOfView3 = animate(v9, tweenInfo2, {
			FieldOfView = fieldOfView2
		}, flag2) -- equivalent call inferred; original call site unknown

		if fieldOfView3 ~= nil then
			v7.fieldOfView = fieldOfView3
		end
	end
end

local function raiseBackdrop(p, flag2: boolean)
	count += 1
	v6 = v6 or parent2.FieldOfView
	blurIn(flag2) -- equivalent call inferred; original call site unknown

	if not p.holdCamera then
		pushFieldOfView(flag2) -- equivalent call inferred; original call site unknown
	end

	if not flag and tabletLayout() and StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		flag = true
	end
end

local function lowerBackdrop(flag2: boolean)
	count += 1
	local v8 = count

	-- equivalent calls inferred from this helper; original call sites unknown
	local function forget()
		if count == v8 then
			blurEffect.Enabled = false
			v6 = nil
		end
	end

	restoreFieldOfView(flag2) -- equivalent call inferred; original call site unknown
	local blur = v7.blur

	if blur ~= nil then
		v7.blur = nil
		blur:Cancel()
	end

	local blur2 = animate(blurEffect, tweenInfo2, {
		Size = 0
	}, flag2) -- equivalent call inferred; original call site unknown

	if blur2 ~= nil then
		v7.blur = blur2
	end

	if blur2 then
		blur2.Completed:Once(forget)
	else
		forget() -- equivalent call inferred; original call site unknown
	end

	unparkPlayerList() -- equivalent call inferred; original call site unknown
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera ~= nil and currentCamera ~= parent2 then
		parent2 = currentCamera
		blurEffect.Parent = currentCamera
	end
end)
local v8 = { function(instance)
		return instance:FindFirstChild("Frame")
	end, function(instance)
		return instance:FindFirstChildOfClass("Frame")
	end, function(instance)
		return instance:FindFirstChildWhichIsA("ImageLabel")
	end }

local function stageFor(p: string)
	local v9 = v4[p]

	if v9 then
		return v9
	end

	local v10 = {
		generation = 0,
		wired = false
	}
	v4[p] = v10
	return v10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropCloser(p)
	local closer = p.closer

	if closer then
		closer:Disconnect()
		p.closer = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function screenNamed(p: string)
	local screenGui = GUI.Get(p)
	assert(screenGui:IsA("ScreenGui"), (`tab {p} must resolve to a ScreenGui`))
	return screenGui
end

local function bodyOf(p)
	for _, v9 in v8 do
		local guiObject = v9(p)

		if guiObject and guiObject:IsA("GuiObject") then
			return guiObject
		end
	end

	error((`tab {p.Name} has no GuiObject body`))
end

local function scaleOf(parent)
	local menuScale = parent:FindFirstChild("MenuScale")

	if menuScale and menuScale:IsA("UIScale") then
		return menuScale
	end

	local uIScale = parent:FindFirstChildOfClass("UIScale")

	if uIScale then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Name = "MenuScale"
	uIScale2.Parent = parent
	return uIScale2
end

local function specOf(instance)
	return {
		holdCamera = instance:GetAttribute("ModalDialog") == true,
		selfAnimated = instance:GetAttribute("AuthoredOpenAnimation") == true,
		snapClose = instance:GetAttribute("ImmediateClose") == true
	}
end

local function entryTravel(p)
	local Y = p.AbsoluteSize.Y

	if Y <= 0 then
		Y = parent2.ViewportSize.Y / 2
	end

	return (math.clamp(Y * 0.18, numberRange.Min, numberRange.Max))
end

local function loweredPose(p)
	local Y = p.AbsoluteSize.Y

	if Y <= 0 then
		Y = parent2.ViewportSize.Y / 2
	end

	return uDim + UDim2.fromOffset(0, (math.clamp(Y * 0.18, numberRange.Min, numberRange.Max)))
end

local function closeButtonOf(instance)
	local close = instance:FindFirstChild("Close")

	if close == nil then
		local frame = instance:FindFirstChildWhichIsA("Frame")

		if frame then
			close = frame:FindFirstChild("Close")
		else
			close = nil
		end
	end

	if close == nil then
		return nil
	end

	assert(close:IsA("GuiButton"), (`{close:GetFullName()} must be a GuiButton`))
	return close
end

local function wireCloseButton(p, p2)
	if p.wired then
		return
	end

	local v9 = closeButtonOf(p2)

	if v9 then
		ButtonFX(v9, 1.08)
		GUI.OnActivated(v9, function()
			v2.Deactivate()
		end)
		GamepadBindings.Inspect(v9)
	end

	p.wired = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseFocus(ancestor)
	local selectedObject = GuiService.SelectedObject

	if selectedObject ~= nil and selectedObject:IsDescendantOf(ancestor) then
		GuiService.SelectedObject = nil
		GuiService.GuiNavigationEnabled = false
	end
end

local function admitted(p: string)
	return v[p] ~= true or BossEventFlags.ContentEnabled:Get() == true
end

local function exit(p: string, p2)
	local v9 = v4[p]

	if not v9 then
		v9 = {
			generation = 0,
			wired = false
		}
		v4[p] = v9
	end

	local screenGui = screenNamed(p) -- equivalent call inferred; original call site unknown
	local v11 = specOf(screenGui)
	local parent = bodyOf(screenGui)
	local v13 = parent:FindFirstChild("MenuScale")

	if not (v13 and v13:IsA("UIScale")) then
		v13 = parent:FindFirstChildOfClass("UIScale")

		if not v13 then
			v13 = Instance.new("UIScale")
			v13.Name = "MenuScale"
			v13.Parent = parent
		end
	end

	local instant = p2.instant == true or v11.snapClose
	local replacedBy = p2.replacedBy
	v9.generation += 1
	local generation = v9.generation
	dropCloser(v9) -- equivalent call inferred; original call site unknown
	v3 = nil
	releaseFocus(screenGui) -- equivalent call inferred; original call site unknown

	-- equivalent calls inferred from this helper; original call sites unknown
	local function settle()
		if v9.generation ~= generation then
			return
		end

		dropCloser(v9) -- equivalent call inferred; original call site unknown
		screenGui.Enabled = false
	end

	if v11.selfAnimated then
		screenGui:SetAttribute("Open", false)

		if instant or not parent.Visible then
			if v9.generation == generation then
				dropCloser(v9) -- equivalent call inferred; original call site unknown
				screenGui.Enabled = false
			end
		else
			v9.closer = parent:GetPropertyChangedSignal("Visible"):Connect(function()
				if not parent.Visible then
					settle() -- equivalent call inferred; original call site unknown
				end
			end)
			task.delay(1.2, settle)
		end
	elseif instant then
		v13.Scale = 0.9

		if v9.generation == generation then
			dropCloser(v9) -- equivalent call inferred; original call site unknown
			screenGui.Enabled = false
		end
	else
		TweenService:Create(v13, tweenInfo, {
			Scale = 0.9
		}):Play()
		local Y = parent.AbsoluteSize.Y

		if Y <= 0 then
			Y = parent2.ViewportSize.Y / 2
		end

		local tween = TweenService:Create(parent, tweenInfo, {
			Position = uDim + UDim2.fromOffset(0, (math.clamp(Y * 0.18, numberRange.Min, numberRange.Max)))
		})
		tween:Play()

		if tween then
			tween.Completed:Once(settle)
		end
	end

	if replacedBy == nil then
		lowerBackdrop(instant)
	end

	v2.Deactivated:Fire(p, {
		instant = instant,
		replacedBy = replacedBy
	})
end

local function enter(p: string, flag2: boolean)
	local v9 = v4[p]

	if not v9 then
		v9 = {
			generation = 0,
			wired = false
		}
		v4[p] = v9
	end

	local screenGui = screenNamed(p) -- equivalent call inferred; original call site unknown
	local v11 = specOf(screenGui)
	local parent = bodyOf(screenGui)
	local v13 = parent:FindFirstChild("MenuScale")

	if not (v13 and v13:IsA("UIScale")) then
		v13 = parent:FindFirstChildOfClass("UIScale")

		if not v13 then
			v13 = Instance.new("UIScale")
			v13.Name = "MenuScale"
			v13.Parent = parent
		end
	end

	v9.generation += 1
	dropCloser(v9) -- equivalent call inferred; original call site unknown
	wireCloseButton(v9, parent)
	v3 = p
	screenGui.Enabled = true
	count += 1
	v6 = v6 or parent2.FieldOfView
	blurIn(flag2) -- equivalent call inferred; original call site unknown

	if not v11.holdCamera then
		pushFieldOfView(flag2) -- equivalent call inferred; original call site unknown
	end

	if not flag and tabletLayout() and StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		flag = true
	end

	if v11.selfAnimated then
		parent.Position = uDim
		screenGui:SetAttribute("Open", true)
	elseif flag2 then
		parent.Position = uDim
		v13.Scale = 1
	else
		local Y = parent.AbsoluteSize.Y

		if Y <= 0 then
			Y = parent2.ViewportSize.Y / 2
		end

		parent.Position = uDim + UDim2.fromOffset(0, (math.clamp(Y * 0.18, numberRange.Min, numberRange.Max)))
		v13.Scale = 0.96
		TweenService:Create(parent, tweenInfo, {
			Position = uDim
		}):Play()
		TweenService:Create(v13, tweenInfo, {
			Scale = 1
		}):Play()
	end

	v2.Activated:Fire(p, {
		instant = flag2
	})
end

function v2.Active()
	return v3
end

function v2.IsActive(p: string?)
	return v3 ~= nil and (p == nil or v3 == p)
end

function v2.Activate(replacedBy: string, p2)
	if v3 == replacedBy or v[replacedBy] == true and BossEventFlags.ContentEnabled:Get() ~= true then
		return false
	end

	local v9 = v3

	if v9 ~= nil then
		exit(v9, {
			instant = true,
			replacedBy = replacedBy
		})
	end

	enter(replacedBy, p2 ~= nil and p2.instant == true)
	return true
end

function v2.Deactivate(p)
	local v9 = v3

	if v9 ~= nil then
		exit(v9, {
			instant = p ~= nil and p.instant == true
		})
	end
end

function v2.Toggle(p: string, p2)
	if not v2.Activate(p, p2) and v3 == p then
		v2.Deactivate(p2)
	end
end

BossEventFlags.ContentEnabled.Changed:Connect(function()
	if v3 ~= nil and v[v3] == true and BossEventFlags.ContentEnabled:Get() ~= true then
		v2.Deactivate({
			instant = true
		})
	end
end)
return table.freeze(v2)