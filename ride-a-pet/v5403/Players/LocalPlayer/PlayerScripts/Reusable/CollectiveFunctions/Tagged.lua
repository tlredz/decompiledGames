local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local blur = Lighting:WaitForChild("Blur")
local SFX = game.SoundService:WaitForChild("SFX")
local main = game.Players.LocalPlayer.PlayerGui:WaitForChild("Main")
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

-- equivalent calls inferred from this helper; original call sites unknown
local function OnHoverStart(p, fn)
	p.MouseEnter:Connect(fn)
	p.SelectionGained:Connect(fn)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function OnHoverEnd(p, fn)
	p.MouseLeave:Connect(fn)
	p.SelectionLost:Connect(fn)
end

local v = {}
CollectionService:GetInstanceRemovedSignal("FollowingHead"):Connect(function(p)
	local v2 = v[p]

	if v2 then
		v2()
	end
end)

for tag, v2 in {
	MovingGradient = function(p)
		p.Offset = Vector2.new(-0.5, 0)
		TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {
			Offset = Vector2.new(0.5, 0)
		}):Play()
	end,
	ComboSound = function(instance)
		if not instance:GetAttribute("BasePlaybackSpeed") then
			instance:SetAttribute("BasePlaybackSpeed", instance.PlaybackSpeed)
		end

		local v2 = 0
		instance:GetAttributeChangedSignal("Play"):Connect(function()
			local now = os.clock()

			if now - v2 < 0.05 then
				return
			end

			v2 = now
			local lastCollectTime = instance:GetAttribute("LastCollectTime") or 0
			local collectCombo = instance:GetAttribute("CollectCombo") or 0
			local basePlaybackSpeed = instance:GetAttribute("BasePlaybackSpeed") or instance.PlaybackSpeed
			local v3 = (now - lastCollectTime > 1.37 and 0 or collectCombo) + 1
			instance:SetAttribute("LastCollectTime", now)
			instance:SetAttribute("CollectCombo", v3)
			local clone = instance:Clone()

			for _, tag in clone:GetTags() do
				clone:RemoveTag(tag)
			end

			clone.Name = instance.Name .. "_Shot"
			clone.PlaybackSpeed = basePlaybackSpeed + math.min((v3 - 1) * 0.05, 1.73)
			clone.Parent = instance.Parent
			clone:Play()
			clone.Ended:Once(function()
				clone:Destroy()
			end)
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, instance.TimeLength / math.max(clone.PlaybackSpeed, 0.1) + 2)
		end)
	end,
	Rainbow = function(instance)
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Changed:Connect(function(p)
			if not instance.Parent then
				numberValue:Destroy()
				return
			end

			local color = Color3.fromHSV(p, 1, 1)

			if instance:IsA("Highlight") then
				instance.FillColor = color
			elseif instance:IsA("ParticleEmitter") then
				instance.Color = ColorSequence.new(color)
			end
		end)
		TweenService:Create(
			numberValue,
			TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
			{
				Value = 1
			}
		):Play()
	end,
	FollowingHead = function(instance)
		if v[instance] then
			return
		end

		local RunService = game:GetService("RunService")
		local localPlayer = game.Players.LocalPlayer
		local cFrame = instance.CFrame
		local position = instance.Position
		instance.Anchored = true
		instance.CanCollide = false
		local renderSteppedConnection = nil
		local destroyingConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Stop()
			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end
		end

		local function Update()
			local character = localPlayer.Character
			local head = character and character:FindFirstChild("Head")

			if not head then
				instance.CFrame = instance.CFrame:Lerp(cFrame, 0.1)
			elseif (position - head.Position).Magnitude <= 15 then
				local cframe = CFrame.lookAt(position, head.Position)
				instance.CFrame = instance.CFrame:Lerp(cframe, 0.1)
			else
				instance.CFrame = instance.CFrame:Lerp(cFrame, 0.1)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Refresh()
			if instance:IsDescendantOf(workspace) then
				if not renderSteppedConnection then
					renderSteppedConnection = RunService.RenderStepped:Connect(Update)
				end
			else
				Stop() -- equivalent call inferred; original call site unknown
			end
		end

		local ancestryChangedConnection = instance.AncestryChanged:Connect(Refresh)

		local function Cleanup()
			Stop() -- equivalent call inferred; original call site unknown
			ancestryChangedConnection:Disconnect()

			if destroyingConnection then
				destroyingConnection:Disconnect()
			end

			v[instance] = nil
		end

		v[instance] = Cleanup
		destroyingConnection = instance.Destroying:Connect(Cleanup)
		Refresh() -- equivalent call inferred; original call site unknown
	end,
	SpinModel = function(instance)
		local pivot = instance:GetPivot()
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 0
		numberValue.Changed:Connect(function(p)
			if instance.Parent then
				instance:PivotTo(pivot * CFrame.Angles(0, math.rad(p), 0))
			else
				numberValue:Destroy()
			end
		end)
		local v2 = math.random(3, 5)
		TweenService:Create(
			numberValue,
			TweenInfo.new(v2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
			{
				Value = 360
			}
		):Play()
	end,
	Floating = function(instance)
		local primaryPart = instance.PrimaryPart or instance:WaitForChild("Handle")
		local cFrame = primaryPart.CFrame + createVector(0, 1, 0)
		TweenService:Create(
			primaryPart,
			TweenInfo.new(math.random(50, 150) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
			{
				CFrame = cFrame
			}
		):Play()
	end,
	FocusFrame = function(instance)
		local localPlayer = game.Players.LocalPlayer
		local backpackGui = localPlayer.PlayerGui:WaitForChild("BackpackGui")
		local blur2 = Lighting:WaitForChild("Blur")
		local currentCamera = workspace.CurrentCamera

		-- equivalent calls inferred from this helper; original call sites unknown
		local function AdjustDepth(p)
			local v2 = math.max((localPlayer:GetAttribute("FocusFrameDepth") or 0) + p, 0)
			localPlayer:SetAttribute("FocusFrameDepth", v2)
			return v2
		end

		local tween = TweenService:Create(blur2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		})
		local tween2 = TweenService:Create(blur2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 50
		})
		local tween3 = TweenService:Create(
			currentCamera,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				FieldOfView = 70
			}
		)
		local tween4 = TweenService:Create(
			currentCamera,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				FieldOfView = 60
			}
		)
		local v2 = instance.Visible and instance:GetAttribute("UIClosing") ~= true

		local function Refresh()
			local v3 = instance.Visible and instance:GetAttribute("UIClosing") ~= true

			if v3 == v2 then
				return
			end

			v2 = v3

			if v3 == false then
				if AdjustDepth(-1) > 0 then
					return
				end

				for _, v4 in CollectionService:GetTagged("HUD") do
					v4.Visible = true
				end

				tween:Play()

				if not localPlayer:GetAttribute("IsRiding") then
					tween3:Play()
				end

				backpackGui.Enabled = true
			else
				if AdjustDepth(1) > 1 then
					return
				end

				for _, v4 in CollectionService:GetTagged("HUD") do
					v4.Visible = false
				end

				backpackGui.Enabled = false
				tween2:Play()
				tween4:Play()
			end
		end

		instance:GetPropertyChangedSignal("Visible"):Connect(Refresh)
		instance:GetAttributeChangedSignal("UIClosing"):Connect(Refresh)
	end,
	ExpandingText = function(instance)
		local expandScalePerCharacter = instance:GetAttribute("ExpandScalePerCharacter")
		local expandOffsetPerCharacter = instance:GetAttribute("ExpandOffsetPerCharacter")

		if not expandScalePerCharacter then
			local v2 = math.max(utf8.len(instance.Text) or #instance.Text, 1)
			expandScalePerCharacter = instance.Size.X.Scale / v2
			expandOffsetPerCharacter = instance.Size.X.Offset / v2
			instance:SetAttribute("ExpandScalePerCharacter", expandScalePerCharacter)
			instance:SetAttribute("ExpandOffsetPerCharacter", expandOffsetPerCharacter)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Update()
			local v2 = math.max(utf8.len(instance.Text) or #instance.Text, 1)
			instance.Size = UDim2.new(
				expandScalePerCharacter * v2,
				(expandOffsetPerCharacter or 0) * v2,
				instance.Size.Y.Scale,
				instance.Size.Y.Offset
			)
		end

		Update() -- equivalent call inferred; original call site unknown
		instance:GetPropertyChangedSignal("Text"):Connect(Update)
	end,
	TextShadow = function(parent)
		if parent.Name:match("_Shadow$") or parent.Name:match("_Face$") then
			return
		end

		local parent2 = parent.Parent

		if not parent2 then
			return
		end

		local color = Color3.fromRGB(0, 0, 0)
		local layerCollector = parent:FindFirstAncestorWhichIsA("LayerCollector")
		local v2

		if layerCollector == nil then
			v2 = false
		else
			v2 = not layerCollector:IsA("ScreenGui")
		end

		if parent2:FindFirstChildWhichIsA("UIGridStyleLayout") then
			local child = parent2:FindFirstChild(parent.Name .. "_Shadow")

			if child then
				child:Destroy()
			end

			local child2 = parent:FindFirstChild(parent.Name .. "_Shadow")
			local child3 = parent:FindFirstChild(parent.Name .. "_Face")

			if not (child2 and child3) then
				if child2 then
					child2:Destroy()
				end

				if child3 then
					child3:Destroy()
				end

				local function MakeLayer(p)
					local clone = parent:Clone()
					clone.Name = parent.Name .. p

					for _, tag in clone:GetTags() do
						clone:RemoveTag(tag)
					end

					clone.AnchorPoint = Vector2.zero
					clone.Position = UDim2.fromScale(0, 0)
					clone.Size = UDim2.fromScale(1, 1)
					clone.Rotation = 0
					clone.BackgroundTransparency = 1
					clone.TextTransparency = 0
					clone.Visible = true
					return clone
				end

				child3 = MakeLayer("_Face")
				child2 = MakeLayer("_Shadow")
				child2.TextColor3 = color
				child2.TextStrokeTransparency = 1
				child2.ZIndex = 1
				child3.ZIndex = 2
				child2.Parent = parent
				child3.Parent = parent
			end

			parent.TextTransparency = 1
			parent.TextStrokeTransparency = 1
			local uIStroke = parent:FindFirstChildOfClass("UIStroke")

			if uIStroke then
				uIStroke.Enabled = false
			end

			if v2 then
				child2.Position = UDim2.fromScale(0, 0.05)
			else
				-- equivalent calls inferred from this helper; original call sites unknown
				local function UpdateOffset()
					local v3 = math.max(1, (math.round(parent.AbsoluteSize.Y * 0.05)))
					child2.Position = UDim2.fromOffset(0, v3)
				end

				UpdateOffset() -- equivalent call inferred; original call site unknown
				parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateOffset)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function SyncText()
				child2.Text = parent.Text
				child3.Text = parent.Text
			end

			SyncText() -- equivalent call inferred; original call site unknown
			parent:GetPropertyChangedSignal("Text"):Connect(SyncText)
			return child2
		else
			local clone = parent2:FindFirstChild(parent.Name .. "_Shadow")

			if not clone then
				clone = parent:Clone()
				clone.Name = parent.Name .. "_Shadow"
				clone.ZIndex = parent.ZIndex - 1
				clone.TextColor3 = color
				clone.TextStrokeTransparency = 1
				clone.BackgroundTransparency = 1
			end

			local function UpdatePosition()
				if v2 then
					clone.Position = parent.Position + UDim2.fromScale(0, parent.Size.Y.Scale * 0.05)
					return
				end

				local v3 = math.max(1, (math.round(parent.AbsoluteSize.Y * 0.05)))
				clone.Position = parent.Position + UDim2.fromOffset(0, v3)
			end

			UpdatePosition()

			if not v2 then
				parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePosition)
			end

			parent:GetPropertyChangedSignal("Position"):Connect(UpdatePosition)
			clone.Size = parent.Size
			parent:GetPropertyChangedSignal("Size"):Connect(function()
				clone.Size = parent.Size
				UpdatePosition()
			end)
			clone.Text = parent.Text
			parent:GetPropertyChangedSignal("Text"):Connect(function()
				clone.Text = parent.Text
			end)
			clone.Visible = parent.Visible
			parent:GetPropertyChangedSignal("Visible"):Connect(function()
				clone.Visible = parent.Visible
			end)
			clone.Parent = parent2
			return clone
		end
	end,
	Spin = function(p)
		TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 0), {
			Rotation = 360
		}):Play()
	end,
	TiltLoop = function(p)
		p.Rotation = -7
		TweenService:Create(p, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0), {
			Rotation = 7
		}):Play()
	end,
	EnlargeOnHover = function(parent)
		local v2 = parent:FindFirstChildOfClass("UIScale")

		if not v2 then
			v2 = Instance.new("UIScale")
			v2.Scale = 1
			v2.Parent = parent
		end

		local tween = TweenService:Create(v2, tweenInfo, {
			Scale = 1.15
		})
		local tween2 = TweenService:Create(v2, tweenInfo, {
			Scale = 1
		})

		local function fn()
			SFX.UI.Hover:Play()
			tween:Play()
		end

		OnHoverStart(parent, fn) -- equivalent call inferred; original call site unknown

		local function fn2()
			tween2:Play()
		end

		OnHoverEnd(parent, fn2) -- equivalent call inferred; original call site unknown
	end,
	RotateOnHover = function(p)
		local rotation = p.Rotation
		local tween = TweenService:Create(p, tweenInfo, {
			Rotation = rotation + 3
		})
		local tween2 = TweenService:Create(p, tweenInfo, {
			Rotation = rotation
		})

		local function fn()
			tween:Play()
		end

		OnHoverStart(p, fn) -- equivalent call inferred; original call site unknown

		local function fn2()
			tween2:Play()
		end

		OnHoverEnd(p, fn2) -- equivalent call inferred; original call site unknown
	end,
	Bouncing = function(instance)
		local position = instance.Position
		local uILayout = instance.Parent and instance.Parent:FindFirstChildWhichIsA("UILayout")

		if uILayout then
			warn(string.format(
				"Bouncing: %s is laid out by a %s, which overrides Position - the bounce will not be visible",
				instance:GetFullName(),
				uILayout.ClassName
			))
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Lifted(p: number)
			local v2 = math.max(instance.AbsoluteSize.Y * 0.35 * p, 1)
			return UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset - v2)
		end

		local tweenInfo3 = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfo4 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.spawn(function()
			while instance.Parent do
				if instance.Visible then
					local v6 = TweenService:Create(instance, tweenInfo3, {
						Position = Lifted(1)
					})
					v6:Play()
					v6.Completed:Wait()
					local tween = TweenService:Create(instance, tweenInfo4, {
						Position = position
					})
					tween:Play()
					tween.Completed:Wait()
					local v10 = TweenService:Create(
						instance,
						TweenInfo.new(0.11200000000000002, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Lifted(0.4)
						}
					)
					v10:Play()
					v10.Completed:Wait()
					local tween2 = TweenService:Create(
						instance,
						TweenInfo.new(0.08800000000000001, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Position = position
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
				else
					instance.Position = position
				end

				task.wait(0.45)
			end
		end)
	end,
	DarkenOnHover = function(guiObject)
		local v2 = guiObject:IsA("ImageButton") and "ImageColor3" or guiObject:IsA("ImageLabel") and "ImageColor3" or "BackgroundColor3"
		local flag = false
		local v3 = guiObject[v2]

		local function fn()
			if flag then
				return
			end

			flag = true
			v3 = guiObject[v2]
			TweenService:Create(guiObject, tweenInfo, {
				[v2] = Color3.new(v3.R * 0.75, v3.G * 0.75, v3.B * 0.75)
			}):Play()
		end

		OnHoverStart(guiObject, fn) -- equivalent call inferred; original call site unknown

		local function fn2()
			if not flag then
				return
			end

			flag = false
			TweenService:Create(guiObject, tweenInfo, {
				[v2] = v3
			}):Play()
		end

		OnHoverEnd(guiObject, fn2) -- equivalent call inferred; original call site unknown
	end,
	ClickSound = function(p)
		p.Activated:Connect(function()
			SFX.Click:Play()
		end)
	end,
	ShrinkAndPop = function(parent)
		local v2 = false
		local v3 = parent:FindFirstChildOfClass("UIScale")

		if not v3 then
			v3 = Instance.new("UIScale")
			v3.Scale = 1
			v3.Parent = parent
		end

		local tween = TweenService:Create(v3, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = 0.8
		})
		local tween2 = TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
			Scale = 1
		})
		parent.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v2 = true
				tween:Play()
			end
		end)
		parent.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				v2 = false
				tween2:Play()
			end
		end)

		local function fn()
			v2 = false
			tween2:Play()
		end

		OnHoverEnd(parent, fn) -- equivalent call inferred; original call site unknown
	end,
	AutoAdjust = function(scrollingFrame)
		if not scrollingFrame:IsA("ScrollingFrame") then
			warn(string.format(
				"AutoAdjust: %s is a %s, not a ScrollingFrame",
				scrollingFrame:GetFullName(),
				scrollingFrame.ClassName
			))
			return
		end

		local autoAdjustMargin = scrollingFrame:GetAttribute("AutoAdjustMargin") or 4
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Horizontal()
			return scrollingFrame.ScrollingDirection == Enum.ScrollingDirection.X
		end

		local function FarEdge(folder)
			local v2 = Horizontal() and "X" or "Y"
			local v3 = folder.AbsolutePosition[v2] + folder.AbsoluteSize[v2]

			for _, guiObject in folder:GetDescendants() do
				if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
					continue
				end

				local v4 = guiObject.AbsolutePosition[v2] + guiObject.AbsoluteSize[v2]

				if v3 < v4 then
					v3 = v4
				end
			end

			return v3
		end

		local function Fit()
			if not scrollingFrame.Parent then
				return
			end

			local v2 = Horizontal() and "X" or "Y"
			local v3 = scrollingFrame.AbsolutePosition[v2] - scrollingFrame.CanvasPosition[v2]
			local v4 = v3
			local v5 = false

			for _, guiObject in scrollingFrame:GetChildren() do
				if not (guiObject:IsA("GuiObject") and guiObject.Visible) then
					continue
				end

				v5 = true
				local farEdge = FarEdge(guiObject)

				if v4 < farEdge then
					v4 = farEdge
				end
			end

			local uIPadding = scrollingFrame:FindFirstChildOfClass("UIPadding")
			local v6

			if uIPadding then
				local paddingRight = Horizontal() and uIPadding.PaddingRight or uIPadding.PaddingBottom
				v6 = paddingRight.Offset + scrollingFrame.AbsoluteSize[v2] * paddingRight.Scale
			else
				v6 = 0
			end

			local v7 = v5 and v4 - v3 + v6 + autoAdjustMargin or 0
			local uDim = Horizontal() and UDim2.fromOffset(v7, 0) or UDim2.fromOffset(0, v7)

			if scrollingFrame.CanvasSize ~= uDim then
				scrollingFrame.CanvasSize = uDim
			end
		end

		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Queue()
			if flag then
				return
			end

			flag = true
			task.defer(function()
				flag = false
				Fit()
			end)
		end

		local v2 = {}

		local function Hook(guiObject)
			if not guiObject:IsA("GuiObject") or v2[guiObject] then
				return
			end

			v2[guiObject] = true
			guiObject:GetPropertyChangedSignal("Visible"):Connect(Queue)
			guiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(Queue)
			guiObject:GetPropertyChangedSignal("AbsolutePosition"):Connect(Queue)
			Queue() -- equivalent call inferred; original call site unknown
		end

		for _, child in scrollingFrame:GetChildren() do
			Hook(child)
		end

		scrollingFrame.ChildAdded:Connect(Hook)
		scrollingFrame.ChildRemoved:Connect(function(child)
			v2[child] = nil
			Queue() -- equivalent call inferred; original call site unknown
		end)
		scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(Queue)
		local uIGridStyleLayout = scrollingFrame:FindFirstChildWhichIsA("UIGridStyleLayout")

		if uIGridStyleLayout then
			uIGridStyleLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Queue)
		end

		if not flag then
			flag = true
			task.defer(function()
				flag = false
				Fit()
			end)
		end
	end,
	SlideUpOpen = function(instance)
		local position = instance.Position
		local uDim = UDim2.new(position.X.Scale, position.X.Offset, 1.5, 0)
		instance.Position = uDim
		instance.Visible = false
		local darkFrame = main:FindFirstChild("DarkFrame")
		local tween = TweenService:Create(blur, tweenInfo2, {
			Size = 20
		})
		local tween2 = TweenService:Create(blur, tweenInfo2, {
			Size = 0
		})
		local v2, v3

		if darkFrame then
			v2 = TweenService:Create(darkFrame, tweenInfo2, {
				BackgroundTransparency = 0.2
			})
			v3 = TweenService:Create(darkFrame, tweenInfo2, {
				BackgroundTransparency = 1
			})
		else
			v2 = nil
			v3 = nil
		end

		local tween3 = TweenService:Create(instance, tweenInfo2, {
			Position = position
		})
		local tween4 = TweenService:Create(instance, tweenInfo2, {
			Position = uDim
		})
		instance:GetAttributeChangedSignal("IsOpen"):Connect(function()
			if instance:GetAttribute("IsOpen") then
				for _, v4 in CollectionService:GetTagged("SlideUpOpen") do
					if v4 == instance then
						continue
					end

					v4.Visible = false
					v4:SetAttribute("IsOpen", false)
				end

				instance.Visible = true

				if darkFrame then
					v2:Play()
				end

				tween:Play()
				tween3:Play()
			else
				tween4:Play()

				if v3 and instance.Visible == true then
					v3:Play()
				end

				tween2:Play()
				task.delay(0.2, function()
					if not instance:GetAttribute("IsOpen") then
						instance.Visible = false
					end
				end)
			end
		end)
	end
} do
	local v3 = v2
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
		v3(p)
	end)

	for _, v4 in CollectionService:GetTagged(tag) do
		v2(v4)
	end
end