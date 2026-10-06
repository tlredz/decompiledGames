local StarterGui = game:GetService("StarterGui")
local AssetLibrary = {
	Get = function(childName: string, childName2: string)
		local child = StarterGui:WaitForChild("UI素材"):FindFirstChild(childName)
		assert(child, ("AssetLibrary: 素材分类不存在：%s"):format(childName))
		local child2 = child:FindFirstChild(childName2)
		assert(child2, ("AssetLibrary: 素材不存在：%s/%s"):format(childName, childName2))
		return child2
	end
}

function AssetLibrary:Clone(p2: string)
	return AssetLibrary.Get(self, p2):Clone()
end

return AssetLibrary