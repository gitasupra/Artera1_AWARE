import SwiftUI

struct ContentView: View {
    @State private var enableDataCollection = false
    @State private var shouldHide = false

    var body: some View {
        NavigationView {
            TabView {
                // Page 1
                Page1View()
                    .tabItem {
                        Label("AWARE", systemImage: "person.circle.fill")
                    }

                // Page 2
                Page2View(enableDataCollection: $enableDataCollection, shouldHide: $shouldHide)
                    .tabItem {
                        Label("Page 2", systemImage: "info.circle")
                    }
            }
            .navigationTitle("AWARE App")
        }
    }
}

struct Page1View: View {


    var body: some View {
        VStack {
            Text("AWARE")
                .font(.largeTitle)
                .padding()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100)) // Adjust the font size to make the image bigger
                .foregroundColor(.gray)
                .padding()


            
        }
    }
}

struct Page2View: View {
    @Binding var enableDataCollection: Bool
    @Binding var shouldHide: Bool
    var body: some View {
        VStack {
//            Text("Page 2 Content")
//                .font(.largeTitle)
//                .padding()
            
            if (enableDataCollection) {
                if !shouldHide {
                    Text("Disable Data Collection on your Apple Watch")
                    Button {
                        enableDataCollection.toggle()
                        print(enableDataCollection)
                    } label: {
                        Image(systemName: "touchid")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .background(Color.green)
                            .controlSize(.extraLarge)
                    }
                }
            } else {
                Text("Enable Data Collection on your Apple Watch")
                Button {
                    enableDataCollection.toggle()
                    print(enableDataCollection)
                } label: {
                    Image(systemName: "touchid")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(Color.red)
                        .controlSize(.extraLarge)
                }
            }
        }
    }
}

#Preview{
    ContentView()
}
