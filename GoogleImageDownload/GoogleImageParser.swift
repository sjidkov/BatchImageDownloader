//
//  GoogleImageParser.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import Foundation

struct SearchResultData {
    let imageURL: URL?
    let articleURL: URL?
    let title: String
    let id = UUID()
}

class GoogleImageParser {
    
    var searchURL: String
    var results: [SearchResultData]
    
    init(searchTerm: String) {
        self.searchURL = "Test"
        self.results = []
        
        
        self.getSearchURLString(searchTerm: searchTerm)
        self.getSearchResults(string: self.searchURL)
    }
    
    func getSearchURLString(searchTerm: String) {
        
        let base = "https://images.google.com/search?tbm=isch&q="
        
        //trim start of white spaces
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        //remove all non a-z 0-9 from search results
        let pattern = "[^A-Za-z0-9]+"
        let result = trimmed.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        
        //remove all white spaces
        let formatted = result.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        self.searchURL = base + formatted
    }
    
    func getSearchResults(string: String) {
        
        guard let myURL = URL(string: searchURL) else {
            print("Error: \(searchURL) doesn't seem to be a valid URL")
            return
        }
        
        do {
            
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            print("got html")
            parseHTMLString(htmlString: myHTMLString)
    
            } catch let error {
            print("Error: \(error)")
        }
    }
    
    func parseHTMLString(htmlString: String) {
        
        //get part of html that contains links
        let mainPart = matches(for: #"(sideChannel:\s\{\}\}\))([\s\S]*)(sideChannel:\s\{\}\}\)\;\<\/script\>)"#, in: htmlString)
        
        //pulls outs containers that have website link, image link, and image description
        let links = matches(for: #"(\[1\,\[0,)([\s\S]*?)(?=\,\[1\,\[0,)"#, in: mainPart.first ?? "error")
        
        for a in links {
            
            //return array that has three htmls -> first is encrypted, second is image link, third is website article
            let htmls = matches(for: #"(https:)([\s\S]*?)(?=")"#, in: a)
            
            //returns title strings (?<=\}\]\n,"[0-9]{4}":\[null,)([\s\S]*?)(])
            let titles = matches(for: #"(?<=\}\]\n,"[0-9]{4}":\[null,)([\s\S]*?)(])"#, in: a)
            
            //returns formatted title strings (?<=\")(.*?)(?=\")
            let titlesTrimmed = matches(for: #"(?<=\")(.*?)(?=\")"#, in: String(titles.first ?? "error"))
            
            if htmls.count > 2  && !titles.isEmpty {
                
                if let imageURL = URL(string: htmls[1]), let linkURL = URL(string: htmls[2]), let title = titlesTrimmed.first {
                    results.append(SearchResultData(imageURL: imageURL, articleURL: linkURL, title: title))
                }
            }
        }
    }
    
    //runs regex on string and returns all matches.
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
