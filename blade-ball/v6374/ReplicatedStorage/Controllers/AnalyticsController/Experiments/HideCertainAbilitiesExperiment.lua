local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Types.Analytics)
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Controllers.UI.ShopController)
local v2 = {
	Platform = "Super Jump",
	["Quad Jump"] = "Super Jump",
	["Wind Cloak"] = "Thunder Dash",
	["Shadow Step"] = "Thunder Dash",
	Swap = "Blink"
}
local v3 = {
	"Time Hole",
	"Dragon Spirit",
	"Dribble",
	"Tact",
	"Calming Deflection",
	"Death Slash",
	"Titan Blade",
	"Phantom",
	"Continuity Zero",
	"Waypoint",
	"Rapture",
	"Infinity",
	"Freeze Trap",
	"Force",
	"Serpent Shadow Clone",
	"Quantum Arena",
	"Singularity",
	"Slash of Duality",
	"Water Dragon"
}
return {
	RemoteConfig = "HideCertainAbilities",
	DefaultValue = false,
	Disabled = true,
	Configs = {
		[true] = function(_)
			v.Client:WaitReplion("Data")

			local function toggleVisibility(childName: string, flag: boolean)
				local child = ReplicatedStorage2.Misc.DataAbilities:FindFirstChild(childName)

				if not child then
					return
				end

				if not flag and child:GetAttribute("_OriginalHidden") == nil then
					child:SetAttribute("_OriginalHidden", child:GetAttribute("Hidden") == true)
				end

				if not flag ~= flag then
					if flag then
						child:SetAttribute("Hidden", (child:GetAttribute("_OriginalHidden")))
					else
						child:SetAttribute("Hidden", true)
					end
				end
			end

			local v4 = nil

			local function updateAbilities()
				local names = {}

				for _, v5 in client:Get("Ability") or {} do
					if v5.Name then
						table.insert(names, v5.Name)
					end
				end

				local v5 = #names >= 7
				local v6 = false

				for _, v8 in v3 do
					if not table.find(names, v8) then
						continue
					end

					v6 = true
					break
				end

				local v8 = v6 or v5

				if v8 and v4 then
					v4:Destroy()
					v4 = nil
				end

				for _, v9 in v3 do
					toggleVisibility(v9, v8)
				end

				for k, v9 in v2 do
					local v10 = #client:FindItems("Ability", v9) > 0
					toggleVisibility(k, v8 or v10)
				end
			end

			v4 = client:OnChange("Ability", updateAbilities)
			updateAbilities()
		end
	}
}