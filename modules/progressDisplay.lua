------------------------------------------------------------------------------------------
--
-- Progress Display av 10FINGERS AB
-- progressDisplay.lua
--
-- Påbörjad: 2012-11-19 av Marcus Thunström
-- Uppdaterad: 2012-11-28 av Marcus Thunström
--
--[[--------------------------------------------------------------------------------------



API-beskrivning:


	progressDisplay = require('modules.progressDisplay')( [parent,] progressType, minValue, maxValue, params )
		- parent: vilken grupp progressdisplayen ska läggas in i. (Default: nil)
		- progressType: typ av progressdisplay. Varje typ har egna unika metoder utöver de vanliga metoderna.
		- minValue: början på intervallet som visas.
		- maxValue: slutet på intervallet som visas.
		- params: parametrar som används av progressdisplayen av angiven typ.

	progressDisplay:getMaxHeight(  ) :: Returnerar den maximala höjden som progressdisplayen kan ta upp.
		> Returnerar: maximalt möjlig höjd.

	progressDisplay:getProgress(  ) :: Returnerar hur fylld progressdisplayen är.
		> Returnerar: tal mellan minValue och maxValue.

	progressDisplay:setInterval( minValue, maxValue )
		- minValue: minsta värdet i progressdisplayen.
		- maxValue: högsta värdet i progressdisplayen.

	progressDisplay:setProgress( progress )
		- progress: hur fylld progressdisplayen ska vara.


	======== Progresstyp: bar ========

		progressDisplay = require('modules.progressDisplay')(parent, 'bar', minValue, maxValue, params)
			- params: tabell...
				blurAlpha: alpha på bakgrund.
				color: färg på progressbaren.
				bgColor: färg på progressbarens bakgrund.
				focusAlpha: alpha på baren.
				size: storlek (höjd) på progressbaren.
				width: progressbarens bredd.
				hideText: Om texten ska vara dolt eller inte

		progressDisplay:setWidth( width ) :: Sätter ny bredd på progressbaren. (Ej implementerad!)
			- width: ny bredd.


	======== Progresstyp: bullets ========

		progressDisplay = require('modules.progressDisplay')(parent, 'bullets', minValue, maxValue, params)
			- params: tabell...
				blurAlpha: alpha på ofokuserade prickar.
				blurScale: skala på ofokuserade prickar.
				color: färg på prickarna.
				focusAlpha: alpha på fokuserade prickar.
				focusScale: skala på fokuserade prickar.
				focusSpread: över hur många extra prickar fokuset ska överlappa.
				segmentDistance: hur långt det är mellan centrumen på prickarna.
				segmentSize: diameter på prickarna.

		progressDisplay:setSegmentAmount( amount ) :: Sätter antal prickar. (Ej helt implementerad!)
			- amount: antal prickar.


	======== Progresstyp: rays ========

		progressDisplay = require('modules.progressDisplay')(parent, 'rays', minValue, maxValue, params)
			- params: tabell...
				blurAlpha: alpha på ofokuserade strålar.
				blurScale: skala på ofokuserade strålar.
				color: färg på strålar.
				focusAlpha: alpha på fokuserade strålar.
				focusScale: skala på fokuserade strålar.
				focusSpread: över hur många extra strålar fokuset ska överlappa.
				inner: inre radie för strålarna.
				outer: yttre radie för strålarna.
				segmentWidth: bredden på strålarna.

		progressDisplay:setSegmentAmount( amount ) :: Sätter antal strålar. (Ej helt implementerad!)
			- amount: antal strålar.



Exempel på användande:

	local progressDisplay = require('modules.progressDisplay')('bullets', 1, 6, {color={255,150,50}})
	progressDisplay.x, progressDisplay.y = display.contentWidth/2, 140
	progressDisplay:setProgress(5)

	local progressDisplay = require('modules.progressDisplay')('bar', 0, 4, {color={50,255,100}, width=400})
	progressDisplay.x, progressDisplay.y = display.contentWidth/2, 260
	progressDisplay:setProgress(1.65)



--]]--------------------------------------------------------------------------------------



local Pi, Tau            = math.pi, 2*math.pi

local tenfLib            = require('modules.utils.tenfLib')

local clamp              = tenfLib.clamp
local printObj           = tenfLib.printObj
local removeAllChildren  = tenfLib.removeAllChildren

local deadZoneR          = 20

local k                  = {}

local constructors       = {}
local methods            = {[k]={}, bar={}, bullets={}, rays={}}







-- Funktioner
------------------------------------------------------------------------------------------



local setInterval
local setProgress



function setInterval(progDispGroup, minValue, maxValue)
	local data = progDispGroup[k]
	data.minValue, data.maxValue = minValue or data.minValue, maxValue or data.maxValue
