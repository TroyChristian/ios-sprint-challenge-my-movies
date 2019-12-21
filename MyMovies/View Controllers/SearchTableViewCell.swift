//
//  SearchTableViewCell.swift
//  MyMovies
//
//  Created by Lambda_School_Loaner_219 on 12/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    let movieController = MovieController()
      
    @IBAction func addMovieTapped(_ sender: Any) {
        guard let title = titleLabel.text else {return}
        movieController.createMovie(title:title, identifier: UUID(), hasWatched:false)
    }
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    
  
    

}
