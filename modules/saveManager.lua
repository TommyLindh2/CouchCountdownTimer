return function()
	local obj = {}
	local username, password = "tompa", "hemligt123"
	local url = "http://85.226.14.142/CouchTimer"
	local secret = "mattiasegna"

	local function md5Hash(content)
		local crypto = require( "crypto" )
		return crypto.digest( crypto.md5, content )
	end

	function obj:loadData(_onComplete)
		local key = md5Hash(username .. password .. secret)
		network.request( url .. "/login.php?username=" .. username .. "&password=" .. password .. "&key=" .. key, "GET", function(eLogin)
			if eLogin.phase == "ended" and not eLogin.isError then
				
				local userid
				if pcall(function() tonumber(eLogin.response) end) then
					userid = tonumber(eLogin.response)
				else
					if _onComplete then _onComplete({success = false}) end
					return
				end


				if userid > 0 then
					
					-- Load data
					local key = md5Hash(userid .. secret)
					network.request( url .. "/getData.php?user=" .. userid .. "&key=" .. key, "GET", function(eGet)
						if eGet.phase == "ended" and not eGet.isError then
							if _onComplete then _onComplete({success = true, data = eGet.response}) end
						elseif eGet.phase == "ended" then
							if _onComplete then _onComplete({success = false}) end
						end
					end)


				else
					if _onComplete then _onComplete({success = false}) end
				end
			elseif eLogin.phase == "ended" then
				if _onComplete then _onComplete({success = false}) end
			end
		end)
	end

	

	function obj:saveData(_data, _onComplete)
		local key = md5Hash(username .. password .. secret)
		network.request( url .. "/login.php?username=" .. username .. "&password=" .. password .. "&key=" .. key, "GET", function(eLogin)
			if eLogin.phase == "ended" and not eLogin.isError then
				local userid
				if pcall(function() tonumber(eLogin.response) end) then
					userid = tonumber(eLogin.response)
				else
					if _onComplete then _onComplete({success = false}) end
					return
				end

				if userid > 0 then

					-- Save data
					local key = md5Hash(userid .. secret)
					local params = {
						body = "user=" .. userid .. "&key=" .. key .. "&data=" .. _data
					}
					
					network.request( url .. "/setData.php", "POST", function(eSet)
						if eSet.phase == "ended" and not eSet.isError then
							local responseNr
							if pcall(function() tonumber(eSet.response) end) then
								responseNr = tonumber(eSet.response)
							else
								if _onComplete then _onComplete({success = false}) end
								return
							end

							if _onComplete then _onComplete({success = responseNr > 0}) end
						elseif eSet.phase == "ended" then
							if _onComplete then _onComplete({success = false}) end
						end
					end, params)

				else
					if _onComplete then _onComplete({success = false}) end
				end
			elseif eLogin.phase == "ended" then
				if _onComplete then _onComplete({success = false}) end
			end
		end)
	end

	return obj
end