end



function setProgress(progDispGroup, value)
	local data = progDispGroup[k]
	data.value = clamp(value, data.minValue, data.maxValue)
end







-- Metoder
------------------------------------------------------------------------------------------







methods[k].getProgress = function(progDispGroup)
	return progDispGroup[k].value
end







-- Bar
------------------------------------------------------------------------------------------



function constructors.bar(progDispGroup, params)

	local data = progDispGroup[k]
	data.color = params.color and (type(params.color) == 'table' and params.color or {params.color}) or _G.navBarColor
	data.bgColor = params.bgColor or {0.4}
	data.textColor = params.textColor and (type(params.textColor) == 'table' and params.textColor or {params.textColor}) or {1}
	data.barSize = params.size or 20
	data.barWidth = params.width or display.contentWidth
	data.blurAlpha = params.blurAlpha or 0.4
	data.focusAlpha = params.focusAlpha or 1
	data.hideText = params.hideText or false

	local contentGroup = data.contentGroup
	contentGroup.x = -data.barWidth/2

	data.background = display.newRect(contentGroup, data.barWidth / 2, -data.barSize/2, data.barWidth, data.barSize)
	data.background.alpha = data.blurAlpha
	data.background:setFillColor(unpack(_G.getGradientColor(data.bgColor)))--unpack(data.color))

	data.progressBar = display.newRect(contentGroup, 0, -data.barSize/2, data.barWidth, data.barSize)
	data.progressBar.alpha = data.focusAlpha
	data.progressBar:setFillColor(unpack(_G.getGradientColor(data.color)))
	--data.progressBar:setReferencePoint(display.CenterLeftReferencePoint)
	data.progressBar.anchorX, data.progressBar.anchorY = 0, 0.5

	local options = 
	{
		parent = contentGroup,
		text = "",
		x = data.background.x,
		y = data.background.y - (_G.isSimulator and 0 or 2),
		width = data.barWidth,
		height = data.barSize + 2,
		font = _G.fontName,
		fontSize = _G.fontSizeVerySmall,
		align = "center"  --new alignment parameter
	}
	data.progressText = display.newText( options )
	data.progressText:setFillColor(unpack(data.textColor))
	data.progressText.isVisible = not data.hideText

	progDispGroup:setProgress(data.value)

end



function methods.bar.getMaxHeight(progDispGroup)
	return progDispGroup[k].barSize
end



function methods.bar.setInterval(progDispGroup, minValue, maxValue)
	setInterval(progDispGroup, minValue, maxValue)
end



function methods.bar.setProgress(progDispGroup, value)
	setProgress(progDispGroup, value)
	local data = progDispGroup[k]
	data.progressBar.xScale = math.max((data.value-data.minValue)/(data.maxValue-data.minValue), 0.001)
	data.progressText.text = data.value .. " / " .. data.maxValue .. " (" .. (data.maxValue == 0 and "0" or _G.tenfLib.round((data.value / data.maxValue) * 100, 1)) .. "%)"
end



function methods.bar.setWidth(progDispGroup, width)
	-- TODO
end







-- Bullets
------------------------------------------------------------------------------------------



function constructors.bullets(progDispGroup, params)

	local data = progDispGroup[k]
	data.blurAlpha = params.blurAlpha or 0.3
	data.blurScale = params.blurScale or 0.5
	data.color = params.color and (type(params.color) == 'table' and params.color or {params.color}) or {255}
	data.focusAlpha = params.focusAlpha or 1
	data.focusScale = params.focusScale or 1
	data.focusSpread = params.focusSpread or 0
	data.radius = params.radius or nil
	data.segmentDistance = params.segmentDistance or 40
	data.segmentSize = params.segmentSize or 20

	progDispGroup:setSegmentAmount(params.segmentAmount or data.maxValue-data.minValue+1)

end



function methods.bullets.getMaxHeight(progDispGroup)
	local data = progDispGroup[k]
	return 2*(data.radius or 0)+data.segmentSize*math.max(data.blurScale, data.focusScale)
end



function methods.bullets.setInterval(progDispGroup, minValue, maxValue)
	setInterval(progDispGroup, minValue, maxValue)
	local data = progDispGroup[k]
	progDispGroup:setSegmentAmount(data.maxValue-data.minValue+1)
end



