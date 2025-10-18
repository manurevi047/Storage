import SwiftUI

struct NotesView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading notes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if notes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No notes yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap the + button to create your first note")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink(destination: NoteDetailView(note: note)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(note.content)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    Text(note.updatedAt, style: .relative)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView { note in
                    notes.insert(note, at: 0)
                }
            }
            .onAppear {
                loadNotes()
            }
        }
    }
    
    private func loadNotes() {
        isLoading = true
        Task {
            let fetchedNotes = await supabaseManager.fetchNotes()
            await MainActor.run {
                self.notes = fetchedNotes
                self.isLoading = false
            }
        }
    }
    
    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            Task {
                let success = await supabaseManager.deleteNote(id: note.id)
                if success {
                    notes.remove(at: index)
                }
            }
        }
    }
}

struct NoteDetailView: View {
    @State var note: Note
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedContent = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                
                TextField("Content", text: $editedContent, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(10...)
            } else {
                Text(note.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(note.content)
                    .font(.body)
                
                Text("Updated \(note.updatedAt, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveNote()
                    } else {
                        startEditing()
                    }
                }
            }
        }
    }
    
    private func startEditing() {
        editedTitle = note.title
        editedContent = note.content
        isEditing = true
    }
    
    private func saveNote() {
        let updatedNote = Note(
            id: note.id,
            title: editedTitle,
            content: editedContent,
            userId: note.userId,
            createdAt: note.createdAt,
            updatedAt: Date()
        )
        
        Task {
            if let savedNote = await supabaseManager.updateNote(updatedNote) {
                await MainActor.run {
                    self.note = savedNote
                    self.isEditing = false
                }
            }
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var title = ""
    @State private var content = ""
    @State private var isLoading = false
    
    let onNoteAdded: (Note) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Content", text: $content, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(10...)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(isLoading || title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        isLoading = true
        Task {
            if let note = await supabaseManager.createNote(title: title, content: content) {
                await MainActor.run {
                    onNoteAdded(note)
                    dismiss()
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NotesView()
}