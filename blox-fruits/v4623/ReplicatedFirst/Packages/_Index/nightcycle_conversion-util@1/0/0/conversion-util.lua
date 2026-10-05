return {
	Temperature = {
		Celsius = {
			toKelvin = function(p: number)
				return p + 273.15
			end,
			toFahrenheit = function(p: number)
				return p * 1.8 + 32
			end
		},
		Kelvin = {
			toCelsius = function(p: number)
				return p - 273.15
			end,
			toFahrenheit = function(p: number)
				return (p - 273.15) * 1.8 + 32
			end
		},
		Fahrenheit = {
			toCelsius = function(p: number)
				return (p - 32) * 0.5555555555555556
			end,
			toKelvin = function(p: number)
				return (p - 32) * 0.5555555555555556 + 273.15
			end
		}
	},
	Mass = {
		Ounce = {
			toPound = function(p: number)
				return p * 0.0625
			end,
			toStone = function(p: number)
				return p * 0.004464566929133858
			end,
			toUsTon = function(p: number)
				return p * 0.00003125
			end,
			toImperialTon = function(p: number)
				return p * 0.000027903543307086617
			end,
			toMetricTon = function(p: number)
				return p * 0.00002835
			end,
			toRoblox = function(p: number)
				return p * 1291.454081632653
			end,
			toGram = function(p: number)
				return p * 28.35
			end,
			toMicrogram = function(p: number)
				return p * 0.00002835
			end,
			toMilligram = function(p: number)
				return p * 0.028350000000000004
			end,
			toCentigram = function(p: number)
				return p * 0.28350000000000003
			end,
			toKilogram = function(p: number)
				return p * 28350
			end,
			toMegagram = function(p: number)
				return p * 28350000
			end
		},
		Pound = {
			toOunce = function(p: number)
				return p * 16
			end,
			toStone = function(p: number)
				return p * 0.07143307086614173
			end,
			toUsTon = function(p: number)
				return p * 0.0005
			end,
			toImperialTon = function(p: number)
				return p * 0.00044645669291338587
			end,
			toMetricTon = function(p: number)
				return p * 0.0004536
			end,
			toRoblox = function(p: number)
				return p * 20663.26530612245
			end,
			toGram = function(p: number)
				return p * 453.6
			end,
			toMicrogram = function(p: number)
				return p * 0.0004536
			end,
			toMilligram = function(p: number)
				return p * 0.45360000000000006
			end,
			toCentigram = function(p: number)
				return p * 4.5360000000000005
			end,
			toKilogram = function(p: number)
				return p * 453600
			end,
			toMegagram = function(p: number)
				return p * 453600000
			end
		},
		Stone = {
			toOunce = function(p: number)
				return p * 223.98589065255732
			end,
			toPound = function(p: number)
				return p * 13.999118165784832
			end,
			toUsTon = function(p: number)
				return p * 0.006999559082892416
			end,
			toImperialTon = function(p: number)
				return p * 0.00625
			end,
			toMetricTon = function(p: number)
				return p * 0.00635
			end,
			toRoblox = function(p: number)
				return p * 289267.4927113702
			end,
			toGram = function(p: number)
				return p * 6350
			end,
			toMicrogram = function(p: number)
				return p * 0.00635
			end,
			toMilligram = function(p: number)
				return p * 6.3500000000000005
			end,
			toCentigram = function(p: number)
				return p * 63.5
			end,
			toKilogram = function(p: number)
				return p * 6350000
			end,
			toMegagram = function(p: number)
				return p * 6350000000
			end
		},
		UsTon = {
			toOunce = function(p: number)
				return p * 32000.000000000004
			end,
			toPound = function(p: number)
				return p * 2000.0000000000002
			end,
			toStone = function(p: number)
				return p * 142.86614173228347
			end,
			toImperialTon = function(p: number)
				return p * 0.8929133858267718
			end,
			toMetricTon = function(p: number)
				return p * 0.9072000000000001
			end,
			toRoblox = function(p: number)
				return p * 41326530.6122449
			end,
			toGram = function(p: number)
				return p * 907200.0000000001
			end,
			toMicrogram = function(p: number)
				return p * 0.9072000000000001
			end,
			toMilligram = function(p: number)
				return p * 907.2000000000002
			end,
			toCentigram = function(p: number)
				return p * 9072.000000000002
			end,
			toKilogram = function(p: number)
				return p * 907200000.0000001
			end,
			toMegagram = function(p: number)
				return p * 907200000000.0001
			end
		},
		ImperialTon = {
			toOunce = function(p: number)
				return p * 35837.74250440917
			end,
			toPound = function(p: number)
				return p * 2239.8589065255733
			end,
			toStone = function(p: number)
				return p * 160
			end,
			toUsTon = function(p: number)
				return p * 1.1199294532627866
			end,
			toMetricTon = function(p: number)
				return p * 1.016
			end,
			toRoblox = function(p: number)
				return p * 46282798.83381923
			end,
			toGram = function(p: number)
				return p * 1016000
			end,
			toMicrogram = function(p: number)
				return p * 1.016
			end,
			toMilligram = function(p: number)
				return p * 1016
			end,
			toCentigram = function(p: number)
				return p * 10160
			end,
			toKilogram = function(p: number)
				return p * 1016000000
			end,
			toMegagram = function(p: number)
				return p * 1016000000000
			end
		},
		MetricTon = {
			toOunce = function(p: number)
				return p * 35273.36860670194
			end,
			toPound = function(p: number)
				return p * 2204.585537918871
			end,
			toStone = function(p: number)
				return p * 157.48031496062993
			end,
			toUsTon = function(p: number)
				return p * 1.1022927689594355
			end,
			toImperialTon = function(p: number)
				return p * 0.984251968503937
			end,
			toRoblox = function(p: number)
				return p * 45553935.8600583
			end,
			toGram = function(p: number)
				return p * 1000000
			end,
			toMicrogram = function(p: number)
				return p * 1
			end,
			toMilligram = function(p: number)
				return p * 1000
			end,
			toCentigram = function(p: number)
				return p * 10000
			end,
			toKilogram = function(p: number)
				return p * 1000000000
			end,
			toMegagram = function(p: number)
				return p * 1000000000000
			end
		},
		Roblox = {
			toOunce = function(p: number)
				return p * 0.0007743209876543211
			end,
			toPound = function(p: number)
				return p * 0.000048395061728395067
			end,
			toStone = function(p: number)
				return p * 3.457007874015748e-6
			end,
			toUsTon = function(p: number)
				return p * 2.4197530864197532e-8
			end,
			toImperialTon = function(p: number)
				return p * 2.160629921259843e-8
			end,
			toMetricTon = function(p: number)
				return p * 2.1952e-8
			end,
			toGram = function(p: number)
				return p * 0.021952000000000003
			end,
			toMicrogram = function(p: number)
				return p * 2.1952e-8
			end,
			toMilligram = function(p: number)
				return p * 0.000021952000000000003
			end,
			toCentigram = function(p: number)
				return p * 0.00021952000000000004
			end,
			toKilogram = function(p: number)
				return p * 21.952
			end,
			toMegagram = function(p: number)
				return p * 21952.000000000004
			end
		},
		Gram = {
			toOunce = function(p: number)
				return p * 0.03527336860670194
			end,
			toPound = function(p: number)
				return p * 0.002204585537918871
			end,
			toStone = function(p: number)
				return p * 0.00015748031496062991
			end,
			toUsTon = function(p: number)
				return p * 1.1022927689594355e-6
			end,
			toImperialTon = function(p: number)
				return p * 9.84251968503937e-7
			end,
			toMetricTon = function(p: number)
				return p * 1e-6
			end,
			toRoblox = function(p: number)
				return p * 45.5539358600583
			end,
			toMicrogram = function(p: number)
				return p * 1e-6
			end,
			toMilligram = function(p: number)
				return p * 0.001
			end,
			toCentigram = function(p: number)
				return p * 0.01
			end,
			toKilogram = function(p: number)
				return p * 1000
			end,
			toMegagram = function(p: number)
				return p * 1000000
			end
		},
		Microgram = {
			toOunce = function(p: number)
				return p * 35273.36860670194
			end,
			toPound = function(p: number)
				return p * 2204.585537918871
			end,
			toStone = function(p: number)
				return p * 157.48031496062993
			end,
			toUsTon = function(p: number)
				return p * 1.1022927689594355
			end,
			toImperialTon = function(p: number)
				return p * 0.984251968503937
			end,
			toMetricTon = function(p: number)
				return p * 1
			end,
			toRoblox = function(p: number)
				return p * 45553935.8600583
			end,
			toGram = function(p: number)
				return p * 1000000
			end,
			toMilligram = function(p: number)
				return p * 1000
			end,
			toCentigram = function(p: number)
				return p * 10000
			end,
			toKilogram = function(p: number)
				return p * 1000000000
			end,
			toMegagram = function(p: number)
				return p * 1000000000000
			end
		},
		Milligram = {
			toOunce = function(p: number)
				return p * 35.273368606701936
			end,
			toPound = function(p: number)
				return p * 2.204585537918871
			end,
			toStone = function(p: number)
				return p * 0.15748031496062992
			end,
			toUsTon = function(p: number)
				return p * 0.0011022927689594356
			end,
			toImperialTon = function(p: number)
				return p * 0.000984251968503937
			end,
			toMetricTon = function(p: number)
				return p * 0.001
			end,
			toRoblox = function(p: number)
				return p * 45553.9358600583
			end,
			toGram = function(p: number)
				return p * 1000
			end,
			toMicrogram = function(p: number)
				return p * 0.001
			end,
			toCentigram = function(p: number)
				return p * 10
			end,
			toKilogram = function(p: number)
				return p * 1000000
			end,
			toMegagram = function(p: number)
				return p * 1000000000
			end
		},
		Centigram = {
			toOunce = function(p: number)
				return p * 3.527336860670194
			end,
			toPound = function(p: number)
				return p * 0.2204585537918871
			end,
			toStone = function(p: number)
				return p * 0.015748031496062992
			end,
			toUsTon = function(p: number)
				return p * 0.00011022927689594356
			end,
			toImperialTon = function(p: number)
				return p * 0.0000984251968503937
			end,
			toMetricTon = function(p: number)
				return p * 0.00009999999999999999
			end,
			toRoblox = function(p: number)
				return p * 4555.39358600583
			end,
			toGram = function(p: number)
				return p * 100
			end,
			toMicrogram = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMilligram = function(p: number)
				return p * 0.1
			end,
			toKilogram = function(p: number)
				return p * 100000
			end,
			toMegagram = function(p: number)
				return p * 100000000
			end
		},
		Kilogram = {
			toOunce = function(p: number)
				return p * 0.00003527336860670194
			end,
			toPound = function(p: number)
				return p * 2.204585537918871e-6
			end,
			toStone = function(p: number)
				return p * 1.5748031496062992e-7
			end,
			toUsTon = function(p: number)
				return p * 1.1022927689594356e-9
			end,
			toImperialTon = function(p: number)
				return p * 9.84251968503937e-10
			end,
			toMetricTon = function(p: number)
				return p * 1e-9
			end,
			toRoblox = function(p: number)
				return p * 0.045553935860058306
			end,
			toGram = function(p: number)
				return p * 0.001
			end,
			toMicrogram = function(p: number)
				return p * 1e-9
			end,
			toMilligram = function(p: number)
				return p * 1e-6
			end,
			toCentigram = function(p: number)
				return p * 0.00001
			end,
			toMegagram = function(p: number)
				return p * 1000
			end
		},
		Megagram = {
			toOunce = function(p: number)
				return p * 3.527336860670194e-8
			end,
			toPound = function(p: number)
				return p * 2.204585537918871e-9
			end,
			toStone = function(p: number)
				return p * 1.5748031496062991e-10
			end,
			toUsTon = function(p: number)
				return p * 1.1022927689594356e-12
			end,
			toImperialTon = function(p: number)
				return p * 9.84251968503937e-13
			end,
			toMetricTon = function(p: number)
				return p * 1e-12
			end,
			toRoblox = function(p: number)
				return p * 0.0000455539358600583
			end,
			toGram = function(p: number)
				return p * 1e-6
			end,
			toMicrogram = function(p: number)
				return p * 1e-12
			end,
			toMilligram = function(p: number)
				return p * 1e-9
			end,
			toCentigram = function(p: number)
				return p * 1e-8
			end,
			toKilogram = function(p: number)
				return p * 0.001
			end
		}
	},
	Area = {
		InchesSquared = {
			toFeetSquared = function(p: number)
				return p * 0.00005993694633245826
			end,
			toYardsSquared = function(p: number)
				return p * 0.0005394325169921243
			end,
			toMilesSquared = function(p: number)
				return p * 2.490970232905717e-10
			end,
			toAcre = function(p: number)
				return p * 1.5942268581630712e-7
			end,
			toHectare = function(p: number)
				return p * 6.451612903225807e-8
			end,
			toRoblox = function(p: number)
				return p * 0.008229098090849242
			end,
			toMeterSquared = function(p: number)
				return p * 0.0006451612903225806
			end,
			toMicrometerSquared = function(p: number)
				return p * 6.451612903225806e-10
			end,
			toMillimeterSquared = function(p: number)
				return p * 6.451612903225807e-7
			end,
			toCentimeterSquared = function(p: number)
				return p * 6.451612903225806e-6
			end,
			toKilometerSquared = function(p: number)
				return p * 0.6451612903225806
			end,
			toMegameterSquared = function(p: number)
				return p * 645.1612903225806
			end
		},
		FeetSquared = {
			toInchesSquared = function(p: number)
				return p * 16684.2
			end,
			toYardsSquared = function(p: number)
				return p * 9
			end,
			toMilesSquared = function(p: number)
				return p * 4.155984555984555e-6
			end,
			toAcre = function(p: number)
				return p * 0.002659839974696431
			end,
			toHectare = function(p: number)
				return p * 0.0010764
			end,
			toRoblox = function(p: number)
				return p * 137.29591836734693
			end,
			toMeterSquared = function(p: number)
				return p * 10.764
			end,
			toMicrometerSquared = function(p: number)
				return p * 0.000010763999999999999
			end,
			toMillimeterSquared = function(p: number)
				return p * 0.010764
			end,
			toCentimeterSquared = function(p: number)
				return p * 0.10764
			end,
			toKilometerSquared = function(p: number)
				return p * 10764
			end,
			toMegameterSquared = function(p: number)
				return p * 10764000
			end
		},
		YardsSquared = {
			toInchesSquared = function(p: number)
				return p * 1853.8
			end,
			toFeetSquared = function(p: number)
				return p * 0.11111111111111112
			end,
			toMilesSquared = function(p: number)
				return p * 4.6177606177606175e-7
			end,
			toAcre = function(p: number)
				return p * 0.00029553777496627015
			end,
			toHectare = function(p: number)
				return p * 0.00011960000000000001
			end,
			toRoblox = function(p: number)
				return p * 15.255102040816325
			end,
			toMeterSquared = function(p: number)
				return p * 1.196
			end,
			toMicrometerSquared = function(p: number)
				return p * 1.1959999999999999e-6
			end,
			toMillimeterSquared = function(p: number)
				return p * 0.001196
			end,
			toCentimeterSquared = function(p: number)
				return p * 0.01196
			end,
			toKilometerSquared = function(p: number)
				return p * 1196
			end,
			toMegameterSquared = function(p: number)
				return p * 1196000
			end
		},
		MilesSquared = {
			toInchesSquared = function(p: number)
				return p * 4014500000
			end,
			toFeetSquared = function(p: number)
				return p * 240616.8710516537
			end,
			toYardsSquared = function(p: number)
				return p * 2165551.839464883
			end,
			toAcre = function(p: number)
				return p * 640.0023722095649
			end,
			toHectare = function(p: number)
				return p * 259
			end,
			toRoblox = function(p: number)
				return p * 33035714.285714284
			end,
			toMeterSquared = function(p: number)
				return p * 2590000
			end,
			toMicrometerSquared = function(p: number)
				return p * 2.59
			end,
			toMillimeterSquared = function(p: number)
				return p * 2590
			end,
			toCentimeterSquared = function(p: number)
				return p * 25900
			end,
			toKilometerSquared = function(p: number)
				return p * 2590000000
			end,
			toMegameterSquared = function(p: number)
				return p * 2590000000000
			end
		},
		Acre = {
			toInchesSquared = function(p: number)
				return p * 6272633
			end,
			toFeetSquared = function(p: number)
				return p * 375.9624674842067
			end,
			toYardsSquared = function(p: number)
				return p * 3383.6622073578596
			end,
			toMilesSquared = function(p: number)
				return p * 0.0015624942084942084
			end,
			toHectare = function(p: number)
				return p * 0.40468600000000005
			end,
			toRoblox = function(p: number)
				return p * 51618.11224489796
			end,
			toMeterSquared = function(p: number)
				return p * 4046.86
			end,
			toMicrometerSquared = function(p: number)
				return p * 0.00404686
			end,
			toMillimeterSquared = function(p: number)
				return p * 4.046860000000001
			end,
			toCentimeterSquared = function(p: number)
				return p * 40.4686
			end,
			toKilometerSquared = function(p: number)
				return p * 4046860
			end,
			toMegameterSquared = function(p: number)
				return p * 4046860000
			end
		},
		Hectare = {
			toInchesSquared = function(p: number)
				return p * 15500000
			end,
			toFeetSquared = function(p: number)
				return p * 929.022668153103
			end,
			toYardsSquared = function(p: number)
				return p * 8361.204013377926
			end,
			toMilesSquared = function(p: number)
				return p * 0.0038610038610038607
			end,
			toAcre = function(p: number)
				return p * 2.4710516301527603
			end,
			toRoblox = function(p: number)
				return p * 127551.02040816325
			end,
			toMeterSquared = function(p: number)
				return p * 10000
			end,
			toMicrometerSquared = function(p: number)
				return p * 0.01
			end,
			toMillimeterSquared = function(p: number)
				return p * 10
			end,
			toCentimeterSquared = function(p: number)
				return p * 100
			end,
			toKilometerSquared = function(p: number)
				return p * 10000000
			end,
			toMegameterSquared = function(p: number)
				return p * 10000000000
			end
		},
		Roblox = {
			toInchesSquared = function(p: number)
				return p * 121.52000000000002
			end,
			toFeetSquared = function(p: number)
				return p * 0.007283537718320329
			end,
			toYardsSquared = function(p: number)
				return p * 0.06555183946488295
			end,
			toMilesSquared = function(p: number)
				return p * 3.027027027027027e-8
			end,
			toAcre = function(p: number)
				return p * 0.000019373044780397644
			end,
			toHectare = function(p: number)
				return p * 7.840000000000001e-6
			end,
			toMeterSquared = function(p: number)
				return p * 0.07840000000000001
			end,
			toMicrometerSquared = function(p: number)
				return p * 7.840000000000001e-8
			end,
			toMillimeterSquared = function(p: number)
				return p * 0.00007840000000000001
			end,
			toCentimeterSquared = function(p: number)
				return p * 0.0007840000000000001
			end,
			toKilometerSquared = function(p: number)
				return p * 78.4
			end,
			toMegameterSquared = function(p: number)
				return p * 78400.00000000001
			end
		},
		MeterSquared = {
			toInchesSquared = function(p: number)
				return p * 1550
			end,
			toFeetSquared = function(p: number)
				return p * 0.0929022668153103
			end,
			toYardsSquared = function(p: number)
				return p * 0.8361204013377926
			end,
			toMilesSquared = function(p: number)
				return p * 3.861003861003861e-7
			end,
			toAcre = function(p: number)
				return p * 0.00024710516301527604
			end,
			toHectare = function(p: number)
				return p * 0.0001
			end,
			toRoblox = function(p: number)
				return p * 12.755102040816325
			end,
			toMicrometerSquared = function(p: number)
				return p * 1e-6
			end,
			toMillimeterSquared = function(p: number)
				return p * 0.001
			end,
			toCentimeterSquared = function(p: number)
				return p * 0.01
			end,
			toKilometerSquared = function(p: number)
				return p * 1000
			end,
			toMegameterSquared = function(p: number)
				return p * 1000000
			end
		},
		MicrometerSquared = {
			toInchesSquared = function(p: number)
				return p * 1550000000
			end,
			toFeetSquared = function(p: number)
				return p * 92902.2668153103
			end,
			toYardsSquared = function(p: number)
				return p * 836120.4013377926
			end,
			toMilesSquared = function(p: number)
				return p * 0.38610038610038605
			end,
			toAcre = function(p: number)
				return p * 247.10516301527605
			end,
			toHectare = function(p: number)
				return p * 100
			end,
			toRoblox = function(p: number)
				return p * 12755102.040816326
			end,
			toMeterSquared = function(p: number)
				return p * 1000000
			end,
			toMillimeterSquared = function(p: number)
				return p * 1000
			end,
			toCentimeterSquared = function(p: number)
				return p * 10000
			end,
			toKilometerSquared = function(p: number)
				return p * 1000000000
			end,
			toMegameterSquared = function(p: number)
				return p * 1000000000000
			end
		},
		MillimeterSquared = {
			toInchesSquared = function(p: number)
				return p * 1550000
			end,
			toFeetSquared = function(p: number)
				return p * 92.9022668153103
			end,
			toYardsSquared = function(p: number)
				return p * 836.1204013377926
			end,
			toMilesSquared = function(p: number)
				return p * 0.0003861003861003861
			end,
			toAcre = function(p: number)
				return p * 0.24710516301527605
			end,
			toHectare = function(p: number)
				return p * 0.1
			end,
			toRoblox = function(p: number)
				return p * 12755.102040816326
			end,
			toMeterSquared = function(p: number)
				return p * 1000
			end,
			toMicrometerSquared = function(p: number)
				return p * 0.001
			end,
			toCentimeterSquared = function(p: number)
				return p * 10
			end,
			toKilometerSquared = function(p: number)
				return p * 1000000
			end,
			toMegameterSquared = function(p: number)
				return p * 1000000000
			end
		},
		CentimeterSquared = {
			toInchesSquared = function(p: number)
				return p * 155000
			end,
			toFeetSquared = function(p: number)
				return p * 9.29022668153103
			end,
			toYardsSquared = function(p: number)
				return p * 83.61204013377926
			end,
			toMilesSquared = function(p: number)
				return p * 0.000038610038610038606
			end,
			toAcre = function(p: number)
				return p * 0.024710516301527603
			end,
			toHectare = function(p: number)
				return p * 0.01
			end,
			toRoblox = function(p: number)
				return p * 1275.5102040816325
			end,
			toMeterSquared = function(p: number)
				return p * 100
			end,
			toMicrometerSquared = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillimeterSquared = function(p: number)
				return p * 0.1
			end,
			toKilometerSquared = function(p: number)
				return p * 100000
			end,
			toMegameterSquared = function(p: number)
				return p * 100000000
			end
		},
		KilometerSquared = {
			toInchesSquared = function(p: number)
				return p * 1.55
			end,
			toFeetSquared = function(p: number)
				return p * 0.00009290226681531031
			end,
			toYardsSquared = function(p: number)
				return p * 0.0008361204013377926
			end,
			toMilesSquared = function(p: number)
				return p * 3.8610038610038606e-10
			end,
			toAcre = function(p: number)
				return p * 2.4710516301527605e-7
			end,
			toHectare = function(p: number)
				return p * 1.0000000000000001e-7
			end,
			toRoblox = function(p: number)
				return p * 0.012755102040816325
			end,
			toMeterSquared = function(p: number)
				return p * 0.001
			end,
			toMicrometerSquared = function(p: number)
				return p * 1e-9
			end,
			toMillimeterSquared = function(p: number)
				return p * 1e-6
			end,
			toCentimeterSquared = function(p: number)
				return p * 0.00001
			end,
			toMegameterSquared = function(p: number)
				return p * 1000
			end
		},
		MegameterSquared = {
			toInchesSquared = function(p: number)
				return p * 0.00155
			end,
			toFeetSquared = function(p: number)
				return p * 9.29022668153103e-8
			end,
			toYardsSquared = function(p: number)
				return p * 8.361204013377926e-7
			end,
			toMilesSquared = function(p: number)
				return p * 3.861003861003861e-13
			end,
			toAcre = function(p: number)
				return p * 2.4710516301527603e-10
			end,
			toHectare = function(p: number)
				return p * 1e-10
			end,
			toRoblox = function(p: number)
				return p * 0.000012755102040816325
			end,
			toMeterSquared = function(p: number)
				return p * 1e-6
			end,
			toMicrometerSquared = function(p: number)
				return p * 1e-12
			end,
			toMillimeterSquared = function(p: number)
				return p * 1e-9
			end,
			toCentimeterSquared = function(p: number)
				return p * 1e-8
			end,
			toKilometerSquared = function(p: number)
				return p * 0.001
			end
		}
	},
	Volume = {
		InchesCubed = {
			toFeetCubed = function(p: number)
				return p * 0.0005786981417715633
			end,
			toMeterCubed = function(p: number)
				return p * 0.00001638699528054536
			end,
			toCentimeterCubed = function(p: number)
				return p * 16.38699528054536
			end,
			toImperialTeaspoon = function(p: number)
				return p * 2.768353434714211
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.9227844782380702
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.5767419375983219
			end,
			toImperialCup = function(p: number)
				return p * 0.05768222338751967
			end,
			toImperialPint = function(p: number)
				return p * 0.028841111693759833
			end,
			toImperialQuart = function(p: number)
				return p * 0.014425171901888521
			end,
			toImperialGallon = function(p: number)
				return p * 0.00367751240586745
			end,
			toUsTeaspoon = function(p: number)
				return p * 3.3249213424226536
			end,
			toUsTablespoon = function(p: number)
				return p * 1.1082197168327215
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.5541098584163607
			end,
			toUsLegalCup = function(p: number)
				return p * 0.06827920162558992
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.03462572102779234
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.017321054011536444
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.004329457141491508
			end,
			toRoblox = function(p: number)
				return p * 0.0007464921319490414
			end,
			toLiter = function(p: number)
				return p * 0.01638699528054536
			end,
			toMicroliter = function(p: number)
				return p * 1.6386995280545357e-8
			end,
			toMilliliter = function(p: number)
				return p * 0.00001638699528054536
			end,
			toCentiliter = function(p: number)
				return p * 0.0001638699528054536
			end,
			toKiloliter = function(p: number)
				return p * 16.38699528054536
			end,
			toMegaliter = function(p: number)
				return p * 16386.995280545358
			end
		},
		FeetCubed = {
			toInchesCubed = function(p: number)
				return p * 1728.0166080000001
			end,
			toMeterCubed = function(p: number)
				return p * 0.028317000000000002
			end,
			toCentimeterCubed = function(p: number)
				return p * 28317
			end,
			toImperialTeaspoon = function(p: number)
				return p * 4783.760712
			end,
			toImperialTablespoon = function(p: number)
				return p * 1594.586904
			end,
			toImperialFluidOunce = function(p: number)
				return p * 996.6196466999999
			end,
			toImperialCup = function(p: number)
				return p * 99.67584000000001
			end,
			toImperialPint = function(p: number)
				return p * 49.837920000000004
			end,
			toImperialQuart = function(p: number)
				return p * 24.92693661971831
			end,
			toImperialGallon = function(p: number)
				return p * 6.35480251346499
			end,
			toUsTeaspoon = function(p: number)
				return p * 5745.5193
			end,
			toUsTablespoon = function(p: number)
				return p * 1915.022076
			end,
			toUsFluidOunce = function(p: number)
				return p * 957.511038
			end,
			toUsLegalCup = function(p: number)
				return p * 117.98759439
			end,
			toUsLiquidPint = function(p: number)
				return p * 59.833821
			end,
			toUsLiquidQuart = function(p: number)
				return p * 29.931068999999997
			end,
			toUsLiquidGallon = function(p: number)
				return p * 7.481373844121531
			end,
			toRoblox = function(p: number)
				return p * 1.289950801749271
			end,
			toLiter = function(p: number)
				return p * 28.317
			end,
			toMicroliter = function(p: number)
				return p * 0.000028317
			end,
			toMilliliter = function(p: number)
				return p * 0.028317000000000002
			end,
			toCentiliter = function(p: number)
				return p * 0.28317000000000003
			end,
			toKiloliter = function(p: number)
				return p * 28317
			end,
			toMegaliter = function(p: number)
				return p * 28317000
			end
		},
		MeterCubed = {
			toInchesCubed = function(p: number)
				return p * 61024
			end,
			toFeetCubed = function(p: number)
				return p * 35.31447540346788
			end,
			toCentimeterCubed = function(p: number)
				return p * 1000000
			end,
			toImperialTeaspoon = function(p: number)
				return p * 168936
			end,
			toImperialTablespoon = function(p: number)
				return p * 56312
			end,
			toImperialFluidOunce = function(p: number)
				return p * 35195.1
			end,
			toImperialCup = function(p: number)
				return p * 3520
			end,
			toImperialPint = function(p: number)
				return p * 1760
			end,
			toImperialQuart = function(p: number)
				return p * 880.2816901408452
			end,
			toImperialGallon = function(p: number)
				return p * 224.41651705565528
			end,
			toUsTeaspoon = function(p: number)
				return p * 202900
			end,
			toUsTablespoon = function(p: number)
				return p * 67628
			end,
			toUsFluidOunce = function(p: number)
				return p * 33814
			end,
			toUsLegalCup = function(p: number)
				return p * 4166.67
			end,
			toUsLiquidPint = function(p: number)
				return p * 2113
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1057
			end,
			toUsLiquidGallon = function(p: number)
				return p * 264.20079260237776
			end,
			toRoblox = function(p: number)
				return p * 45.553935860058296
			end,
			toLiter = function(p: number)
				return p * 1000
			end,
			toMicroliter = function(p: number)
				return p * 0.001
			end,
			toMilliliter = function(p: number)
				return p * 1
			end,
			toCentiliter = function(p: number)
				return p * 10
			end,
			toKiloliter = function(p: number)
				return p * 1000000
			end,
			toMegaliter = function(p: number)
				return p * 1000000000
			end
		},
		CentimeterCubed = {
			toInchesCubed = function(p: number)
				return p * 0.061024
			end,
			toFeetCubed = function(p: number)
				return p * 0.00003531447540346788
			end,
			toMeterCubed = function(p: number)
				return p * 1e-6
			end,
			toImperialTeaspoon = function(p: number)
				return p * 0.168936
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.056312
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.0351951
			end,
			toImperialCup = function(p: number)
				return p * 0.00352
			end,
			toImperialPint = function(p: number)
				return p * 0.00176
			end,
			toImperialQuart = function(p: number)
				return p * 0.0008802816901408451
			end,
			toImperialGallon = function(p: number)
				return p * 0.00022441651705565528
			end,
			toUsTeaspoon = function(p: number)
				return p * 0.2029
			end,
			toUsTablespoon = function(p: number)
				return p * 0.06762800000000001
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.033814000000000004
			end,
			toUsLegalCup = function(p: number)
				return p * 0.00416667
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.002113
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.001057
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.0002642007926023778
			end,
			toRoblox = function(p: number)
				return p * 0.0000455539358600583
			end,
			toLiter = function(p: number)
				return p * 0.001
			end,
			toMicroliter = function(p: number)
				return p * 1e-9
			end,
			toMilliliter = function(p: number)
				return p * 1e-6
			end,
			toCentiliter = function(p: number)
				return p * 0.00001
			end,
			toKiloliter = function(p: number)
				return p * 1
			end,
			toMegaliter = function(p: number)
				return p * 1000
			end
		},
		ImperialTeaspoon = {
			toInchesCubed = function(p: number)
				return p * 0.36122555287209357
			end,
			toFeetCubed = function(p: number)
				return p * 0.00020904055620748615
			end,
			toMeterCubed = function(p: number)
				return p * 5.919401430127385e-6
			end,
			toCentimeterCubed = function(p: number)
				return p * 5.919401430127386
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.3333333333333333
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.20833392527347633
			end,
			toImperialCup = function(p: number)
				return p * 0.0208362930340484
			end,
			toImperialPint = function(p: number)
				return p * 0.0104181465170242
			end,
			toImperialQuart = function(p: number)
				return p * 0.005210740695534671
			end,
			toImperialGallon = function(p: number)
				return p * 0.0013284114520034525
			end,
			toUsTeaspoon = function(p: number)
				return p * 1.2010465501728464
			end,
			toUsTablespoon = function(p: number)
				return p * 0.40031727991665483
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.20015863995832742
			end,
			toUsLegalCup = function(p: number)
				return p * 0.024664192356868873
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.012507695221859166
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.006256807311644646
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.0015639105495713038
			end,
			toRoblox = function(p: number)
				return p * 0.0002696520330779603
			end,
			toLiter = function(p: number)
				return p * 0.0059194014301273854
			end,
			toMicroliter = function(p: number)
				return p * 5.919401430127385e-9
			end,
			toMilliliter = function(p: number)
				return p * 5.919401430127385e-6
			end,
			toCentiliter = function(p: number)
				return p * 0.00005919401430127386
			end,
			toKiloliter = function(p: number)
				return p * 5.919401430127386
			end,
			toMegaliter = function(p: number)
				return p * 5919.4014301273855
			end
		},
		ImperialTablespoon = {
			toInchesCubed = function(p: number)
				return p * 1.083676658616281
			end,
			toFeetCubed = function(p: number)
				return p * 0.0006271216686224585
			end,
			toMeterCubed = function(p: number)
				return p * 0.00001775820429038216
			end,
			toCentimeterCubed = function(p: number)
				return p * 17.75820429038216
			end,
			toImperialTeaspoon = function(p: number)
				return p * 3.0000000000000004
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.625001775820429
			end,
			toImperialCup = function(p: number)
				return p * 0.0625088791021452
			end,
			toImperialPint = function(p: number)
				return p * 0.0312544395510726
			end,
			toImperialQuart = function(p: number)
				return p * 0.015632222086604013
			end,
			toImperialGallon = function(p: number)
				return p * 0.003985234356010358
			end,
			toUsTeaspoon = function(p: number)
				return p * 3.60313965051854
			end,
			toUsTablespoon = function(p: number)
				return p * 1.2009518397499646
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.6004759198749823
			end,
			toUsLegalCup = function(p: number)
				return p * 0.07399257707060662
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.0375230856655775
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.01877042193493394
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.004691731648713912
			end,
			toRoblox = function(p: number)
				return p * 0.000808956099233881
			end,
			toLiter = function(p: number)
				return p * 0.01775820429038216
			end,
			toMicroliter = function(p: number)
				return p * 1.775820429038216e-8
			end,
			toMilliliter = function(p: number)
				return p * 0.00001775820429038216
			end,
			toCentiliter = function(p: number)
				return p * 0.0001775820429038216
			end,
			toKiloliter = function(p: number)
				return p * 17.75820429038216
			end,
			toMegaliter = function(p: number)
				return p * 17758.20429038216
			end
		},
		ImperialFluidOunce = {
			toInchesCubed = function(p: number)
				return p * 1.733877727297266
			end,
			toFeetCubed = function(p: number)
				return p * 0.0010033918188460294
			end,
			toMeterCubed = function(p: number)
				return p * 0.000028413046134263013
			end,
			toCentimeterCubed = function(p: number)
				return p * 28.413046134263013
			end,
			toImperialTeaspoon = function(p: number)
				return p * 4.799986361737856
			end,
			toImperialTablespoon = function(p: number)
				return p * 1.5999954539126187
			end,
			toImperialCup = function(p: number)
				return p * 0.1000139223926058
			end,
			toImperialPint = function(p: number)
				return p * 0.0500069611963029
			end,
			toImperialQuart = function(p: number)
				return p * 0.02501148427311885
			end,
			toImperialGallon = function(p: number)
				return p * 0.006376356852392955
			end,
			toUsTeaspoon = function(p: number)
				return p * 5.765007060641965
			end,
			toUsTablespoon = function(p: number)
				return p * 1.921517483967939
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.9607587419839695
			end,
			toUsLegalCup = function(p: number)
				return p * 0.11838778693624966
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.06003676648169774
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.030032589763916002
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.007506749308920213
			end,
			toRoblox = function(p: number)
				return p * 0.0012943260811890947
			end,
			toLiter = function(p: number)
				return p * 0.02841304613426301
			end,
			toMicroliter = function(p: number)
				return p * 2.841304613426301e-8
			end,
			toMilliliter = function(p: number)
				return p * 0.000028413046134263013
			end,
			toCentiliter = function(p: number)
				return p * 0.0002841304613426301
			end,
			toKiloliter = function(p: number)
				return p * 28.413046134263013
			end,
			toMegaliter = function(p: number)
				return p * 28413.04613426301
			end
		},
		ImperialCup = {
			toInchesCubed = function(p: number)
				return p * 17.33636363636364
			end,
			toFeetCubed = function(p: number)
				return p * 0.01003252142143974
			end,
			toMeterCubed = function(p: number)
				return p * 0.00028409090909090913
			end,
			toCentimeterCubed = function(p: number)
				return p * 284.0909090909091
			end,
			toImperialTeaspoon = function(p: number)
				return p * 47.993181818181824
			end,
			toImperialTablespoon = function(p: number)
				return p * 15.997727272727273
			end,
			toImperialFluidOunce = function(p: number)
				return p * 9.998607954545454
			end,
			toImperialPint = function(p: number)
				return p * 0.5
			end,
			toImperialQuart = function(p: number)
				return p * 0.25008002560819464
			end,
			toImperialGallon = function(p: number)
				return p * 0.06375469234535662
			end,
			toUsTeaspoon = function(p: number)
				return p * 57.64204545454546
			end,
			toUsTablespoon = function(p: number)
				return p * 19.212500000000002
			end,
			toUsFluidOunce = function(p: number)
				return p * 9.606250000000001
			end,
			toUsLegalCup = function(p: number)
				return p * 1.1837130681818182
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.600284090909091
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.3002840909090909
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.07505704335294824
			end,
			toRoblox = function(p: number)
				return p * 0.012941459051152926
			end,
			toLiter = function(p: number)
				return p * 0.2840909090909091
			end,
			toMicroliter = function(p: number)
				return p * 2.840909090909091e-7
			end,
			toMilliliter = function(p: number)
				return p * 0.00028409090909090913
			end,
			toCentiliter = function(p: number)
				return p * 0.0028409090909090914
			end,
			toKiloliter = function(p: number)
				return p * 284.0909090909091
			end,
			toMegaliter = function(p: number)
				return p * 284090.9090909091
			end
		},
		ImperialPint = {
			toInchesCubed = function(p: number)
				return p * 34.67272727272728
			end,
			toFeetCubed = function(p: number)
				return p * 0.02006504284287948
			end,
			toMeterCubed = function(p: number)
				return p * 0.0005681818181818183
			end,
			toCentimeterCubed = function(p: number)
				return p * 568.1818181818182
			end,
			toImperialTeaspoon = function(p: number)
				return p * 95.98636363636365
			end,
			toImperialTablespoon = function(p: number)
				return p * 31.995454545454546
			end,
			toImperialFluidOunce = function(p: number)
				return p * 19.997215909090908
			end,
			toImperialCup = function(p: number)
				return p * 2
			end,
			toImperialQuart = function(p: number)
				return p * 0.5001600512163893
			end,
			toImperialGallon = function(p: number)
				return p * 0.12750938469071324
			end,
			toUsTeaspoon = function(p: number)
				return p * 115.28409090909092
			end,
			toUsTablespoon = function(p: number)
				return p * 38.425000000000004
			end,
			toUsFluidOunce = function(p: number)
				return p * 19.212500000000002
			end,
			toUsLegalCup = function(p: number)
				return p * 2.3674261363636364
			end,
			toUsLiquidPint = function(p: number)
				return p * 1.200568181818182
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.6005681818181818
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.1501140867058965
			end,
			toRoblox = function(p: number)
				return p * 0.025882918102305853
			end,
			toLiter = function(p: number)
				return p * 0.5681818181818182
			end,
			toMicroliter = function(p: number)
				return p * 5.681818181818182e-7
			end,
			toMilliliter = function(p: number)
				return p * 0.0005681818181818183
			end,
			toCentiliter = function(p: number)
				return p * 0.005681818181818183
			end,
			toKiloliter = function(p: number)
				return p * 568.1818181818182
			end,
			toMegaliter = function(p: number)
				return p * 568181.8181818182
			end
		},
		ImperialQuart = {
			toInchesCubed = function(p: number)
				return p * 69.323264
			end,
			toFeetCubed = function(p: number)
				return p * 0.04011724405833951
			end,
			toMeterCubed = function(p: number)
				return p * 0.0011359999999999999
			end,
			toCentimeterCubed = function(p: number)
				return p * 1136
			end,
			toImperialTeaspoon = function(p: number)
				return p * 191.911296
			end,
			toImperialTablespoon = function(p: number)
				return p * 63.97043199999999
			end,
			toImperialFluidOunce = function(p: number)
				return p * 39.981633599999995
			end,
			toImperialCup = function(p: number)
				return p * 3.9987199999999996
			end,
			toImperialPint = function(p: number)
				return p * 1.9993599999999998
			end,
			toImperialGallon = function(p: number)
				return p * 0.2549371633752244
			end,
			toUsTeaspoon = function(p: number)
				return p * 230.49439999999998
			end,
			toUsTablespoon = function(p: number)
				return p * 76.825408
			end,
			toUsFluidOunce = function(p: number)
				return p * 38.412704
			end,
			toUsLegalCup = function(p: number)
				return p * 4.73333712
			end,
			toUsLiquidPint = function(p: number)
				return p * 2.400368
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1.2007519999999998
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.3001321003963011
			end,
			toRoblox = function(p: number)
				return p * 0.05174927113702622
			end,
			toLiter = function(p: number)
				return p * 1.136
			end,
			toMicroliter = function(p: number)
				return p * 1.1359999999999998e-6
			end,
			toMilliliter = function(p: number)
				return p * 0.0011359999999999999
			end,
			toCentiliter = function(p: number)
				return p * 0.011359999999999999
			end,
			toKiloliter = function(p: number)
				return p * 1136
			end,
			toMegaliter = function(p: number)
				return p * 1136000
			end
		},
		ImperialGallon = {
			toInchesCubed = function(p: number)
				return p * 271.92294400000003
			end,
			toFeetCubed = function(p: number)
				return p * 0.1573613023978529
			end,
			toMeterCubed = function(p: number)
				return p * 0.004456000000000001
			end,
			toCentimeterCubed = function(p: number)
				return p * 4456
			end,
			toImperialTeaspoon = function(p: number)
				return p * 752.7788160000001
			end,
			toImperialTablespoon = function(p: number)
				return p * 250.926272
			end,
			toImperialFluidOunce = function(p: number)
				return p * 156.8293656
			end,
			toImperialCup = function(p: number)
				return p * 15.685120000000001
			end,
			toImperialPint = function(p: number)
				return p * 7.842560000000001
			end,
			toImperialQuart = function(p: number)
				return p * 3.9225352112676064
			end,
			toUsTeaspoon = function(p: number)
				return p * 904.1224000000001
			end,
			toUsTablespoon = function(p: number)
				return p * 301.350368
			end,
			toUsFluidOunce = function(p: number)
				return p * 150.675184
			end,
			toUsLegalCup = function(p: number)
				return p * 18.56668152
			end,
			toUsLiquidPint = function(p: number)
				return p * 9.415528
			end,
			toUsLiquidQuart = function(p: number)
				return p * 4.709992
			end,
			toUsLiquidGallon = function(p: number)
				return p * 1.1772787318361955
			end,
			toRoblox = function(p: number)
				return p * 0.2029883381924198
			end,
			toLiter = function(p: number)
				return p * 4.456
			end,
			toMicroliter = function(p: number)
				return p * 4.456e-6
			end,
			toMilliliter = function(p: number)
				return p * 0.004456000000000001
			end,
			toCentiliter = function(p: number)
				return p * 0.04456
			end,
			toKiloliter = function(p: number)
				return p * 4456
			end,
			toMegaliter = function(p: number)
				return p * 4456000
			end
		},
		UsTeaspoon = {
			toInchesCubed = function(p: number)
				return p * 0.30075899457861016
			end,
			toFeetCubed = function(p: number)
				return p * 0.00017404867128372538
			end,
			toMeterCubed = function(p: number)
				return p * 4.928536224741252e-6
			end,
			toCentimeterCubed = function(p: number)
				return p * 4.928536224741252
			end,
			toImperialTeaspoon = function(p: number)
				return p * 0.8326071956628881
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.27753573188762937
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.1734603252833908
			end,
			toImperialCup = function(p: number)
				return p * 0.017348447511089205
			end,
			toImperialPint = function(p: number)
				return p * 0.008674223755544603
			end,
			toImperialQuart = function(p: number)
				return p * 0.004338500197835609
			end,
			toImperialGallon = function(p: number)
				return p * 0.0011060449337390599
			end,
			toUsTablespoon = function(p: number)
				return p * 0.33330704780680137
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.16665352390340069
			end,
			toUsLegalCup = function(p: number)
				return p * 0.02053558403154263
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.010413997042878265
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.005209462789551503
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.0013021231769461694
			end,
			toRoblox = function(p: number)
				return p * 0.00022451422306583684
			end,
			toLiter = function(p: number)
				return p * 0.0049285362247412515
			end,
			toMicroliter = function(p: number)
				return p * 4.928536224741251e-9
			end,
			toMilliliter = function(p: number)
				return p * 4.928536224741252e-6
			end,
			toCentiliter = function(p: number)
				return p * 0.000049285362247412513
			end,
			toKiloliter = function(p: number)
				return p * 4.928536224741252
			end,
			toMegaliter = function(p: number)
				return p * 4928.536224741251
			end
		},
		UsTablespoon = {
			toInchesCubed = function(p: number)
				return p * 0.9023481398237416
			end,
			toFeetCubed = function(p: number)
				return p * 0.0005221871917470262
			end,
			toMeterCubed = function(p: number)
				return p * 0.000014786774708700538
			end,
			toCentimeterCubed = function(p: number)
				return p * 14.786774708700538
			end,
			toImperialTeaspoon = function(p: number)
				return p * 2.4980185721890344
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.8326728573963447
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.5204220145501862
			end,
			toImperialCup = function(p: number)
				return p * 0.05204944697462589
			end,
			toImperialPint = function(p: number)
				return p * 0.026024723487312947
			end,
			toImperialQuart = function(p: number)
				return p * 0.013016527032306813
			end,
			toImperialGallon = function(p: number)
				return p * 0.0033183964786132262
			end,
			toUsTeaspoon = function(p: number)
				return p * 3.0002365883953392
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.5
			end,
			toUsLegalCup = function(p: number)
				return p * 0.06161161057550127
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.031244454959484236
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.015629620867096468
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.003906677598071476
			end,
			toRoblox = function(p: number)
				return p * 0.0006735957866572766
			end,
			toLiter = function(p: number)
				return p * 0.014786774708700538
			end,
			toMicroliter = function(p: number)
				return p * 1.4786774708700537e-8
			end,
			toMilliliter = function(p: number)
				return p * 0.000014786774708700538
			end,
			toCentiliter = function(p: number)
				return p * 0.0001478677470870054
			end,
			toKiloliter = function(p: number)
				return p * 14.786774708700538
			end,
			toMegaliter = function(p: number)
				return p * 14786.77470870054
			end
		},
		UsFluidOunce = {
			toInchesCubed = function(p: number)
				return p * 1.8046962796474832
			end,
			toFeetCubed = function(p: number)
				return p * 0.0010443743834940523
			end,
			toMeterCubed = function(p: number)
				return p * 0.000029573549417401077
			end,
			toCentimeterCubed = function(p: number)
				return p * 29.573549417401075
			end,
			toImperialTeaspoon = function(p: number)
				return p * 4.996037144378069
			end,
			toImperialTablespoon = function(p: number)
				return p * 1.6653457147926893
			end,
			toImperialFluidOunce = function(p: number)
				return p * 1.0408440291003724
			end,
			toImperialCup = function(p: number)
				return p * 0.10409889394925179
			end,
			toImperialPint = function(p: number)
				return p * 0.05204944697462589
			end,
			toImperialQuart = function(p: number)
				return p * 0.026033054064613627
			end,
			toImperialGallon = function(p: number)
				return p * 0.0066367929572264525
			end,
			toUsTeaspoon = function(p: number)
				return p * 6.0004731767906785
			end,
			toUsTablespoon = function(p: number)
				return p * 2
			end,
			toUsLegalCup = function(p: number)
				return p * 0.12322322115100254
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.06248890991896847
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.031259241734192936
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.007813355196142952
			end,
			toRoblox = function(p: number)
				return p * 0.0013471915733145531
			end,
			toLiter = function(p: number)
				return p * 0.029573549417401077
			end,
			toMicroliter = function(p: number)
				return p * 2.9573549417401074e-8
			end,
			toMilliliter = function(p: number)
				return p * 0.000029573549417401077
			end,
			toCentiliter = function(p: number)
				return p * 0.0002957354941740108
			end,
			toKiloliter = function(p: number)
				return p * 29.573549417401075
			end,
			toMegaliter = function(p: number)
				return p * 29573.54941740108
			end
		},
		UsLegalCup = {
			toInchesCubed = function(p: number)
				return p * 14.645748283401375
			end,
			toFeetCubed = function(p: number)
				return p * 0.008475467316458438
			end,
			toMeterCubed = function(p: number)
				return p * 0.00023999980800015362
			end,
			toCentimeterCubed = function(p: number)
				return p * 239.99980800015362
			end,
			toImperialTeaspoon = function(p: number)
				return p * 40.54460756431395
			end,
			toImperialTablespoon = function(p: number)
				return p * 13.51486918810465
			end,
			toImperialFluidOunce = function(p: number)
				return p * 8.446817242546205
			end,
			toImperialCup = function(p: number)
				return p * 0.8447993241605407
			end,
			toImperialPint = function(p: number)
				return p * 0.42239966208027035
			end,
			toImperialQuart = function(p: number)
				return p * 0.21126743661985353
			end,
			toImperialGallon = function(p: number)
				return p * 0.05385992100542046
			end,
			toUsTeaspoon = function(p: number)
				return p * 48.69596104323117
			end,
			toUsTablespoon = function(p: number)
				return p * 16.230707015434387
			end,
			toUsFluidOunce = function(p: number)
				return p * 8.115353507717193
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.5071195943043245
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.25367979705616234
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.06340813949805907
			end,
			toRoblox = function(p: number)
				return p * 0.010932935860065305
			end,
			toLiter = function(p: number)
				return p * 0.2399998080001536
			end,
			toMicroliter = function(p: number)
				return p * 2.399998080001536e-7
			end,
			toMilliliter = function(p: number)
				return p * 0.00023999980800015362
			end,
			toCentiliter = function(p: number)
				return p * 0.002399998080001536
			end,
			toKiloliter = function(p: number)
				return p * 239.99980800015362
			end,
			toMegaliter = function(p: number)
				return p * 239999.8080001536
			end
		},
		UsLiquidPint = {
			toInchesCubed = function(p: number)
				return p * 28.880265026029345
			end,
			toFeetCubed = function(p: number)
				return p * 0.01671295570443345
			end,
			toMeterCubed = function(p: number)
				return p * 0.00047326076668244207
			end,
			toCentimeterCubed = function(p: number)
				return p * 473.26076668244207
			end,
			toImperialTeaspoon = function(p: number)
				return p * 79.95078088026503
			end,
			toImperialTablespoon = function(p: number)
				return p * 26.650260293421674
			end,
			toImperialFluidOunce = function(p: number)
				return p * 16.656460009465214
			end,
			toImperialCup = function(p: number)
				return p * 1.665877898722196
			end,
			toImperialPint = function(p: number)
				return p * 0.832938949361098
			end,
			toImperialQuart = function(p: number)
				return p * 0.41660278757257224
			end,
			toImperialGallon = function(p: number)
				return p * 0.10620753291796274
			end,
			toUsTeaspoon = function(p: number)
				return p * 96.0246095598675
			end,
			toUsTablespoon = function(p: number)
				return p * 32.00567912920019
			end,
			toUsFluidOunce = function(p: number)
				return p * 16.002839564600094
			end,
			toUsLegalCup = function(p: number)
				return p * 1.9719214387127308
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.5002366303833412
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.12503586966511018
			end,
			toRoblox = function(p: number)
				return p * 0.02155889061053398
			end,
			toLiter = function(p: number)
				return p * 0.47326076668244205
			end,
			toMicroliter = function(p: number)
				return p * 4.73260766682442e-7
			end,
			toMilliliter = function(p: number)
				return p * 0.00047326076668244207
			end,
			toCentiliter = function(p: number)
				return p * 0.004732607666824421
			end,
			toKiloliter = function(p: number)
				return p * 473.26076668244207
			end,
			toMegaliter = function(p: number)
				return p * 473260.76668244204
			end
		},
		UsLiquidQuart = {
			toInchesCubed = function(p: number)
				return p * 57.73320719016084
			end,
			toFeetCubed = function(p: number)
				return p * 0.033410099719458734
			end,
			toMeterCubed = function(p: number)
				return p * 0.0009460737937559131
			end,
			toCentimeterCubed = function(p: number)
				return p * 946.073793755913
			end,
			toImperialTeaspoon = function(p: number)
				return p * 159.82592242194895
			end,
			toImperialTablespoon = function(p: number)
				return p * 53.27530747398297
			end,
			toImperialFluidOunce = function(p: number)
				return p * 33.29716177861873
			end,
			toImperialCup = function(p: number)
				return p * 3.330179754020814
			end,
			toImperialPint = function(p: number)
				return p * 1.665089877010407
			end,
			toImperialQuart = function(p: number)
				return p * 0.8328114381654165
			end,
			toImperialGallon = function(p: number)
				return p * 0.21231458567233236
			end,
			toUsTeaspoon = function(p: number)
				return p * 191.95837275307477
			end,
			toUsTablespoon = function(p: number)
				return p * 63.98107852412489
			end,
			toUsFluidOunce = function(p: number)
				return p * 31.990539262062445
			end,
			toUsLegalCup = function(p: number)
				return p * 3.94197729422895
			end,
			toUsLiquidPint = function(p: number)
				return p * 1.9990539262062443
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.2499534461706507
			end,
			toRoblox = function(p: number)
				return p * 0.04309738491963889
			end,
			toLiter = function(p: number)
				return p * 0.946073793755913
			end,
			toMicroliter = function(p: number)
				return p * 9.46073793755913e-7
			end,
			toMilliliter = function(p: number)
				return p * 0.0009460737937559131
			end,
			toCentiliter = function(p: number)
				return p * 0.009460737937559131
			end,
			toKiloliter = function(p: number)
				return p * 946.073793755913
			end,
			toMegaliter = function(p: number)
				return p * 946073.793755913
			end
		},
		UsLiquidGallon = {
			toInchesCubed = function(p: number)
				return p * 230.97584000000003
			end,
			toFeetCubed = function(p: number)
				return p * 0.13366528940212596
			end,
			toMeterCubed = function(p: number)
				return p * 0.0037850000000000006
			end,
			toCentimeterCubed = function(p: number)
				return p * 3785.0000000000005
			end,
			toImperialTeaspoon = function(p: number)
				return p * 639.4227600000002
			end,
			toImperialTablespoon = function(p: number)
				return p * 213.14092000000002
			end,
			toImperialFluidOunce = function(p: number)
				return p * 133.2134535
			end,
			toImperialCup = function(p: number)
				return p * 13.323200000000002
			end,
			toImperialPint = function(p: number)
				return p * 6.661600000000001
			end,
			toImperialQuart = function(p: number)
				return p * 3.3318661971830994
			end,
			toImperialGallon = function(p: number)
				return p * 0.8494165170556554
			end,
			toUsTeaspoon = function(p: number)
				return p * 767.9765000000001
			end,
			toUsTablespoon = function(p: number)
				return p * 255.97198000000003
			end,
			toUsFluidOunce = function(p: number)
				return p * 127.98599000000002
			end,
			toUsLegalCup = function(p: number)
				return p * 15.770845950000002
			end,
			toUsLiquidPint = function(p: number)
				return p * 7.997705000000002
			end,
			toUsLiquidQuart = function(p: number)
				return p * 4.000745
			end,
			toRoblox = function(p: number)
				return p * 0.1724216472303207
			end,
			toLiter = function(p: number)
				return p * 3.7850000000000006
			end,
			toMicroliter = function(p: number)
				return p * 3.7850000000000006e-6
			end,
			toMilliliter = function(p: number)
				return p * 0.0037850000000000006
			end,
			toCentiliter = function(p: number)
				return p * 0.03785000000000001
			end,
			toKiloliter = function(p: number)
				return p * 3785.0000000000005
			end,
			toMegaliter = function(p: number)
				return p * 3785000.0000000005
			end
		},
		Roblox = {
			toInchesCubed = function(p: number)
				return p * 1339.5988480000003
			end,
			toFeetCubed = function(p: number)
				return p * 0.7752233640569272
			end,
			toMeterCubed = function(p: number)
				return p * 0.021952000000000006
			end,
			toCentimeterCubed = function(p: number)
				return p * 21952.000000000004
			end,
			toImperialTeaspoon = function(p: number)
				return p * 3708.483072000001
			end,
			toImperialTablespoon = function(p: number)
				return p * 1236.1610240000002
			end,
			toImperialFluidOunce = function(p: number)
				return p * 772.6028352000001
			end,
			toImperialCup = function(p: number)
				return p * 77.27104000000001
			end,
			toImperialPint = function(p: number)
				return p * 38.63552000000001
			end,
			toImperialQuart = function(p: number)
				return p * 19.323943661971835
			end,
			toImperialGallon = function(p: number)
				return p * 4.926391382405746
			end,
			toUsTeaspoon = function(p: number)
				return p * 4454.060800000001
			end,
			toUsTablespoon = function(p: number)
				return p * 1484.5698560000003
			end,
			toUsFluidOunce = function(p: number)
				return p * 742.2849280000001
			end,
			toUsLegalCup = function(p: number)
				return p * 91.46673984000002
			end,
			toUsLiquidPint = function(p: number)
				return p * 46.38457600000001
			end,
			toUsLiquidQuart = function(p: number)
				return p * 23.203264000000004
			end,
			toUsLiquidGallon = function(p: number)
				return p * 5.799735799207398
			end,
			toLiter = function(p: number)
				return p * 21.952000000000005
			end,
			toMicroliter = function(p: number)
				return p * 0.000021952000000000006
			end,
			toMilliliter = function(p: number)
				return p * 0.021952000000000006
			end,
			toCentiliter = function(p: number)
				return p * 0.21952000000000005
			end,
			toKiloliter = function(p: number)
				return p * 21952.000000000004
			end,
			toMegaliter = function(p: number)
				return p * 21952000.000000004
			end
		},
		Liter = {
			toInchesCubed = function(p: number)
				return p * 61.024
			end,
			toFeetCubed = function(p: number)
				return p * 0.03531447540346788
			end,
			toMeterCubed = function(p: number)
				return p * 0.001
			end,
			toCentimeterCubed = function(p: number)
				return p * 1000
			end,
			toImperialTeaspoon = function(p: number)
				return p * 168.936
			end,
			toImperialTablespoon = function(p: number)
				return p * 56.312
			end,
			toImperialFluidOunce = function(p: number)
				return p * 35.1951
			end,
			toImperialCup = function(p: number)
				return p * 3.52
			end,
			toImperialPint = function(p: number)
				return p * 1.76
			end,
			toImperialQuart = function(p: number)
				return p * 0.8802816901408451
			end,
			toImperialGallon = function(p: number)
				return p * 0.22441651705565527
			end,
			toUsTeaspoon = function(p: number)
				return p * 202.9
			end,
			toUsTablespoon = function(p: number)
				return p * 67.628
			end,
			toUsFluidOunce = function(p: number)
				return p * 33.814
			end,
			toUsLegalCup = function(p: number)
				return p * 4.16667
			end,
			toUsLiquidPint = function(p: number)
				return p * 2.113
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1.057
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.2642007926023778
			end,
			toRoblox = function(p: number)
				return p * 0.0455539358600583
			end,
			toMicroliter = function(p: number)
				return p * 1e-6
			end,
			toMilliliter = function(p: number)
				return p * 0.001
			end,
			toCentiliter = function(p: number)
				return p * 0.01
			end,
			toKiloliter = function(p: number)
				return p * 1000
			end,
			toMegaliter = function(p: number)
				return p * 1000000
			end
		},
		Microliter = {
			toInchesCubed = function(p: number)
				return p * 61024000
			end,
			toFeetCubed = function(p: number)
				return p * 35314.475403467884
			end,
			toMeterCubed = function(p: number)
				return p * 1000
			end,
			toCentimeterCubed = function(p: number)
				return p * 1000000000
			end,
			toImperialTeaspoon = function(p: number)
				return p * 168936000
			end,
			toImperialTablespoon = function(p: number)
				return p * 56312000
			end,
			toImperialFluidOunce = function(p: number)
				return p * 35195100
			end,
			toImperialCup = function(p: number)
				return p * 3520000
			end,
			toImperialPint = function(p: number)
				return p * 1760000
			end,
			toImperialQuart = function(p: number)
				return p * 880281.6901408451
			end,
			toImperialGallon = function(p: number)
				return p * 224416.51705565528
			end,
			toUsTeaspoon = function(p: number)
				return p * 202900000
			end,
			toUsTablespoon = function(p: number)
				return p * 67628000
			end,
			toUsFluidOunce = function(p: number)
				return p * 33814000
			end,
			toUsLegalCup = function(p: number)
				return p * 4166670
			end,
			toUsLiquidPint = function(p: number)
				return p * 2113000
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1057000
			end,
			toUsLiquidGallon = function(p: number)
				return p * 264200.79260237777
			end,
			toRoblox = function(p: number)
				return p * 45553.9358600583
			end,
			toLiter = function(p: number)
				return p * 1000000
			end,
			toMilliliter = function(p: number)
				return p * 1000
			end,
			toCentiliter = function(p: number)
				return p * 10000
			end,
			toKiloliter = function(p: number)
				return p * 1000000000
			end,
			toMegaliter = function(p: number)
				return p * 1000000000000
			end
		},
		Milliliter = {
			toInchesCubed = function(p: number)
				return p * 61024
			end,
			toFeetCubed = function(p: number)
				return p * 35.31447540346788
			end,
			toMeterCubed = function(p: number)
				return p * 1
			end,
			toCentimeterCubed = function(p: number)
				return p * 1000000
			end,
			toImperialTeaspoon = function(p: number)
				return p * 168936
			end,
			toImperialTablespoon = function(p: number)
				return p * 56312
			end,
			toImperialFluidOunce = function(p: number)
				return p * 35195.1
			end,
			toImperialCup = function(p: number)
				return p * 3520
			end,
			toImperialPint = function(p: number)
				return p * 1760
			end,
			toImperialQuart = function(p: number)
				return p * 880.2816901408452
			end,
			toImperialGallon = function(p: number)
				return p * 224.41651705565528
			end,
			toUsTeaspoon = function(p: number)
				return p * 202900
			end,
			toUsTablespoon = function(p: number)
				return p * 67628
			end,
			toUsFluidOunce = function(p: number)
				return p * 33814
			end,
			toUsLegalCup = function(p: number)
				return p * 4166.67
			end,
			toUsLiquidPint = function(p: number)
				return p * 2113
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1057
			end,
			toUsLiquidGallon = function(p: number)
				return p * 264.20079260237776
			end,
			toRoblox = function(p: number)
				return p * 45.553935860058296
			end,
			toLiter = function(p: number)
				return p * 1000
			end,
			toMicroliter = function(p: number)
				return p * 0.001
			end,
			toCentiliter = function(p: number)
				return p * 10
			end,
			toKiloliter = function(p: number)
				return p * 1000000
			end,
			toMegaliter = function(p: number)
				return p * 1000000000
			end
		},
		Centiliter = {
			toInchesCubed = function(p: number)
				return p * 6102.4
			end,
			toFeetCubed = function(p: number)
				return p * 3.531447540346788
			end,
			toMeterCubed = function(p: number)
				return p * 0.1
			end,
			toCentimeterCubed = function(p: number)
				return p * 100000
			end,
			toImperialTeaspoon = function(p: number)
				return p * 16893.600000000002
			end,
			toImperialTablespoon = function(p: number)
				return p * 5631.2
			end,
			toImperialFluidOunce = function(p: number)
				return p * 3519.5099999999998
			end,
			toImperialCup = function(p: number)
				return p * 352
			end,
			toImperialPint = function(p: number)
				return p * 176
			end,
			toImperialQuart = function(p: number)
				return p * 88.02816901408451
			end,
			toImperialGallon = function(p: number)
				return p * 22.441651705565526
			end,
			toUsTeaspoon = function(p: number)
				return p * 20290
			end,
			toUsTablespoon = function(p: number)
				return p * 6762.8
			end,
			toUsFluidOunce = function(p: number)
				return p * 3381.4
			end,
			toUsLegalCup = function(p: number)
				return p * 416.667
			end,
			toUsLiquidPint = function(p: number)
				return p * 211.3
			end,
			toUsLiquidQuart = function(p: number)
				return p * 105.69999999999999
			end,
			toUsLiquidGallon = function(p: number)
				return p * 26.420079260237777
			end,
			toRoblox = function(p: number)
				return p * 4.55539358600583
			end,
			toLiter = function(p: number)
				return p * 100
			end,
			toMicroliter = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMilliliter = function(p: number)
				return p * 0.1
			end,
			toKiloliter = function(p: number)
				return p * 100000
			end,
			toMegaliter = function(p: number)
				return p * 100000000
			end
		},
		Kiloliter = {
			toInchesCubed = function(p: number)
				return p * 0.061024
			end,
			toFeetCubed = function(p: number)
				return p * 0.00003531447540346788
			end,
			toMeterCubed = function(p: number)
				return p * 1e-6
			end,
			toCentimeterCubed = function(p: number)
				return p * 1
			end,
			toImperialTeaspoon = function(p: number)
				return p * 0.168936
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.056312
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.0351951
			end,
			toImperialCup = function(p: number)
				return p * 0.00352
			end,
			toImperialPint = function(p: number)
				return p * 0.00176
			end,
			toImperialQuart = function(p: number)
				return p * 0.0008802816901408451
			end,
			toImperialGallon = function(p: number)
				return p * 0.00022441651705565528
			end,
			toUsTeaspoon = function(p: number)
				return p * 0.2029
			end,
			toUsTablespoon = function(p: number)
				return p * 0.06762800000000001
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.033814000000000004
			end,
			toUsLegalCup = function(p: number)
				return p * 0.00416667
			end,
			toUsLiquidPint = function(p: number)
				return p * 0.002113
			end,
			toUsLiquidQuart = function(p: number)
				return p * 0.001057
			end,
			toUsLiquidGallon = function(p: number)
				return p * 0.0002642007926023778
			end,
			toRoblox = function(p: number)
				return p * 0.0000455539358600583
			end,
			toLiter = function(p: number)
				return p * 0.001
			end,
			toMicroliter = function(p: number)
				return p * 1e-9
			end,
			toMilliliter = function(p: number)
				return p * 1e-6
			end,
			toCentiliter = function(p: number)
				return p * 0.00001
			end,
			toMegaliter = function(p: number)
				return p * 1000
			end
		},
		Megaliter = {
			toInchesCubed = function(p: number)
				return p * 0.000061024
			end,
			toFeetCubed = function(p: number)
				return p * 3.531447540346788e-8
			end,
			toMeterCubed = function(p: number)
				return p * 1e-9
			end,
			toCentimeterCubed = function(p: number)
				return p * 0.001
			end,
			toImperialTeaspoon = function(p: number)
				return p * 0.000168936
			end,
			toImperialTablespoon = function(p: number)
				return p * 0.00005631199999999999
			end,
			toImperialFluidOunce = function(p: number)
				return p * 0.0000351951
			end,
			toImperialCup = function(p: number)
				return p * 3.5199999999999998e-6
			end,
			toImperialPint = function(p: number)
				return p * 1.7599999999999999e-6
			end,
			toImperialQuart = function(p: number)
				return p * 8.802816901408451e-7
			end,
			toImperialGallon = function(p: number)
				return p * 2.2441651705565526e-7
			end,
			toUsTeaspoon = function(p: number)
				return p * 0.0002029
			end,
			toUsTablespoon = function(p: number)
				return p * 0.000067628
			end,
			toUsFluidOunce = function(p: number)
				return p * 0.000033814
			end,
			toUsLegalCup = function(p: number)
				return p * 4.16667e-6
			end,
			toUsLiquidPint = function(p: number)
				return p * 2.113e-6
			end,
			toUsLiquidQuart = function(p: number)
				return p * 1.0569999999999998e-6
			end,
			toUsLiquidGallon = function(p: number)
				return p * 2.6420079260237776e-7
			end,
			toRoblox = function(p: number)
				return p * 4.55539358600583e-8
			end,
			toLiter = function(p: number)
				return p * 1e-6
			end,
			toMicroliter = function(p: number)
				return p * 1e-12
			end,
			toMilliliter = function(p: number)
				return p * 1e-9
			end,
			toCentiliter = function(p: number)
				return p * 1e-8
			end,
			toKiloliter = function(p: number)
				return p * 0.001
			end
		}
	},
	Length = {
		Inch = {
			toFoot = function(p: number)
				return p * 0.00774153803230948
			end,
			toYard = function(p: number)
				return p * 0.023217537736752655
			end,
			toMile = function(p: number)
				return p * 0.00001578619408577216
			end,
			toNauticalMile = function(p: number)
				return p * 0.000013714895401731863
			end,
			toLightYear = function(p: number)
				return p * 2.6847041839136887e-18
			end,
			toAstronomicalUnit = function(p: number)
				return p * 1.69786004572242e-13
			end,
			toRoblox = function(p: number)
				return p * 0.09071423672859788
			end,
			toMeter = function(p: number)
				return p * 0.025399986284007407
			end,
			toMicrometer = function(p: number)
				return p * 2.5399986284007406e-8
			end,
			toMillimeter = function(p: number)
				return p * 0.00002539998628400741
			end,
			toCentimeter = function(p: number)
				return p * 0.00025399986284007405
			end,
			toKilometer = function(p: number)
				return p * 25.399986284007408
			end,
			toMegameter = function(p: number)
				return p * 25399.986284007406
			end
		},
		Foot = {
			toInch = function(p: number)
				return p * 129.17329810000004
			end,
			toYard = function(p: number)
				return p * 2.9990859232175504
			end,
			toMile = function(p: number)
				return p * 0.0020391547545059044
			end,
			toNauticalMile = function(p: number)
				return p * 0.0017715982721382294
			end,
			toLightYear = function(p: number)
				return p * 3.4679209385900014e-16
			end,
			toAstronomicalUnit = function(p: number)
				return p * 2.1931818181818184e-11
			end,
			toRoblox = function(p: number)
				return p * 11.717857142857143
			end,
			toMeter = function(p: number)
				return p * 3.2810000000000006
			end,
			toMicrometer = function(p: number)
				return p * 3.2810000000000004e-6
			end,
			toMillimeter = function(p: number)
				return p * 0.0032810000000000005
			end,
			toCentimeter = function(p: number)
				return p * 0.032810000000000006
			end,
			toKilometer = function(p: number)
				return p * 3281.0000000000005
			end,
			toMegameter = function(p: number)
				return p * 3281000.0000000005
			end
		},
		Yard = {
			toInch = function(p: number)
				return p * 43.070889400000006
			end,
			toFoot = function(p: number)
				return p * 0.33343492837549527
			end,
			toMile = function(p: number)
				return p * 0.0006799254195152269
			end,
			toNauticalMile = function(p: number)
				return p * 0.0005907127429805616
			end,
			toLightYear = function(p: number)
				return p * 1.1563259697706375e-16
			end,
			toAstronomicalUnit = function(p: number)
				return p * 7.312834224598931e-12
			end,
			toRoblox = function(p: number)
				return p * 3.907142857142857
			end,
			toMeter = function(p: number)
				return p * 1.094
			end,
			toMicrometer = function(p: number)
				return p * 1.094e-6
			end,
			toMillimeter = function(p: number)
				return p * 0.0010940000000000001
			end,
			toCentimeter = function(p: number)
				return p * 0.010940000000000002
			end,
			toKilometer = function(p: number)
				return p * 1094
			end,
			toMegameter = function(p: number)
				return p * 1094000
			end
		},
		Mile = {
			toInch = function(p: number)
				return p * 63346.490900000004
			end,
			toFoot = function(p: number)
				return p * 490.39926851569635
			end,
			toYard = function(p: number)
				return p * 1470.7495429616085
			end,
			toNauticalMile = function(p: number)
				return p * 0.8687904967602592
			end,
			toLightYear = function(p: number)
				return p * 1.700665891554804e-13
			end,
			toAstronomicalUnit = function(p: number)
				return p * 1.0755347593582888e-8
			end,
			toRoblox = function(p: number)
				return p * 5746.428571428571
			end,
			toMeter = function(p: number)
				return p * 1609
			end,
			toMicrometer = function(p: number)
				return p * 0.001609
			end,
			toMillimeter = function(p: number)
				return p * 1.609
			end,
			toCentimeter = function(p: number)
				return p * 16.09
			end,
			toKilometer = function(p: number)
				return p * 1609000
			end,
			toMegameter = function(p: number)
				return p * 1609000000
			end
		},
		NauticalMile = {
			toInch = function(p: number)
				return p * 72913.4252
			end,
			toFoot = function(p: number)
				return p * 564.4620542517524
			end,
			toYard = function(p: number)
				return p * 1692.870201096892
			end,
			toMile = function(p: number)
				return p * 1.1510254816656307
			end,
			toLightYear = function(p: number)
				return p * 1.9575097769791776e-13
			end,
			toAstronomicalUnit = function(p: number)
				return p * 1.2379679144385027e-8
			end,
			toRoblox = function(p: number)
				return p * 6614.285714285714
			end,
			toMeter = function(p: number)
				return p * 1852
			end,
			toMicrometer = function(p: number)
				return p * 0.001852
			end,
			toMillimeter = function(p: number)
				return p * 1.852
			end,
			toCentimeter = function(p: number)
				return p * 18.52
			end,
			toKilometer = function(p: number)
				return p * 1852000
			end,
			toMegameter = function(p: number)
				return p * 1852000000
			end
		},
		LightYear = {
			toInch = function(p: number)
				return p * 3.724805161e17
			end,
			toFoot = function(p: number)
				return p * 2883572081682413.5
			end,
			toYard = function(p: number)
				return p * 8648080438756855
			end,
			toMile = function(p: number)
				return p * 5880049720323.182
			end,
			toNauticalMile = function(p: number)
				return p * 5108531317494.601
			end,
			toAstronomicalUnit = function(p: number)
				return p * 63241.978609625665
			end,
			toRoblox = function(p: number)
				return p * 3.378928571428571e16
			end,
			toMeter = function(p: number)
				return p * 9461000000000000
			end,
			toMicrometer = function(p: number)
				return p * 9461000000
			end,
			toMillimeter = function(p: number)
				return p * 9461000000000
			end,
			toCentimeter = function(p: number)
				return p * 94610000000000
			end,
			toKilometer = function(p: number)
				return p * 9.461e18
			end,
			toMegameter = function(p: number)
				return p * 9.461e21
			end
		},
		AstronomicalUnit = {
			toInch = function(p: number)
				return p * 5889766960000
			end,
			toFoot = function(p: number)
				return p * 45595854922.279785
			end,
			toYard = function(p: number)
				return p * 136745886654.47896
			end,
			toMile = function(p: number)
				return p * 92977004.35052827
			end,
			toNauticalMile = function(p: number)
				return p * 80777537.79697625
			end,
			toLightYear = function(p: number)
				return p * 0.000015812281999788606
			end,
			toRoblox = function(p: number)
				return p * 534285714285.71423
			end,
			toMeter = function(p: number)
				return p * 149600000000
			end,
			toMicrometer = function(p: number)
				return p * 149600
			end,
			toMillimeter = function(p: number)
				return p * 149600000
			end,
			toCentimeter = function(p: number)
				return p * 1496000000
			end,
			toKilometer = function(p: number)
				return p * 149600000000000
			end,
			toMegameter = function(p: number)
				return p * 1.496e17
			end
		},
		Roblox = {
			toInch = function(p: number)
				return p * 11.023628
			end,
			toFoot = function(p: number)
				return p * 0.0853398354160317
			end,
			toYard = function(p: number)
				return p * 0.25594149908592323
			end,
			toMile = function(p: number)
				return p * 0.0001740211311373524
			end,
			toNauticalMile = function(p: number)
				return p * 0.00015118790496760262
			end,
			toLightYear = function(p: number)
				return p * 2.959518021350809e-17
			end,
			toAstronomicalUnit = function(p: number)
				return p * 1.871657754010695e-12
			end,
			toMeter = function(p: number)
				return p * 0.28
			end,
			toMicrometer = function(p: number)
				return p * 2.8e-7
			end,
			toMillimeter = function(p: number)
				return p * 0.00028000000000000003
			end,
			toCentimeter = function(p: number)
				return p * 0.0028000000000000004
			end,
			toKilometer = function(p: number)
				return p * 280
			end,
			toMegameter = function(p: number)
				return p * 280000
			end
		},
		Meter = {
			toInch = function(p: number)
				return p * 39.3701
			end,
			toFoot = function(p: number)
				return p * 0.30478512648582745
			end,
			toYard = function(p: number)
				return p * 0.9140767824497257
			end,
			toMile = function(p: number)
				return p * 0.0006215040397762585
			end,
			toNauticalMile = function(p: number)
				return p * 0.0005399568034557236
			end,
			toLightYear = function(p: number)
				return p * 1.056970721911003e-16
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.6844919786096254e-12
			end,
			toRoblox = function(p: number)
				return p * 3.571428571428571
			end,
			toMicrometer = function(p: number)
				return p * 1e-6
			end,
			toMillimeter = function(p: number)
				return p * 0.001
			end,
			toCentimeter = function(p: number)
				return p * 0.01
			end,
			toKilometer = function(p: number)
				return p * 1000
			end,
			toMegameter = function(p: number)
				return p * 1000000
			end
		},
		Micrometer = {
			toInch = function(p: number)
				return p * 39370100
			end,
			toFoot = function(p: number)
				return p * 304785.12648582744
			end,
			toYard = function(p: number)
				return p * 914076.7824497257
			end,
			toMile = function(p: number)
				return p * 621.5040397762585
			end,
			toNauticalMile = function(p: number)
				return p * 539.9568034557236
			end,
			toLightYear = function(p: number)
				return p * 1.056970721911003e-10
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.684491978609625e-6
			end,
			toRoblox = function(p: number)
				return p * 3571428.5714285714
			end,
			toMeter = function(p: number)
				return p * 1000000
			end,
			toMillimeter = function(p: number)
				return p * 1000
			end,
			toCentimeter = function(p: number)
				return p * 10000
			end,
			toKilometer = function(p: number)
				return p * 1000000000
			end,
			toMegameter = function(p: number)
				return p * 1000000000000
			end
		},
		Millimeter = {
			toInch = function(p: number)
				return p * 39370.1
			end,
			toFoot = function(p: number)
				return p * 304.78512648582745
			end,
			toYard = function(p: number)
				return p * 914.0767824497257
			end,
			toMile = function(p: number)
				return p * 0.6215040397762585
			end,
			toNauticalMile = function(p: number)
				return p * 0.5399568034557236
			end,
			toLightYear = function(p: number)
				return p * 1.0569707219110031e-13
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.684491978609626e-9
			end,
			toRoblox = function(p: number)
				return p * 3571.428571428571
			end,
			toMeter = function(p: number)
				return p * 1000
			end,
			toMicrometer = function(p: number)
				return p * 0.001
			end,
			toCentimeter = function(p: number)
				return p * 10
			end,
			toKilometer = function(p: number)
				return p * 1000000
			end,
			toMegameter = function(p: number)
				return p * 1000000000
			end
		},
		Centimeter = {
			toInch = function(p: number)
				return p * 3937.01
			end,
			toFoot = function(p: number)
				return p * 30.478512648582743
			end,
			toYard = function(p: number)
				return p * 91.40767824497257
			end,
			toMile = function(p: number)
				return p * 0.06215040397762585
			end,
			toNauticalMile = function(p: number)
				return p * 0.05399568034557236
			end,
			toLightYear = function(p: number)
				return p * 1.0569707219110031e-14
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.684491978609626e-10
			end,
			toRoblox = function(p: number)
				return p * 357.1428571428571
			end,
			toMeter = function(p: number)
				return p * 100
			end,
			toMicrometer = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillimeter = function(p: number)
				return p * 0.1
			end,
			toKilometer = function(p: number)
				return p * 100000
			end,
			toMegameter = function(p: number)
				return p * 100000000
			end
		},
		Kilometer = {
			toInch = function(p: number)
				return p * 0.0393701
			end,
			toFoot = function(p: number)
				return p * 0.00030478512648582747
			end,
			toYard = function(p: number)
				return p * 0.0009140767824497257
			end,
			toMile = function(p: number)
				return p * 6.215040397762585e-7
			end,
			toNauticalMile = function(p: number)
				return p * 5.399568034557235e-7
			end,
			toLightYear = function(p: number)
				return p * 1.056970721911003e-19
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.684491978609626e-15
			end,
			toRoblox = function(p: number)
				return p * 0.0035714285714285713
			end,
			toMeter = function(p: number)
				return p * 0.001
			end,
			toMicrometer = function(p: number)
				return p * 1e-9
			end,
			toMillimeter = function(p: number)
				return p * 1e-6
			end,
			toCentimeter = function(p: number)
				return p * 0.00001
			end,
			toMegameter = function(p: number)
				return p * 1000
			end
		},
		Megameter = {
			toInch = function(p: number)
				return p * 0.0000393701
			end,
			toFoot = function(p: number)
				return p * 3.047851264858274e-7
			end,
			toYard = function(p: number)
				return p * 9.140767824497256e-7
			end,
			toMile = function(p: number)
				return p * 6.215040397762585e-10
			end,
			toNauticalMile = function(p: number)
				return p * 5.399568034557236e-10
			end,
			toLightYear = function(p: number)
				return p * 1.056970721911003e-22
			end,
			toAstronomicalUnit = function(p: number)
				return p * 6.684491978609625e-18
			end,
			toRoblox = function(p: number)
				return p * 3.571428571428571e-6
			end,
			toMeter = function(p: number)
				return p * 1e-6
			end,
			toMicrometer = function(p: number)
				return p * 1e-12
			end,
			toMillimeter = function(p: number)
				return p * 1e-9
			end,
			toCentimeter = function(p: number)
				return p * 1e-8
			end,
			toKilometer = function(p: number)
				return p * 0.001
			end
		}
	},
	Time = {
		Minute = {
			toHour = function(p: number)
				return p * 0.016666666666666666
			end,
			toDay = function(p: number)
				return p * 0.0006944444444444444
			end,
			toWeek = function(p: number)
				return p * 0.0000992063492063492
			end,
			toYear = function(p: number)
				return p * 1.901285268841737e-6
			end,
			toDecade = function(p: number)
				return p * 1.901285268841737e-7
			end,
			toCentury = function(p: number)
				return p * 1.901285268841737e-8
			end,
			toRoblox = function(p: number)
				return p * 60
			end,
			toSecond = function(p: number)
				return p * 60
			end,
			toMicrosecond = function(p: number)
				return p * 0.000059999999999999995
			end,
			toMillisecond = function(p: number)
				return p * 0.06
			end,
			toCentisecond = function(p: number)
				return p * 0.6
			end,
			toKilosecond = function(p: number)
				return p * 60000
			end,
			toMegasecond = function(p: number)
				return p * 60000000
			end
		},
		Hour = {
			toMinute = function(p: number)
				return p * 60
			end,
			toDay = function(p: number)
				return p * 0.041666666666666664
			end,
			toWeek = function(p: number)
				return p * 0.005952380952380953
			end,
			toYear = function(p: number)
				return p * 0.0001140771161305042
			end,
			toDecade = function(p: number)
				return p * 0.000011407711613050422
			end,
			toCentury = function(p: number)
				return p * 1.1407711613050422e-6
			end,
			toRoblox = function(p: number)
				return p * 3600
			end,
			toSecond = function(p: number)
				return p * 3600
			end,
			toMicrosecond = function(p: number)
				return p * 0.0036
			end,
			toMillisecond = function(p: number)
				return p * 3.6
			end,
			toCentisecond = function(p: number)
				return p * 36
			end,
			toKilosecond = function(p: number)
				return p * 3600000
			end,
			toMegasecond = function(p: number)
				return p * 3600000000
			end
		},
		Day = {
			toMinute = function(p: number)
				return p * 1440
			end,
			toHour = function(p: number)
				return p * 24
			end,
			toWeek = function(p: number)
				return p * 0.14285714285714288
			end,
			toYear = function(p: number)
				return p * 0.0027378507871321013
			end,
			toDecade = function(p: number)
				return p * 0.0002737850787132101
			end,
			toCentury = function(p: number)
				return p * 0.000027378507871321015
			end,
			toRoblox = function(p: number)
				return p * 86400
			end,
			toSecond = function(p: number)
				return p * 86400
			end,
			toMicrosecond = function(p: number)
				return p * 0.08639999999999999
			end,
			toMillisecond = function(p: number)
				return p * 86.4
			end,
			toCentisecond = function(p: number)
				return p * 864
			end,
			toKilosecond = function(p: number)
				return p * 86400000
			end,
			toMegasecond = function(p: number)
				return p * 86400000000
			end
		},
		Week = {
			toMinute = function(p: number)
				return p * 10080
			end,
			toHour = function(p: number)
				return p * 168
			end,
			toDay = function(p: number)
				return p * 7
			end,
			toYear = function(p: number)
				return p * 0.019164955509924708
			end,
			toDecade = function(p: number)
				return p * 0.0019164955509924709
			end,
			toCentury = function(p: number)
				return p * 0.0001916495550992471
			end,
			toRoblox = function(p: number)
				return p * 604800
			end,
			toSecond = function(p: number)
				return p * 604800
			end,
			toMicrosecond = function(p: number)
				return p * 0.6048
			end,
			toMillisecond = function(p: number)
				return p * 604.8000000000001
			end,
			toCentisecond = function(p: number)
				return p * 6048
			end,
			toKilosecond = function(p: number)
				return p * 604800000
			end,
			toMegasecond = function(p: number)
				return p * 604800000000
			end
		},
		Year = {
			toMinute = function(p: number)
				return p * 525960
			end,
			toHour = function(p: number)
				return p * 8766.000000000002
			end,
			toDay = function(p: number)
				return p * 365.25
			end,
			toWeek = function(p: number)
				return p * 52.17857142857144
			end,
			toDecade = function(p: number)
				return p * 0.1
			end,
			toCentury = function(p: number)
				return p * 0.010000000000000002
			end,
			toRoblox = function(p: number)
				return p * 31557600.000000004
			end,
			toSecond = function(p: number)
				return p * 31557600.000000004
			end,
			toMicrosecond = function(p: number)
				return p * 31.5576
			end,
			toMillisecond = function(p: number)
				return p * 31557.600000000006
			end,
			toCentisecond = function(p: number)
				return p * 315576.00000000006
			end,
			toKilosecond = function(p: number)
				return p * 31557600000.000004
			end,
			toMegasecond = function(p: number)
				return p * 31557600000000.004
			end
		},
		Decade = {
			toMinute = function(p: number)
				return p * 5259600
			end,
			toHour = function(p: number)
				return p * 87660
			end,
			toDay = function(p: number)
				return p * 3652.5
			end,
			toWeek = function(p: number)
				return p * 521.7857142857143
			end,
			toYear = function(p: number)
				return p * 9.999999999999998
			end,
			toCentury = function(p: number)
				return p * 0.1
			end,
			toRoblox = function(p: number)
				return p * 315576000
			end,
			toSecond = function(p: number)
				return p * 315576000
			end,
			toMicrosecond = function(p: number)
				return p * 315.57599999999996
			end,
			toMillisecond = function(p: number)
				return p * 315576
			end,
			toCentisecond = function(p: number)
				return p * 3155760
			end,
			toKilosecond = function(p: number)
				return p * 315576000000
			end,
			toMegasecond = function(p: number)
				return p * 315576000000000
			end
		},
		Century = {
			toMinute = function(p: number)
				return p * 52596000
			end,
			toHour = function(p: number)
				return p * 876600
			end,
			toDay = function(p: number)
				return p * 36525
			end,
			toWeek = function(p: number)
				return p * 5217.857142857143
			end,
			toYear = function(p: number)
				return p * 99.99999999999999
			end,
			toDecade = function(p: number)
				return p * 10
			end,
			toRoblox = function(p: number)
				return p * 3155760000
			end,
			toSecond = function(p: number)
				return p * 3155760000
			end,
			toMicrosecond = function(p: number)
				return p * 3155.7599999999998
			end,
			toMillisecond = function(p: number)
				return p * 3155760
			end,
			toCentisecond = function(p: number)
				return p * 31557600
			end,
			toKilosecond = function(p: number)
				return p * 3155760000000
			end,
			toMegasecond = function(p: number)
				return p * 3155760000000000
			end
		},
		Roblox = {
			toMinute = function(p: number)
				return p * 0.016666666666666666
			end,
			toHour = function(p: number)
				return p * 0.0002777777777777778
			end,
			toDay = function(p: number)
				return p * 0.000011574074074074073
			end,
			toWeek = function(p: number)
				return p * 1.6534391534391535e-6
			end,
			toYear = function(p: number)
				return p * 3.168808781402895e-8
			end,
			toDecade = function(p: number)
				return p * 3.168808781402895e-9
			end,
			toCentury = function(p: number)
				return p * 3.168808781402895e-10
			end,
			toSecond = function(p: number)
				return p * 1
			end,
			toMicrosecond = function(p: number)
				return p * 1e-6
			end,
			toMillisecond = function(p: number)
				return p * 0.001
			end,
			toCentisecond = function(p: number)
				return p * 0.01
			end,
			toKilosecond = function(p: number)
				return p * 1000
			end,
			toMegasecond = function(p: number)
				return p * 1000000
			end
		},
		Second = {
			toMinute = function(p: number)
				return p * 0.016666666666666666
			end,
			toHour = function(p: number)
				return p * 0.0002777777777777778
			end,
			toDay = function(p: number)
				return p * 0.000011574074074074073
			end,
			toWeek = function(p: number)
				return p * 1.6534391534391535e-6
			end,
			toYear = function(p: number)
				return p * 3.168808781402895e-8
			end,
			toDecade = function(p: number)
				return p * 3.168808781402895e-9
			end,
			toCentury = function(p: number)
				return p * 3.168808781402895e-10
			end,
			toRoblox = function(p: number)
				return p * 1
			end,
			toMicrosecond = function(p: number)
				return p * 1e-6
			end,
			toMillisecond = function(p: number)
				return p * 0.001
			end,
			toCentisecond = function(p: number)
				return p * 0.01
			end,
			toKilosecond = function(p: number)
				return p * 1000
			end,
			toMegasecond = function(p: number)
				return p * 1000000
			end
		},
		Microsecond = {
			toMinute = function(p: number)
				return p * 16666.666666666668
			end,
			toHour = function(p: number)
				return p * 277.77777777777777
			end,
			toDay = function(p: number)
				return p * 11.574074074074073
			end,
			toWeek = function(p: number)
				return p * 1.6534391534391535
			end,
			toYear = function(p: number)
				return p * 0.031688087814028945
			end,
			toDecade = function(p: number)
				return p * 0.003168808781402895
			end,
			toCentury = function(p: number)
				return p * 0.0003168808781402895
			end,
			toRoblox = function(p: number)
				return p * 1000000
			end,
			toSecond = function(p: number)
				return p * 1000000
			end,
			toMillisecond = function(p: number)
				return p * 1000
			end,
			toCentisecond = function(p: number)
				return p * 10000
			end,
			toKilosecond = function(p: number)
				return p * 1000000000
			end,
			toMegasecond = function(p: number)
				return p * 1000000000000
			end
		},
		Millisecond = {
			toMinute = function(p: number)
				return p * 16.666666666666668
			end,
			toHour = function(p: number)
				return p * 0.2777777777777778
			end,
			toDay = function(p: number)
				return p * 0.011574074074074073
			end,
			toWeek = function(p: number)
				return p * 0.0016534391534391536
			end,
			toYear = function(p: number)
				return p * 0.00003168808781402895
			end,
			toDecade = function(p: number)
				return p * 3.168808781402895e-6
			end,
			toCentury = function(p: number)
				return p * 3.1688087814028954e-7
			end,
			toRoblox = function(p: number)
				return p * 1000
			end,
			toSecond = function(p: number)
				return p * 1000
			end,
			toMicrosecond = function(p: number)
				return p * 0.001
			end,
			toCentisecond = function(p: number)
				return p * 10
			end,
			toKilosecond = function(p: number)
				return p * 1000000
			end,
			toMegasecond = function(p: number)
				return p * 1000000000
			end
		},
		Centisecond = {
			toMinute = function(p: number)
				return p * 1.6666666666666667
			end,
			toHour = function(p: number)
				return p * 0.027777777777777776
			end,
			toDay = function(p: number)
				return p * 0.0011574074074074073
			end,
			toWeek = function(p: number)
				return p * 0.00016534391534391536
			end,
			toYear = function(p: number)
				return p * 3.1688087814028946e-6
			end,
			toDecade = function(p: number)
				return p * 3.168808781402895e-7
			end,
			toCentury = function(p: number)
				return p * 3.1688087814028954e-8
			end,
			toRoblox = function(p: number)
				return p * 100
			end,
			toSecond = function(p: number)
				return p * 100
			end,
			toMicrosecond = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillisecond = function(p: number)
				return p * 0.1
			end,
			toKilosecond = function(p: number)
				return p * 100000
			end,
			toMegasecond = function(p: number)
				return p * 100000000
			end
		},
		Kilosecond = {
			toMinute = function(p: number)
				return p * 0.000016666666666666667
			end,
			toHour = function(p: number)
				return p * 2.7777777777777776e-7
			end,
			toDay = function(p: number)
				return p * 1.1574074074074074e-8
			end,
			toWeek = function(p: number)
				return p * 1.6534391534391535e-9
			end,
			toYear = function(p: number)
				return p * 3.168808781402895e-11
			end,
			toDecade = function(p: number)
				return p * 3.168808781402895e-12
			end,
			toCentury = function(p: number)
				return p * 3.168808781402895e-13
			end,
			toRoblox = function(p: number)
				return p * 0.001
			end,
			toSecond = function(p: number)
				return p * 0.001
			end,
			toMicrosecond = function(p: number)
				return p * 1e-9
			end,
			toMillisecond = function(p: number)
				return p * 1e-6
			end,
			toCentisecond = function(p: number)
				return p * 0.00001
			end,
			toMegasecond = function(p: number)
				return p * 1000
			end
		},
		Megasecond = {
			toMinute = function(p: number)
				return p * 1.6666666666666667e-8
			end,
			toHour = function(p: number)
				return p * 2.7777777777777777e-10
			end,
			toDay = function(p: number)
				return p * 1.1574074074074074e-11
			end,
			toWeek = function(p: number)
				return p * 1.6534391534391534e-12
			end,
			toYear = function(p: number)
				return p * 3.1688087814028944e-14
			end,
			toDecade = function(p: number)
				return p * 3.1688087814028946e-15
			end,
			toCentury = function(p: number)
				return p * 3.1688087814028953e-16
			end,
			toRoblox = function(p: number)
				return p * 1e-6
			end,
			toSecond = function(p: number)
				return p * 1e-6
			end,
			toMicrosecond = function(p: number)
				return p * 1e-12
			end,
			toMillisecond = function(p: number)
				return p * 1e-9
			end,
			toCentisecond = function(p: number)
				return p * 1e-8
			end,
			toKilosecond = function(p: number)
				return p * 0.001
			end
		}
	},
	Energy = {
		BritishThermalUnit = {
			toCalorie = function(p: number)
				return p * 252.15105162523898
			end,
			toWattHour = function(p: number)
				return p * 0.29305555555555557
			end,
			toFootPound = function(p: number)
				return p * 778.023598820059
			end,
			toJoule = function(p: number)
				return p * 1055
			end,
			toMicrojoule = function(p: number)
				return p * 0.001055
			end,
			toMillijoule = function(p: number)
				return p * 1.055
			end,
			toCentijoule = function(p: number)
				return p * 10.55
			end,
			toKilojoule = function(p: number)
				return p * 1055000
			end,
			toMegajoule = function(p: number)
				return p * 1055000000
			end
		},
		Calorie = {
			toBritishThermalUnit = function(p: number)
				return p * 0.003965876777251185
			end,
			toWattHour = function(p: number)
				return p * 0.0011622222222222223
			end,
			toFootPound = function(p: number)
				return p * 3.085545722713864
			end,
			toJoule = function(p: number)
				return p * 4.184
			end,
			toMicrojoule = function(p: number)
				return p * 4.184e-6
			end,
			toMillijoule = function(p: number)
				return p * 0.004184
			end,
			toCentijoule = function(p: number)
				return p * 0.04184
			end,
			toKilojoule = function(p: number)
				return p * 4184
			end,
			toMegajoule = function(p: number)
				return p * 4184000
			end
		},
		WattHour = {
			toBritishThermalUnit = function(p: number)
				return p * 3.4123222748815167
			end,
			toCalorie = function(p: number)
				return p * 860.4206500956022
			end,
			toFootPound = function(p: number)
				return p * 2654.867256637168
			end,
			toJoule = function(p: number)
				return p * 3600
			end,
			toMicrojoule = function(p: number)
				return p * 0.0036
			end,
			toMillijoule = function(p: number)
				return p * 3.6
			end,
			toCentijoule = function(p: number)
				return p * 36
			end,
			toKilojoule = function(p: number)
				return p * 3600000
			end,
			toMegajoule = function(p: number)
				return p * 3600000000
			end
		},
		FootPound = {
			toBritishThermalUnit = function(p: number)
				return p * 0.001285308056872038
			end,
			toCalorie = function(p: number)
				return p * 0.3240917782026769
			end,
			toWattHour = function(p: number)
				return p * 0.0003766666666666667
			end,
			toJoule = function(p: number)
				return p * 1.356
			end,
			toMicrojoule = function(p: number)
				return p * 1.356e-6
			end,
			toMillijoule = function(p: number)
				return p * 0.0013560000000000002
			end,
			toCentijoule = function(p: number)
				return p * 0.013560000000000001
			end,
			toKilojoule = function(p: number)
				return p * 1356
			end,
			toMegajoule = function(p: number)
				return p * 1356000
			end
		},
		Joule = {
			toBritishThermalUnit = function(p: number)
				return p * 0.0009478672985781991
			end,
			toCalorie = function(p: number)
				return p * 0.2390057361376673
			end,
			toWattHour = function(p: number)
				return p * 0.0002777777777777778
			end,
			toFootPound = function(p: number)
				return p * 0.7374631268436578
			end,
			toMicrojoule = function(p: number)
				return p * 1e-6
			end,
			toMillijoule = function(p: number)
				return p * 0.001
			end,
			toCentijoule = function(p: number)
				return p * 0.01
			end,
			toKilojoule = function(p: number)
				return p * 1000
			end,
			toMegajoule = function(p: number)
				return p * 1000000
			end
		},
		Microjoule = {
			toBritishThermalUnit = function(p: number)
				return p * 947.8672985781991
			end,
			toCalorie = function(p: number)
				return p * 239005.7361376673
			end,
			toWattHour = function(p: number)
				return p * 277.77777777777777
			end,
			toFootPound = function(p: number)
				return p * 737463.1268436578
			end,
			toJoule = function(p: number)
				return p * 1000000
			end,
			toMillijoule = function(p: number)
				return p * 1000
			end,
			toCentijoule = function(p: number)
				return p * 10000
			end,
			toKilojoule = function(p: number)
				return p * 1000000000
			end,
			toMegajoule = function(p: number)
				return p * 1000000000000
			end
		},
		Millijoule = {
			toBritishThermalUnit = function(p: number)
				return p * 0.9478672985781991
			end,
			toCalorie = function(p: number)
				return p * 239.0057361376673
			end,
			toWattHour = function(p: number)
				return p * 0.2777777777777778
			end,
			toFootPound = function(p: number)
				return p * 737.4631268436577
			end,
			toJoule = function(p: number)
				return p * 1000
			end,
			toMicrojoule = function(p: number)
				return p * 0.001
			end,
			toCentijoule = function(p: number)
				return p * 10
			end,
			toKilojoule = function(p: number)
				return p * 1000000
			end,
			toMegajoule = function(p: number)
				return p * 1000000000
			end
		},
		Centijoule = {
			toBritishThermalUnit = function(p: number)
				return p * 0.09478672985781991
			end,
			toCalorie = function(p: number)
				return p * 23.900573613766728
			end,
			toWattHour = function(p: number)
				return p * 0.027777777777777776
			end,
			toFootPound = function(p: number)
				return p * 73.74631268436578
			end,
			toJoule = function(p: number)
				return p * 100
			end,
			toMicrojoule = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillijoule = function(p: number)
				return p * 0.1
			end,
			toKilojoule = function(p: number)
				return p * 100000
			end,
			toMegajoule = function(p: number)
				return p * 100000000
			end
		},
		Kilojoule = {
			toBritishThermalUnit = function(p: number)
				return p * 9.478672985781991e-7
			end,
			toCalorie = function(p: number)
				return p * 0.0002390057361376673
			end,
			toWattHour = function(p: number)
				return p * 2.7777777777777776e-7
			end,
			toFootPound = function(p: number)
				return p * 0.0007374631268436578
			end,
			toJoule = function(p: number)
				return p * 0.001
			end,
			toMicrojoule = function(p: number)
				return p * 1e-9
			end,
			toMillijoule = function(p: number)
				return p * 1e-6
			end,
			toCentijoule = function(p: number)
				return p * 0.00001
			end,
			toMegajoule = function(p: number)
				return p * 1000
			end
		},
		Megajoule = {
			toBritishThermalUnit = function(p: number)
				return p * 9.47867298578199e-10
			end,
			toCalorie = function(p: number)
				return p * 2.3900573613766727e-7
			end,
			toWattHour = function(p: number)
				return p * 2.7777777777777777e-10
			end,
			toFootPound = function(p: number)
				return p * 7.374631268436577e-7
			end,
			toJoule = function(p: number)
				return p * 1e-6
			end,
			toMicrojoule = function(p: number)
				return p * 1e-12
			end,
			toMillijoule = function(p: number)
				return p * 1e-9
			end,
			toCentijoule = function(p: number)
				return p * 1e-8
			end,
			toKilojoule = function(p: number)
				return p * 0.001
			end
		}
	},
	Force = {
		Roblox = {
			toPoundForce = function(p: number)
				return p * 1.3792646864103808
			end,
			toNewton = function(p: number)
				return p * 6.134969325153374
			end,
			toMicronewton = function(p: number)
				return p * 6.134969325153374e-6
			end,
			toMillinewton = function(p: number)
				return p * 0.006134969325153374
			end,
			toCentinewton = function(p: number)
				return p * 0.06134969325153374
			end,
			toKilonewton = function(p: number)
				return p * 6134.9693251533745
			end,
			toMeganewton = function(p: number)
				return p * 6134969.325153374
			end
		},
		PoundForce = {
			toRoblox = function(p: number)
				return p * 0.7250240000000001
			end,
			toNewton = function(p: number)
				return p * 4.448
			end,
			toMicronewton = function(p: number)
				return p * 4.4480000000000004e-6
			end,
			toMillinewton = function(p: number)
				return p * 0.0044480000000000006
			end,
			toCentinewton = function(p: number)
				return p * 0.044480000000000006
			end,
			toKilonewton = function(p: number)
				return p * 4448
			end,
			toMeganewton = function(p: number)
				return p * 4448000
			end
		},
		Newton = {
			toRoblox = function(p: number)
				return p * 0.163
			end,
			toPoundForce = function(p: number)
				return p * 0.22482014388489208
			end,
			toMicronewton = function(p: number)
				return p * 1e-6
			end,
			toMillinewton = function(p: number)
				return p * 0.001
			end,
			toCentinewton = function(p: number)
				return p * 0.01
			end,
			toKilonewton = function(p: number)
				return p * 1000
			end,
			toMeganewton = function(p: number)
				return p * 1000000
			end
		},
		Micronewton = {
			toRoblox = function(p: number)
				return p * 163000
			end,
			toPoundForce = function(p: number)
				return p * 224820.14388489208
			end,
			toNewton = function(p: number)
				return p * 1000000
			end,
			toMillinewton = function(p: number)
				return p * 1000
			end,
			toCentinewton = function(p: number)
				return p * 10000
			end,
			toKilonewton = function(p: number)
				return p * 1000000000
			end,
			toMeganewton = function(p: number)
				return p * 1000000000000
			end
		},
		Millinewton = {
			toRoblox = function(p: number)
				return p * 163
			end,
			toPoundForce = function(p: number)
				return p * 224.82014388489208
			end,
			toNewton = function(p: number)
				return p * 1000
			end,
			toMicronewton = function(p: number)
				return p * 0.001
			end,
			toCentinewton = function(p: number)
				return p * 10
			end,
			toKilonewton = function(p: number)
				return p * 1000000
			end,
			toMeganewton = function(p: number)
				return p * 1000000000
			end
		},
		Centinewton = {
			toRoblox = function(p: number)
				return p * 16.3
			end,
			toPoundForce = function(p: number)
				return p * 22.48201438848921
			end,
			toNewton = function(p: number)
				return p * 100
			end,
			toMicronewton = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillinewton = function(p: number)
				return p * 0.1
			end,
			toKilonewton = function(p: number)
				return p * 100000
			end,
			toMeganewton = function(p: number)
				return p * 100000000
			end
		},
		Kilonewton = {
			toRoblox = function(p: number)
				return p * 0.000163
			end,
			toPoundForce = function(p: number)
				return p * 0.00022482014388489207
			end,
			toNewton = function(p: number)
				return p * 0.001
			end,
			toMicronewton = function(p: number)
				return p * 1e-9
			end,
			toMillinewton = function(p: number)
				return p * 1e-6
			end,
			toCentinewton = function(p: number)
				return p * 0.00001
			end,
			toMeganewton = function(p: number)
				return p * 1000
			end
		},
		Meganewton = {
			toRoblox = function(p: number)
				return p * 1.63e-7
			end,
			toPoundForce = function(p: number)
				return p * 2.2482014388489208e-7
			end,
			toNewton = function(p: number)
				return p * 1e-6
			end,
			toMicronewton = function(p: number)
				return p * 1e-12
			end,
			toMillinewton = function(p: number)
				return p * 1e-9
			end,
			toCentinewton = function(p: number)
				return p * 1e-8
			end,
			toKilonewton = function(p: number)
				return p * 0.001
			end
		}
	},
	Pressure = {
		Roblox = {
			toAtmosphere = function(p: number)
				return p * 0.0007751937984496125
			end,
			toBar = function(p: number)
				return p * 0.0007854651162790699
			end,
			toTorr = function(p: number)
				return p * 0.5891489148670661
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 0.011391807342698618
			end,
			toPascal = function(p: number)
				return p * 78.54651162790698
			end,
			toMicropascal = function(p: number)
				return p * 0.00007854651162790698
			end,
			toMillipascal = function(p: number)
				return p * 0.07854651162790698
			end,
			toCentipascal = function(p: number)
				return p * 0.7854651162790698
			end,
			toKilopascal = function(p: number)
				return p * 78546.51162790698
			end,
			toMegapascal = function(p: number)
				return p * 78546511.62790698
			end
		},
		Atmosphere = {
			toRoblox = function(p: number)
				return p * 1290
			end,
			toBar = function(p: number)
				return p * 1.01325
			end,
			toTorr = function(p: number)
				return p * 760.0021001785152
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 14.695431472081218
			end,
			toPascal = function(p: number)
				return p * 101325
			end,
			toMicropascal = function(p: number)
				return p * 0.101325
			end,
			toMillipascal = function(p: number)
				return p * 101.325
			end,
			toCentipascal = function(p: number)
				return p * 1013.25
			end,
			toKilopascal = function(p: number)
				return p * 101325000
			end,
			toMegapascal = function(p: number)
				return p * 101325000000
			end
		},
		Bar = {
			toRoblox = function(p: number)
				return p * 1273.1310140636565
			end,
			toAtmosphere = function(p: number)
				return p * 0.9869232667160127
			end,
			toTorr = function(p: number)
				return p * 750.0637554192106
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 14.503263234227697
			end,
			toPascal = function(p: number)
				return p * 99999.99999999999
			end,
			toMicropascal = function(p: number)
				return p * 0.09999999999999998
			end,
			toMillipascal = function(p: number)
				return p * 99.99999999999999
			end,
			toCentipascal = function(p: number)
				return p * 999.9999999999999
			end,
			toKilopascal = function(p: number)
				return p * 99999999.99999999
			end,
			toMegapascal = function(p: number)
				return p * 99999999999.99998
			end
		},
		Torr = {
			toRoblox = function(p: number)
				return p * 1.6973637305699483
			end,
			toAtmosphere = function(p: number)
				return p * 0.0013157858376511226
			end,
			toBar = function(p: number)
				return p * 0.0013332200000000002
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 0.019336040609137056
			end,
			toPascal = function(p: number)
				return p * 133.322
			end,
			toMicropascal = function(p: number)
				return p * 0.000133322
			end,
			toMillipascal = function(p: number)
				return p * 0.133322
			end,
			toCentipascal = function(p: number)
				return p * 1.33322
			end,
			toKilopascal = function(p: number)
				return p * 133322
			end,
			toMegapascal = function(p: number)
				return p * 133322000
			end
		},
		PoundPerSquareInch = {
			toRoblox = function(p: number)
				return p * 87.78238341968914
			end,
			toAtmosphere = function(p: number)
				return p * 0.06804835924006909
			end,
			toBar = function(p: number)
				return p * 0.06895000000000001
			end,
			toTorr = function(p: number)
				return p * 51.71689593615458
			end,
			toPascal = function(p: number)
				return p * 6895.000000000001
			end,
			toMicropascal = function(p: number)
				return p * 0.006895000000000001
			end,
			toMillipascal = function(p: number)
				return p * 6.895000000000001
			end,
			toCentipascal = function(p: number)
				return p * 68.95000000000002
			end,
			toKilopascal = function(p: number)
				return p * 6895000.000000001
			end,
			toMegapascal = function(p: number)
				return p * 6895000000.000001
			end
		},
		Pascal = {
			toRoblox = function(p: number)
				return p * 0.012731310140636566
			end,
			toAtmosphere = function(p: number)
				return p * 9.869232667160129e-6
			end,
			toBar = function(p: number)
				return p * 0.00001
			end,
			toTorr = function(p: number)
				return p * 0.007500637554192106
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 0.000145032632342277
			end,
			toMicropascal = function(p: number)
				return p * 1e-6
			end,
			toMillipascal = function(p: number)
				return p * 0.001
			end,
			toCentipascal = function(p: number)
				return p * 0.01
			end,
			toKilopascal = function(p: number)
				return p * 1000
			end,
			toMegapascal = function(p: number)
				return p * 1000000
			end
		},
		Micropascal = {
			toRoblox = function(p: number)
				return p * 12731.310140636566
			end,
			toAtmosphere = function(p: number)
				return p * 9.869232667160128
			end,
			toBar = function(p: number)
				return p * 10
			end,
			toTorr = function(p: number)
				return p * 7500.637554192106
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 145.032632342277
			end,
			toPascal = function(p: number)
				return p * 1000000
			end,
			toMillipascal = function(p: number)
				return p * 1000
			end,
			toCentipascal = function(p: number)
				return p * 10000
			end,
			toKilopascal = function(p: number)
				return p * 1000000000
			end,
			toMegapascal = function(p: number)
				return p * 1000000000000
			end
		},
		Millipascal = {
			toRoblox = function(p: number)
				return p * 12.731310140636566
			end,
			toAtmosphere = function(p: number)
				return p * 0.009869232667160128
			end,
			toBar = function(p: number)
				return p * 0.01
			end,
			toTorr = function(p: number)
				return p * 7.500637554192107
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 0.145032632342277
			end,
			toPascal = function(p: number)
				return p * 1000
			end,
			toMicropascal = function(p: number)
				return p * 0.001
			end,
			toCentipascal = function(p: number)
				return p * 10
			end,
			toKilopascal = function(p: number)
				return p * 1000000
			end,
			toMegapascal = function(p: number)
				return p * 1000000000
			end
		},
		Centipascal = {
			toRoblox = function(p: number)
				return p * 1.2731310140636565
			end,
			toAtmosphere = function(p: number)
				return p * 0.0009869232667160128
			end,
			toBar = function(p: number)
				return p * 0.001
			end,
			toTorr = function(p: number)
				return p * 0.7500637554192107
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 0.0145032632342277
			end,
			toPascal = function(p: number)
				return p * 100
			end,
			toMicropascal = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillipascal = function(p: number)
				return p * 0.1
			end,
			toKilopascal = function(p: number)
				return p * 100000
			end,
			toMegapascal = function(p: number)
				return p * 100000000
			end
		},
		Kilopascal = {
			toRoblox = function(p: number)
				return p * 0.000012731310140636567
			end,
			toAtmosphere = function(p: number)
				return p * 9.86923266716013e-9
			end,
			toBar = function(p: number)
				return p * 1e-8
			end,
			toTorr = function(p: number)
				return p * 7.5006375541921065e-6
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 1.45032632342277e-7
			end,
			toPascal = function(p: number)
				return p * 0.001
			end,
			toMicropascal = function(p: number)
				return p * 1e-9
			end,
			toMillipascal = function(p: number)
				return p * 1e-6
			end,
			toCentipascal = function(p: number)
				return p * 0.00001
			end,
			toMegapascal = function(p: number)
				return p * 1000
			end
		},
		Megapascal = {
			toRoblox = function(p: number)
				return p * 1.2731310140636566e-8
			end,
			toAtmosphere = function(p: number)
				return p * 9.869232667160129e-12
			end,
			toBar = function(p: number)
				return p * 1.0000000000000001e-11
			end,
			toTorr = function(p: number)
				return p * 7.500637554192107e-9
			end,
			toPoundPerSquareInch = function(p: number)
				return p * 1.4503263234227698e-10
			end,
			toPascal = function(p: number)
				return p * 1e-6
			end,
			toMicropascal = function(p: number)
				return p * 1e-12
			end,
			toMillipascal = function(p: number)
				return p * 1e-9
			end,
			toCentipascal = function(p: number)
				return p * 1e-8
			end,
			toKilopascal = function(p: number)
				return p * 0.001
			end
		}
	},
	Power = {
		Roblox = {
			toNewtonMeter = function(p: number)
				return p * 1.721170395869191
			end,
			toWatt = function(p: number)
				return p * 1.721170395869191
			end,
			toMicrowatt = function(p: number)
				return p * 1.721170395869191e-6
			end,
			toMilliwatt = function(p: number)
				return p * 0.0017211703958691911
			end,
			toCentiwatt = function(p: number)
				return p * 0.017211703958691912
			end,
			toKilowatt = function(p: number)
				return p * 1721.170395869191
			end,
			toMegawatt = function(p: number)
				return p * 1721170.395869191
			end
		},
		NewtonMeter = {
			toRoblox = function(p: number)
				return p * 0.581
			end,
			toWatt = function(p: number)
				return p * 1
			end,
			toMicrowatt = function(p: number)
				return p * 1e-6
			end,
			toMilliwatt = function(p: number)
				return p * 0.001
			end,
			toCentiwatt = function(p: number)
				return p * 0.01
			end,
			toKilowatt = function(p: number)
				return p * 1000
			end,
			toMegawatt = function(p: number)
				return p * 1000000
			end
		},
		Watt = {
			toRoblox = function(p: number)
				return p * 0.581
			end,
			toNewtonMeter = function(p: number)
				return p * 1
			end,
			toMicrowatt = function(p: number)
				return p * 1e-6
			end,
			toMilliwatt = function(p: number)
				return p * 0.001
			end,
			toCentiwatt = function(p: number)
				return p * 0.01
			end,
			toKilowatt = function(p: number)
				return p * 1000
			end,
			toMegawatt = function(p: number)
				return p * 1000000
			end
		},
		Microwatt = {
			toRoblox = function(p: number)
				return p * 581000
			end,
			toNewtonMeter = function(p: number)
				return p * 1000000
			end,
			toWatt = function(p: number)
				return p * 1000000
			end,
			toMilliwatt = function(p: number)
				return p * 1000
			end,
			toCentiwatt = function(p: number)
				return p * 10000
			end,
			toKilowatt = function(p: number)
				return p * 1000000000
			end,
			toMegawatt = function(p: number)
				return p * 1000000000000
			end
		},
		Milliwatt = {
			toRoblox = function(p: number)
				return p * 581
			end,
			toNewtonMeter = function(p: number)
				return p * 1000
			end,
			toWatt = function(p: number)
				return p * 1000
			end,
			toMicrowatt = function(p: number)
				return p * 0.001
			end,
			toCentiwatt = function(p: number)
				return p * 10
			end,
			toKilowatt = function(p: number)
				return p * 1000000
			end,
			toMegawatt = function(p: number)
				return p * 1000000000
			end
		},
		Centiwatt = {
			toRoblox = function(p: number)
				return p * 58.099999999999994
			end,
			toNewtonMeter = function(p: number)
				return p * 100
			end,
			toWatt = function(p: number)
				return p * 100
			end,
			toMicrowatt = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMilliwatt = function(p: number)
				return p * 0.1
			end,
			toKilowatt = function(p: number)
				return p * 100000
			end,
			toMegawatt = function(p: number)
				return p * 100000000
			end
		},
		Kilowatt = {
			toRoblox = function(p: number)
				return p * 0.0005809999999999999
			end,
			toNewtonMeter = function(p: number)
				return p * 0.001
			end,
			toWatt = function(p: number)
				return p * 0.001
			end,
			toMicrowatt = function(p: number)
				return p * 1e-9
			end,
			toMilliwatt = function(p: number)
				return p * 1e-6
			end,
			toCentiwatt = function(p: number)
				return p * 0.00001
			end,
			toMegawatt = function(p: number)
				return p * 1000
			end
		},
		Megawatt = {
			toRoblox = function(p: number)
				return p * 5.809999999999999e-7
			end,
			toNewtonMeter = function(p: number)
				return p * 1e-6
			end,
			toWatt = function(p: number)
				return p * 1e-6
			end,
			toMicrowatt = function(p: number)
				return p * 1e-12
			end,
			toMilliwatt = function(p: number)
				return p * 1e-9
			end,
			toCentiwatt = function(p: number)
				return p * 1e-8
			end,
			toKilowatt = function(p: number)
				return p * 0.001
			end
		}
	},
	Acceleration = {
		Roblox = {
			toMetersPerSecondSquared = function(p: number)
				return p * 0.28
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 2.8e-7
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 0.00028000000000000003
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 0.0028000000000000004
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 280
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 280000
			end
		},
		MetersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 3.571428571428571
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 1e-6
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 0.001
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 0.01
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 1000
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 1000000
			end
		},
		MicrometersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 3571428.5714285714
			end,
			toMetersPerSecondSquared = function(p: number)
				return p * 1000000
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 1000
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 10000
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 1000000000
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 1000000000000
			end
		},
		MillimetersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 3571.428571428571
			end,
			toMetersPerSecondSquared = function(p: number)
				return p * 1000
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 0.001
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 10
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 1000000
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 1000000000
			end
		},
		CentimetersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 357.1428571428571
			end,
			toMetersPerSecondSquared = function(p: number)
				return p * 100
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 0.1
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 100000
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 100000000
			end
		},
		KilometersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 0.0035714285714285713
			end,
			toMetersPerSecondSquared = function(p: number)
				return p * 0.001
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 1e-9
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 1e-6
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 0.00001
			end,
			toMegametersPerSecondSquared = function(p: number)
				return p * 1000
			end
		},
		MegametersPerSecondSquared = {
			toRoblox = function(p: number)
				return p * 3.571428571428571e-6
			end,
			toMetersPerSecondSquared = function(p: number)
				return p * 1e-6
			end,
			toMicrometersPerSecondSquared = function(p: number)
				return p * 1e-12
			end,
			toMillimetersPerSecondSquared = function(p: number)
				return p * 1e-9
			end,
			toCentimetersPerSecondSquared = function(p: number)
				return p * 1e-8
			end,
			toKilometersPerSecondSquared = function(p: number)
				return p * 0.001
			end
		}
	},
	Velocity = {
		Roblox = {
			toMilesPerHour = function(p: number)
				return p * 0.12521772231467462
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.07780890133831311
			end,
			toKnot = function(p: number)
				return p * 0.14409055803391316
			end,
			toFeetPerSecond = function(p: number)
				return p * 0.08537398501003571
			end,
			toMetersPerSecond = function(p: number)
				return p * 0.2801120448179272
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 2.8011204481792714e-7
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.0002801120448179272
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.0028011204481792717
			end,
			toKilometersPerSecond = function(p: number)
				return p * 280.1120448179272
			end,
			toMegametersPerSecond = function(p: number)
				return p * 280112.0448179272
			end
		},
		MilesPerHour = {
			toRoblox = function(p: number)
				return p * 7.98609
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.621388888888889
			end,
			toKnot = function(p: number)
				return p * 1.1507201646090535
			end,
			toFeetPerSecond = function(p: number)
				return p * 0.6818043279487961
			end,
			toMetersPerSecond = function(p: number)
				return p * 2.237
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 2.237e-6
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.0022370000000000003
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.02237
			end,
			toKilometersPerSecond = function(p: number)
				return p * 2237
			end,
			toMegametersPerSecond = function(p: number)
				return p * 2237000
			end
		},
		KilometersPerHour = {
			toRoblox = function(p: number)
				return p * 12.851999999999999
			end,
			toMilesPerHour = function(p: number)
				return p * 1.6092981671881983
			end,
			toKnot = function(p: number)
				return p * 1.8518518518518516
			end,
			toFeetPerSecond = function(p: number)
				return p * 1.0972264553489788
			end,
			toMetersPerSecond = function(p: number)
				return p * 3.5999999999999996
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 3.5999999999999994e-6
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.0036
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.036
			end,
			toKilometersPerSecond = function(p: number)
				return p * 3599.9999999999995
			end,
			toMegametersPerSecond = function(p: number)
				return p * 3599999.9999999995
			end
		},
		Knot = {
			toRoblox = function(p: number)
				return p * 6.940079999999999
			end,
			toMilesPerHour = function(p: number)
				return p * 0.869021010281627
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.54
			end,
			toFeetPerSecond = function(p: number)
				return p * 0.5925022858884486
			end,
			toMetersPerSecond = function(p: number)
				return p * 1.944
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 1.944e-6
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.001944
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.01944
			end,
			toKilometersPerSecond = function(p: number)
				return p * 1944
			end,
			toMegametersPerSecond = function(p: number)
				return p * 1944000
			end
		},
		FeetPerSecond = {
			toRoblox = function(p: number)
				return p * 11.713170000000002
			end,
			toMilesPerHour = function(p: number)
				return p * 1.4666964684845778
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.9113888888888891
			end,
			toKnot = function(p: number)
				return p * 1.6877572016460909
			end,
			toMetersPerSecond = function(p: number)
				return p * 3.2810000000000006
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 3.2810000000000004e-6
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.0032810000000000005
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.032810000000000006
			end,
			toKilometersPerSecond = function(p: number)
				return p * 3281.0000000000005
			end,
			toMegametersPerSecond = function(p: number)
				return p * 3281000.0000000005
			end
		},
		MetersPerSecond = {
			toRoblox = function(p: number)
				return p * 3.57
			end,
			toMilesPerHour = function(p: number)
				return p * 0.44702726866338843
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.2777777777777778
			end,
			toKnot = function(p: number)
				return p * 0.51440329218107
			end,
			toFeetPerSecond = function(p: number)
				return p * 0.30478512648582745
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 1e-6
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.001
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.01
			end,
			toKilometersPerSecond = function(p: number)
				return p * 1000
			end,
			toMegametersPerSecond = function(p: number)
				return p * 1000000
			end
		},
		MicrometersPerSecond = {
			toRoblox = function(p: number)
				return p * 3570000
			end,
			toMilesPerHour = function(p: number)
				return p * 447027.26866338844
			end,
			toKilometersPerHour = function(p: number)
				return p * 277777.7777777778
			end,
			toKnot = function(p: number)
				return p * 514403.29218106996
			end,
			toFeetPerSecond = function(p: number)
				return p * 304785.12648582744
			end,
			toMetersPerSecond = function(p: number)
				return p * 1000000
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 1000
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 10000
			end,
			toKilometersPerSecond = function(p: number)
				return p * 1000000000
			end,
			toMegametersPerSecond = function(p: number)
				return p * 1000000000000
			end
		},
		MillimetersPerSecond = {
			toRoblox = function(p: number)
				return p * 3570
			end,
			toMilesPerHour = function(p: number)
				return p * 447.02726866338844
			end,
			toKilometersPerHour = function(p: number)
				return p * 277.77777777777777
			end,
			toKnot = function(p: number)
				return p * 514.4032921810699
			end,
			toFeetPerSecond = function(p: number)
				return p * 304.78512648582745
			end,
			toMetersPerSecond = function(p: number)
				return p * 1000
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 0.001
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 10
			end,
			toKilometersPerSecond = function(p: number)
				return p * 1000000
			end,
			toMegametersPerSecond = function(p: number)
				return p * 1000000000
			end
		},
		CentimetersPerSecond = {
			toRoblox = function(p: number)
				return p * 357
			end,
			toMilesPerHour = function(p: number)
				return p * 44.70272686633884
			end,
			toKilometersPerHour = function(p: number)
				return p * 27.77777777777778
			end,
			toKnot = function(p: number)
				return p * 51.440329218106996
			end,
			toFeetPerSecond = function(p: number)
				return p * 30.478512648582743
			end,
			toMetersPerSecond = function(p: number)
				return p * 100
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 0.1
			end,
			toKilometersPerSecond = function(p: number)
				return p * 100000
			end,
			toMegametersPerSecond = function(p: number)
				return p * 100000000
			end
		},
		KilometersPerSecond = {
			toRoblox = function(p: number)
				return p * 0.00357
			end,
			toMilesPerHour = function(p: number)
				return p * 0.0004470272686633884
			end,
			toKilometersPerHour = function(p: number)
				return p * 0.0002777777777777778
			end,
			toKnot = function(p: number)
				return p * 0.00051440329218107
			end,
			toFeetPerSecond = function(p: number)
				return p * 0.00030478512648582747
			end,
			toMetersPerSecond = function(p: number)
				return p * 0.001
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 1e-9
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 1e-6
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 0.00001
			end,
			toMegametersPerSecond = function(p: number)
				return p * 1000
			end
		},
		MegametersPerSecond = {
			toRoblox = function(p: number)
				return p * 3.5699999999999997e-6
			end,
			toMilesPerHour = function(p: number)
				return p * 4.470272686633884e-7
			end,
			toKilometersPerHour = function(p: number)
				return p * 2.7777777777777776e-7
			end,
			toKnot = function(p: number)
				return p * 5.144032921810699e-7
			end,
			toFeetPerSecond = function(p: number)
				return p * 3.047851264858274e-7
			end,
			toMetersPerSecond = function(p: number)
				return p * 1e-6
			end,
			toMicrometersPerSecond = function(p: number)
				return p * 1e-12
			end,
			toMillimetersPerSecond = function(p: number)
				return p * 1e-9
			end,
			toCentimetersPerSecond = function(p: number)
				return p * 1e-8
			end,
			toKilometersPerSecond = function(p: number)
				return p * 0.001
			end
		}
	},
	Density = {
		Roblox = {
			toGramsPerCubicMeter = function(p: number)
				return p * 1e-6
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 1e-12
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 1e-9
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 1e-8
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 0.001
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 1
			end
		},
		GramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 1000000
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 1e-6
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 0.001
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 0.01
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 1000
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 1000000
			end
		},
		MicrogramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 1000000000000
			end,
			toGramsPerCubicMeter = function(p: number)
				return p * 1000000
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 1000
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 10000
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 1000000000
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 1000000000000
			end
		},
		MilligramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 1000000000
			end,
			toGramsPerCubicMeter = function(p: number)
				return p * 1000
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 0.001
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 10
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 1000000
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 1000000000
			end
		},
		CentigramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 100000000
			end,
			toGramsPerCubicMeter = function(p: number)
				return p * 100
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 0.00009999999999999999
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 0.1
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 100000
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 100000000
			end
		},
		KilogramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 1000
			end,
			toGramsPerCubicMeter = function(p: number)
				return p * 0.001
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 1e-9
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 1e-6
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 0.00001
			end,
			toMegagramsPerCubicMeter = function(p: number)
				return p * 1000
			end
		},
		MegagramsPerCubicMeter = {
			toRoblox = function(p: number)
				return p * 1
			end,
			toGramsPerCubicMeter = function(p: number)
				return p * 1e-6
			end,
			toMicrogramsPerCubicMeter = function(p: number)
				return p * 1e-12
			end,
			toMilligramsPerCubicMeter = function(p: number)
				return p * 1e-9
			end,
			toCentigramsPerCubicMeter = function(p: number)
				return p * 1e-8
			end,
			toKilogramsPerCubicMeter = function(p: number)
				return p * 0.001
			end
		}
	}
}