function methods.bullets.setProgress(progDispGroup, value)
	setProgress(progDispGroup, value)
	local data = progDispGroup[k]
	local contentGroup = data.contentGroup
	local v, min, max, len = data.value, data.minValue, data.maxValue, data.segmentAmount
	if data.radius then
		for i = 1, len-1 do
			local segment = contentGroup[i]
			local focusAmount = -math.min(math.abs(v-min-i)/(data.focusSpread+1)-1, 0)
				-math.min(math.abs(v-min-i+len-1)/(data.focusSpread+1)-1, 0)
				-math.min(math.abs(v-min-i-len+1)/(data.focusSpread+1)-1, 0)
			segment.alpha = data.blurAlpha+(data.focusAlpha-data.blurAlpha)*focusAmount
			segment.xScale = data.blurScale+(data.focusScale-data.blurScale)*focusAmount
			segment.yScale = segment.xScale
		end
	else
		for i = 1, len do
			local segment = contentGroup[i]
			local focusAmount = -math.min(math.abs(v-min-i+1)/(data.focusSpread+1)-1, 0)
			segment.alpha = data.blurAlpha+(data.focusAlpha-data.blurAlpha)*focusAmount
			segment.xScale = data.blurScale+(data.focusScale-data.blurScale)*focusAmount
			segment.yScale = segment.xScale
		end
	end
end



function methods.bullets.setSegmentAmount(progDispGroup, amount) -- TODO: få setProgress att samarbeta med setSegmentAmount

	local data = progDispGroup[k]
	data.segmentAmount = amount

	local contentGroup = data.contentGroup
	removeAllChildren(contentGroup)
	if not data.radius then
		contentGroup.x = -data.segmentDistance*(data.segmentAmount+1)/2
	end

	if data.radius then
		for i = 1, data.segmentAmount-1 do
			local a = i*Tau/(data.segmentAmount-1)
			local x, y = data.radius*math.sin(a), -data.radius*math.cos(a)
			display.newCircle(contentGroup, x, y, data.segmentSize/2):setFillColor(unpack(data.color))
		end
	else
		for i = 1, data.segmentAmount do
			local x, y = i*data.segmentDistance, 0
			display.newCircle(contentGroup, x, y, data.segmentSize/2):setFillColor(unpack(data.color))
		end
	end

	progDispGroup:setProgress(data.value)

end







-- Rays
------------------------------------------------------------------------------------------



function constructors.rays(progDispGroup, params)

	local data = progDispGroup[k]
	data.blurAlpha = params.blurAlpha or 0.5
	data.blurScale = params.blurScale or 0.7
	data.color = params.color and (type(params.color) == 'table' and params.color or {params.color}) or {255}
	data.focusAlpha = params.focusAlpha or 1
	data.focusScale = params.focusScale or 1
	data.focusSpread = params.focusSpread or 0
	data.inner = params.inner or 0
	data.outer = params.outer or 60
	data.segmentWidth = params.segmentWidth or 8
	data.sudden = params.sudden or false

	progDispGroup:setSegmentAmount(params.segmentAmount or data.maxValue-data.minValue+1)

end



function methods.rays.getMaxHeight(progDispGroup)
	local data = progDispGroup[k]
	return 2*data.outer*math.max(data.blurScale, data.focusScale)
end



function methods.rays.setInterval(progDispGroup, minValue, maxValue)
	setInterval(progDispGroup, minValue, maxValue)
	local data = progDispGroup[k]
	progDispGroup:setSegmentAmount(data.maxValue-data.minValue+1)
end



function methods.rays.setProgress(progDispGroup, value)
	setProgress(progDispGroup, value)
	local data = progDispGroup[k]
	local contentGroup = data.contentGroup
	local v, min, max, len = data.value, data.minValue, data.maxValue, data.segmentAmount
	for i = 1, len-1 do
		local segment = contentGroup[i]
		local focusAmount = 0
		if data.sudden then
			if i <= v-min or i >= v-min+len-2 then -- TODO: focusSpread när sudden=true
				focusAmount = -math.min(math.abs(v-min-i)-1, 0)
					-math.min(math.abs(v-min-i+len-1)-1, 0)
			end
		else
			focusAmount = -math.min(math.abs(v-min-i)/(data.focusSpread+1)-1, 0)
				-math.min(math.abs(v-min-i+len-1)/(data.focusSpread+1)-1, 0)
				-math.min(math.abs(v-min-i-len+1)/(data.focusSpread+1)-1, 0)
		end
		segment.alpha = data.blurAlpha+(data.focusAlpha-data.blurAlpha)*focusAmount
		segment.xScale = data.blurScale+(data.focusScale-data.blurScale)*focusAmount
		segment.yScale = segment.xScale
	end
end



