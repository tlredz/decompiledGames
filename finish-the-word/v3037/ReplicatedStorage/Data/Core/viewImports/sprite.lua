local import = _G.import("romodel")
local basic = _G.import("viewImports"):get("basic")
local model = import.model(basic.EmptyElement, basic.ConstrainedElement)

-- equivalent calls inferred from this helper; original call sites unknown
local function setFrame(state, p)
	local frameLabel = state.FrameLabels[p]

	if not frameLabel then
		return
	end

	if state.ActiveFrame then
		state.ActiveFrame.Visible = false
	end

	frameLabel.Visible = true
	state.ActiveFrame = frameLabel
end

function model.init(p)
	local images = p.Images or p[1] or { p.Image }
	local result = {}

	for i, image in ipairs(images) do
		result[i] = import.make("ImageLabel", {
			BackgroundTransparency = 1,
			Image = image,
			ImageColor3 = Color3.new(1, 1, 1),
			ImageTransparency = p.ImageTransparency,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Stretch,
			Visible = false
		})
	end

	return {
		ClipsDescendants = true,
		Size = p.Size or UDim2.fromScale(1, 1),
		AspectRatio = p.AspectRatio or 1.777,
		FrameLabels = result
	}, result
end

function model.prespawn(instance)
	local count = #instance.FrameLabels
	local speed = instance.Speed or 1
	task.spawn(function()
		local v = 1
		local total = 0

		while true do
			if v <= count then
				setFrame(instance, v) -- equivalent call inferred; original call site unknown
				v = math.floor(total * 24 * speed) + 1
				total += task.wait(0)
			elseif instance.Looping then
				v = 1
				total = 0
			else
				instance:Destroy()
				break
			end
		end
	end)
end

function model:despawn()
	self.Looping = false
end

local model2 = import.model(basic.ImageLabel, basic.ConstrainedElement)
local v = {
	{
		Row = 0,
		Column = 0
	},
	{
		Row = 1,
		Column = 0
	},
	{
		Row = 0,
		Column = 1
	},
	{
		Row = 1,
		Column = 1
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function setSheetFrame(state, i)
	local v2 = math.floor((i - 1) / 4) + 1
	local v3 = v[(i - 1) % 4 + 1]
	local imageRectSize = state.SourceSize / 2
	state.Image = state.Images[v2]
	state.ImageRectSize = imageRectSize
	state.ImageRectOffset = Vector2.new(v3.Column * imageRectSize.X, v3.Row * imageRectSize.Y)
end

function model2.init(data)
	local sourceSize = data.SourceSize or Vector2.new(1024, 576)
	return {
		BackgroundTransparency = 1,
		Image = data.Images[1],
		ImageColor3 = Color3.new(1, 1, 1),
		ImageRectSize = sourceSize / 2,
		ImageRectOffset = Vector2.new(0, 0),
		Images = data.Images,
		SourceSize = sourceSize,
		Size = data.Size or UDim2.fromScale(1, 1),
		ScaleType = Enum.ScaleType.Stretch
	}
end

function model2.prespawn(instance)
	local v2 = #instance.Images * 4
	local v3 = 1 / (24 * (instance.Speed or 1))
	task.spawn(function()
		while true do
			for i = 1, v2 do
				setSheetFrame(instance, i) -- equivalent call inferred; original call site unknown
				task.wait(v3)
			end

			if instance.Looping then
				continue
			end

			instance:Destroy()
			break
		end
	end)
end

function model2:despawn()
	self.Looping = false
end

return {
	Sprite = model,
	SpriteSheet = model2
}