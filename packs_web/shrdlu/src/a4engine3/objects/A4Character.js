var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var A4CHARACTER_STATE_NONE = -1;
var A4CHARACTER_STATE_IDLE = 0;
var A4CHARACTER_STATE_WALKING = 1;
var A4CHARACTER_STATE_INTERACTING = 2;
var A4CHARACTER_STATE_TALKING = 3;
var A4CHARACTER_STATE_THOUGHT_BUBBLE = 4;
var A4CHARACTER_STATE_IN_VEHICLE = 5;
var A4CHARACTER_STATE_IN_BED = 6;
var A4CHARACTER_STATE_IN_BED_CANNOT_GETUP = 7;
var A4CHARACTER_STATE_IN_BED_TALKING = 8;
var A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_TALKING = 9;
var A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE = 10;
var A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE = 11;
var A4CHARACTER_STATE_DYING = 12;
var A4CHARACTER_STATE_IN_VEHICLE_TALKING = 13;
var A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE = 14;
var A4CHARACTER_COMMAND_IDLE = 0;
var A4CHARACTER_COMMAND_WALK = 1;
// note: "TAKE" turns into "USE" when there is no takeable object, but there is an "useable" object
var A4CHARACTER_COMMAND_TAKE = 2;
var A4CHARACTER_COMMAND_DROP = 3;
var A4CHARACTER_COMMAND_USE = 4;
var A4CHARACTER_COMMAND_UNEQUIP = 5;
var A4CHARACTER_COMMAND_INTERACT = 6;
var A4CHARACTER_COMMAND_TALK = 7;
var A4CHARACTER_COMMAND_THOUGHT_BUBBLE = 8;
var A4CHARACTER_COMMAND_GIVE = 9;
//var A4CHARACTER_COMMAND_SELL:number = 10;
//var A4CHARACTER_COMMAND_BUY:number = 11;
var A4CHARACTER_COMMAND_PUSH = 12;
var A4CharacterCommand = /** @class */ (function () {
    function A4CharacterCommand(c, a, d, target, t, p) {
        this.command = c;
        this.argument = a;
        this.direction = d;
        this.target = target; // if there are multiple objects in the same direction, this allows to specify which one to target
        this.text = t;
        this.priority = p;
    }
    return A4CharacterCommand;
}());
var A4Character = /** @class */ (function (_super) {
    __extends(A4Character, _super);
    function A4Character(name, sort) {
        var _this = _super.call(this, name, sort) || this;
        // attributes:
        _this.inventory = [];
        _this.strength = 1;
        //    talking_state:number;
        //    talking_state_cycle:number;
        _this.vehicle = null;
        _this.sleepingInBed = null;
        // talking:
        //talkingSpeechAct:SpeechAct = null;
        _this.talkingText = null;
        _this.talkingBubble = null;
        _this.talkingTarget = null;
        _this.talkingBubbleDuration = 0;
        _this.hungerTimer = 0;
        _this.thirstTimer = 0;
        _this.state = A4CHARACTER_STATE_IDLE;
        _this.canSwim = false;
        _this.interacteable = true;
        return _this;
    }
    A4Character.prototype.loadObjectAdditionalContent = function (xml, game, of, objectsToRevisit_xml, objsctsToRevisit_object) {
        _super.prototype.loadObjectAdditionalContent.call(this, xml, game, of, objectsToRevisit_xml, objsctsToRevisit_object);
        var items_xml = getFirstElementChildByTag(xml, "items");
        if (items_xml != null) {
            //            let item_xml_l:NodeListOf<Element> = items_xml.children;
            var item_xml_l = items_xml.children;
            for (var i = 0; i < item_xml_l.length; i++) {
                var item_xml = item_xml_l[i];
                var tmp = item_xml.getAttribute("probability");
                if (tmp != null) {
                    if (Math.random() >= Number(tmp))
                        continue;
                }
                var completeRedefinition = false;
                if (item_xml.getAttribute("completeRedefinition") == "true")
                    completeRedefinition = true;
                var classStr = item_xml.getAttribute("class");
                if (classStr == null)
                    classStr = item_xml.getAttribute("type");
                var item = of.createObject(classStr, game, false, completeRedefinition);
                if (item == null) {
                    console.error("object factory returned null for object of class " + item_xml.getAttribute("class"));
                }
                else {
                    var id = item_xml.getAttribute("id");
                    if (id != null) {
                        item.ID = id;
                        if (!isNaN(Number(id)) &&
                            Number(id) >= A4Object.s_nextID)
                            A4Object.s_nextID = Number(id) + 1;
                    }
                    item.loadObjectAdditionalContent(item_xml, game, of, objectsToRevisit_xml, objsctsToRevisit_object);
                    this.addObjectToInventory(item, game);
                }
            }
        }
        // check if the character is in a vehicle or bed:
        var attributes_xml = getElementChildrenByTag(xml, "attribute");
        for (var i = 0; i < attributes_xml.length; i++) {
            var attribute_xml = attributes_xml[i];
            if (attribute_xml.getAttribute("name") == "vehicle") {
                objectsToRevisit_xml.push(xml);
                objsctsToRevisit_object.push(this);
                break;
            }
            if (attribute_xml.getAttribute("name") == "sleepingInBed") {
                objectsToRevisit_xml.push(xml);
                objsctsToRevisit_object.push(this);
                break;
            }
        }
    };
    A4Character.prototype.loadObjectAttribute = function (attribute_xml) {
        if (_super.prototype.loadObjectAttribute.call(this, attribute_xml))
            return true;
        var a_name = attribute_xml.getAttribute("name");
        if (a_name == "vehicle") {
            // this is loaded in "revisitObject"
            return true;
        }
        else if (a_name == "sleepingInBed") {
            // this is loaded in "revisitObject"
            return true;
        }
        else if (a_name == "hungerTimer") {
            this.hungerTimer = Number(attribute_xml.getAttribute("value"));
            return true;
        }
        else if (a_name == "thirstTimer") {
            this.thirstTimer = Number(attribute_xml.getAttribute("value"));
            return true;
        }
        else if (a_name == "strength") {
            this.strength = Number(attribute_xml.getAttribute("value"));
            return true;
        }
        return false;
    };
    A4Character.prototype.revisitObject = function (xml, game) {
        _super.prototype.revisitObject.call(this, xml, game);
        var attributes_xml = getElementChildrenByTag(xml, "attribute");
        for (var _i = 0, attributes_xml_1 = attributes_xml; _i < attributes_xml_1.length; _i++) {
            var attribute_xml = attributes_xml_1[_i];
            var a_name = attribute_xml.getAttribute("name");
            if (a_name == "vehicle") {
                var o_ID = attribute_xml.getAttribute("value");
                var tmp = game.findObjectByIDJustObject(o_ID);
                if (tmp == null) {
                    console.error("Revisiting A4Character, and cannot find object with ID " + o_ID);
                }
                else {
                    var o = tmp;
                    this.vehicle = o;
                }
                break;
            }
            else if (a_name == "sleepingInBed") {
                var o_ID = attribute_xml.getAttribute("value");
                var tmp = game.findObjectByIDJustObject(o_ID);
                if (tmp == null) {
                    console.error("Revisiting A4Character, and cannot find object with ID " + o_ID);
                }
                else {
                    this.sleepingInBed = tmp;
                    this.sleepingInBed.setStoryStateVariable("characterIn", "true", game);
                }
                break;
            }
        }
    };
    A4Character.prototype.savePropertiesToXML = function (game) {
        var xmlString = _super.prototype.savePropertiesToXML.call(this, game);
        if (this.vehicle != null)
            xmlString += this.saveObjectAttributeToXML("vehicle", this.vehicle.ID) + "\n";
        if (this.sleepingInBed != null)
            xmlString += this.saveObjectAttributeToXML("sleepingInBed", this.sleepingInBed.ID) + "\n";
        xmlString += this.saveObjectAttributeToXML("hungerTimer", this.hungerTimer) + "\n";
        xmlString += this.saveObjectAttributeToXML("thirstTimer", this.thirstTimer) + "\n";
        xmlString += this.saveObjectAttributeToXML("strength", this.strength) + "\n";
        if (this.inventory.length > 0) {
            xmlString += "<items>\n";
            for (var _i = 0, _a = this.inventory; _i < _a.length; _i++) {
                var o = _a[_i];
                xmlString += o.saveToXML(game, 0, false) + "\n";
            }
            xmlString += "</items>\n";
        }
        return xmlString;
    };
    A4Character.prototype.update = function (game) {
        var ret = _super.prototype.update.call(this, game);
        this.hungerTimer++;
        this.thirstTimer++;
        // update the inventory items:
        for (var _i = 0, _a = this.inventory; _i < _a.length; _i++) {
            var o = _a[_i];
            o.update(game);
        }
        var max_movement_pixels_requested = 0;
        // direction control:
        for (var i = 0; i < A4_NDIRECTIONS; i++) {
            if (this.direction_command_received_this_cycle[i]) {
                this.continuous_direction_command_timers[i]++;
            }
            else {
                this.continuous_direction_command_timers[i] = 0;
            }
        }
        if (this.state == A4CHARACTER_STATE_IDLE) {
            var most_recent_viable_walk_command = A4_DIRECTION_NONE;
            var timer = 0;
            for (var i = 0; i < A4_NDIRECTIONS; i++) {
                if (this.direction_command_received_this_cycle[i]) { //} && this.canMove(i, false)) {
                    if (most_recent_viable_walk_command == A4_DIRECTION_NONE ||
                        this.continuous_direction_command_timers[i] < timer) {
                        most_recent_viable_walk_command = i;
                        timer = this.continuous_direction_command_timers[i];
                    }
                }
            }
            if (most_recent_viable_walk_command != A4_DIRECTION_NONE) {
                this.state = A4CHARACTER_STATE_WALKING;
                this.direction = most_recent_viable_walk_command;
                max_movement_pixels_requested = this.continuous_direction_command_max_movement[most_recent_viable_walk_command];
            }
        }
        for (var i = 0; i < A4_NDIRECTIONS; i++)
            this.direction_command_received_this_cycle[i] = false;
        if (this.state != this.previousState || this.direction != this.previousDirection)
            this.stateCycle = 0;
        this.previousState = this.state;
        this.previousDirection = this.direction;
        switch (this.state) {
            case A4CHARACTER_STATE_IDLE:
                if (this.stateCycle == 0) {
                    if (this.animations[A4_ANIMATION_IDLE_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                    }
                    else {
                        this.currentAnimation = A4_ANIMATION_IDLE;
                    }
                    this.animations[this.currentAnimation].reset();
                }
                else {
                    //                    this.animations[this.currentAnimation].update();
                }
                this.stateCycle++;
                break;
            case A4CHARACTER_STATE_WALKING:
                {
                    if (this.stateCycle == 0) {
                        if (this.animations[A4_ANIMATION_MOVING_LEFT + this.direction] != null) {
                            this.currentAnimation = A4_ANIMATION_MOVING_LEFT + this.direction;
                        }
                        else if (this.animations[A4_ANIMATION_MOVING] != null) {
                            this.currentAnimation = A4_ANIMATION_MOVING;
                        }
                        else if (this.animations[A4_ANIMATION_IDLE_LEFT + this.direction] != null) {
                            this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                        }
                        else {
                            this.currentAnimation = A4_ANIMATION_IDLE;
                        }
                        this.animations[this.currentAnimation].reset();
                    }
                    else {
                        //                        this.animations[this.currentAnimation].update();
                    }
                    if ((this.x % this.map.tileWidth == 0) && (this.y % this.map.tileHeight == 0)) {
                        var bridge_1 = null;
                        if (!this.canMove(this.direction, false) ||
                            (this.y <= 0 && this.direction == A4_DIRECTION_UP) ||
                            (this.x <= 0 && this.direction == A4_DIRECTION_LEFT)) {
                            this.state = A4CHARACTER_STATE_IDLE;
                            this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                            this.animations[this.currentAnimation].reset();
                            bridge_1 = this.checkIfPushingAgainstMapEdgeBridge(this.direction);
                            if (bridge_1 == null)
                                break;
                        }
                        // check if we are pushing against the edge of a map with a "bridge":
                        if (bridge_1 == null)
                            bridge_1 = this.checkIfPushingAgainstMapEdgeBridge(this.direction);
                        if (bridge_1 != null) {
                            // teleport!
                            var target = bridge_1.linkedTo.findAvailableTargetLocation(this, this.map.tileWidth, this.map.tileHeight);
                            if (target != null) {
                                if (game.checkPermissionToWarp(this, bridge_1.linkedTo.map)) {
                                    game.requestWarp(this, bridge_1.linkedTo.map, target[0], target[1]);
                                }
                            }
                            else {
                                if (this == game.currentPlayer)
                                    game.addMessage("Something is blocking the way!");
                            }
                            break;
                        }
                    }
                    this.stateCycle++;
                    // the following kind of messy code just makes characters walk at the proper speed
                    // it follows the idea of Bresenham's algorithms for proportionally scaling the speed of
                    // the characters without using any floating point calculations.
                    // it also makes the character move sideways a bit, if they need to align to fit through a corridor
                    var step = game.tileWidth;
                    if (this.direction == A4_DIRECTION_UP || this.direction == A4_DIRECTION_DOWN)
                        step = game.tileHeight;
                    var bridge = null;
                    var pixelsMoved = 0;
                    while (this.walkingCounter <= step) {
                        var dir = this.direction;
                        this.x += direction_x_inc[dir];
                        this.y += direction_y_inc[dir];
                        this.walkingCounter += this.getWalkSpeed();
                        pixelsMoved++;
                        if ((this.x % game.tileWidth) == 0 && (this.y % game.tileHeight) == 0) {
                            this.state = A4CHARACTER_STATE_IDLE;
                            this.walkingCounter = 0;
                            bridge = this.map.getBridge(this.x + this.getPixelWidth() / 2, this.y + this.getPixelHeight() / 2);
                            if (bridge != null) {
                                // if we enter a bridge, but it's not with the first pixel we moved, then stop and do not go through the bridge,
                                // to give the AI a chance to decide whether to go through the bridge or not
                                if (pixelsMoved > 1) {
                                    this.x -= direction_x_inc[dir];
                                    this.y -= direction_y_inc[dir];
                                    bridge = null;
                                }
                                break;
                            }
                        }
                        // walk in blocks of a tile wide:
                        if (direction_x_inc[dir] != 0 && (this.x % game.tileWidth) == 0) {
                            this.walkingCounter = 0;
                            break;
                        }
                        if (direction_y_inc[dir] != 0 && (this.y % game.tileHeight) == 0) {
                            this.walkingCounter = 0;
                            break;
                        }
                        if (max_movement_pixels_requested > 0) {
                            max_movement_pixels_requested--;
                            if (max_movement_pixels_requested <= 0)
                                break;
                        }
                        if ((this.x % game.tileWidth) == 0 && (this.y % game.tileHeight) == 0)
                            break;
                    }
                    if (this.walkingCounter >= step)
                        this.walkingCounter -= step;
                    if (bridge != null) {
                        // teleport!
                        var target = bridge.linkedTo.findAvailableTargetLocation(this, this.map.tileWidth, this.map.tileHeight);
                        if (target != null) {
                            if (game.checkPermissionToWarp(this, bridge.linkedTo.map)) {
                                game.requestWarp(this, bridge.linkedTo.map, target[0], target[1]); //, this.layer);
                            }
                        }
                        else {
                            if (this == game.currentPlayer)
                                game.addMessage("Something is blocking the way!");
                        }
                    }
                    break;
                }
            case A4CHARACTER_STATE_INTERACTING:
                if (this.stateCycle == 0) {
                    if (this.animations[A4_ANIMATION_INTERACTING_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_INTERACTING_LEFT + this.direction;
                    }
                    else if (this.animations[A4_ANIMATION_INTERACTING] != null) {
                        this.currentAnimation = A4_ANIMATION_INTERACTING;
                    }
                    else if (this.animations[A4_ANIMATION_IDLE_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                    }
                    else {
                        this.currentAnimation = A4_ANIMATION_IDLE;
                    }
                    this.animations[this.currentAnimation].reset();
                }
                else {
                    //                    this.animations[this.currentAnimation].update();
                }
                this.stateCycle++;
                if (this.stateCycle >= this.getWalkSpeed()) {
                    this.state = A4CHARACTER_STATE_IDLE;
                }
                break;
            case A4CHARACTER_STATE_DYING:
                if (this.stateCycle == 0) {
                    if (this.animations[A4_ANIMATION_DEATH_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_DEATH_LEFT + this.direction;
                    }
                    else if (this.animations[A4_ANIMATION_DEATH] != null) {
                        this.currentAnimation = A4_ANIMATION_DEATH;
                    }
                    else if (this.animations[A4_ANIMATION_IDLE_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                    }
                    else {
                        this.currentAnimation = A4_ANIMATION_IDLE;
                    }
                    this.animations[this.currentAnimation].reset();
                }
                else {
                    //                this.animations[this.currentAnimation].update();
                }
                this.stateCycle++;
                if (this.stateCycle >= this.getWalkSpeed()) {
                    // drop all the items:
                    for (var _b = 0, _c = this.inventory; _b < _c.length; _b++) {
                        var o = _c[_b];
                        game.requestWarp(o, this.map, this.x, this.y); //, A4_LAYER_FG);
                        o.event(A4_EVENT_DROP, null, this.map, game); // pass 'null' as the character, since this character is dead
                    }
                    this.inventory = [];
                    return false;
                }
                break;
            case A4CHARACTER_STATE_IN_VEHICLE:
                if (this.map != this.vehicle.map) {
                    game.requestWarp(this, this.vehicle.map, this.vehicle.x, this.vehicle.y); //, this.layer);
                }
                else {
                    this.x = this.vehicle.x;
                    this.y = this.vehicle.y;
                }
                break;
            case A4CHARACTER_STATE_TALKING:
                if (this.stateCycle == 0) {
                    if (this.animations[A4_ANIMATION_TALKING_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_TALKING_LEFT + this.direction;
                    }
                    else if (this.animations[A4_ANIMATION_TALKING] != null) {
                        this.currentAnimation = A4_ANIMATION_TALKING;
                    }
                    else if (this.animations[A4_ANIMATION_IDLE_LEFT + this.direction] != null) {
                        this.currentAnimation = A4_ANIMATION_IDLE_LEFT + this.direction;
                    }
                    else {
                        this.currentAnimation = A4_ANIMATION_IDLE;
                    }
                    this.animations[this.currentAnimation].reset();
                    //                    console.log("animation due to talking: " + this.currentAnimation);
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor(">" + this.talkingText, MSX_COLOR_LIGHT_GREEN);
                        }
                        else {
                            game.addMessageWithColor(this.name + ": " + this.talkingText, MSX_COLOR_WHITE);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    if (this.map == game.currentPlayer.map) {
                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("talk", this.ID, this.sort, null, null, this.talkingText, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                    }
                    /*
                    if (this.talkingTarget!=null && game.contains(this.talkingTarget)) {
                        this.talkingTarget.receiveSpeechAct(this, this.talkingTarget, this.talkingSpeechAct);
                        this.receiveSpeechAct(this, this.talkingTarget, this.talkingSpeechAct);
                    }
                    */
                    // after the speech bubble is done, we record it in the map:
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IDLE;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_THOUGHT_BUBBLE:
                if (this.stateCycle == 0) {
                    this.currentAnimation = A4_ANIMATION_IDLE;
                    if (this == game.currentPlayer) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor("(" + this.talkingText + ")", MSX_COLOR_GREEN);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IDLE;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_BED:
            case A4CHARACTER_STATE_IN_BED_CANNOT_GETUP:
                break;
            case A4CHARACTER_STATE_IN_BED_TALKING:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor(">" + this.talkingText, MSX_COLOR_LIGHT_GREEN);
                        }
                        else {
                            game.addMessageWithColor(this.name + ": " + this.talkingText, MSX_COLOR_WHITE);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    // after the speech bubble is done, we record it in the map:
                    if (this.map == game.currentPlayer.map) {
                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("talk", this.ID, this.sort, null, null, this.talkingText, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                    }
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.state = A4CHARACTER_STATE_IN_BED;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_TALKING:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor(">" + this.talkingText, MSX_COLOR_LIGHT_GREEN);
                        }
                        else {
                            game.addMessageWithColor(this.name + ": " + this.talkingText, MSX_COLOR_WHITE);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    // after the speech bubble is done, we record it in the map:
                    if (this.map == game.currentPlayer.map) {
                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("talk", this.ID, this.sort, null, null, this.talkingText, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                    }
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IN_BED_CANNOT_GETUP;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor("(" + this.talkingText + ")", MSX_COLOR_GREEN);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IN_BED;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor("(" + this.talkingText + ")", MSX_COLOR_GREEN);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    // after the speech bubble is done, we record it in the map:
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IN_BED_CANNOT_GETUP;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_VEHICLE_TALKING:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor(">" + this.talkingText, MSX_COLOR_LIGHT_GREEN);
                        }
                        else {
                            game.addMessageWithColor(this.name + ": " + this.talkingText, MSX_COLOR_WHITE);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    // after the speech bubble is done, we record it in the map:
                    if (this.map == game.currentPlayer.map) {
                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("talk", this.ID, this.sort, null, null, this.talkingText, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                    }
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IN_VEHICLE;
                    this.talkingTarget = null;
                }
                break;
            case A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE:
                if (this.stateCycle == 0) {
                    if (this.map == game.currentPlayer.map) {
                        if (this == (game.currentPlayer)) {
                            game.addMessageWithColor("(" + this.talkingText + ")", MSX_COLOR_GREEN);
                        }
                    }
                }
                this.stateCycle++;
                if (this.stateCycle >= this.talkingBubbleDuration) {
                    this.talkingText = null;
                    this.talkingBubble = null;
                    this.talkingBubbleDuration = 0;
                    this.state = A4CHARACTER_STATE_IN_VEHICLE;
                    this.talkingTarget = null;
                }
                break;
        }
        return ret;
    };
    A4Character.prototype.draw = function (offsetx, offsety, game) {
        // when character is sleeping, the grapic is displayed by the bed itself, so, no need to draw:
        if (!this.isInVehicle() &&
            this.state != A4CHARACTER_STATE_IN_BED &&
            this.state != A4CHARACTER_STATE_IN_BED_CANNOT_GETUP &&
            this.state != A4CHARACTER_STATE_IN_BED_TALKING &&
            this.state != A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_TALKING &&
            this.state != A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE &&
            this.state != A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE) {
            _super.prototype.draw.call(this, offsetx, offsety, game);
        }
    };
    A4Character.prototype.drawTextBubbles = function (offsetx, offsety, screenWidth, screenHeight, game) {
        if (this.talkingBubble != null &&
            this.stateCycle < this.talkingBubbleDuration - 15) {
            var focus_1 = this;
            if (this.sleepingInBed != null)
                focus_1 = this.sleepingInBed;
            var px = Math.floor(focus_1.x + offsetx + focus_1.getPixelWidth() / 2);
            var bx = Math.floor(px - this.talkingBubble.width / 2);
            if (bx < 0)
                bx = 0;
            if (bx + this.talkingBubble.width >= screenWidth)
                bx = screenWidth - this.talkingBubble.width;
            var py = (focus_1.y + offsety - focus_1.pixel_tallness);
            var by = py - (8 + this.talkingBubble.height);
            //            console.log("drawTextBubbles: " + by + " vs " + screenHeight);
            if (by < 0 || py < screenHeight / 3) {
                py = focus_1.y + offsety + focus_1.getPixelHeight();
                by = py + 8;
            }
            var f = 1;
            var fade_speed = 15;
            if (this.stateCycle < fade_speed)
                f = this.stateCycle / fade_speed;
            var limit = Math.floor(this.talkingBubbleDuration);
            if (this.stateCycle > limit - fade_speed)
                f = (limit - this.stateCycle) / fade_speed;
            if (f < 0)
                f = 0;
            if (f > 1)
                f = 1;
            this.talkingBubble.draw(bx, by, px, py, this.state == A4CHARACTER_STATE_THOUGHT_BUBBLE ||
                this.state == A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE ||
                this.state == A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE, f);
        }
    };
    A4Character.prototype.isIdle = function () {
        if (this.vehicle == null) {
            return this.state == A4CHARACTER_STATE_IDLE;
        }
        else {
            return this.state == A4CHARACTER_STATE_IN_VEHICLE && this.vehicle.state == A4CHARACTER_STATE_IDLE;
        }
    };
    A4Character.prototype.isTalking = function () {
        return this.state == A4CHARACTER_STATE_TALKING ||
            this.state == A4CHARACTER_STATE_IN_BED_TALKING ||
            this.state == A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_TALKING ||
            this.state == A4CHARACTER_STATE_THOUGHT_BUBBLE ||
            this.state == A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE ||
            this.state == A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE ||
            this.state == A4CHARACTER_STATE_IN_VEHICLE_TALKING ||
            this.state == A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE;
    };
    A4Character.prototype.issueCommand = function (command, game) {
        if (command.text != null) {
            this.issueCommandWithString(command.command, command.text, command.direction, game);
        }
        else {
            this.issueCommandWithArguments(command.command, command.argument, command.direction, command.target, game);
        }
    };
    //	issueCommandWithSpeechAct(command:number, argument:SpeechAct, direction:number, target:A4Character, game:A4Game)
    A4Character.prototype.issueCommandWithString = function (command, argument, direction, game) {
        if (this.state != A4CHARACTER_STATE_IDLE &&
            this.state != A4CHARACTER_STATE_IN_BED &&
            this.state != A4CHARACTER_STATE_IN_BED_CANNOT_GETUP &&
            this.state != A4CHARACTER_STATE_IN_VEHICLE)
            return false;
        switch (command) {
            case A4CHARACTER_COMMAND_TALK:
            case A4CHARACTER_COMMAND_THOUGHT_BUBBLE:
                {
                    this.talkingText = argument;
                    if (this.talkingText != null) {
                        this.talkingBubble = new A4TextBubble(this.talkingText, 24, fontFamily8px, 6, 8, game, this);
                        if (game.debugTextBubbleLog != null) {
                            game.debugTextBubbleLog.push([game.cycle, this.ID, this.talkingBubble]);
                        }
                        if (game.drawTextBubbles) {
                            this.talkingBubbleDuration = TEXT_INITIAL_DELAY + this.talkingText.length * TEXT_SPEED;
                        }
                        else {
                            // if we are not drawing them, make it faster:
                            this.talkingBubbleDuration = (TEXT_INITIAL_DELAY + this.talkingText.length * TEXT_SPEED) / 2;
                        }
                        //                this.talkingTarget = target;
                        if (this.state == A4CHARACTER_STATE_IDLE) {
                            if (command == A4CHARACTER_COMMAND_TALK) {
                                this.state = A4CHARACTER_STATE_TALKING;
                            }
                            else {
                                this.state = A4CHARACTER_STATE_THOUGHT_BUBBLE;
                            }
                        }
                        else if (this.state == A4CHARACTER_STATE_IN_BED) {
                            if (command == A4CHARACTER_COMMAND_TALK) {
                                this.state = A4CHARACTER_STATE_IN_BED_TALKING;
                            }
                            else {
                                this.state = A4CHARACTER_STATE_IN_BED_THOUGHT_BUBBLE;
                            }
                        }
                        else if (this.state == A4CHARACTER_STATE_IN_BED_CANNOT_GETUP) {
                            if (command == A4CHARACTER_COMMAND_TALK) {
                                this.state = A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_TALKING;
                            }
                            else {
                                this.state = A4CHARACTER_STATE_IN_BED_CANNOT_GETUP_THOUGHT_BUBBLE;
                            }
                        }
                        else if (this.state == A4CHARACTER_STATE_IN_VEHICLE) {
                            if (command == A4CHARACTER_COMMAND_TALK) {
                                this.state = A4CHARACTER_STATE_IN_VEHICLE_TALKING;
                            }
                            else {
                                this.state = A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE;
                            }
                        }
                        this.stateCycle = 0;
                    }
                    else {
                        console.error("issueCommandWithString: this.talkingText = " + this.talkingText);
                    }
                    return true;
                }
        }
        return false;
    };
    A4Character.prototype.issueCommandWithArguments = function (command, argument, direction, target, game) {
        //console.log("issueCommandWithArguments: " + command);
        if (this.state == A4CHARACTER_STATE_IN_VEHICLE) {
            if (command == A4CHARACTER_COMMAND_WALK ||
                command == A4CHARACTER_COMMAND_INTERACT) {
                this.vehicle.issueCommand(command, argument, direction, target, game);
                return;
            }
            else {
                if (command != A4CHARACTER_COMMAND_TAKE)
                    return;
            }
        }
        else {
            if (this.state == A4CHARACTER_STATE_IN_BED) {
                if (command != A4CHARACTER_COMMAND_TAKE &&
                    command != A4CHARACTER_COMMAND_WALK)
                    return;
            }
            else {
                if (this.state != A4CHARACTER_STATE_IDLE)
                    return;
            }
        }
        //        console.log("issueCommandWithArguments: " + command);
        switch (command) {
            case A4CHARACTER_COMMAND_IDLE:
                break;
            case A4CHARACTER_COMMAND_WALK:
                if (this.state == A4CHARACTER_STATE_IN_BED) {
                    this.getOutOfBed(game);
                }
                else {
                    //<shrdluSpecific>
                    // When a player is interacting with a container, but decides to walk away,
                    // we need to close the split inventory screen
                    if (this == game.currentPlayer &&
                        game.HUD_state == SHRDLU_HUD_STATE_SPLIT_INVENTORY) {
                        game.HUD_state = SHRDLU_HUD_STATE_INVENTORY;
                        game.HUD_remote_inventory = null;
                    }
                    //</shrdluSpecific>
                    this.direction_command_received_this_cycle[direction] = true;
                    this.continuous_direction_command_max_movement[direction] = argument;
                }
                break;
            case A4CHARACTER_COMMAND_TAKE:
                {
                    if (this.isInVehicle()) {
                        // Humans can only get out of vehicles if they have a spacesuit:
                        if (this.sort.is_a_string("human")) {
                            var helmet = null;
                            var suit = null;
                            for (var _i = 0, _a = game.currentPlayer.inventory; _i < _a.length; _i++) {
                                var item = _a[_i];
                                if (item.sort.is_a_string("helmet"))
                                    helmet = item;
                                if (item.sort.is_a_string("workingspacesuit"))
                                    suit = item;
                            }
                            if (helmet != null && suit != null) {
                                helmet.droppable = false;
                                suit.droppable = false;
                                game.setStoryStateVariable("spacesuit", "helmet");
                            }
                            else {
                                this.issueCommandWithString(A4CHARACTER_COMMAND_THOUGHT_BUBBLE, "I am not going out there without a spacesuit!!", A4_DIRECTION_NONE, game);
                                break;
                            }
                        }
                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("disembark", this.ID, this.sort, this.vehicle.ID, this.vehicle.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                        var vehicle = this.vehicle;
                        if (this.disembark()) {
                            game.inGameActionsForLog.push(["disembark(" + this.ID + "," + vehicle.ID + ")", "" + game.in_game_seconds]);
                        }
                    }
                    else {
                        if (this.state == A4CHARACTER_STATE_IN_BED) {
                            this.getOutOfBed(game);
                        }
                        else {
                            if (!this.takeAction(game)) {
                                if (!this.useAction(game)) {
                                    /*
                                    // see if there is a vehicle:
                                    let v:A4Object = this.map.getVehicleObject(this.x + this.getPixelWidth()/2 - 1, this.y + this.getPixelHeight()/2 - 1, 2, 2);
                                    if (v!=null) {
                                        this.embark(<A4Vehicle>v);
                                        this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("embark", this.ID, this.sort,
                                                                                                      v.ID, v.sort, null,
                                                                                                      null, null,
                                                                                                      this.x, this.y, this.x+this.getPixelWidth(), this.y+this.getPixelHeight()));
                                        game.inGameActionsForLog.push(["embark("+this.ID+","+v.ID+")",""+game.in_game_seconds]);
                                    } else {
                                    */
                                    // interact with the object in front:
                                    this.issueCommandWithArguments(A4CHARACTER_COMMAND_INTERACT, A4_DIRECTION_NONE, direction, null, game);
                                    //}
                                }
                            }
                        }
                    }
                }
                break;
            case A4CHARACTER_COMMAND_DROP:
                {
                    var o = this.inventory[argument];
                    if (o != null) {
                        if (o.droppable) {
                            // drop:
                            this.inventory.splice(argument, 1);
                            game.requestWarp(o, this.map, this.x, this.y); //, A4_LAYER_FG);
                            this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("drop", this.ID, this.sort, o.ID, o.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                            o.event(A4_EVENT_DROP, this, this.map, game);
                            this.eventWithObject(A4_EVENT_ACTION_DROP, null, o, this.map, game);
                            game.playSound("data/sfx/itemPickup.wav");
                            game.inGameActionsForLog.push(["drop(" + this.ID + "," + o.ID + ")", "" + game.in_game_seconds]);
                        }
                    }
                }
                break;
            case A4CHARACTER_COMMAND_USE:
                {
                    var o = this.inventory[argument];
                    if (o != null) {
                        if (o.usable) {
                            o.event(A4_EVENT_USE, this, this.map, game);
                            this.eventWithObject(A4_EVENT_ACTION_USE, null, o, this.map, game);
                            game.inGameActionsForLog.push(["use(" + this.ID + "," + o.ID + ")", "" + game.in_game_seconds]);
                        }
                    }
                }
                break;
            case A4CHARACTER_COMMAND_INTERACT:
                {
                    // get the object to interact with:
                    var collisions = this.map.getAllObjectCollisionsOnlyWithOffset(this, direction_x_inc[direction], direction_y_inc[direction]);
                    if (collisions == null || collisions.length == 0)
                        collisions = this.map.getAllObjectCollisionsWithOffset(this, direction_x_inc[direction], direction_y_inc[direction]);
                    //                    console.log("Character received the interact command for direction " + direction + " resulting in " + collisions.length + " collisions");
                    for (var _b = 0, collisions_1 = collisions; _b < collisions_1.length; _b++) {
                        var o = collisions_1[_b];
                        //                        console.log("considering " + o.name);
                        if (o.interacteable) {
                            if ((o instanceof A4Character) && o.isInVehicle())
                                continue;
                            //                            console.log(o.name + " is interacteable!");
                            // interact:
                            this.direction = direction;
                            this.state = A4CHARACTER_STATE_INTERACTING;
                            this.stateCycle = 0;
                            this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("interact", this.ID, this.sort, o.ID, o.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                            o.event(A4_EVENT_INTERACT, this, this.map, game);
                            this.eventWithObject(A4_EVENT_ACTION_INTERACT, null, o, this.map, game);
                            game.inGameActionsForLog.push(["interact(" + this.ID + "," + o.ID + ")", "" + game.in_game_seconds]);
                            break;
                        }
                    }
                    // just default to a walk:
                    //this.issueCommandWithArguments(A4CHARACTER_COMMAND_WALK, argument, direction, target, game);
                }
                break;
            case A4CHARACTER_COMMAND_PUSH:
                {
                    //                    console.log("got the push command");
                    // get the object to interact with:
                    var collisions = this.map.getAllObjectCollisionsWithOffset(this, direction_x_inc[direction], direction_y_inc[direction]);
                    for (var _c = 0, collisions_2 = collisions; _c < collisions_2.length; _c++) {
                        var o = collisions_2[_c];
                        //                        console.log("checking object " + o.name);
                        if (o.isPushable()) {
                            this.pushAction(o, argument, game);
                            break;
                        }
                    }
                }
                break;
            case A4CHARACTER_COMMAND_GIVE:
                {
                    var item_to_give = this.inventory[argument];
                    var item_weight = 1;
                    if (item_to_give == null) {
                        // error!
                        console.error("Character " + this.name + " trying to give item " + argument + ", which it does not have...");
                    }
                    else {
                        var x2 = target.x + target.getPixelWidth() / 2;
                        var y2 = target.y + target.getPixelHeight() / 2;
                        var dx = Math.floor((this.x + this.getPixelWidth() / 2) - x2);
                        var dy = Math.floor((this.y + this.getPixelHeight() / 2) - y2);
                        var d_1 = dx * dx + dy * dy;
                        var maxd = Math.max(game.tileWidth, game.tileHeight) * 5;
                        if (d_1 > maxd * maxd) {
                            // too far!
                            console.log("Character " + this.name + " trying to give item " + argument + " to a character that is too far...");
                            //                            if (this == <A4Character>game.currentPlayer) game.addMessageWithOriginator(this, "I need to get closer!");
                        }
                        else {
                            var target_c = target;
                            if (item_to_give instanceof A4Item) {
                                item_weight = item_to_give.weight;
                            }
                            if (target_c.inventory.length >= A4_INVENTORY_SIZE) {
                                //                                if (this == <A4Character>game.currentPlayer) game.addMessageWithOriginator(this, "The other's inventory is full!");
                            }
                            else if (item_weight > target_c.strength) {
                                // too heavy for the receiver!
                            }
                            else {
                                // give!
                                this.inventory.splice(argument, 1);
                                target_c.addObjectToInventory(item_to_give, game);
                                //                                if (this == <A4Character>game.currentPlayer) game.addMessageWithOriginator(this, "Here, take this.");
                                this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("give", this.ID, this.sort, target_c.ID, target_c.sort, null, item_to_give.ID, item_to_give.sort, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                                target_c.eventWithObject(A4_EVENT_RECEIVE, this, item_to_give, this.map, game);
                                this.eventWithObject(A4_EVENT_ACTION_GIVE, target_c, item_to_give, this.map, game);
                                game.playSound("data/sfx/itemPickup.wav");
                                game.inGameActionsForLog.push(["give(" + this.ID + "," + item_to_give.ID + "," + target_c.ID + ")", "" + game.in_game_seconds]);
                            }
                        }
                    }
                }
                break;
        }
    };
    A4Character.prototype.pushAction = function (o, direction, game) {
        if (this.strength >= o.weight) {
            //                            console.log("object " + o.name + " is pushable");
            this.direction = direction;
            this.state = A4CHARACTER_STATE_WALKING;
            this.stateCycle = 0;
            this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("push", this.ID, this.sort, o.ID, o.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
            if (!o.event(A4_EVENT_PUSH, this, this.map, game))
                return false;
            this.eventWithObject(A4_EVENT_ACTION_INTERACT, null, o, this.map, game);
            game.inGameActionsForLog.push(["push(" + this.ID + "," + o.ID + ")", "" + game.in_game_seconds]);
            return true;
        }
        else {
            if (this == game.currentPlayer) {
                this.issueCommandWithString(A4CHARACTER_COMMAND_THOUGHT_BUBBLE, "too heavy for me, I'd need to get a robot to move this!!", A4_DIRECTION_NONE, game);
            }
            else if (this.name == "Shrdlu") {
                this.issueCommandWithString(A4CHARACTER_COMMAND_TALK, "I do not have energy for moving the huge boulder. Please bring me to Aurora Station.", A4_DIRECTION_NONE, game);
            }
            return false;
        }
    };
    A4Character.prototype.takeAction = function (game) {
        var item = this.map.getTakeableObject(this.x + this.getPixelWidth() / 2 - 1, this.y + this.getPixelHeight() / 2 - 1, 2, 2);
        if (item == null) {
            // no item under the player, check to see if there is something right in front:
            var collisions = this.map.getAllObjectCollisionsWithOffset(this, direction_x_inc[this.direction], direction_y_inc[this.direction]);
            for (var _i = 0, collisions_3 = collisions; _i < collisions_3.length; _i++) {
                var o = collisions_3[_i];
                if (o.takeable) {
                    item = o;
                    break;
                }
            }
        }
        if (item != null) {
            var weight = 0;
            if (item instanceof A4Item) {
                weight = item.weight;
            }
            if (weight > this.strength) {
                // if (this == <A4Character>game.currentPlayer) game.addMessageWithOriginator(this, "Too heavy!");
                return false;
            }
            else if (this.inventory.length < A4_INVENTORY_SIZE) {
                game.requestWarp(item, null, 0, 0); //, 0);
                this.addObjectToInventory(item, game);
                this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("take", this.ID, this.sort, item.ID, item.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
                item.event(A4_EVENT_PICKUP, this, this.map, game);
                this.eventWithObject(A4_EVENT_ACTION_TAKE, null, item, this.map, game);
                game.playSound("data/sfx/itemPickup.wav");
                game.inGameActionsForLog.push(["take(" + this.ID + "," + item.ID + ")", "" + game.in_game_seconds]);
                return true;
            }
            else {
                if (this == game.currentPlayer)
                    game.addMessageWithOriginator(this, "Inventory full!");
                return false;
            }
        }
        return false;
    };
    A4Character.prototype.useAction = function (game) {
        var object = this.map.getUsableObject(this.x + this.getPixelWidth() / 2 - 1, this.y + this.getPixelHeight() / 2 - 1, 2, 2);
        if (object != null) {
            //console.log("useAction on " + object.name);
            this.state = A4CHARACTER_STATE_INTERACTING;
            this.map.addPerceptionBufferRecord(new PerceptionBufferRecord("interact", this.ID, this.sort, object.ID, object.sort, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight()));
            object.event(A4_EVENT_USE, this, this.map, game);
            this.eventWithObject(A4_EVENT_ACTION_USE, null, object, this.map, game);
            game.inGameActionsForLog.push(["interact(" + this.ID + "," + object.ID + ")", "" + game.in_game_seconds]);
            return true;
        }
        return false;
    };
    // embark/disembark vehicles:
    A4Character.prototype.embark = function (v) {
        this.vehicle = v;
        this.vehicle.embark(this);
        if (this.state == A4CHARACTER_STATE_TALKING) {
            this.state = A4CHARACTER_STATE_IN_VEHICLE_TALKING;
        }
        else if (this.state == A4CHARACTER_STATE_THOUGHT_BUBBLE) {
            this.state = A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE;
        }
        else {
            this.talkingText = null;
            this.talkingBubble = null;
            this.state = A4CHARACTER_STATE_IN_VEHICLE;
            this.stateCycle = 0;
        }
    };
    A4Character.prototype.disembark = function () {
        // 1) find a non-colliding position around the vehicle:
        var best_x, best_y;
        var best_d = null;
        var cx = this.vehicle.x + this.vehicle.getPixelWidth() / 2;
        var cy = this.vehicle.y + this.vehicle.getPixelHeight() / 2;
        var ccx = this.getPixelWidth() / 2;
        var ccy = this.getPixelHeight() / 2;
        for (var y = this.vehicle.y - this.getPixelHeight(); y < this.vehicle.y + this.vehicle.getPixelHeight() + this.getPixelHeight(); y += this.map.tileHeight) {
            for (var x = this.vehicle.x - this.getPixelWidth(); x < this.vehicle.x + this.vehicle.getPixelWidth() + this.getPixelWidth(); x += this.map.tileWidth) {
                if (this.map.walkable(x, y, this.getPixelWidth(), this.getPixelHeight(), this)) {
                    var d_2 = Math.abs(x + ccx - cx) + Math.abs(y + ccy - cy);
                    if (best_d == null || d_2 < best_d) {
                        best_d = d_2;
                        best_x = x;
                        best_y = y;
                    }
                }
            }
        }
        if (best_d != null) {
            if (this.vehicle != null)
                this.vehicle.disembark(this);
            this.x = best_x;
            this.y = best_y;
            if (this.state == A4CHARACTER_STATE_IN_VEHICLE_TALKING) {
                this.state = A4CHARACTER_STATE_TALKING;
            }
            else if (this.state == A4CHARACTER_STATE_IN_VEHICLE_THOUGHT_BUBBLE) {
                this.state = A4CHARACTER_STATE_THOUGHT_BUBBLE;
            }
            else {
                this.talkingText = null;
                this.talkingBubble = null;
                this.state = A4CHARACTER_STATE_IDLE;
                this.stateCycle = 0;
            }
            this.vehicle = null;
            return true;
        }
        return false;
    };
    A4Character.prototype.getInBed = function (b, game) {
        this.sleepingInBed = b;
        this.state = A4CHARACTER_STATE_IN_BED;
        this.stateCycle = 0;
        this.sleepingInBed.setStoryStateVariable("characterIn", "true", game);
    };
    A4Character.prototype.getOutOfBed = function (game) {
        this.sleepingInBed.setStoryStateVariable("characterIn", "false", game);
        this.sleepingInBed = null;
        this.state = A4CHARACTER_STATE_IDLE;
        this.stateCycle = 0;
    };
    A4Character.prototype.isInVehicle = function () {
        if (this.vehicle != null)
            return true;
        return false;
    };
    A4Character.prototype.addObjectToInventory = function (o, game) {
        if (this.inventory.length >= A4_INVENTORY_SIZE) {
            game.requestWarp(o, this.map, this.x, this.y); //, A4_LAYER_FG);
            o.event(A4_EVENT_DROP, this, this.map, game);
            var pbr = new PerceptionBufferRecord("drop", this.ID, this.sort, null, null, null, null, null, this.x, this.y, this.x + this.getPixelWidth(), this.y + this.getPixelHeight());
            pbr.directObjectID = o.ID;
            pbr.directObjectSort = o.sort;
            this.map.addPerceptionBufferRecord(pbr);
        }
        else {
            this.inventory.push(o);
        }
    };
    A4Character.prototype.removeFromInventory = function (o) {
        var idx = this.inventory.indexOf(o);
        if (idx >= 0)
            this.inventory.splice(idx, 1);
    };
    A4Character.prototype.isWalkable = function () {
        return this.isInVehicle();
    };
    A4Character.prototype.isHeavy = function () {
        return true;
    }; // this is used by pressure plates
    A4Character.prototype.isCharacter = function () {
        return true;
    };
    A4Character.prototype.findObjectByName = function (name) {
        for (var _i = 0, _a = this.inventory; _i < _a.length; _i++) {
            var o = _a[_i];
            if (o.name == name)
                return [o];
            var o2 = o.findObjectByName(name);
            if (o2 != null)
                return [o].concat(o2);
        }
        return null;
    };
    A4Character.prototype.findObjectByID = function (ID) {
        for (var _i = 0, _a = this.inventory; _i < _a.length; _i++) {
            var o = _a[_i];
            if (o.ID == ID)
                return [o];
            var o2 = o.findObjectByID(ID);
            if (o2 != null)
                return [o].concat(o2);
        }
        return null;
    };
    A4Character.prototype.hasKey = function (ID) {
        for (var _i = 0, _a = this.inventory; _i < _a.length; _i++) {
            var o = _a[_i];
            if ((o instanceof A4Key) &&
                o.keyID == ID)
                return true;
        }
        return false;
    };
    return A4Character;
}(A4WalkingObject));
