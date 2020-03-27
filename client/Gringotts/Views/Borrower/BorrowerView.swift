//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct BorrowerView: View {
    var body: some View {
        NavigationView {
            BorrowerMasterView()
            BorrowerDetailView()
        }
    }
}

struct BorrowerMasterView: View {
    var body: some View {
        VStack {
            Text("Builder Holder")
            Spacer()
        }
        .frame(minWidth: 220, maxWidth: 800)
    }
}

struct BorrowerDetailView: View {
    var body: some View {
        List {
            Text("Builder Detail")
                .font(.largeTitle)
                .padding()

        }
        .onAppear {
        }
    }
}

struct BorrowerView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowerView()
    }
}
