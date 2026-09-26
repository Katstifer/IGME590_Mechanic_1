class_name InventoryInputHandler
extends Control

var currentSlot: InventorySlot; 
var previousSlot: InventorySlot; 

var currentHeldItem: InventoryItem = null; 
var currentInventory: InventoryGrid;

var mouseOnGrid : bool = false; 

@export var spawnHandler : InventoryItemSpawnHandler; 
@export var inventoryGrids : Array[InventoryGrid];
@export var itemContainer : Control; 
@export var inventoryItemPrefabs : Array[PackedScene];
var spawnGrid : InventorySpawnGrid = null; 

@export var slotSize : int = 64; 

func _ready() -> void:
	for grid in inventoryGrids: 
		if (grid is InventorySpawnGrid):
			spawnGrid = grid; 
		grid.setFields(self, spawnHandler, slotSize);
		grid.mouseEnteredGrid.connect(onMouseEnterGrid);
		grid.mouseExitedGrid.connect(onMouseExitGrid);
		grid.mouseEnteredGridSlot.connect(onMouseEnterSlot);
		
	spawnHandler.setFields(inventoryItemPrefabs, self, itemContainer, spawnGrid, slotSize);

func _process(delta: float) -> void:
	if (currentInventory != null):
		if (currentHeldItem != null && currentSlot != null):
			if (currentSlot != previousSlot):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem); 
				previousSlot = currentSlot; 
			if Input.is_action_just_pressed("Place"):
				placeItem(); 
				
				pass; 
			if Input.is_action_just_pressed("SwapItem"):
				swapItem(); 
				 
		elif (currentSlot != null):
			if (currentSlot != previousSlot):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
			
			if Input.is_action_just_pressed("PickUp"):
				pickupItem(); 
	else: 
		if (currentSlot != null):
			currentSlot = null; 

	if (currentHeldItem != null):
		if Input.is_action_just_pressed("Rotate"):
			currentHeldItem.rotateItem(); 
						
			if (currentInventory != null && currentSlot != null):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
				
		if Input.is_action_just_pressed("DropItem"):
			dropItem(); 
			
			if (currentInventory != null && currentSlot != null):
				currentInventory.handleSlotHighlights(currentSlot, currentHeldItem);
	else: 
		#if Input.is_action_just_pressed("SpawnItem"):
			#spawnItem(); 
		pass; 	

#Called when the mouse enters an area of an inventory			
func onMouseEnterGrid(grid: InventoryGrid):
	#print("Mouse entered: " + str(grid));
	currentInventory = grid; 
	#print("Current inventory: " + str(currentInventory));
	
#Called when the mouse exits the area of an inventory
func onMouseExitGrid(grid: InventoryGrid): 
	#print ("Mouse exited: " + str(grid));
	if (grid.highlightedSlots.size() > 0 && grid.highlightedSlots != null):
		grid.unhighlightSlots(grid.highlightedSlots);
	currentInventory = null; 

#Called when the mouse enters a slot. 
func onMouseEnterSlot(slot: InventorySlot):
	previousSlot = currentSlot; 
	currentSlot = slot; 
	#print("Mouse entered new slot: " + str(currentSlot));
	
#Picks up an item occupying a slot. 
func pickupItem(): 
	var newItem = currentInventory.pickupItem(currentSlot);
	if (newItem != null):
		currentHeldItem = newItem; 
		currentHeldItem.get_parent().move_child(currentHeldItem, currentHeldItem.get_parent().get_child_count() - 1)
	
#Drops an item while holding it, returning it to its previous
#spot. Does not work if the item hasn't been placed yet. 
func dropItem():
	if (currentHeldItem.previousContainer == null):
		print("Can't drop item without previous slot.")
		return; 
	
	if (currentHeldItem.previousAngle != currentHeldItem.angle):
		currentHeldItem.rotateToAngle(currentHeldItem.previousAngle);
	
	var targetInventory; 
	if (currentInventory == null):
		print("Inventory hovered is null, finding inventory of slot.")
		targetInventory = findInventoryOfSlot(currentHeldItem.previousContainer);
		if (targetInventory == null):
			print("Can't find inventory of slot.");
			return; 
	elif (!currentInventory.slotData.has(currentHeldItem.previousContainer)):
		print("Finding inventory that contains slot.");
		targetInventory = findInventoryOfSlot(currentHeldItem.previousContainer);
		if (targetInventory == null):
			print("Can't find inventory of slot.");
			return; 
	else: 
		targetInventory = currentInventory; 
		
	var itemDropped = targetInventory.dropItem(currentHeldItem);
	if (itemDropped):
		currentHeldItem = null; 
	else:
		print("Couldn't drop item.");

#Places an item in a grid
func placeItem(): 
	var itemPlaced = currentInventory.attemptItemPlace(currentSlot, currentHeldItem);
	if (itemPlaced):
		currentHeldItem = null;  
	else:
		print("Couldn't place item");

#Swap one item with another item at the anchor point
func swapItem(): 
	var swapItem = currentInventory.swapItem(currentSlot, currentHeldItem);
	if (swapItem != null):
		currentHeldItem = swapItem; 
		currentHeldItem.get_parent().move_child(currentHeldItem, currentHeldItem.get_parent().get_child_count() - 1)

#Find the inventory a slot is in. 
func findInventoryOfSlot(slot: InventorySlot) -> InventoryGrid: 
	for grid in inventoryGrids: 
		if (grid.slotData.has(slot)):
			return grid; 
	return null; 

#Called to spawn a random item 
func spawnItem():
	if (spawnHandler == null):
		return; 
	#If the current held item is not null and the inventory is
	#using the spawn and immediately attach method, return.
	if (currentHeldItem != null && spawnGrid == null): 
		return; 
		
	spawnHandler.spawnItem(); 

#Occurs when the button that sends the signal is pressed
func onSpawnButtonPress() -> void:
	spawnItem(); 
