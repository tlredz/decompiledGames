local Spring = require(script.Parent:WaitForChild("Spring"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local Fade = {
	PROPS = {
		Frame = { "BackgroundTransparency" },
		ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
		ImageButton = { "BackgroundTransparency", "ImageTransparency" },
		TextLabel = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
		TextButton = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
		TextBox = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
		ViewportFrame = { "BackgroundTransparency", "ImageTransparency" },
		ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" },
		CanvasGroup = { "BackgroundTransparency", "GroupTransparency" },
		UIStroke = { "Transparency" },
		UIShadow = { "Transparency" }
	},
	property = function(instance)
		if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			return "ImageTransparency"
		end

		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			return "TextTransparency"
		end

		if instance:IsA("UIStroke") or instance.ClassName == "UIShadow" then
			return "Transparency"
		end

		if instance:IsA("CanvasGroup") then
			return "GroupTransparency"
		end

		return "BackgroundTransparency"
	end
}
local class = {}
class.__index = class
local v = Store.new()

local function collect(folder, entries, skip, known)
	local function record(instance)
		if skip and skip(instance) then
			return
		end

		local v2 = Fade.PROPS[instance.ClassName]

		if not v2 then
			return
		end

		local v3 = known and known[instance]

		for _, prop in ipairs(v2) do
			local base = v3 and v3[prop]

			if base == nil then
				base = instance[prop]

				if base >= 1 then
					if known then
						v3 = v3 or {}
						known[instance] = v3
						v3[prop] = false
					end

					base = nil
				elseif known then
					v3 = v3 or {}
					known[instance] = v3
					v3[prop] = base
				end
			elseif base == false then
				base = nil
			end

			if base ~= nil then
				entries[#entries + 1] = {
					inst = instance,
					prop = prop,
					base = base
				}
			end
		end
	end

	record(folder)

	for _, valueBase in ipairs(folder:GetDescendants()) do
		if not valueBase:IsA("ValueBase") then
			record(valueBase)
		end
	end
end

function Fade.group(p, p2)
	local v2 = v[p]

	if v2 then
		return v2
	end

	local object = setmetatable({}, class)
	object.root = p
	object.entries = {}
	object.skip = p2 and p2.Skip
	object.hidden = 0
	object.known = Store.new()
	collect(p, object.entries, object.skip, object.known)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "FadeDriver"
	numberValue.Value = 0
	numberValue.Parent = p
	object.driver = numberValue
	object.connection = numberValue.Changed:Connect(function(p3)
		local hidden = object.hidden

		if p3 ~= hidden and (p3 <= 0 or p3 >= 1 or math.abs(p3 - hidden) >= 0.0009765625) then
			object:_write(p3)
		end
	end)
	v[p] = object
	return object
end

function class:_write(hidden)
	self.hidden = hidden
	local entries = self.entries

	for i = 1, #entries do
		local entry = entries[i]
		local inst = entry.inst

		if inst.Parent then
			inst[entry.prop] = entry.base + (1 - entry.base) * hidden
		end
	end
end

function class:Refresh()
	table.clear(self.entries)
	collect(self.root, self.entries, self.skip, self.known)
	self:_write(self.hidden)
end

function class:Apply(p)
	spr.stop(self.driver)
	self:_write(p)
	self.driver.Value = p
end

function class:Spring(p2, p3)
	Spring.to(self.driver, p3 or p2 > 0.5 and "CloseFade" or "OpenFade", {
		Value = p2
	})
end

function class:Completed(p2)
	spr.completed(self.driver, p2)
end

function class:Destroy()
	spr.stop(self.driver)
	self.connection:Disconnect()
	self.driver:Destroy()
	v[self.root] = nil
end

function Fade.show(p, value)
	Fade.group(p):Spring(0, value or "OpenFade")
end

function Fade.hide(p, value, p2)
	local scope = Fade.group(p)
	scope:Spring(1, value or "CloseFade")

	if p2 then
		scope:Completed(p2)
	end
end

function Fade.has(p)
	return v[p] ~= nil
end

return Fade