local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundPacks = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("SoundPacks"))
local SoundPackButton = {}
SoundPackButton.__index = SoundPackButton

function SoundPackButton.Hydrate(instance, options)
	local v = options or {}
	local object = setmetatable({
		Instance = instance,
		SoundKey = v.soundKey,
		Sound = v.sound,
		_stroke = instance:FindFirstChildOfClass("UIStroke"),
		_gradient = instance:FindFirstChildOfClass("UIGradient"),
		_lock = instance:FindFirstChild("Lock"),
		_itemImage = instance:FindFirstChild("ItemImage"),
		_equipped = v.equipped == true,
		_locked = v.locked == true,
		_onActivated = v.onActivated,
		_onHovered = v.onHovered,
		_ownsInstance = false,
		_connections = {}
	}, SoundPackButton)
	local sound = v.sound

	if sound then
		if object._itemImage and sound.icon then
			object._itemImage.Image = sound.icon
		end

		local itemTitle = instance:FindFirstChild("ItemTitle")
		local textLabel = itemTitle and itemTitle:FindFirstChildOfClass("TextLabel")

		if textLabel then
			textLabel.Text = sound.displayName
		end

		if object._gradient then
			SoundPacks.ApplyGradient(object._gradient, sound.gradient)
		end
	end

	table.insert(object._connections, instance.Activated:Connect(function()
		if object._onActivated then
			object._onActivated(object)
		end
	end))
	table.insert(object._connections, instance.MouseEnter:Connect(function()
		if object._onHovered then
			object._onHovered(object)
		end
	end))
	object:SetLocked(object._locked, v.price)
	object:_refreshEquipped()
	return object
end

function SoundPackButton.Create(options)
	local v = options or {}
	assert(v.template, "[SoundPackButton] opts.template requis")
	local clone = v.template:Clone()
	clone.Name = v.soundKey or clone.Name
	clone.Visible = true

	if v.layoutOrder then
		clone.LayoutOrder = v.layoutOrder
	end

	local hydrate = SoundPackButton.Hydrate(clone, v)
	hydrate._ownsInstance = true
	clone.Parent = v.parent
	return hydrate
end

function SoundPackButton:_refreshEquipped()
	if self._stroke then
		self._stroke.Color = self._equipped and SoundPacks.COLOR_EQUIPPED or SoundPacks.COLOR_DEFAULT
	end
end

function SoundPackButton:SetEquipped(flag: boolean)
	self._equipped = flag == true
	self:_refreshEquipped()
end

function SoundPackButton:SetLocked(flag: boolean, text: string?)
	self._locked = flag == true

	if self._lock then
		self._lock.Visible = self._locked
		local priceTextLabel = self._lock:FindFirstChild("PriceTextLabel")

		if priceTextLabel and text then
			priceTextLabel.Text = text
		end
	end

	if self._itemImage then
		self._itemImage.ImageTransparency = self._locked and SoundPacks.LOCKED_TRANSPARENCY or 0
	end
end

function SoundPackButton:IsLocked()
	return self._locked
end

function SoundPackButton:Destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)

	if self._ownsInstance then
		self.Instance:Destroy()
	end
end

return SoundPackButton