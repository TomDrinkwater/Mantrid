//  UserData.swift
//  Mantrid
//
//  Copyright (c) 2014 Tom Drinkwater.
//  www.tomdrinkwater.com

import Foundation

class UserData {
    ////////// BLOODY SODDING ENUMS /////////
    enum PressState : String {case PressOff = "PressOff", PressPoly = "PressPoly", PressChan = "PressChan", PressMulti = "PressMulti"}
    enum LEDModeState : String {case LedOff = "LedOff", LedRed = "LedRed", LedBoth = "LedBoth"}
    
    enum sLEDState: String { //I really hate these stupid enums!
        case Off = "Off"
        case Amber = "Amb"
        case Red = "Red"
    }
    //////// ARRAYS //////////////
    var noteLeds: [sLEDState] = [sLEDState.Red, sLEDState.Off, sLEDState.Off, sLEDState.Red, sLEDState.Off, sLEDState.Off,
        sLEDState.Amber, sLEDState.Amber, sLEDState.Off, sLEDState.Off, sLEDState.Off, sLEDState.Off]
    
    //var padLeds = [sLEDState](count: 48, repeatedValue: sLEDState.Off)    //this is used in set leds from notes but a single variable would do?
    var arbLEDs = [sLEDState](count: 48, repeatedValue: sLEDState.Off)
    var padNotes = [Int](count: 49, repeatedValue: 42)//this is recalculated on the fly, shouldn't even be in userData? MOVE
    var arbNotes = [40, 42, 44, 46, 48, 50, 52, 54, 47, 49, 51, 53, 55, 57, 59, 61, 52, 54, 56, 58, 60, 62, 64, 66, 59, 61, 63,65, 67, 69, 71, 73, 64, 66, 68, 70, 72, 74, 76, 78, 71, 73, 75, 77, 79, 81, 83, 85, 87]//equivalent to padnotes // copied to and from padnotes to actually use it, this is just the back up.
    //init to wicki a tone lower to start to be diff from iso yet not all same note

    ////// FLAGS //////////
    var settingNotes = false // should these be saved? should always be false when loading setup! MOVE
    var settingLEDs = false // MOVE to manta object?
    
    var arbNotesLayout = false
    var setLEDsArbitrary = false
    var fast = true
    var turbo = false
    
    var displayNoteNums = true
    var pressureState = PressState.PressPoly // this is the specific variable of that type being declared and initialised
    var ledModeState = LEDModeState.LedBoth
    
   //// user variables ////////
    var thin = 1
    var upRight = 7
    var upLeft = 5
    var basenote = 42//this is now a midi note number rather than a pitch class, still refers to pad 0
    var numMultiChannels = 15 //channel 16 is number 15
    //var transpose = 0
    var baseChannel = 0
    
    func exportFile() {
        var noteLedsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...11 {
            var value : sLEDState = noteLeds[i]
            noteLedsNS.append(value.rawValue)
        }
        var arbLEDsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...47 {
            var value : sLEDState = arbLEDs[i]
            arbLEDsNS.append(value.rawValue)
        }
        
        var allData = ["thin": thin,
            "upRight": upRight,
            "upLeft": upLeft,
            "basenote": basenote,
            "numMultiChannels": numMultiChannels,
            "baseChannel": baseChannel,
            "arbNotesLayout": arbNotesLayout,
            "setLEDsArbitrary": setLEDsArbitrary,
            "pressureStateNS": pressureState.rawValue,
            "ledModeStateNS": ledModeState.rawValue,
            "arbNotes": arbNotes,
            "noteLedsNS": noteLedsNS,
            "arbLEDsNS": arbLEDsNS].mutableCopy() as NSMutableDictionary
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.showsHiddenFiles = true
        let myFileTypes:NSArray = ["plist"]
        savePanel.allowedFileTypes = myFileTypes
        savePanel.allowsOtherFileTypes = false
        
        savePanel.beginWithCompletionHandler { (result: Int) -> Void in //this is a swift closure - executes only after OK button pressed
            if result == NSFileHandlingPanelOKButton {
                if let exportedFileURL = savePanel.URL {
                    allData.writeToURL(exportedFileURL, atomically:true)
                }
            }
        } // End block
        
    }//end export file

    
    func importFile() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.showsHiddenFiles = true
        openPanel.allowsMultipleSelection = false
        
