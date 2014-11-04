//
//  SaveandLoad.swift
//  MenuBar
//
//  Created by Office on 05/10/2014.
//  Copyright (c) 2014 Office. All rights reserved.
//

import Foundation
import Cocoa //needed for NSSavePanel
import AppKit

class SaveandLoad {
    
    let allUserSettings = ["field":"value"]//need to populate this correctly and get the vars into it from other class
    
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

    
}//end class