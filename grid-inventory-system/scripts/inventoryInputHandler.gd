class_name InventoryInputHandler
extends Control

var currentSlot: InventorySlot; 
var previousSlot: InventorySlot; 

var currentHeldItem: InventoryItem = null; 
var currentInventory: InventoryGrid;

var mouseOnGrid : bool = false; 

@export var inventoryGrids : Array[InventoryGrid];
@export var spawnHandler : InventoryItemSpawnHandler; 
@export var slotSize : int = 64; 

func _ready() -> void:
	for grid in inventoryGrids: 
		grid.setFields(self, spawnHandler, slotSize);
		grid.mouseEnteredGrid.connect(onMouseEnterGrid);
		grid.mouseExitedGrid.connect(onMouseExitGrid);
		grid.mouseEnteredGridSlot.connect(onMouseEnterSlot);

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

func findInventoryOfSlot(slot: InventorySlot) -> InventoryGrid: 
	for grid in inventoryGrids: 
		if (grid.slotData.has(slot)):
			return grid; 
	return null; 
