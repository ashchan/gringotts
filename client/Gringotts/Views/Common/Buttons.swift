//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    init(foregroundColor: Color = .black, backgroundColor: Color = .gray, pressedColor: Color = .white, pressedBackgroundColor: Color = .blue) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.pressedColor = pressedColor
        self.pressedBackgroundColor = pressedBackgroundColor
    }

    var foregroundColor: Color
    var backgroundColor: Color
    var pressedColor: Color
    var pressedBackgroundColor: Color

    func makeBody(configuration: Self.Configuration) -> some View {
      configuration.label
        .foregroundColor(configuration.isPressed ? pressedColor : foregroundColor)
        .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color(red: 0, green: 0, blue: 0.8) : .blue)
            .background(Color.white.opacity(0))
    }
}

struct ActionButton: View {
    var image: String
    var title: String

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Image(image).actionButtonStyle()
            Text(title).buttonStyle(ActionButtonStyle())
        }
    }
}

extension Image {
    func actionButtonStyle() -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 1)
            )
   }
}
