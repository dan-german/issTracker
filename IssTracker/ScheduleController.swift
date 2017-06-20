import UIKit
import ObjectMapper

class ScheduleController: UITableViewController {
    
    
    //MARK: - Pass Times Arrays
    
    var riseHoursForSectionStrings = [[String]]()
    var fallHoursForSectionStrings = [[String]]()
    var daysMonthYearStrings = [String]()
    var uniqueStrings = [String]()
    var sortedUniqueStrings = [String]()
    var rawDates = [Date]()
    var sortedDates = [Date]()
    var passTimes = [PassTime]()
    var emojiArray = [[String]]()
    
    //MARK: - Properties
    
    let passes = 30
    let dateFormatter = DateFormatter()
    let dateFormatter2 = DateFormatter()
    var timer = Timer()
    var firstCellPath: IndexPath?
    var firstCell: PassTimeCell?
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        dateFormatter2.dateFormat = "HH:mm:ss"
        
        tableView.register(PassTimeCell.self, forCellReuseIdentifier: "passTimeCell")
        tableView.sectionHeaderHeight = 30
        tableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.setupPassTimeSchedule), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(progressBarAndTitleTimer), userInfo: nil, repeats: true)
        
        let height: CGFloat = 15
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
        self.tableView.contentInset = UIEdgeInsetsMake(20,0,0,0);
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshTableView), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        self.setupPassTimeSchedule()
    }
    
    //MARK: - Table View Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return riseHoursForSectionStrings[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "passTimeCell", for: indexPath) as! PassTimeCell
        cell.riseTimeLabel.text = "↑ " + riseHoursForSectionStrings[indexPath.section][indexPath.row]
        cell.fallTimeLabel.text = "↓ " + fallHoursForSectionStrings[indexPath.section][indexPath.row]
        cell.emojiLabel.text = emojiArray[indexPath.section][indexPath.row]
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return uniqueStrings.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return sortedUniqueStrings[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        return 11.5
    }
    
    //MARK: -
    
    func refreshTableView(sender: UIRefreshControl) {
        
        
        self.setupPassTimeSchedule()
        self.tableView.reloadData()
        sender.endRefreshing()
    }
    
    public func setupPassTimeSchedule() {
        
        
        if ConnectionChecker.isConnected() {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.populateArrays()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        } else {
            
            let alert = UIAlertController(title: "Failed to retrieve ISS pass times data", message: "Please check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func populateArrays() {
        
        
        emptyArrays()
        
        PassTimesManager.Instance.updatePassTimes()
        
        passTimes = PassTimesManager.Instance.passTimes
        
        // Make a "Friday, Apr 21, 2017" type string array
        for i in 0..<passTimes.count  {
            
            daysMonthYearStrings.append(passTimes[i].riseDate)
        }
        
        // Copy the array above into an array of unique dates only (no double or more dates)
        uniqueStrings = Array(Set(daysMonthYearStrings))
        
        // Translate unique string into unique dates
        for string in uniqueStrings {
            
            rawDates.append(dateFormatter.date(from: string)!)
        }
        
        // Sort the unique dates array chronologically
        sortedDates = rawDates.sorted(by: { $0.compare($1) == .orderedAscending })
        
        // Making a new array of unique strings, but sorted chronologically
        for date in sortedDates {
            
            let stringDate = dateFormatter.string(from: date)
            sortedUniqueStrings.append(stringDate)
        }
        
        for i in 0..<sortedUniqueStrings.count {
            
            // Make section for each day of sighting
            riseHoursForSectionStrings.append([])
            fallHoursForSectionStrings.append([])
            emojiArray.append([])
            
            for j in 0..<passTimes.count{
                
                //Populate the section/day with sightings
                if passTimes[j].wholeDate.hasSuffix(sortedUniqueStrings[i]){
                    
                    riseHoursForSectionStrings[i].append(passTimes[j].riseHour)
                    fallHoursForSectionStrings[i].append(passTimes[j].fallHour)
                    emojiArray[i].append(passTimes[j].emoji)
                }
            }
        }
    }
    
    private func emptyArrays() {
        
        
        riseHoursForSectionStrings.removeAll()
        fallHoursForSectionStrings.removeAll()
        daysMonthYearStrings.removeAll()
        uniqueStrings.removeAll()
        sortedUniqueStrings.removeAll()
        rawDates.removeAll()
        sortedDates.removeAll()
        passTimes.removeAll()
        emojiArray.removeAll()
    }
    
    func secondsToString(time: TimeInterval) -> String {
        
        
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if time < 3600 {
            return String(format:"%02i:%02i", minutes, seconds)
        } else if time < 60 {
            return String(format:"%02i" , seconds)
        } else {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
    }
    
    @objc private func progressBarAndTitleTimer() {
        
        
        if !passTimes.isEmpty {
            
            let riseTime = passTimes[0].risetime
            let closestDate = Date(timeIntervalSince1970:riseTime!)
            let secondsToPassTime = closestDate.timeIntervalSince(Date())
            
            if secondsToPassTime < 0 {
                
                firstCellPath = IndexPath.init(row: 0, section: 0)
                firstCell = tableView.cellForRow(at: firstCellPath!) as! PassTimeCell?
                
                navigationItem.title = "Next pass: Now!"
                let fallTime = passTimes[0].risetime! + Double(passTimes[0].duration!)
                let fallTimeDate = Date(timeIntervalSince1970: fallTime)
                let secondsToFallTime = fallTimeDate.timeIntervalSince(Date())
                firstCell?.progressBar.progress = 1 - Float(secondsToFallTime / Double(passTimes[0].duration!))
                
                if secondsToFallTime < 0 {
                    firstCell?.progressBar.progress = 0
                    setupPassTimeSchedule()
                }
            } else {
                navigationItem.title = "Next pass: " + (secondsToString(time: secondsToPassTime))
                firstCell?.progressBar.progress = 0
            }
        }
    }
}


