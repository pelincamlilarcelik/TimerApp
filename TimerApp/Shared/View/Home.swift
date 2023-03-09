//
//  Home.swift
//  TimerApp
//
//  Created by Onur Celik on 9.03.2023.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var pomodoroModel: PomodoroModel
    var body: some View {
        VStack{
            Text("Pomodoro Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
            GeometryReader{proxy in
                VStack(spacing: 15) {
                    ZStack{
                        Circle()
                            .fill(.white.opacity(0.03))
                            .padding(-40)
                        
                        Circle()
                            .trim(from:0,to:pomodoroModel.progress)
                            .stroke(.white.opacity(0.03),lineWidth: 80)
                            
                        // Shadow
                        Circle()
                            .stroke(Color("Purple").opacity(0.7),lineWidth: 10)
                            .blur(radius: 15)
                            .padding(-2)
                        Circle()
                            .fill(Color("BG"))
                        Circle()
                            .trim(from:0,to:pomodoroModel.progress)
                            .stroke(Color("Purple").opacity(0.7),lineWidth: 10)
                        // Knob
                        GeometryReader{proxy in
                            let size = proxy.size
                            Circle()
                                .fill(Color("Purple"))
                                .frame(width:30,height: 30)
                                .overlay {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                }
                                .frame(width:size.width,height: size.height,alignment: .center)
                                .offset(x:size.height/2)
                                .rotationEffect(Angle(degrees: pomodoroModel.progress*360))
                        }
                        
                        Text(pomodoroModel.timerStringValue)
                            .font(.system(size: 45,weight: .light))
                            .rotationEffect(Angle(degrees: 90))
                            .animation(.none, value: pomodoroModel.progress)
                        
                    }
                    .padding(60)
                    .frame(height:proxy.size.width)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: pomodoroModel.progress)
                    .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
                    Button {
                        if pomodoroModel.isStarted{
                            pomodoroModel.stopTimer()
                            // Cancelling all notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }else{
                            pomodoroModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !pomodoroModel.isStarted ? "timer" : "stop.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle.bold())
                            .frame(width:80,height: 80)
                            .background{
                                Circle()
                                    .fill(Color("Purple"))
                            }
                            .shadow(color:Color("Purple"),radius: 8)
                    }

                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
                
                
            }
            
        }
        .padding()
        .background{
            Color("BG")
                .ignoresSafeArea()
        }
        .overlay{
            ZStack{
                Color.black
                    .opacity(pomodoroModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        pomodoroModel.hour = 0
                        pomodoroModel.minutes = 0
                        pomodoroModel.seconds = 0
                        pomodoroModel.addNewTimer = false
                    }
                NewTimerView()
                    .frame(maxHeight: .infinity,alignment: .bottom)
                    .offset(y:pomodoroModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: pomodoroModel.addNewTimer)
        }
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if pomodoroModel.isStarted{
                pomodoroModel.updateTimer()
            }
        }
        .alert("Time is up", isPresented: $pomodoroModel.isFinished) {
            Button("Start New",role: .cancel) {
                pomodoroModel.stopTimer()
                pomodoroModel.addNewTimer = true
            }
            Button("Close",role: .destructive) {
                pomodoroModel.stopTimer()
                
            }
        }
    }
    // New Timer Bottom Sheet
    @ViewBuilder
    func NewTimerView()->some View{
        VStack(spacing:15){
            Text("Add New Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top,10)
            HStack(spacing: 15) {
                Text("\(pomodoroModel.hour) hr")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                            pomodoroModel.hour = value
                        }
                    }
                Text("\(pomodoroModel.minutes) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "min") { value in
                            pomodoroModel.minutes = value
                        }
                    }
                Text("\(pomodoroModel.seconds) sec")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                            pomodoroModel.seconds = value
                        }
                    }
                
            }
            .padding(.top,20)
            Button {
                pomodoroModel.startTimer()
            } label: {
                Text("Start")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal,100)
                    .padding(.vertical)
                    .background{
                        Capsule()
                            .fill(Color("Purple"))
                    }
            }
            .disabled(pomodoroModel.seconds == 0)
            .opacity(pomodoroModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)

        }
        .padding()
        .frame(maxWidth:.infinity)
        .background{
            RoundedRectangle(cornerRadius: 10,style: .continuous)
                .fill(Color("BG"))
                .ignoresSafeArea()
        }
    }
    // Reusable Context Menu Options
    @ViewBuilder
    func ContextMenuOptions(maxValue:Int,hint:String,onClick: @escaping (Int)->())->some View{
        ForEach(0...maxValue,id:\.self) { value in
            Button("\(value) \(hint)") {
                onClick(value)
            }
        }
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PomodoroModel())
    }
}
