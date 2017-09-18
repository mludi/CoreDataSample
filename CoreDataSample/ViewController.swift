//
//  ViewController.swift
//  CoreDataSample
//
//  Created by Matthias Ludwig on 15.09.17.
//  Copyright © 2017 Matthias Ludwig. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    // MARK: - Constants
    fileprivate let sortKey = "date"
    fileprivate let reuseIdentifier = "Cell"
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CoreData Sample"
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem = item
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Actions
    @objc func add() {       
        for _ in 1...100 {
            let message = Message(context: managedObjectContext)
            message.date = NSDate()
            message.body = String.random()
        }
        do {
            try managedObjectContext.save()
        }
        catch {
            print("error while saving \(error)")
        }        
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let message = self.fetchedResultsController.object(at: indexPath)
        guard let date = message.date, let body = message.body else {
            fatalError()
        }
        cell.textLabel?.text = "\(date) with \(body)"
        return cell
    }
    
    // MARK: - Properties
    fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let moc = appDelegate?.persistentContainer.viewContext else {
            fatalError()
        }
        return moc
    }()

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchBatchSize = 20

        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        return fetchedResultsController
    }()
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            break
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let newIndexPath = newIndexPath else {
            return
        }
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            break
        case .update:
            break
        case .move:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

// MARK: - Helper
extension String {
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
