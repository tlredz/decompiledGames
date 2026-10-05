game:GetService("TweenService")
local Players = game:GetService("Players")
local module = require("@game/ReplicatedStorage/Packages/Observers")
local module2 = require("@game/ReplicatedStorage/Packages/Trove")
require("@game/ReplicatedStorage/Common/Utils/Utilities/Inst")
local module3 = require("@game/ReplicatedStorage/Common/Logger")
local scope = module3.namespace("Accessories", {
	enabled = false
}):scope("ProyectionAccessory")
local trails = script.Trails
return module.observeTag("ProyectionAccessory", function(instance)
	local parent = instance.Parent.Parent

	if not Players:GetPlayerFromCharacter(parent) then
		return
	end

	local humanoid = parent:WaitForChild("Humanoid", 30)

	if not (parent:WaitForChild("HumanoidRootPart", 30) and humanoid and instance and instance:IsDescendantOf(parent)) then
		scope:warn("Accessory is not a descendant of character", parent, instance)
		return
	end

	local maid = module2.new()
	local v = {}
	local v2 = false

	local function enableParticles(enabled)
		if enabled == v2 then
			return
		end

		v2 = enabled
		scope:info("Enabling particles", enabled)

		for _, v3 in v do
			v3.Enabled = enabled
		end
	end

	local function attachTrails(instance2)
		scope:info("Attaching trails", instance2)
		local v3 = maid:Add(instance2:Clone())

		for _, child in v3:GetChildren() do
			local parent2 = parent:QueryDescendants((`BasePart[Name="{child.Name}"]`))[1]

			if parent2 then
				for _, v5 in child:QueryDescendants("ParticleEmitter") do
					maid:Add(v5)
					v5.Enabled = false
					table.insert(v, v5)
				end

				for _, v5 in child:QueryDescendants(">Attachment") do
					maid:Add(v5)
					v5.Parent = parent2
				end
			else
				scope:warn("Could not find part", child, "in character", parent)
			end
		end

		v3:Destroy()
		scope:info("Attached trails", #v)
	end

	maid:Add(task.delay(1, attachTrails, trails))
	maid:Add(task.spawn(function()
		scope:info("Starting accessory")

		while true do
			if humanoid.MoveDirection.Magnitude > 0 then
				if v2 ~= true then
					v2 = true
					scope:info("Enabling particles", true)

					for _, v3 in v do
						v3.Enabled = true
					end
				end
			elseif v2 ~= false then
				v2 = false
				scope:info("Enabling particles", false)

				for _, v3 in v do
					v3.Enabled = false
				end
			end

			task.wait()
		end
	end))
	return function()
		scope:warn("Cleaning up accessory")
		maid:Destroy()
		maid = nil
	end
end)