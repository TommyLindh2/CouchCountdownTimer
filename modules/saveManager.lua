return function(_username, _password)
	local obj = {}
	local username, password = "tompa", "hemligt123"
	if _username and _password then
		username = _username
		password = _password
	end
	local url = "http://192.168.0.16/CouchTimer"
	--local url = "http://85.226.14.142/CouchTimer"
	local secret = "mattiasegna"

	local function md5Hash(content)
		local crypto = require( "crypto" )
		return crypto.digest( crypto.md5, content )
	end

	local defaultErrorMapping =
	{
		['save'] = "Lyckades inte ladda upp data på servern. (Felhantering kanske kommer i nästa version)",
		['load'] = "Lyckades inte hämta data från servern. (Felhantering kanske kommer i nästa version)",
	}

	local function getErrorMessage(source, _errormessage)
		return {success = false, message = _errormessage or defaultErrorMapping[source] or 'Fungerar ej!\nSlå Tommy nästa gång du ser HEN!'}
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
				
				local userid
				if tonumber(eLogin.response) then
					userid = tonumber(eLogin.response)
				else
					onComplete(getErrorMessage('load'))
					return
				end


				if userid > 0 then
					
					-- Load data
					local key = md5Hash(userid .. secret)
					network.request( url .. "/getData.php?user=" .. userid .. "&key=" .. key, "GET", function(eGet)
						if eGet.phase == "ended" and not eGet.isError then
							
							if tonumber(eGet.response) then
								local responseCode = tonumber(eGet.response)
								if responseCode == 0 then
									onComplete({success = true, data = ''})
								else
									onComplete(getErrorMessage('load'))
								end
							else
								onComplete({success = true, data = eGet.response})
							end

						elseif eGet.phase == "ended" then
							onComplete(getErrorMessage('load', 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'))
						end
					end)
				elseif userid == 0 then
					onComplete(getErrorMessage('load', 'Kan inte hitta din användare på servern'))
				else
					onComplete(getErrorMessage('load'))
				end
			elseif eLogin.phase == "ended" then
				onComplete(getErrorMessage('load', 'Nätverksfel!\n(Kan bero på att serverns IP är ändrat eller att du inte har internet)'))
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
				local userid
				if tonumber(eLogin.response) then
					userid = tonumber(eLogin.response)
				else
					onComplete(getErrorMessage('save'))
					return
				end

				if userid > 0 then

					-- Save data
					local key = md5Hash(userid .. _data .. secret)
					local params = {
						body = "user=" .. userid .. "&key=" .. key .. "&data=" .. _data
					}
					
					network.request( url .. "/setData.php", "POST", function(eSet)
						if eSet.phase == "ended" and not eSet.isError then
							local responseNr
							if tonumber(eSet.response) then
								responseNr = tonumber(eSet.response)
							else
								onComplete(getErrorMessage('save'))
								return
							end
							onComplete({success = responseNr > 0})
						elseif eSet.phase == "ended" then
							onComplete(getErrorMessage('save'))
						end
					end, params)

				elseif userid == 0 then
					onComplete(getErrorMessage('save', 'Kan inte hitta din användare på servern'))
				else
					onComplete(getErrorMessage('save'))
				end
			elseif eLogin.phase == "ended" then
				onComplete(getErrorMessage('save'))
			end
		end)
	end

	return obj
end