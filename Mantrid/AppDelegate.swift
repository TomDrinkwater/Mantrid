//
//  AppDelegate.swift
//  Mantrid
//
//  Created by puce on 22/10/2014.
//  Copyright (c) 2014 puce. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let myManta = swiftMantaObj()
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var multiChanMenu: NSPopUpButton!
    
    @IBOutlet weak var upRightOutlet: NSPopUpButton!
    
    @IBOutlet weak var upLeftOutlet: NSPopUpButton!
    
    @IBOutlet weak var transposeLabel: NSTextField!
    
    @IBOutlet weak var layoutTypeMenu: NSPopUpButton!
    
    @IBOutlet weak var pressTypeMenu: NSPopUpButton!
    
    
    @IBOutlet weak var thinMenu: NSPopUpButton!
    
    @IBOutlet weak var fastButton: NSButton!
    
    @IBOutlet weak var ledModeMenu: NSPopUpButton!
    
    @IBOutlet weak var ledSetMenu: NSPopUpButton!
    
    @IBOutlet weak var baseChannelMenu: NSPopUpButton!
    
    @IBOutlet weak var ledLabel: NSTextField!
    
    @IBAction func baseChannelMenu(sender: NSPopUpButton) {
        myManta.userData.baseChannel = sender.indexOfSelectedItem
    }
    
    
    @IBAction func upLeftMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        myManta.userData.upLeft = (item * -1) + 12
        println("the item selected is\((item * -1) + 12)")
        myManta.reCalcAll()
    }
    
    @IBAction func upRightMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        myManta.userData.upRight = (item * -1) + 12
        println("the item selected is\((item * -1) + 12)")
        myManta.reCalcAll()
    }
    
    @IBAction func layoutTypeMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        if item == 1 {
            setArbNoteslayout()
        } else {
            setIsoNotesLayout()
        }
    }
    
    func setArbNoteslayout() {
        myManta.userData.arbNotesLayout = true
        
        //myManta.userData.padNotes = myManta.userData.arbNotes
        myManta.reCalcAll()//should fill padNotes with arbNotes+transpose
        
        println("arb layout \(myManta.userData.arbNotesLayout)")
    }
    
    func setIsoNotesLayout() {
        myManta.userData.arbNotesLayout = false
        
        myManta.userData.arbNotes = myManta.userData.padNotes//save current arbitrary padnotes to arbnotes
        
        myManta.reCalcAll()//should refill padNotes with Iso layout
        println("iso layout")
    }
    //////////////////////////////////////////////////
    func setViewFromModel(){
        upLeftOutlet.selectItemAtIndex(12 - myManta.userData.upLeft)
        //println("upLeft = \(myManta.userData.upLeft)")
        //println("setting index to \(12 - myManta.userData.upLeft)")
        upRightOutlet.selectItemAtIndex(12 - myManta.userData.upRight)
        if myManta.userData.arbNotesLayout {
            layoutTypeMenu.selectItemAtIndex(1)
            //myManta.userData.padNotes = myManta.userData.arbNotes
        } else {
            layoutTypeMenu.selectItemAtIndex(0)
        }
        setTransposeLabeler()
        
        baseChannelMenu.selectItemAtIndex(myManta.userData.baseChannel)
        
        switch myManta.userData.pressureState {
            case UserData.PressState.PressOff:pressTypeMenu.selectItemAtIndex(0)
            multiChanMenu.enabled = false
            case UserData.PressState.PressPoly:pressTypeMenu.selectItemAtIndex(1)
            multiChanMenu.enabled = false
            case UserData.PressState.PressChan:pressTypeMenu.selectItemAtIndex(2)
            multiChanMenu.enabled = false
            case UserData.PressState.PressMulti:pressTypeMenu.selectItemAtIndex(3)
            multiChanMenu.enabled = true
        }
        
        switch myManta.userData.ledModeState {
            case UserData.LEDModeState.LedOff:ledModeMenu.selectItemAtIndex(0)
            case UserData.LEDModeState.LedRed:ledModeMenu.selectItemAtIndex(1)
            case UserData.LEDModeState.LedBoth:ledModeMenu.selectItemAtIndex(2)
        }
        
        thinMenu.selectItemAtIndex(myManta.userData.thin-1)
        multiChanMenu.selectItemAtIndex(myManta.userData.numMultiChannels-1)
        myManta.userData.setLEDsArbitrary ? ledSetMenu.selectItemAtIndex(1) : ledSetMenu.selectItemAtIndex(0)
        
        myManta.userData.settingNotes = false//every load sets these back to false
        myManta.userData.settingLEDs = false
        ledSetButton.state = NSOffState
        noteSetButton.state = NSOffState
        
        myManta.reCalcAll()
    }
    /////////////////////////////////////////////////
    func setLedLabel(){
        let ledLabelText = myManta.userData.makeLedLabelText()
        ledLabel.stringValue = ledLabelText
    }
    
    
    func setTransposeLabeler() {
        transposeLabel.stringValue = "transpose = " + String(myManta.userData.transpose)
    }
    
    @IBAction func saveButton(sender: NSButton) {
        myManta.userData.saveDefaults()
    }
    
    @IBAction func loadButton(sender: NSButton) {
        myManta.userData.loadDefaults()
        setViewFromModel()
    }
    
    
    @IBAction func octaveDownButton(sender: NSButton) {
        myManta.Transpose(-12)
        myManta.reCalcAll()
    }
    @IBAction func octaveUpButton(sender: NSButton) {
        myManta.Transpose(12)
        myManta.reCalcAll()
    }
    @IBAction func semiDownButton(sender: NSButton) {
        myManta.Transpose(-1)
        myManta.reCalcAll()
    }
    @IBAction func semiUpButton(sender: NSButton) {
        myManta.Transpose(1)
        myManta.reCalcAll()
    }
    
    @IBAction func noteSetButton(sender: NSButton) {
        myManta.userData.settingNotes = !myManta.userData.settingNotes
        println("settingNotes \(myManta.userData.settingNotes)")
        if myManta.userData.settingNotes {//when notes set switch to arb layout
            
            setArbNoteslayout()
            layoutTypeMenu.selectItemAtIndex(1)
            myManta.userData.settingLEDs = false // can't set leds and notes at same time
            ledSetButton.state = NSOffState
        } else {// if finished setting notes save arbnotes
            myManta.userData.arbNotes = myManta.userData.padNotes
        }
        noteSetLabeler()
    }
    
    @IBOutlet weak var noteSetButton: NSButton!
    
    @IBOutlet weak var noteSetLabel: NSTextField!
    
    func noteSetLabeler() {
        noteSetLabel.stringValue = myManta.userData.makeNoteLabelText()
    }
    
    @IBAction func pressureTypeMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        switch item {
        case 0:myManta.userData.pressureState = UserData.PressState.PressOff
            multiChanMenu.enabled = false
        case 1:myManta.userData.pressureState = UserData.PressState.PressPoly
            multiChanMenu.enabled = false
        case 2:myManta.userData.pressureState = UserData.PressState.PressChan
            multiChanMenu.enabled = false
        case 3:myManta.userData.pressureState = UserData.PressState.PressMulti
            multiChanMenu.enabled = true
        default:myManta.userData.pressureState = UserData.PressState.PressPoly
            multiChanMenu.enabled = false
        }
    }
    
    @IBAction func thinMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        myManta.userData.thin = item+1
    }
    
    @IBAction func multiChanMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        myManta.userData.numMultiChannels = item
    }
    
    @IBAction func fastButton(sender: NSButton) {
        myManta.userData.fast = !myManta.userData.fast
        println("fast is\(myManta.userData.fast)")
    }
    
    @IBAction func ledModeMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        switch item {
        case 0:
            myManta.userData.ledModeState = UserData.LEDModeState.LedOff
            println("leds off")
        case 1:
            myManta.userData.ledModeState = UserData.LEDModeState.LedRed
            println("leds red only")
        case 2:
            myManta.userData.ledModeState = UserData.LEDModeState.LedBoth
            println("leds both")
        default:
            myManta.userData.ledModeState = UserData.LEDModeState.LedBoth
            println("leds default both")
        }
        myManta.reCalcAll()
    }
    
    @IBAction func setLEDsArbMenu(sender: NSPopUpButton) {
        var item = sender.indexOfSelectedItem
        item == 0 ? (myManta.userData.setLEDsArbitrary = false) : (myManta.userData.setLEDsArbitrary = true)
        myManta.reCalcAll()
    }
    
    
    @IBOutlet weak var ledSetButton: NSButton!
    
    @IBAction func setLEDbutton(sender: NSButton) {
        myManta.userData.settingLEDs = !myManta.userData.settingLEDs //toggle
        if myManta.userData.settingLEDs {
            myManta.userData.settingNotes = false // can't set leds and notes at same time
            noteSetButton.state = NSOffState
        }
        setLedLabel()
    }
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var menuConnectItem : NSMenuItem = NSMenuItem()
    var menuShowWindowItem : NSMenuItem = NSMenuItem()
    var menuHideWindowItem : NSMenuItem = NSMenuItem()
    var menuQuitItem : NSMenuItem = NSMenuItem()
    var statusImage:NSImage? = nil
    
    override func awakeFromNib(){
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        //statusBarItem.title = "Mantrid"
        
        self.statusImage = NSImage(named: "blueicon")
        statusBarItem.image = self.statusImage
        
        //Add menuClickedItem to menu
        menuConnectItem.title = "..connect"
        menuConnectItem.action = Selector("connect")
        menuConnectItem.keyEquivalent = ""
        menu.addItem(menuConnectItem)
        
        //Add menuShowWindowItem to menu
        menuShowWindowItem.title = "Show"
        menuShowWindowItem.action = Selector("setWindowVisible:")
        menuShowWindowItem.keyEquivalent = ""
        menu.addItem(menuShowWindowItem)
        
        //Add menuWindowItem to menu
        menuHideWindowItem.title = "Hide"
        menuHideWindowItem.action = Selector("hideWindow:")
        menuHideWindowItem.keyEquivalent = ""
        menu.addItem(menuHideWindowItem)
        
        //Add menuWindowItem to menu
        menuQuitItem.title = "Quit"
        menuQuitItem.action = Selector("quit:")
        menuQuitItem.keyEquivalent = ""
        menu.addItem(menuQuitItem)

        self.window.orderOut(self)//hide window on start
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        println("myManta object looks like \(myManta)")
        
        connect()
        multiChanMenu.enabled = false
        setLedLabel()
        noteSetLabeler()
    }
    
    func connect(){
        myManta.connected = myManta.SafeConnect()
        if myManta.connected {
            myManta.quitting = false
            var myserial = myManta.GetSerialNumber()
            menuConnectItem.title = "connected to \(myserial)"
            self.statusImage = NSImage(named: "redicon")
            statusBarItem.image = self.statusImage
            myManta.onConnect()
        } else {
            menuConnectItem.title = "..connect"
            println("failed to connect")
            self.statusImage = NSImage(named: "blueicon")
            statusBarItem.image = self.statusImage
        }
        
        //myManta.Connect()
    }//end connect
    
    
    func setWindowVisible(sender: AnyObject){
            NSApplication.sharedApplication().activateIgnoringOtherApps(true)//make whole app foreground
            self.window.makeKeyAndOrderFront(self)//show
            //menuWindowItem.title = "Hide"//set title to opposite
    }
    
    func hideWindow(sender: AnyObject){
            self.window.orderOut(self)//else hide
            //menuWindowItem.title = "Show"//set title to opposite
    }

    
    func quit(sender: AnyObject){//WHY DOESN'T THIS WORK!!!
        
        let hasquit = myManta.onQuit()
        
        println("onquit has finished \(hasquit)")
        //let connected = myManta.IsConnected()//should be disconnected by now!
        //println("is connected \(connected)")
        
        NSApplication.sharedApplication().terminate(self)
    }

    
    
    func applicationWillTerminate(aNotification: NSNotification) {//does this actually ever get called?
        //myManta.onQuit()
    }//end applicationWillTerminate
    
}//end appdelegate

