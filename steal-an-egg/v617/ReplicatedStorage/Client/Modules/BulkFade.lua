local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Cubic)
local v = {
	ImageButton = true,
	ImageLabel = true
}
local v2 = {
	TextLabel = true,
	TextButton = true,
	TextBox = true
}
local v3 = {
	ScrollingFrame = true
}

local function GetTransparencyProperties(guiBase)
	local v4 = {}
	pcall(function()
		if guiBase.Transparency and type(guiBase.Transparency) ~= "userdata" and not guiBase:IsA("GuiBase") then
			v4.Transparency = guiBase.Transparency
		end
	end)
	pcall(function()
		if guiBase.BackgroundTransparency and type(guiBase.BackgroundTransparency) ~= "userdata" then
			v4.BackgroundTransparency = guiBase.BackgroundTransparency
		end
	end)

	if v[guiBase.ClassName] then
		v4.ImageTransparency = guiBase.ImageTransparency
	end

	if v2[guiBase.ClassName] then
		v4.TextTransparency = guiBase.TextTransparency
		v4.TextStrokeTransparency = guiBase.TextStrokeTransparency
	end

	if v3[guiBase.ClassName] then
		v4.ScrollBarImageTransparency = guiBase.ScrollBarImageTransparency
	end

	if v4 == {} then
		return
	else
		return v4
	end
end

local function ReturnPropertiesAtValue(items, p: number)
	for k, _ in pairs(items) do
		items[k] = items[k] == 1 and 1 or p
	end

	return items
end

local class = {}
class.__index = class

function class.new(folder, p, value: number?)
	local object = setmetatable({}, class)
	object.TweenInfo = p or tweenInfo
	object.AppearTweens = {}
	object.DisappearTweens = {}
	object.Elements = {}
	object.GoalTransparency = value or 1
	object.new = nil
	object:AddObject(type(folder) ~= "table" and { folder, table.unpack(folder:GetDescendants()) } or folder)
	return object
end

function class:AddObject(list)
	if type(list) == "table" then
		for _, v4 in ipairs(list) do
			self:AddObject(v4)
		end
	else
		local transparencyProperties = GetTransparencyProperties(list)

		if transparencyProperties then
			table.insert(self.Elements, list)
			self.AppearTweens[list] = TweenService:Create(list, self.TweenInfo, transparencyProperties)
			local disappearTweens = self.DisappearTweens
			local tweenInfo2 = self.TweenInfo
			local goalTransparency = self.GoalTransparency

			for k, _ in pairs(transparencyProperties) do
				transparencyProperties[k] = transparencyProperties[k] == 1 and 1 or goalTransparency
			end

			disappearTweens[list] = TweenService:Create(list, tweenInfo2, transparencyProperties)
		end
	end
end

function class:RemoveObject(list)
	if type(list) == "table" then
		for _, v4 in ipairs(list) do
			self:RemoveObject(v4)
		end
	else
		self.AppearTweens[list] = nil
		self.DisappearTweens[list] = nil
		local index = table.find(self.Elements, list)

		if index then
			table.remove(self.Elements, index)
		end
	end
end

function class.FadeOut(p)
	for _, disappearTween in pairs(p.DisappearTweens) do
		disappearTween:Play()
	end

	return p.DisappearTweens[p.Elements[1]].Completed
end

function class.FadeOutInstant(p)
	for _, element in p.Elements do
		local transparencyProperties = GetTransparencyProperties(element)

		for k in transparencyProperties do
			element[k] = 1
		end
	end
end

function class.FadeIn(p)
	for _, appearTween in pairs(p.AppearTweens) do
		appearTween:Play()
	end

	return p.AppearTweens[p.Elements[1]].Completed
end

return (setmetatable(class, {
	__call = class.new
}))