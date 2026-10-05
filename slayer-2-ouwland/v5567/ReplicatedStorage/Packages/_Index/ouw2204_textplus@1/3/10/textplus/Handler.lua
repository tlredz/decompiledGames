local Handler = {}
Handler.__index = Handler
local RunService = game:GetService("RunService")
local Storage = require(script.Parent.Storage)
local AnimatorManager = require(script.Parent.Animators.AnimatorManager)
local TextPlusUtility = require(script.Parent.TextPlusUtility)
local typeof2 = typeof
local Defaults = require(script.Parent.Animators.Defaults)
local left = Enum.TextXAlignment.Left
local top = Enum.TextYAlignment.Top
local sub = string.sub
local fromScale = UDim2.fromScale
local fromOffset = UDim2.fromOffset
local vector = Vector2.new(0, 0)

function Handler:GetContentSize(parent)
	if parent == nil then
		return
	end

	if parent.Parent == nil or parent.Parent.Parent == nil then
		warn("Parent frame is not parented correctely")
		return vector
	end

	if parent.AbsoluteSize.Y <= 0 then
		warn("Parent frame is too small")
		return vector
	end

	if self.RawContent ~= nil and self.Sequence == nil then
		self.Sequence = TextPlusUtility.Phase1(self.RawContent, self)
		self.SequenceCount = #self.Sequence
		self.RawContent = nil
	end

	local absoluteSize = parent.AbsoluteSize
	local frame = Instance.new("Frame")
	frame.Name = "TextPlusTextHolder"
	frame.AutoLocalize = false
	frame.Size = self.Settings.ContentScaled and fromScale(1, 1) or UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
	frame.BackgroundTransparency = 1
	frame.Parent = parent
	local v = parent.AbsoluteSize.X > 0
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Parent = frame
	uIListLayout.Name = "List"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self:ApplyAlignments(frame, uIListLayout)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Wraps = self.Settings.Wrapped

	for _, v3 in ipairs(self.Sequence) do
		local params = nil
		local v4

		if typeof2(v3) == "table" then
			v4 = TextPlusUtility.splitWordsAndSpaces(v3.Text)
			params = v3.Params
		else
			v4 = TextPlusUtility.splitWordsAndSpaces(v3)
		end

		local flag = false
		local size = self.Settings.Size
		local scale = self.Settings.Scale or 1
		local fontFace = self.Settings.FontFace
		local font = self.Settings.Font
		local img

		if params ~= nil then
			scale = params.scale or scale
			size = params.size or size
			fontFace = params.fontface or fontFace
			font = params.font or font
			img = params.img
		end

		if self.Settings.Scaled then
			size = math.min(math.min(absoluteSize.Y, 100) * scale, 100)
		end

		for _, idValue in ipairs(v4) do
			if idValue == "#" or sub(idValue, 1, 1) == "#" then
				if idValue == "#" then
					if img ~= nil then
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.AutoLocalize = false
						imageLabel.Name = "img - " .. img
						local size2

						if self.Settings.Scaled and v then
							size2 = fromScale(size / absoluteSize.X, size / absoluteSize.Y)
						else
							size2 = fromOffset(size, size)
						end

						imageLabel.Size = size2
						imageLabel.ImageTransparency = 1
						imageLabel.Parent = frame
						imageLabel.BackgroundTransparency = 1
						imageLabel.Image = "rbxassetid://" .. img
						continue
					end
				else
					local v6 = sub(idValue, 2)

					if v6 ~= nil then
						idValue = self:GetIdValue(v6) or v6
					end
				end
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = idValue
			textLabel.AutoLocalize = false
			textLabel.TextSize = size
			textLabel.Text = idValue
			textLabel.TextXAlignment = self.Settings.XAlignment or left
			textLabel.TextYAlignment = self.Settings.YAlignment or top
			textLabel.BackgroundTransparency = 1
			textLabel.TextTransparency = 1
			textLabel.Parent = frame

			if fontFace == nil then
				textLabel.Font = font or Defaults.Font
			else
				textLabel.FontFace = fontFace
			end

			local textBounds = textLabel.TextBounds

			if self.Settings.Scaled and v then
				textLabel.Size = fromScale(textBounds.X / absoluteSize.X, textBounds.Y / absoluteSize.Y)
				textLabel.TextScaled = true
			else
				textLabel.Size = fromOffset(textBounds.X, textBounds.Y)
			end

			local absoluteContentSize = uIListLayout.AbsoluteContentSize

			if self.Settings.Overfill or not (absoluteContentSize.Y > absoluteSize.Y) then
				continue
			end

			textLabel.Parent = nil
			textLabel:Destroy()
			flag = true
			break
		end

		if flag then
			break
		end
	end

	local absoluteContentSize = frame.List.AbsoluteContentSize
	frame:Destroy()
	return absoluteContentSize
