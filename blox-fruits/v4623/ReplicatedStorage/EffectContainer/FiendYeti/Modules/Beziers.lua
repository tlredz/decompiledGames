local Beziers = {
	Linear = function(p, p2, p3, p4, p5)
		local v = p / 100
		local v2 = v >= 1 and 1 or v

		if not (p2 and p3) then
			return
		end

		if not (p4 and p4[p5]) then
			return p2 + v2 * (p3 - p2)
		end

		if p5 ~= "CFrame" then
			p4[p5] = p2 + v2 * (p3 - p2)
			return
		end

		local p6 = p2.p
		local p7 = p3.p
		p4[p5] = CFrame.new(p6 + v2 * (p7 - p6))
	end,
	Quadratic = function(p, p2, p3, p4, model, p5)
		local v = p / 100
		local v2 = v >= 1 and 1 or v

		if not (p2 and p3 and p4) then
			return
		end

		if not model or not (model:IsA("Model") and model.PrimaryPart.Position) and model[p5] == nil then
			return (1 - v2) ^ 2 * p2 + 2 * (1 - v2) * v2 * p3 + v2 ^ 2 * p4
		end

		if p5 == "CFrame" then
			local p6 = p2.p
			local p7 = p3.p
			local p8 = p4.p

			if model:IsA("Model") then
				model:SetPrimaryPartCFrame(CFrame.new((1 - v2) ^ 2 * p6 + 2 * (1 - v2) * v2 * p7 + v2 ^ 2 * p8))
			else
				model.CFrame = CFrame.new((1 - v2) ^ 2 * p6 + 2 * (1 - v2) * v2 * p7 + v2 ^ 2 * p8)
			end

			print("x")
		elseif model:IsA("Model") then
			model:SetPrimaryPartCFrame(CFrame.new((1 - v2) ^ 2 * p2 + 2 * (1 - v2) * v2 * p3 + v2 ^ 2 * p4))
		else
			model[p5] = (1 - v2) ^ 2 * p2 + 2 * (1 - v2) * v2 * p3 + v2 ^ 2 * p4
		end
	end,
	Cubic = function(p, p2, p3, p4, p5, p6, p7)
		local v = p / 100
		local v2 = v >= 1 and 1 or v

		if not (p2 and p3 and p4 and p5) then
			return
		end

		if not (p6 and p6[p7]) then
			return (1 - v2) ^ 3 * p2 + 3 * (1 - v2) ^ 2 * v2 * p3 + 3 * (1 - v2) * v2 ^ 2 * p4 + v2 ^ 3 * p5
		end

		if p7 ~= "CFrame" then
			p6[p7] = (1 - v2) ^ 3 * p2 + 3 * (1 - v2) ^ 2 * v2 * p3 + 3 * (1 - v2) * v2 ^ 2 * p4 + v2 ^ 3 * p5
			return
		end

		local p8 = p2.p
		local p9 = p3.p
		local p10 = p4.p
		local p11 = p5.p
		local position = p6.Position
		p6[p7] = CFrame.new((1 - v2) ^ 3 * p8 + 3 * (1 - v2) ^ 2 * v2 * p9 + 3 * (1 - v2) * v2 ^ 2 * p10 + v2 ^ 3 * p11)
		p6[p7] = CFrame.new(p6.Position, position) * CFrame.Angles(0, 3.141592653589793, 0)
	end
}

function Beziers.Interpolate(p, p2, p3, p4, p5, ...)
	local lastTime = tick()
	local v = lastTime + p4
	local v2 = p3 - p2

	while tick() < v do
		local RunService = game:GetService("RunService")
		RunService.Heartbeat:wait()
		local v3 = p2 + v2 * ((tick() - lastTime) / p4)

		if p == "Linear" then
			Beziers.Linear(v3, ...)
		elseif p == "Quadratic" then
			Beziers.Quadratic(v3, ...)
		elseif p == "Cubic" then
			Beziers.Cubic(v3, ...)
		end
	end

	if p5 then
		spawn(p5)
	end
end

return Beziers