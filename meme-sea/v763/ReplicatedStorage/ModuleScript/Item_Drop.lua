local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local assets = ReplicatedStorage:WaitForChild("Assets")
local sword = ServerStorage:WaitForChild("Sword")
local accessories = assets:WaitForChild("Accessories")
ServerStorage:WaitForChild("StorageItem")
local ItemSettings = require(moduleScript:WaitForChild("ItemSettings"))
require(moduleScript:WaitForChild("Setting"))
local SetText = require(moduleScript:WaitForChild("SetText"))
local ItemDrop = {}
local v = {
	["Big Floppa"] = {
		["Floppa Hat"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Walter Dog"] = {
		["Cheems Cola"] = {
			Item_Type = "Item",
			Drop_Chance = 15,
			Amount = 1
		},
		["Egg Doge"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Sus Face"] = {
		["Sus Face"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Gorilla King"] = {
		["Cat Food"] = {
			Item_Type = "Item",
			Drop_Chance = 15,
			Amount = 1
		},
		["Giant Banana"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	Obamid = {
		Obamid = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		},
		["Pixel Sword"] = {
			Item_Type = "Weapon",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Pink Absorber"] = {
		["Pink Hammer"] = {
			Item_Type = "Weapon",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	Moai = {
		["Noob Head"] = {
			Item_Type = "Item",
			Drop_Chance = 10,
			Amount = 1
		},
		["Moai Face"] = {
			Item_Type = "Accessory",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Rick Roller"] = {
		["Rick Buddy"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	MrBeast = {
		["Money Bag"] = {
			Item_Type = "Item",
			Drop_Chance = 15,
			Amount = 1
		},
		MrBeast = {
			Item_Type = "Accessory",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Super Popcat"] = {
		["Popcat Pet"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Reverse Master"] = {
		Card = {
			Item_Type = "Weapon",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	Baller = {
		Ball = {
			Item_Type = "Item",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Scary Skull"] = {
		["Flame Orb"] = {
			Item_Type = "Item",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Red Sus"] = {
		["Sussy Orb"] = {
			Item_Type = "Item",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Sus Duck"] = {
		["Sussy Orb"] = {
			Item_Type = "Item",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Giant Pumpkin"] = {
		["Nugget Man"] = {
			Item_Type = "Item",
			Drop_Chance = 25,
			Amount = 1
		},
		["Pumpkin Head"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Evil Noob"] = {
		["Yellow Blade"] = {
			Item_Type = "Weapon",
			Drop_Chance = 5,
			Amount = 1
		},
		["Noob Friend"] = {
			Item_Type = "Accessory",
			Drop_Chance = 5,
			Amount = 1
		}
	},
	["Lord Sus"] = {
		["Purple Katana"] = {
			Item_Type = "Weapon",
			Drop_Chance = 5,
			Amount = 1
		},
		["Sus Pals"] = {
			Item_Type = "Accessory",
			Drop_Chance = 10,
			Amount = 1
		}
	},
	["Meme Beast"] = {
		Portal = {
			Item_Type = "Weapon",
			Drop_Chance = 25,
			Amount = 1
		},
		["Meme Cube"] = {
			Item_Type = "Item",
			Drop_Chance = 50,
			Amount = 1
		}
	}
}

function ItemDrop.Check_Type(childName: string)
	if sword:FindFirstChild(childName) then
		return "Weapon"
	end

	if accessories:FindFirstChild(childName) then
		return "Accessory"
	end

	return "Item"
end

function ItemDrop.Check_ItemDrop(p: string)
	if v[p] then
		return true
	end
end

function ItemDrop.ItemDrop(p: string, instance)
	local v2 = v[p]

	if v2 then
		local items = instance:FindFirstChild("Items")
		local playerSpecial = instance:FindFirstChild("PlayerSpecial")

		if items and playerSpecial then
			for k, v3 in pairs(v2) do
				local doubleDrop = playerSpecial:FindFirstChild("DoubleDrop")
				local v4 = doubleDrop and doubleDrop.Value == true and v3.Drop_Chance < 100 and 2 or 1
				local v5 = {}

				for _ = 1, v3.Drop_Chance * v4 do
					table.insert(v5, k)
				end

				if #v5 < 100 then
					for _ = 1, 100 - #v5 do
						table.insert(v5, "None")
					end
				end

				local v6 = v5[math.random(1, #v5)]

				if not (v6 and v6 ~= "None") then
					continue
				end

				local check_Type = ItemDrop.Check_Type(v6)

				if not check_Type then
					continue
				end

				if check_Type == "Weapon" then
					local weapon = items:FindFirstChild("Weapon")

					if weapon then
						local child = weapon:FindFirstChild(v6)

						if child then
							if instance:GetAttribute("TH") then
								SetText.SetText(instance, "CustomMessage", {
									Message = `อาวุธดรอป : {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							else
								SetText.SetText(instance, "CustomMessage", {
									Message = `Weapon Drop: {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							end

							if child.Value < 1 then
								child.Value += 1
							end
						end
					end
				elseif check_Type == "Accessory" then
					local accessory = items:FindFirstChild("Accessory")

					if accessory then
						local child = accessory:FindFirstChild(v6)

						if child then
							if instance:GetAttribute("TH") then
								SetText.SetText(instance, "CustomMessage", {
									Message = `อุปกรณ์เสริมดรอป : {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							else
								SetText.SetText(instance, "CustomMessage", {
									Message = `Accessory Drop: {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							end

							if child.Value < 1 then
								child.Value += 1
							end
						end
					end
				elseif check_Type == "Item" then
					local itemStorage = items:FindFirstChild("ItemStorage")

					if itemStorage then
						local child = itemStorage:FindFirstChild(v6)

						if child then
							if instance:GetAttribute("TH") then
								SetText.SetText(instance, "CustomMessage", {
									Message = `ได้รับ {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							else
								SetText.SetText(instance, "CustomMessage", {
									Message = `Obtained {TextColor(`&lt;{v6}&gt;`, "100,215,255")} ({math.floor(v2[v6].Drop_Chance * v4)}%)`,
									Duration = 4
								})
							end

							if (not (ItemSettings[v6] and ItemSettings[v6].Max_Capacity) and 99 or ItemSettings[v6].Max_Capacity) > child.Value then
								child.Value += v2[v6].Amount or 1
							end
						end
					end
				end
			end
		end
	end
end

function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

return ItemDrop