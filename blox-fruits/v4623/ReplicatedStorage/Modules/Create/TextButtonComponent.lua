require(game.ReplicatedStorage.Modules.Util.Trove)
local class = {}
class.__index = class
local v = {
	Gift = "rbxassetid://11332562153"
}
local v2 = {
	Appearance = function(object, p, p2)
		if p == object.Instance then
			object:SetButtonAppearance(p2)
		end
	end,
	ImageId = function(_, p, p2)
		p.Image = v[p2] or p2
	end
}
local v3 = {
	Active = {
		TextButton = {
			BackgroundColor3 = Color3.fromRGB(255, 214, 49),
			BorderColor3 = Color3.fromRGB(255, 240, 69)
		},
		Trans = {
			BackgroundColor3 = Color3.fromRGB(255, 241, 87),
			BorderColor3 = Color3.fromRGB(27, 42, 53)
		},
		TextLabel = {
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		}
	},
	Inactive = {
		TextButton = {
			BackgroundColor3 = Color3.fromRGB(132, 132, 132),
			BorderColor3 = Color3.fromRGB(91, 91, 91)
		},
		Trans = {
			BackgroundColor3 = Color3.fromRGB(194, 194, 194),
			BorderColor3 = Color3.fromRGB(27, 42, 53)
		},
		TextLabel = {
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		}
	},
	Blue = {
		TextButton = {
			BackgroundColor3 = Color3.fromHex("#3E8CD0"),
			BorderColor3 = Color3.fromHex("#54ADE8")
		},
		Trans = {
			BackgroundColor3 = Color3.fromHex("#54ADE8"),
			BorderColor3 = Color3.fromRGB(27, 42, 53)
		},
		TextLabel = {
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		}
	}
}

function class:UpdateProperties(items)
	if not (items and next(items)) then
		return self
	end

	local fn

	fn = function(instance, p2)
		local visible

		if p2.Visible ~= nil then
			visible = p2.Visible
		end

		p2.Visible = nil

		if visible == false then
			instance.Visible = false
		end

		for childName, v4 in pairs(p2) do
			if v2[childName] then
				local v5 = childName
				local v6 = v4
				local success, result = pcall(function()
					v2[v5](self, instance, v6)
				end)

				if not success then
					print("UpdateProperties not valid", childName, result)
				end
			elseif typeof(v4) == "table" and instance:FindFirstChild(childName) then
				fn(instance[childName], v4)
			else
				local v5 = childName
				local v6 = v4

				if not pcall(function()
					instance[v5] = v6
				end) then
					print("IDK", childName, v4, debug.traceback())
				end
			end
		end

		if visible == true then
			instance.Visible = true
		end
	end

	fn(self.Instance, items)
	return self
end

function class:SetButtonAppearance(value: string)
	local v4 = value or "Active"

	if v4 ~= self.Appearance then
		self.Appearance = assert(v3[v4], (`bad buttonAppearance["{v4}"]`)) and v4
		local instance = self.Instance

		for k, v5 in pairs(v3[self.Appearance].TextButton) do
			instance[k] = v5
		end

		self:UpdateProperties({
			Trans = v3[self.Appearance].Trans
		})
		self:UpdateProperties({
			TextLabel = v3[self.Appearance].TextLabel
		})
	end
end

function class:Destroy()
	if self._DestroyOnCleanup and self.Instance and self.Instance.Parent then
		self.Instance:Destroy()
	end

	self.Instance = nil
end

return function(p, p2)
	return (setmetatable({
		Instance = p or script.Parent.Templates.TextButtonTemplate:Clone(),
		Appearance = "_None",
		_DestroyOnCleanup = p == nil
	}, class):UpdateProperties(p2))
end