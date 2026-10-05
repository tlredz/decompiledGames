local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local bottomHudLift = gameSettings.BottomHudLift
local info = faye.Info(0.25, Enum.EasingStyle.Quad)
local modulesByName = {}

for _, moduleScript in script:GetChildren() do
	if moduleScript.ClassName ~= "ModuleScript" then
		continue
	end

	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

return function(maid, instance)
	local value = maid:Value(UDim2.new(0.5, 0, 1, -bottomHudLift))
	local v = nil
	local v2 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function contentTop(instance2)
		local uIListLayout = instance2:FindFirstChildOfClass("UIListLayout")

		if uIListLayout == nil then
			return nil
		end

		return instance2.AbsolutePosition.Y + instance2.AbsoluteSize.Y - uIListLayout.AbsoluteContentSize.Y
	end

	local function follow()
		if v == nil or v.Parent == nil or not v.Visible then
			value:Set(UDim2.new(0.5, 0, 1, -bottomHudLift))
			return
		end

		local v4 = contentTop(v) -- equivalent call inferred; original call site unknown
		local v5 = v4 or v.AbsolutePosition.Y
		local aAABottomCenterNotifications = v:FindFirstChild("AAABottomCenterNotifications")

		if aAABottomCenterNotifications ~= nil and aAABottomCenterNotifications:IsA("GuiObject") and aAABottomCenterNotifications.Visible then
			local uIListLayout = aAABottomCenterNotifications:FindFirstChildOfClass("UIListLayout")
			local v6 = uIListLayout == nil and 0 or uIListLayout.AbsoluteContentSize.Y
			v5 += aAABottomCenterNotifications.AbsoluteSize.Y - v6
			local uIListLayout2 = v:FindFirstChildOfClass("UIListLayout")

			if v6 <= 0 and uIListLayout2 ~= nil then
				v5 += uIListLayout2.Padding.Scale * v.AbsoluteSize.Y + uIListLayout2.Padding.Offset
			end
		end

		local v6 = instance.AbsoluteSize.Y - (v5 - instance.AbsolutePosition.Y)
		value:Set(UDim2.new(0.5, 0, 1, -(v6 + 6)))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchList(uIListLayout)
		if v2 == nil then
			return
		end

		v2:Connect(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), follow)
	end

	local function bind(guiObject)
		if guiObject.Name ~= "BottomHolder" or not guiObject:IsA("GuiObject") then
			return
		end

		if v2 ~= nil then
			v2:Destroy()
		end

		v = guiObject
		v2 = maid:Extend()
		v2:Connect(guiObject:GetPropertyChangedSignal("AbsolutePosition"), follow)
		v2:Connect(guiObject:GetPropertyChangedSignal("AbsoluteSize"), follow)
		v2:Connect(guiObject:GetPropertyChangedSignal("Visible"), follow)
		local uIListLayout = guiObject:FindFirstChildOfClass("UIListLayout")

		if uIListLayout ~= nil and v2 ~= nil then
			v2:Connect(uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), follow)
		end

		local aAABottomCenterNotifications = guiObject:FindFirstChild("AAABottomCenterNotifications")
		local uIListLayout2

		if aAABottomCenterNotifications ~= nil then
			uIListLayout2 = aAABottomCenterNotifications:FindFirstChildOfClass("UIListLayout")
		end

		if uIListLayout2 ~= nil and v2 ~= nil then
			v2:Connect(uIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"), follow)
		end

		v2:Connect(guiObject.DescendantAdded, function(uIListLayout3)
			if not uIListLayout3:IsA("UIListLayout") then
				return
			end

			local parent = uIListLayout3.Parent

			if parent == guiObject or parent ~= nil and parent.Name == "AAABottomCenterNotifications" then
				watchList(uIListLayout3) -- equivalent call inferred; original call site unknown
				follow()
			end
		end)
		follow()
	end

	maid:Connect(instance.ChildAdded, bind)
	maid:Connect(instance.ChildRemoved, function(p)
		if p ~= v then
			return
		end

		if v2 ~= nil then
			v2:Destroy()
			v2 = nil
		end

		v = nil
		follow()
	end)
	maid:Connect(instance:GetPropertyChangedSignal("AbsoluteSize"), follow)
	local bottomHolder = instance:FindFirstChild("BottomHolder")

	if bottomHolder ~= nil then
		bind(bottomHolder)
	end

	maid:Create("Frame")({
		Name = "QuestionStrip",
		Parent = instance,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = maid:Animation(value, info),
		Size = UDim2.fromScale(0.24, 0.3),
		ZIndex = 1500,
		BackgroundTransparency = 1,
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = 5
		}),
		maid:Create("UIListLayout")({
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		})
	})
	local v3 = {}
	maid:Connect(PopUpCreator.signal, function(p: number, p2, ...)
		if v3[p] ~= nil then
			v3[p]:Destroy()
			v3[p] = nil
		end

		if p2 ~= nil then
			v3[p] = maid:Extend()
			local v4 = v3[p]:Create("Frame")({
				Name = `Popup{p}`,
				Parent = instance,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 1500,
				CleanDelay = 0.25
			})
			modulesByName[p2.Type](v3[p], v4.Instance, p2, p, ...)
		end
	end)
	maid:Add(function()
		for _, v4 in v3 do
			if v4.IsActive then
				v4:Destroy()
			end
		end
	end)
end