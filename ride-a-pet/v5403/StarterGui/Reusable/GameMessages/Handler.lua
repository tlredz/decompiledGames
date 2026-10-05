local services = game.ReplicatedStorage:WaitForChild("Services")
local Tweens = require(services:WaitForChild("Tweens"))
local parent = script.Parent
local gameMessage = parent:WaitForChild("GameMessageHandler"):WaitForChild("GameMessage")
game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("GameMessage")
local _ = parent.Parent
local v = {}

local function ApplySpanGradient(parent2, value, data)
	local v2, v3 = string.find(value, data.Text, 1, true)
	local assets = game.ReplicatedStorage:FindFirstChild("Assets")
	local rarityGradients = assets and assets:FindFirstChild("RarityGradients")
	local uIGradient

	if type(data.Rarity) == "string" then
		uIGradient = rarityGradients and rarityGradients:FindFirstChild(data.Rarity)
	else
		uIGradient = false
	end

	local v4 = typeof(data.Color) == "ColorSequence"

	if not (v2 and (v4 or uIGradient and uIGradient:IsA("UIGradient"))) then
		return
	end

	local v5 = string.sub(value, 1, v2 - 1):gsub("%s+$", "")
	local v6 = string.sub(value, v3 + 1):gsub("^%s+", "")
	local v7 = { v5, data.Text, v6 }
	local prefixText = data.PrefixText
	local v8

	if type(prefixText) == "string" and prefixText ~= "" and v5:sub(1, #prefixText) == prefixText then
		v7 = {
			prefixText,
			v5:sub(#prefixText + 1):gsub("^%s+", ""),
			data.Text,
			v6
		}
		v8 = {
			[1] = true,
			[3] = true
		}
	else
		v8 = {
			[2] = true
		}
	end

	local v9 = math.clamp(tonumber(data.Gap) or 30, 0, 100)
	local v10 = false
	local v11 = {}
	local total = 0
	local Xs = {}
	local v12 = 1

	for i, v13 in ipairs(v7) do
		v11[i] = (v13 == "" or not (v10 and v9)) and 0 or v9
		total += v11[i]

		if v13 ~= "" then
			v10 = true
		end
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = parent2.FontFace
	getTextBoundsParams.Size = 100
	getTextBoundsParams.Width = 100000
	getTextBoundsParams.RichText = true

	for i, text in ipairs(v7) do
		getTextBoundsParams.Text = text
		local success, result = pcall(function()
			local TextService = game:GetService("TextService")
			return TextService:GetTextBoundsAsync(getTextBoundsParams)
		end)

		if not success then
			getTextBoundsParams:Destroy()
			return
		end

		Xs[i] = result.X
		total += result.X
		v12 = math.max(v12, result.Y)
	end

	getTextBoundsParams:Destroy()

	if not parent2.Parent or total <= 0 then
		return
	end

	local thicknessesByUIStroke = {}
	local clones = {}

	for i, text in ipairs(v7) do
		local clone = parent2:Clone()
		clone.Name = "MessagePart" .. i
		clone.Text = text
		clone.TextScaled = false
		clone.TextWrapped = false
		clone.TextStrokeTransparency = 1
		clone.BackgroundTransparency = 1
		clone.BorderSizePixel = 0
		clone.AutomaticSize = Enum.AutomaticSize.None
		clone.AnchorPoint = Vector2.new(0, 0.5)
		clone.TextXAlignment = Enum.TextXAlignment.Center
		clone.TextYAlignment = Enum.TextYAlignment.Center

		for _, child in ipairs(clone:GetChildren()) do
			if not (child:IsA("UIGradient") or child:IsA("UISizeConstraint") or child:IsA("UIAspectRatioConstraint") or child:IsA("UITextSizeConstraint")) then
				continue
			end

			child:Destroy()
		end

		for _, uIStroke in ipairs(clone:GetChildren()) do
			if uIStroke:IsA("UIStroke") then
				thicknessesByUIStroke[uIStroke] = uIStroke.Thickness
			end
		end

		if v8[i] then
			local v14

			if v4 then
				v14 = Instance.new("UIGradient")
				v14.Color = data.Color
				v14.Rotation = tonumber(data.Rotation) or 0
			else
				v14 = uIGradient:Clone()
			end

			v14.Parent = clone
		end

		clones[i] = clone
	end

	parent2.Text = ""

	for _, uIStroke in ipairs(parent2:GetChildren()) do
		if uIStroke:IsA("UIStroke") then
			uIStroke:Destroy()
		end
	end

	for _, v13 in ipairs(clones) do
		v13.Parent = parent2
	end

	local function Resize()
		local absoluteSize = parent2.AbsoluteSize
		local textSize = math.max(1, (math.floor(math.min(absoluteSize.X / total, absoluteSize.Y / v12, 1) * 100)))
		local v14 = textSize / 100
		local v15 = (absoluteSize.X - total * v14) / 2

		for k, v16 in pairs(thicknessesByUIStroke) do
			k.Thickness = v16 * math.clamp(textSize / 32, 0.25, 1)
		end

		for i, v16 in ipairs(clones) do
			local v17 = v15 + v11[i] * v14
			local v18 = Xs[i] * v14
			v16.TextSize = textSize
			v16.Position = UDim2.new(0, v17, 0.5, 0)
			v16.Size = UDim2.new(0, v18, 1, 0)
			v15 = v17 + v18
		end
	end

	Resize()
	local absoluteSizeChangedConnection = parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
	parent2.Destroying:Once(function()
		absoluteSizeChangedConnection:Disconnect()
	end)
end

local TweenService = game:GetService("TweenService")
local object = setmetatable({}, {
	__mode = "k"
})

local function PopAdmin(instance)
	local appearScale = (instance:FindFirstChild("AdminBanner") or instance):FindFirstChild("AppearScale")

	if not appearScale then
		return
	end

	local v2 = object[appearScale]

	if v2 then
		v2:Cancel()
	else
		appearScale.Scale = 1.1
	end

	local tween = TweenService:Create(
		appearScale,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	object[appearScale] = tween
	tween.Completed:Once(function()
		if object[appearScale] == tween then
			object[appearScale] = nil
		end
	end)
	tween:Play()
end

local function DecorateAdmin(parent2, p)
	local messageLabel = parent2:FindFirstChild("MessageLabel")

	if not messageLabel then
		return
	end

	local frame = Instance.new("Frame")
	frame.Name = "AdminBanner"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = parent2.BackgroundColor3
	frame.BackgroundTransparency = parent2.BackgroundTransparency
	frame.BorderSizePixel = parent2.BorderSizePixel
	frame.BorderColor3 = parent2.BorderColor3
	frame.ZIndex = parent2.ZIndex
	parent2.BackgroundTransparency = 1
	parent2.BorderSizePixel = 0
	frame.Parent = parent2

	for _, child in parent2:GetChildren() do
		if not (child:IsA("UIGradient") or child:IsA("UICorner") or child:IsA("UIStroke") or child.Name == "Counter") then
			continue
		end

		child.Parent = frame
	end

	messageLabel.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "AdminBox"
	frame2.BackgroundTransparency = 1
	local position = messageLabel.Position
	local size = messageLabel.Size
	local anchorPoint = messageLabel.AnchorPoint
	frame2.Position = position
	frame2.Size = size
	frame2.AnchorPoint = anchorPoint
	frame2.ZIndex = messageLabel.ZIndex
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "AdminContent"
	frame3.BackgroundTransparency = 1
	frame3.AnchorPoint = Vector2.new(0.5, 0.5)
	frame3.ZIndex = messageLabel.ZIndex
	frame3.Parent = frame
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "AppearScale"
	uIScale.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "AdminProfilePicture"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", p)
	imageLabel.ZIndex = messageLabel.ZIndex
	imageLabel.Parent = frame3
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = imageLabel
	messageLabel.Parent = frame3
	messageLabel.AnchorPoint = Vector2.zero
	messageLabel.TextScaled = false
	messageLabel.TextWrapped = false
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	local fontFace = messageLabel.FontFace
	local richText = messageLabel.RichText
	getTextBoundsParams.Font = fontFace
	getTextBoundsParams.Size = 100
	getTextBoundsParams.Width = 100000
	getTextBoundsParams.RichText = richText
	getTextBoundsParams.Text = messageLabel.Text
	local success, result = pcall(function()
		local TextService = game:GetService("TextService")
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)
	getTextBoundsParams:Destroy()

	if not frame.Parent then
		return
	end

	if not success then
		result = Vector2.new(math.max(100, #messageLabel.Text * 55), 120)
	end

	local v2 = result.X + 145
	local v3 = math.max(100, result.Y)

	local function Resize()
		local absoluteSize = parent2.AbsoluteSize
		local vector = Vector2.new(
			absoluteSize.X * frame2.Size.X.Scale + frame2.Size.X.Offset,
			absoluteSize.Y * frame2.Size.Y.Scale + frame2.Size.Y.Offset
		)
		local vector2 = Vector2.new(
			absoluteSize.X * frame2.Position.X.Scale + frame2.Position.X.Offset,
			absoluteSize.Y * frame2.Position.Y.Scale + frame2.Position.Y.Offset
		)
		local v4 = math.min(vector.X / v2, vector.Y / v3, 1)
		local v5 = vector2 + vector * (Vector2.new(0.5, 0.5) - frame2.AnchorPoint)
		frame3.Position = UDim2.fromOffset(v5.X, v5.Y)
		frame3.Size = UDim2.fromOffset(v2 * v4, v3 * v4)
		imageLabel.Position = UDim2.fromOffset(0, (v3 - 120) * v4 / 2)
		imageLabel.Size = UDim2.fromOffset(v4 * 120, v4 * 120)
		messageLabel.Position = UDim2.fromOffset(v4 * 145, 0)
		messageLabel.Size = UDim2.fromOffset(result.X * v4, v3 * v4)
		messageLabel.TextSize = math.max(1, v4 * 100)
		local uIStroke = messageLabel:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Enabled = true
			uIStroke.Thickness = math.clamp(messageLabel.TextSize / 16, 1, 2.5)
		end
	end

	Resize()
	local absoluteSizeChangedConnection = parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(Resize)
	frame.Destroying:Once(function()
		absoluteSizeChangedConnection:Disconnect()
	end)
	PopAdmin(frame)
end

local Handler = {
	AddMessage = function(_, childName, value, value2, image, p)
		for _, frame in parent:GetChildren() do
			if frame:IsA("Frame") and frame:GetAttribute("Pinned") ~= true then
				frame.LayoutOrder = 0
			end
		end

		local child = parent:FindFirstChild(childName)

		if child then
			child.LayoutOrder = 1

			if type(p) == "table" then
				PopAdmin(child)
			end

			Tweens:FadeIn(child, {
				FadeInTime = 0.1
			})

			if v[childName] then
				task.cancel(v[childName])
				v[childName] = nil
			end

			v[childName] = task.delay(value or 3, function()
				Tweens:FadeOut(child, {
					FadeOutTime = 1
				})
				task.wait(1.1)
				child:Destroy()
			end)
			local counter = child:FindFirstChild("Counter", true)
			local count = child:GetAttribute("Count")

			if count then
				child:SetAttribute("Count", count + 1)
				counter.Text = string.format("x%i", count + 1)
			else
				child:SetAttribute("Count", 2)
			end

			counter.Visible = true
		else
			local clone = gameMessage:Clone()
			clone.LayoutOrder = 1
			local messageLabel = clone:WaitForChild("MessageLabel")

			if type(p) == "table" then
				messageLabel:RemoveTag("TextShadow")

				for _, descendant in clone:GetDescendants() do
					if descendant.Name == "MessageLabel_Shadow" or descendant.Name == "MessageLabel_Face" then
						descendant:Destroy()
					end
				end

				messageLabel.TextTransparency = 0
				messageLabel.TextStrokeTransparency = 1
			end

			clone.Name = childName
			messageLabel.Text = childName

			if type(value2) == "table" and type(value2.Text) == "string" and (type(value2.Rarity) == "string" or typeof(value2.Color) == "ColorSequence") then
				task.spawn(ApplySpanGradient, messageLabel, childName, value2)
			elseif typeof(value2) == "string" then
				local assets = game.ReplicatedStorage:FindFirstChild("Assets")
				local rarityGradients = assets and assets:FindFirstChild("RarityGradients")
				local child2 = rarityGradients and rarityGradients:FindFirstChild(value2)

				if child2 then
					local clone2 = child2:Clone()
					clone2.Name = value2
					clone2.Parent = messageLabel
				end
			elseif typeof(value2) == "ColorSequence" then
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Color = value2
				uIGradient.Parent = messageLabel
			elseif type(value2) == "table" and typeof(value2.Color) == "ColorSequence" then
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Color = value2.Color

				if tonumber(value2.Rotation) then
					uIGradient.Rotation = tonumber(value2.Rotation)
				end

				uIGradient.Parent = messageLabel
			end

			clone.Parent = parent

			if type(p) == "table" and type(p.UserId) == "number" and p.UserId > 0 then
				task.spawn(DecorateAdmin, clone, p.UserId)
			end

			if type(image) == "string" and image ~= "" then
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Name = "Icon"
				imageLabel.BackgroundTransparency = 1
				imageLabel.Image = image
				imageLabel.ScaleType = Enum.ScaleType.Fit
				imageLabel.AnchorPoint = Vector2.new(1, 0.5)
				imageLabel.Position = UDim2.fromScale(0.098, 0.5)
				imageLabel.Size = UDim2.fromScale(0, 0.62)
				imageLabel.ZIndex = messageLabel.ZIndex
				local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uIAspectRatioConstraint.AspectRatio = 1
				uIAspectRatioConstraint.Parent = imageLabel
				imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
				imageLabel.Parent = clone
			end

			v[childName] = task.delay(value or 5, function()
				Tweens:FadeOut(clone, {
					FadeOutTime = 1
				})
				task.wait(1.1)
				clone:Destroy()
			end)
		end
	end
}
local v2 = {}

function Handler.Countdown(_, p, p2)
	if v2[p] then
		return
	end

	local clone = gameMessage:Clone()
	clone.Name = "Countdown " .. p
	clone:SetAttribute("Pinned", true)
	clone.LayoutOrder = -1
	local messageLabel = clone:WaitForChild("MessageLabel")
	messageLabel.Text = string.format("%s %.1f", p, (math.max(p2 - workspace:GetServerTimeNow(), 0)))
	clone.Parent = parent
	v2[p] = clone
	task.spawn(function()
		while clone.Parent do
			local v3 = p2 - workspace:GetServerTimeNow()

			if v3 <= 0 then
				break
			end

			messageLabel.Text = string.format("%s %.1f", p, v3)
			task.wait(0.05)
		end

		messageLabel.Text = string.format("%s 0.0", p)
		Tweens:FadeOut(clone, {
			FadeOutTime = 1
		})
		task.wait(1.1)
		clone:Destroy()
		v2[p] = nil
	end)
end

local v3 = {}

function Handler.PinMessage(_, text, image)
	if v3[text] then
		return
	end

	local clone = gameMessage:Clone()
	clone.Name = "Pinned " .. text
	clone:SetAttribute("Pinned", true)
	clone.LayoutOrder = -1
	local messageLabel = clone:WaitForChild("MessageLabel")
	messageLabel.Text = text
	clone.Parent = parent

	if type(image) == "string" and image ~= "" then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Icon"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = image
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.AnchorPoint = Vector2.new(1, 0.5)
		imageLabel.Position = UDim2.fromScale(0.098, 0.5)
		imageLabel.Size = UDim2.fromScale(0, 0.62)
		imageLabel.ZIndex = messageLabel.ZIndex
		local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
		uIAspectRatioConstraint.AspectRatio = 1
		uIAspectRatioConstraint.Parent = imageLabel
		imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		imageLabel.Parent = clone
	end

	v3[text] = clone
end

function Handler.UnpinMessage(_, p)
	local v4 = v3[p]

	if not v4 then
		return
	end

	v3[p] = nil
	task.spawn(function()
		Tweens:FadeOut(v4, {
			FadeOutTime = 0.4
		})
		task.wait(0.5)
		v4:Destroy()
	end)
end

return Handler