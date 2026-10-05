local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChunkSystem = require(ReplicatedStorage.Utilities.ChunkSystem)
local Config = require(script.Parent.Config)
return {
	create = function()
		local strikeRadiusMaxStuds = Config.strikeRadiusMaxStuds
		local v = ChunkSystem.new(2, strikeRadiusMaxStuds)
		local v2 = {}
		local v3 = {}
		local parts = {}
		return {
			add = function(instance)
				if instance:GetAttribute("Type") ~= "Event" and not v2[instance] then
					local position = instance.Position
					local chunk = v:GetChunk(position, true)
					local v4 = {
						part = instance,
						position = position,
						chunk = chunk
					}
					v2[instance] = v4
					v3[chunk] = true
					chunk:AddObject(v4)
				end
			end,
			remove = function(p)
				local v4 = v2[p]

				if v4 then
					v4.chunk:RemoveObject(v4)

					if #v4.chunk:GetObjects() == 0 then
						v3[v4.chunk] = nil
						v:RemoveChunk(v4.position)
					end

					v2[p] = nil
				end
			end,
			pick = function(vector: Vector3, p: number)
				table.clear(parts)
				local v4 = Config.strikeRadiusMinStuds ^ 2
				local v5 = p ^ 2
				local v6 = math.floor((vector.X - p) / strikeRadiusMaxStuds + 0.5)
				local v7 = math.floor((vector.X + p) / strikeRadiusMaxStuds + 0.5)
				local v8 = math.floor((vector.Z - p) / strikeRadiusMaxStuds + 0.5)
				local v9 = math.floor((vector.Z + p) / strikeRadiusMaxStuds + 0.5)

				for i = v6, v7 do
					for i2 = v8, v9 do
						local chunk = v:GetChunk(
							Vector3.new(i * strikeRadiusMaxStuds, 0, i2 * strikeRadiusMaxStuds),
							false
						)

						if not chunk then
							continue
						end

						for _, v10 in chunk:GetObjects() do
							local v11 = v10.position - vector
							local v12 = v11.X * v11.X + v11.Z * v11.Z

							if v4 <= v12 and v12 <= v5 then
								table.insert(parts, v10.part)
							end
						end
					end
				end

				if #parts > 0 then
					return parts[math.random(1, #parts)]
				end

				local v10 = 1e999
				local part = nil

				for k in v3 do
					local position = k:GetPosition()
					local v11 = math.max(0, math.abs(position.X - vector.X) - strikeRadiusMaxStuds / 2)
					local v12 = math.max(0, math.abs(position.Z - vector.Z) - strikeRadiusMaxStuds / 2)

					if not (v11 * v11 + v12 * v12 <= v10) then
						continue
					end

					for _, v13 in k:GetObjects() do
						local v14 = v13.position - vector
						local v15 = v14.X * v14.X + v14.Z * v14.Z

						if not (v15 < v10) then
							continue
						end

						part = v13.part
						v10 = v15
					end
				end

				return part
			end
		}
	end
}