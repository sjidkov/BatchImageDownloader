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
    @State var selectedItem: SearchResult?
    
    @State var showingGoogleSearch: Bool = false
    @State var showingWebLink: Bool = false
    @State var showActionView = false
    @State var downloadingData = false
    @State private var showingDetail = false
    
    
    var body: some View {
        NavigationView() {
            GeometryReader { geo in
                VStack() {
                    //to google search webview
                    searchWebViewNavLink
                    if selectedItem != nil {
                        //to full screen image view
                        fullScreenImageNavLink
                        //to image artible link webview
                        imageArticleNavLink
                    }
                    //image results
                    if items.count > 0 && showingSearchResults {
                        imageSearchResultsView
                    } else {
                        //title view
                        titleView
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
            .onAppear {
                self.showingGoogleSearch = false
            }
            //how to use view
            .sheet(isPresented: $showingDetail) {
                InfoView().padding()
            }
            
            //action sheet for google search and batch download
            .actionSheet(isPresented: $showActionView, content: {
                self.extraFunctionsActionSheet
            })
            
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    toolBar
                }
            }
        }
    }
    
    //MARK : - View Components
    
    //navLinks
    var searchWebViewNavLink: some View {
        NavigationLink(destination: BrowserView(model: WebViewModel(link: browserLink, type: "website", name: "google")), isActive: $showingGoogleSearch) { EmptyView() }
    }
    
    var fullScreenImageNavLink: some View {
        NavigationLink(destination: FullImageView(image: UIImage(data: selectedItem!.imageData ?? Data()) ?? UIImage(), shareButtonAction: {
            actionSheet(data: selectedItem!.imageData)
        }), isActive: $showingFullImage) { EmptyView() }
    }
    
    var imageArticleNavLink: some View {
        NavigationLink(destination: BrowserView(model: WebViewModel(link: selectedItem!.linkURLString ?? "error", type: "website", name: selectedItem!.title ?? "error")), isActive: $showingWebLink) { EmptyView() }
    }
    
    //ScrollView
    var imageSearchResultsView: some View {
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
                        ImageCard(shareButtonAction: {
                            actionSheet(data: item.imageData)
                        }, deleteButtonAction: {
                            deleteItem(item: item)
                        }, item: item, selectedItem: $selectedItem, showingFullImage: $showingFullImage, showingWebLink: $showingWebLink).padding(5)
                    }
                }
            }
        }
    }
    
    //TitleView
    var titleView: some View {
        VStack {
            //Title HStack -> Two color
            HStack() {
                Image(systemName: "magnifyingglass").foregroundColor(.titleColor1)
            }.font(.system(size: 60, weight: .semibold, design: .rounded))
            HStack() {
                Image(systemName: "photo").foregroundColor(.titleColor3)
            }.font(.system(size: 60, weight: .semibold, design: .rounded))
            HStack() {
                Image(systemName: "square.and.arrow.down.on.square").foregroundColor(.titleColor5)
            }.font(.system(size: 60, weight: .semibold, design: .rounded))
        }
    }
    
    //Toolbar
    var toolBar: some View {
        HStack() {
            searchTextField
            Spacer()
            searchFieldButtons
        }.padding(.leading)
        .frame(width: UIScreen.main.bounds.size.width)
    }
    
    //tool bar view components
    var searchTextField: some View {
        HStack() {
            //search icon and progress indicator -> ZStack used for alignment reasons
            ZStack() {
                if !downloadingData {
                    Image(systemName: "magnifyingglass").foregroundColor(items.count > 0 ? .green : .gray)
                } else {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.yellow))//.padding()
                }
            }
            //textfield for search
            TextField("search here...",
                      text: $searchTerm,
                      
                      onEditingChanged: {
                        _ in print("changed")
                        print("\(searchTerm)\(browserLink)")
                      },
                      onCommit: {
                        print("commit")
                        clearResults()
                        setSearchURLStrings()
                        getResults()
                      })
            Spacer()
        }.frame(width: UIScreen.main.bounds.size.width * 0.7)
        .padding([.all], 6)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(downloadingData ? Color.yellow : (items.count > 0 ? Color.green : Color.blue), lineWidth: 1)
        )
        
    }
    
    //clear, info, and showExtraMenu buttons
    var searchFieldButtons: some View {
        HStack() {
            if items.count > 0 {
                clearResultsButton
            } else {
                infoButton
            }
            showExtraMenuButton
        }.padding(.trailing)
    }
    
    //clears results and resets search term
    var clearResultsButton: some View {
        Button(action: {
            if !searchTerm.isEmpty {
                searchTerm = ""
            }
            clearResults()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(.red)
        }
    }
    
    //shows infoView
    var infoButton: some View {
        Button(action: {
            self.showingDetail.toggle()
        }) {
            Image(systemName: "info.circle.fill")
                .renderingMode(.original)
                .font(.title3)
            
        }
    }
    
    //shows extra menu action view
    var showExtraMenuButton: some View {
        Button(action: {
            self.showActionView.toggle()
        }) {
            Image(systemName: "ellipsis.circle")
                .font(.title3)
                .foregroundColor(.orange)
        }
    }
    
    //action sheet for batch download and manual google search
    var extraFunctionsActionSheet: ActionSheet {
        var sheet: ActionSheet = ActionSheet(title: Text(""))
        if items.count > 0 {
            sheet = ActionSheet(title: Text("Extra"), message: nil, buttons: [
                //show google search wkwebview button
                .default(Text("Google Search"), action: {
                    // triggers navlink to wkwebview for google search
                    self.showingGoogleSearch.toggle()
                }),
                //show batchDownload action sheet button
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
    
    
}

//MARK: - View Functions
extension ContentView {
    //configure and present single image download/share action sheet
    func actionSheet(data: Data?) {
        guard let data = data else { return }
        let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: { () -> Void in
            print("image saved")
        })
    }
    
    //configure and present batch dowload/share action sheet
    func batchActionSheet(data: [Data]) {
        if data.count > 0 {
            let av = UIActivityViewController(activityItems: data, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: { () -> Void in
                print("images saved")
            })
        }
    }
    
    //gets array of image data for batch download action sheet
    private func getDataArrayFromSearchResults() -> [Data] {
        var dataArray: [Data] = []
        for item in items {
            if let data = item.imageData {
                dataArray.append(data)
            }
        }
        return dataArray
    }
    
    //checks if you can unwrap an image from Data?
    private func dataHasImage(data: Data?) -> Bool {
        if let data = data, let _ = UIImage(data: data) {
            return true
        } else {
            return false
        }
    }
    
    //cleans and formats searchTerm and browserURL
    func setSearchURLStrings() {
        if self.searchTerm != "" {
            let base = "https://www.google.ca/search?client=safari&q="
            
            //trim start of white spaces
            let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //remove all non a-z 0-9 from search results
            let pattern = "[^A-Za-z0-9]+"
            let result = trimmed.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
            
            //remove all white spaces
            let formatted = result.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            
            //set search term
            searchTerm = formatted
            //set browser link
            browserLink =  base + formatted
        } else {
            browserLink = "https://www.google.ca/search?client=safari"
        }
    }
}

//MARK: - Core Data Fuctions
extension ContentView {
    
    //gets search results
    private func getResults() {
        //check for empty search
        guard !searchTerm.isEmpty else {
            return
        }
        
        //make parser using search term
        parser = GoogleImageParser(searchTerm: searchTerm)
        
        //make temp core data entries from parser results
        for item in parser.results {
            //check results quality
            if let imageURL = item.imageURL, let linkURL = item.articleURL{
                //toggle showing results to change view
                showingSearchResults = true
                //start async image data download
                DispatchQueue.global().async {
                    //change indicators and view colors in nav bar to show downloading
                    downloadingData = true
                    //check if data exists
                    if let data = try? Data(contentsOf: imageURL) {
                        //add item
                        addItem(imageURL: imageURL, linkURL: linkURL, title: item.title ,data: data)
                        //change indicators and view colors in nav bar to show finished
                        downloadingData = false
                    }
                }
            }
        }
        
        //save items in temp storage
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
    
    //delete all core data items
    private func clearResults() {
        showingSearchResults = false
        for item in items {
            self.viewContext.delete(item)
        }
    }
    
    //add searchResult item
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
    
    //delete searchResult item
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
