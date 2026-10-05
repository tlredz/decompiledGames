local InstanceUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Promise = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Promise"))
local v = {
	Transparency = {
		"BasePart",
		"UIStroke",
		"Decal",
		"Texture",
		"Beam"
	},
	BackgroundTransparency = { "GuiObject" },
	TextTransparency = { "TextLabel", "TextButton" },
	TextStrokeTransparency = { "TextLabel", "TextButton" },
	ImageTransparency = { "ImageLabel", "ImageButton", "ViewportFrame" }
}
local v2 = {
	Enabled = { "ParticleEmitter" }
}
local tweenInfo = TweenInfo.new(0)

function InstanceUtil.onDestroyed(instance, callback)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ancestryChangedConnection:Disconnect()
			callback()
		end
	end)

	if not instance.Parent then
		ancestryChangedConnection:Disconnect()
		callback()
	end

	return ancestryChangedConnection
end

function InstanceUtil.hide(p, p2, callback)
	local v3 = typeof(p) == "table" and p or { p }

	for k, v4 in pairs(v) do
		for _, className in pairs(v4) do
			for _, beam in pairs(v3) do
				if not beam:IsA(className) then
					continue
				end

				local formatted = ("%s_%s"):format("_InstanceUtilShowHide", k)

				if not beam:GetAttribute(formatted) then
					beam:SetAttribute(formatted, beam[k])
				end

				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new(1)
				else
					TweenService:Create(beam, p2, {
						[k] = 1
					}):Play()
				end
			end
		end
	end

	for k, v4 in pairs(v2) do
		for _, className in pairs(v4) do
			for _, v5 in pairs(v3) do
				if not v5:IsA(className) then
					continue
				end

				local formatted = ("%s_%s"):format("_InstanceUtilShowHide", k)

				if not v5:GetAttribute(formatted) then
					v5:SetAttribute(formatted, v5[k])
				end

				v5[k] = false
			end
		end
	end

	if callback then
		task.delay(p2 and p2.Time or tweenInfo.Time, callback)
	end
end

function InstanceUtil.show(p, p2, callback)
	local v3 = typeof(p) == "table" and p or { p }

	for k, v4 in pairs(v) do
		for _, className in pairs(v4) do
			for _, beam in pairs(v3) do
				if not beam:IsA(className) then
					continue
				end

				local attribute = beam:GetAttribute((("%s_%s"):format("_InstanceUtilShowHide", k))) or 0

				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new(0)
				else
					TweenService:Create(beam, p2, {
						[k] = attribute
					}):Play()
				end
			end
		end
	end

	for k, v4 in pairs(v2) do
		for _, className in pairs(v4) do
			for _, v5 in pairs(v3) do
				if not v5:IsA(className) then
					continue
				end

				local formatted = ("%s_%s"):format("_InstanceUtilShowHide", k)
				v5[k] = v5:GetAttribute(formatted) == nil or v5:GetAttribute(formatted)
			end
		end
	end

	if callback then
		task.delay(p2 and p2.Time or tweenInfo.Time, callback)
	end
end

function InstanceUtil:setProperties(items)
	for k, item in pairs(items) do
		self[k] = item
	end
end

function InstanceUtil.takeExplorerScreenshotOfInstanceHeirachy(instance)
	local v3 = {}
	local result = {}

	for _, child in pairs(instance:GetChildren()) do
		local name = child.Name

		if v3[name] then
			name ..= (" (%d)"):format(v3[name] + 1)
		end

		v3[name] = (v3[name] or 0) + 1
		result[name] = InstanceUtil.takeExplorerScreenshotOfInstanceHeirachy(child)
	end

	return result
end

function InstanceUtil.convert(instance, className: string)
	local instance2 = Instance.new(className)
	instance2.Name = instance.Name
	instance2.Parent = instance.Parent

	for _, child in pairs(instance:GetChildren()) do
		child.Parent = instance2
	end

	instance:Destroy()
end

function InstanceUtil.waitForPath(instance, value: string, value2: number?)
	local v3 = value2 or 60
	return Promise.new(function(callback, callback2)
		local child = instance

		if v3 then
			task.delay(v3, function()
				callback2((`InstanceUtil.waitForPath timed out after {v3} seconds. Parent: {instance:GetFullName()}  Path: {value}  Got to: {child:GetFullName()}`))
			end)
		end

		local parts = value:split("/")

		for _, childName in pairs(parts) do
			child = child:WaitForChild(childName)
		end

		callback(child)
	end)
end

function InstanceUtil.findFirstDescendant(instance, callback)
	for _, child in pairs(instance:GetChildren()) do
		if callback(child) then
			return child
		end
	end

	for _, child in pairs(instance:GetChildren()) do
		local firstDescendant = InstanceUtil.findFirstDescendant(child, callback)

		if firstDescendant then
			return firstDescendant
		end
	end
end

return InstanceUtil