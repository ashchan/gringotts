//
// UDT Hackathon Project Gringotts by Team Goblins
// Copyright © 2020 Goblins. all rights reserved.
// 

import SwiftUI

struct MarketView: View {
    @EnvironmentObject var store: Store
    @State var publishFormExpanded = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            List {
                HStack(alignment: .top) {
                    Text("Market")
                        .font(.title)
                    Spacer()

                    Button(action: {
                        self.refresh()
                    }) {
                        Text("Refresh")
                    }
                }
                .padding()

                ForEach(self.store.state.matches) { match in
                    MatchRow(match: match)
                }
            }
            .onAppear {
                self.refreshIfNecessary()
            }

            VStack {
                HStack {
                    Button(action: {
                        self.publishFormExpanded = true
                    }) {
                        Text("I need CKB!")
                    }
                    Spacer()
                }
            }
            .padding()
            .background(Color.blue)

            if publishFormExpanded {
                MatchForm(isPresented: $publishFormExpanded)
                    .background(Color.yellow)
            }
        }
    }
}

extension MarketView {
    func refresh() {
        store.loadMatches()
    }

    func refreshIfNecessary() {
        if store.state.matches.isEmpty {
            refresh()
        }
    }
}

struct MarketView_Previews: PreviewProvider {
    static var previews: some View {
        MarketView()
            .environmentObject(Store())
    }
}
