local function Map(p, p2, p3, p4, p5)
	return (p - p2) / (p3 - p2) * (p5 - p4) + p4
end

local Mesh = {}
Mesh.__index = Mesh

function Mesh.Init(ceive, propertys, request, release, retain)
	local self = setmetatable({}, Mesh)
	self.Ceive = ceive
	self.Propertys = propertys
	self.Request = request
	self.Release = release
	self.Retain = retain
	return self
end

function Mesh:Draw(cframe: CFrame, vector: Vector3, items, items2)
	local ceive = self.Ceive

	if not ceive.Enabled then
		return
	end

	local v = -1e999
	local v2 = -1e999
	local v3 = -1e999
	local v4 = 1e999
	local v5 = 1e999
	local v6 = 1e999

	for _, item in items do
		v = math.max(v, item.x)
		v2 = math.max(v2, item.y)
		v3 = math.max(v3, item.z)
		v4 = math.min(v4, item.x)
		v5 = math.min(v5, item.y)
		v6 = math.min(v6, item.z)
	end

	for k, item in items do
		local v7 = (item.x - v4) / (v - v4) * 1 + -0.5
		local v8 = (item.y - v5) / (v2 - v5) * 1 + -0.5
		local v9 = (item.z - v6) / (v3 - v6) * 1 + -0.5
		items[k] = cframe * CFrame.new(Vector3.new(v7, v8, v9) * vector)
	end

	for _, item in items2 do
		if #item == 3 then
			local item2 = items[item[1].v]
			local item3 = items[item[2].v]
			local item4 = items[item[3].v]
			ceive.Ray:Draw(item2.Position, item3.Position)
			ceive.Ray:Draw(item3.Position, item4.Position)
			ceive.Ray:Draw(item4.Position, item2.Position)
		else
			local item2 = items[item[1].v]
			local item3 = items[item[2].v]
			local item4 = items[item[3].v]
			local item5 = items[item[4].v]
			ceive.Ray:Draw(item2.Position, item3.Position)
			ceive.Ray:Draw(item2.Position, item5.Position)
			ceive.Ray:Draw(item5.Position, item3.Position)
			ceive.Ray:Draw(item4.Position, item5.Position)
			ceive.Ray:Draw(item3.Position, item4.Position)
		end
	end
end

function Mesh.Create(p, cframe: CFrame, vector: Vector3, vertices, faces)
	local v = {
		Transform = cframe,
		Size = vector,
		Vertices = vertices,
		Faces = faces,
		AlwaysOnTop = p.Propertys.AlwaysOnTop,
		Transparency = p.Propertys.Transparency,
		Color3 = p.Propertys.Color3,
		Enabled = true,
		Destroy = false
	}
	p.Retain(p, v)
	return v
end

function Mesh:Update(data)
	local ceive = self.Ceive
	ceive.PushProperty("AlwaysOnTop", data.AlwaysOnTop)
	ceive.PushProperty("Transparency", data.Transparency)
	ceive.PushProperty("Color3", data.Color3)
	self:Draw(data.Transform, data.Size, data.Vertices, data.Faces)
end

return Mesh