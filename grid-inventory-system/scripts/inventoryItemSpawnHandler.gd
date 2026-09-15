class_name InventoryItemSpawnHandler
extends Node

@export var inventoryItemPrefabs : Array[PackedScene];
@export var itemContainer : Control; 
@export var inputHandler : InventoryInputHandler; 

func setFields(prefabs : Array[PackedScene], container : Control): 
	inventoryItemPrefabs = prefabs; 
	itemContainer = container; 
	
func spawnItem() -> InventoryItem:
	if (inventoryItemPrefabs.size() <= 0):
		return; 
	if (itemContainer == null):
		return; 
		
	var itemIndex = randi_range(0, inventoryItemPrefabs.size() - 1);
	var newItem = inventoryItemPrefabs[itemIndex].instantiate(); 
	
	itemContainer.add_child(newItem);
	return newItem; 

func onSpawnButtonPressed() -> void:
	print("Spawn button pressed!");
	if (inputHandler == null):
		print("Input handler is null");
		return; 
	if (inputHandler.currentHeldItem != null): 
		print("Can't spawn item while holding another.");
		return; 
		
	var newItem = spawnItem(); 
	newItem.isSelected = true; 
	inputHandler.currentHeldItem = newItem; 
