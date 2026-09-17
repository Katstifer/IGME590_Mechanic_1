class_name InventoryItemSpawnHandler
extends Node

var inventoryItemPrefabs : Array[PackedScene];
var itemContainer : Control; 
var inputHandler : InventoryInputHandler; 
var spawnGrid : InventorySpawnGrid = null; 

var inventoryItemGrids : Array = [];


func setFields(prefabs : Array[PackedScene], input: InventoryInputHandler, container : Control, spawnInventory : InventorySpawnGrid): 
	inputHandler = input; 
	inventoryItemPrefabs = prefabs; 
	itemContainer = container; 
	spawnGrid = spawnInventory; 
	
	inventoryItemGrids.resize(inventoryItemPrefabs.size())
	for i in inventoryItemPrefabs.size(): 
		var tempItem = inventoryItemPrefabs[i].instantiate();
		inventoryItemGrids[i] = tempItem.itemGrid; 
		tempItem.queue_free();
		
	print(inventoryItemGrids);
		
	

func spawnItem():
	if (inventoryItemPrefabs.size() <= 0):
		return; 
	if (itemContainer == null):
		return; 
		
	var itemIndex = randi_range(0, inventoryItemPrefabs.size() - 1);
	var newItem = inventoryItemPrefabs[itemIndex].instantiate(); 	
	
	#If the spawn grid isn't null
	if (spawnGrid != null):
		
		#Try to find a slot to place the new item in
		var spawnSuccess = false; 
		var foundSlot = spawnGrid.findFirstSpace(newItem);
		
		#If the spot cannot be found for the item in question
		if (foundSlot == null):
			#Delete the item that can't be spawned
			newItem.queue_free();
			var usedItems = []; 
			#Loop through the item prefabs until one is found that
			#can fit in the area
			for i in inventoryItemPrefabs.size(): 
				var index; 
				index = randi_range(0, inventoryItemPrefabs.size() - 1);
				
				if (usedItems.has(inventoryItemPrefabs[index])):
					while (usedItems.has(inventoryItemPrefabs[index])):
						index = randi_range(0, inventoryItemPrefabs.size() - 1);
				 
				usedItems.append(inventoryItemPrefabs[index]);	
					
				var tempItem = inventoryItemPrefabs[index].instantiate();
				#If it fits in the space, set the newItem to reference
				#the temp item and break the loop. 
				if spawnGrid.findFirstSpace(tempItem) != null:
					newItem = tempItem; 
					foundSlot = spawnGrid.findFirstSpace(tempItem);
					spawnSuccess = true; 
					break;
				#If the item doesn't fit, delete it.
				else: 
					tempItem.queue_free(); 
		#If the item didn't have trouble spawning on the first time
		#mark spawning as a success
		else: 
			spawnSuccess = true; 	
		
		if (spawnSuccess == false):
			newItem.queue_free(); 
			print("Couldn't spawn item.");
		else: 
			itemContainer.add_child(newItem);
			spawnGrid.handleItemSpawn(newItem, foundSlot);
	else: 
		itemContainer.add_child(newItem);
		newItem.isSelected = true; 
		inputHandler.currentHeldItem = newItem; 

func onSpawnButtonPressed() -> void:
	print("Spawn button pressed!");
	if (inputHandler == null):
		return; 
	if (inputHandler.currentHeldItem != null): 
		return; 
		
	spawnItem(); 
