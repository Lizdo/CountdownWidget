#Countdown Today Widget

A basic count down widget that resides in your notification center. Available for 10.10. Good for keeping track of the time when the count down timer on your oven doesn't work.

It looks like this in the notification center:

![image](https://raw.githubusercontent.com/Lizdo/CountdownWidget/master/Export/Screenshot.png)

When the time is up, a small notification will popup:

![image](https://raw.githubusercontent.com/Lizdo/CountdownWidget/master/Export/Notification.png)

##Installation

- Unzip [this file](https://github.com/Lizdo/CountdownWidget/raw/master/Export/Countdown%20TodayWidget.zip)
- Right click on the extracted .app and run it (To by pass the [code-signing](https://support.apple.com/en-qa/HT202491))
- Add the Countdown widget from your notification center

##### Some Technical Details

Sending a notification from the notification center turned out to be more difficult than I thought. Sending anonymous notification doesn't seem to work, and the app instance that is alive in the Today Widget section will be killed soon after you close the notification center. The solution I'm using right now is to use [apple script](http://apple.stackexchange.com/questions/57412/how-can-i-trigger-a-notification-center-notification-from-an-applescript-or-shel) to trigger the notification. When the timer is changed, I will use the saved process id and kill the previous apple script task. Almost all the logic are inside [TodayViewController.swift](https://github.com/Lizdo/CountdownWidget/blob/master/CountdownTodayWidget/TodayViewController.swift) file.