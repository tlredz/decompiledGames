local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Utility = {}
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function Utility.createStagger(p, callback, p2)
	local flag = false
	local flag2 = false
	local v = (not p or p == 0) and 0.01 or p
	local staggeredCallback

	staggeredCallback = function(...)
		if flag then
			flag2 = true
			return
		end

		local v2 = table.pack(...)
		flag = true
		flag2 = false
		task.spawn(function()
			if p2 then
				task.wait(v)
			end

			callback(table.unpack(v2))
		end)
		task.delay(v, function()
			flag = false

			if flag2 then
				staggeredCallback(table.unpack(v2))
			end
		end)
	end

	return staggeredCallback
end

function Utility.round(p)
	return (math.floor(p + 0.5))
end

function Utility:reverseTable()
	for i = 1, math.floor(#self / 2) do
		local v = #self - i + 1
		local v2 = self[v]
		local v3 = self[i]
		self[i] = v2
		self[v] = v3
	end
end

function Utility.copyTable(list)
	assert(type(list) == "table", "First argument must be a table")
	local result = table.create(#list)

	for k, v in pairs(list) do
		if type(v) == "table" then
			result[k] = Utility.copyTable(v)
		else
			result[k] = v
		end
	end

	return result
end

local v = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"<",
	">",
	"?",
	"@",
	"{",
	"}",
	"[",
	"]",
	"!",
	"(",
	")",
	"=",
	"+",
	"~",
	"#"
}

function Utility.generateUID(value)
	local v2 = v
	local v3 = #v2
	local v4 = ""

	for _ = 1, value or 8 do
		v4 ..= v2[math.random(1, v3)]
	end

	return v4
end

local v2 = {}

function Utility:setVisible(visible, p)
	local v3 = v2[self]

	if not v3 then
		v3 = {}
		v2[self] = v3
		self.Destroying:Once(function()
			v2[self] = nil
		end)
	end

	if visible then
		v3[p] = nil
	else
		v3[p] = true
	end

	if visible then
		for _, _ in pairs(v3) do
			visible = false
			break
		end
	end

	self.Visible = visible
end

function Utility.formatStateName(value)
	return string.upper((string.sub(value, 1, 1))) .. string.lower((string.sub(value, 2)))
end

function Utility.localPlayerRespawned(onCharacterRemoving)
	localPlayer.CharacterRemoving:Connect(onCharacterRemoving)
end

function Utility.getClippedContainer(parent)
	local v3 = parent:FindFirstChild("ClippedContainer")

	if not v3 then
		v3 = Instance.new("Folder")
		v3.Name = "ClippedContainer"
		v3.Parent = parent
	end

	return v3
end

local v3 = require3(script.Parent.Packages.Janitor)
local GuiService = game:GetService("GuiService")

function Utility.clipOutside(data, uDims)
	local v4 = data.janitor:add(v3.new())
	uDims.Destroying:Once(function()
		v4:Destroy()
	end)
	data.janitor:add(uDims)
	local parent = uDims.Parent
	local parent2 = v4:add(Instance.new("Frame"))
	parent2:SetAttribute("IsAClippedClone", true)
	parent2.Name = uDims.Name
	parent2.AnchorPoint = uDims.AnchorPoint
	parent2.Size = uDims.Size
	parent2.Position = uDims.Position
	parent2.BackgroundTransparency = 1
	parent2.LayoutOrder = uDims.LayoutOrder
	parent2.Parent = parent
	local objectValue = Instance.new("ObjectValue")
	objectValue.Name = "OriginalInstance"
	objectValue.Value = uDims
	objectValue.Parent = parent2
	local clone = objectValue:Clone()
	uDims:SetAttribute("HasAClippedClone", true)
	clone.Name = "ClippedClone"
	clone.Value = parent2
	clone.Parent = uDims
	local v6 = nil
	local v7 = require3(data.iconModule)
	local container = v7.container

	local function updateScreenGui()
		local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")

		if not string.match(screenGui.Name, "Clipped") then
			screenGui = container[screenGui.Name .. "Clipped"]
		end

		v6 = screenGui
		uDims.AnchorPoint = Vector2.new(0, 0)
		uDims.Parent = Utility.getClippedContainer(v6)
	end

	v4:add(data.alignmentChanged:Connect(updateScreenGui))
	updateScreenGui()

	for _, uIAspectRatioConstraint in pairs(uDims:GetChildren()) do
		if not uIAspectRatioConstraint:IsA("UIAspectRatioConstraint") then
			continue
		end

		local clone_2 = uIAspectRatioConstraint:Clone()
		clone_2.Parent = parent2
	end

	local widget = data.widget
	local v8 = false
	local ignoreVisibilityUpdater = uDims:GetAttribute("IgnoreVisibilityUpdater")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateVisibility()
		if ignoreVisibilityUpdater then
			return
		end

		local visible = widget.Visible

		if v8 then
			visible = false
		end

		Utility.setVisible(uDims, visible, "ClipHandler")
	end

	v4:add(widget:GetPropertyChangedSignal("Visible"):Connect(updateVisibility))
	local v9 = nil
	local checkIfOutsideParentXBounds

	checkIfOutsideParentXBounds = function()
		task.defer(function()
			local scrollingFrame = nil
			local UID = data.UID

			if uDims:GetAttribute("ClipToJoinedParent") then
				local parentIconUID = UID

				for _ = 1, 10 do
					local iconByUID = v7.getIconByUID(parentIconUID)

					if not iconByUID then
						break
					end

					local joinedFrame = iconByUID.joinedFrame
					parentIconUID = iconByUID.parentIconUID

					if not joinedFrame then
						break
					end

					if joinedFrame and joinedFrame.Name == "DropdownScroller" then
						scrollingFrame = joinedFrame
						break
					else
						scrollingFrame = joinedFrame
					end
				end
			end

			if scrollingFrame then
				local absolutePosition = uDims.AbsolutePosition
				local halfAbsoluteSize = uDims.AbsoluteSize / 2
				local absolutePosition2 = scrollingFrame.AbsolutePosition
				local absoluteSize = scrollingFrame.AbsoluteSize
				local v11 = absolutePosition + halfAbsoluteSize
				local v12 = v11.X < absolutePosition2.X
				local v13 = v11.X > absolutePosition2.X + absoluteSize.X
				local v14 = v11.Y < absolutePosition2.Y
				local v15 = v11.Y > absolutePosition2.Y + absoluteSize.Y
				local v16 = v12 or v13 or v14 or v15

				if v16 ~= v8 then
					v8 = v16
					updateVisibility() -- equivalent call inferred; original call site unknown
				end

				if scrollingFrame:IsA("ScrollingFrame") and v9 ~= scrollingFrame then
					v9 = scrollingFrame
					v4:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
						checkIfOutsideParentXBounds()
					end), "Disconnect", "TrackUtilityScroller-" .. UID)
				end
			else
				v8 = false
				updateVisibility() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	local currentCamera = workspace.CurrentCamera
	local additionalOffsetX = uDims:GetAttribute("AdditionalOffsetX") or 0

	local function trackProperty(p)
		local v10 = "Absolute" .. p

		local function updateProperty()
			local v11 = parent2[v10]
			local uDim = UDim2.fromOffset(v11.X, v11.Y)

			if p == "Position" then
				local v12 = currentCamera.ViewportSize.X - uDims.AbsoluteSize.X - 4
				local offset = uDim.X.Offset

				if offset < 4 then
					offset = 4
				elseif v12 < offset then
					offset = v12
				end

				local uDim2 = UDim2.fromOffset(offset, uDim.Y.Offset)
				local topbarInset = GuiService.TopbarInset
				local X = workspace.CurrentCamera.ViewportSize.X
				local X2 = v6.AbsoluteSize.X
				local X3 = v6.AbsolutePosition.X

				if not v7.isOldTopbar then
					X3 = X - X2 - 0
				end

				local v13 = X3 - additionalOffsetX
				uDim = uDim2 + UDim2.fromOffset(-v13, topbarInset.Height)
				task.defer(function()
					local scrollingFrame = nil
					local UID = data.UID

					if uDims:GetAttribute("ClipToJoinedParent") then
						local parentIconUID = UID

						for _ = 1, 10 do
							local iconByUID = v7.getIconByUID(parentIconUID)

							if not iconByUID then
								break
							end

							local joinedFrame = iconByUID.joinedFrame
							parentIconUID = iconByUID.parentIconUID

							if not joinedFrame then
								break
							end

							if joinedFrame and joinedFrame.Name == "DropdownScroller" then
								scrollingFrame = joinedFrame
								break
							else
								scrollingFrame = joinedFrame
							end
						end
					end

					if scrollingFrame then
						local absolutePosition = uDims.AbsolutePosition
						local halfAbsoluteSize = uDims.AbsoluteSize / 2
						local absolutePosition2 = scrollingFrame.AbsolutePosition
						local absoluteSize = scrollingFrame.AbsoluteSize
						local v15 = absolutePosition + halfAbsoluteSize
						local v16 = v15.X < absolutePosition2.X
						local v17 = v15.X > absolutePosition2.X + absoluteSize.X
						local v18 = v15.Y < absolutePosition2.Y
						local v19 = v15.Y > absolutePosition2.Y + absoluteSize.Y
						local v20 = v16 or v17 or v18 or v19

						if v20 ~= v8 then
							v8 = v20
							updateVisibility() -- equivalent call inferred; original call site unknown
						end

						if scrollingFrame:IsA("ScrollingFrame") and v9 ~= scrollingFrame then
							v9 = scrollingFrame
							v4:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
								checkIfOutsideParentXBounds()
							end), "Disconnect", "TrackUtilityScroller-" .. UID)
						end
					else
						v8 = false
						updateVisibility() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			uDims[p] = uDim
		end

		local stagger = Utility.createStagger(0.01, updateProperty)
		v4:add(parent2:GetPropertyChangedSignal(v10):Connect(stagger))
		v4:add(parent2:GetAttributeChangedSignal("ForceUpdate"):Connect(function()
			stagger()
		end))
		local stagger2 = Utility.createStagger(0.5, updateProperty, true)
		v4:add(parent2:GetPropertyChangedSignal(v10):Connect(stagger2))

		if p == "Position" then
			v4:add(v6:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				stagger()
			end))
		end
	end

	task.delay(0.1, checkIfOutsideParentXBounds)
	task.defer(function()
		local scrollingFrame = nil
		local UID = data.UID

		if uDims:GetAttribute("ClipToJoinedParent") then
			local parentIconUID = UID

			for _ = 1, 10 do
				local iconByUID = v7.getIconByUID(parentIconUID)

				if not iconByUID then
					break
				end

				local joinedFrame = iconByUID.joinedFrame
				parentIconUID = iconByUID.parentIconUID

				if not joinedFrame then
					break
				end

				if joinedFrame and joinedFrame.Name == "DropdownScroller" then
					scrollingFrame = joinedFrame
					break
				else
					scrollingFrame = joinedFrame
				end
			end
		end

		if scrollingFrame then
			local absolutePosition = uDims.AbsolutePosition
			local halfAbsoluteSize = uDims.AbsoluteSize / 2
			local absolutePosition2 = scrollingFrame.AbsolutePosition
			local absoluteSize = scrollingFrame.AbsoluteSize
			local v11 = absolutePosition + halfAbsoluteSize
			local v12 = v11.X < absolutePosition2.X
			local v13 = v11.X > absolutePosition2.X + absoluteSize.X
			local v14 = v11.Y < absolutePosition2.Y
			local v15 = v11.Y > absolutePosition2.Y + absoluteSize.Y
			local v16 = v12 or v13 or v14 or v15

			if v16 ~= v8 then
				v8 = v16
				updateVisibility() -- equivalent call inferred; original call site unknown
			end

			if scrollingFrame:IsA("ScrollingFrame") and v9 ~= scrollingFrame then
				v9 = scrollingFrame
				v4:add(scrollingFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
					checkIfOutsideParentXBounds()
				end), "Disconnect", "TrackUtilityScroller-" .. UID)
			end
		else
			v8 = false
			updateVisibility() -- equivalent call inferred; original call site unknown
		end
	end)
	updateVisibility() -- equivalent call inferred; original call site unknown
	trackProperty("Position")
	v4:add(uDims:GetPropertyChangedSignal("Visible"):Connect(function() end))

	if uDims:GetAttribute("TrackCloneSize") then
		trackProperty("Size")
	else
		v4:add(uDims:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			local absoluteSize = uDims.AbsoluteSize
			parent2.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
		end))
	end

	return parent2