        let myFileTypes:NSArray = ["plist"]
        openPanel.allowedFileTypes = myFileTypes
        openPanel.allowsOtherFileTypes = false
        openPanel.beginWithCompletionHandler { (result: Int) -> Void in //start closure
            
            if result == NSFileHandlingPanelOKButton {
                if let importedFileURL = openPanel.URL {// holds path to selected file, if there is one
                    
                    if let contentsNS = NSDictionary(contentsOfURL: importedFileURL){
                        //INTEGERS
                        if let myObject: AnyObject = contentsNS.objectForKey("thin"){
                            self.thin = myObject as Int
                            println("loaded thin = \(self.thin)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("upRight"){
                            self.upRight = myObject as Int
                            println("loaded upRight = \(self.upRight)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("upLeft"){
                            self.upLeft = myObject as Int
                            println("loaded upLeft = \(self.upLeft)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("basenote"){
                            self.basenote = myObject as Int
                            println("loaded basenote = \(self.basenote)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("numMultiChannels"){
                            self.numMultiChannels = myObject as Int
                            println("loaded numMultiChannels = \(self.numMultiChannels)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("baseChannel"){
                            self.baseChannel = myObject as Int
                            println("loaded baseChannel = \(self.baseChannel)")
                        }
                        //BOOLS
                        if let myObject: AnyObject = contentsNS.objectForKey("arbNotesLayout"){
                            self.arbNotesLayout = myObject as Bool
                            println("loaded arbNotesLayout = \(self.arbNotesLayout)")
                        }
                        if let myObject: AnyObject = contentsNS.objectForKey("setLEDsArbitrary"){
                            self.setLEDsArbitrary = myObject as Bool
                            println("loaded setLEDsArbitrary = \(self.setLEDsArbitrary)")
                        }
                        //ARRAYS
                        if let myObject: AnyObject = contentsNS.objectForKey("arbNotes"){
                            self.arbNotes = myObject as [Int]
                            println("loaded arbNotes = \(self.arbNotes)")
                        }
                        //ENUMS
                        if let ledModeStateNS: AnyObject = contentsNS.objectForKey("ledModeStateNS"){
                            let temp = ledModeStateNS as String
                            if let enumValue = LEDModeState(rawValue: temp){
                                self.ledModeState = enumValue
                                println("loaded ledModeState \(self.ledModeState.rawValue)")
                            }
                        }
                        if let pressureStateNS: AnyObject = contentsNS.objectForKey("pressureStateNS"){
                            let temp = pressureStateNS as String
                            if let enumValue = PressState(rawValue: temp){
                                self.pressureState = enumValue
                                println("loaded pressureState \(self.pressureState.rawValue)")
                            }
                        }
                        //ARRAYS OF ENUMS
                        
                        if let noteLedsNS : AnyObject? = contentsNS.objectForKey("noteLedsNS") {
                            var readArray : [String] = noteLedsNS! as [String]// convert to swift strings?
                            //println("loaded noteLedsNS \(readArray)")
                            for i in 0...11 {
                                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                                    self.noteLeds[i] = value // the if binding means don't have to unwrap with !
                                }//convert each element back to a optional swift enum
                            }
                            println("converted noteLedsNS")
                            for i in 0...11 {
                                print(" \(self.noteLeds[i].rawValue)")
                            }
                        } else {
                            println("failed to read noteLedsNS")
                        }//end load noteLeds
                        
                        
                        if let arbLEDsNS : AnyObject? = contentsNS.objectForKey("arbLEDsNS") {
                            var readArray : [String] = arbLEDsNS! as [String]// convert to swift strings?
                            //println("loaded arbLEDsNS \(readArray)")
                            for i in 0...47 {
                                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                                    self.arbLEDs[i] = value // the if binding means don't have to unwrap with !
                                }//convert each element back to a optional swift enum
                            }
                            println("converted arbLEDsNS")
                            for i in 0...47 {
                                print(" \(self.arbLEDs[i].rawValue)")
                            }
                        } else {
                            println("failed to read arbLEDsNS")
                        }//end load arbLEDs
                        
                    } //end if let contents
                    
                    //println("the loaded content is \(NSContents!)") ///\(contents)
                    println("loaded from \(importedFileURL))") /*//\(importedFileURL)*/
                    let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                    appDelegate.setViewFromModel()
                } else {
                    println("load failed");
                }
                
            }//end if result is ok button
        }//end closure
        
    }//end importfile
    
  ///////////////////////////////////////////////////////////////////////////
    
    //let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveDefaults(){
        //NSUserDefaults.resetStandardUserDefaults()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "defaultsExist")
        
        userDefaults.setInteger(thin, forKey: "thin")
        userDefaults.setInteger(upRight, forKey: "upRight")
        userDefaults.setInteger(upLeft, forKey: "upLeft")
        userDefaults.setInteger(basenote, forKey: "basenote")
        userDefaults.setInteger(numMultiChannels, forKey: "numMultiChannels")
        userDefaults.setInteger(baseChannel, forKey: "baseChannel")
        
        userDefaults.setBool(arbNotesLayout, forKey: "arbNotesLayout")
        userDefaults.setBool(setLEDsArbitrary, forKey: "setLEDsArbitrary")
        userDefaults.setBool(fast, forKey: "fast")
        userDefaults.setBool(turbo, forKey: "turbo")
        
        let arbNotesNS = arbNotes as NSArray //cast this swift array of int to NSArray
        userDefaults.setObject(arbNotesNS, forKey: "arbNotesNS")
        
        var noteLedsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...11 {
            var value : sLEDState = noteLeds[i]
            noteLedsNS.append(value.rawValue)
        }
        userDefaults.setObject(noteLedsNS, forKey: "noteLedsNS")
        
        var arbLEDsNS: [NSString] = [NSString]() //create an array of NS string with string values for swift enum.
        for i in 0...47 {
            var value : sLEDState = arbLEDs[i]
            arbLEDsNS.append(value.rawValue)
        }
        userDefaults.setObject(arbLEDsNS, forKey: "arbLEDsNS")
        
        var pressureStateNS = pressureState.rawValue as NSString
        userDefaults.setObject(pressureStateNS, forKey: "pressureStateNS")
        
        var ledModeStateNS = ledModeState.rawValue as NSString
        userDefaults.setObject(ledModeStateNS, forKey: "ledModeStateNS")
        
        //userDefaults.synchronize()
        println("saved user data")
    }//// end save /////////
    
    func testDefaults1() -> Bool{
        let defaults = NSUserDefaults.standardUserDefaults()
        let value  = defaults.boolForKey("defaultsExist")// no checking of type
        println("defaultsExist = \(value)")
        return value
    }
    
    func testDefaults() -> Bool{
        let defaults = NSUserDefaults.standardUserDefaults()
        var value: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("thin")
        
        if value != nil{
            let mythin = value!.integerValue
            print("value exists ")
            println(mythin)
            return true
        } else {
            println("value is nil")
            return false
        }
        
    }

//////////////////////////////////////////////////////////////////////////
    func loadDefaults(){
        //NSUserDefaults.resetStandardUserDefaults()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let pressureStateNS = defaults.stringForKey("pressureStateNS"){
            pressureState = PressState(rawValue: pressureStateNS)!
            //println("loaded pressureState \(pressureState.rawValue)")
        }
        
        if let ledModeStateNS = defaults.stringForKey("ledModeStateNS"){
            ledModeState = LEDModeState(rawValue: ledModeStateNS)!
            //println("loaded ledModeState \(ledModeState.rawValue)")
        }
        
        
        if let arbNotesNS : AnyObject? = defaults.objectForKey("arbNotesNS") {
            if let readArray : [Int]? = arbNotesNS as? [Int] {
                arbNotes = readArray!
                //println("loaded arbNotesNS \(arbNotes)")
            } else {
                println("failed to load arbNotesNS = \(arbNotesNS)")
            }
        }
        
       // if let optionalInt : Int? = defaults.integerForKey("thin"){
      //      println("loaded thin = \(thin)")
      //  }
        
        thin  = defaults.integerForKey("thin")// no checking of type
        //println("loaded thin = \(thin)")

        upLeft  = defaults.integerForKey("upLeft")// no checking of type
        //println("loaded upLeft = \(upLeft)")

        upRight  = defaults.integerForKey("upRight")// no checking of type
        //println("loaded upRight = \(upRight)")

        basenote  = defaults.integerForKey("basenote")// no checking of type
        //println("loaded basenote = \(basenote)")
        
        numMultiChannels = defaults.integerForKey("numMultiChannels")// no checking of type
        //println("loaded numMultiChannels = \(numMultiChannels)")
        
        baseChannel = defaults.integerForKey("baseChannel")// no checking of type
        //println("loaded baseChannel = \(baseChannel)")
        
        arbNotesLayout = defaults.boolForKey("arbNotesLayout")// no checking of type
        //println("loaded arbNotesLayout = \(arbNotesLayout)")
        
        setLEDsArbitrary = defaults.boolForKey("setLEDsArbitrary")// no checking of type
        //println("loaded setLEDsArbitrary = \(setLEDsArbitrary)")
        
        fast = defaults.boolForKey("fast")// no checking of type
        //println("loaded fast = \(fast)")
        
        turbo = defaults.boolForKey("turbo")// no checking of type
        //println("loaded turbo = \(turbo)")
        
        if let noteLedsNS : AnyObject? = defaults.objectForKey("noteLedsNS") {
            var readArray : [String] = noteLedsNS! as [String]// convert to swift strings?
            //println("loaded noteLedsNS \(readArray)")
            for i in 0...11 {
                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                    noteLeds[i] = value // the if binding means don't have to unwrap with !
                }//convert each element back to a optional swift enum
            }
            println("converted noteLedsNS")
            for i in 0...11 {
                print(" \(noteLeds[i].rawValue)")
            }
        } else {
            println("failed to read noteLedsNS")
        }
        
