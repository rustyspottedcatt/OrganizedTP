--[[
    https://www.roblox.com/users/1539582829/profile
    https://twitter.com/zzen_a

    MIT License

    Copyright (c) 2023 rustyspotted

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local OrganizedTP = {}
OrganizedTP.__index = OrganizedTP
OrganizedTP.Presets = (script.Parent :: Instance)

local Promise = require(OrganizedTP.Presets.promise)
local Signal = require(OrganizedTP.Presets.signal)

function OrganizedTP.new()
	local self = setmetatable({}, OrganizedTP)

	self.OnPlayerTeleported = Signal.new()
	self.OnApiCall = Signal.new()
	self.OnError = Signal.new()

	return self
end

function OrganizedTP:handleTeleport(wrapCoroutine : boolean)
	if wrapCoroutine then 
		coroutine.wrap(function()
			Players.PlayerAdded:Connect(function(player : Player)
				Promise.new(function(resolve, reject)
					self.OnApiCall:Fire()

					local API_URL : string = "https://yapi-api.com/api/v2/getTargettedGames"
					local success, response = pcall(function()
						return HttpService:GetAsync(API_URL)
					end)

					if not success then return reject("Couldn't fetch data from API") end

					local data = HttpService:JSONDecode(response)
                    local sortedKeys = {}

                    for key, data in pairs(data.data) do
                        table.insert(sortedKeys, tonumber(key), data)
                    end

                    print(sortedKeys)

                    table.sort(sortedKeys, function(a, b)
                        print(a, b)
                        return a.priority < b.priority
                    end)

                    print(sortedKeys)
                    if sortedKeys[1].tpAll == false and type(sortedKeys[1].whitelist) == "table" then 
                        resolve(sortedKeys[1].placeID, sortedKeys[1].whitelist) 
                    else
                        resolve(sortedKeys[1].placeID)
                    end
				end):andThen(function(placeID : number, whitelist : table?)
                    if type(whitelist) == "table" then
                        for _, userID in pairs(whitelist) do
                            if player.UserId == userID then
                                local success, err = pcall(function()
                                    return TeleportService:TeleportAsync(placeID, {player})
                                end)
                                if not success then return self.OnError:Fire(err) end

                                self.OnPlayerTeleported:Fire(player, placeID)
                            else
                                continue;
                            end
                        end
                    else
                        local success, err = pcall(function()
                            return TeleportService:TeleportAsync(placeID, {player})
                        end)
                        if not success then return self.OnError:Fire(err) end

                        self.OnPlayerTeleported:Fire(player, placeID)
                    end
				end):catch(function(...)
					return self.OnError:Fire(...)
				end)
			end)     
		end)()
	end
end

return OrganizedTP