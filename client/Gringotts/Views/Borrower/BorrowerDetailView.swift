//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct BorrowerDetailView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List {
            Text("Builder Detail")
                .font(.largeTitle)
                .padding()
        }
    }
}

struct BorrowerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowerDetailView().environmentObject(Store())
    }
}