function methods.rays.setSegmentAmount(progDispGroup, amount)

	local data = progDispGroup[k]
	data.segmentAmount = amount

	local contentGroup = data.contentGroup
	removeAllChildren(contentGroup)

	for i = 1, data.segmentAmount-1 do

		local segment = display.newLine(contentGroup, 0, 0, 0, data.outer-data.inner)
		segment.width = data.segmentWidth
		segment:setColor(unpack(data.color))
		segment.yReference = data.outer-data.inner

		local a = i*Tau/(data.segmentAmount-1)
		segment.x, segment.y, segment.rotation = data.inner*math.sin(a), -data.inner*math.cos(a), a/Tau*360

	end

	progDispGroup:setProgress(data.value)

end







------------------------------------------------------------------------------------------



return function(parent, progressType, minValue, maxValue, params)
	if type(parent) ~= 'table' then
		parent, progressType, minValue,     maxValue, params   =
		nil,    parent,       progressType, minValue, maxValue
	end

	local progDispGroup = tenfLib.newGroup(parent)
	progDispGroup[k] = {
		contentGroup = tenfLib.newGroup(progDispGroup),
		progressType = progressType,
		value = minValue,  minValue = minValue,  maxValue = maxValue,
	}

	local constructor = constructors[progressType]
	if not constructor then error('invalid progress display type "'..tostring(progressType)..'"', 2) end
	tenfLib.setAttr(progDispGroup, methods[k])
	tenfLib.setAttr(progDispGroup, methods[progressType])
	constructor(progDispGroup, params or k)

	return progDispGroup
end



--[[             .,77$I88$?
        .?ZZ77Z:..,:ZZZOONZ$O8O$:
      ,ZOOMO8$,....:OOOOZODZ8OD8OZ.
  ,ZODO8$DDNI:,....,O8OZOODN$$OOO7
.OOO8888$NMN$+,....,Z8I+I$OD877OO.
?8OOO8ZOOMMN8O=,...,7OII$$?IMO$Z$
 $DOOZOONMN$ZZD?=,.,7$7$$DN?78O$.
  Z8OZ$ZMN$ZNN7O$+,.+8$I$NMD??                 ,:::::::,,,.
   $8OO.8DNMMNZZZ~,.,I$$$?Z$I=.             ,:,::::~~~:. .
    ZZ+ $ZODO888+::,,.,~$7$I?+            :~:,,,,:
        .ZOO88O8+~:,,,..,I?I+,          8NNDZ:,,
         7$ZOOZ?+:,~::,...+=:.        NMMMMNO.
          Z$$$+?+~I88D8O,..,        ZNMMMND.
          :?$O$++=8NN8N8:...       NMNNNN.
          :7I7+?+=?DNNND:,.,     :7NNNDI
          I7+7I?I++$ZOZ7=,:O=  .,,~888+
        .I77$$Z7?I$$$77I~:,.?DZ,,,,:8$
        7$$777Z$$7?I?++~:,,..=DD:,,.,?
       7$$$7I77$II++~:::,,...,8DD:,..,,
      ,7$$$7I777?I++~::,,.....=DDDZ,...,
      77$77$I$II??+=~~:,,,....,DDDDD,..,,
     .777III77$??+=:~~~:,,,,,.,=DD8D~...,,
     I777I??I$ZI?=~:~==:,,.,..,,8D$DZ....,
     III??++I7I?=~,,,~~~:,,....,IO=DZ....,.
     I?+==~=I??=~~,,.:~:,,....,,::+8:....,.
    .II?=++=I?+=~~::,,:::,,,..,,,,::,......
     +I?++=?=?+==~~:::::=:,,,,,,:,,,,.....,
      II+??????++~~==~=~~:,::,,::,,,.,...,,.
      7I?+?7?I??~:+=+++?==~,,,,::,..=:,,.,,,
     .I++?I++??++=~~~===+?~:,,,.    ,=~,...,
      I+===++++=+~====?=++~,,.,      :=:,.,,
      ?+~:~~= ,,~~~==~~=+~:,.,,       =~:,,.
      =+=~::~.       =~~+~,,,,,       ,~:,,.
       ++~:,,.       =~~+~::,,.       =~,,,
       +=~:,,,       =~~:,,,,,        ~:..,
       ~+~,,.,      .~:~:,....        =:.,,
       .+=,,..      ~:=:,,,,,         ~,..,
        ?+~,..,   .~::~:,,,,,         ~,..,
        +~:,.., ,:~:::~:,,..,         :,,.,
        +~,...,~~::~:~:,.....        .:,,,,
       .~,,....I7=+=:~:,,...         ::,=::,
      .,,,,,,.,     ,,,,....        ,+=,+:,~
     :=,:=,,~,,     :::::,,,.         ,::=~
    .?=,+:,,:,,    ~~~~~,,,,,
                   ..~7++=:~.
]]
