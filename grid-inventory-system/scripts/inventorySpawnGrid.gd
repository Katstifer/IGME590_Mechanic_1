class_name InventorySpawnGrid
extends InventoryGrid

func findFirstSpace(spawnItem: InventoryItem):
	for slot in slotData:
		var fitSlots = getPotentialSpace(slot, spawnItem);
		if (checkForFit(spawnItem.itemGrid, fitSlots)):
			return slot; 
	return null; 

func handleItemSpawn(spawnItem: InventoryItem, placeSlot : InventorySlot) -> bool:
	if (placeSlot == null):
		print("Can't find a place for spawned item.");
		return false;
	else: 
		var fitSlots = getPotentialSpace(placeSlot, spawnItem);
		placeItem(spawnItem, placeSlot, fitSlots);
		return true; 
