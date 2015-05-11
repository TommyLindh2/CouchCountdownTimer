return function(_username, _password)
	local obj = {}
	local username, password = "tompa", "hemligt123"
	if _username and _password then
		username = _username
		password = _password
	end
	--local url = "http://192.168.0.16/CouchTimer"
	local url = "http://85.226.14.142/CouchTimer"
	local secret = "mattiasegna"

	local function md5Hash(content)
		local crypto = require( "crypto" )
		return crypto.digest( crypto.md5, content )
	end

	function obj:loadData(_onComplete)
		native.setKeyboardFocus( nil )
		native.setActivityIndicator( true, 'Hämtar data från server' )

		local function onComplete(...)
			native.setActivityIndicator( false )
			if _onComplete then _onComplete(...) end
		end

		local key = md5Hash(username .. password .. secret)
		network.request( url .. "/login.php?username=" .. username .. "&password=" .. password .. "&key=" .. key, "GET", function(eLogin)
			if eLogin.phase == "ended" and not eLogin.isError then

				local parsedLoginResponse = _G.json.decode(eLogin.response)
				parsedLoginResponse = parsedLoginResponse or {success = false, message = "Unknown error!\nPlease inform Tommy boy"}

				if parsedLoginResponse.success then
					local userid = parsedLoginResponse.data
					-- Load data
					local key = md5Hash(userid .. secret)
					network.request( url .. "/getData.php?user=" .. userid .. "&key=" .. key, "GET", function(eGet)
						if eGet.phase == "ended" and not eGet.isError then
							
							local parsedGetResponse = _G.json.decode(eGet.response)
							parsedGetResponse = parsedGetResponse or {success = false, message = "Unknown error!\nPlease inform Tommy boy"}
							onComplete(parsedGetResponse)

						elseif eGet.phase == "ended" then
							onComplete({success = false, message = 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'})
						end
					end)

				else
					onComplete(parsedLoginResponse)
				end
			elseif eLogin.phase == "ended" then
				onComplete({success = false, message = 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'})
			end
		end)
	end

	

	function obj:saveData(_data, _onComplete)
		native.setKeyboardFocus( nil )
		native.setActivityIndicator( true, 'Laddar upp data till server' )

		local function onComplete(...)
			native.setActivityIndicator( false )
			if _onComplete then _onComplete(...) end
		end

		local key = md5Hash(username .. password .. secret)
		network.request( url .. "/login.php?username=" .. username .. "&password=" .. password .. "&key=" .. key, "GET", function(eLogin)
			if eLogin.phase == "ended" and not eLogin.isError then
				
				local parsedLoginResponse = _G.json.decode(eLogin.response)
				parsedLoginResponse = parsedLoginResponse or {success = false, message = "Unknown error!\nPlease inform Tommy boy"}

				if parsedLoginResponse.success then
					local userid = parsedLoginResponse.data

					-- Save data
					local key = md5Hash(userid .. secret)
					local params = {
						body = "user=" .. userid .. "&key=" .. key .. "&data=" .. _data
					}
					
					network.request( url .. "/setData.php", "POST", function(eSet)
						if eSet.phase == "ended" and not eSet.isError then
						
							local parsedSetResponse = _G.json.decode(eSet.response)
							parsedSetResponse = parsedSetResponse or {success = false, message = "Unknown error!\nPlease inform Tommy boy"}
							_G.printObj(parsedSetResponse)
							onComplete(parsedSetResponse)

						elseif eSet.phase == "ended" then
							onComplete({success = false, message = 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'})
						end
					end, params)
				else
					onComplete(parsedLoginResponse)
				end
			elseif eLogin.phase == "ended" then
				onComplete({success = false, message = 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'})
			end
		end)
	end

	return obj
end