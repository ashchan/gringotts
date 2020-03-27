//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MarketView: View {
    var body: some View {
        NavigationView {
            MarketMasterView(selectedSection: .constant("Explore"))
            MarketDetailView()
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView()
    }
}
