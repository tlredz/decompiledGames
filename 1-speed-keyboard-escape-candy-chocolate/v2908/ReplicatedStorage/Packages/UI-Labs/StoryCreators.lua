local StoryCreators = {}
require(script.Parent.Types)

local function CombineTableInfo(p, items)
	for k, item in pairs(items) do
		p[k] = item
	end

	return p
end

function StoryCreators.CreateRoactStory(items, story)
	local result = {
		use = "roact",
		story = story
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function StoryCreators.CreateReactStory(items, story)
	local result = {
		use = "react",
		story = story
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function StoryCreators.CreateFusionStory(items, story)
	local result = {
		use = "fusion",
		story = story
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function StoryCreators.CreateIrisStory(items, story)
	local result = {
		use = "iris",
		story = story
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function StoryCreators.CreateVideStory(items, story)
	local result = {
		use = "Vide",
		story = story
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function StoryCreators.CreateGenericStory(items, render)
	local result = {
		render = render
	}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

return StoryCreators