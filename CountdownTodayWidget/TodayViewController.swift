//
//  TodayViewController.swift
//  CountdownTodayWidget
//
//  Created by Liz on 15/3/1.
//  Copyright (c) 2015 Liz. All rights reserved.
//

import Cocoa
import NotificationCenter
import Foundation

class TodayViewController: NSViewController, NCWidgetProviding, NSUserNotificationCenterDelegate {

    override var nibName: String? {
        return "TodayViewController"
    }

    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        
        // Need to reschedule the timer when the view is reloaded
        scheduleTimer()
        displayCountdownTime()
        completionHandler(.NoData)
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        return NSEdgeInsetsZero
    }
    
    override func viewWillAppear() {
        // Set the reset button to be red
        var colorTitle = NSMutableAttributedString(attributedString: resetButton.attributedTitle)
        var titleRange = NSRange(location: 0, length: colorTitle.length)
        colorTitle.addAttribute(NSForegroundColorAttributeName, value: alertColor, range: titleRange)
        resetButton?.attributedTitle = colorTitle
    }
    
    @IBOutlet weak var countdownTextField: NSTextField!
    
    @IBOutlet weak var resetButton: NSButton!
    
    @IBAction func plus1MinButtonClicked(sender: NSButton) {
        addCountdownTime(60.0)
    }
    
    @IBAction func plus5MinButtonClicked(sender: NSButton) {
        addCountdownTime(300.0)
    }
    
    @IBAction func plus30MinButtonClicked(sender: NSButton) {
        addCountdownTime(1800.0)
    }
    
    @IBAction func plus1HourButtonClicked(sender: NSButton) {
        addCountdownTime(3600.0)
    }
    
    @IBAction func resetButtonClicked(sender: NSButton) {
        resetCountdownTime()
    }
    
    var timer:NSTimer?
    
    let kCountDownTargetTime:String = "CountDownWidgetTargetTime"
    let kCountDownNofiticationIdentifier:String = "CountDownWidgetNotificationIdentifier"
    let kCountDownTaskID:String = "CountDownWidgetTaskID"
    
    func addCountdownTime(seconds: NSTimeInterval) {
        // Load from user defaults
        var targetTime:NSDate? = NSUserDefaults.standardUserDefaults().objectForKey(kCountDownTargetTime) as? NSDate;
        if (targetTime != nil) {
            if targetTime!.timeIntervalSinceNow > 0 {
                // Target time is still in the future
                targetTime = targetTime!.dateByAddingTimeInterval(seconds)
            }else{
                targetTime = NSDate(timeIntervalSinceNow:seconds)
            }
        }else{
            targetTime = NSDate(timeIntervalSinceNow:seconds)
        }
        
        // Save to user defaults
        NSUserDefaults.standardUserDefaults().setObject(targetTime, forKey: kCountDownTargetTime)
        
        // Reschedule the timer when the time is updated
        scheduleTimer()
        
        // Kill the previous apple script task if available
        let taskID = NSUserDefaults.standardUserDefaults().integerForKey(kCountDownTaskID)
        if taskID != 0 {
            system("/bin/kill -KILL \(taskID)");
        }
        
        // Schedule a notification using apple script
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "delay \(targetTime!.timeIntervalSinceNow) \n display notification \"Time\'s Up\" with title \"Countdown Widget\" sound name \"Blow\""]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        NSUserDefaults.standardUserDefaults().setInteger(NSInteger(task.processIdentifier), forKey:kCountDownTaskID)
        
        // Commented out as Sending an anonymous UserNotification from Notification Center doesn't work...which is ironic
        
//        let notification:NSUserNotification = NSUserNotification()
//        notification.title = "Time's Up!"
//        notification.soundName = NSUserNotificationDefaultSoundName
//        notification.identifier = kCountDownNofiticationIdentifier
//        notification.deliveryDate = targetTime
//        notification.soundName = NSUserNotificationDefaultSoundName
//        NSUserNotificationCenter.defaultUserNotificationCenter().scheduleNotification(notification)
//        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    
        
        // Update the countdown UI right now
        displayCountdownTime()
    }
    
    func resetCountdownTime() {
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: kCountDownTargetTime)
        displayCountdownTime()
    }
    
    let alertColor = NSColor(red:0.813, green:0.39, blue:0.309, alpha:1)
    let defaultColor = NSColor.whiteColor()
    
    func scheduleTimer() {
        if timer == nil || !timer!.valid{
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1.0), target: self, selector: "displayCountdownTime", userInfo: nil, repeats: true)
            NSLog("Timer running")
        }
    }
    
    // Actually update the UI here once a second
    func displayCountdownTime() {
        var targetTime:NSDate? = NSUserDefaults.standardUserDefaults().objectForKey(kCountDownTargetTime) as? NSDate;
        var countdownTime:Int32 = 0;
        
        if targetTime != nil && targetTime!.timeIntervalSinceNow > 0 {
            countdownTime = Int32(floor(targetTime!.timeIntervalSinceNow))
        }
        
        let hour:Int32 = countdownTime/3600
        let minute:Int32 = (countdownTime - hour * 3600)/60
        let second:Int32 = (countdownTime - hour * 3600 - minute * 60)
        
        let displayString = (hour != 0) ? String(format: "%02d:%02d:%02d", hour, minute, second) : String(format: "%02d:%02d", minute, second)
        
        countdownTextField.stringValue = displayString
        countdownTextField.textColor = (countdownTime <= 30 && countdownTime > 0) ? alertColor : defaultColor
    }


}
