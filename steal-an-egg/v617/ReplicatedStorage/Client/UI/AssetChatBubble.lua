local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local MessageTyper = require(ReplicatedStorage.Client.UI.MessageTyper)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local vector2 = Vector2.new(1084, 144)
local vector3 = Vector2.new(251, 72)
local vector4 = Vector2.new(213.84, 56.4)
local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local strict = t.strict(t.instanceIsA("Model"))
local strict2 = t.strict(t.instanceIsA("BasePart"))
local strict3 = t.strict(t.boolean)
local strict4 = t.strict(t.string)
local AssetChatBubble = {}
AssetChatBubble.__index = AssetChatBubble
AssetChatBubble.__class = "AssetChatBubble"
local chatBubble = ReplicatedStorage.Assets.Billboards.ChatBubble
local frame = chatBubble.Frame
assert(
	chatBubble:IsA("BillboardGui") and frame:IsA("Frame") and frame.TextLabel:IsA("TextLabel"),
	"the chat bubble blueprint has the wrong instance shape"
)
local alwaysOnTop = true

local function claimAdornee(state)
	local adornee = state.adornee

	if adornee ~= nil then
		return adornee
	end

	assert(state.proxied, "a bubble without an adornee must have been built in proxy mode")
	local part = Instance.new("Part")
	part.Name = "AssetBubbleProxy"
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = false
	part.Massless = true
	part.CFrame = state.centre.CFrame + createVector(0, -1, 0)
	part.Parent = state.model
	local v2

	if state.centre.Anchored then
		v2 = Instance.new("Motor6D")
		v2.C0 = state.centre.CFrame:ToObjectSpace(part.CFrame)
	else
		v2 = Instance.new("WeldConstraint")
	end

	v2.Part0 = state.centre
	v2.Part1 = part
	v2.Parent = state.centre
	state.lifetime:Add(part)
	state.adornee = part
	return part
end

local function tearDown(p, p2)
	local showing = p.showing

	if showing == nil or p2 ~= nil and showing ~= p2 then
		return
	end

	p.showing = nil
	showing:Destroy()
end

local function widenToFit(frame2, textLabel, text: string)
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = textLabel.FontFace
	getTextBoundsParams.Size = vector4.Y
	getTextBoundsParams.Width = 10000
	getTextBoundsParams.Text = text
	local textBoundsAsync = TextService:GetTextBoundsAsync(getTextBoundsParams)
	getTextBoundsParams:Destroy()
	assert(textBoundsAsync.Y > 0, "measured chat bubble text has no height")
	local size = frame2.Size
	local v2

	if size.X.Offset == 0 then
		v2 = size.Y.Offset == 0
	else
		v2 = false
	end

	assert(v2, "the chat bubble frame must be sized purely in scale")
	local v3 = vector3.X - vector4.X
	local v4 = math.max(vector3.X, textBoundsAsync.X + v3)
	frame2.Size = UDim2.fromScale(v4 / vector2.X, size.Y.Scale)
end

function AssetChatBubble.new(model, centre, proxied: boolean)
	strict(model)
	strict2(centre)
	strict3(proxied)
	local self = setmetatable({}, AssetChatBubble)
	self.lifetime = Trove.new()
	self.showing = nil
	self.model = model
	self.centre = centre
	local adornee

	if not proxied then
		adornee = centre
	end

	self.adornee = adornee
	self.sizeFactor = math.max(centre.Size.X / 0.49799999594688416, centre.Size.Y / 0.4440000057220459)
	self.proxied = proxied
	self.muted = false
	return self
end

function AssetChatBubble:Destroy()
	local showing = self.showing

	if showing ~= nil then
		self.showing = nil
		showing:Destroy()
	end

	self.lifetime:Destroy()
end

function AssetChatBubble.PinAbove(flag: boolean)
	strict3(flag)
	alwaysOnTop = flag
end

function AssetChatBubble:Mute(muted: boolean)
	strict3(muted)

	if self.muted == muted then
		return
	end

	self.muted = muted

	if muted then
		local showing = self.showing

		if showing ~= nil then
			self.showing = nil
			showing:Destroy()
		end
	end
end

function AssetChatBubble:Say(p: string, callback)
	strict4(p)

	if self.muted then
		if callback ~= nil then
			callback()
		end
	else
		local showing = self.showing

		if showing ~= nil then
			self.showing = nil
			showing:Destroy()
		end

		local clone = chatBubble:Clone()
		local frame2 = clone.Frame
		local textLabel = frame2.TextLabel
		assert(frame2:IsA("Frame"), "the cloned chat bubble lost its Frame")
		assert(textLabel:IsA("TextLabel"), "the cloned chat bubble lost its TextLabel")
		local size = clone.Size
		clone.Size = UDim2.new(
			size.X.Scale * self.sizeFactor,
			size.X.Offset * self.sizeFactor,
			size.Y.Scale * self.sizeFactor,
			size.Y.Offset * self.sizeFactor
		)
		frame2.AutomaticSize = Enum.AutomaticSize.None
		clone.Adornee = claimAdornee(self)
		clone.AlwaysOnTop = alwaysOnTop
		clone.Parent = self.model
		clone.Enabled = true
		textLabel.Text = ""
		local maid = Trove.new()
		self.showing = maid
		maid:Add(clone)
		maid:Add(task.spawn(function()
			if self.showing ~= maid then
				return
			end

			widenToFit(frame2, textLabel, p)

			if self.showing ~= maid then
				return
			end

			local uIScale = EnsureUIScale(frame2)
			uIScale.Scale = 0
			local v3 = MessageTyper.new(textLabel, nil, nil, false)
			maid:Add(function()
				v3:Halt()
			end)
			local tween = TweenService:Create(uIScale, tweenInfo, {
				Scale = 1
			})
			maid:Add(tween)
			maid:Add(task.delay(4, function()
				if self.showing ~= maid then
					return
				end

				local tween2 = TweenService:Create(uIScale, tweenInfo2, {
					Scale = 0
				})
				maid:Add(tween2)
				maid:Add(tween2.Completed:Connect(function()
					local v4 = self
					local v5 = maid
					local showing2 = v4.showing

					if showing2 ~= nil and (v5 == nil or showing2 == v5) then
						v4.showing = nil
						showing2:Destroy()
					end

					if callback ~= nil then
						callback()
					end
				end))
				tween2:Play()
			end))
			task.delay(0.2, function()
				v3:Type(p, textLabel.TextColor3)
			end)
			tween:Play()
		end))
	end
end

return AssetChatBubble