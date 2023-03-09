//
//  PomodoroModel.swift
//  TimerApp
//
//  Created by Onur Celik on 9.03.2023.
//

import SwiftUI
class PomodoroModel: NSObject,ObservableObject, UNUserNotificationCenterDelegate{
    @Published var progress: CGFloat = 1
    @Published var timerStringValue: String = "00:00"
    @Published var hour: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var isStarted: Bool = false
    @Published var addNewTimer: Bool = false
    
    @Published var totalseconds: Int = 0
    @Published var staticTotalSeconds: Int = 0
    // Post Timer Properties
    @Published var isFinished: Bool = false
    override init(){
        super.init()
        self.authorizeNotification()
    }
    // MARK: Requesting Notification Access
    func authorizeNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert,.sound,.badge]) { _, _ in
            
        }
        // To Show in App Notification
        UNUserNotificationCenter.current().delegate = self
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound,.banner])
    }
    
    // MARK: Starting Timer
    func startTimer(){
        withAnimation(.easeInOut(duration: 0.25)){isStarted = true}
        // Setting String Time Value
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        // calculating total second for timer animation
        totalseconds = (hour*3600) + (minutes*60) + (seconds)
        staticTotalSeconds = totalseconds
        addNewTimer = false
        addNotification()
    }
    // MARK: Stopping Timer
    func stopTimer(){
        withAnimation {
            isStarted = false
            hour = 0
            minutes = 0
            seconds = 0
            progress = 1
        }
        totalseconds = 0
        staticTotalSeconds = 0
        timerStringValue = "00:00"
    }
    // MARK: Updating Timer
    func updateTimer(){
        totalseconds -= 1
        progress = CGFloat(totalseconds)/CGFloat(staticTotalSeconds)
        progress = (progress < 0 ? 0 : progress)
        hour = totalseconds/3600
        minutes = (totalseconds/60) % 60
        seconds = (totalseconds % 60)
        timerStringValue = "\(hour == 0 ? "" : "\(hour):")\(minutes >= 10 ? "\(minutes)":"0\(minutes)"):\(seconds >= 10 ? "\(seconds)":"0\(seconds)")"
        if hour == 0 && minutes == 0 && seconds == 0{
            isStarted = false
            isFinished = true
        }
    }
    
    func addNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro Timer"
        content.subtitle = "Time is up"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(staticTotalSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
