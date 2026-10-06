local object = setmetatable({}, {
	__mode = "k"
})
local TweenService = game:GetService("TweenService")
local object2 = setmetatable({}, {
	__mode = "k"
})

local function groups(folder)
	if folder:IsA("CanvasGroup") then
		return { folder }
	end

	local canvasGroups = {}

	if not folder:IsA("ScreenGui") then
		return canvasGroups
	end

	for _, canvasGroup in ipairs(folder:GetDescendants()) do
		if not canvasGroup:IsA("CanvasGroup") then
			continue
		end

		local parent = canvasGroup.Parent
		local v = false

		while parent and parent ~= folder do
			if parent:IsA("CanvasGroup") then
				v = true
				break
			else
				parent = parent.Parent
			end
		end

		if not v then
			table.insert(canvasGroups, canvasGroup)
		end
	end

	return canvasGroups
end

local MenuFade = {
	IsOpen = function(screenGui, p)
		local v = p or screenGui:IsA("ScreenGui") and "Enabled" or "Visible"
		local v2 = object[screenGui] or object2[screenGui]

		if v2 then
			return v2.open
		end

		return screenGui[v]
	end
}

local function directSet(folder, p, open)
	local v = object[folder]

	if v then
		v.tween:Cancel()
		v.connection:Disconnect()

		for _, entry in v.entries do
			if entry.object.Parent then
				entry.object[entry.property] = entry.base
			end
		end

		v.driver:Destroy()
		object[folder] = nil
	end

	if folder[p] == open then
		return
	end

	local localPlayer = game.Players.LocalPlayer

	if localPlayer and localPlayer:GetAttribute("ReducedMotion") then
		folder[p] = open
		return
	end

	local entries = {}

	local function collect(instance)
		local v3 = {}

		if instance:IsA("GuiObject") then
			table.insert(v3, "BackgroundTransparency")
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			table.insert(v3, "TextTransparency")
			table.insert(v3, "TextStrokeTransparency")
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") or instance:IsA("ViewportFrame") then
			table.insert(v3, "ImageTransparency")
		end

		if instance:IsA("UIStroke") then
			table.insert(v3, "Transparency")
		end

		for _, property in v3 do
			local base = instance[property]

			if base < 1 then
				table.insert(entries, {
					object = instance,
					property = property,
					base = base
				})
			end
		end
	end

	collect(folder)

	for _, descendant in folder:GetDescendants() do
		collect(descendant)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = open and 1 or 0

	local function paint()
		for _, v3 in entries do
			if v3.object.Parent then
				v3.object[v3.property] = v3.base + (1 - v3.base) * numberValue.Value
			end
		end
	end

	folder[p] = true
	paint()
	local changedConnection = numberValue.Changed:Connect(paint)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(open and 0.2 or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = open and 0 or 1
		}
	)
	local v3 = {
		open = open,
		driver = numberValue,
		tween = tween,
		connection = changedConnection,
		entries = entries
	}
	object[folder] = v3
	tween.Completed:Connect(function(p2)
		if object[folder] ~= v3 or p2 ~= Enum.PlaybackState.Completed then
			return
		end

		changedConnection:Disconnect()
		folder[p] = open

		for _, v4 in entries do
			if v4.object.Parent then
				v4.object[v4.property] = v4.base
			end
		end

		object[folder] = nil
		numberValue:Destroy()
	end)
	tween:Play()
end

function MenuFade:Set(p, open)
	local v = self:IsA("ScreenGui") and self or self:FindFirstAncestorWhichIsA("ScreenGui")

	if v and v:GetAttribute("DirectFade") then
		directSet(self, p, open)
		return
	end

	local v2 = groups(self)

	if #v2 == 0 then
		self[p] = open
		return
	end

	local v3 = object2[self] or {
		open = self[p],
		version = 0,
		tweens = {}
	}
	object2[self] = v3

	if v3.open == open and self[p] == open then
		return
	end

	v3.open = open
	v3.version += 1
	local version = v3.version

	for _, tween in ipairs(v3.tweens) do
		tween:Cancel()
	end

	v3.tweens = {}
	local localPlayer = game.Players.LocalPlayer

	if localPlayer and localPlayer:GetAttribute("ReducedMotion") then
		self[p] = open

		for _, v4 in ipairs(v2) do
			v4.GroupTransparency = 0
		end
	elseif open then
		local v4 = self[p]
		self[p] = true

		for _, v5 in ipairs(v2) do
			if not v4 then
				v5.GroupTransparency = 1
			end

			local tween = TweenService:Create(v5, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				GroupTransparency = 0
			})
			table.insert(v3.tweens, tween)
			tween:Play()
		end
	else
		for _, v4 in ipairs(v2) do
			local tween = TweenService:Create(
				v4,
				TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					GroupTransparency = 1
				}
			)
			table.insert(v3.tweens, tween)
			tween:Play()
		end

		task.delay(0.14, function()
			if v3.version ~= version then
				return
			end

			self[p] = false

			for _, v4 in ipairs(v2) do
				v4.GroupTransparency = 0
			end
		end)
	end
end

return MenuFade