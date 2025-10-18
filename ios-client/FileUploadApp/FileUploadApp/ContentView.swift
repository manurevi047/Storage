import SwiftUI

struct ContentView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        Group {
            if supabaseManager.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            supabaseManager.checkAuthStatus()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
            
            FilesView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Files")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    ContentView()
}