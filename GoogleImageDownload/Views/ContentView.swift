//
//  ContentView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SearchResult.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<SearchResult>

    @State var parser = GoogleImageParser(searchTerm: "test")
    @State var searchTerm = ""
    @State var browserLink = "https://www.google.ca/search?client=safari"
    @State var showingSearchResults: Bool = false
    
    @State var showingFullImage: Bool = false
    @State var showingGoogleSearch: Bool = false
    @State var showingWebLink: Bool = false
    @State var showActionView = false
    @State var downloadingData = false
    @State private var showingDetail = false
    
    var body: some View {
        NavigationView() {
            GeometryReader { geo in
                VStack() {
                    NavigationLink(destination: BrowserView(model: WebViewModel(link: browserLink, type: "website", name: "google")), isActive: $showingGoogleSearch) { EmptyView() }
                    //show Image results

                    if items.count > 0 && showingSearchResults {
                        ScrollView {
                            LazyVStack(alignment: .center, spacing: 0) {
                                HStack() {
                                    Spacer()
                                    Text("\(items.count)").foregroundColor(.titleColor3)
                                    Text("images").foregroundColor(.titleColor5)
                                    Text("found").foregroundColor(.titleColor1)
                                    Spacer()
                                }.font(.largeTitle).padding()
                                ForEach(items) { item in
                                    if dataHasImage(data: item.imageData) {
                                        NavigationLink(destination: FullImageView(image: UIImage(data: item.imageData ?? Data()) ?? UIImage(), shareButtonAction: {
                                            actionSheet(data: item.imageData)
                                        }), isActive: $showingFullImage) { EmptyView() }
                                        NavigationLink(destination: BrowserView(model: WebViewModel(link: item.linkURLString ?? "error", type: "website", name: item.title ?? "error")), isActive: $showingWebLink) { EmptyView() }
                                        ImageCard(shareButtonAction: {
                                            actionSheet(data: item.imageData)
                                        }, deleteButtonAction: {
                                            deleteItem(item: item)
                                        }, item: item, showingFullImage: $showingFullImage, showingWebLink: $showingWebLink).padding(5)
                                    }
                                }
                            }
                        }
                    } else {
                        TitleCard()//.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                
                }
            .onAppear {
                print("main appeared")
                self.showingGoogleSearch = false
            }
            .sheet(isPresented: $showingDetail) {
                InfoView().padding()
                    }
            
            .actionSheet(isPresented: $showActionView, content: {
                        self.extraFunctionsActionSheet
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        HStack() {
                        //Spacer()
                           HStack() {
                                ZStack() {
                                    if !downloadingData {
                                        Image(systemName: "magnifyingglass").foregroundColor(items.count > 0 ? .green : .gray)
                                    } else {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.yellow))//.padding()
                                    }
                                }
                                
                                TextField("search here...",
                                          text: $searchTerm,
                                          
                                          onEditingChanged: {
                                            _ in print("changed")
                                            print("\(searchTerm)\(browserLink)")
                                          },
                                          onCommit: {
                                            print("commit")
                                            clearResults()
                                            getResults()
                                            setSearchURLString()
                                          })//.padding([.leading, .trailing])
                                Spacer()
                           }.frame(width: UIScreen.main.bounds.size.width * 0.7)
                            .padding([.all], 6)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(downloadingData ? Color.yellow : (items.count > 0 ? Color.green : Color.blue), lineWidth: 1)
                            )
                            Spacer()
                            HStack() {
                                if items.count > 0 {
                                    Button(action: {
                                        if !searchTerm.isEmpty {
                                            searchTerm = ""
                                        }
                                        clearResults()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                } else {
                                    Button(action: {
                                        self.showingDetail.toggle()
                                    }) {
                                        Image(systemName: "info.circle.fill")
                                            .renderingMode(.original)
                                    }
                                }
                                Button(action: {
                                    self.showActionView.toggle()
                                }) {
                                    Image(systemName: "ellipsis.circle")
                                        .foregroundColor(.orange)
                                }
                            }.padding(.trailing)
                        }.padding(.leading).frame(width: UIScreen.main.bounds.size.width)
                }
            }
        }
    }
    
    var extraFunctionsActionSheet: ActionSheet {
        var sheet: ActionSheet = ActionSheet(title: Text(""))
        if items.count > 0 {
            sheet = ActionSheet(title: Text("Extra"), message: nil, buttons: [
            
            .default(Text("Google Search"), action: {
                // triggers navlink to wkwebview for google search
                self.showingGoogleSearch.toggle()
            }),
            .default(Text("Batch Download"), action: {
                // presents sheet for batch image download
                self.batchActionSheet(data: self.getDataArrayFromSearchResults())
            }),
            .cancel()
        ]) } else {
            sheet = ActionSheet(title: Text("Extra"), message: nil, buttons: [
                
                .default(Text("Google Search"), action: {
                    self.showingGoogleSearch.toggle()
                }),
                
                .cancel()
            ])
        }
        return sheet
    }
    
    func actionSheet(data: Data?) {
        guard let data = data else { return }
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: { () -> Void in
            print("image saved")
        })
    }
    
    func getDataArrayFromSearchResults() -> [Data] {
        var dataArray: [Data] = []
        for item in items {
            if let data = item.imageData {
                dataArray.append(data)
            }
        }
        return dataArray
    }
    
    func batchActionSheet(data: [Data]) {
        if data.count > 0 {
            let av = UIActivityViewController(activityItems: data, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: { () -> Void in
                print("image saved")
            })
        }
    }

    private func dataHasImage(data: Data?) -> Bool {
        if let data = data, let _ = UIImage(data: data) {
            return true
        } else {
            return false
        }
    }
    
    
    private func getResults() {

        guard !searchTerm.isEmpty else {
            return
        }
        
        parser = GoogleImageParser(searchTerm: searchTerm)
        
        for item in parser.results {
            if let imageURL = item.imageURL, let linkURL = item.articleURL{
                showingSearchResults = true
                DispatchQueue.global().async {
                    downloadingData = true
                    
                    if let data = try? Data(contentsOf: imageURL) {
                        addItem(imageURL: imageURL, linkURL: linkURL, title: item.title ,data: data)
                        downloadingData = false
                    }
                }
            }
        }
        
        if showingSearchResults {
        do {
            try viewContext.save()
           
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        }
    }
    
    private func clearResults() {
        
        showingSearchResults = false
        
        for item in items {
            self.viewContext.delete(item)
        }
    }
    
    private func addItem(imageURL: URL, linkURL: URL, title: String, data: Data) {
        withAnimation {
            let newItem = SearchResult(context: viewContext)
            newItem.timestamp = Date()
            newItem.imageData = data
            newItem.imageURLString = "\(imageURL)"
            newItem.linkURLString = "\(linkURL)"
            newItem.title = title
        }
    }
    
    private func deleteItem(item: SearchResult) {
        
        self.viewContext.delete(item)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func setSearchURLString() {
        
        if self.searchTerm != "" {
            let base = "https://www.google.ca/search?client=safari&q="
            let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
            let formatted = trimmed.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            browserLink =  base + formatted
        } else {
            browserLink = "https://www.google.ca/search?client=safari"
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
