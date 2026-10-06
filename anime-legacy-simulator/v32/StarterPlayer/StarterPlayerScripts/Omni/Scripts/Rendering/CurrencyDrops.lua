local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local currencyDrops = module.Assets:WaitForChild("Models"):WaitForChild("CurrencyDrops")
local v = {}
local CurrencyDrops = {}

function CurrencyDrops.Create(p: string, childName: string, amount: number, position: Vector3)
	if v[p] then
		return
	end

	local child = currencyDrops:FindFirstChild(childName)

	if child and not module.Data.Settings["Low Mode"] then
		local side = math.random(1, 2) == 1 and 1 or -1
		local clones = {}

		for _ = 1, math.random(3, 5) do
			local clone = child:Clone()
			clone:PivotTo(CFrame.new(position))
			clone.Parent = workspace.Cache
			table.insert(clones, clone)
		end

		v[p] = {
			Side = side,
			Models = clones,
			Name = childName,
			Amount = amount,
			Location = position,
			Time = os.clock(),
			Cache = {}
		}
		module.Sound:PlayEffect("Drop.Create", {
			Cooldown = 0.08
		})
	else
		v[p] = {
			Models = {}
		}
		CurrencyDrops.Collect(p)
	end
end

function CurrencyDrops.Collect(p: string)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, folder in v2.Models do
		local billboardGui = folder:FindFirstChildWhichIsA("BillboardGui", true)

		if billboardGui then
			billboardGui.Enabled = false
		end

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
				descendant.Enabled = false
			end
		end

		module.Utils.Particles:Emit(folder)
		module.Services.Debris:AddItem(folder, 5)
	end

	module.Signal:Fire("General", "CurrencyDrops", "Collect", p)
	module.Sound:PlayEffect("Drop.Collect", {
		Cooldown = 0.08
	})
	v[p] = nil
end

module.Services.RunService.Heartbeat:Connect(function()
	local HRP = module:GetHRP()

	if not HRP then
		return
	end

	local now = os.clock()
	local cFrame = HRP.CFrame

	for k, v2 in v do
		local count = #v2.Models
		local v3 = (now - v2.Time) / 2.5
		local pointToObjectSpace = cFrame:PointToObjectSpace(v2.Location)
		local v4 = (math.atan2(pointToObjectSpace.X, pointToObjectSpace.Z) + 1.5707963267948966) * v2.Side
		local v5 = cFrame * CFrame.new(math.sin(v4) * 10, 0, math.cos(v4) * 10)

		if v3 >= 1 then
			CurrencyDrops.Collect(k)
		elseif v3 >= 0.6666666666666666 then
			local v6 = (v3 - 0.6666666666666666) / 0.3333333333333333

			for _, model in v2.Models do
				local v7 = 1 - v6
				local v8 = v6 * 3
				local v9 = (6.283185307179586 * v6 + v8) * v2.Side
				local v10 = math.sin(v4 + v9) * 10 * v7
				local v11 = math.cos(v4 + v9) * 10 * v7
				model:PivotTo(cFrame * CFrame.new(v10, 0, v11))
			end
		elseif v3 >= 0.3333333333333333 then
			local v6 = (v3 - 0.3333333333333333) / 0.3333333333333333

			for k2, model in v2.Models do
				local v7 = "SpiralEnd" .. k2
				local v8 = (k2 - 1) / count
				local v9 = math.max(0, (v6 - v8) / (1 - v8))

				if not v2.Cache[v7] then
					v2.Cache[v7] = model:GetPivot().Position
				end

				local v10 = v2.Cache[v7]

				if not v10 then
					continue
				end

				local v11 = v5.Position - v10
				local unit = v11.Unit
				local magnitude = v11.Magnitude
				local v12 = not (magnitude > 0.01) and createVector(1, 0, 0) or unit:Cross(createVector(0, 1, 0)) or createVector(
					1,
					0,
					0
				)
				local v13 = math.sin(v9 * 3 * 3.141592653589793) * 5
				local v14 = v10 + unit * magnitude * v9 + v12 * v13 * v2.Side
				model:PivotTo(CFrame.new(v14))
			end
		else
			local v6 = v3 / 0.3333333333333333
			local v7 = 1 - v6

			for k2, model in v2.Models do
				local v8 = k2 / count * 6.283185307179586
				local v9 = v6 * 3
				local v10 = math.cos(v8 + v9) * 10 * v7
				local v11 = math.sin(v8 + v9) * 10 * v7
				local v12 = v6 * 15
				local v13 = v2.Location + Vector3.new(v10, v12, v11)
				model:PivotTo(CFrame.new(v13))
			end
		end
	end
end)
return CurrencyDrops