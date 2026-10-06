local module = require("@game/ReplicatedStorage/Omni")
local uDim = UDim2.fromScale(0, 0)
local color = Color3.new(1, 1, 1)
local fusion = module.Libs.Fusion
local notifications = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Notifications")
local v = {}
local v2 = {}
local count = 0
local Text = {}
local scope = fusion.scoped(fusion, {
	Build = function(self)
		self.Size = self:Value(uDim)
		self.SizeSpring = self:Spring(self.Size, 30, 1)
		self.Color = self:Value(color)
		self.ColorSpring = self:Spring(self.Color, 10, 1)
		self.Instance = notifications.Text:Clone()
		self.Instance.Name = "TextNotification"
		self.Instance.Message.TextColor3 = color
		module.NotificationList.Add(self.Instance, "Text")
		table.insert(self, self.Instance.Destroying:Connect(function()
			Text.Destroy(self.Identifier)
		end))
		self:Observer(self.SizeSpring):onChange(function()
			local sizeSpring = self.peek(self.SizeSpring)

			if not sizeSpring then
				return
			end

			if self.Closing and math.abs(sizeSpring.X.Scale) + math.abs(sizeSpring.Y.Scale) < 0.001 then
				Text.Destroy(self.Identifier)
			end
		end)
		self:Observer(self.ColorSpring):onChange(function()
			local colorSpring = self.peek(self.ColorSpring)

			if not colorSpring then
				return
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, module.Utils.Colors:Lighten(colorSpring, 0.5)),
				ColorSequenceKeypoint.new(1, colorSpring)
			})
			self.Instance.Message.UIGradient.Color = colorSequence
		end)
		self:Hydrate(self.Instance.Message)({
			Size = self.SizeSpring
		})
		self.Size:set(notifications.Text.Message.Size)
		return true
	end,
	Set = function(self, info)
		if self.Info then
			if info.Message == self.Info.Message then
				self.Amount = (self.Amount or 0) + 1
			else
				self.Amount = 1
			end
		else
			self.Amount = 1
		end

		local amount = self.Amount
		local sound = info.Sound

		if typeof(sound) ~= "string" then
			local color2 = info.Color

			if color2 == Color3.new(1, 0, 0) then
				sound = "Error"
			elseif color2 == Color3.new(1, 1, 0) then
				sound = "Warn"
			elseif color2 == Color3.new(0, 1, 0) then
				sound = "Success"
			elseif color2 == Color3.new(0, 0, 1) then
				sound = "Info"
			else
				sound = "Default"
			end
		end

		module.Sound:PlayEffect("Notifications." .. sound, {
			Group = "Notifications",
			Cooldown = 0.1
		})
		self.Info = info
		self.Closing = false
		self.ColorSpring:setPosition(color)
		self.Color:set(info.Color)
		self.Size:set(notifications.Text.Message.Size)
		self.Instance.Message.Text = `{info.Message}{amount > 1 and " (" .. amount .. "x)" or ""}`

		if self.Thread then
			task.cancel(self.Thread)
			self.Thread = nil
		end

		self.Thread = task.delay(info.Time or 3, function()
			self.Thread = nil
			self:Close()
		end)
	end,
	Close = function(self)
		if self.Thread then
			task.cancel(self.Thread)
			self.Thread = nil
		end

		self.Closing = true
		self.Size:set(uDim)
		local sizeSpring = self.peek(self.SizeSpring)

		if sizeSpring and math.abs(sizeSpring.X.Scale) + math.abs(sizeSpring.Y.Scale) < 0.001 then
			Text.Destroy(self.Identifier)
		end

		Text.PumpQueue()
	end
})

local function GetOpenCount()
	local count2 = 0

	for _, v3 in v do
		if not v3.Closing then
			count2 += 1
		end
	end

	return count2
end

local function Enqueue(clone)
	for _, v3 in v2 do
		if v3.Params.Identifier ~= clone.Identifier then
			continue
		end

		if v3.Params.Message == clone.Message then
			v3.Amount += 1
		else
			v3.Amount = 1
		end

		v3.Params = clone
		return
	end

	table.insert(v2, {
		Params = clone,
		Amount = 1
	})
end

local function Open(params, amount: number)
	count += 1
	local innerScope = scope:innerScope()
	innerScope.Identifier = params.Identifier
	innerScope.Sequence = count

	if not innerScope:Build() then
		innerScope:doCleanup()
		return
	end

	innerScope:Set(params)

	if amount > 1 then
		innerScope.Amount = amount
		innerScope.Instance.Message.Text = `{params.Message} ({amount}x)`
	end

	v[params.Identifier] = innerScope
end

function Text.Create(p)
	if typeof(p) ~= "table" then
		return
	end

	local clone = table.clone(p)

	if typeof(clone.Message) ~= "string" then
		return
	end

	if typeof(clone.Identifier) ~= "string" then
		clone.Identifier = clone.Message
	end

	if not module.Shared.Notifications.IsFinite(clone.Time) then
		clone.Time = 3
	end

	if typeof(clone.Color) ~= "Color3" then
		clone.Color = color
	end

	clone.Time = math.clamp(clone.Time, 0.1, 60)
	local v3 = v[clone.Identifier]

	if v3 and not v3.Closing then
		v3:Set(clone)
		return
	end

	if not v3 then
		local count2 = 0

		for _, v4 in v do
			if not v4.Closing then
				count2 += 1
			end
		end

		if not (module.Shared.Notifications.MaximumTexts <= count2) then
			count += 1
			local innerScope = scope:innerScope()
			innerScope.Identifier = clone.Identifier
			innerScope.Sequence = count

			if not innerScope:Build() then
				innerScope:doCleanup()
				return
			end

			innerScope:Set(clone)
			v[clone.Identifier] = innerScope
			return
		end
	end

	Enqueue(clone)
end

function Text.PumpQueue()
	while v2[1] do
		local count2 = 0

		for _, v3 in v do
			if not v3.Closing then
				count2 += 1
			end
		end

		if not (count2 < module.Shared.Notifications.MaximumTexts) then
			break
		end

		local v3 = v2[1]

		if v[v3.Params.Identifier] then
			local v4 = false

			for k, v6 in v2 do
				if v[v6.Params.Identifier] then
					continue
				end

				table.remove(v2, k)
				Open(v6.Params, v6.Amount)
				v4 = true
				break
			end

			if not v4 then
				break
			end
		else
			table.remove(v2, 1)
			Open(v3.Params, v3.Amount)
		end
	end
end

function Text.Destroy(p: string?)
	if p then
		local v3 = v[p]

		if not v3 then
			return
		end

		v[p] = nil

		if v3.Thread then
			task.cancel(v3.Thread)
			v3.Thread = nil
		end

		module.NotificationList.Remove(v3.Instance)
		v3.Instance:Destroy()
		v3:doCleanup()
		Text.PumpQueue()
	else
		table.clear(v2)

		for k in v do
			Text.Destroy(k)
		end

		count = 0
	end
end

return Text