end

function Handler:ApplyAlignments(p2, p3)
	if p3 == nil then
		return
	end

	local v = 0
	local v2 = 0

	if self.Settings.YAlignment == Enum.TextYAlignment.Center then
		p3.VerticalAlignment = Enum.VerticalAlignment.Center
		v2 = 0.5
	elseif self.Settings.YAlignment == Enum.TextYAlignment.Bottom then
		p3.VerticalAlignment = Enum.VerticalAlignment.Bottom
		v2 = 1
	end

	if self.Settings.XAlignment == Enum.TextXAlignment.Center then
		p3.HorizontalAlignment = Enum.HorizontalAlignment.Center
		v = 0.5
	elseif self.Settings.XAlignment == Enum.TextXAlignment.Right then
		p3.HorizontalAlignment = Enum.HorizontalAlignment.Right
		v = 1
	end

	p2.AnchorPoint = Vector2.new(v, v2)
	p2.Position = fromScale(v, v2)
end

function Handler:Play(parent)
	if parent == nil then
		return
	end

	if parent.Parent == nil or parent.Parent.Parent == nil then
		warn("Parent frame is not parented correctely")
		return self
	end

	if parent.AbsoluteSize.Y <= 0 then
		warn("Parent frame is too small")
		return self
	end

	self.__playing = true

	if self.RawContent ~= nil and self.Sequence == nil then
		self.Sequence = TextPlusUtility.Phase1(self.RawContent, self)
		self.SequenceCount = #self.Sequence
		self.RawContent = nil
	end

	if self.RenderStep ~= nil then
		self.RenderStep:Disconnect()
		self.RenderStep = nil
	end

	if self.Container ~= nil then
		self.Container:Destroy()
	end

	self.Container = self.Settings.UseCanvas and Instance.new("CanvasGroup") or Instance.new("Frame")
	self.Container.Name = "TextPlusTextHolder"
	self.Container.AutoLocalize = false

	if self.Settings.ContentScaled then
		self.Container.Size = fromScale(1, 1)
	end

	self.Container.BackgroundTransparency = 1
	self.Container.Parent = parent
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Parent = self.Container
	uIListLayout.Name = "List"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	self.ListObject = uIListLayout
	self:ApplyAlignments(self.Container, uIListLayout)
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.Wraps = self.Settings.Wrapped
	self.CurrentIndex = 1
	self.CurrentIndexPosition = 1
	self.CurrentCharacterPosition = 1
	local absoluteSize = nil
	local v = nil
	self.RenderStep = RunService.Heartbeat:Connect(function(dt)
		if absoluteSize == nil then
			absoluteSize = parent.AbsoluteSize
			v = parent.AbsoluteSize.X > 0

			if not self.Settings.ContentScaled then
				self.Container.Size = UDim2.fromOffset(absoluteSize.X, absoluteSize.Y)
			end
		end

		AnimatorManager(self, dt, absoluteSize, v)
	end)
	return self, self.Container
end

function Handler:GetIdValue(p2: string)
	if p2 == nil then
		return nil
	end

	local v = Storage.IdsStorage[p2]

	if v == nil then
		return nil
	end

	if typeof2(v) == "function" then
		return v(self)
	end

	return v
end

local v = {
	TextSize = "Size",
	TextColor3 = "Color",
	TextTransparency = "Transparency",
	TextStrokeColor3 = "StrokeColor",
	TextStrokeTransparency = "StrokeTransparency",
	FontFace = "FontFace",
	TextXAlignment = "XAlignment",
	TextYAlignment = "YAlignment"
}
local find = table.find

