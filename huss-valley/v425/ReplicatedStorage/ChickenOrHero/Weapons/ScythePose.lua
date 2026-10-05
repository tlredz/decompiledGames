local v = {}
local v2 = {
	{ 0, -23.2023 },
	{ 0.0263158, -23.8203 },
	{ 0.0526316, -24.3125 },
	{ 0.0789474, -24.7376 },
	{ 0.1052632, -24.8749 },
	{ 0.131579, -23.8196 },
	{ 0.1578947, -19.3039 },
	{ 0.1842105, -5.9943 },
	{ 0.2105263, 27.6341 },
	{ 0.2368421, 82.9123 },
	{ 0.2631579, 132.0323 },
	{ 0.2894737, 159.1408 },
	{ 0.3157895, 165.5134 },
	{ 0.3421053, 163.3501 },
	{ 0.3684211, 158.9437 },
	{ 0.3947368, 155.0231 },
	{ 0.4210527, 151.7035 },
	{ 0.4473684, 149.1205 },
	{ 0.4736842, 147.37 },
	{ 0.5, 146.4846 },
	{ 0.5263158, 147.4136 },
	{ 0.5526316, 152.0685 },
	{ 0.5789474, 157.6169 },
	{ 0.6052632, 159.5907 },
	{ 0.631579, 17.2384 },
	{ 0.6578947, -20.4119 },
	{ 0.6842105, -41.8735 },
	{ 0.7105263, -59.2729 },
	{ 0.7368421, -61.4298 },
	{ 0.7631579, -51.9283 },
	{ 0.7894737, -42.4804 },
	{ 0.8157895, -36.581 },
	{ 0.8421053, -34.3622 },
	{ 0.8684211, -35.484 },
	{ 0.8947368, -39.4032 },
	{ 0.9210526, -45.0567 },
	{ 0.9473685, -48.2368 },
	{ 0.9736842, -48.2466 },
	{ 1, -48.2575 }
}

function v.angle(value)
	local v3 = math.clamp(value or 0, 0, 1)
	local v4 = v2[1]

	for i = 2, #v2 do
		local v5 = v2[i]

		if v3 <= v5[1] then
			local v6 = (v3 - v4[1]) / (v5[1] - v4[1])
			return (math.rad(v4[2] + (v5[2] - v4[2]) * v6))
		else
			v4 = v5
		end
	end

	return (math.rad(v4[2]))
end

function v.new(instance)
	if instance:GetAttribute("WeaponStyle") ~= "Scythe" then
		return nil
	end

	local handle = instance:FindFirstChild("Handle")
	local blade = instance:FindFirstChild("Blade")
	local bladeWeld = handle and handle:FindFirstChild("BladeWeld")
	local gripPoint = blade and blade:FindFirstChild("GripPoint")

	if bladeWeld and bladeWeld:IsA("Weld") and gripPoint and gripPoint:IsA("Attachment") then
		local C0 = bladeWeld.C0
		return {
			weld = bladeWeld,
			recoveryLift = instance:GetAttribute("DiveRecoveryLiftDegrees"),
			recoveryTurn = instance:GetAttribute("DiveRecoveryTurnDegrees"),
			base = C0,
			gripInHandle = C0 * bladeWeld.C1:Inverse() * gripPoint.CFrame,
			gripInverse = gripPoint.CFrame:Inverse(),
			c1 = bladeWeld.C1
		}
	else
		return nil
	end
end

function v.restore(p)
	if p and p.weld.Parent then
		p.weld.C0 = p.base
	end
end

function v.apply(data, value, value2)
	if not (data and data.weld.Parent) then
		return
	end

	local v3 = math.clamp(value2 or 0, 0, 1)

	if v3 < 0.001 then
		v.restore(data)
		return
	end

	local v4

	if type(data.recoveryLift) == "number" then
		local v5 = math.clamp(((value or 0) - 0.5) / 0.25, 0, 1)
		local v6 = v5 * v5 * (3 - v5 * 2) * v3
		v4 = math.rad(data.recoveryLift) * v6
		local _ = math.rad(data.recoveryTurn or 0) * v6
	else
		v4 = 0
	end

	data.weld.C0 = data.gripInHandle * CFrame.Angles(0, 0, v.angle(value) * v3) * CFrame.Angles(v4, 0, 0) * data.gripInverse * data.c1
end

return table.freeze(v)