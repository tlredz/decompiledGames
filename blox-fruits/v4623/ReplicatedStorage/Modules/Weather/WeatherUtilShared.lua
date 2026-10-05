local angles = {
	0,
	15,
	-15,
	20,
	-20,
	45,
	-45,
	90,
	-90,
	135,
	-135,
	180,
	-180
}
local WeatherUtilShared = {}
WeatherUtilShared.angles = angles

function WeatherUtilShared.createTornadoProperties(p)
	local v2 = {
		Name = "Tornado",
		Id = p.Id or "Tornado",
		_CameraEffect = false,
		_PrecipitationType = false
	}
	assert(v2._CameraEffect == false)
	assert(v2._PrecipitationType == false)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	return v2
end

function WeatherUtilShared.createLightningProperties(data)
	local v2 = {
		Name = "Lightning",
		Height = data.Height or 1000,
		Interval = data.Interval or NumberRange.new(5, 10),
		Radius = data.Radius or 20,
		Damage = data.Damage or {},
		Id = data.Id or "Lightning",
		_CameraEffect = false,
		_PrecipitationType = false
	}
	assert(v2._CameraEffect == false)
	assert(v2._PrecipitationType == false)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	assert(v2.Height and typeof(v2.Height) == "number")
	assert(v2.Interval and typeof(v2.Interval) == "NumberRange")
	assert(v2.Radius and typeof(v2.Radius) == "number")
	assert(v2.Damage and typeof(v2.Damage) == "table")

	if v2.Damage.Player then
		assert(typeof(v2.Damage.Player) == "number")
	end

	if v2.Damage.Boat then
		assert(typeof(v2.Damage.Boat) == "number")
	end

	return v2
end

function WeatherUtilShared.createCloudProperties(data)
	local v2 = {
		Name = "Clouds",
		Intensity = data.Intensity or 1,
		Color = data.Color or Color3.fromRGB(230, 230, 230),
		Cover = data.Cover or 0.5,
		Density = data.Density or 0.7,
		Id = data.Id or "Clouds",
		_CameraEffect = true,
		_PrecipitationType = false
	}
	assert(v2._CameraEffect == true)
	assert(v2._PrecipitationType == false)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	assert(v2.Intensity and typeof(v2.Intensity) == "number")
	assert(v2.Color and typeof(v2.Color) == "Color3")
	assert(v2.Cover and typeof(v2.Cover) == "number")
	assert(v2.Density and typeof(v2.Density) == "number")
	return v2
end

function WeatherUtilShared.createRainProperties(data)
	local v2 = {
		Name = "Rain",
		Intensity = data.Intensity or 0.1,
		Color = data.Color or Color3.fromRGB(255, 255, 255),
		PrimaryVolumeModifier = data.PrimaryVolumeModifier or 1,
		Id = data.Id or "Rain",
		_CameraEffect = true,
		_PrecipitationType = true
	}
	assert(v2._CameraEffect == true)
	assert(v2._PrecipitationType == true)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	assert(v2.Intensity and typeof(v2.Intensity) == "number")
	assert(v2.Color and typeof(v2.Color) == "Color3")
	assert(v2.PrimaryVolumeModifier and typeof(v2.PrimaryVolumeModifier) == "number")
	return v2
end

function WeatherUtilShared.createSnowProperties(data)
	local v2 = {
		Name = "Snow",
		Intensity = data.Intensity or 0.1,
		Color = data.Color or Color3.fromRGB(255, 255, 255),
		PrimaryVolumeModifier = data.PrimaryVolumeModifier or 1,
		Id = data.Id or "Snow",
		_CameraEffect = true,
		_PrecipitationType = true
	}
	assert(v2._CameraEffect == true)
	assert(v2._PrecipitationType == true)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	assert(v2.Intensity and typeof(v2.Intensity) == "number")
	assert(v2.Color and typeof(v2.Color) == "Color3")
	assert(v2.PrimaryVolumeModifier and typeof(v2.PrimaryVolumeModifier) == "number")
	return v2
end

function WeatherUtilShared.createAshProperties(data)
	local v2 = {
		Name = "Ash",
		Intensity = data.Intensity or 0.1,
		Color = data.Color or Color3.fromRGB(255, 255, 255),
		PrimaryVolumeModifier = data.PrimaryVolumeModifier or 1,
		Id = data.Id or "Ash",
		_CameraEffect = true,
		_PrecipitationType = true
	}
	assert(v2._CameraEffect == true)
	assert(v2._PrecipitationType == true)
	assert(v2.Id and typeof(v2.Id) == "string")
	assert(v2.Name and typeof(v2.Name) == "string")
	assert(v2.Intensity and typeof(v2.Intensity) == "number")
	assert(v2.Color and typeof(v2.Color) == "Color3")
	assert(v2.PrimaryVolumeModifier and typeof(v2.PrimaryVolumeModifier) == "number")
	return v2
end

function WeatherUtilShared.angle(list)
	if not list then
		return angles[math.random(#angles)]
	end

	local v2 = {}

	for _, v3 in pairs(angles) do
		if not table.find(list, v3) then
			table.insert(v2, v3)
		end
	end

	if #v2 == 0 then
		v2 = angles
	end

	return v2[math.random(#v2)]
end

return WeatherUtilShared