local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
require(packages.Promise)
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local _ = Players.LocalPlayer.PlayerGui
local notification = ReplicatedStorage:WaitForChild("events"):WaitForChild("notification")
local remoteEvent = Net:RemoteEvent("Notification", -1)
local remoteEvent2 = Net:RemoteEvent("FancyNotification", -1)
local remoteEvent3 = Net:RemoteEvent("NavigateNotification", -1)
local remoteEvent4 = Net:RemoteEvent("Reflection", -1)
local module = require("./HudController")
local NotificationController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function FastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	return tween
end

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function StripLayouts(folder)
	for _, uIGridStyleLayout in folder:GetDescendants() do
		if uIGridStyleLayout:IsA("UIGridStyleLayout") then
			uIGridStyleLayout:Destroy()
		end
	end
end

local function CollectFade(instance, list)
	if instance:IsA("GuiObject") and instance.BackgroundTransparency < 1 then
		table.insert(list, {
			Inst = instance,
			Prop = "BackgroundTransparency",
			Rest = instance.BackgroundTransparency
		})
	end

	if instance:IsA("TextLabel") or instance:IsA("TextButton") then
		table.insert(list, {
			Inst = instance,
			Prop = "TextTransparency",
			Rest = instance.TextTransparency
		})
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		table.insert(list, {
			Inst = instance,
			Prop = "ImageTransparency",
			Rest = instance.ImageTransparency
		})
	elseif instance:IsA("UIStroke") then
		table.insert(list, {
			Inst = instance,
			Prop = "Transparency",
			Rest = instance.Transparency
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CollectFadeTree(folder, p)
	CollectFade(folder, p)

	for _, descendant in folder:GetDescendants() do
		CollectFade(descendant, p)
	end
end

local function FadeIn(items, tweenInfo3)
	for _, item in items do
		item.Inst[item.Prop] = 1
		local tween = TweenService:Create(item.Inst, tweenInfo3, {
			[item.Prop] = item.Rest
		})
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end
end

local function FadeOut(items, tweenInfo3)
	for _, item in items do
		local tween = TweenService:Create(item.Inst, tweenInfo3, {
			[item.Prop] = 1
		})
		tween:Play()
		tween.Completed:Once(function()
			tween:Destroy()
		end)
	end
end

local function RemoveFadeTargets(_fade, fade)
	local v = {}

	for _, item in fade do
		v[item] = true
	end

	for i = #_fade, 1, -1 do
		if v[_fade[i]] then
			table.remove(_fade, i)
		end
	end
end

NotificationController._readySignal = Signal.new()
NotificationController._isReady = true
NotificationController._pauses = {}
NotificationController._reflections = {}
NotificationController._reflectionOrder = {}
NotificationController._reflectionConnection = nil

function NotificationController:AwaitReady()
	if not self._isReady then
		self._readySignal:Wait()
	end
end

function NotificationController:PauseNotifications(p: string, duration: number?)
	self._pauses[p] = true
	self._isReady = false

	if duration then
		task.delay(duration, function()
			self:UnpauseNotifications(p)
		end)
	end
end

function NotificationController:UnpauseNotifications(p: string)
	if self._pauses[p] then
		self._pauses[p] = nil
		self._isReady = next(self._pauses) == nil

		if self._isReady then
			self._readySignal:Fire()
		end
	end
end

function NotificationController:Notify(p: string, value: number?, sound)
	self:AwaitReady()

	if sound and typeof(sound) == "string" then
		sound = ReplicatedStorage.resources.sounds:FindFirstChild(sound, true)
	end

	if sound and not sound:IsA("Sound") then
		sound = nil
	end

	local safeZone = module:GetSafeZone()

	if not safeZone then
		return
	end

	local announcements = safeZone:FindFirstChild("announcements")

	if not announcements then
		return
	end

	local v = value or 5
	local clone = script.Template:Clone()
	clone.Main.TextTransparency = 1
	clone.Main.TextStrokeTransparency = 1
	clone.Shine.ImageTransparency = 1
	clone.Main.Position = UDim2.new(0.5, 0, -0.3, 0)
	clone.Main.Text = tostring(p)
	clone.Parent = announcements
	clone.Visible = true

	if sound then
		sound:Play()
	end

	local v2 = v * 0.2
	local v3 = v * 0.7
	local v4 = v * 0.1
	FastTween(clone.Icon, TweenInfo.new(v2 * 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Main, TweenInfo.new(v2 * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		TextTransparency = 0,
		Position = UDim2.new(0.5, 0, 0, 0),
		TextStrokeTransparency = 0.58
	}) -- equivalent call inferred; original call site unknown
	FastTween(clone.Shine, TweenInfo.new(v2 * 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		ImageTransparency = 0.1
	}) -- equivalent call inferred; original call site unknown
	task.delay(v3, function()
		FastTween(clone.Main, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			TextTransparency = 1,
			Position = UDim2.new(0.5, 0, -0.3, 0),
			TextStrokeTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		FastTween(clone.Shine, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		FastTween(clone.Icon, TweenInfo.new(v4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			ImageTransparency = 1
		}) -- equivalent call inferred; original call site unknown
		Debris:AddItem(clone, v4)
	end)
	return clone
end

function NotificationController:FancyNotify(data)
	self:AwaitReady()
	local announcements = module:GetSafeZone():WaitForChild("announcements")
	local appearTime = data.AppearTime or 0.4
	local lifetime = data.Lifetime or 5
	local disappearTime = data.DisappearTime or 1
	local tweenInfo3 = TweenInfo.new(appearTime, Enum.EasingStyle.Linear)
	local tweenInfo4 = TweenInfo.new(disappearTime, Enum.EasingStyle.Linear)
	local clone = script.FancyTemplate:Clone()
	local container = clone.container
	local maid = Trove.new()

	for k, component in data.Components do
		if component.Type == "Icon" then
			local clone2 = script.FancyComponents.icon:Clone()
			clone2.LayoutOrder = k
			clone2.Image = component.AssetId
			clone2.ImageColor3 = component.Color or Color3.new(1, 1, 1)
			clone2.Size = UDim2.fromScale(1, component.Size or 1.1)
			clone2.ScaleType = component.ScaleType or Enum.ScaleType.Fit
			clone2.UIAspectRatioConstraint.AspectRatio = component.AspectRatio or 1
			clone2.ImageTransparency = 1
			TweenService:Create(clone2, tweenInfo3, {
				ImageTransparency = component.Transparency or 0
			}):Play()
			clone2.Parent = container.content
			maid:Add(function()
				TweenService:Create(clone2, tweenInfo4, {
					ImageTransparency = 1
				}):Play()
			end)
		elseif component.Type == "Text" then
			local clone2 = script.FancyComponents.text:Clone()
			clone2.LayoutOrder = k
			clone2.Text = component.Text

			if component.Font then
				clone2.FontFace = component.Font
			end

			clone2.Size = UDim2.fromScale(0, component.Size or 1)
			clone2.UIStroke.StrokeSizingMode = component.StrokeMode or Enum.StrokeSizingMode.FixedSize
			clone2.UIStroke.Color = component.StrokeColor or Color3.new(0, 0, 0)
			clone2.UIStroke.Thickness = component.StrokeSize or 1
			clone2.TextTransparency = 1
			clone2.UIStroke.Transparency = 1
			TweenService:Create(clone2, tweenInfo3, {
				TextTransparency = component.Transparency or 0
			}):Play()
			TweenService:Create(clone2.UIStroke, tweenInfo3, {
				Transparency = component.StrokeTransparency or 0.5
			}):Play()
			clone2.Parent = container.content
			maid:Add(function()
				TweenService:Create(clone2, tweenInfo4, {
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone2.UIStroke, tweenInfo4, {
					Transparency = 1
				}):Play()
			end)
		elseif component.Type == "Button" then
			local clone2 = script.FancyComponents.button:Clone()
			clone2.LayoutOrder = k
			clone2.Text = component.Text

			if component.Font then
				clone2.FontFace = component.Font
			end

			local color = component.Color or Color3.fromRGB(193, 255, 164)
			clone2.TextColor3 = color
			clone2.border.Color = color
			clone2.hover.ImageColor3 = color
			clone2.Size = UDim2.fromScale(0, component.Size or 1)
			clone2.BackgroundTransparency = 1
			clone2.TextTransparency = 1
			clone2.border.Transparency = 1
			clone2.stroke.Transparency = 1
			clone2.hover.ImageTransparency = 1
			TweenService:Create(clone2, tweenInfo3, {
				TextTransparency = 0,
				BackgroundTransparency = 0.45
			}):Play()
			TweenService:Create(clone2.border, tweenInfo3, {
				Transparency = 0.36
			}):Play()
			TweenService:Create(clone2.stroke, tweenInfo3, {
				Transparency = 0.36
			}):Play()
			TweenService:Create(clone2.hover, tweenInfo3, {
				ImageTransparency = 0
			}):Play()
			local v = component
			maid:Add(clone2.Activated:Once(function()
				if v.DismissOnClick ~= false then
					maid:Clean()
				end

				if v.OnClick then
					local v2 = nil
					local fn

					if typeof(v.OnClick) == "string" then
						fn = function(...)
							Net:Fire(v.OnClick, ...)
						end
					elseif typeof(v.OnClick) == "function" then
						fn = v.OnClick
					else
						fn = typeof(v.OnClick) == "Instance" and function(...)
							if v.OnClick:IsA("BindableEvent") then
								v.OnClick:Fire(...)
							elseif v.OnClick:IsA("BaseRemoteEvent") then
								v.OnClick:FireServer(...)
							elseif v.OnClick:IsA("BindableFunction") then
								v.OnClick:Invoke(...)
							elseif v.OnClick:IsA("RemoteFunction") then
								v.OnClick:InvokeServer(...)
							end
						end or v2
					end

					if fn then
						if v.ClickDataUnpack and typeof(v.ClickData) == "table" then
							fn(table.unpack(v.ClickData))
						else
							fn(v.ClickData)
						end
					end
				end
			end))
			clone2.Parent = container.content
			maid:Add(function()
				TweenService:Create(clone2, tweenInfo4, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(clone2.border, tweenInfo4, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.stroke, tweenInfo4, {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2.hover, tweenInfo4, {
					ImageTransparency = 1
				}):Play()
			end)
		end
	end

	container.Shine.ImageTransparency = 1
	container.Shine.ImageColor3 = data.ShineFlash or data.ShineColor or Color3.new(0, 0, 0)
	container.Position = UDim2.fromScale(0, 1)
	clone.Size = UDim2.fromScale(1, 0.45 * (data.Size or 1))
	clone.Parent = announcements
	clone.Visible = true
	local v

	if typeof(data.Sound) == "table" then
		v = data.Sound
	else
		v = { data.Sound }
	end

	for _, instance in v do
		if typeof(instance) == "string" then
			instance = ReplicatedStorage.resources.sounds:FindFirstChild(instance, true)
		end

		if not (typeof(instance) == "Instance" and (instance:IsA("Sound") or instance:IsA("AudioPlayer"))) then
			continue
		end

		instance:Play()
	end

	TweenService:Create(container, TweenInfo.new(appearTime, Enum.EasingStyle.Back), {
		Position = UDim2.new()
	}):Play()
	TweenService:Create(container.Shine, tweenInfo3, {
		ImageTransparency = data.ShineTransparency or 0.25
	}):Play()

	if data.ShineFlash then
		TweenService:Create(
			container.Shine,
			TweenInfo.new(data.ShineFlashTime or 1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
			{
				ImageColor3 = data.ShineColor or Color3.new(0, 0, 0)
			}
		):Play()
	end

	maid:Add(function()
		TweenService:Create(container.Shine, tweenInfo4, {
			ImageTransparency = 1
		}):Play()
		task.delay(disappearTime, clone.Destroy, clone)
	end)

	if lifetime ~= -1 and math.isfinite(lifetime) then
		task.delay(lifetime, maid.Clean, maid)
	end

	return clone
end

function NotificationController:_UpdateHeaderText(data)
	if data.Count > 1 then
		data.HeaderLabel.Text = ("%s <font color=\"#b0b0b0\" size=\"11\">(×%d)</font>"):format(
			data.BaseHeader,
			data.Count
		)
	else
		data.HeaderLabel.Text = data.BaseHeader
	end
end

function NotificationController:_ApplyDetails(data, items, flag: boolean)
	local detailsFrame = data.DetailsFrame

	if not detailsFrame then
		return
	end

	for _, item in items do
		local detailEntry = data.DetailEntries[item.Key]

		if detailEntry then
			detailEntry.Label.Text = item.Text

			if detailEntry.Removing then
				detailEntry.Removing = false
				detailEntry.RemoveAt = nil
				FadeIn(detailEntry.Fade, tweenInfo2)
			end

			detailEntry.ExpireAt = item.RemoveTime and os.clock() + item.RemoveTime or nil
		else
			local clone = script.ReflectionComponents.ExtraLabel:Clone()
			clone.Text = item.Text
			clone.AnchorPoint = Vector2.new(1, 0)
			local fade = {}
			CollectFadeTree(clone, fade) -- equivalent call inferred; original call site unknown
			table.move(fade, 1, #fade, #data._fade + 1, data._fade)
			local detailEntries = data.DetailEntries
			local key = item.Key
			local expireAt

			if item.RemoveTime then
				expireAt = os.clock() + item.RemoveTime or nil
			end

			detailEntries[key] = {
				Label = clone,
				Fade = fade,
				ExpireAt = expireAt,
				Removing = false,
				RemoveAt = nil
			}
			table.insert(data.DetailOrder, item.Key)

			if not flag then
				FadeIn(fade, tweenInfo)
			end

			clone.Parent = detailsFrame
		end
	end
end

function NotificationController:_StepReflectionInternal(data, p: number, p2: number)
	local headerLabel = data.HeaderLabel
	headerLabel.Position = headerLabel.Position:Lerp(
		UDim2.new(headerLabel.Position.X.Scale, headerLabel.Position.X.Offset, 0, 0),
		p
	)
	local detailsFrame = data.DetailsFrame

	if detailsFrame then
		for i = #data.DetailOrder, 1, -1 do
			local v = data.DetailOrder[i]
			local detailEntry = data.DetailEntries[v]

			if detailEntry then
				if detailEntry.Removing then
					if detailEntry.RemoveAt <= p2 then
						RemoveFadeTargets(data._fade, detailEntry.Fade)
						detailEntry.Label:Destroy()
						data.DetailEntries[v] = nil
						table.remove(data.DetailOrder, i)
					end
				elseif detailEntry.ExpireAt and detailEntry.ExpireAt <= p2 then
					detailEntry.Removing = true
					detailEntry.RemoveAt = p2 + 0.5
					FadeOut(detailEntry.Fade, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
				end
			else
				table.remove(data.DetailOrder, i)
			end
		end

		local total = 0

		for _, v in data.DetailOrder do
			local detailEntry = data.DetailEntries[v]

			if not detailEntry then
				continue
			end

			local label = detailEntry.Label
			label.Position = label.Position:Lerp(UDim2.new(1, 0, 0, total), p)
			total += label.AbsoluteSize.Y
		end

		detailsFrame.Position = detailsFrame.Position:Lerp(
			UDim2.new(detailsFrame.Position.X.Scale, detailsFrame.Position.X.Offset, 0, headerLabel.AbsoluteSize.Y + 2),
			p
		)
	end
end

function NotificationController:NavigateNotify(text: string, clickData: string, lifetime: number?, value, value2: number?)
	return NotificationController:FancyNotify({
		Components = {
			{
				Type = "Text",
				Text = text
			},
			{
				Type = "Button",
				Text = "Navigate",
				Color = Color3.fromRGB(89, 178, 255),
				OnClick = "RequestCustomNavigate",
				ClickData = clickData,
				Size = 1 / (value2 or 1),
				DismissOnClick = true
			}
		},
		Sound = value or "popup2",
		Size = value2,
		Lifetime = lifetime,
		DisappearTime = 0.5
	})
end

function NotificationController:_StepReflections(p: number)
	local now = os.clock()
	local v = 1 - math.exp(p * -16)

	for i = #self._reflectionOrder, 1, -1 do
		local v2 = self._reflectionOrder[i]

		if v2.Removing then
			if v2.RemoveAt <= now then
				table.remove(self._reflectionOrder, i)

				if self._reflections[v2.Key] == v2 then
					self._reflections[v2.Key] = nil
				end

				v2.Trove:Destroy()
			end
		elseif v2.ExpireAt and v2.ExpireAt <= now then
			self:_BeginRemoveReflection(v2)
		end
	end

	local total = 0

	for i = #self._reflectionOrder, 1, -1 do
		local v2 = self._reflectionOrder[i]
		self:_StepReflectionInternal(v2, v, now)
		local frame = v2.Frame

		if v2.Removing then
			local uDim = UDim2.new(1, frame.AbsoluteSize.X, frame.Position.Y.Scale, frame.Position.Y.Offset)
			frame.Position = frame.Position:Lerp(uDim, v)
		else
			local uDim = frame.Position:Lerp(UDim2.new(1, 0, 1, -total), v)

			if math.abs(uDim.X.Offset) < 0.5 then
				uDim = UDim2.new(1, 0, uDim.Y.Scale, uDim.Y.Offset)
			end

			frame.Position = uDim
			total += frame.AbsoluteSize.Y + 6
		end
	end

	if #self._reflectionOrder == 0 and self._reflectionConnection then
		self._reflectionConnection:Disconnect()
		self._reflectionConnection = nil
	end
end

function NotificationController:_EnsureReflectionLoop()
	if self._reflectionConnection then
		return
	end

	self._reflectionConnection = RunService.RenderStepped:Connect(function(dt)
		self:_StepReflections(dt)
	end)
end

function NotificationController:_BuildReflection(data)
	local reflections = module:GetSafeZone():WaitForChild("reflections")
	local clone = script.ReflectionTemplate:Clone()
	StripLayouts(clone)
	clone.AnchorPoint = Vector2.new(1, 1)
	clone.Position = UDim2.new(1, 150, 1, 0)
	clone.Visible = true
	local v = {
		Key = data.Key,
		Frame = clone,
		HeaderLabel = clone.Label,
		BaseHeader = data.Header,
		Count = 1,
		DetailEntries = {},
		DetailOrder = {},
		DetailsFrame = clone:FindFirstChild("Details"),
		Trove = Trove.new(),
		Lifetime = data.Lifetime or 5,
		DisappearTime = data.DisappearTime or 0.4,
		ExpireAt = nil,
		RemoveAt = nil,
		Removing = false,
		_fade = {}
	}
	v.Trove:Add(clone)
	self:_UpdateHeaderText(v)
	CollectFadeTree(clone, v._fade) -- equivalent call inferred; original call site unknown

	if data.Details then
		self:_ApplyDetails(v, data.Details, true)
	end

	FadeIn(v._fade, TweenInfo.new(data.AppearTime or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
	clone.Parent = reflections

	if v.Lifetime ~= -1 and math.isfinite(v.Lifetime) then
		v.ExpireAt = os.clock() + v.Lifetime
	end

	table.insert(self._reflectionOrder, v)
	self._reflections[data.Key] = v
	self:_EnsureReflectionLoop()
	return v
end

function NotificationController:_RepeatReflection(state, p)
	if state.Removing then
		state.Removing = false
		state.RemoveAt = nil
		FadeIn(state._fade, tweenInfo2)
	end

	state.Count += 1

	if p.Header then
		state.BaseHeader = p.Header
	end

	self:_UpdateHeaderText(state)

	if p.Details then
		self:_ApplyDetails(state, p.Details, false)
	end

	if state.Lifetime ~= -1 and math.isfinite(state.Lifetime) then
		state.ExpireAt = os.clock() + state.Lifetime
	end
end

function NotificationController:_BeginRemoveReflection(state)
	if state.Removing then
		return
	end

	state.Removing = true
	state.RemoveAt = os.clock() + state.DisappearTime
	FadeOut(state._fade, TweenInfo.new(state.DisappearTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
end

function NotificationController:DismissReflection(p: string)
	local _reflection = self._reflections[p]

	if _reflection then
		self:_BeginRemoveReflection(_reflection)
	end
end

function NotificationController:Reflect(p)
	self:AwaitReady()
	local _reflection = self._reflections[p.Key]

	if not _reflection then
		return self:_BuildReflection(p).Frame
	end

	self:_RepeatReflection(_reflection, p)
	return _reflection.Frame
end

function NotificationController.Start(_)
	notification.OnClientEvent:Connect(function(p: string, p2: number?, childName: string?)
		local sound = childName and ReplicatedStorage.resources.sounds:FindFirstChild(childName, true)

		if sound and not sound:IsA("Sound") then
			sound = nil
		end

		NotificationController:Notify(p, p2, sound)
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: number?, sound: string?)
		if typeof(sound) == "string" then
			sound = ReplicatedStorage.resources.sounds:FindFirstChild(sound, true)
		end

		if sound and not sound:IsA("Sound") then
			sound = nil
		end

		NotificationController:Notify(p, p2, sound)
	end)
	remoteEvent2.OnClientEvent:Connect(function(p)
		NotificationController:FancyNotify(p)
	end)
	remoteEvent4.OnClientEvent:Connect(function(p)
		NotificationController:Reflect(p)
	end)
	remoteEvent3.OnClientEvent:Connect(function(...)
		NotificationController:NavigateNotify(...)
	end)
end

return NotificationController