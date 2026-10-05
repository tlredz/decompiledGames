local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local assets = require(ReplicatedStorage.shared.utils.assets)
local UI = script.Parent.Parent.UI
require("../Types")
local Boat = {}

function Boat.GetBoothButton(_, data)
	local clone = UI.boothEntry:Clone()
	local v = vessels.library[data.Name]
	clone.Name = data.Name
	clone.detail.itemName.Text = data.Name
	clone.detail.itemType.Text = "Boat"
	clone.icon.Image = data.Icon or v.Icon or ""

	if data.Price == -1 then
		clone.price.Text = "Trading Only"
		return clone
	end

	clone.price.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	return clone
end

function Boat.LoadScene(object, p, p2)
	local v = vessels.library[p.Name]
	local clone = assets.getAsync("vessel", p.Name):Clone()

	if clone:FindFirstChild("PlanePart") then
		clone.PlanePart:Destroy()
	end

	object:IgnorePerformance(clone)
	object:CreatePodium(clone, p2)
	clone:PivotTo(clone:GetPivot() * CFrame.fromOrientation(0, 1.5707963267948966, 0))

	if not p2 then
		local v2 = #clone:QueryDescendants("Seat, VehicleSeat")
		local stats = {
			`Speed: {v.MaxSpeed} S/ps`,
			`Steering: {math.round(v.TurningSpeed * 100)}°`,
			`Acceleration: {tonumber(string.format("%.3f", v.Accel))} S/ps`,
			(`Seats: {v2}`)
		}

		if v.Durability then
			table.insert(stats, (`Durability: {v.Durability}`))
		end

		if v.IsSubmarine then
			table.insert(stats, (`Vertical Speed: {v.SubmarineVerticalSpeed or 50}`))
		elseif v.FlyingBoat then
			table.insert(stats, (`Vertical Speed: {v.VerticalMaxSpeed}`))
		end

		object:SetInfo({
			Description = v.Description,
			Stats = stats
		})
	end
end

return Boat