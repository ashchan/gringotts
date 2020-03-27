//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MarketDetailView: View {
    var body: some View {
        ZStack {
            ScrollView {
                Image("MarketPlaceholder")
                    .resizable()
                    //.scaledToFit()
            }.blur(radius: 5)

            Text("Not open yet due to regulation reason.")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(30)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(10)
        }.frame(minWidth: 500)
    }
}

struct MarketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MarketDetailView()
    }
}
