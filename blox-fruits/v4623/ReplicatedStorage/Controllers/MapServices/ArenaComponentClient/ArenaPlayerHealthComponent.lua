local Component = require(game.ReplicatedStorage.Modules.Component)
require(game.ReplicatedStorage.Util.Signal2)
require(game.ReplicatedStorage.Types.SlappingArenaTypes)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local v = Component.new({
	Tag = "ArenaHealthController",
	Ancestors = { workspace }
})

function v.Construct(_) end

function v:GetHealth()
	return self.Instance:GetAttribute("Health") or 100
end

local _ = {
	None = 1,
	Low = 2,
	Half = 3,
	Full = 4
}
local v2 = {
	{ 0, 0, 1 },
	{ 0.5, 768, 2 },
	{ 25, 512, 3 },
	{ 50, 256, 4 }
}

function v:onHeartStageChanged(p2, p3, p4)
	if p2 == 1 and p4 == 2 then
		self.Maid.lastHeartAnim = task.spawn(function()
			local position = p3.Parent.Position

			function self.Maid.lastHeartAnimEnd()
				if p3.Parent then
					p3.Parent.Position = position
					p3.ImageColor3 = Color3.new(1, 1, 1)
				end
			end

			while task.wait() do
				local v3 = math.cos(os.clock() * 20) * 0.01
				local v4 = math.abs(math.sin(os.clock() * 30) * 0.01)
				p3.Parent.Position = position + UDim2.new(v3, 0, v4, 0)
				local v5 = math.abs((math.sin(os.clock() * 2.5)))
				p3.ImageColor3 = Color3.new(1 - v5 * 0.5, 1 - v5 * 1.5, 1 - v5 * 1.5)
			end
		end)
	end
end

function v:onHealthChanged()
	local health = self:GetHealth()

	if health > 10 and self.Maid.lastHeartAnim then
		self.Maid.lastHeartAnim = nil
		task.defer(function()
			self.Maid.lastHeartAnimEnd = nil
		end)
	end

	local _ = self.Hearts

	for k, heartImage in self.HeartImages do
		local v3 = health - 50
		local v4 = 0
		local v5 = 1

		for i, v6 in ipairs(v2) do
			if not (math.max(health, 0) >= v6[1]) then
				continue
			end

			v4 = v6[2]
			v5 = v6[3]

			if not (i == 2 and (k ~= 1 or health > 1)) then
				continue
			end

			if health > 25 or k == 1 then
				v4 = v2[3][2]
				v5 = v2[3][3]
			else
				v4 = v2[1][2]
				v5 = v2[1][3]
			end
		end

		heartImage.ImageRectOffset = Vector2.new(v4, 0)
		self:onHeartStageChanged(k, heartImage, v5)
		health = v3
	end
end

local outline1 = script.Hearts.Frame.Outline1

function v:Start()
	self.Maid = Maid.new()
	self.Hearts = script.Hearts:Clone()
	self.Maid:GiveTask(self.Hearts)
	self.Maid:GiveTask(self.Instance:GetAttributeChangedSignal("Health"):Connect(function()
		self:onHealthChanged()
	end))

	repeat
		task.wait()
	until self.Instance:GetAttribute("MaxHealth")

	self.numHearts = math.ceil((self.Instance:GetAttribute("MaxHealth") or 150) / 50)
	self.Hearts.Size = UDim2.new(1.3333333333333333 * self.numHearts, 0, 1, 0)
	self.HeartImages = {}
	self.Hearts.Frame.Outline1:Destroy()
	self.Hearts.Frame.Outline2:Destroy()
	self.Hearts.Frame.Outline3:Destroy()

	for _ = 1, self.numHearts do
		local clone = outline1:Clone()
		clone.Parent = self.Hearts.Frame
	end

	local _ = 0.3 / (self.numHearts / 3)
	local v3 = ({
		{ 0.5 },
		{ 0.3, 0.7 },
		{ 0.2, 0.5, 0.8 },
		{
			0.2,
			0.4,
			0.6,
			0.8
		},
		{
			0,
			0.2,
			0.5,
			0.8,
			1
		},
		{
			0.2,
			0.33333333333333337,
			0.4666666666666667,
			0.6000000000000001,
			0.7333333333333334,
			0.8666666666666667
		}
	})[self.numHearts]

	for i, child in self.Hearts.Frame:GetChildren() do
		table.insert(self.HeartImages, child.Heart)
		child.Position = UDim2.new(v3[i], 0, 0.5, 0)
	end

	self.Hearts.Parent = self.Instance.Parent
	self:onHealthChanged()
end

function v.Stop(p)
	p.Maid:Destroy()
end

function v.RenderSteppedUpdate(_) end

return v