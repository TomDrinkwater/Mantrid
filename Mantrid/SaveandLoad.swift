//
//  SaveandLoad.swift
//  MenuBar
//
//  Copyright (c) 2014 Tom Drinkwater.
//  www.tomdrinkwater.com

import Foundation
import Cocoa //needed for NSSavePanel
import AppKit
// THIS CLASS CURRENTLY UNUSED
class SaveandLoad {
    
    //let allUserSettings = ["field":"value"]//need to populate this correctly and get the vars into it from other class
    
    //These are instance methods, should they really be type methods? why? shoulod this be an object at all? better  just a file of funcs?
    
    
    func saveArbNotes(arraytosave: [Int]) {
        let myNSarray = arraytosave as NSArray
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(myNSarray, forKey: "myArray")
        userDefaults.synchronize()
        
    }
    
    func loadArbNotes(){
        var defaults = NSUserDefaults.standardUserDefaults()
        let key = "myArray"
        if let testArray : AnyObject? = defaults.objectForKey(key) {
            var readArray : [Int] = testArray! as [Int]
            println("loaded array \(readArray)")
        } else {
            println("failed to read array")
        }
    }
    
    func saveArray(){//how do I pass allUserSettings to the function? is global within this class? use -> to set argument if needed
        
        let myarray = ["save an array", "Two", "Three"] as NSArray
        myarray.writeToFile("/Users/puce/Desktop/trial2.txt", atomically:true)//last arg specifies write to aux file and rename
        
    }
    
    func saveString(){
        let myString = "now save this string" as NSString
        myString.writeToFile("/Users/puce/Desktop/savedstring.txt", atomically:true, encoding: NSUTF8StringEncoding, error: nil)//apparently string write to file needs the extra args
        
    }
    
    func exportFile() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.showsHiddenFiles = true
        let myFileTypes:NSArray = ["txt"]
        savePanel.allowedFileTypes = myFileTypes
        savePanel.allowsOtherFileTypes = false
  
