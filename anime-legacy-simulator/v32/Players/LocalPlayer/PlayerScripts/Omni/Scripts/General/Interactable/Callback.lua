local module = require("@game/ReplicatedStorage/Omni")
local frames = module.Interface:WaitForChild("Frames")
local v = {}

local function CanAutoOpenDoor(instance)
	if not (module.Data.Settings["Auto Dungeon Doors"] == true and (instance.Enabled and instance:IsDescendantOf(workspace))) then
		return false
	end

	local HRP = module:GetHRP()
	local parent = instance.Parent

	if HRP and parent and parent:IsA("BasePart") then
		return (HRP.Position - parent.Position).Magnitude <= instance.MaxActivationDistance
	end

	return false
end

local Callback = {
	["Collect Fruit"] = {
		Prompt = function(instance)
			if not instance.Enabled then
				return
			end

			local fruitID = instance:GetAttribute("FruitID")

			if typeof(fruitID) ~= "string" then
				return
			end

			module.Signal:Fire("General", "Fruits", "Collect", fruitID)
		end
	},
	["Open Dungeon Door"] = {
		Prompt = function(instance)
			if not instance.Enabled then
				return
			end

			local roomIndex = instance:GetAttribute("RoomIndex")
			local childIndex = instance:GetAttribute("ChildIndex")

			if typeof(roomIndex) ~= "number" or typeof(childIndex) ~= "number" then
				return
			end

			module.Signal:Fire("General", "Gamemodes", "OpenDoor", roomIndex, childIndex)
		end,
		Shown = function(instance)
			if v[instance] or not CanAutoOpenDoor(instance) then
				return
			end

			local roomIndex = instance:GetAttribute("RoomIndex")
			local childIndex = instance:GetAttribute("ChildIndex")

			if typeof(roomIndex) ~= "number" or typeof(childIndex) ~= "number" then
				return
			end

			v[instance] = task.spawn(function()
				for _ = 1, 5 do
					if not CanAutoOpenDoor(instance) or module.Signal:Invoke(
						"General",
						"Gamemodes",
						"OpenDoor",
						roomIndex,
						childIndex
					) == true then
						break
					end

					task.wait(0.5)
				end

				v[instance] = nil
			end)
		end
	}
}

for k in module.Shared.Maps.List do
	local v2 = k
	local objectText = k
	Callback[`{k} Teleport`] = {
		Prompt = function(p)
			module.Signal:Fire("General", "Maps", "Teleport", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Teleport to"
			p.ObjectText = objectText
		end
	}
end

for k in module.Npcs do
	local v2 = k
	local objectText = k
	Callback[`{k} Dialog`] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Dialog", "Start", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Talk to"
			p.ObjectText = objectText
		end
	}
end

for k in module.Shared.Gacha.List do
	local v2 = k
	local objectText = k
	Callback[`{k} Gacha`] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Gacha", "Start", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Open"
			p.ObjectText = objectText
		end
	}
end

for _, guiObject in frames:GetChildren() do
	if not guiObject:IsA("GuiObject") then
		continue
	end

	local name = guiObject.Name
	local objectText = name
	Callback[`{name} Interface`] = {
		Prompt = function()
			module.Frame:Open(name)
		end,
		PromptSetup = function(p)
			p.ActionText = "Open"
			p.ObjectText = objectText
		end
	}
end

for k in module.Shared.Progression.List do
	local v2 = k
	local objectText = k
	Callback[`{k} Progression`] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Progression", "Start", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Open"
			p.ObjectText = objectText
		end
	}
end

for k, v2 in module.Shared.Gamemodes.List do
	local v3 = k
	local v4 = v2
	local objectText = k
	Callback[`{k} Gamemode`] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Gamemodes", "Start", v3)
		end,
		PromptSetup = function(p)
			p.ActionText = v4.Style == "Party" and "Open" or "Join"
			p.ObjectText = objectText
		end
	}
end

for k in module.Shared.Profession.List do
	local v2 = k
	local objectText = k
	Callback[`{k} Profession`] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Profession", "Start", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Open"
			p.ObjectText = objectText
		end
	}
end

for k in module.Shared.Upgrade.List do
	local v2 = k
	local objectText = k
	Callback[k .. " Upgrade"] = {
		Prompt = function()
			module.Signal:FireSelf("Interface", "Upgrade", "Start", v2)
		end,
		PromptSetup = function(p)
			p.ActionText = "Open"
			p.ObjectText = objectText
		end
	}
end

return Callback