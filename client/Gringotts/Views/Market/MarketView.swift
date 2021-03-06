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
            .padding(EdgeInsets(top: 10, leading: 6, bottom: 32, trailing: 6))
            .onAppear {
                self.refreshIfNecessary()
            }


            if showPublishBanner {
                VStack {
                    HStack {
                        Text("Publish. Wait. Holders will offer.")
                            .foregroundColor(.white)
                        Button(action: {
                            self.publishFormExpanded = true
                        }) {
                            Text("I want some CKB!")
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [.purple, .blue, Color(red: 0, green: 0.87, blue: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            }

            if publishFormExpanded {
                MatchForm(isPresented: $publishFormExpanded)
            }
        }
        .background(Color.white)
    }
}

extension MarketView {
    var showPublishBanner: Bool {
        !store.state.settings.builderAddress.isEmpty
    }

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
