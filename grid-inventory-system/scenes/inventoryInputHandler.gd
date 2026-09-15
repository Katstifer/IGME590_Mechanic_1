class_name InventoryInputHandler
extends Control

var currentSlot: InventorySlot; 
var previousSlot: InventorySlot; 

var currentHeldItem: InventoryItem = null; 
var currentInventory: InventoryGrid;

var mouseOnGrid : bool = false; 

@export var inventoryGrids : Array[InventoryGrid];

func _ready() -> void:
	for grid in inventoryGrids: 
		grid.mouseEnteredGrid.connect(onMouseEnterGrid);
		grid.mouseExitedGrid.connect(onMouseExitGrid);
		grid.mouseEnteredGridSlot.connect(onMouseEnterSlot);
		pass; 

func _process(delta: float) -> void:
	if (currentInventory != null):
		if (currentHeldItem != null && currentSlot != null):
			if (currentSlot != previousSlot):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem); 
				previousSlot = currentSlot; 
			if Input.is_action_just_pressed("Place"):
				print("Attempt place in: " + str(currentInventory));
				placeItem(); 
				
				pass; 
			if Input.is_action_just_pressed("SwapItem"):
				print("Attempt swap in: " + str(currentInventory));
				swapItem(); 
				 
		elif (currentSlot != null):
			if (currentSlot != previousSlot):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
			
			if Input.is_action_just_pressed("PickUp"):
				print("Attempt pick up in: " + str(currentInventory));
				pickupItem(); 
	else: 
		if (currentSlot != null):
			currentSlot = null; 

	if (currentHeldItem != null):
		if Input.is_action_just_pressed("Rotate"):
			print("Attempting to rotate: " + str(currentHeldItem));
			currentHeldItem.rotateItem(); 
			currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
			
			if (currentInventory != null && currentSlot != null):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
				
		if Input.is_action_just_pressed("DropItem"):
			print("Attempt to drop: " + str(currentHeldItem));
			dropItem(); 
			
			if (currentInventory != null && currentSlot != null):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
					
func onMouseEnterGrid(grid: InventoryGrid):
	#print("Mouse entered: " + str(grid));
	currentInventory = grid; 
	#print("Current inventory: " + str(currentInventory));
	
func onMouseExitGrid(grid: InventoryGrid): 
	#print ("Mouse exited: " + str(grid));
	if (grid.highlightedSlots.size() > 0 && grid.highlightedSlots != null):
		grid.unhighlightSlots(grid.highlightedSlots);
	currentInventory = null; 

func onMouseEnterSlot(slot: InventorySlot):
	previousSlot = currentSlot; 
	currentSlot = slot; 
	#print("Mouse entered new slot: " + str(currentSlot));
	
func pickupItem(): 
	var newItem = currentInventory.pickupItem(currentSlot);
	if (newItem != null):
		currentHeldItem = newItem; 
		currentHeldItem.get_parent().move_child(currentHeldItem, currentHeldItem.get_parent().get_child_count() - 1)
	
func dropItem():
	var itemDropped = currentInventory.dropItem(currentHeldItem);
	if (itemDropped):
		currentHeldItem = null; 
	else:
		print("Couldn't drop item.");
	
func placeItem(): 
	var itemPlaced = currentInventory.attemptItemPlace(currentSlot, currentHeldItem);
	if (itemPlaced):
		currentHeldItem = null;  
	else:
		print("Couldn't place item");
	
func swapItem(): 
	var swapItem = currentInventory.swapItem(currentSlot, currentHeldItem);
	if (swapItem != null):
		currentHeldItem = swapItem; 
		currentHeldItem.get_parent().move_child(currentHeldItem, currentHeldItem.get_parent().get_child_count() - 1)
