local createVector = vector.create
local insert = table.insert
local remove = table.remove
local Workspace = game:GetService("Workspace")
local folder = Instance.new("Folder")
folder.Name = "PartCache"
folder.Parent = Workspace.Debree
local folder2 = Instance.new("Folder")
folder2.Name = "Temp"
folder2.Parent = folder
local smoothPlastic = Enum.Material.SmoothPlastic
local smoothNoOutlines = Enum.SurfaceType.SmoothNoOutlines
local mediumstonegrey = BrickColor.new("Medium stone grey")

function DefaultSettings(instance, flag: boolean?)
	instance.Size = createVector(0.01, 0.01, 0.01)
	instance.Position = createVector(0, -1000, 0)
	instance.Parent = folder
	instance.TopSurface = smoothNoOutlines
	instance.BottomSurface = smoothNoOutlines
	instance.Transparency = 1
	instance.MaterialVariant = ""
	instance.Reflectance = 0
	instance.CanTouch = false
	instance.CanQuery = false
	instance.Anchored = true
	instance.BrickColor = mediumstonegrey
	instance.Material = smoothPlastic

	if flag ~= true then
		local children = instance:GetChildren()

		for i = 1, #children do
			children[i]:Destroy()
		end
	end
end

local PartCache = {
	IdleCount = 75,
	Holder = {}
}

for _ = 1, 75 do
	local part = Instance.new("Part")
	DefaultSettings(part, true)
	insert(PartCache.Holder, part)
end

function PartCache.GetPart()
	if PartCache.IdleCount > 0 then
		local v = PartCache.Holder[1]
		v.Transparency = 0
		v.Size = createVector(1, 1, 1)

		if v.Parent == nil then
			v.Parent = folder
		end

		PartCache.IdleCount -= 1
		remove(PartCache.Holder, 1)
		return v
	else
		local part = Instance.new("Part")
		part.Parent = folder2
		part.TopSurface = smoothNoOutlines
		part.BottomSurface = smoothNoOutlines
		part.Size = createVector(1, 1, 1)
		return part
	end
end

function PartCache.DeletePart(instance)
	if instance.Parent == folder2 then
		instance:Destroy()
		return
	end

	DefaultSettings(instance)
	PartCache.IdleCount += 1
	insert(PartCache.Holder, instance)
end

return PartCache