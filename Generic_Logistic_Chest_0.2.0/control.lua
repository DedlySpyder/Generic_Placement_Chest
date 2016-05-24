require "defines"

debug_mode = false

supportedChests = {	"generic-logistic-chest-passive-provider",
					"generic-logistic-chest-active-provider",
					"generic-logistic-chest-storage",
					"generic-logistic-chest-requester"}

--Check when an entity is placed
function on_entity_placed(event)
	local entity = event.created_entity
	local player = game.players[event.player_index]
	
	--If it is a generic chest, draw GUI and add it and the player match to the table
	if (entity.name == "generic-logistic-chest") then
		drawSelectionGUI(player)
		global.genericChestPlayerData = doesGenericChestGlobalExistOrCreate(global.genericChestPlayerData)
		
		table.insert(global.genericChestPlayerData, {player=player, chest=entity})
		debugLog(#global.genericChestPlayerData)
	end
end

--Register events, references the function
script.on_event(defines.events.on_built_entity, on_entity_placed)

--Check on a GUI click
function on_gui_click(event)
	local elementName = event.element.name
	debugLog(elementName.." clicked")
	
	--Find the button header (for this mod)
	local modSubString = string.sub(elementName, 1, 14)
	debugLog(modSubString)
	
	if (modSubString == "genericChests_") then
		local player = game.players[event.player_index]
		
		--Find the exact button name
		local modButton = string.sub(elementName, 15, #elementName)
		debugLog(modButton)
		
		--Do work depending on the button
		if (modButton == "passiveProvider") then
			switchChest(player, "generic-logistic-chest-passive-provider")
		elseif (modButton == "activeProvider") then
			switchChest(player, "generic-logistic-chest-active-provider")
		elseif (modButton == "storage") then
			switchChest(player, "generic-logistic-chest-storage")
		elseif (modButton == "requester") then
			switchChest(player, "generic-logistic-chest-requester")
		elseif (modButton == "close") then
			destroySlectionGUI(player)
		end
	end
end

script.on_event(defines.events.on_gui_click, on_gui_click)

--Internal Scripts

--GUI Scripts
--Draw the selection GUI
function drawSelectionGUI(player)
	if (player ~= nil) then
		--The frame to hold everything
		local selectionGUI = player.gui.center.add{type="frame", name="genericChestSelectionFrame", direction="vertical", caption={"generic-chest-select-chest"}}
		
		--The flow to hold the buttons
		local selectionButtonFlow = selectionGUI.add{type="flow", direction="horizontal"}
		
		--The buttons
		selectionButtonFlow.add{type="button", name="genericChests_passiveProvider", style="generic_passive_provider_chest_button"}
		selectionButtonFlow.add{type="button", name="genericChests_activeProvider", style="generic_active_provider_chest_button"}
		selectionButtonFlow.add{type="button", name="genericChests_storage", style="generic_storage_chest_button"}
		selectionButtonFlow.add{type="button", name="genericChests_requester", style="generic_requester_chest_button"}
		
		--Close button
		selectionGUI.add{type="button", name="genericChests_close", caption={"generic-chest-close"}}
	end
end

--Destroys the selection GUI
function destroySlectionGUI(player)
	if (player.gui.center.genericChestSelectionFrame ~= nil and player.gui.center.genericChestSelectionFrame.valid) then
		player.gui.center.genericChestSelectionFrame.destroy()
	end
	
	--Remove the playerData from the table
	for _, playerData in pairs(global.genericChestPlayerData) do
		if (playerData.player == player) then
			local newFunction = function (arg) return arg.chest == playerData.chest end --Function that returns true or false if the entities match
			global.genericChestPlayerData = removeFromTable(newFunction, global.genericChestPlayerData)
			debugLog(#global.genericChestPlayerData)
		end
	end
end

--Replaces the generic chest with a replacement
function switchChest(player, chestName)
	
	for _, playerData in pairs(global.genericChestPlayerData) do
		if (playerData.player == player) then
			local position = playerData.chest.position
			playerData.chest.destroy()
			
			player.surface.create_entity{name=chestName, position=position, force=player.force}
		end
	end
	
	destroySlectionGUI(player)
end

--Initialize global.genericChestPlayerData
function doesGenericChestGlobalExistOrCreate(checkTable)
	if checkTable == nil then
		return {player=nil, chest=nil}
	else
		return checkTable
	end
end

--Removes an entity from a global table
--Works by adding everything except the old entry to a new table and overwritting the old table
function removeFromTable(func, oldTable)
	if (oldTable == nil) then return nil end
	local newTable = {}
	for _, row in ipairs(oldTable) do
		if not func(row) then table.insert(newTable, row) end
	end
	return newTable
end

--DEBUG messages
function debugLog(message)
	if debug_mode then
		game.player.print(message)
	end
end 