//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MarketMasterView: View {
    @Binding var selectedSection: String?

    var sections = ["Explore", "Popular", "New"]

    var body: some View {
        List(selection: $selectedSection) {

            ForEach(self.sections, id: \.self) { section in
                MarketSectionRow(section: section)
                    .tag(section)
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 220, maxWidth: 400)
    }
}

struct MarketSectionRow: View {
    let section: String

    var body: some View {
        HStack {
            Text(section)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 10)
    }
}

struct MarketMasterView_Previews: PreviewProvider {
    static var previews: some View {
        MarketMasterView(selectedSection: .constant("Explore"))
    }
}
