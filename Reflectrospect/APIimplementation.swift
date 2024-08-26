//
//  APIimplementation.swift
//  Reflectrospect
//
//  Created by Sindhu Rallabhandi on 4/12/24.
//

import Foundation

class APIimplementation{
    private var urlAsString = ""
    private let apiKey = "35e1fec5956a43e9b3ddbf941f0386a3"
    private var articles = [ArticleInfo]()
    private var articlesList = [ListArticles]()
    private var query: String = ""
    init(category:String){
        self.query = category
    }
    
    func fetchArticles(completion: @escaping ([ListArticles]) -> Void){
        urlAsString = "https://newsapi.org/v2/everything?q=\(query) NOT suicide NOT quiz&language=en&apiKey=35e1fec5956a43e9b3ddbf941f0386a3"
        
   
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        let jsonQuery = urlSession.dataTask(with: url){ data, response, error -> Void in
            if(error != nil){
                print(error!.localizedDescription)
            }
            
            do{
                let decoder = JSONDecoder()
                let jsonResult = try decoder.decode(Articles.self, from: data!)
                self.articles = jsonResult.articles
                for article in self.articles{
                    let title = article.title.lowercased()
                    if title == "[removed]"{
                        continue
                    }
                    else{
                        let listArticle = ListArticles(title: article.title, url: article.url)
                        self.articlesList.append(listArticle)
                    }
                }
                completion(self.articlesList)
            }
            catch{
                print("Error decoding JSON:", error.localizedDescription)
            }
        }
        jsonQuery.resume()
    }
}


struct Articles: Codable{
    let status: String
    let totalResults: Int
    let articles: [ArticleInfo]
}

struct ArticleInfo: Codable{
    let source: SourceData
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: String
    let content: String?
}

struct SourceData:Codable{
    let id: String?
    let name: String
}

struct ListArticles:Identifiable{
    var id = UUID()
    let title: String
    let url: URL
}
