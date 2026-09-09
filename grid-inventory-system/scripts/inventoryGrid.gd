class_name InventoryGrid
extends GridContainer

@export var slotSize: int = 32; 
@export var slotBorderWidth: int = 2; 

@export var width: int = 3; 
@export var height: int = 3; 

@export var vertSeparation: int = 0;
@export var horSeparation: int = 0; 

@export var slotData: Array[Node] = []; 
@export var currentSlot: Node; 
@export var currentHeldItem: Node = null; 

@export var inventoryItemPrefabs: Array[PackedScene] = [];

const GlobalEnums = preload("res://scripts/globalEnums.gd");

@export var slotPrefab: PackedScene; 

func _ready() -> void:
	add_theme_constant_override("h_separation", horSeparation);
	add_theme_constant_override("v_separation", vertSeparation);
	
	setupInventory(); 
		
func _process(delta: float) -> void:
	if (!get_global_rect().has_point((get_global_mouse_position()))):
		if (currentSlot != null):
			currentSlot = null
	if (currentHeldItem != null && currentSlot != null):
		if Input.is_action_just_pressed("LMB"):
			print("Will attempt to place item!")
			attemptItemPlace(currentSlot, currentHeldItem);
	
# Setup inventory by filling the grid container with slots
func setupInventory(): 
	self.columns = width; 
	for y in height:
		for x in width:
			createSlot(); 
			print("Created inventory slot at " + str(x) + ", " + str(y));

func createSlot(): 
	var inventorySlot = slotPrefab.instantiate();
	inventorySlot.rectSize = slotSize; 
	inventorySlot.borderWidth = slotBorderWidth; 
	
	inventorySlot.mouseEnteredSlot.connect(onSlotMouseEnter)
	inventorySlot.mouseExitedSlot.connect(onSlotMouseExit)
	inventorySlot.attemptItemPickup.connect(onAttemptPickup)
			
	add_child(inventorySlot);
	slotData.append(inventorySlot);
	print(slotData);
	
func createEmptySlotData():
	var totalElements = width * height;  
	slotData = []; 
	slotData.resize(totalElements);
	
# Called whenever the mouse enters the area of a slot. 
func onSlotMouseEnter(slot: Node):
	currentSlot = slot; 
	var slotVector = getSlotCoords(slot);
	print("Vector: " + str(slotVector.x) + ", " + str(slotVector.y));
	var slotRef = getSlotFromCoords(slotVector.y, slotVector.x);
	print(slotRef)
	print("Entered Slot: " + str(slot))
	currentSlot.updateSlotColor(GlobalEnums.SlotState.EMPTY);

# Called whenever the mouse leaves the area of a slot
func onSlotMouseExit(slot: Node):
	print("On mouse exit in InventoryGrid")
	slot.updateSlotColor(GlobalEnums.SlotState.DEFAULT);
	
#Gets the X and Y coords (representing column, and row)
#from a slot node
func getSlotCoords(slot: Node):
	print(slot);
	var index = slotData.find(slot);
	if (index == -1):
		print("Slot not found.")
	else :
		var row = index / width
		var column = index % width

		return Vector2(int(column), int(row));
	
#Checks whether an item can be placed in a specified area. 
func checkForFit(itemShape: Array[Array]): 
	var startCoord = getSlotCoords(currentSlot);
	#How many columns/how long along X item is
	var shapeWidth = itemShape[0].size();
	#How many rows/how long along Y item is
	var shapeHeight = itemShape.size(); 

	#Loop through slots grid and see if slots the specified
	#distance away from the start contain an object
	for y in range(startCoord.y, startCoord.y + shapeHeight):
		if (startCoord.y + shapeHeight) > height:
			print("Item is not fully in the grid.")
			return false; 
		else :
			for x in range(startCoord.x, startCoord.x + shapeWidth):
				if (startCoord.y + shapeHeight) > height:
					print("Item is not fully in the grid.")
					return false; 
				else : 
					var relativeItemTile = itemShape[y - startCoord.y][x - startCoord.x];
					#If this part of the item grid doesn't have anything any it,
					#we can skip collision checks. 
					if (relativeItemTile == 0):
						pass; 
					else :
						#If the slot that is being checked whether we can
						#slot the item onto has something in it, return that
						#we cannot fit it
						var checkSlot = getSlotFromCoords(y, x);
						if (checkSlot.hasItem()):
							return false; 

#Gets a reference to an inventory slot using its row and column
func getSlotFromCoords(row: int, column: int):
	var index = getIndexFromCoords(row, column);
	if (index < slotData.size()):
		var slot = slotData[index];
		return slot; 
	else : 
		return null;

#Gets the index of an inventory slot using its row and column
func getIndexFromCoords(row: int, column: int):
	print("Column (X): " + str(column) + " Row (Y): " + str(row))
	var index = row * width + column;  
	print("Index: " + str(index))
	return index; 

#Attempts to place an item at a specified slot
#It will attempt to place an item using the top left-most
#tile in the item's structure. 
func placeItem(item: Node, slot: Node):
	if (checkForFit(item.itemGrid) == true):
		#Place item logic here
		var itemShape = item.itemGrid; 
		var startCoord = getSlotCoords(slot);
		var shapeWidth = itemShape[0].size();
		var shapeHeight = itemShape.size(); 
		
		#Removes the item from the previous slots it was in
		clearItemFromSlots(item); 
		
		#Add a reference to the item to any slot that will contain it
		for y in range(startCoord.y, startCoord.y + shapeHeight):
			for x in range(startCoord.x, startCoord.x + shapeWidth):
				var relativeItemTile = itemShape[y - startCoord.y][x - startCoord.x];
				if (relativeItemTile == 1):
					var updateSlot = getSlotFromCoords(y, x);
					updateSlot.addItem(item);
		
		#Update item previous location
		item.previousLocation = Vector2(startCoord.x, startCoord.y);
		
	else : 
		print("Item cannot be placed here!");
		pass; 

#Clears out any references slots may have 
func clearItemFromSlots(item: Node):
	for i in slotData.size(): 
		if slotData[i].containedItem == item : 
			slotData[i].removeItem(); 
		
#"Drops" an item, putting it back where it was before 
# it began being moved	
func dropItem(item: Node):
	pass;

func onAttemptPickup(slot: Node):
	if (currentHeldItem != null):
		slot.containedItem.pickupItem(); 
	else:
		pass;

func attemptItemPlace(slot: Node, item: Node):
	placeItem(item, slot);
	
#Spawns a new item in from the prefabs list (NOT IMPLEMENTED YET)
func onSpawnButtonPress() -> void:
	print("Spawn button pressed!");
	if (inventoryItemPrefabs.size() <= 0):
		return; 
	var newItem = inventoryItemPrefabs[0].instantiate(); 
	self.get_parent().add_child(newItem);
	newItem.isSelected = true; 
	currentHeldItem = newItem; 
