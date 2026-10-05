local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local items = require(ReplicatedStorage.shared.modules.library.items)
local gliderdata = require(ReplicatedStorage.shared.modules.library.items.gliderdata)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local Item = {}

function Item.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local item = items.Items[data.Name]
	local v = gliderdata[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = v and "Glider" or "Item"
	clone.icon.Image = data.Icon or item.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function Item.LoadScene(object, p, p2)
	local _ = items.Items[p.Name]
	local v = gliderdata[p.Name]
	local clone = assets.getAsync("item", p.Name):Clone()
	local folder = clone:FindFirstChild(p.Name)

	if v then
		for _, part in folder:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			if part.Transparency >= 1 and part:FindFirstAncestor("Details") then
				part:Destroy()
			else
				part.Anchored = true
			end
		end

		local handle = folder:FindFirstChild("handle")

		if handle then
			handle.CFrame += createVector(0, 3, 0)
		end
	end

	object:IgnorePerformance(clone)
	object:CreatePodium(folder, p2)
	folder:PivotTo(folder:GetPivot() * CFrame.fromOrientation(0, 3.141592653589793, 0))

	if not p2 then
		local stats = {}

		if v then
			if v.UseCameraPhysics then
				table.insert(stats, "Glider Type: Hang Glider")
				table.insert(stats, (`Max Speed: {v.MaxMomentum} S/ps`))
			else
				table.insert(stats, "Glider Type: Standard")
				table.insert(stats, (`Speed: +{v.SpeedBoost} S/ps`))
			end
		end

		object:SetInfo({
			Description = nil,
			Stats = stats
		})
	end
end

return Item