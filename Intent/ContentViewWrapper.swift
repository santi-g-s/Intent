//
//  ContentViewWrapper.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 03/06/2023.
//

import SwiftUI
import Combine

struct ContentViewWrapper: View {
    
    @AppStorage("showOnboardingView") var showOnboardingView: Bool = true
    
    var body: some View {
        ContentView()
            .sheet(isPresented: $showOnboardingView){
                OnboardingView()
                    .interactiveDismissDisabled(true)
            }
    }
}

struct OnboardingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.indigo.opacity(0.2))
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.indigo)
    }
    
    let timer = Timer.publish(every: 2, tolerance: 0.5, on: .main, in: .common).autoconnect()
    
    let symbols: [String] = {
        guard let path = Bundle.main.path(forResource: "curatedsfsymbols", ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            return []
        }
        return content.replacingOccurrences(of: ".fill\n", with: "\n")
            .split(separator: "\n")
            .map { String($0)}
            .shuffled()
    }()
    
    @State var selection = 0
    
    @State var pageSelection = 0
    
    var body: some View {
        VStack {
            VStack(alignment: .leading){
                Spacer()
                    .frame(height: 40)
                Image("IntentIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                Text("Welcome to **Intent**")
                    .font(.system(.largeTitle, design: .rounded, weight: .regular))
                    .padding(.leading, 10)
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            TabView(selection: $pageSelection){
                firstView
                    .tag(0)
                secondView
                    .tag(1)
                thirdView
                    .tag(2)
                fourthView
                    .tag(3)
                fifthView
                    .tag(4)
                finalView
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
        }
        
    }
    
    var firstView: some View {
        VStack {
            Text("A mindful habit tracker that elevates **progress** above perfection")
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            
            TabView(selection: $selection) {
                ForEach(symbols.indices, id: \.self) { index in
                    Image(systemName: symbols[index])
                        .resizable()
                        .fontWeight(.light)
                        .foregroundStyle(.quaternary)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .tag(index)
                }
                .padding(.bottom, 40)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onReceive(timer) { time in
                withAnimation {
                    if selection + 1 < symbols.count - 1 {
                        selection = selection + 1
                    } else {
                        selection = 0
                    }
                }
            }
            .disabled(true)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @State var habitScore1 = 0.1
    @State var isComplete1 = false
    
    @State var habitScore2 = 0.1
    @State var isComplete2 = false
    
    @State private var cancellable1: AnyCancellable?
    @State private var cancellable2: AnyCancellable?
    
    var secondView: some View {
        VStack {
            Text("Build a streak by ensuring your **habit circle** never dies")
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            
            ZStack {
                Circle()
                    .foregroundStyle(.regularMaterial)
                
                Circle()
                    .foregroundColor(.indigo.opacity(isComplete1 ? 1 : 0.75))
                    .shadow(color: .indigo.adjust(brightness: -0.3).opacity(0.2), radius: isComplete1 ? 16 : 0, x: 0, y: 0)
                    .scaleEffect(habitScore1)
                    .overlay {
                        Group {
                            if isComplete1 {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                                    .foregroundStyle(.tertiary)
                                    .colorScheme(.dark)
                            }
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: habitScore1)
            }
            .onTapGesture {
                habitScore1 = min(habitScore1 + 0.1, 1.0)
                isComplete1 = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        self.isComplete1 = false
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
            
            Spacer()
            
        }
        .padding(.horizontal)
        .onAppear {
            let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
            
            cancellable1 = timer
                .sink { _ in
                    
                    if self.habitScore1 >= 0.9 {
                        withAnimation {
                            self.habitScore1 = 0.0
                        }
                    } else {
                        withAnimation {
                            self.habitScore1 += 0.1
                            self.isComplete1 = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                self.isComplete1 = false
                            }
                        }
                    }
                    
                }
        }
        .onDisappear {
            self.cancellable1?.cancel()
        }
    }
    
    var thirdView: some View {
        VStack {
            Text("It's fine if you don't reach your goal today, just **try again tomorrow** to keep your habit circle alive")
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        
            ZStack {
                Circle()
                    .foregroundStyle(.regularMaterial)
                
                Circle()
                    .foregroundColor(.indigo.opacity(isComplete2 ? 1 : 0.75))
                    .shadow(color: .indigo.adjust(brightness: -0.3).opacity(0.2), radius: isComplete2 ? 16 : 0, x: 0, y: 0)
                    .scaleEffect(habitScore2)
                    .overlay {
                        Group {
                            if isComplete2 {
                                Image(systemName: "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                                    .foregroundStyle(.tertiary)
                                    .colorScheme(.dark)
                            }
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.45, blendDuration: 0), value: habitScore2)
            }
            .onTapGesture {
                habitScore2 = min(habitScore2 + 0.1, 1.0)
                isComplete2 = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        self.isComplete2 = false
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
            
            cancellable2 = timer
                .sink { _ in
                    withAnimation {
                        let randomVal = Int.random(in: 0...1) // randomly generate 0 or 1
                        if randomVal != 0 {
                            // increase score
                            self.habitScore2 = min(self.habitScore2 + 0.1, 1.0)
                            self.isComplete2 = true
                        } else {
                            // decrease score
                            if habitScore2 <= 0.2 {
                                // increase if already too small
                                self.habitScore2 = min(self.habitScore2 + 0.1, 1.0)
                                self.isComplete2 = true
                            } else {
                                self.habitScore2 = max(self.habitScore2 - 0.2, 0.0)
                            }
                        }
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            self.isComplete2 = false
                        }
                    }
                }
        }
        .onDisappear {
            self.cancellable2?.cancel()
        }
    }
    
    @State private var hue: Double = 0.5
    
    @State private var cancellable3: AnyCancellable?
    
    var color: Color {
        Color(hue: hue, saturation: 0.8, brightness: 0.8)
    }
    
    var fourthView: some View {
        VStack {
            Text("**Customise** your habits and set specific **goals** that suit your needs")
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            //TODO: Color Slider than YOU can change (alternatively automatically changes), modifies background color
            Slider(value: $hue, in: 0...1)
                .padding(.horizontal, 40)
                .tint(color)
            
            Image(systemName: "wand.and.stars")
                .resizable()
                .fontWeight(.light)
                .foregroundStyle(color)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding(80)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .foregroundColor(color.opacity(0.05))
                )
            
            Spacer()
        }
        .padding(.horizontal)
        .onAppear {
            let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
            
            cancellable3 = timer
                .sink { _ in
                    withAnimation {
                        hue = Double.random(in: 0...1)
                    }
                }
        }
        .onDisappear {
            cancellable3?.cancel()
        }
    }
    
    var fifthView: some View {
        VStack {
            Text("All your **data stays protected** on your device. Private and secure.")
                .font(.system(.title2, design: .rounded, weight: .regular))
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image(systemName: "lock.shield")
                .resizable()
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding([.horizontal, .bottom], 40)
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var finalView: some View {
        VStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Circle()
                    .foregroundColor(.indigo)
                    .overlay {
                        HStack {
                            Image(systemName: "checkmark")
                                .bold()
                            Text("Get Started")
                                .bold()
                        }
                        .foregroundColor(.white)
                    }
            }
            .buttonStyle(ScaleButtonStyle())
            .background(Circle().foregroundStyle(.regularMaterial))
            .padding(40)
            
            Spacer()
        }
    }
}

struct ContentViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
