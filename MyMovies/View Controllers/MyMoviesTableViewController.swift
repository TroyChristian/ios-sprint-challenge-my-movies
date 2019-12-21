//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController {
let movieController = MovieController()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let seenDescriptor = NSSortDescriptor(key: "hasWatched", ascending:true)
        fetchRequest.sortDescriptors = [seenDescriptor] //descriptor tracking hasWatched bool
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "hasWatched", cacheName: nil)
        
        frc.delegate = self 
        
        do {
            try frc.performFetch()
        } catch {
            fatalError("Error retreiving movies during fetch: \(error)")
        }
        return frc
    }()

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchedResultsController.sections?[section].name == "0" {
            return "Unwatched"
        } else {
            return "Watched"
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     guard   let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MovieTableViewCell else { return UITableViewCell() }
        let movie = fetchedResultsController.object(at: indexPath)
        cell.titleLabel.text = movie.title
        cell.movie = movie
        return cell

       

    }
    

    
  
    

    
  
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movie = fetchedResultsController.object(at:indexPath)
            movieController.deleteMovie(movie: movie)
        }    
    }
    

    
}
 
extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.beginUpdates()
     }
     
     func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
         tableView.endUpdates()
     }
     
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
         switch type {
         case .insert:
             tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
         case .delete:
             tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
         default:
             break
         }
     }
     func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
         switch type {
         case .insert:
             guard let newIndexPath = newIndexPath else { return }
             tableView.insertRows(at: [newIndexPath], with: .automatic)
         case .update:
             guard let indexPath = indexPath else { return }
                       tableView.reloadRows(at: [indexPath], with: .automatic)
         case .move:
             guard let oldIndexPath = indexPath,
             let newIndexPath = newIndexPath else { return }
             tableView.deleteRows(at: [oldIndexPath], with: .automatic)
                       tableView.insertRows(at: [newIndexPath], with: .automatic)
         case .delete:
             guard let indexPath = indexPath else { return }
                                tableView.deleteRows(at: [indexPath], with: .automatic)
         @unknown default:
             fatalError()
         }
     }
 }



