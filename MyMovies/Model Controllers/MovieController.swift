//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData


class MovieController {
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []

    
    init(){
        fetchMovieFromServer()
    }
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    let fireBaseURL = URL(string:"https://mymovies-741fb.firebaseio.com/")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
               
                completion(error)
            }
        }.resume()
    }
    
    func put(movie:Movie, completion: @escaping () -> Void = {}) {
        let identifier = movie.identifier ?? UUID()
        movie.identifier = identifier
        print("I Put the movie \(String(describing: movie.title)) with the identifier \(identifier)")
        
        let requestURL = fireBaseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        guard let movieRepresentation = movie.movieRepresentation
          else {
            print("Failed to assign a movie representation. line 72 MovieController")
            return
        }
        print("I am now a movie representation with the identifier attribute of \(String(describing: movieRepresentation.identifier))" )
        
        do {
            request.httpBody = try JSONEncoder().encode(movieRepresentation)
            
        } catch {
            print("Error encoding the movie representation. line 81 MovieController.")
            completion()
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                print("Error putting movie: \(error) line 89 MovieController")
                completion()
            }
        }.resume()
    }
    
    
    func fetchMovieFromServer(completion: @escaping() -> Void = {}) {
        let requestURL = fireBaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with:requestURL) { data, _, error in
            if let error = error {
                print("Error retreiving movie from server. FetchMovieFromServer line 99. \(error)")
                completion()
            }
            
            guard let data = data else {
                print("Error retreiving movie from server. FetchMovieFromServer line 106. \(String(describing: error))")
                completion()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieRepresentations = Array(try decoder.decode([String: MovieRepresentation].self, from: data).values)
                try self.updateMovies(with: movieRepresentations)
            } catch {
                print("Error decoding movies. MovieController line 116. \(error)")
            }
        }.resume()
    }
    // examine this function for funkiness in deleting movie from server. Movie is missing an identifier.
     private func updateMovies(with representations: [MovieRepresentation]) throws {
         let moviesWithID = representations.filter { $0.identifier != nil }
         let identifiersToFetch = moviesWithID.compactMap { UUID(uuidString: $0.identifier!) }
         let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
         var moviesToCreate = representationsByID
         
         let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
         
         let context = CoreDataStack.shared.container.newBackgroundContext()
         
         context.perform {
             do {
                 let existingMovies = try context.fetch(fetchRequest)
                 
                 for movie in existingMovies {
                     guard let id = movie.identifier,
                         let representation = representationsByID[id] else { continue }
                     self.update(movie: movie, with: representation)
                     moviesToCreate.removeValue(forKey: id)
                 }
                 
                 for representation in moviesToCreate.values {
                    Movie(movieRepresentation: representation, context: context)
                 }
             } catch {
                 print("Error fetching tasks for UUIDs: \(error)")
             }
         }
         
         try CoreDataStack.shared.save(context: context)
     }
     
     private func update(movie: Movie, with representation: MovieRepresentation) {
         movie.title = representation.title
        movie.identifier = UUID(uuidString: representation.identifier!)
         movie.hasWatched = representation.hasWatched ?? false
     }
 
    
    @discardableResult func createMovie(title:String, identifier: UUID, hasWatched: Bool?) -> Movie{
        let context = CoreDataStack.shared.container.newBackgroundContext()
        let movie = Movie(title:title, identifier:identifier, hasWatched:hasWatched, context:context)
        CoreDataStack.shared.save(context:context)
        put(movie:movie)
        
        return movie
    }
    
    func updateMovie(movie:Movie, title:String, identifier: UUID, hasWatched:Bool?) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        guard let hasWatched = hasWatched else {return}
        
        movie.title = title
        movie.hasWatched = hasWatched
        movie.identifier = identifier
        put(movie:movie)
        CoreDataStack.shared.save(context:context)
    }
    
    func deleteMovieFromServer(movieID: UUID, completion: @escaping () -> Void = {}){
      
        let requestURL = fireBaseURL.appendingPathComponent(movieID.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with:request) {(_, _, error) in
            if let error = error {
                print("Error deleting selected movie, MovieController line 186: \(error)" )
                completion()
                return
            }
            print("I have executed deleteMovieFromServer")
            completion()
            
        
        }.resume()
    
    
    
    }
   func deleteMovie(movie:Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        CoreDataStack.shared.save()
    //deleteMovieFromServer(movieID: movie.identifier!)
    }
        



}

