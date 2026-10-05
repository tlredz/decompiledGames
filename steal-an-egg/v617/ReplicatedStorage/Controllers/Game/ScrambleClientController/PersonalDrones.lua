local Players = game:GetService("Players")
return {
	new = function(parent, callback, callback2)
		local v = {}
		local v2 = {}
		local v3 = {}
		local revision = -1
		local v4 = false
		local dataByRevision = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function discard(p: string)
			local v5 = v3[p]

			if v5 then
				callback2(v5)
				v5:Destroy()
				v3[p] = nil
			end
		end

		local function update(instance, instance2)
			for k, attribute in instance2.Attributes do
				instance:SetAttribute(k, attribute)
			end

			local hitbox = instance.Hitbox
			local hitbox2 = instance.Hitbox
			local cFrame = instance2.CFrame
			local size = instance2.Size
			hitbox.CFrame = cFrame
			hitbox2.Size = size
			instance.Hitbox:SetAttribute("MaxHealth", instance2.MaxHealth)
			instance.Hitbox:SetAttribute("Health", instance2.Health)
		end

		function v.Apply(data)
			if type(data) ~= "table" or data.OwnerUserId ~= Players.LocalPlayer.UserId or type(data.Revision) ~= "number" or data.Revision <= revision then
				return
			end

			if not (v4 or data.Full) then
				dataByRevision[data.Revision] = data
				return
			end

			v4 = true
			revision = data.Revision

			if data.Full then
				local v5 = {}

				for _, upsert in data.Upserts do
					v5[upsert.Id] = true
				end

				for k in v2 do
					if v5[k] then
						continue
					end

					discard(k) -- equivalent call inferred; original call site unknown
					v2[k] = nil
				end
			end

			for _, v5 in data.Removed or {} do
				discard(v5) -- equivalent call inferred; original call site unknown
				v2[v5] = nil
			end

			for _, v5 in data.Upserts or {} do
				if v5.OwnerUserId ~= Players.LocalPlayer.UserId then
					continue
				end

				v2[v5.Id] = v5

				if v3[v5.Id] then
					update(v3[v5.Id], v5)
				end
			end

			if next(dataByRevision) then
				local v5 = {}

				for _, v6 in dataByRevision do
					table.insert(v5, v6)
				end

				table.clear(dataByRevision)
				table.sort(v5, function(a, b)
					return a.Revision < b.Revision
				end)

				for _, v6 in v5 do
					v.Apply(v6)
				end
			end
		end

		function v.Tick()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()
			local v5 = {}

			for k, v6 in v2 do
				if v6.ExpiresAt and v6.ExpiresAt <= serverTimeNow then
					discard(k) -- equivalent call inferred; original call site unknown
					v2[k] = nil
				else
					local magnitude = (currentCamera.CFrame.Position - v6.CFrame.Position).Magnitude

					if magnitude <= 180 then
						table.insert(v5, {
							Id = k,
							Distance = magnitude
						})
					end
				end
			end

			table.sort(v5, function(a, b)
				return a.Distance < b.Distance
			end)
			local v6 = {}

			for i = 1, math.min(32, #v5) do
				v6[v5[i].Id] = true
			end

			for k in v3 do
				if v6[k] then
					continue
				end

				discard(k) -- equivalent call inferred; original call site unknown
			end

			for k in v6 do
				if v3[k] then
					continue
				end

				local v7 = v2[k]
				local model = Instance.new("Model")
				model.Name = "PersonalDrone_" .. k
				local part = Instance.new("Part")
				part.Name = "Hitbox"
				part.Anchored = true
				part.Transparency = 1
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Parent = model
				model.PrimaryPart = part
				update(model, v7)
				model.Parent = parent
				v3[k] = model
				callback(model)
			end
		end

		function v.Ready()
			return v4
		end

		function v.Destroy()
			for k in v3 do
				discard(k) -- equivalent call inferred; original call site unknown
			end

			table.clear(v2)
		end

		return v
	end
}