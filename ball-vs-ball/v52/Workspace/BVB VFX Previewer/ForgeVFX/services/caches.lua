local createVector = vector.create
local module = require("../obj/ObjectCache")
local module2 = require("../mod/utility")
return {
	init = function(list)
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Locked = true
		local folder = Instance.new("Folder")
		folder.Name = "DO_NOT_REMOVE_ForgeSharedPartCache"
		folder.Archivable = false
		folder.Parent = workspace.Terrain
		module2.protectParent(list, folder)
		local shared_part = module.new(part, folder, {
			size = 150,
			on_free = function(p)
				local value = p.value
				value.Transparency = 1
				value.Anchored = true
				value.CanQuery = false
				value.CanCollide = false
				value.CollisionGroup = "ForgeMouseIgnore"
				value.AssemblyLinearVelocity = createVector(0, 0, 0)
				value.AssemblyAngularVelocity = createVector(0, 0, 0)
				value.Parent = folder
				value:ClearAllChildren()
			end
		})
		table.insert(list, function()
			shared_part:destroy()
		end)
		return {
			shared_part = shared_part
		}
	end
}