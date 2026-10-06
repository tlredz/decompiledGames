local AssetLibrary = require(script.Parent.AssetLibrary)
local BallCardQuality = require(script.Parent.BallCardQuality)
local object = setmetatable({}, {
	__mode = "k"
})
return {
	apply = function(self, p)
		if object[self] == p then
			return
		end

		local v = assert(BallCardQuality.templateNames[p], "Unknown ball quality")
		local v2 = AssetLibrary.Get("小球卡片品质", v)

		for _, v3 in {
			"FontFace",
			"TextColor3",
			"TextTransparency",
			"TextStrokeColor3",
			"TextStrokeTransparency"
		} do
			self[v3] = v2[v3]
		end

		for _, child in ipairs(self:GetChildren()) do
			if not (child:IsA("UIGradient") or child:IsA("UIStroke") or child:IsA("UITextSizeConstraint")) then
				continue
			end

			child:Destroy()
		end

		for _, child in ipairs(v2:GetChildren()) do
			if not (child:IsA("UIGradient") or child:IsA("UIStroke") or child:IsA("UITextSizeConstraint")) then
				continue
			end

			local clone = child:Clone()
			clone.Parent = self
		end

		object[self] = p
	end
}