//
//  MovieTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_219 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    let movieController = MovieController()
  
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    
    
    @IBOutlet weak var hasWatchedBTN: UIButton!
    @IBAction func hasWatchedBTNTapped(_ sender: Any) {
        guard let movie = movie else {return}
        movie.hasWatched = !movie.hasWatched
        movieController.put(movie:movie)
        CoreDataStack.shared.save()
        updateViews()
    }
    var movie: Movie? {
    didSet {
        updateViews()
    }
    }

    
    func updateViews() {
        guard let movie = movie else {return}
        if movie.hasWatched {
            hasWatchedBTN.setTitle("Watched", for: .normal)
        } else {
            hasWatchedBTN.setTitle("Unwatched", for: .normal)
        }
    }
    
}
