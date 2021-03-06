//
//  SecondViewController.swift
//  portfolio
//
//  Created by Bhavik Shah on 5/1/15.
//  Copyright (c) 2015 shah. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var friendsTableView: UITableView!
    var stockTickerParam:String!
    var stockPriceParam:String!
    var stockGainParam:String!
    
    //stockSymbol, stockPrice, stockSummary,dollarGain, percentGain
    var stocks: [(String, String, String, String, String)] =
    [("AAPL", "130.12", "52 week high 132.44 52 week low 84.24", "12", "2.00"),
        ("GOOG", "540.23", "52 week high 604.23", "-5", "1.00"),
        ("USB", "42.34", "52 week high 45.22", "4", "3.00")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let nib = UINib(nibName: "FriendsCustomTableViewCell", bundle:nil)
        
        friendsTableView.register(nib, forCellReuseIdentifier: "customCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(SecondViewController.stocksUpdated(_:)), name: NSNotification.Name(rawValue: kNotificationStocksUpdated), object: nil)
        
        self.updateStocks()
        
    }
    
    func updateStocks() {
        let stockManager:StockManagerSingleton = StockManagerSingleton.sharedInstance
      //  stockManager.updateListOfSymbols(stocks)
        
        //Repeat this method after 15 secs. (For simplicity of the tutorial we are not cancelling it never)
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: {
                self.updateStocks()
            }
        )
    }
    func stocksUpdated(_ notification: Notification) {
        //var values = Array<Dictionary<String,AnyObject>>()
        //values.append(notification.userInfo as!  Dictionary<String, AnyObject>)
        
        let values = (notification.userInfo as! Dictionary<String,NSArray>)
        let stocksReceived:NSArray = values[kNotificationStocksUpdated]!
        
        stocks.removeAll(keepingCapacity: false)
        for quote in stocksReceived {
            NSLog("inside stocksReceived")
            let quoteDict:NSDictionary = quote as! NSDictionary
            let quoteSymbol = quoteDict["symbol"] as! String
            let lastTradePrice = quoteDict["LastTradePriceOnly"] as! String
            // var dollarGain = quoteDict["Change"] as Double

            let dollarGain = quoteDict["Change"] as! String
            //var changeInPercentString = quoteDict["ChangeinPercent"] as Double
           
            let changeInPercentString = quoteDict["ChangeinPercent"] as! String
            
            let myElement: (String, String, String, String, String) = (quoteSymbol, lastTradePrice, "summary", changeInPercentString, dollarGain)
            stocks.append(myElement)
            
        }

        friendsTableView.reloadData()
        NSLog("Symbols Values updated :)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FriendsCustomTableViewCell = self.friendsTableView.dequeueReusableCell(withIdentifier: "customCell") as! FriendsCustomTableViewCell!
        var (ticker, price, summary, dollargain, percentgain) = stocks[indexPath.row]
        
//        switch stocks[indexPath.row].3 {
//        case let x where x < 0.0:
//            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
//        case let x where x > 0.0:
//            cell.backgroundColor = UIColor(red: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0)
//        case let x:
//            cell.backgroundColor = UIColor(red: 44.0/255.0, green: 186.0/255.0, blue: 231.0/255.0, alpha: 1.0)
//        }
//        
        cell.loadItem(ticker, price: price, summary: summary, dollargain: dollargain, percentgain: percentgain)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you selected #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPath!) as! FriendsCustomTableViewCell!
        
        stockTickerParam = currentCell?.stockTicker.text
        stockPriceParam = currentCell?.stockPrice.text
        stockGainParam = currentCell?.stockGain.text
        print("ticker selected #\(stockTickerParam)")
        
        performSegue(withIdentifier: "FriendsStockDetailView", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue!, sender: Any!) {
        if (segue!.identifier == "FriendsStockDetailView") {
            let viewController = segue!.destination as! StockDetailViewController
            
            viewController.stockTickerSymbol = stockTickerParam
            viewController.stockPriceParam = stockPriceParam
            viewController.stockGainParam = stockGainParam
            
        }
    }
}

