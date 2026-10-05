local ReplicatedStorage = game:GetService("ReplicatedStorage")
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)

-- equivalent calls inferred from this helper; original call sites unknown
local function isTouch()
	return Platform_Handler.Platform.Value == "Mobile"
end

local HoverInfo = {}
HoverInfo.__index = HoverInfo
HoverInfo.Changed = simplesignal.new()
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function publish()
	if v == nil then
		HoverInfo.Changed:Fire(nil)
	else
		HoverInfo.Changed:Fire({
			Name = v.Name,
			Icons = v.Icons
		})
	end
end

function HoverInfo.Current()
	if v == nil then
		return nil
	end

	return {
		Name = v.Name,
		Icons = v.Icons
	}
end

local function show(p)
	if v == p then
		return
	end

	v = p
	publish() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hide(p)
	if v ~= p then
		return
	end

	v = nil
	publish() -- equivalent call inferred; original call site unknown
end

function HoverInfo:Enter()
	if isTouch() then
		if v == self then
			if v ~= self then
				return
			end

			v = nil
		else
			if v == self then
				return
			end

			v = self
		end
	else
		if self.Hovering then
			return
		end

		self.Hovering = true

		if v == self then
			return
		end

		v = self
	end

	publish() -- equivalent call inferred; original call site unknown
end

function HoverInfo:Leave()
	if isTouch() or not self.Hovering then
		return
	end

	self.Hovering = false
	hide(self) -- equivalent call inferred; original call site unknown
end

function HoverInfo:Hide()
	self.Hovering = false
	hide(self) -- equivalent call inferred; original call site unknown
end

function HoverInfo.Reset()
	local v2 = v
	v = nil

	if v2 ~= nil then
		v2.Hovering = false
	end

	publish() -- equivalent call inferred; original call site unknown
end

function HoverInfo:_unbind()
	if self._enter ~= nil then
		self._enter:Disconnect()
		self._enter = nil
	end

	if self._leave ~= nil then
		self._leave:Disconnect()
		self._leave = nil
	end

	if self._gone ~= nil then
		self._gone:Disconnect()
		self._gone = nil
	end
end

function HoverInfo:_bind()
	self:_unbind()
	local target = self.Target

	if target == nil or not target:IsA("GuiObject") then
		return
	end

	self._enter = target.MouseEnter:Connect(function()
		self:Enter()
	end)
	self._leave = target.MouseLeave:Connect(function()
		self:Leave()
	end)
	self._gone = target.Destroying:Once(function()
		self:Destroy()
	end)
end

function HoverInfo.new(target, name: string, icons)
	local self = setmetatable({
		Target = target,
		Name = name,
		Icons = icons,
		Hovering = false
	}, HoverInfo)
	self:_bind()
	return self
end

function HoverInfo:SetName(name: string)
	if self.Name == name then
		return
	end

	self.Name = name

	if v == self then
		publish() -- equivalent call inferred; original call site unknown
	end
end

function HoverInfo:SetIcons(icons)
	self.Icons = icons

	if v == self then
		publish() -- equivalent call inferred; original call site unknown
	end
end

function HoverInfo:SetTarget(target)
	if self.Target == target then
		return
	end

	hide(self) -- equivalent call inferred; original call site unknown
	self.Hovering = false
	self.Target = target
	self:_bind()
end

function HoverInfo:Refresh(target, name: string?, icons)
	if target ~= nil and target ~= self.Target then
		hide(self) -- equivalent call inferred; original call site unknown
		self.Hovering = false
		self.Target = target
		self:_bind()
	end

	if name ~= nil then
		self.Name = name
	end

	self.Icons = icons

	if v == self then
		publish() -- equivalent call inferred; original call site unknown
	end
end

function HoverInfo:Destroy()
	hide(self) -- equivalent call inferred; original call site unknown
	self.Hovering = false
	self:_unbind()
	self.Target = nil
end

return HoverInfo