        savePanel.beginWithCompletionHandler { (result: Int) -> Void in //this is a swift closure look it up
            if result == NSFileHandlingPanelOKButton {
                if let exportedFileURL = savePanel.URL {
                    let myString = "this string saved at \(exportedFileURL)" as NSString
                    myString.writeToURL(exportedFileURL, atomically:true, encoding: NSUTF8StringEncoding, error: nil)//an instance function
                    /*apparently string write to file needs the extra args*/
                }
            }
        } // End block
    }
    
    
    func importFile() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.showsHiddenFiles = true
        openPanel.allowsMultipleSelection = false
        
        let myFileTypes:NSArray = ["txt"]
        openPanel.allowedFileTypes = myFileTypes
        openPanel.allowsOtherFileTypes = false
        ///openPanel.runModal()
        openPanel.beginWithCompletionHandler { (result: Int) -> Void in //this is a swift closure look it up
            
            
            if result == NSFileHandlingPanelOKButton {
                if let importedFileURL = openPanel.URL {// holds path to selected file, if there is one
                    let contents = NSString(contentsOfURL: importedFileURL, encoding: NSUTF8StringEncoding, error: nil);//a class function on NSString returns a string from file
                    
                    println("the loaded content is \(contents!)") ///\(contents)
                    println("loaded from \(importedFileURL))") /*//\(importedFileURL)*/
                } else {
                    println("load failed");
                }
            }
        }
        
    }//end importfile

    func importFileModal() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = true
        openPanel.showsHiddenFiles = true
        openPanel.allowsMultipleSelection = false
        
        let myFileTypes:NSArray = ["txt"]
        openPanel.allowedFileTypes = myFileTypes
        openPanel.allowsOtherFileTypes = false
        openPanel.runModal()
        
        /// var importedFileURL: NSArray = []///is this the same as below?
        
        /// var importedFileURL = [] as NSArray
        let importedFileURL = openPanel.URL // holds path to selected file, if there is one
        
        //now open the file and read contents
        if (importedFileURL != nil) {
            let contents = NSString(contentsOfURL: importedFileURL!, encoding: NSUTF8StringEncoding, error: nil);//a class function on NSString returns a string from file
            
            println("the loaded content is \(contents!)") ///\(contents)
            println("loaded from \(importedFileURL!))") /*//\(importedFileURL)*/
        } else {
            println("load failed");
        }
        
    }//end importfile
    
    
  /*  ///////////////////////////////////////////////////////////////////////////
    
    //let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func saveDefaults(){
        //NSUserDefaults.resetStandardUserDefaults()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(thin, forKey: "thin")
        userDefaults.setInteger(upRight, forKey: "upRight")
        userDefaults.setInteger(upLeft, forKey: "upLeft")
        userDefaults.setInteger(basenote, forKey: "basenote")
        userDefaults.setInteger(numMultiChannels, forKey: "numMultiChannels")
        //userDefaults.setInteger(transpose, forKey: "transpose")
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
        
        userDefaults.synchronize()
        println("saved user data")
    }//// end save /////////
    //////////////////////////////////////////////////////////////////////////
    func loadDefaults(){
        //NSUserDefaults.resetStandardUserDefaults()
        let defaults = NSUserDefaults.standardUserDefaults()
        
        /*if let pressureStateNS : AnyObject? = defaults.objectForKey("pressureStateNS") {
        if let temp : String? = pressureStateNS as? String {
        let stringValue = temp!
        if let enumValue = PressState(rawValue: stringValue){
        pressureState = enumValue
        //println("loaded pressureState \(pressureState.rawValue)")
        
        }
        } else {
        println("failed to load pressureStateNS = \(pressureStateNS)")
        }
        }*/
        
        /* if let pressureStateNS: AnyObject = defaults.objectForKey("pressureStateNS"){
        let temp = pressureStateNS as String
        if let enumValue = PressState(rawValue: temp){
        pressureState = enumValue
        println("loaded pressureState \(self.pressureState.rawValue)")
        }
        }*/
        
        if let pressureStateNS = defaults.stringForKey("pressureStateNS"){
            pressureState = PressState(rawValue: pressureStateNS)!
        }
        
        
        if let ledModeStateNS : AnyObject? = defaults.objectForKey("ledModeStateNS") {
            if let temp : String? = ledModeStateNS as? String {
                let stringValue = temp!
                if let enumValue = LEDModeState(rawValue: stringValue){
                    ledModeState = enumValue
                    //println("loaded ledModeState \(ledModeState.rawValue)")//makes a runtime error but must be a bug!
                }
            } else {
                println("failed to load ledModeStateNS = \(ledModeStateNS)")
            }
        }
        
        if let arbNotesNS : AnyObject? = defaults.objectForKey("arbNotesNS") {
            if let readArray : [Int]? = arbNotesNS as? [Int] {
                arbNotes = readArray!
                println("loaded arbNotesNS \(arbNotes)")
            } else {
                println("failed to load arbNotesNS = \(arbNotesNS)")
            }
        }
        
        if let optThin : AnyObject? = defaults.objectForKey("thin") { //this is nuts!
            if let temp : NSNumber? = optThin as? NSNumber{
                thin = temp as Int
                println("loaded thin = \(thin)")
            } else {
                println("failed to load thin = \(thin)")
            }
        }
        
        if let optUpRight : AnyObject? = defaults.objectForKey("upRight") { //this is nuts!
            if let temp : NSNumber? = optUpRight as? NSNumber{
                upRight = temp as Int
                println("loaded upRight = \(upRight)")
            } else {
                println("failed to load upRight = \(upRight)")
            }
        }
        
        if let optUpLeft : AnyObject? = defaults.objectForKey("upLeft") { //this is nuts!
            if let temp : NSNumber? = optUpLeft as? NSNumber{
                upLeft = temp as Int
                println("loaded upLeft = \(upLeft)")
            } else {
                println("failed to load upLeft = \(upLeft)")
            }
        }
        
        basenote  = defaults.integerForKey("basenote")// no checking of type
        println("loaded basenote = \(basenote)")
        
        numMultiChannels = defaults.integerForKey("numMultiChannels")// no checking of type
        println("loaded numMultiChannels = \(numMultiChannels)")
        
        baseChannel = defaults.integerForKey("baseChannel")// no checking of type
        println("loaded baseChannel = \(baseChannel)")
        
        arbNotesLayout = defaults.boolForKey("arbNotesLayout")// no checking of type
        println("loaded arbNotesLayout = \(arbNotesLayout)")
        
        setLEDsArbitrary = defaults.boolForKey("setLEDsArbitrary")// no checking of type
        println("loaded setLEDsArbitrary = \(setLEDsArbitrary)")
        
        fast = defaults.boolForKey("fast")// no checking of type
        println("loaded fast = \(fast)")
        
        turbo = defaults.boolForKey("turbo")// no checking of type
        println("loaded turbo = \(turbo)")
        
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

*/
    
}//end class