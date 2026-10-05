local AssetService = game:GetService("AssetService")

local function u8(buf: buffer, offset: number, p: number, p2: number)
	if offset < 0 or p <= offset then
		return p2
	end

	return (buffer.readu8(buf, offset))
end

return {
	Blur = function(_, p, value, value2)
		local v = value2 or 12
		local v2 = p.Size.X // v
		local v3 = p.Size.Y // v
		local size = p.Size
		local vector = Vector2.new(v2, v3)
		local v4 = v2 * v3 * 4
		local editableImage = AssetService:CreateEditableImage({
			Size = vector
		})
		editableImage:DrawImageTransformed(Vector2.zero, Vector2.new(v2 / size.X, v3 / size.Y), 0, p, {
			SamplingMode = Enum.ResamplerMode.Default,
			PivotPoint = Vector2.zero
		})
		local pixelsBuffer = editableImage:ReadPixelsBuffer(Vector2.zero, vector)

		for _ = 1, value or 3 do
			for i = 0, v3 - 1 do
				for i2 = 0, v2 - 1 do
					local v5 = v2 * 4 * (i + 1) + (i2 - 1) * 4
					local v6 = v2 * 4 * (i + 1) + (i2 + 1) * 4
					local v7 = v2 * 4 * (i - 1) + (i2 - 1) * 4
					local v8 = v2 * 4 * (i - 1) + (i2 + 1) * 4
					local v9 = v2 * 4 * i + i2 * 4

					for i3 = 0, 2 do
						local v10 = v9 + i3
						local v11 = v10 < 0 and 0 or v4 <= v10 and 0 or buffer.readu8(pixelsBuffer, v10)
						local v12 = v5 + i3
						local v13

						if v12 < 0 or v4 <= v12 then
							v13 = v11
						else
							v13 = buffer.readu8(pixelsBuffer, v12)
						end

						local v14 = v6 + i3
						local v15

						if v14 < 0 or v4 <= v14 then
							v15 = v11
						else
							v15 = buffer.readu8(pixelsBuffer, v14)
						end

						local v16 = v7 + i3
						local v17

						if v16 < 0 or v4 <= v16 then
							v17 = v13
						else
							v17 = buffer.readu8(pixelsBuffer, v16)
						end

						local v18 = v8 + i3
						local v19

						if v18 < 0 or v4 <= v18 then
							v19 = v15
						else
							v19 = buffer.readu8(pixelsBuffer, v18)
						end

						local midpoint = (v15 + v13) / 2
						local midpoint2 = (v19 + v17) / 2
						local midpoint3 = (v17 + v13) / 2
						local _ = (v19 + v15) / 2
						buffer.writeu8(
							pixelsBuffer,
							v9 + i3,
							(v13 + v15 + v17 + v19 + midpoint + midpoint2 + midpoint3 + midpoint3 + v11) / 9
						)
					end
				end
			end
		end

		editableImage:WritePixelsBuffer(Vector2.zero, vector, pixelsBuffer)
		return editableImage
	end
}