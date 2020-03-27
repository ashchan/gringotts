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

struct LenderView_Previews: PreviewProvider {
    static var previews: some View {
        LenderView()
    }
}
