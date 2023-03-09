//
//  TimerAppApp.swift
//  TimerApp
//
//  Created by Onur Celik on 9.03.2023.
//

import SwiftUI

@main
struct TimerAppApp: App {
    @StateObject var pomodoroModel: PomodoroModel = .init()
    @Environment(\.scenePhase) var phase
    // Storing last timestamp
    @State var lastActiveTimeStamp: Date = Date()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pomodoroModel)
        }
        .onChange(of: phase) { newValue in
            if pomodoroModel.isStarted{
                if newValue == .background{
                   lastActiveTimeStamp = Date()
                }
                if newValue == .active{
                   // Finding the difference
                    let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
                    if pomodoroModel.totalseconds - Int(currentTimeStampDiff) <= 0 {
                        pomodoroModel.isStarted = false
                        pomodoroModel.totalseconds = 0
                        pomodoroModel.isFinished = true
                    }else{
                        pomodoroModel.totalseconds -= Int(currentTimeStampDiff)
                    }
                }
            }
        }
    }
}
