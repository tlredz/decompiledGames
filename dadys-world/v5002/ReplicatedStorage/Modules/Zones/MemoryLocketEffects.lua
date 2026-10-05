local createVector = vector.create
local MemoryLocketEffects = {}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Maid = require(ReplicatedStorage.Modules.Core.Maid)
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)

function MemoryLocketEffects.ClientAbility(_, instance, instance2)
	local humanoid = instance:WaitForChild("Humanoid")
	local active = instance2:WaitForChild("Active")
	local maid = nil
	local v = {
		Bandage = true,
		HealthKit = true
	}

	local function get_healing_items()
		local result = {}

		for _, v2 in pairs(CollectionService:GetTagged("Item")) do
			if v2:IsDescendantOf(workspace) and v[v2.Name] then
				result[#result + 1] = v2
			end
		end

		return result
	end

	local function set_active(flag: boolean, items)
		active.Value = flag == true

		if flag then
			if maid then
				return
			end

			maid = Maid.new()

			local function add_obj(instance3)
				local v2 = HighlightController:PlayHighlight(instance3, "Healing", {
					FillColor = Color3.fromRGB(168, 255, 160),
					FillTransparency = 1,
					OutlineColor = Color3.fromRGB(168, 255, 160),
					OutlineTransparency = 0,
					Priority = HighlightController.Priority.TRINKET,
					Billboard = {
						Label = "HEALING",
						Template = "HolidayWarningIcon",
						Size = UDim2.new(12, 0, 12, 0),
						StudsOffset = createVector(0, 5, 0)
					}
				})
				maid:GiveTask(function()
					if v2 and v2.Parent then
						v2:Destroy()
					end
				end)
			end

			maid:GiveTask(CollectionService:GetInstanceAddedSignal("Item"):Connect(function(instance3)
				if instance3:IsDescendantOf(workspace) and v[instance3.Name] then
					add_obj(instance3)
				end
			end))

			for _, item in pairs(items) do
				task.spawn(add_obj, item)
			end
		elseif maid then
			maid:Destroy()
			maid = nil
		end
	end

	local function update_hp()
		if humanoid.Health >= humanoid.MaxHealth then
			active.Value = false

			if maid then
				maid:Destroy()
				maid = nil
			end
		else
			local v2 = get_healing_items()

			if #v2 > 0 then
				set_active(true, v2)
				return
			end

			active.Value = false

			if maid then
				maid:Destroy()
				maid = nil
			end
		end
	end

	local function update_item_check()
		local v2 = get_healing_items()

		if #v2 == 0 then
			active.Value = false

			if maid then
				maid:Destroy()
				maid = nil
			end
		elseif humanoid.Health >= humanoid.MaxHealth then
			active.Value = false

			if maid then
				maid:Destroy()
				maid = nil
			end
		else
			set_active(true, v2)
		end
	end

	humanoid.HealthChanged:Connect(update_hp)
	CollectionService:GetInstanceAddedSignal("Item"):Connect(update_item_check)
	CollectionService:GetInstanceRemovedSignal("Item"):Connect(update_item_check)
	task.spawn(update_hp)
end

return MemoryLocketEffects