function Handler.From(p, instance, p2)
	if instance == nil or instance.ClassName ~= "TextLabel" then
		return p
	end

	local v2 = typeof2(p2) == "table"

	for k, v3 in pairs(v) do
		if not (p2 == nil or p2 ~= v3 and p2 ~= k and (not v2 or find(p2, v3) == nil and find(p2, k) == nil)) then
			continue
		end

		p.Settings[v3] = instance[k]
	end

	return p
end

function Handler:Stop()
	if self.RenderStep ~= nil then
		self.RenderStep:Disconnect()
		self.RenderStep = nil
	end

	if self.SizeChangedConnection ~= nil then
		self.SizeChangedConnection:Disconnect()
		self.SizeChangedConnection = nil
	end

	if self.__playing and self.Settings.OnFinished ~= nil then
		self.Settings.OnFinished(self)
	end

	self.__playing = nil

	if self.Animations ~= nil then
		for i = #self.Animations, 1, -1 do
			self.Animations[i]:Destroy()
			self.Animations[i] = nil
		end
	end

	if self.List ~= nil then
		for i = #self.List, 1, -1 do
			if self.List[i] ~= nil then
				self.List[i] = nil
			end
		end

		self.List = nil
	end

	self.CurrentAnimation = nil
	self.Count = nil
	self.WordLength = nil
	self.PrevCharX = nil
	self.PrevCharacterPosition = nil
	self.Word = nil
	self.LastRunSuccessful = nil
	self.CurrentCharacterPosition = nil
	self.CurrentIndex = nil
	self.CurrentIndexPosition = nil
	self.WordInstance = nil
	self.CurrentFontFace = nil
	self.Timer = nil
	self.__Broke = nil
	self.__DeleteWhenDone = nil
	self.Animations = nil
end

function Handler:Destroy()
	self:__removeRoutines()
	self:Stop()
	self.Container = nil
	self.ListObject = nil

	if self.Sequence ~= nil then
		for i = #self.Sequence, 1, -1 do
			self.Sequence[i] = nil
		end
	end

	self.Sequence = nil
	self.SequenceCount = nil
	self.RawContent = nil
end

function Handler:__addRoutine()
	local thread = coroutine.running()

	if self.__routine == nil then
		self.__routine = thread
		return thread
	end

	if typeof(self.__routine) == "thread" then
		warn(1111)
		self.__routine = { self.__routine }
	end

	table.insert(self.__routine, thread)
	return thread
end

function Handler:__removeRoutines()
	if self.__routine ~= nil then
		if typeof2(self.__routine) == "thread" then
			coroutine.resume(self.__routine)
		else
			for i = #self.__routine, 1, -1 do
				coroutine.resume(self.__routine[i])
			end
		end

		self.__routine = nil
	end
end

function Handler:Wait()
	if self.__playing then
		self:__addRoutine()
		coroutine.yield()
	else
		warn("Text+ Writer is not currently running so the :Wait function can not be used.")
	end

	return self, self.Container
end