        if let arbLEDsNS : AnyObject? = defaults.objectForKey("arbLEDsNS") {
            var readArray : [String] = arbLEDsNS! as [String]// convert to swift strings?
            //println("loaded arbLEDsNS \(readArray)")
            for i in 0...47 {
                if let value  = sLEDState(rawValue: readArray[i]){//value will be optional. if user edits plist and misspells the tag it will fail
                    arbLEDs[i] = value // the if binding means don't have to unwrap with !
                }//convert each element back to a optional swift enum
            }
            println("converted arbLEDsNS")
            for i in 0...47 {
                print(" \(arbLEDs[i].rawValue)")
            }
        } else {
            println("failed to read arbLEDsNS")
        }
        
    }//end loadDefaults
    
    init() {
        setIsoNotes()
    }
    
    func setIsoNotes() {
        var thisrowoffset = 0
        var nextPad = upRight - upLeft
        var rownumber = 0
        var j = 0
        padNotes[j] = (basenote)//set first note
        ++j
        for i in 0...5 {//loop 6 times for 6 rows
            for k in 0...6 {//7 remaining pads per row
                padNotes[j] = (padNotes[j-1] + nextPad)
                ++j //next pad
            }//end pad loop
            rownumber = Int((j-1)/8)//why not just ++rownumber
            if ((rownumber % 2) == 1 ) {  // if odd num row
                thisrowoffset = upLeft
            } else {               //else even num  row
                thisrowoffset = upRight
            }
            padNotes[j] = (padNotes[j-8] + thisrowoffset)//does first note of new row //THIS IS AN OUT BY ONE ERROR requires array to be one bigger
            //this could be rewritten is more literal way modeled on makeLedLabelText to deal with specific manta layout.
            ++j
        }//end outer loop
        
        
        let lowestNote = minElement(padNotes)//this is a bit crappy!
        let highestNote = maxElement(padNotes)
        var correction = 0
        if lowestNote < 0 {correction = 0 - lowestNote}
        if highestNote > 127 {correction = 127 - highestNote}
        if correction  != 0 {// is there a better way to clamp/clip these values?
            for ii in 0...47 {
                padNotes[ii] += correction
                if padNotes[ii] < 0 {padNotes[ii] = 0}
                if padNotes[ii] > 127 {padNotes[ii] = 127}
            }
        }
        println("isolayout correction is \(correction)")
        
    }// end setIsonotes
    
    func makeLedLabelText()-> String{
        var ledLabelText = "  "
        if setLEDsArbitrary {// this is clumsy!
            for i in 40...47{//line 6
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 32...39{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r  "
            for i in 24...31{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 16...23{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r  "
            for i in 8...15{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
            ledLabelText += "\r"
            for i in 0...7{
                ledLabelText += "\(arbLEDs[i].rawValue) "
            }
        } else {
            ledLabelText = ("A- \(noteLeds[0].rawValue) Bb-\(noteLeds[1].rawValue) B- \(noteLeds[2].rawValue) C- \(noteLeds[3].rawValue) \rC#-\(noteLeds[4].rawValue) D- \(noteLeds[5].rawValue) Eb-\(noteLeds[6].rawValue) E- \(noteLeds[7].rawValue) \rF- \(noteLeds[8].rawValue) F#-\(noteLeds[9].rawValue) G- \(noteLeds[10].rawValue) G#-\(noteLeds[11].rawValue)")
        }
        return ledLabelText
    }
    
    func makeNoteLabelText() -> String{
        var noteLabelText = "  "
        for i in 40...47{//line 6
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 32...39{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r  "
        for i in 24...31{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 16...23{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r  "
        for i in 8...15{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        noteLabelText += "\r"
        for i in 0...7{
            if padNotes[i] < 100 {noteLabelText += " "}
            noteLabelText += "\(padNotes[i]) "
        }
        return noteLabelText
    }
    
    func makePitchClassLabelText() -> String{
        var name = ""
        var output = "  "
        for i in 40...47{//line 6
            name = noteNumberToName(padNotes[i])
            output += name
        }
        output += "\r"
        for i in 32...39{
            name = noteNumberToName(padNotes[i])
            output += name
        }
        output += "\r  "
        for i in 24...31{
            name = noteNumberToName(padNotes[i])
            output += name
        }
        output += "\r"
        for i in 16...23{
            name = noteNumberToName(padNotes[i])
            output += name
        }
        output += "\r  "
        for i in 8...15{
            name = noteNumberToName(padNotes[i])
            output += name
        }
        output += "\r"
        for i in 0...7{
            name = noteNumberToName(padNotes[i])
            output += name
        }
        //println(output)
        return output
        
    }
    
    func noteNumberToName(notenumber : Int) -> String{
        let pitchClass = Int((notenumber+3)%12)
        let octave = Int((notenumber)/12)-1
        var name = ""
        switch pitchClass {
            case 0: name = (" A\(octave) ")
            case 1: name = "Bb\(octave) "
            case 2: name = " B\(octave) "
            case 3: name = " C\(octave) "
            case 4: name = "C#\(octave) "
            case 5: name = " D\(octave) "
            case 6: name = "Eb\(octave) "
            case 7: name = " E\(octave) "
            case 8: name = " F\(octave) "
            case 9: name = "F#\(octave) "
            case 10: name = " G\(octave) "
            case 11: name = "G#\(octave) "
            default: println("this should never happen - pitchclass out of range")
            
        }
        //println("notename is \(name)")
        return name
    }


}//end userdata

