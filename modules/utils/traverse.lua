--=======================================================================================
--=
--=  Traverse
--=  av 10Fingers AB
--=
--=  Filuppdateringar:
--=   * 2013-05-20 <MarcusThunström> - Ny funktion: findAll.
--=   * 2013-05-14 <MarcusThunström> - Nya funktioner: next, previous.
--=   * 2013-04-18 <MarcusThunström> - Lagt till funktion: closest.
--=   * 2013-04-16 <MarcusThunström> - Fil skapad. Lagt till funktioner: find, setIdAttributeName.
--=
--[[=====================================================================================



	API-beskrivning:

		traverse = require("modules.utils.traverse")

		traverse.closest( object, attrs ) :: returnerar utgångsobjektet eller närmsta parent:en som matchar angivna attributer
		traverse.closest( object, id ) :: returnerar utgångsobjektet eller närmsta parent:en som har angivet ID
			- object: Utgångsdisplayobjekt.
			- attrs: Tabell med attributer som displayobjektet ska matcha.
			- id: Värde på ID-attributen som displayobjektet ska ha. (ID-attributens namn ändras med setIdAttributeName() )
			> Returnerar: Objektet som matchar attributerna, eller nil om inget objekt finns.

		traverse.find( [context,] attrs )
		traverse.find( [context,] id )
			- context: Vilken DisplayGroup som ska sökas igenom.
			- attrs: Tabell med attributer som displayobjektet ska matcha.
			- id: Värde på ID-attributen som displayobjektet ska ha. (ID-attributens namn ändras med setIdAttributeName() )
			> Returnerar: Objektet som matchar attributerna, eller nil om inget objekt finns.

		traverse.findAll( [context,] attrs )
		traverse.findAll( [context,] id )
			- context: Vilken DisplayGroup som ska sökas igenom.
			- attrs: Tabell med attributer som displayobjekten ska matcha.
			- id: Värde på ID-attributen som displayobjekten ska ha. (ID-attributens namn ändras med setIdAttributeName() )
			> Returnerar: Lista med objekt som matchar attributerna.

		traverse.next( object ) :: returnerar objektet efter angivet objekt (sibling).
		traverse.previous( object ) :: returnerar objektet innan angivet objekt (sibling).
			- object: Utgångsdisplayobjekt.
			> Returnerar: Nästa/föregående objekt, eller nil om inget mer objekt finns.

		traverse.setIdAttributeName( [idAttributeName] )
			- idAttributeName: Nytt namn på ID-attributen. (Default: "id")



	Exempel:


		local group = display.newGroup()
		display.newImage(group, "foo.png").id = 1
		display.newImage(group, "bar.png").id = 2
		local image2 = traverse.find(2)  -- returnerar den andra bilden


		local group = display.newGroup()
		display.newImage(group, "foo.png").letter = "A"
		display.newImage(group, "bar.png").letter = "B"
		local imageA = traverse.find{ letter="A" }  -- returnerar den första bilden

		traverse.setIdAttributeName("letter")
		local imageB = traverse.find("B")  -- returnerar den andra bilden



--=====================================================================================]]



local tenfLib     = require('modules.utils.tenfLib')

local idAttrName  = 'id'

local lib         = {}



--=======================================================================================



local collectMatches



function collectMatches(context, attrs, results)
	for i = 1, context.numChildren do
		local isMatch, child = true, context[i]
		for attr, v in pairs(attrs) do
			if child[attr] ~= v then
				isMatch = false
				break
			end
		end
		if isMatch then results[#results+1] = child end
		if child.numChildren then collectMatches(child, attrs, results) end
	end
end



--=======================================================================================



-- traverse.closest( object, attrs )
function lib.closest(obj, attrs)
	if type(attrs) ~= 'table' then attrs = {[idAttrName]=attrs} end
	repeat
		local isMatch = true
		for attr, v in pairs(attrs) do
			if obj[attr] ~= v then
				isMatch = false
				break
			end
		end
		if isMatch then return obj end
		obj = obj.parent
	until not obj
	return nil
end



-- traverse.find( [context,] attrs )
-- traverse.find( [context,] id )
function lib.find(context, attrs)
	if not attrs then context, attrs = display.currentStage, context end
	if type(attrs) ~= 'table' then attrs = {[idAttrName]=attrs} end
	for i = 1, context.numChildren do
		local child = context[i]
		local isMatch = true
		for attr, v in pairs(attrs) do
			if child[attr] ~= v then
				isMatch = false
				break
			end
		end
		if isMatch then
			return child
		else
			if child.numChildren then
				local match = lib.find(child, attrs)
				if match then return match end
			end
		end
	end
	return nil
end

-- traverse.findAll( [context,] attrs )
-- traverse.findAll( [context,] id )
function lib.findAll(context, attrs)
	if not attrs then context, attrs = display.currentStage, context end
	if type(attrs) ~= 'table' then attrs = {[idAttrName]=attrs} end
	local results = {}
	collectMatches(context, attrs, results)
	return results
end



-- traverse.next( object )
function lib.next(obj)
	return obj.parent[tenfLib.indexOf(obj)+1]
end

-- traverse.previous( object )
function lib.previous(obj)
	return obj.parent[tenfLib.indexOf(obj)-1]
end



-- traverse.setIdAttributeName( [idAttributeName] )
function lib.setIdAttributeName(name)
	idAttrName = name or 'id'
end



--=======================================================================================



return lib



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