function Handler:Print(parent)
	if parent == nil then
		return
	end

	if parent.Parent == nil or parent.Parent.Parent == nil then
		warn("Parent frame is not parented correctely")
		return vector
	end

	if parent.AbsoluteSize.Y <= 0 then
		warn("Parent frame is too small")
		return vector
	end

	self:__removeRoutines()
	local v2 = parent.AbsoluteSize.X > 0

	if self.__playing then
		self:Stop()
	end

	if self.Container ~= nil then
		for _, child in self.Container:GetChildren() do
			if child.Name ~= "List" then
				child:Destroy()
			end
		end
	end

	self.ListObject = nil
	local absoluteSize = parent.AbsoluteSize
	local listObject

	if self.Container == nil then
		self.Container = self.Settings.UseCanvas and Instance.new("CanvasGroup") or Instance.new("Frame")
		self.Container.Name = "TextPlusTextHolder"
		self.Container.AutoLocalize = false
		self.Container.Size = self.Settings.ContentScaled and fromScale(1, 1) or UDim2.fromOffset(
			absoluteSize.X,
			absoluteSize.Y
		)
		self.Container.BackgroundTransparency = 1
		self.Container.Parent = parent
		listObject = Instance.new("UIListLayout")
		listObject.Parent = self.Container
		listObject.Name = "List"
		listObject.SortOrder = Enum.SortOrder.LayoutOrder
		self.ListObject = listObject
	else
		listObject = self.Container.List
	end

	self:ApplyAlignments(self.Container, listObject)
	listObject.FillDirection = Enum.FillDirection.Horizontal
	listObject.Wraps = self.Settings.Wrapped

	if self.RawContent ~= nil and self.Sequence == nil then
		self.Sequence = TextPlusUtility.Phase1(self.RawContent, self)
		self.SequenceCount = #self.Sequence
		self.RawContent = nil
	end

	for i = 1, self.SequenceCount do
		local size = self.Settings.Size
		local color = self.Settings.Color
		local strokeColor = self.Settings.StrokeColor
		local transparency = self.Settings.Transparency
		local strokeTransparency = self.Settings.StrokeTransparency
		local scale = self.Settings.Scale or 1
		local fontFace = self.Settings.FontFace
		local font = self.Settings.Font
		local img = nil
		local text

		if typeof2(self.Sequence[i]) == "table" then
			text = self.Sequence[i].Text

			if self.Sequence[i].Params then
				color = self.Sequence[i].Params.color or color
				scale = self.Sequence[i].Params.scale or scale
				size = self.Sequence[i].Params.size or size
				transparency = self.Sequence[i].Params.transparency or transparency
				strokeTransparency = self.Sequence[i].Params.stroketransparency or strokeTransparency
				strokeColor = self.Sequence[i].Params.strokecolor or strokeColor
				fontFace = self.Sequence[i].Params.fontface or fontFace
				font = self.Sequence[i].Params.font or font
				img = self.Sequence[i].Params.img
			end
		else
			text = self.Sequence[i]
		end

		if text == nil then
			continue
		end

		if self.Settings.Scaled then
			size = math.min(math.min(absoluteSize.Y, 100) * scale, 100)
		end

		local splitWordsAndSpaces, v5 = TextPlusUtility.splitWordsAndSpaces(text)

		for i2 = 1, v5 do
			local idValue = splitWordsAndSpaces[i2]

			if idValue == "#" or sub(idValue, 1, 1) == "#" then
				if idValue == "#" then
					if img ~= nil then
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.AutoLocalize = false
						imageLabel.Name = "img - " .. img
						local size2

						if self.Settings.Scaled and v2 then
							size2 = fromScale(size / absoluteSize.X, size / absoluteSize.Y)
						else
							size2 = fromOffset(size, size)
						end

						imageLabel.Size = size2
						imageLabel.Parent = self.Container
						imageLabel.BackgroundTransparency = 1
						imageLabel.Image = "rbxassetid://" .. img
						continue
					end
				else
					local v6 = sub(idValue, 2)

					if v6 ~= nil then
						idValue = self:GetIdValue(v6) or v6
					end
				end
			end

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = idValue
			textLabel.AutoLocalize = false
			textLabel.Parent = self.Container
			textLabel.TextTransparency = transparency
			textLabel.TextSize = size
			textLabel.Text = idValue
			textLabel.TextXAlignment = self.Settings.XAlignment or left
			textLabel.TextYAlignment = self.Settings.YAlignment or top
			textLabel.BackgroundTransparency = 1
			textLabel.TextStrokeTransparency = strokeTransparency or Defaults.StrokeTransparency
			textLabel.TextStrokeColor3 = strokeColor or Defaults.StrokeColor

			if fontFace == nil then
				textLabel.Font = font or Defaults.Font
			else
				textLabel.FontFace = fontFace
			end

			textLabel.TextColor3 = color or Defaults.Color
			local textBounds = textLabel.TextBounds

			if self.Settings.Scaled and v2 then
				textLabel.Size = fromScale(textBounds.X / absoluteSize.X, textBounds.Y / absoluteSize.Y)
				textLabel.TextScaled = true
			else
				textLabel.Size = fromOffset(textBounds.X, textBounds.Y)
			end

			local absoluteContentSize = listObject.AbsoluteContentSize

			if self.Settings.Overfill or not (absoluteContentSize.Y > absoluteSize.Y) then
				continue
			end

			textLabel.Parent = nil
			textLabel:Destroy()
			return
		end
	end

	local absoluteContentSize = listObject.AbsoluteContentSize
	self:Destroy()
	return absoluteContentSize
end

return Handler