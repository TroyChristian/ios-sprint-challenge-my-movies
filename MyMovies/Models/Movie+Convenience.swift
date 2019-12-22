//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_219 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData

extension Movie {
    var movieRepresentation: MovieRepresentation? {
        guard let title = title,
            let identifier = identifier?.uuidString else {return nil}
        return MovieRepresentation(title:title, identifier: identifier, hasWatched: hasWatched)
    }
    /*
     identifier?.uuidString ?? ""
     */
   @discardableResult convenience init(title:String, identifier: UUID = UUID(), hasWatched:Bool?, context: NSManagedObjectContext =  CoreDataStack.shared.mainContext) {
        
        self.init(context:context)
        
        self.title = title
        self.identifier = identifier
        self.hasWatched = hasWatched ?? false
    }
    
    @discardableResult convenience init?(movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = UUID(uuidString: movieRepresentation.identifier!) else {return nil}
        
        self.init(title: movieRepresentation.title,
                  identifier:identifier,
                  hasWatched: movieRepresentation.hasWatched,
                  context:context)
    }
}
