local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Omni.Libs.Fusion)
local v = {}
local v2 = {}

local function GetThings(folder)
	local result = {}

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("GuiObject") or descendant:IsA("UIStroke") then
			table.insert(result, descendant)
		end
	end

	table.insert(result, folder)
	return result
end

local function Apply(items, p: number)
	for _, instance in items do
		if instance:IsA("GuiObject") then
			local orgBackgroundTransparency = instance:GetAttribute("OrgBackgroundTransparency")

			if not orgBackgroundTransparency then
				orgBackgroundTransparency = instance.BackgroundTransparency
				instance:SetAttribute("OrgBackgroundTransparency", orgBackgroundTransparency)
			end

			instance.BackgroundTransparency = orgBackgroundTransparency + (1 - orgBackgroundTransparency) * p
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") then
			local orgTextTransparency = instance:GetAttribute("OrgTextTransparency")

			if not orgTextTransparency then
				orgTextTransparency = instance.TextTransparency
				instance:SetAttribute("OrgTextTransparency", orgTextTransparency)
			end

			instance.TextTransparency = orgTextTransparency + (1 - orgTextTransparency) * p
		end

		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") or instance:IsA("ViewportFrame") then
			local orgImageTransparency = instance:GetAttribute("OrgImageTransparency")

			if not orgImageTransparency then
				orgImageTransparency = instance.ImageTransparency
				instance:SetAttribute("OrgImageTransparency", orgImageTransparency)
			end

			instance.ImageTransparency = orgImageTransparency + (1 - orgImageTransparency) * p
		end

		if not instance:IsA("UIStroke") then
			continue
		end

		local orgTransparency = instance:GetAttribute("OrgTransparency")

		if not orgTransparency then
			orgTransparency = instance.Transparency
			instance:SetAttribute("OrgTransparency", orgTransparency)
		end

		instance.Transparency = orgTransparency + (1 - orgTransparency) * p
	end
end

local function GetHandler(guiObject, p: number, speed: number?, update)
	if not (guiObject and guiObject:IsA("GuiObject") and guiObject.Parent) then
		return
	end

	local v3 = typeof(speed) ~= "number" and 10 or speed
	local v4 = v[guiObject]

	if v4 then
		return v4
	end

	v4 = {}
	v4.Scope = {}
	v4.Holder = guiObject
	v4.Update = update
	v4.Things = GetThings(guiObject)
	v4.Goal = Fusion.Value(v4.Scope, p)
	v4.Current = Fusion.Spring(v4.Scope, v4.Goal, v3, 1)
	v4.Connection = Fusion.Observer(v4.Scope, v4.Current):onChange(function()
		local goal = Fusion.peek(v4.Goal)
		local current = Fusion.peek(v4.Current)
		local parent = guiObject and guiObject.Parent
		local v5 = current == goal or not parent

		if parent then
			Apply(v4.Things, current)

			if v4.Update then
				v4.Update(guiObject, current)
			end
		end

		if v5 then
			Fusion.doCleanup(v4.Scope)
			v[guiObject] = nil
		end
	end)
	v[guiObject] = v4
	return v4
end

function v2.Hide(data)
	if typeof(data) ~= "table" then
		return
	end

	local holder = data.Holder
	local speed

	if typeof(data.Speed) == "number" then
		speed = data.Speed or nil
	end

	local delay

	if typeof(data.Delay) == "number" then
		delay = data.Delay or nil
	end

	local update

	if typeof(data.Update) == "function" then
		update = data.Update or nil
	end

	if typeof(delay) == "number" and delay > 0 then
		Apply(GetThings(holder), 0)
		task.delay(delay, v2.Hide, {
			Holder = holder,
			Speed = speed,
			Update = update
		})
	else
		local handler = GetHandler(holder, 0, speed, update)

		if not handler then
			return
		end

		handler.Goal:set(1)
	end
end

function v2.Show(data)
	if typeof(data) ~= "table" then
		return
	end

	local holder = data.Holder
	local speed

	if typeof(data.Speed) == "number" then
		speed = data.Speed or nil
	end

	local delay

	if typeof(data.Delay) == "number" then
		delay = data.Delay or nil
	end

	local update

	if typeof(data.Update) == "function" then
		update = data.Update or nil
	end

	if delay then
		Apply(GetThings(holder), 1)
		task.delay(delay, v2.Show, {
			Holder = holder,
			Speed = speed,
			Update = update
		})
	else
		local handler = GetHandler(holder, 1, speed, update)

		if not handler then
			return
		end

		handler.Goal:set(0)
	end
end

return table.freeze(v2)