local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local t = require(ReplicatedStorage.Packages.t)
return {
	Apply = function(p, textColor: Color3, p2: number)
		t.strict(t.Instance)(p)
		t.strict(t.Color3)(textColor)
		t.strict(t.number)(p2)
		local speedPerSecond = p.SpeedPerSecond
		assert(speedPerSecond:IsA("BasePart"), (`Treadmill "{p.Name}" SpeedPerSecond must be a BasePart`))
		local billboardGui = speedPerSecond.BillboardGui
		assert(
			billboardGui:IsA("BillboardGui"),
			(`Treadmill "{p.Name}" SpeedPerSecond.BillboardGui must be a BillboardGui`)
		)
		local textLabel = billboardGui.Frame.TextLabel
		assert(
			textLabel:IsA("TextLabel"),
			(`Treadmill "{p.Name}" SpeedPerSecond.BillboardGui.Frame.TextLabel must be a TextLabel`)
		)
		textLabel.TextColor3 = textColor
		textLabel.Text = `+{addCommas(p2)}/step`
		return billboardGui
	end
}