local MeshSprite = {}

function MeshSprite.PlaySpriteAll(folder, list, value: number?)
	local v = #list * (1 / (value or 60))

	for _, decal in ipairs(folder:GetDescendants()) do
		if decal:IsA("Decal") and decal.Name == "Sprite" then
			task.spawn(MeshSprite.PlayDecal, decal, list, value)
		end
	end

	return v
end

function MeshSprite:PlayDecal(items, value: number?)
	local v = 1 / (value or 60)

	for _, item in items do
		self.Texture = item
		task.wait(v)
	end
end

return MeshSprite