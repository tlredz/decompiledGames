local module = require("@game/ReplicatedStorage/Omni")
local replication = workspace:WaitForChild("Server"):WaitForChild("Replication")
local v = {}
local Accessories = {}

local function ObserveAccessory(p, stringValue)
	if not stringValue:IsA("StringValue") or p.AccessoryConnections[stringValue] then
		return
	end

	p.AccessoryConnections[stringValue] = stringValue:GetPropertyChangedSignal("Value"):Connect(function()
		Accessories.Update(p.Name)
	end)
end

function Accessories.Setup(folder)
	if not folder:IsA("Folder") then
		return
	end

	local child = module.Services.Players:FindFirstChild(folder.Name)

	if not child then
		return
	end

	local v2 = {
		Player = child,
		Name = child.Name,
		PlayerFolder = folder,
		Connections = {},
		AccessoryConnections = {}
	}
	v2.Connections.Character = child.CharacterAdded:Connect(function()
		Accessories.Update(child.Name)
	end)
	v2.Connections.Appearance = child.CharacterAppearanceLoaded:Connect(function()
		Accessories.Update(child.Name)
	end)
	v2.Connections._Added = folder.ChildAdded:Connect(function()
		Accessories.Update(child.Name)
	end)
	v2.Connections.Destroyed = folder.AncestryChanged:Connect(function(_, parent)
		if not parent then
			for _, connection in v2.Connections do
				connection:Disconnect()
			end

			table.clear(v2.Connections)

			for _, accessoryConnection in v2.AccessoryConnections do
				accessoryConnection:Disconnect()
			end

			table.clear(v2.AccessoryConnections)
			v[child.Name] = nil
		end
	end)
	v[child.Name] = v2
	Accessories.Update(child.Name)
end

function Accessories.Update(p: string)
	local v2 = v[p]

	if not (v2 and v2.Player.Character) then
		return
	end

	local v3 = v2.Player == module.Instance
	local v4

	if v3 and not module.Data.Settings["Hide My Accessories"] or not (v3 or module.Data.Settings["Hide Other Accessories"]) then
		v4 = {}

		if not v2.AccessoriesFolder then
			local accessories = v2.PlayerFolder:FindFirstChild("Accessories")

			if accessories then
				v2.AccessoriesFolder = accessories
				v2.Connections.Added = accessories.ChildAdded:Connect(function(child)
					ObserveAccessory(v2, child)
					Accessories.Update(v2.Name)
				end)
				v2.Connections.Removed = accessories.ChildRemoved:Connect(function(child)
					local accessoryConnection = v2.AccessoryConnections[child]

					if accessoryConnection then
						accessoryConnection:Disconnect()
						v2.AccessoryConnections[child] = nil
					end

					Accessories.Update(v2.Name)
				end)

				for _, child in accessories:GetChildren() do
					ObserveAccessory(v2, child)
				end
			end
		end

		if v2.AccessoriesFolder then
			for _, stringValue in v2.AccessoriesFolder:GetChildren() do
				if stringValue:IsA("StringValue") then
					v4[stringValue.Name] = {
						Name = stringValue.Value
					}
				end
			end
		end
	end

	module.Utils.Accessories.EnsureAccessories(v2.Player.Character, v4)
end

function Accessories.UpdateAll()
	for k in v do
		Accessories.Update(k)
	end
end

module:OnDataChanged({ "Settings" }, Accessories.UpdateAll)
module.Utils.Instance:ObserveChilds(replication, Accessories.Setup)
return Accessories