end

function Utility:joinFeature(object2, UIDs, joinedFrame)
	local joinJanitor = self.joinJanitor
	joinJanitor:clean()

	if not joinedFrame then
		self:leave()
		return
	end

	self.parentIconUID = object2.UID
	self.joinedFrame = joinedFrame

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateAlignent()
		local alignment = object2.alignment
		self:setAlignment(alignment == "Center" and "Left" or alignment, true)
	end

	joinJanitor:add(object2.alignmentChanged:Connect(updateAlignent))
	updateAlignent() -- equivalent call inferred; original call site unknown
	self:modifyTheme({ "IconButton", "BackgroundTransparency", 1 }, "JoinModification")
	self:modifyTheme({ "ClickRegion", "Active", false }, "JoinModification")

	if object2.childModifications then
		task.defer(function()
			self:modifyTheme(object2.childModifications, object2.childModificationsUID)
		end)
	end

	local instance = self:getInstance("ClickRegion")

	local function makeSelectable()
		instance.Selectable = object2.isSelected
	end

	joinJanitor:add(object2.toggled:Connect(makeSelectable))
	task.defer(makeSelectable)
	joinJanitor:add(function()
		instance.Selectable = true
	end)
	local UID = self.UID
	table.insert(UIDs, UID)
	object2:autoDeselect(false)
	object2.childIconsDict[UID] = true

	if not object2.isEnabled then
		object2:setEnabled(true)
	end

	self.joinedParent:Fire(object2)
	joinJanitor:add(function()
		if not self.joinedFrame then
			return
		end

		for k, v4 in pairs(UIDs) do
			if v4 ~= UID then
				continue
			end

			table.remove(UIDs, k)
			break
		end

		local iconByUID = require3(self.iconModule).getIconByUID(self.parentIconUID)

		if not iconByUID then
			return
		end

		self:setAlignment(self.originalAlignment)
		self.parentIconUID = false
		self.joinedFrame = false
		self:removeModification("JoinModification")
		local v4 = true
		local childIconsDict = iconByUID.childIconsDict
		childIconsDict[UID] = nil

		for _, _ in pairs(childIconsDict) do
			v4 = false
			break
		end

		if v4 and not iconByUID.isAnOverflow then
			iconByUID:setEnabled(false)
		end

		updateAlignent() -- equivalent call inferred; original call site unknown
	end)
end

return Utility