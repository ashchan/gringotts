//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct LenderView: View {
    var body: some View {
        NavigationView {
            LenderMasterView()
            LenderDetailView()
        }
    }
}

struct LenderMasterView: View {
    var body: some View {
        VStack {
            Text("Hello Holder")
            Spacer()
        }
        .frame(width: 280)
    }
}

struct LenderDetailView: View {
    var body: some View {
        List{
            Text("Holder Detail")
                .font(.largeTitle)
                .padding()

        }
        .onAppear {
        }
    }
}

struct LenderView_Previews: PreviewProvider {
    static var previews: some View {
        LenderView()
    }
}
