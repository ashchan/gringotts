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

struct BorrowerView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowerView()
    }
}
